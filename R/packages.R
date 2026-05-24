
# Core packages shared between interactive work and pipeline

core_packages <- c(
    "tibble",
    "ggplot2",
    "dplyr",
    "maps",
    "stringr",
    "here",
    "sf",
    "rnaturalearth",
    "rnaturalearthdata",
    "ggspatial",
    "prettymapr",
    "readxl",
    "readr",
    "targets",
    "janitor",
    "glue",
    "tidyverse",
    "broom",
    "knitr",
    "lubridate"
  )

load_core_packages <- function(pkgs = core_packages) {
  to_load <- setdiff(pkgs, loadedNamespaces())
  invisible(lapply(pkgs, require, character.only = TRUE))
}