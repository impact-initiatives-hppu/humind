#' @title Calculate Food Security Sectoral Composite Score and Need Indicators
#'
#' @description
#' This function calculates a food security sectoral composite score based on
#' the FCLCM phase. It assigns a score from 1 to 5 corresponding to
#' the FCLCM phase, and determines if a household is in need or in
#' severe need of food security assistance.
#'
#' Prerequisite food security functions
#' must be run before this function:
#'
#' * [add_fcs()]
#' * [add_hhs()]
#' * [add_rcsi()]
#' * [add_lcsi()]
#' * [add_fclcm_phase()]
#'
#'
#' @param df A data frame.
#' @param fclcm_phase Column name for the FCLCM phase.
#' @param phase1 Label for Phase 1 FCLC.
#' @param phase2 Label for Phase 2 FCLC.
#' @param phase3 Label for Phase 3 FCLC.
#' @param phase4 Label for Phase 4 FCLC.
#' @param phase5 Label for Phase 5 FCLC.
#'
#' @return A data frame with additional columns:
#'
#' * comp_foodsec_score: Food security composite score (1-5)
#' * comp_foodsec_in_need: Binary indicator for being in need of food security assistance
#' * comp_foodsec_in_severe_need: Binary indicator for being in severe need of food security assistance
#'
#' @export
add_comp_foodsec <- function(
  df,
  fclcm_phase = "fclcm_phase",
  phase1 = "Phase 1 FCLC",
  phase2 = "Phase 2 FCLC",
  phase3 = "Phase 3 FCLC",
  phase4 = "Phase 4 FCLC",
  phase5 = "Phase 5 FCLC"
) {
  #------ Checks

  # Check if fclcm_phase is in df
  if_not_in_stop(df, fclcm_phase, "df")

  # Check if all phases are in df
  fclcm_phase_levels <- c(phase1, phase2, phase3, phase4, phase5)
  are_values_in_set(df, fclcm_phase, fclcm_phase_levels)

  #------ Score

  # Score
  df <- dplyr::mutate(
    df,
    comp_foodsec_score = dplyr::case_when(
      !!rlang::sym(fclcm_phase) == phase5 ~ 5,
      !!rlang::sym(fclcm_phase) == phase4 ~ 4,
      !!rlang::sym(fclcm_phase) == phase3 ~ 3,
      !!rlang::sym(fclcm_phase) == phase2 ~ 2,
      !!rlang::sym(fclcm_phase) == phase1 ~ 1,
      .default = NA_real_
    )
  )

  # Is in need?
  df <- is_in_need(
    df,
    "comp_foodsec_score",
    "comp_foodsec_in_need"
  )

  # Is in severe need?
  df <- is_in_severe_need(
    df,
    "comp_foodsec_score",
    "comp_foodsec_in_severe_need"
  )

  df
}
