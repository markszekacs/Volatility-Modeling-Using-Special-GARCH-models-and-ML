# R/01_data_io.R
#' Read a single-column price/return series from Excel/CSV and return zoo
read_series <- function(path, date_format = "%m/%d/%Y") {
  stopifnot(file.exists(path))
  
  ext <- tools::file_ext(path)
  if (ext %in% c("xlsx", "xls")) {
    x <- readxl::read_excel(path)
    z <- zoo::read.zoo(x, FUN = as.Date, format = date_format, header = TRUE)
  } else if (ext == "csv") {
    x <- read.csv(path)
    z <- zoo::read.zoo(x, FUN = as.Date, format = date_format, header = TRUE, sep = ",")
  } else {
    stop("Unsupported file extension: ", ext)
  }
  z
}

#' Save processed data as .rds (reproducibility/cache)
save_processed <- function(obj, out_path) {
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(obj, out_path)
  invisible(out_path)
}

#' Load processed .rds if exists, otherwise build it
load_or_build <- function(rds_path, builder_fn) {
  if (file.exists(rds_path)) return(readRDS(rds_path))
  obj <- builder_fn()
  save_processed(obj, rds_path)
  obj
}S
