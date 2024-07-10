#' Rank top 3 infrequent expenditure types
#'
#' @param df A data frame.
#' @param expenditure_infreq_types A character vector. The names of the columns that contain the amount of infrequent expenditures types.
#' @param id_col The name of the column that contains the unique identifier.
#'
#' @export
add_top3_expenditure_type_infreq <- function(
    df,
    expenditure_infreq_types = c("cm_expenditure_infrequent_shelter",
                                 "cm_expenditure_infrequent_nfi",
                                 "cm_expenditure_infrequent_health",
                                 "cm_expenditure_infrequent_education",
                                 "cm_expenditure_infrequent_debt",
                                 "cm_expenditure_infrequent_other"), 
    id_col = "uuid"){
  
  #------ Checks
  
  # Check if the columns exist
  if_not_in_stop(df, expenditure_infreq_types, "df")
  
  # Check that all infrequent expenditure types are here
  if (length(expenditure_infreq_types) < 6) {
    
    rlang::abort("Some of the infrequent expenditure types are null.")
  }
  
  # Check that expenditure types are numeric
  are_cols_numeric(df, expenditure_infreq_types)
  
  #------ Ranking
  
  df <- rank_top3_vars(
    df = df,
    vars = c(expenditure_infreq_types),
    new_colname_top1 = "cm_infreq_expenditure_top1",
    new_colname_top2 = "cm_infreq_expenditure_top2",
    new_colname_top3 = "cm_infreq_expenditure_top3",
    id_col = id_col)
  
  return(df)
  
  
  
}