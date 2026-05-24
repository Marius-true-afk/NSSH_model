
# when only reading Herring_data_Katja.csv i get these bounds

#  lon_min     lon_max      lat_min       lat_max
# -21.16667	   54.88333	    58.00833	    80.59333

# when combining the csv files, i get these bounds

#  lon_min     lon_max      lat_min       lat_max
# -4.916667	     32	           5	        70.41667	

# Defines global bounding box based on Stenevik et. al. (2022) metadata:
# boundingboxWKTPOLYGON((49.9 56.9,-21.9 56.9,-21.9 77.1,49.9 77.1,49.9 56.9))
# Observations outside this region are considered irrelevant and are removed

define_bbox <- function() {
  list(
    lon_min = -22,
    lon_max = 56,
    lat_min = 57,
    lat_max = 82
  )
}

# References
# Erling Kåre Stenevik (HI), Sondre Hølleland (HI), Katja Enberg (UiB), 
# Åge Høines (HI), Are Salthaug (HI), Aril Slotte (HI), Sindre Vathehol (HI),
# Sondre Aanes (NR) (2022) Individual samples of Norwegian Spring Spawning
# herring 1935-2019 https://doi.org/10.21335/NMDC-496562593

# ----------------------------------------------------------------------

# The data contains some obvious errors as they are located domestically
# in Norway and Russia. These points needs to be removed.

# The coordinates for the polygons is found visually using Google maps 
# and controlled by using a dashed bbox on top of the distribution map to
# control the accuracy of the point removal.
make_polygons <- function() {
  poly_norway_russia <- st_polygon(list(rbind(
    c(11.4, 57.6),
    c(11.4, 62.8),
    c(50.0, 62.8),
    c(50.0, 57.6),
    c(11.4, 57.6)
  )))
  poly_inland_norway <- st_polygon(list(rbind(
    c(23.1, 68.6),
    c(23.1, 68.0),
    c(24.7, 68.0),
    c(24.7, 68.6),
    c(23.1, 68.6)
  )))
  st_sfc(poly_norway_russia, poly_inland_norway, crs = 4326)
}

# ----------------------------------------------------------------------
