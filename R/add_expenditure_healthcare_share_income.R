# ANA
# 2025 Indicator ID: IND162
# 2025 Metric ID: TBD

#' @title Add Healthcare Expenditure Share of Income
#'
#' @description
#' Calculates the share of infrequent healthcare expenditure relative to total
#' household income, normalising both to the same recall period, and flags
#' households with catastrophic health care spending.
#'
#' This is a convenience wrapper around `add_expenditure_type_share_income()`
#' with defaults set for the health expenditure module. The healthcare
#' expenditure question has a 6-month (180-day) recall period while income is
#' collected over 30 days, so the default `expenditure_recall_period` is 180.
#'
#' Prerequisite: run `add_expenditure_type_zero_infreq()` before calling this
#' function. `cm_income_total` must also be present in `df`, either directly
#' from the survey or via `add_income_source_prop()`.
#'
#' @param df A data frame.
#' @param expenditure_type Column name for infrequent health expenditure amount.
#' @param total_income Column name for total household income.
#' @param expenditure_recall_period Recall period of the health expenditure
#'   column in days. Default: `180` (6 months).
#' @param income_recall_period Recall period of the income column in days.
#'   Default: `30`.
#' @param catastrophic_threshold Numeric threshold for catastrophic spending
#'   (proportion). Default: `0.10` (10%).
#'
#' @return A data frame with two additional columns:
#'
#' * `cm_expenditure_infrequent_health_share_income`: Recall-normalised health
#'   expenditure share of income, or `NA` if income is 0 or `NA`.
#' * `cm_expenditure_infrequent_health_share_income_d`: `1L` if catastrophic
#'   (share >= threshold), `0L` otherwise, `NA` if share is `NA`.
#'
#' @export
add_expenditure_healthcare_share_income <- function(
  df,
  expenditure_type = "cm_expenditure_infrequent_health",
  total_income = "cm_income_total",
  expenditure_recall_period = 180,
  income_recall_period = 30,
  catastrophic_threshold = 0.10
) {
  add_expenditure_type_share_income(
    df,
    expenditure_type = expenditure_type,
    income_total = total_income,
    expenditure_recall_period = expenditure_recall_period,
    income_recall_period = income_recall_period,
    catastrophic_threshold = catastrophic_threshold
  )
}
