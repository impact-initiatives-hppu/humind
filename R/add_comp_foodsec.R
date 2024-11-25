#' Food security sectoral composite - add score and dummy for in need
#'
#' @param df A data frame.
#' @param fc_phase Column name for the food security phase.
#' @param phase1 Label for Phase 1 FC.
#' @param phase2 Label for Phase 2 FC.
#' @param phase3 Label for Phase 3 FC.
#' @param phase4 Label for Phase 4 FC.
#' @param phase5 Label for Phase 5 FC.
#'
#' @export
add_comp_foodsec <- function(
    df,
    fc_phase = "fsl_fc_phase",
    phase1 = "Phase 1 FC",
    phase2 = "Phase 2 FC",
    phase3 = "Phase 3 FC",
    phase4 = "Phase 4 FC",
    phase5 = "Phase 5 FC"){

  #------ Checks

  # Check if fc_phase is in df
  if_not_in_stop(df, fc_phase, "df")

  # Check if all phases are in df
  fc_phase_levels <- c(phase1, phase2, phase3, phase4, phase5)
  are_values_in_set(df, fc_phase, fc_phase_levels)

  #------ Score

  # Score
  df <- dplyr::mutate(
    df,
    comp_foodsec_score = dplyr::case_when(
      !!rlang::sym(fc_phase) == phase5 ~ 5,
      !!rlang::sym(fc_phase) == phase4 ~ 4,
      !!rlang::sym(fc_phase) == phase3 ~ 3,
      !!rlang::sym(fc_phase) == phase2 ~ 2,
      !!rlang::sym(fc_phase) == phase1 ~ 1,
      .default =  NA_real_
    )
  )

  # Is in need?
  df <- is_in_need(
    df,
    "comp_foodsec_score",
    "comp_foodsec_in_need"
  )

  # Is in acute need?
  df <- is_in_acute_need(
    df,
    "comp_foodsec_score",
    "comp_foodsec_in_acute_need"
  )

  return(df)

}
