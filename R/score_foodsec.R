#' Add score for food security
#'
#' @param df A data frame.
#' @param fc_phase Column name for the food security phase.
#' @param fc_phase_levels Levels of the food security phase.
#'
#' @export
score_foodsec <- function(
    df,
    fc_phase = "fsl_fc_phase",
    fc_phase_levels = c("Phase 1 FC", "Phase 2 FC", "Phase 3 FC", "Phase 4 FC", "Phase 5 FC")){

  #------ Checks

  # Check if fc_phase is in df
  if_not_in_stop(df, fc_phase, "df")

  # Check if fc_phase_levels are in df
  are_values_in_set(df, fc_phase, fc_phase_levels)

  #------ Score

  # Score
  df <- dplyr::mutate(
    df,
    foodsec_score = dplyr::case_when(
      df[[fc_phase]] == fc_phase_levels[5] ~ 5,
      df[[fc_phase]] == fc_phase_levels[4] ~ 4,
      df[[fc_phase]] == fc_phase_levels[3] ~ 3,
      df[[fc_phase]] == fc_phase_levels[2] ~ 2,
      df[[fc_phase]] == fc_phase_levels[1] ~ 1,
      .default =  NA_real_
    )
  )

  return(df)

}
