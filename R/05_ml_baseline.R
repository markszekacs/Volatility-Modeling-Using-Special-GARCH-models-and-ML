# R/05_ml_baseline.R
# Requires: glmnet

make_lag_matrix <- function(x, L) {
  # x numeric vector
  n <- length(x)
  X <- sapply(1:L, function(k) x[(L + 1 - k):(n - k)])
  y <- x[(L + 1):n]
  list(X = X, y = y)
}

ml_var_forecast <- function(returns_zoo, n_start, alpha, L = 20, use_abs = TRUE) {
  r <- as.numeric(returns_zoo)
  dates <- zoo::index(returns_zoo)
  
  target <- if (use_abs) abs(r) else r^2
  feat_src <- target
  
  # build lagged design
  mm <- make_lag_matrix(feat_src, L)
  X <- mm$X
  y <- mm$y
  out_dates <- dates[(L + 1):length(dates)]
  
  # rolling forecasts start at n_start (aligned to X/y)
  start_idx <- n_start - L
  if (start_idx < 50) stop("n_start too small given L")
  
  sigma_hat <- rep(NA_real_, length(y))
  
  for (t in seq(start_idx, length(y) - 1)) {
    X_train <- X[1:t, , drop = FALSE]
    y_train <- y[1:t]
    
    # ridge (alpha=0); cv chooses lambda
    fit <- glmnet::cv.glmnet(X_train, y_train, alpha = 0)
    sigma_hat[t + 1] <- as.numeric(stats::predict(fit, newx = X[t + 1, , drop = FALSE], s = "lambda.min"))
  }
  
  # Turn sigma forecast into VaR (mean=0 baseline)
  q <- stats::qnorm(alpha)
  var_hat <- q * sigma_hat
  
  # align with actual returns at same horizon (t+1)
  actual <- r[(L + 1):length(r)]
  
  # keep only from start_idx+1 onward where sigma_hat exists
  keep <- which(!is.na(var_hat))
  list(
    var = zoo::zoo(var_hat[keep], out_dates[keep]),
    actual = zoo::zoo(actual[keep], out_dates[keep])
  )
}
