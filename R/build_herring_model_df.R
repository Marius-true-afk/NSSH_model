
build_herring_model_df <- function(
    herring_analysis_df,
    seasonal_mean_temp_df,
    nssh_stock_clean_df,
    nao_index_df
) {
  herring_analysis_df |>
    dplyr::left_join(
      seasonal_mean_temp_df,
      by = dplyr::join_by(year == season_year)
    ) |>
    dplyr::left_join(
      nssh_stock_clean_df,
      by = dplyr::join_by(year)
    ) |>
    dplyr::left_join(
      nao_index_df,
      by = dplyr::join_by(year)
    )
}