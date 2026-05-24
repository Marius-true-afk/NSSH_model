
# Filter out invalid (mainly missing) maturity value before modelling

# input "data"  is a df returned by add_doy_mat_stage()
# output is cleaned df with valid maturity_bin and doy values

clean_maturity <- function(data) {
  data |> 
    dplyr::filter(
      !is.na(maturity),      # From combined raw datasets
      !is.na(maturity_bin),  # binary maturity stage
      !is.na(doy),           # day-of-year
      maturity >= 1,
      maturity <= 7
    )
}