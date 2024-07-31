#' Add income source amount as proportions of total income
#'
#' @param df A data frame
#' @param income_souce_salaried_n Column name for salaried income amount.
#' @param income_source_casual_n Column name for casual income amount.
#' @param income_source_own_business_n Column name for own business income amount.
#' @param income_source_own_production_n Column name for own production income amount.
#' @param income_source_social_benefits_n Column name for social benefits income amount.
#' @param income_source_rent_n Column name for rent income amount.
#' @param income_source_remittances_n Column name for remittances income amount.
#' @param income_source_assistance_n Column name for assistance income amount.
#' @param income_source_support_friends_n Column name for support from friends income amount.
#' @param income_source_donation_n Column name for donation income amount.
#' @param income_source_other_n Column name for other income amount.
#' 
#' @section Details on loans:
#' 
#' Loans (income_source_support_friends_n and income_source_donation_n) are considered to be a cash influx. Yet they do not count as a formal income source. While it is good practice to collect these figures as part of this module, they should not be included in the total income calculation. This is why their default value here is NULL.
#'
#' @export
add_income_source_prop <- function(
    df,
    income_souce_salaried_n = "cm_income_source_salaried_n",
    income_source_casual_n = "cm_income_source_casual_n",
    income_source_own_business_n = "cm_income_source_own_business_n",
    income_source_own_production_n = "cm_income_source_own_production_n",
    income_source_social_benefits_n= "cm_income_source_social_benefits_n",
    income_source_rent_n = "cm_income_source_rent_n",
    income_source_remittances_n = "cm_income_source_remittances_n",
    income_source_assistance_n = "cm_income_source_assistance_n",
    income_source_support_friends_n = NULL,
    income_source_donation_n = NULL,
    income_source_other_n = "cm_income_source_other_n"){

  #------ Checks

  # All sources
  income_sources <- c(
    income_souce_salaried_n,
    income_source_casual_n,
    income_source_own_business_n,
    income_source_own_production_n,
    income_source_social_benefits_n,
    income_source_rent_n,
    income_source_remittances_n,
    income_source_assistance_n,
    income_source_support_friends_n,
    income_source_donation_n,
    income_source_other_n
  )

  # Check if the columns exist
  if_not_in_stop(df, income_sources, "df")

  # CHeck that all income sources are here
  if (length(income_sources) < 9) {

    rlang::abort("Some of the income sources are null.")
  }

  # Check that sources are numeric
  are_cols_numeric(df, income_sources)

  #------ Calculate proportions

  # Calculate total income
  df <- sum_vars(df, income_sources, "cm_income_total")

  # Calculate the proportion of each expenditure component with respect to the total expenditure
  df <- dplyr::mutate(
    df,
    dplyr::across(
      dplyr::all_of(income_sources),
      \(x) ifelse(!!rlang::sym("cm_income_total") == 0, NA_real_, x / !!rlang::sym("cm_income_total")),
      .names = "{.col}_prop")
  )

  return(df)

}
