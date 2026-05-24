

clean_nssh_stock_file <- function(nssh_stock_df) {
  nssh_stock_df |>
    janitor::clean_names()
}