#' @title Calculate Health Composite Score and Need Indicators
#'
#' @description
#' This function calculates a health composite score based on healthcare access and needs.
#' It considers whether individuals needed healthcare, whether they accessed it if needed,
#' and optionally takes into account disability status. The function then determines if a
#' household is in need or in acute need of health assistance based on the calculated score.
#'
#' Prerequisite functions:
#'
#' * add_loop_healthcare_needed_cat.R
#' * add_loop_wgq_ss.R - if WG-SS data collected
#'
#'
#' @param df A data frame.
#' @param ind_healthcare_needed_no_n Column name for the number of individuals who did not need to access healthcare.
#' @param ind_healthcare_needed_yes_unmet_n Column name for the number of individuals who needed to access healthcare but did not.
#' @param ind_healthcare_needed_yes_met_n Column name for the number of individuals who needed to access healthcare and did.
#' @param wgq_dis Logical. If TRUE, the function will consider the disability columns.
#' @param ind_healthcare_needed_no_wgq_dis_n Column name for the number of individuals who did not need to access healthcare and have a disability.
#' @param ind_healthcare_needed_yes_unmet_wgq_dis_n Column name for the number of individuals who needed to access healthcare but did not and have a disability.
#' @param ind_healthcare_needed_yes_met_wgq_dis_n Column name for the number of individuals who needed to access healthcare and did and have a disability.
#'
#' @return A data frame with additional columns:
#'
#' * comp_health_score: Health composite score (1-4)
#' * comp_health_in_need: Binary indicator for being in need of health assistance
#' * comp_health_in_acute_need: Binary indicator for being in acute need of health assistance
#'
#' @export
add_comp_health <- function(
    df,
    ind_healthcare_needed_no_n = "health_ind_healthcare_needed_no_n",
    ind_healthcare_needed_yes_unmet_n = "health_ind_healthcare_needed_yes_unmet_n",
    ind_healthcare_needed_yes_met_n = "health_ind_healthcare_needed_yes_met_n",
    wgq_dis = FALSE,
    ind_healthcare_needed_no_wgq_dis_n = "health_ind_healthcare_needed_no_wgq_dis_n",
    ind_healthcare_needed_yes_unmet_wgq_dis_n = "health_ind_healthcare_needed_yes_unmet_wgq_dis_n",
    ind_healthcare_needed_yes_met_wgq_dis_n = "health_ind_healthcare_needed_yes_met_wgq_dis_n"
){

  #------ Checks

  # Check if wgq_dis is logical, if not stop
  if (!is.logical(wgq_dis)) rlang::abort("wgq_dis must be TRUE or FALSE.")

  # Get vars names
  vars_n <- c(ind_healthcare_needed_no_n, ind_healthcare_needed_yes_unmet_n, ind_healthcare_needed_yes_met_n)
  if (wgq_dis) vars_dis_n <- c(ind_healthcare_needed_no_wgq_dis_n, ind_healthcare_needed_yes_unmet_wgq_dis_n, ind_healthcare_needed_yes_met_wgq_dis_n)

  # Check if the variables are in the data frame
  if_not_in_stop(df, vars_n, "df")
  if (wgq_dis) if_not_in_stop(df, vars_dis_n, "df")

  # Check if values are numeric and above 0
  are_cols_numeric(df, vars_n)
  if (wgq_dis) are_cols_numeric(df, vars_dis_n)
  are_values_in_range(df, vars_n, 0, Inf)
  if (wgq_dis) are_values_in_range(df, vars_dis_n, 0, Inf)

  #------ Compute

  # if healthcare needed no, then wgq_dis, else NA
  if(!wgq_dis) {
    df <- dplyr::mutate(
      df,
      comp_health_score = dplyr::case_when(
        !!rlang::sym(ind_healthcare_needed_yes_unmet_n) > 0 ~ 3,
        !!rlang::sym(ind_healthcare_needed_yes_met_n) > 0 ~ 2,
        !!rlang::sym(ind_healthcare_needed_no_n) > 0 ~ 1,
        .default = NA_real_
      )
    )
  } else {
    df <- dplyr::mutate(
      df,
      comp_health_score = dplyr::case_when(
        !!rlang::sym(ind_healthcare_needed_yes_unmet_wgq_dis_n) > 0 ~ 4,
        !!rlang::sym(ind_healthcare_needed_yes_unmet_n) > 0 ~ 3,
        !!rlang::sym(ind_healthcare_needed_yes_met_wgq_dis_n) > 0 ~ 3,
        !!rlang::sym(ind_healthcare_needed_no_wgq_dis_n) > 0 ~ 3,
        !!rlang::sym(ind_healthcare_needed_yes_met_n) > 0 ~ 2,
        !!rlang::sym(ind_healthcare_needed_no_n) > 0 ~ 1,
        .default = NA_real_
      )
    )
  }

  # Is in need?
  df <- is_in_need(df, "comp_health_score", "comp_health_in_need")
  # Is in acute need?
  df <- is_in_acute_need(df, "comp_health_score", "comp_health_in_acute_need")

  return(df)
}
