#' @title Calculate Health Composite Score and Need Indicators
#'
#' @description
#' This function calculates a health composite score based on healthcare access and needs.
#' It considers whether individuals needed healthcare, whether they accessed it if needed,
#' and optionally takes into account disability status. The function then determines if a
#' household is in need or in severe need of health assistance based on the calculated score.
#'
#' Prerequisite functions:
#'
#' * add_loop_healthcare_needed_cat.R
#'
#'
#' @param df A data frame.
#' @param ind_healthcare_needed_no_n Column name for the number of individuals who did not need to access healthcare.
#' @param ind_healthcare_needed_yes_unmet_n Column name for the number of individuals who needed to access healthcare but did not.
#' @param ind_healthcare_needed_yes_met_n Column name for the number of individuals who needed to access healthcare and did.
#'
#' @return A data frame with additional columns:
#'
#' * comp_health_score: Health composite score (1-4)
#' * comp_health_in_need: Binary indicator for being in need of health assistance
#' * comp_health_in_severe_need: Binary indicator for being in severe need of health assistance
#'
#' @export
add_comp_health <- function(
  df,
  ind_healthcare_needed_no_n = "health_ind_healthcare_needed_no_n",
  ind_healthcare_needed_yes_unmet_n = "health_ind_healthcare_needed_yes_unmet_n",
  ind_healthcare_needed_yes_met_n = "health_ind_healthcare_needed_yes_met_n"
) {
  #------ Checks

  # Get vars names
  vars_n <- c(
    ind_healthcare_needed_no_n,
    ind_healthcare_needed_yes_unmet_n,
    ind_healthcare_needed_yes_met_n
  )

  # Check if the variables are in the data frame
  if_not_in_stop(df, vars_n, "df")

  # Check if values are numeric and above 0
  are_cols_numeric(df, vars_n)

  are_values_in_range(df, vars_n, 0, Inf)

  #------ Compute

  df <- dplyr::mutate(
    df,
    comp_health_score = dplyr::case_when(
      !!rlang::sym(ind_healthcare_needed_yes_unmet_n) > 0 ~ 3,
      !!rlang::sym(ind_healthcare_needed_yes_met_n) > 0 ~ 2,
      !!rlang::sym(ind_healthcare_needed_no_n) > 0 ~ 1,
      .default = NA_real_
    )
  )

  # Is in need?
  df <- is_in_need(df, "comp_health_score", "comp_health_in_need")
  # Is in severe need?
  df <- is_in_severe_need(df, "comp_health_score", "comp_health_in_severe_need")

  return(df)
}
