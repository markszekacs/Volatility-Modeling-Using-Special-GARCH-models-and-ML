# R/06_var_backtests.R
# Simple violation indicator: actual < VaR (a te definíciód szerint a report is ezt nézi) :contentReference[oaicite:9]{index=9}
var_violations <- function(actual_z, var_z) {
  a <- as.numeric(actual_z)
  v <- as.numeric(var_z)
  stopifnot(length(a) == length(v))
  as.integer(a < v)
}

kupiec_uc <- function(I, alpha) {
  # LR_UC Kupiec (1995)
  T <- length(I); N <- sum(I)
  phat <- N / T
  # handle edge cases
  eps <- 1e-12
  phat <- min(max(phat, eps), 1 - eps)
  alpha <- min(max(alpha, eps), 1 - eps)
  
  logL0 <- (T - N) * log(1 - alpha) + N * log(alpha)
  logL1 <- (T - N) * log(1 - phat) + N * log(phat)
  LRuc <- -2 * (logL0 - logL1)
  pval <- stats::pchisq(LRuc, df = 1, lower.tail = FALSE)
  list(LRuc = LRuc, p_value = pval, T = T, N = N, phat = phat)
}

christoffersen_ind <- function(I) {
  # Independence test (Christoffersen 1998) using 2-state Markov transitions
  I <- as.integer(I)
  T <- length(I)
  I_lag <- I[-T]
  I_now <- I[-1]
  
  n00 <- sum(I_lag == 0 & I_now == 0)
  n01 <- sum(I_lag == 0 & I_now == 1)
  n10 <- sum(I_lag == 1 & I_now == 0)
  n11 <- sum(I_lag == 1 & I_now == 1)
  
  p01 <- if ((n00 + n01) == 0) 0 else n01 / (n00 + n01)
  p11 <- if ((n10 + n11) == 0) 0 else n11 / (n10 + n11)
  p1  <- (n01 + n11) / (n00 + n01 + n10 + n11)
  
  eps <- 1e-12
  p01 <- min(max(p01, eps), 1 - eps)
  p11 <- min(max(p11, eps), 1 - eps)
  p1  <- min(max(p1,  eps), 1 - eps)
  
  logL_ind <- n00*log(1-p01) + n01*log(p01) + n10*log(1-p11) + n11*log(p11)
  logL_p1  <- (n00+n10)*log(1-p1) + (n01+n11)*log(p1)
  
  LRind <- -2 * (logL_p1 - logL_ind)
  pval <- stats::pchisq(LRind, df = 1, lower.tail = FALSE)
  
  list(LRind = LRind, p_value = pval, n00 = n00, n01 = n01, n10 = n10, n11 = n11)
}

cc_test <- function(I, alpha) {
  uc <- kupiec_uc(I, alpha)
  ind <- christoffersen_ind(I)
  LRcc <- uc$LRuc + ind$LRind
  pval <- stats::pchisq(LRcc, df = 2, lower.tail = FALSE)
  list(LRcc = LRcc, p_value = pval, uc = uc, ind = ind)
}