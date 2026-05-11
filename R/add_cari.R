# Guidance used: https://docs.wfp.org/api/documents/WFP-0000134704/download/

#' @title Add CARI Indicators
#'
#' @description Computes CARI domain indicators for the Consolidated Approach
#' for Reporting Indicators of Food Security (CARI).
#'
#' **Current Status** combines the Food Consumption Score category
#' (`fsl_fcs_cat`) and the reduced Coping Strategies Index score
#' (`fsl_rcsi_score`) into an integer score 1–4:
#'
#' * **1** (food secure): Acceptable FCS and rCSI score < 4
#' * **2** (marginally food secure): Acceptable FCS and rCSI score >= 4
#' * **3** (moderately food insecure): Borderline FCS (rCSI not considered)
#' * **4** (severely food insecure): Poor FCS (rCSI not considered)
#'
#' **Food Expenditure Share (FES)** is the proportion of food expenditure
#' relative to total expenditure (output of `add_expenditure_type_prop()`),
#' scored 1–4:
#'
#' * **1**: FES < 50%
#' * **2**: FES in \[50%, 65%)
#' * **3**: FES in \[65%, 75%)
#' * **4**: FES >= 75%
#'
#' **LCSI** is the Livelihood Coping Strategy category (output of `add_lcsi()`
#' from `impactR4PHU`), scored 1–4:
#'
#' * **1** (none): No coping strategies applied
#' * **2** (stress): Stress coping strategies applied
#' * **3** (crisis): Crisis coping strategies applied
#' * **4** (emergency): Emergency coping strategies applied
#'
#' Prerequisite: run `add_fcs()`, `add_rcsi()`, and `add_lcsi()` (from
#' `impactR4PHU`) and `add_expenditure_type_prop()` before calling this
#' function.
#'
#' @param df A data frame.
#' @param fcs_cat Column name for the FCS category.
#' @param fcs_cat_acceptable Level for Acceptable food consumption.
#' @param fcs_cat_borderline Level for Borderline food consumption.
#' @param fcs_cat_poor Level for Poor food consumption.
#' @param rcsi_score Column name for the rCSI score.
#' @param cm_expenditure_frequent_food_prop Column name for the food expenditure
#'   proportion relative to total expenditure (output of
#'   `add_expenditure_type_prop()`).
#' @param lcsi_cat Column name for the LCSI category (output of `add_lcsi()`).
#' @param lcsi_cat_none Level for no coping strategies applied.
#' @param lcsi_cat_stress Level for stress coping strategies applied.
#' @param lcsi_cat_crisis Level for crisis coping strategies applied.
#' @param lcsi_cat_emergency Level for emergency coping strategies applied.
#'
#' @return A data frame with additional columns:
#'
#' * `fsl_cari_current_status_score`: Integer score 1–4, or `NA`.
#' * `fsl_cari_fes_prop`: Food expenditure share (copy of
#'   `cm_expenditure_frequent_food_prop`), or `NA`.
#' * `fsl_cari_fes_score`: Integer score 1–4, or `NA`.
#' * `fsl_cari_lcsi_score`: Integer score 1–4, or `NA`.
#'
#' @export
add_cari <- function(
  df,
  fcs_cat = "fsl_fcs_cat",
  fcs_cat_acceptable = "Acceptable",
  fcs_cat_borderline = "Borderline",
  fcs_cat_poor = "Poor",
  rcsi_score = "fsl_rcsi_score",
  cm_expenditure_frequent_food_prop = "cm_expenditure_frequent_food_prop",
  lcsi_cat = "fsl_lcsi_cat",
  lcsi_cat_none = "None",
  lcsi_cat_stress = "Stress",
  lcsi_cat_crisis = "Crisis",
  lcsi_cat_emergency = "Emergency"
) {
  #------ Checks

  if_not_in_stop(
    df,
    c(fcs_cat, rcsi_score, cm_expenditure_frequent_food_prop, lcsi_cat),
    "df"
  )

  are_values_in_set(
    df,
    fcs_cat,
    c(fcs_cat_acceptable, fcs_cat_borderline, fcs_cat_poor)
  )

  are_values_in_range(df, rcsi_score, lower = 0, upper = 56)

  are_values_in_range(
    df,
    cm_expenditure_frequent_food_prop,
    lower = 0,
    upper = 1
  )

  are_values_in_set(
    df,
    lcsi_cat,
    c(lcsi_cat_none, lcsi_cat_stress, lcsi_cat_crisis, lcsi_cat_emergency)
  )

  #------ Compute current status

  df <- dplyr::mutate(
    df,
    fsl_cari_current_status_score = dplyr::case_when(
      .data[[fcs_cat]] == fcs_cat_acceptable & .data[[rcsi_score]] < 4 ~ 1L,
      .data[[fcs_cat]] == fcs_cat_acceptable & .data[[rcsi_score]] >= 4 ~ 2L,
      .data[[fcs_cat]] == fcs_cat_borderline ~ 3L,
      .data[[fcs_cat]] == fcs_cat_poor ~ 4L,
      .default = NA_integer_
    )
  )

  #------ Compute Food Expenditure Share (FES)

  df <- dplyr::mutate(
    df,
    fsl_cari_fes_prop = .data[[cm_expenditure_frequent_food_prop]],
    fsl_cari_fes_score = dplyr::case_when(
      is.na(.data[["fsl_cari_fes_prop"]]) ~ NA_integer_,
      .data[["fsl_cari_fes_prop"]] < 0.50 ~ 1L,
      .data[["fsl_cari_fes_prop"]] < 0.65 ~ 2L,
      .data[["fsl_cari_fes_prop"]] < 0.75 ~ 3L,
      .default = 4L
    )
  )

  #------ Compute LCSI score

  df <- dplyr::mutate(
    df,
    fsl_cari_lcsi_score = dplyr::case_when(
      .data[[lcsi_cat]] == lcsi_cat_none ~ 1L,
      .data[[lcsi_cat]] == lcsi_cat_stress ~ 2L,
      .data[[lcsi_cat]] == lcsi_cat_crisis ~ 3L,
      .data[[lcsi_cat]] == lcsi_cat_emergency ~ 4L,
      .default = NA_integer_
    )
  )

  return(df)
}
