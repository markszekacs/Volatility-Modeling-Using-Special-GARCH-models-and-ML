# R/04_garch_rollfit.R
fit_garch_roll <- function(spec, returns_zoo, n_start, refit_every, refit_window, var_alpha) {
  rugarch::ugarchroll(
    spec,
    data = returns_zoo,
    n.start = n_start,
    refit.every = refit_every,
    refit.window = refit_window,
    calculate.VaR = TRUE,
    VaR.alpha = var_alpha
  )
}

extract_var_forecast <- function(roll_obj) {
  # VaR: col1 forecast VaR, col2 actual (ahogy nálad is) :contentReference[oaicite:7]{index=7}
  VaR_mat <- roll_obj@forecast$VaR
  dates <- as.Date(rownames(VaR_mat))
  list(
    var = zoo::zoo(VaR_mat[, 1], dates),
    actual = zoo::zoo(VaR_mat[, 2], dates)
  )
}

var_report_table <- function(roll_obj, var_alpha) {
  # rugarch report() stdout-ot ad; ezt capture-öljük file-ba is
  out <- utils::capture.output(rugarch::report(roll_obj, type = "VaR", VaR.alpha = var_alpha))
  out
}
