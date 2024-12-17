#' @title Impute Missing Values
#' 
#' @description This set of functions replaces missing values in specified variables.
#' * [impute_value()] replaces all missing values with a specific value, while
#' * [impute_median()] replaces missing values with the (weighted) median of the variable.
#' 
#' @param df A dataframe containing the variables to be imputed.
#' @param vars A character vector of the variables to replace NA with.
#' @param value The value to replace NA with.
#' 
#' @return A dataframe with imputed values:
#' 
#' * vars: The specified variables with missing values replaced.
#'
#' @export
impute_value <- function(df, vars, value) {

  #------ Checks

  # Check if the variable are present
  if_not_in_stop(df, vars, "df")

  # Check if the variables are numeric
  are_cols_numeric(df, vars)

  #------ Imputation

  df <- dplyr::mutate(df, dplyr::across(dplyr::all_of(vars), \(x) tidyr::replace_na(x, value)))

  return(df)
}






#' @rdname impute_value
#' 
#' @param group A character vector of the grouping variables.
#' @param weighted A boolean indicating whether to use the weighted median or not.
#' @param weight The weight variable.
#' 
#' @return A dataframe with imputed values:
#' 
#' * vars: The specified variables with missing values replaced by their respective (weighted) medians.
#'
#' @export
impute_median <- function(df, vars, group = NULL, weighted = FALSE, weight = NULL) {

  #------ Checks

  # Check if the variable are present
  if_not_in_stop(df, vars, "df")

  # Check if the variables are numeric
  are_cols_numeric(df, vars)

  # Check if group is NULL if group is there
  if (!is.null(group)) if_not_in_stop(df, group, "df")

  # Check if "weighted" is logical and not NA
  if (!is.logical(weighted)) rlang::abort("weighted must be a logical value.")

  # Check if the weight variable is present
  if (weighted) if_not_in_stop(df, weight, "df")

  # Check if the weight variable is numeric
  if (weighted) are_cols_numeric(df, weight)

  #------ Imputation

  # If group is not null, group by
  if (!is.null(group)) {

    df <- dplyr::group_by(df, !!!rlang::syms(group))
  }

  if (weighted)
  # TODO: Implement weighted median imputation
  {
    rlang::abort("Weighted median has not been implemented yet. Please use 'FALSE'.")
    # df <- dplyr::mutate(
    #   df,
    #   dplyr::across(
    #     dplyr::all_of(vars),
    #     \(x) tidyr::replace_na(
    #       x,
    #       limma::weighted.median(x, w = !!rlang::sym(weight), na.rm = TRUE)
    #     )
    #   )
    # )
  } else {

    df <- dplyr::mutate(
      df,
      dplyr::across(
        dplyr::all_of(vars),
        \(x) tidyr::replace_na(
          x,
          stats::median(x, na.rm = TRUE)
        )
      )
    )

  }

  # Ungroup
  df <- dplyr::ungroup(df)

  # Convert back to a dataframe as dplyr usually returns a tibble by default
  df <- as.data.frame(df)

  return(df)
}
