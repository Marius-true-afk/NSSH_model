
read_nao_file <- function(file_path) {
  readr::read_csv(
    file_path,
    show_col_types = FALSE
  )
}