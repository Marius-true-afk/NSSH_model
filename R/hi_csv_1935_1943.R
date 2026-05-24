
# Datasett fra HI (Norwegian Institute of Marine research)
# I only want data fra 1935 - 1943 to expand the other csv file

hi_csv_1935_1943 <- function(file_in, file_out) {
  df <- read_csv(file_in, show_col_types = FALSE)
  
  df <- df |> 
    filter(year >= 1935 & year <= 1943) |> 
    mutate(across(where(is.numeric), as.numeric))
  
  write_csv(df, file_out)
  
  return(file_out)
}
