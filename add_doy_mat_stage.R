
# day-of-year (DOY) target + function
# used to find the mean day of maturing
# Leap years is not taken into consideration as it should not affect the result

add_doy_mat_stage <- function(data) {
  data |> 
    # columns in combined dataset
    dplyr::select(year, age, day, month, maturity, lat, lon, gear, length) |>
    dplyr::mutate(                                        
      # Adds column for date
      date = lubridate::make_date(year, month, day),
      doy = lubridate::yday(date), # Day of year 1-365
      
      # Adds column for maturity stage (ignores cases where maturity is missing)
      # Bin intervals  from HI fish sample manual (Mjanger et. al., 2022)
      maturity_bin = dplyr::case_when(
        maturity >= 3 & maturity <= 4 ~ 0L, # maturity 3-4 = maturing
        maturity >= 5 & maturity <= 6 ~ 1L, # maturity 5-6 = spawning
        .default = NA                       # everything else is ignored
      )
    ) |> 
    # Sorts data in chronological order withing each year
    dplyr::arrange(year, doy)
}

# References:
# Mjanger, H., Svendsen, B. V., Fuglebakk, E., Gulbrandsen, M. L.,
# Diaz, J., Johansen, G. O., Vollen, T., Bruck, S. A., & Gundersen, S. (2022).
# Håndbok for prøvetaking av fisk, krepsdyr og andre evertebrater.
# Havforskningsinstituttets kvalitetssystem, Version: FOU.SPD.HB-01, 145.



