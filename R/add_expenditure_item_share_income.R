#' @title Add Expenditure Type Share of Income and Catastrophic Spending Flag
#'
#' @description
#' Calculates the share of a single expenditure type relative to total income normalising both to the same recall period before computing the ratio, and flags households where that share meets or exceeds the catastrophic threshold.
#'
#' The share is computed as: `(expenditure * income_recall_period) / (income * expenditure_recall_period)`
#'
#' Prerequisite: `cm_income_total` (or the column supplied to `income_total`)
#' must already be present in `df`, either from the survey directly or from
#' `add_income_source_prop()`.
#'
#' @param df A data frame.
#' @param expenditure_type Column name for the expenditure amount.
#' @param income_total Column name for the total household income.
#' @param expenditure_recall_period Recall period of the expenditure column in
#'   days. Default: `30`.
#' @param income_recall_period Recall period of the income column in days.
#'   Default: `30`.
#' @param catastrophic_threshold Numeric threshold above which spending is
#'   considered catastrophic (proportion, e.g. `0.25` for 25%).
#'   Default: `0.25`.
#'
#' @return A data frame with two additional columns (names derived from
#'   `expenditure_type`):
#'
#' * `{expenditure_type}_share_income`: Recall-normalised share of expenditure relative to income, or `NA` if income is 0 or `NA`.
#' * `{expenditure_type}_share_income_d`: `1L` if share >= `catastrophic_threshold`, `0L` if below, `NA_integer_` if share is `NA`.
#'
#' @family expenditure_share_income
#' @export
#'
#' @examples
#' df <- data.frame(
#'   cm_expenditure_infrequent_health = c(60, 0, 30),
#'   cm_income_total = c(100, 200, 0)
#' )
#' add_expenditure_type_share_income(
#'   df,
#'   expenditure_type = "cm_expenditure_infrequent_health",
#'   income_total = "cm_income_total",
#'   expenditure_recall_period = 180,
#'   income_recall_period = 30,
#'   catastrophic_threshold = 0.25
#' )
add_expenditure_type_share_income <- function(
  df,
  expenditure_type,
  income_total = "cm_income_total",
  expenditure_recall_period = 30,
  income_recall_period = 30,
  catastrophic_threshold = 0.25
) {
  #------ Checks

  # df is a df, expenditure_type and income_total columns exist, are integerish
  # and non-negative (the form columns are integer; this also rejects non-finite)
  if_not_in_stop(df, c(expenditure_type, income_total), "df")
  checkmate::assert_integerish(
    df[[expenditure_type]],
    lower = 0,
    any.missing = TRUE,
    .var.name = expenditure_type
  )
  checkmate::assert_integerish(
    df[[income_total]],
    lower = 0,
    any.missing = TRUE,
    .var.name = income_total
  )

  # income_recall_period and expenditure_recall_period must be single strictly positive numeric values
  if (
    !is.numeric(expenditure_recall_period) ||
      length(expenditure_recall_period) != 1 ||
      expenditure_recall_period <= 0
  ) {
    cli::cli_abort(
      "`expenditure_recall_period` must be a single strictly positive numeric value.",
      call = rlang::caller_env()
    )
  }

  if (
    !is.numeric(income_recall_period) ||
      length(income_recall_period) != 1 ||
      income_recall_period <= 0
  ) {
    cli::cli_abort(
      "`income_recall_period` must be a single strictly positive numeric value.",
      call = rlang::caller_env()
    )
  }

  # catastrophic_threshold must be a single numeric value in (0, 1)
  if (
    !is.numeric(catastrophic_threshold) ||
      length(catastrophic_threshold) != 1 ||
      catastrophic_threshold <= 0 ||
      catastrophic_threshold >= 1
  ) {
    cli::cli_abort(
      "`catastrophic_threshold` must be a single numeric value in (0, 1).",
      call = rlang::caller_env()
    )
  }

  #------ Compute recall-normalised share and flag

  share_col <- paste0(expenditure_type, "_share_income")
  dummy_col <- paste0(expenditure_type, "_share_income_d")

  df <- dplyr::mutate(
    df,
    "{share_col}" := dplyr::if_else(
      is.na(.data[[income_total]]) | .data[[income_total]] == 0,
      NA_real_,
      (.data[[expenditure_type]] * income_recall_period) /
        (.data[[income_total]] * expenditure_recall_period)
    ),
    "{dummy_col}" := dplyr::case_when(
      is.na(.data[[share_col]]) ~ NA_integer_,
      .data[[share_col]] >= catastrophic_threshold ~ 1L,
      .default = 0L
    )
  )

  df
}
