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
#' with fixed parameters for the health expenditure module: expenditure recall
#' period is 180 days (6 months), income recall period is 30 days, and the
#' catastrophic threshold is 0.25 (25%).
#'
#' Prerequisite: run `add_expenditure_type_zero_infreq()` before calling this
#' function. `cm_income_total` must also be present in `df`, either directly
#' from the survey or via `add_income_source_prop()`.
#'
#' @param df A data frame.
#' @param expenditure_type Column name for infrequent health expenditure amount.
#' @param total_income Column name for total household income.
#'
#' @return A data frame with two additional columns:
#'
#' * `cm_expenditure_infrequent_health_share_income`: Recall-normalised health
#'   expenditure share of income, or `NA` if income is 0 or `NA`.
#' * `cm_expenditure_infrequent_health_share_income_d`: `1L` if catastrophic
#'   (share >= 0.25), `0L` otherwise, `NA` if share is `NA`.
#'
#' @export
add_expenditure_healthcare_share_income <- function(
  df,
  expenditure_type = "cm_expenditure_infrequent_health",
  total_income = "cm_income_total"
) {
  add_expenditure_type_share_income(
    df,
    expenditure_type = expenditure_type,
    income_total = total_income,
    expenditure_recall_period = 180,
    income_recall_period = 30,
    catastrophic_threshold = 0.25
  )
}
