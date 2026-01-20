# R/00_config.R
config_default <- function() {
  list(
    seed = 42,
    
    # data
    raw_dir = "data/raw",
    processed_dir = "data/processed",
    outputs_dir = "outputs",
    fig_dir = "outputs/figures",
    tab_dir = "outputs/tables",
    
    # rolling settings (a scriptedben ez tipikusan 2400, 250/365 stb.) :contentReference[oaicite:2]{index=2}
    n_start = 2400,
    refit_every = 250,
    refit_window = "moving",
    
    # risk settings
    var_alpha = 0.01,
    
    # models to run (kulcsok: saját elnevezésed)
    models <- list(
      list(type="garch", key="apARCH11_ged"),
      list(type="garch", key="eGARCH11_std"),
      list(type="ml",    key="ml_ridge_abs", L=20, use_abs=TRUE)
    )
}