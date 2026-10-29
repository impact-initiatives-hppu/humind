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
#'   expenditure share of income; `1` for zero-income households with health
#'   expenditure above `0`; `NA` if income or expenditure is `NA`.
#' * `cm_expenditure_infrequent_health_share_income_d`: `1L` if catastrophic
#'   (share >= 0.25), `0L` if not (or for a zero-income household with zero
#'   health expenditure), `NA_integer_` if income or share is `NA`.
#'
#' @section ANA indicator:
#' Metric ID `MET169` (legacy indicator ID `IND176`); system: Health services.
#'
#' @family expenditure_share_income
#' @export
#'
#' @examples
#' df <- data.frame(
#'   cm_expenditure_infrequent_health = c(60, 0, 30),
#'   cm_income_total = c(100, 200, 0)
#' )
#' add_expenditure_healthcare_share_income(df)
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
