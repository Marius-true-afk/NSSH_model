
# ----------------------------------------------------------------
# _targets.R - Main pipeline definition for Master_targets project
#
# NOTE: When I first created the pipeline i used two different csv files
# with data from 1935-1944 and 1944-2019. After guidance from supervisor
# I removed the data for 1935 - 1944. This lead to this file being
# very un-organized. If time, I will remove the legacy code and clean the file.
# If you are reading this, I did not have time to fix it.
#
# All legacy code is marked with "LEGACY CODE" in before coding chunck and
# should be ignored.
# ----------------------------------------------------------------


# ------------------ Define project root ------------------

if (requireNamespace("here", quietly = TRUE)) {
  here::i_am("_targets.R")
}


# ------------------ Load core packages ------------------
library(targets)


# Resolves potential conflicts
library(conflicted)

# Tidyverse packages
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")
conflict_prefer("map", "purrr")

# Uses base variant as standard
conflict_prefer("setdiff", "base")
conflict_prefer("intersect", "base")
conflict_prefer("union", "base")
conflict_prefer("setequal", "base")


# Find and source R/packages.R independently of working directory
packages_path <- if (requireNamespace("here", quietly = TRUE)) {
  here::here("R", "packages.R")
} else {
  file.path("R", "packages.R")
}

if (file.exists(packages_path)) {
  source(packages_path) # Defines core_packages
} else {
  stop("Could not find 'R/packages.R'.")
}
# ------------------ Set global options ------------------

# Stability settings to run 80MB files

tar_option_set(
  packages = core_packages,        # from R/packages.R,
  memory = "transient",            # releases memory after each targets
  garbage_collection = TRUE,       # keeps memory usage low
  error = "continue",              # continue even though a targets fails
  cue = tar_cue(mode = "thorough") # re-run targets when functions change
  )

# Disables S2-geometry 
sf::sf_use_s2(FALSE)


# ------------------ Source custom R functions ------------------
# Run the R scripts in the R/ folder with your custom functions:
if (requireNamespace("here", quietly = TRUE)) {
  tar_source(here::here("R"))
} else {
  tar_source()
}


# ------------------ Define targets ------------------
list(
  
  
  # ------------------ targets from R/data_prep/ ------------------
  
  # Bounding box parameter
  tar_target(
    bbox,
    define_bbox()
  ),
  
  
  # Makes the polygons for the unwanted datapoints
  tar_target(
    polygons,
    make_polygons()
  ),
  
  # Input and cleaning of "Herring_Data_Katja.csv"
  tar_target(
    katja_data_clean,
    {
      out <- here("data", "Herring_data_Katja_clean.csv")
      df <- clean_herring_data(
        file_in = here("data", "Herring_data_Katja.csv"),
        file_out = out
      )
      write_csv(df, out)
      out
    },
    format = "file"
  ),
  
  # Input and filter of HI data - NOTE: NOT USED - LEGACY CODE AS OF 07.05.2026
  #tar_target(
  #  hi_data_filtered,
  #  hi_csv_1935_1943(
  #    file_in = here("data", "HerringData.csv"),
  #    file_out = here("data", "HerringData_1935_1943.csv")
  #  ),
  #  format = "file"
  #),
  
  #combined Katja + HI data set - NOTE: NOT USED - LEGACY CODE AS OF 07.05.2026
  #tar_target(
  #  combined_data,
  #  combine_csv_files(
  #    katja_path = katja_data_clean,
  #    hi_path = hi_data_filtered,
  #    output_path = here("data", "Herring_data_combined.csv")
  #  ),
  #  format = "file"
  #),
  

  
  # Write the result as a finished csv file which is processed - NOTE: NOT USED - LEGACY CODE AS OF 07.05.2026
  #tar_target(
  #  herring_combined_complete,
  #  remove_unwanted_datapoints(
  #    file_in = combined_data,
  #    polygons = polygons,
  #    bbox = bbox,
  #    file_out = here("data", "Herring_data_combined_complete_v4.csv")
  #  ),
  #  format = "file"
  #),
  
  # Write the result as a finished csv file which is processed - REPLACES LEGACY CODE
  tar_target(
    herring_combined_complete,
    remove_unwanted_datapoints(
      file_in = katja_data_clean,
      polygons = polygons,
      bbox = bbox,
      file_out = here("data", "Herring_data_Katja_complete.csv")
    ),
    format = "file"
  ),
  
  # Read combined, filtered and finished data set as data frame
  tar_target(
    herring_combined_df,
    read_csv(herring_combined_complete, show_col_types = FALSE)
  ),
  
  # ------------------ targets from R/analysis/ ------------------
  
  # Parameter targets - LEGACY CODE AS OF 07.05.2026 
  #tar_target(year_selected, 1974),
  #tar_target(doy_max, 364),
  
  # Calculates DOY and maturity stage
  tar_target(
    herring_doy_mat,
    add_doy_mat_stage(herring_combined_df)
  ),
  
  # From R/data_prep/ - clears NA values in maturity after calculating
  # DOY and maturity stage
  tar_target(
    herring_analysis_df,
    clean_maturity(herring_doy_mat)
  ),
  
  # Temperature CSV file in the project
  tar_target(
    temperature_file,
    here::here("data", "Monthly_mean_1_100m_Norwegian_coastal_stations_1940_2020.csv"),
    format = "file"
  ),
  
  # Read temperature data
  tar_target(
    temperature_df,
    utils::read.csv(
      temperature_file,
      stringsAsFactors = FALSE
    )
  ),
  
  # Compute one shared seasonal mean temperature per season year
  tar_target(
    seasonal_mean_temp_df,
    compute_seasonal_mean_temp(temperature_df)
  ),
  
  # Join shared seasonal temperature onto herring data
  tar_target(
    herring_analysis_temp_df,
    join_seasonal_mean_temp(
      herring_analysis_df = herring_analysis_df,
      seasonal_mean_temp_df = seasonal_mean_temp_df
    )
  ),
  
  # NSSH stock assessment CSV file
  tar_target(
    nssh_stock_file,
    here::here("data", "NSSH_stock_assessment_1950_2014.csv"),
    format = "file"
  ),
  
  # Read NSSH stock assessment data
  tar_target(
    nssh_stock_df,
    read_nssh_stock_file(nssh_stock_file)
  ),
  
  # Clean NSSH stock assessment file column names
  tar_target(
    nssh_stock_clean_df,
    clean_nssh_stock_file(nssh_stock_df)
  ),
  
  # Join NSSH stock assessment data onto herring analysis data
  tar_target(
    herring_analysis_stock_df,
    join_nssh_stock_file(
      herring_analysis_temp_df = herring_analysis_temp_df,
      nssh_stock_clean_df = nssh_stock_clean_df
    )
  ),
  
  # NAO CSV file
  tar_target(
    nao_file,
    here::here("data", "nao_monthly_wide.csv"),
    format = "file"
  ),
  
  # Read NAO data
  tar_target(
    nao_wide_df,
    read_nao_file(nao_file)
  ),
  
  # Compute winter NAO index
  tar_target(
    nao_index_df,
    create_nao_index(nao_wide_df)
  ),
  
  # Join NAO index onto herring analysis data
  tar_target(
    herring_analysis_nao_df,
    join_nao_index(
      herring_analysis_stock_df = herring_analysis_stock_df,
      nao_index_df = nao_index_df
    )
  ),
  
  # Build final modeling dataset with temperature, stock, and NAO
  tar_target(
    herring_model_df,
    build_herring_model_df(
      herring_analysis_df = herring_analysis_df,
      seasonal_mean_temp_df = seasonal_mean_temp_df,
      nssh_stock_clean_df = nssh_stock_clean_df,
      nao_index_df = nao_index_df
    )
  )
    
  # Filters for years and DOY-range
  #tar_target(
  #  doy_data,
  #  filter_doy_year(
  #    herring_analysis_df,
  #    year_filter = year_selected,
  #    doy_max = doy_max
  #  )
  #),
  
  # Generalized logistic model
  #tar_target(
  #  mod_doy_mat,
  #  glm(maturity_bin ~ doy, data = doy_data, family = binomial())
  #  ),
  
  # --- TEST: Maximum likelihood estimation ---
  #tar_target(
  #  mod_doy_mat,
  #  glm(maturity_bin ~ doy, data = doy_data, family = binomial(link = "logit"))
  #),
  
  # Statistical summary
  #tar_target(
  #  mod_summary_tbl,
  #  mod_summary(mod_doy_mat)
  #),
  
  # Statistical summary formatted as table
  #tar_target(
  #  mod_summary_kable,
  #  kable(
  #    mod_summary_tbl,
  #    caption = "Summary of logstic model with estimated DOY50%",
  #    align = "lccrr"
  #  )
  #),
  
  # Plot of maturity curve with 95% confidence interval (CI)
  #tar_target(
  #  maturity_plot,
  #  plot_maturity_curve(
  #    mod_doy_mat,
  #    doy_data,
  #    year = year_selected,
  #    doy_max = doy_max)
  #)
)
  

