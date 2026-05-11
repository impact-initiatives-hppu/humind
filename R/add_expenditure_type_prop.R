#' @title Add Expenditure Type Proportions of Total Expenditure
#'
#' @description
#' This function calculates the proportion of each expenditure type (frequent and infrequent) relative to the grand total expenditure across all categories. It adds new columns to the input data frame representing these proportions.
#'
#' Prerequisite functions:
#'
#' * add_expenditure_type_zero_freq.R
#' * add_expenditure_type_zero_infreq.R
#'
#' @param df A data frame containing frequent and infrequent expenditure data.
#' @param cm_expenditure_frequent_food Column name for food items expenditure amount.
#' @param cm_expenditure_frequent_rent Column name for rent or shelter and/or land expenditure amount.
#' @param cm_expenditure_frequent_water Column name for water expenditure amount from all sources combined.
#' @param cm_expenditure_frequent_nfi Column name for non-food household items expenditure amount for regular purchase.
#' @param cm_expenditure_frequent_utilities Column name for utilities expenditure amount.
#' @param cm_expenditure_frequent_fuel Column name for fuel expenditure amount.
#' @param cm_expenditure_frequent_transportation Column name for transportation expenditure amount.
#' @param cm_expenditure_frequent_communication Column name for communications expenditure amount.
#' @param cm_expenditure_frequent_other Column name for all other frequent expenditures.
#' @param cm_expenditure_infrequent_shelter Column name for shelter maintenance or repair expenditure amount.
#' @param cm_expenditure_infrequent_nfi Column name for non-food household items for infrequent purchase.
#' @param cm_expenditure_infrequent_health Column name for health-related expenditures.
#' @param cm_expenditure_infrequent_education Column name for education-related expenditures.
#' @param cm_expenditure_infrequent_debt Column name for debt repayment expenditure.
#' @param cm_expenditure_infrequent_clothing Column name for clothing expenditure.
#' @param cm_expenditure_infrequent_other Column name for all other infrequent expenditures.
#'
#' @return A data frame with additional columns:
#'
#' * cm_expenditure_total: The grand total expenditure amount (frequent + infrequent).
#' * cm_expenditure_frequent_food_prop: Proportion of food expenditure relative to grand total.
#' * cm_expenditure_frequent_rent_prop: Proportion of rent expenditure relative to grand total.
#' * cm_expenditure_frequent_water_prop: Proportion of water expenditure relative to grand total.
#' * cm_expenditure_frequent_nfi_prop: Proportion of frequent non-food items expenditure relative to grand total.
#' * cm_expenditure_frequent_utilities_prop: Proportion of utilities expenditure relative to grand total.
#' * cm_expenditure_frequent_fuel_prop: Proportion of fuel expenditure relative to grand total.
#' * cm_expenditure_frequent_transportation_prop: Proportion of transportation expenditure relative to grand total.
#' * cm_expenditure_frequent_communication_prop: Proportion of communication expenditure relative to grand total.
#' * cm_expenditure_frequent_other_prop: Proportion of other frequent expenditures relative to grand total.
#' * cm_expenditure_infrequent_shelter_prop: Proportion of shelter maintenance expenditure relative to grand total.
#' * cm_expenditure_infrequent_nfi_prop: Proportion of infrequent non-food items expenditure relative to grand total.
#' * cm_expenditure_infrequent_health_prop: Proportion of health expenditure relative to grand total.
#' * cm_expenditure_infrequent_education_prop: Proportion of education expenditure relative to grand total.
#' * cm_expenditure_infrequent_debt_prop: Proportion of debt repayment expenditure relative to grand total.
#' * cm_expenditure_infrequent_clothing_prop: Proportion of clothing expenditure relative to grand total.
#' * cm_expenditure_infrequent_other_prop: Proportion of other infrequent expenditures relative to grand total.
#'
#' @export
add_expenditure_type_prop <- function(
  df,
  cm_expenditure_frequent_food = "cm_expenditure_frequent_food",
  cm_expenditure_frequent_rent = "cm_expenditure_frequent_rent",
  cm_expenditure_frequent_water = "cm_expenditure_frequent_water",
  cm_expenditure_frequent_nfi = "cm_expenditure_frequent_nfi",
  cm_expenditure_frequent_utilities = "cm_expenditure_frequent_utilities",
  cm_expenditure_frequent_fuel = "cm_expenditure_frequent_fuel",
  cm_expenditure_frequent_transportation = "cm_expenditure_frequent_transportation",
  cm_expenditure_frequent_communication = "cm_expenditure_frequent_communication",
  cm_expenditure_frequent_other = "cm_expenditure_frequent_other",
  cm_expenditure_infrequent_shelter = "cm_expenditure_infrequent_shelter",
  cm_expenditure_infrequent_nfi = "cm_expenditure_infrequent_nfi",
  cm_expenditure_infrequent_health = "cm_expenditure_infrequent_health",
  cm_expenditure_infrequent_education = "cm_expenditure_infrequent_education",
  cm_expenditure_infrequent_debt = "cm_expenditure_infrequent_debt",
  cm_expenditure_infrequent_clothing = "cm_expenditure_infrequent_clothing",
  cm_expenditure_infrequent_other = "cm_expenditure_infrequent_other"
) {
  #------ Checks

  # vector of all expenditure types
  expenditure_types <- c(
    cm_expenditure_frequent_food,
    cm_expenditure_frequent_rent,
    cm_expenditure_frequent_water,
    cm_expenditure_frequent_nfi,
    cm_expenditure_frequent_utilities,
    cm_expenditure_frequent_fuel,
    cm_expenditure_frequent_transportation,
    cm_expenditure_frequent_communication,
    cm_expenditure_frequent_other,
    cm_expenditure_infrequent_shelter,
    cm_expenditure_infrequent_nfi,
    cm_expenditure_infrequent_health,
    cm_expenditure_infrequent_education,
    cm_expenditure_infrequent_debt,
    cm_expenditure_infrequent_clothing,
    cm_expenditure_infrequent_other
  )

  # expenditure types exist and are positive numeric variables
  are_values_in_range(df, expenditure_types, lower = 0, upper = Inf)

  #------ Calculate proportions

  # Calculate grand total expenditure
  df <- sum_vars(df, expenditure_types, "cm_expenditure_total")

  # Calculate the proportion of each expenditure component relative to grand total
  df <- dplyr::mutate(
    df,
    dplyr::across(
      dplyr::all_of(expenditure_types),
      \(x) {
        ifelse(
          !!rlang::sym("cm_expenditure_total") == 0,
          NA_real_,
          x / !!rlang::sym("cm_expenditure_total")
        )
      },
      .names = "{.col}_prop"
    )
  )

  return(df)
}
