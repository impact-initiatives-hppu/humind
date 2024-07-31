#' Add frequent expenditure type amount as proportions of total frequent expenditure
#'
#' @param df A data frame
#' @param cm_expenditure_frequent_food Column name for food items expenditure amount.
#' @param cm_expenditure_frequent_rent Column name for rent or shelter and/or land expenditure amount.
#' @param cm_expenditure_frequent_water Column name for water expenditure amount from all sources combined.
#' @param cm_expenditure_frequent_nfi Column name for non-food household items expenditure amount for regular purchase, such as hygiene items, lightbulbs, etc.
#' @param cm_expenditure_frequent_utilities Column name for utilities expenditure amount, such as electricity or gas connections, etc. 
#' @param cm_expenditure_frequent_fuel Column name for fuel expenditure amount for cooking, for vehicles, etc.
#' @param cm_expenditure_frequent_transportation Column name for transportation expenditure amount, not including vehicle fuel.
#' @param cm_expenditure_frequent_communication Column name for communications expenditure amount, such as phone airtime, Internet costs, etc.
#' @param cm_expenditure_frequent_other Column name for all other frequent expenditures.
#'
#' @export
add_expenditure_type_prop_freq <- function(
    df,
    cm_expenditure_frequent_food = "cm_expenditure_frequent_food",
    cm_expenditure_frequent_rent = "cm_expenditure_frequent_rent",
    cm_expenditure_frequent_water = "cm_expenditure_frequent_water",
    cm_expenditure_frequent_nfi = "cm_expenditure_frequent_nfi",
    cm_expenditure_frequent_utilities = "cm_expenditure_frequent_utilities",
    cm_expenditure_frequent_fuel = "cm_expenditure_frequent_fuel",
    cm_expenditure_frequent_transportation = "cm_expenditure_frequent_transportation",
    cm_expenditure_frequent_communication = "cm_expenditure_frequent_communication",
    cm_expenditure_frequent_other = "cm_expenditure_frequent_other"){
  
  #------ Checks
  
  # All frequent expenditure types
  expenditure_freq_types <- c(
      cm_expenditure_frequent_food,
      cm_expenditure_frequent_rent,
      cm_expenditure_frequent_water,
      cm_expenditure_frequent_nfi,
      cm_expenditure_frequent_utilities,
      cm_expenditure_frequent_fuel,
      cm_expenditure_frequent_transportation,
      cm_expenditure_frequent_communication,
      cm_expenditure_frequent_other
    
  )
  
  # Check if the columns exist
  if_not_in_stop(df, expenditure_freq_types, "df")
  
  # Check that all frequent expenditure types are here
  if (length(expenditure_freq_types) < 9) {
    
    rlang::abort("Some of the frequent expenditure types are null.")
  }
  
  # Check that expenditure types are numeric
  are_cols_numeric(df, expenditure_freq_types)
  
  #------ Calculate proportions
  
  # Calculate total frequent expenditure
  df <- sum_vars(df, expenditure_freq_types, "cm_expenditure_frequent_total")
  
  # Calculate the proportion of each expenditure component with respect to the total expenditure
  df <- dplyr::mutate(
    df,
    dplyr::across(
      dplyr::all_of(expenditure_freq_types),
      \(x) ifelse(!!rlang::sym("cm_expenditure_frequent_total") == 0, NA_real_, x / !!rlang::sym("cm_expenditure_frequent_total")),
      .names = "{.col}_prop")
  )
  
  return(df)
  
}