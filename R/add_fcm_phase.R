#' Add the food consumption matrix to the dataset
#'
#' @description Combines food consumption, coping strategy, and hunger scale
#' categories to produce a food consumption matrix cell and phase.
#'
#' Prerequisite functions:
#'
#' * [add_fcs()] — produces the food consumption score category
#' * [add_rcsi()] — produces the reduced coping strategy index category
#' * [add_hhs()] — produces the household hunger scale categories
#'
#' @param .dataset Main Dataset
#' @param fcs_column_name A string specifying the column name of the food consumption score in the dataset
#' @param rcsi_column_name A string specifying the column name of the reduced coping strategy index in the dataset
#' @param hhs_column_name A string specifying the column name of the household hunger scale in the dataset
#' @param hdds_column_name A string specifying the column name of the household dietary diversity score in the dataset
#' @param fcs_categories_acceptable The name of the value "Acceptable" (by default) in the fcs categories
#' @param fcs_categories_poor The name of the value "Poor" (by default) in the fcs categories
#' @param fcs_categories_borderline The name of the value "Borderline" (by default) in the fcs categories
#' @param rcsi_categories_low The name of the value "No to Low" (by default) in the rcsi categories
#' @param rcsi_categories_medium The name of the value "Medium" (by default) in the rcsi categories
#' @param rcsi_categories_high The name of the value "High" (by default) in the rcsi categories
#' @param hhs_categories_none The name of the value "None" (by default) in the hhs categories
#' @param hhs_categories_little The name of the value "Little" (by default) in the hhs categories
#' @param hhs_categories_moderate The name of the value "Moderate" (by default) in the hhs categories
#' @param hhs_categories_severe The name of the value "Severe" (by default) in the hhs categories
#' @param hhs_categories_very_severe The name of the value "Very Severe" (by default) in the hhs categories
#' @param hdds_categories_low The name of the value "Low" (by default) in the hdds categories
#' @param hdds_categories_medium The name of the value "Medium" (by default) in the hdds categories
#' @param hdds_categories_high The name of the value "High" (by default) in the hdds categories
#'
#'
#' @return this function returns a dataframe with a column called fc_cell that includes values from 1 to 45
#' representing the Food Consumption Score Matrix and the fc_phase column that includes the different 5 phases
#' of food consumption
#' @export
#' @importFrom dplyr case_when mutate
#'
#'
#' @examples
#' test_data <- data.frame(
#'   fsl_fcs_cat = c("Acceptable", "Poor", "Borderline", "Acceptable"),
#'   fsl_rcsi_cat = c("No to Low", "Medium", "No to Low", "High"),
#'   fsl_hhs_cat = c("None", "Little", "Severe", "Very Severe"),
#'   fsl_hdds_cat = c("Low", "High", "Medium", "High")
#' )
#' add_fcm_phase(test_data,
#'   fcs_column_name = "fsl_fcs_cat",
#'   rcsi_column_name = "fsl_rcsi_cat",
#'   hhs_column_name = "fsl_hhs_cat",
#'   hdds_column_name = "fsl_hdds_cat",
#'   fcs_categories_acceptable = "Acceptable",
#'   fcs_categories_poor = "Poor",
#'   fcs_categories_borderline = "Borderline",
#'   rcsi_categories_low = "No to Low",
#'   rcsi_categories_medium = "Medium",
#'   rcsi_categories_high = "High",
#'   hhs_categories_none = "None",
#'   hhs_categories_little = "Little",
#'   hhs_categories_moderate = "Moderate",
#'   hhs_categories_severe = "Severe",
#'   hhs_categories_very_severe = "Very Severe",
#'   hdds_categories_low = "Low",
#'   hdds_categories_medium = "Medium",
#'   hdds_categories_high = "High"
#' )
#'
add_fcm_phase <- function(
  .dataset,
  fcs_column_name = "fsl_fcs_cat",
  rcsi_column_name = "fsl_rcsi_cat",
  hhs_column_name = "fsl_hhs_cat_ipc",
  hdds_column_name = "fsl_hdds_cat",
  fcs_categories_acceptable = "Acceptable",
  fcs_categories_poor = "Poor",
  fcs_categories_borderline = "Borderline",
  rcsi_categories_low = "No to Low",
  rcsi_categories_medium = "Medium",
  rcsi_categories_high = "High",
  hhs_categories_none = "None",
  hhs_categories_little = "Little",
  hhs_categories_moderate = "Moderate",
  hhs_categories_severe = "Severe",
  hhs_categories_very_severe = "Very Severe",
  hdds_categories_low = "Low",
  hdds_categories_medium = "Medium",
  hdds_categories_high = "High"
) {
  ## Throw an error if a dataset wasn't provided as a first argument
  if (!is.data.frame(.dataset)) {
    stop("First argument should be a dataset")
  }

  if (nrow(.dataset) == 0) {
    stop("Dataset is empty")
  }

  if (all(c(hdds_column_name, fcs_column_name) %in% names(.dataset))) {
    fews_vars <- c(
      fcs_column_name,
      rcsi_column_name,
      hhs_column_name,
      hdds_column_name
    )
  } else if (
    hdds_column_name %in%
      names(.dataset) &&
      !fcs_column_name %in% names(.dataset)
  ) {
    fews_vars <- c(rcsi_column_name, hhs_column_name, hdds_column_name)
  } else {
    fews_vars <- c(rcsi_column_name, hhs_column_name, fcs_column_name)
  }

  if (!hhs_column_name %in% names(.dataset)) {
    stop("Missing HHS column")
  }

  if (fcs_column_name %in% names(.dataset)) {
    fcs_categories <- c(
      fcs_categories_acceptable,
      fcs_categories_poor,
      fcs_categories_borderline
    )
    if (!all(.dataset[[fcs_column_name]] %in% c(fcs_categories, NA))) {
      stop(
        "Please check if the fcs categories parameter passes is matching the values in your data"
      )
    }
  }

  hhs_categories <- c(
    hhs_categories_none,
    hhs_categories_little,
    hhs_categories_moderate,
    hhs_categories_severe,
    hhs_categories_very_severe
  )
  if (!all(.dataset[[hhs_column_name]] %in% c(hhs_categories, NA))) {
    stop(
      "Please check if the hhs categories parameter passes is matching the values in your data"
    )
  }
  if (rcsi_column_name %in% names(.dataset)) {
    rcsi_categories <- c(
      rcsi_categories_low,
      rcsi_categories_medium,
      rcsi_categories_high
    )
    if (!all(.dataset[[rcsi_column_name]] %in% c(rcsi_categories, NA))) {
      stop(
        "Please check if the rcsi categories parameter passes is matching the values in your data"
      )
    }
  }

  if (hdds_column_name %in% names(.dataset)) {
    hdds_categories <- c(
      hdds_categories_low,
      hdds_categories_medium,
      hdds_categories_high
    )
    if (!all(.dataset[[hdds_column_name]] %in% c(hdds_categories, NA))) {
      stop(
        "Please check if the hdds categories parameter passes is matching the values in your data"
      )
    }
  }

  if (
    all(
      c(fcs_column_name, rcsi_column_name, hhs_column_name) %in% names(.dataset)
    )
  ) {
    .dataset <- .dataset |>
      dplyr::mutate(
        fsl_fc_cell = dplyr::case_when(
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 1,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 11,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 6,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 16,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 26,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 21,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 31,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 41,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 36,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 2,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 12,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 7,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 17,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 27,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 22,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 32,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 42,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 37,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 3,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 13,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 8,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 18,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 28,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 23,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 33,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 43,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 38,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 4,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 14,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 9,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 19,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 29,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 24,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 34,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 44,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 39,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 5,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 15,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 10,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 20,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 30,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 25,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 35,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 45,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 40,
          TRUE ~ NA_real_
        )
      )
  } else if (
    all(
      c(hdds_column_name, rcsi_column_name, hhs_column_name) %in%
        names(.dataset)
    )
  ) {
    .dataset <- .dataset |>
      dplyr::mutate(
        fsl_fc_cell = dplyr::case_when(
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 1,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 11,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 6,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 16,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 26,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 21,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 31,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 41,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 36,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 2,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 12,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 7,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 17,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 27,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 22,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 32,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 42,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 37,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 3,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 13,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 8,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 18,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 28,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 23,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 33,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 43,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 38,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 4,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 14,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 9,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 19,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 29,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 24,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 34,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 44,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 39,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 5,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 15,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 10,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 20,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 30,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 25,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 35,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 45,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(rcsi_column_name) == rcsi_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 40,
          TRUE ~ NA_real_
        )
      )
  } else if (all(c(fcs_column_name, hhs_column_name) %in% names(.dataset))) {
    .dataset <- .dataset |>
      dplyr::mutate(
        fsl_fc_cell = dplyr::case_when(
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 1,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 11,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 6,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 2,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 12,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 7,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 3,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 13,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 8,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 4,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 14,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 9,
          !!rlang::sym(fcs_column_name) == fcs_categories_acceptable &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 5,
          !!rlang::sym(fcs_column_name) == fcs_categories_poor &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 15,
          !!rlang::sym(fcs_column_name) == fcs_categories_borderline &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 10,
          TRUE ~ NA_real_
        )
      )
  } else if (all(c(hdds_column_name, hhs_column_name) %in% names(.dataset))) {
    .dataset <- .dataset |>
      dplyr::mutate(
        fsl_fc_cell = dplyr::case_when(
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 1,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 11,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_none ~ 6,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 2,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 12,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_little ~ 7,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 3,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 13,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_moderate ~ 8,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 4,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 14,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_severe ~ 9,
          !!rlang::sym(hdds_column_name) == hdds_categories_high &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 5,
          !!rlang::sym(hdds_column_name) == hdds_categories_low &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 15,
          !!rlang::sym(hdds_column_name) == hdds_categories_medium &
            !!rlang::sym(hhs_column_name) == hhs_categories_very_severe ~ 10,
          TRUE ~ NA_real_
        )
      )
  }

  if (
    all(
      c(fcs_column_name, rcsi_column_name, hhs_column_name) %in% names(.dataset)
    ) ||
      all(
        c(hdds_column_name, rcsi_column_name, hhs_column_name) %in%
          names(.dataset)
      )
  ) {
    .dataset <- .dataset |>
      dplyr::mutate(
        fsl_fc_phase = dplyr::case_when(
          fsl_fc_cell %in% c(1, 6) ~ "Phase 1 FC",
          fsl_fc_cell %in%
            c(
              2,
              3,
              7,
              11,
              12,
              16,
              17,
              18,
              21,
              22,
              26,
              31,
              32,
              36
            ) ~ "Phase 2 FC",
          fsl_fc_cell %in%
            c(
              4,
              5,
              8,
              9,
              13,
              19,
              20,
              23,
              24,
              27,
              28,
              33,
              34,
              37,
              38,
              41,
              42,
              43
            ) ~ "Phase 3 FC",
          fsl_fc_cell %in% c(10, 14, 15, 25, 29, 35, 39, 40, 44) ~ "Phase 4 FC",
          fsl_fc_cell %in% c(30, 45) ~ "Phase 5 FC",
          TRUE ~ NA
        )
      )
  } else if (
    all(c(fcs_column_name, hhs_column_name) %in% names(.dataset)) ||
      all(c(hdds_column_name, hhs_column_name) %in% names(.dataset))
  ) {
    .dataset <- .dataset |>
      dplyr::mutate(
        fsl_fc_phase = dplyr::case_when(
          fsl_fc_cell %in% c(1, 6) ~ "Phase 1 FC",
          fsl_fc_cell %in% c(2, 3, 7, 11) ~ "Phase 2 FC",
          fsl_fc_cell %in% c(4, 8, 12, 13) ~ "Phase 3 FC",
          fsl_fc_cell %in% c(5, 9, 10, 14) ~ "Phase 4 FC",
          fsl_fc_cell %in% c(15) ~ "Phase 5 FC",
          TRUE ~ NA
        )
      )
  }
  .dataset
}
