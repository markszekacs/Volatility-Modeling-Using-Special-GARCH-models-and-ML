# scripts/08_run_all.R
# One-command reproduction: data -> models (GARCH + ML) -> VaR -> backtests -> figures/tables
# Run from project root:

# ---- Sources
source("R/00_config.R")
source("R/01_data_io.R")
source("R/02_preprocess.R")
source("R/03_garch_specs.R")
source("R/04_garch_rollfit.R")
source("R/05_ml_baseline.R")
source("R/06_var_backtests.R")
source("R/07_outputs.R")   

cfg <- config_default()
set.seed(cfg$seed)

# ---- Helpers
ensure_dirs <- function(paths) {
  for (p in paths) dir.create(p, recursive = TRUE, showWarnings = FALSE)
}
ensure_dirs(c(cfg$processed_dir, cfg$outputs_dir, cfg$fig_dir, cfg$tab_dir))

# Standardize forecast format across GARCH/ML
standardize_forecast <- function(var_z, actual_z, model_name, dataset_name) {
  list(
    var = var_z,
    actual = actual_z,
    model = model_name,
    dataset = dataset_name
  )
}

# Write/append a single-row summary into an in-memory list (we write once at end)
make_backtest_row <- function(fc, bt, alpha) {
  data.frame(
    dataset = fc$dataset,
    model = fc$model,
    alpha = alpha,
    N = bt$uc$N,
    T = bt$uc$T,
    phat = bt$uc$phat,
    LRuc = bt$uc$LRuc,
    p_uc = bt$uc$p_value,
    LRind = bt$ind$LRind,
    p_ind = bt$ind$p_value,
    LRcc = bt$LRcc,
    p_cc = bt$p_value,
    stringsAsFactors = FALSE
  )
}

# ---- 1) Load/build processed returns
# Put your raw files under data/raw/ (not tracked in git).
# These file names match your current script usage patterns (e.g., generali.xlsx). Adjust as needed. :contentReference[oaicite:0]{index=0}
build_returns <- function(filename, date_format = "%m/%d/%Y") {
  load_or_build(
    rds_path = file.path(cfg$processed_dir, paste0(tools::file_path_sans_ext(filename), "_returns.rds")),
    builder_fn = function() {
      z <- read_series(file.path(cfg$raw_dir, filename), date_format = date_format)
      z <- coerce_clean_numeric(z)
      log_returns(z)
    }
  )
}

datasets <- list(
  allianz  = build_returns("allianz.xlsx"),
  generali = build_returns("generali.xlsx")
)

# ---- 2) Model registry (GARCH + ML)
# If you prefer, move this into config_default() and just read cfg$models here.
models <- list(
  list(type = "garch", key = "sGARCH11_norm", name = "sGARCH(1,1)-norm"),
  list(type = "garch", key = "eGARCH11_std",  name = "eGARCH(1,1)-t"),
  list(type = "garch", key = "apARCH11_ged",  name = "apARCH(1,1)-ged"),
  list(type = "ml",    key = "ml_ridge_abs_L20", name = "ML-Ridge(|r| lags, L=20)", L = 20, use_abs = TRUE)
)

# ---- 3) Run everything
all_backtest_rows <- list()
all_reports <- list()

for (ds_name in names(datasets)) {
  r <- datasets[[ds_name]]
  
  for (m in models) {
    
    # ---- Forecast (VaR + actual) in a standardized format
    if (m$type == "garch") {
      spec <- build_garch_spec(m$key)
      roll <- fit_garch_roll(
        spec = spec,
        returns_zoo = r,
        n_start = cfg$n_start,
        refit_every = cfg$refit_every,
        refit_window = cfg$refit_window,
        var_alpha = cfg$var_alpha
      )
      
      vf <- extract_var_forecast(roll)
      fc <- standardize_forecast(vf$var, vf$actual, m$name, ds_name)
      
      # Save rugarch VaR report text (optional but nice for audit trail)
      rep_lines <- var_report_table(roll, cfg$var_alpha)
      rep_path <- file.path(cfg$tab_dir, paste0(ds_name, "__", m$key, "__rugarch_VaR_report.txt"))
      write_lines(rep_lines, rep_path)
      all_reports[[paste(ds_name, m$key, sep = "__")]] <- rep_path
      
      model_obj <- roll
      
    } else if (m$type == "ml") {
      vf <- ml_var_forecast(
        returns_zoo = r,
        n_start = cfg$n_start,
        alpha = cfg$var_alpha,
        L = m$L,
        use_abs = m$use_abs
      )
      fc <- standardize_forecast(vf$var, vf$actual, m$name, ds_name)
      model_obj <- NULL
      
    } else {
      stop("Unknown model type: ", m$type)
    }
    
    # ---- Backtests (shared across GARCH and ML)
    I <- var_violations(fc$actual, fc$var)
    bt <- cc_test(I, cfg$var_alpha)
    
    # ---- Save plot (shared)
    fig_path <- file.path(
      cfg$fig_dir,
      paste0(ds_name, "__", gsub("[^A-Za-z0-9]+", "_", m$key), "__VaR.png")
    )
    save_var_plot(
      actual_z = fc$actual,
      var_z = fc$var,
      title = paste0("VaR Backtest: ", toupper(ds_name), " | ", fc$model),
      out_path = fig_path
    )
    
    # ---- Collect summary row
    all_backtest_rows[[length(all_backtest_rows) + 1]] <- make_backtest_row(fc, bt, cfg$var_alpha)
    
    # ---- Keep objects for debugging/reuse
    saveRDS(list(forecast=fc, backtest=bt, model=model_obj), file.path(cfg$processed_dir, paste0(ds_name,"__",m$key,"__obj.rds")))
  }
}

# ---- 4) Write final summary tables once
backtests_df <- do.call(rbind, all_backtest_rows)
summary_path <- file.path(cfg$tab_dir, "backtests_summary.csv")
write.csv(backtests_df, summary_path, row.names = FALSE)

# Also save a compact RDS for reproducibility
saveRDS(
  list(
    config = cfg,
    backtests = backtests_df,
    reports = all_reports
  ),
  file.path(cfg$processed_dir, "run_summary.rds")
)

message("Done.")
message("Backtest summary: ", summary_path)
message("Figures in: ", cfg$fig_dir)
message("Tables in: ", cfg$tab_dir)
