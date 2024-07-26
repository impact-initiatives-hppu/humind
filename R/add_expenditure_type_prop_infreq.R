#' Add infrequent expenditure type amount as proportions of total infrequent expenditure
#'
#' @param df A data frame
#' @param cm_expenditure_infrequent_shelter Column name for shelter maintenance or repair expenditure amount.
#' @param cm_expenditure_infrequent_nfi Column containing expenditure amount for non-food household items for infrequent purchase, such as blankets, cooking pots, clothing, etc.
#' @param cm_expenditure_infrequent_health Column name for health-related expenditures, such as healthcare, medicine, etc.
#' @param cm_expenditure_infrequent_education Column name for education-related expenditures, such school fees, supplies, uniforms, etc.
#' @param cm_expenditure_infrequent_debt Column containing expenditure amount for debt repayment. 
#' @param cm_expenditure_infrequent_other Column name for all other infrequent expenditures.
#'
#' @export
add_expenditure_type_prop_infreq <- function(
    df,
    cm_expenditure_infrequent_shelter = "cm_expenditure_infrequent_shelter",
    cm_expenditure_infrequent_nfi = "cm_expenditure_infrequent_nfi",
    cm_expenditure_infrequent_health = "cm_expenditure_infrequent_health",
    cm_expenditure_infrequent_education = "cm_expenditure_infrequent_education",
    cm_expenditure_infrequent_debt = "cm_expenditure_infrequent_debt",
    cm_expenditure_infrequent_other = "cm_expenditure_infrequent_other"){
  
  #------ Checks
  
  # All infrequent expenditure types
  expenditure_infreq_types <- c(
    cm_expenditure_infrequent_shelter,
    cm_expenditure_infrequent_nfi,
    cm_expenditure_infrequent_health,
    cm_expenditure_infrequent_education,
    cm_expenditure_infrequent_debt,
    cm_expenditure_infrequent_other
  )
  
  # Check if the columns exist
  if_not_in_stop(df, expenditure_infreq_types , "df")
  
  # Check that all infrequent expenditure types are here
  if (length(expenditure_infreq_types ) < 6) {
    
    rlang::abort("Some of the infrequent expenditure types are null.")
  }
  
  # Check that expenditure types are numeric
  are_cols_numeric(df, expenditure_infreq_types )
  
  #------ Calculate proportions
  
  # Calculate total infrequent expenditure
  df <- sum_vars(df, expenditure_infreq_types , "cm_expenditure_infrequent_total")
  
  # Calculate the proportion of each expenditure component with respect to the total expenditure
  df <- dplyr::mutate(
    df,
    dplyr::across(
      dplyr::all_of(expenditure_infreq_types ),
      \(x) ifelse(!!rlang::sym("cm_expenditure_infrequent_total") == 0, NA_real_, x / !!rlang::sym("cm_expenditure_infrequent_total")),
      .names = "{.col}_prop")
  )
  
  return(df)
  
}