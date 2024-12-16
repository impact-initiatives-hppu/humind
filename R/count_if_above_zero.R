#' @title Create Dummy Variables and Count Across if Above Zero
#' @description This function creates dummy variables for each input column, setting 1 if the value is above zero, 0 if it's zero, and NA if it's below zero. It then sums these dummy variables to create a count.
#' @param df A data frame containing the columns to be processed.
#' @param vars Vector of column names to be processed.
#' @param new_colname The name of the new column that will contain the count.
#' @return A data frame with additional columns:
#' \item{*_d}{Dummy variables for each input column, where * is the original column name}
#' \item{new_colname}{A new column containing the count of values above zero across the specified variables}
#'
#' @export
count_if_above_zero <- function(df, vars, new_colname){

  #----- Checks

  # Check if vars exists in df
  if_not_in_stop(df, vars, "df")

  # Check if vars are numeric
  are_cols_numeric(df, vars)

  # Paste "_d" to vars names and throw a warning that these will be replaced
  vars_d <- paste0(vars, "_d")
  vars_d_in_df <- intersect(vars_d, colnames(df))
  if (length(vars_d_in_df) > 0) {
    rlang::warn(glue::glue("The following variables exist in 'df' and will be replaced: ", glue::glue_collapse(vars_d_in_df, sep = ", ", last = " and ")))
  }

  # Warn if new colname exist
  if (new_colname %in% colnames(df)) {
    rlang::warn(paste0(new_colname, " already exists in 'df'. It will be replaced."))
  }

  #----- Compute

  # Create dummy vars if above 0, 0 if 0, NA if below 0
  df <- dplyr::mutate(
    df,
    dplyr::across(
      .cols = dplyr::all_of(vars),
      .fns = \(x) dplyr::case_when(
        x > 0 ~ 1,
        x == 0 ~ 0,
        .default = NA_real_
      ),
      .names = "{.col}_d")
  )

  df <- sum_vars(
    df,
    vars_d,
    new_colname = new_colname,
    imputation = "none",
    na_rm = TRUE
  )

    return(df)
  }
