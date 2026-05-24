
# Reads NSSH stock assessment file without further changes

read_nssh_stock_file <- function(file_path) {
  readr::read_csv(
    file_path,
    show_col_types = FALSE
  )
}