#' Add zero when the income source was skipped
#'
#' @param df A data frame.
#' @param income_source A character string. The name of the column that contains the income source.
#' @param none A character string. The value that indicates that the income source was skipped.
#' @param undefined A character vector. The values that indicate that the income source was skipped.
#' @param income_sources A character vector. The names of the columns that contain the amount of income sources.
#'
#' @export
add_income_source_zero_to_sl <- function(
    df,
    income_source = "cm_income_source",
    none = "none",
    undefined = c("dnk", "pnta"),
    income_sources = c("cm_income_source_salaried_n",
                       "cm_income_source_casual_n",
                       "cm_income_source_own_business_n",
                       "cm_income_source_own_production_n",
                       "cm_income_source_social_benefits_n",
                       "cm_income_source_rent_n",
                       "cm_income_source_remittances_n",
                       "cm_income_source_assistance_n",
                       "cm_income_source_support_friends_n",
                       "cm_income_source_donation_n",
                       "cm_income_source_other_n")
){

  #----- Checks

  # Check that income source is of length 1
  if (length(income_source) != 1) {
    rlang::abort("income_source must be of length 1.")
  }

  # Check if income_source is in the data
  if_not_in_stop(df, c(income_source, income_sources), "df")

  # Check that income_sources are numeric
  are_cols_numeric(df, income_sources)

  #----- Run value_to_sl()

  # Run value_to_sl() for each income source at once using param vars
  df <- value_to_sl(
    df,
    var = income_source,
    undefined = undefined,
    sl_vars = income_sources,
    sl_value = 0,
    suffix = "")

  # Ensure that when income_source is "none", all sl_vars are 0
  # Which should be the case already with value_to_sl
  # to be on the safe side in the meantime
  df <- dplyr::mutate(
    df,
    dplyr::across(
      dplyr::all_of(income_sources),
      \(x) dplyr::case_when(
        !!rlang::sym(income_source) == none ~ 0,
        .default = x
      )
    )
  )

  return(df)

}
