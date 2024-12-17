#' @title Sum Columns Row-wise
#' 
#' @description This function sums up specified columns row-wise in a dataframe, with options for imputation of missing values and weighted calculations.
#' 
#' @param df A dataframe containing the columns to be summed.
#' @param vars A character vector of the columns to sum.
#' @param new_colname A character vector of the new column name.
#' @param imputation The imputation method, either none (default), value, median or weighted median.
#' @param na_rm A boolean indicating whether to remove missing values when summing across columns.
#' @param weight The weight variable to calculate weighted means or medians.
#' @param value The value to replace missing values with if imputation is "value".
#' @param group A character vector of the grouping variables.
#' 
#' @return A dataframe with an additional column:
#' 
#' * new_colname: the sum of the specified variables, with imputation applied if specified.
#'
#' @export
sum_vars <- function(df, vars, new_colname, imputation = "none", na_rm = FALSE, weight = "weight", value = 0, group = NULL) {

  #------ Checks

  # Check if all columns are present
  if_not_in_stop(df, vars, "df")

  # Check if all columns are numeric
  are_cols_numeric(df, vars)

  # Check that new_colname is of length 1
  if (length(new_colname) != 1) rlang::abort("new_colname must be of length 1")


  #------ Imputation
  if (imputation == "weighted.median") {

    # Check if weighting column is here and numeric
    if_not_in_stop(df, weight, "df")
    are_cols_numeric(df, weight)

    df <- impute_median(df, vars = vars, weighted = TRUE, weight = weight, group = group)

  } else if (imputation == "median") {

    df <- impute_median(df, vars, group = group)

  } else if (imputation == "value"){

    df <- impute_value(df, vars, value)

  } else if (imputation == "none") {

    df <- df

  } else {

    rlang::abort("The imputation method is not recognized. Please use 'weigthed.median', median', 'value', or 'none'.")

  }

  #------ Sum the columns
  df <- dplyr::mutate(df, "{new_colname}" := rowSums(dplyr::across(dplyr::all_of(vars)), na.rm = na_rm))

  return(df)
}
