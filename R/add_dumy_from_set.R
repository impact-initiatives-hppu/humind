#' Add a dummy variable when any string from a set of strings exists
#'
#' @param df A data frame
#' @param col A column
#' @param set A vector of strings to detect from, such as c("string1", "string2")
#' @param dummy_name The new dummy column name
#' @param na_to_zero Boolean. Convert NAs to zeros or not.
#'
#' @return An update data frame with a new dummy column.
#' @export
add_dummy_from_set <- function(df, col, dummy_name, set, na_to_zero = FALSE){

  # Please not that this is not robust regarding the set of strings.
  # THe function will basically collapse and create a pattern from the character vector.
  # if you look for "male" in a set of "male" and "female", look for "male" will return TRUE for both

  #------ Check if col is in df
  col_name <- rlang::as_name(rlang::enquo(col))
  if_not_in_stop(df, col_name, "df", "col")

  #------ Collapse string patterns
  pattern <- stringr::str_c(set, collapse = "|")

  #------ Mutate 1 if string is detected, 0 if not, NA depends on na_to_zero
  if(!na_to_zero) {
    df <- dplyr::mutate(
      df,
      "{dummy_name}" := dplyr::case_when(
        is.na({{ col }}) ~ NA_real_,
        stringr::str_detect({{ col }}, pattern) ~ 1,
        !stringr::str_detect({{ col }}, pattern) ~ 0,
        .default = NA_real_
      )
    )
  } else if (na_to_zero) {
    df <- dplyr::mutate(
      df,
      "{dummy_name}" := dplyr::case_when(
        is.na({{ col }}) ~ 0,
        stringr::str_detect({{ col }}, pattern) ~ 1,
        !stringr::str_detect({{ col }}, pattern) ~ 0,
        .default = NA_real_
      )
    )
  }

  return(df)

}
