#' Add zero when the infrequent expenditure type was skipped 
#' Note: Infrequent expenditure = 6-month recall period
#'
#' @param df A data frame.
#' @param expenditure_infreq A character string. The name of the column that contains the infrequent expenditures.
#' @param none The value for no expenditure.
#' @param undefined A character vector. The values that indicate that the infrequent expenditures type was skipped.
#' @param expenditure_infreq_types A character vector. The names of the columns that contain the amount of infrequent expenditures types.
#'
#' @export
add_expenditure_type_zero_infreq <- function(
    df,
    expenditure_infreq = "cm_expenditure_frequent",
    none = "none",
    undefined = c("dnk", "pnta"),
    expenditure_infreq_types = c("cm_expenditure_infrequent_shelter",
                                 "cm_expenditure_infrequent_nfi",
                                 "cm_expenditure_infrequent_health",
                                 "cm_expenditure_infrequent_education",
                                 "cm_expenditure_infrequent_debt",
                                 "cm_expenditure_infrequent_other"
    )
){
  
  #----- Checks
  
  # Check that infrequent expenditure is of length 1
  if (length(expenditure_infreq) != 1) {
    rlang::abort("expenditure_infreq must be of length 1.")
  }
  
  # Check if expenditure_infreq is in the data
  if_not_in_stop(df, c(expenditure_infreq, expenditure_infreq_types), "df")
  
  # Check that expenditure_infreq_types are numeric
  are_cols_numeric(df, expenditure_infreq_types)
  
  #----- Run value_to_sl()
  
  # Run value_to_sl() for each income source at once using param vars
  df <- value_to_sl(
    df,
    var = expenditure_infreq,
    undefined = undefined,
    sl_vars = expenditure_infreq_types,
    sl_value = 0,
    suffix = "")
  
  # Ensure that when expenditure_infreq is "none", all sl_vars are 0
  # Which should be the case already with value_to_sl
  # to be on the safe side in the meantime
  df <- dplyr::mutate(
    df,
    dplyr::across(
      dplyr::all_of(expenditure_infreq),
      \(x) dplyr::case_when(
        !!rlang::sym(expenditure_infreq) == none ~ 0,
        .default = x
      )
    )
  )
  
  return(df)
  
  
  
}
