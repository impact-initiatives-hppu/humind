# ANA
# 2025 Indicator ID: IND097
# 2025 Metric ID: TBD

#' @title Add Water Expenditure Share of Income
#'
#' @description
#' Calculates the share of frequent water expenditure relative to total
#' household income and flags households spending 5% or more of income on water
#' (catastrophic water spending).
#'
#' This is a convenience wrapper around `add_expenditure_type_share_income()`
#' with fixed parameters for the water expenditure module: both expenditure and
#' income recall periods are 30 days, and the catastrophic threshold is 0.05
#' (5%).
#'
#' Prerequisite: run `add_expenditure_type_zero_freq()` before calling this
#' function. `cm_income_total` must also be present in `df`, either directly
#' from the survey or via `add_income_source_prop()`.
#'
#' @param df A data frame.
#' @param expenditure_type Column name for frequent water expenditure amount.
#' @param total_income Column name for total household income.
#'
#' @return A data frame with two additional columns:
#'
#' * `cm_expenditure_frequent_water_share_income`: Water expenditure share of
#'   income, or `NA` if income is 0 or `NA`.
#' * `cm_expenditure_frequent_water_share_income_d`: `1L` if catastrophic
#'   (share >= 0.05), `0L` otherwise, `NA` if share is `NA`.
#'
#' @family expenditure_share_income
#' @export
add_expenditure_water_share_income <- function(
  df,
  expenditure_type = "cm_expenditure_frequent_water",
  total_income = "cm_income_total"
) {
  add_expenditure_type_share_income(
    df,
    expenditure_type = expenditure_type,
    income_total = total_income,
    expenditure_recall_period = 30,
    income_recall_period = 30,
    catastrophic_threshold = 0.05
  )
}
