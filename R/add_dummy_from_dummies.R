#' @title Add a dummy variable from dummies (if any is 1)
#'
#' @param df A data frame
#' @param dummy_name The new dummy column name
#' @param ... Dummy columns from df, must be in set c(0,1).
#' @param na_to_zero Boolean. Mutate NA values to zero.
#'
#' @return An update data frame with a new dummy column.
#' @export
add_dummy_from_dummies <- function(df,
                                   dummy_name = "dummy_from_dummies",
                                   ...,
                                   na_to_zero = FALSE){

  #------ Check if cols from ... are in df
  quoted_cols <- purrr::map_chr(rlang::enquos(...), rlang::as_name)
  # if_not_in_stop(df, quoted_cols, "df", arg = "...")

  #------ Check if all values  are 0 or 1
  are_values_in_set(df, quoted_cols, c(0,1))

  #------ Mutate 1 if string is detected, 0 if not, NA depends on na_to_zero
  if(na_to_zero) {
    df <- dplyr::mutate(
      df,
      "{dummy_name}" := dplyr::case_when(
        rowSums(dplyr::across(dplyr::all_of(quoted_cols)), na.rm = TRUE) >= 1 ~ 1,
        rowSums(dplyr::across(dplyr::all_of(quoted_cols)), na.rm = TRUE) < 1 ~ 0,
        TRUE ~ NA_real_
      )
    )
  } else {
    df <- dplyr::mutate(
      df,
      "{dummy_name}" := dplyr::case_when(
        rowSums(dplyr::across(dplyr::all_of(quoted_cols)), na.rm = FALSE) >= 1 ~ 1,
        rowSums(dplyr::across(dplyr::all_of(quoted_cols)), na.rm = FALSE) < 1 ~ 0,
        TRUE ~ NA_real_
      )
    )
  }

  return(df)

}
