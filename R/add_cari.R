# Guidance used: https://docs.wfp.org/api/documents/WFP-0000134704/download/

#' @title Add CARI Indicators
#'
#' @description Computes the Current Status domain of the Consolidated Approach
#' for Reporting Indicators of Food Security (CARI). Combines the Food
#' Consumption Score category (`fsl_fcs_cat`) and the reduced Coping Strategies
#' Index score (`fsl_rcsi_score`) into a categorical score:
#'
#' * **"food_secure"**: Acceptable FCS and rCSI score < 4
#' * **"marginally_food_secure"**: Acceptable FCS and rCSI score >= 4
#' * **"moderately_food_insecure"**: Borderline FCS (rCSI not considered)
#' * **"severely_food_insecure"**: Poor FCS (rCSI not considered)
#'
#' Prerequisite: run `add_fcs()` (from `impactR4PHU`) and `add_rcsi()` (from
#' `impactR4PHU`) before calling this function.
#'
#' @param df A data frame.
#' @param fcs_cat Column name for the FCS category.
#' @param fcs_cat_acceptable Level for Acceptable food consumption.
#' @param fcs_cat_borderline Level for Borderline food consumption.
#' @param fcs_cat_poor Level for Poor food consumption.
#' @param rcsi_score Column name for the rCSI score.
#'
#' @return A data frame with one additional column:
#'
#' * `fsl_cari_current_status_cat`: One of `"food_secure"`,
#'   `"marginally_food_secure"`, `"moderately_food_insecure"`,
#'   `"severely_food_insecure"`, or `NA`.
#'
#' @export
add_cari <- function(
  df,
  fcs_cat = "fsl_fcs_cat",
  fcs_cat_acceptable = "Acceptable",
  fcs_cat_borderline = "Borderline",
  fcs_cat_poor = "Poor",
  rcsi_score = "fsl_rcsi_score"
) {
  #------ Checks

  if_not_in_stop(df, c(fcs_cat, rcsi_score), "df")

  are_values_in_set(
    df,
    fcs_cat,
    c(fcs_cat_acceptable, fcs_cat_borderline, fcs_cat_poor)
  )

  are_values_in_range(df, rcsi_score, lower = 0, upper = 56)

  #------ Compute

  dplyr::mutate(
    df,
    fsl_cari_current_status_cat = dplyr::case_when(
      .data[[fcs_cat]] == fcs_cat_acceptable & .data[[rcsi_score]] < 4 ~
        "food_secure",
      .data[[fcs_cat]] == fcs_cat_acceptable & .data[[rcsi_score]] >= 4 ~
        "marginally_food_secure",
      .data[[fcs_cat]] == fcs_cat_borderline ~
        "moderately_food_insecure",
      .data[[fcs_cat]] == fcs_cat_poor ~
        "severely_food_insecure",
      .default = NA_character_
    )
  )
}
