# R/03_garch_specs.R
#' Build ugarchspec objects by name
build_garch_spec <- function(key) {
  if (key == "sGARCH11_norm") {
    rugarch::ugarchspec(
      mean.model = list(armaOrder = c(0, 0)),
      variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
      distribution.model = "norm"
    )
  } else if (key == "eGARCH11_std") {
    rugarch::ugarchspec(
      mean.model = list(armaOrder = c(0, 0)),
      variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
      distribution.model = "std"
    )
  } else if (key == "apARCH11_ged") {
    rugarch::ugarchspec(
      mean.model = list(armaOrder = c(0, 0)),
      variance.model = list(model = "apARCH", garchOrder = c(1, 1)),
      distribution.model = "ged"
    )
  } else {
    stop("Unknown model key: ", key)
  }
}