

# Removes points that apperes inside the unwanted polygons
remove_unwanted_datapoints <- function(
    file_in,
    bbox,
    polygons,
    file_out,
    crs_projected = 32633
  ) {
  points_df <- readr::read_csv(file_in, show_col_types = FALSE)
  
  points_df <- points_df |> 
    dplyr::mutate(
      lon = suppressWarnings(as.numeric(lon)),
      lat = suppressWarnings(as.numeric(lat))
    ) |> 
    dplyr::filter(
      !is.na(lon),
      !is.na(lat),
      lon >= bbox$lon_min,
      lon <= bbox$lon_max,
      lat >= bbox$lat_min,
      lat <= bbox$lat_max
    )
  
  points_sf <- sf::st_as_sf(
    points_df,
    coords = c("lon", "lat"),
    crs= 4326,
    remove = FALSE
    )
  
  # Project to a planar CRS (meters)
  points_sf_proj <- sf::st_transform(points_sf, crs_projected)
  polygons_proj <- sf::st_transform(polygons, crs_projected)
  
  
  inside <- sf::st_intersects(
    points_sf_proj,
    polygons_proj,
    sparse = FALSE
    )
  
  keep_points <- !apply(inside, 1, any)
  
  
  herring_filtered <- points_df[keep_points, , drop = FALSE]
  
  readr::write_csv(herring_filtered, file_out)
  
  return(file_out)
}
  
