#' Rank top 3 frequent expenditure types
#'
#' @param df A data frame.
#' @param expenditure_freq_types A character vector. The names of the columns that contain the amount of frequent expenditures types.
#' @param id_col The name of the column that contains the unique identifier.
#'
#' @export
add_expenditure_type_freq_rank <- function(
    df,
    expenditure_freq_types = c("cm_expenditure_frequent_food",
                               "cm_expenditure_frequent_rent",
                               "cm_expenditure_frequent_water",
                               "cm_expenditure_frequent_nfi",
                               "cm_expenditure_frequent_utilitiues",
                               "cm_expenditure_frequent_fuel",
                               "cm_expenditure_frequent_transportation",
                               "cm_expenditure_frequent_communication",
                               "cm_expenditure_frequent_other"),
    id_col = "uuid"){
  
  #------ Checks
  
  # Check if the columns exist
  if_not_in_stop(df, expenditure_freq_types, "df")
  
  # Check that all frequent expenditure types are here
  if (length(expenditure_freq_types) < 9) {
    
    rlang::abort("Some of the frequent expenditure types are null.")
  }
  
  # Check that expenditure types are numeric
  are_cols_numeric(df, expenditure_freq_types)
  
  #------ Ranking
  
  df <- rank_top3_vars(
    df = df,
    vars = c(expenditure_freq_types),
    new_colname_top1 = "cm_freq_expenditure_top1",
    new_colname_top2 = "cm_freq_expenditure_top2",
    new_colname_top3 = "cm_freq_expenditure_top3",
    id_col = id_col)
  
  return(df)
  
  
  
}