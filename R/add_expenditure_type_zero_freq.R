#' @title Add Zero for Skipped Frequent Expenditure Types
#'
#' @description
#' This function adds zero values to frequent expenditure types that were skipped in the survey.
#' Frequent expenditures are defined as those with a 30-day recall period. The function also
#' ensures that when no expenditure is reported, all expenditure types are set to zero.
#'
#' @param df A data frame containing expenditure data.
#' @param expenditure_freq A character string. The name of the column that contains the frequent expenditures.
#' @param none The value for no expenditure.
#' @param undefined A character vector. The values that indicate that the frequent expenditures type was skipped.
#' @param expenditure_freq_types A character vector. The names of the columns that contain the amount of frequent expenditures types.
#'
#' @return A data frame with updated expenditure columns: columns specified in expenditure_freq_types are updated with zeros for skipped entries.
#'
#' @export
add_expenditure_type_zero_freq <- function(
  df,
  expenditure_freq = "cm_expenditure_frequent",
  none = "none",
  undefined = c("dnk", "pnta"),
  expenditure_freq_types = c(
    "cm_expenditure_frequent_food",
    "cm_expenditure_frequent_rent",
    "cm_expenditure_frequent_water",
    "cm_expenditure_frequent_nfi",
    "cm_expenditure_frequent_utilities",
    "cm_expenditure_frequent_fuel",
    "cm_expenditure_frequent_transportation",
    "cm_expenditure_frequent_communication",
    "cm_expenditure_frequent_other"
  )
) {
  #----- Checks

  # Check that frequent expenditure is of length 1
  if (length(expenditure_freq) != 1) {
    rlang::abort("expenditure_freq must be of length 1.")
  }

  # Check if expenditure_freq is in the data
  if_not_in_stop(df, c(expenditure_freq, expenditure_freq_types), "df")

  # Check that expenditure_freq_types are numeric
  are_cols_numeric(df, expenditure_freq_types)

  #----- Run value_to_sl()

  # Run value_to_sl() for each income source at once using param vars
  df <- value_to_sl(
    df,
    var = expenditure_freq,
    undefined = undefined,
    sl_vars = expenditure_freq_types,
    sl_value = 0,
    suffix = ""
  )

  # Ensure that when expenditure_freq is "none", all sl_vars are 0
  # Which should be the case already with value_to_sl
  # to be on the safe side in the meantime
  df <- dplyr::mutate(
    df,
    dplyr::across(
      dplyr::all_of(expenditure_freq_types),
      \(x) {
        dplyr::case_when(
          !!rlang::sym(expenditure_freq) == none ~ 0,
          .default = x
        )
      }
    )
  )

  return(df)
}
