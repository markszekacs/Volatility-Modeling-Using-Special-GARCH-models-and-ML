# R/02_preprocess.R
#' Coerce zoo series to numeric coredata, drop missing
coerce_clean_numeric <- function(z) {
  z <- stats::na.omit(z)
  # gyakori: az első oszlop dátum, maradék 1 oszlop érték
  z <- z[, ncol(z), drop = FALSE]
  x <- as.numeric(zoo::coredata(z))
  zoo::zoo(x, zoo::index(z))
}

#' Compute log-returns from price series
log_returns <- function(price_zoo) {
  p <- as.numeric(price_zoo)
  r <- diff(log(p))
  zoo::zoo(as.numeric(r), zoo::index(price_zoo)[-1])
}
