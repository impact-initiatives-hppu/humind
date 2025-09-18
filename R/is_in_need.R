#' @title Add Dummy Variable for 'In Need' Status
#'
#' @description This set of functions adds new binary variables indicating if a score is above certain thresholds. [is_in_need()] adds a variable for scores above 3 (indicating "in need"), while [is_in_severe_need()] adds a variable for scores above 4 (indicating "in severe need").
#'
#' @param df A dataframe containing the score variable.
#' @param score The variable containing the score on a 1-5 scale.
#' @param new_colname The name of the new column. If NULL, the function will create a new column with the name 'score_in_need' or 'score_in_severe_need'.
#'
#' @return A dataframe with an additional column:
#'
#' * new_colname: A binary variable indicating if the score meets the threshold for being "in need" (1) or not (0).
#'
#' @export
is_in_need <- function(
  df,
  score,
  new_colname = NULL
) {
  #------ Checks

  # Check that variable is in df
  if_not_in_stop(df, score, "df")

  # Check that all values are in set 1:5
  are_values_in_set(df, score, 1:5)

  # Create new column name
  if (is.null(new_colname)) {
    new_colname <- paste0(score, "_in_need")
  }

  # Check if newcolname exists in the dataframe, if yes throw a warning for replacement
  if (new_colname %in% names(df)) {
    rlang::warn(paste0(
      new_colname,
      " already exists in the data frame. It will be replaced."
    ))
  }

  #------ Create new variable

  df <- dplyr::mutate(
    df,
    "{new_colname}" := dplyr::case_when(
      !!rlang::sym(score) %in% 1:2 ~ 0,
      !!rlang::sym(score) %in% 3:5 ~ 1,
      .default = NA_integer_
    )
  )

  return(df)
}

#' @rdname is_in_need
#'
#' @export
is_in_severe_need <- function(
  df,
  score,
  new_colname = NULL
) {
  #------ Checks

  # Check that variable is in df
  if_not_in_stop(df, score, "df")

  # Check that all values are in set 1:5
  are_values_in_set(df, score, 1:5)

  # Create new column name
  if (is.null(new_colname)) {
    new_colname <- paste0(score, "_in_severe_need")
  }

  # Check if newcolname exists in the dataframe, if yes throw a warning for replacement
  if (new_colname %in% names(df)) {
    rlang::warn(paste0(
      new_colname,
      " already exists in the data frame. It will be replaced."
    ))
  }

  #------ Create new variable, severe need is defined as score 4 or 5.

  df <- dplyr::mutate(
    df,
    "{new_colname}" := dplyr::case_when(
      !!rlang::sym(score) %in% 1:3 ~ 0,
      !!rlang::sym(score) %in% 4:5 ~ 1,
      .default = NA_integer_
    )
  )

  return(df)
}
