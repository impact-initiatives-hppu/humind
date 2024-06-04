#' Food security sectoral composite - add score and dummy for in need
#'
#' @param df A data frame.
#' @param fc_phase Column name for the food security phase.
#' @param fc_phase_levels Levels of the food security phase.
#'
#' @export
comp_foodsec <- function(
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
    comp_foodsec_score = dplyr::case_when(
      !!rlang::sym(fc_phase) == fc_phase_levels[5] ~ 5,
      !!rlang::sym(fc_phase) == fc_phase_levels[4] ~ 4,
      !!rlang::sym(fc_phase) == fc_phase_levels[3] ~ 3,
      !!rlang::sym(fc_phase) == fc_phase_levels[2] ~ 2,
      !!rlang::sym(fc_phase) == fc_phase_levels[1] ~ 1,
      .default =  NA_real_
    )
  )

  # Is in need?
  df <- is_in_need(
    df,
    "comp_foodsec_score",
    "comp_foodsec_in_need"
  )

  return(df)

}
