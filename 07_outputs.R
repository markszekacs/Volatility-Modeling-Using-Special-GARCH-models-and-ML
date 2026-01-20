# R/07_outputs.R
save_var_plot <- function(actual_z, var_z, title, out_path) {
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  grDevices::png(out_path, width = 1400, height = 900, res = 140)
  on.exit(grDevices::dev.off(), add = TRUE)
  
  plot(actual_z, main = title, xlab = "Date", ylab = "Return / VaR", type = "l")
  lines(var_z, col = "red")
  legend("topright", legend = c("Actual", "VaR"), col = c("black", "red"), lty = c(1, 1))
}

write_lines <- function(lines_vec, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(lines_vec, con = path)
}