#' Add zero when the frequent expenditure type was skipped 
#' Note:Frequent expenditure = 30-day recall period
#'
#' @param df A data frame.
#' @param expenditure_freq A character string. The name of the column that contains the frequent expenditures.
#' @param undefined A character vector. The values that indicate that the frequent expenditures type was skipped.
#' @param expenditure_freq_types A character vector. The names of the columns that contain the amount of frequent expenditures types.
#'
#' @export
add_expenditure_type_zero_freq <- function(
    df,
    expenditure_freq = "cm_expenditure_frequent",
    undefined = c("dnk", "pnta", "none"),
    expenditure_freq_types = c("cm_expenditure_frequent_food",
                               "cm_expenditure_frequent_rent",
                               "cm_expenditure_frequent_water",
                               "cm_expenditure_frequent_nfi",
                               "cm_expenditure_frequent_utilitiues",
                               "cm_expenditure_frequent_fuel",
                               "cm_expenditure_frequent_transportation",
                               "cm_expenditure_frequent_communication",
                               "cm_expenditure_frequent_other")
){
  
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
    suffix = "")
  
  return(df)
  
  
}