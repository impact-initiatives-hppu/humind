#' @title Categorize Age and Create Age-Related Variables
#'
#' @description
#' This function provides two main functionalities:
#' 1. `add_age_cat()`: Adds age categories to a dataframe based on specified breaks.
#' 2. `add_age_18_cat()`: Adds age categories and a dummy variable for below and above 18 years old.
#'
#' @param df A dataframe.
#' @param age_col The column name to recategorize.
#' @param breaks A vector of cut points.
#' @param labels A vector of labels. If NULL, the labels will be the breaks.
#' @param int_undefined A vector of values undefined (such as -999, 999) to replace by char_undefined.
#' @param char_undefined A character to replace int_undefined values, often values corresponding to Don't know or Prefer not to answer.
#' @param new_colname The name of the new column. If NULL, it adds "_cat" to the age_col (or "_18_cat for `add_age_18_cat()`).
#'
#' @return
#' * For `add_age_cat()`: A dataframe with an additional column containing the age categories.
#' * For `add_age_18_cat()`: A dataframe with two additional columns: one with categories (below_18, above_18) and one with a dummy variable (0 for below 18, 1 for above 18).
#'
#' @export
add_age_cat <- function(
  df,
  age_col,
  breaks = c(0, 18, 60, 120),
  labels = NULL,
  int_undefined = c(-999, 999),
  char_undefined = "undefined",
  new_colname = NULL
) {
  # Use categorize_num function
  df <- num_cat(
    df = df,
    num_col = age_col,
    breaks = breaks,
    labels = labels,
    int_undefined = int_undefined,
    char_undefined = char_undefined,
    new_colname = new_colname,
    plus_last = TRUE,
    above_last = TRUE
  )

  return(df)
}

#' @rdname add_age_cat
#'
#' @export
add_age_18_cat <- function(
  df,
  age_col,
  int_undefined = c(-999, 999),
  char_undefined = "undefined",
  new_colname = NULL
) {
  # If new_colname is not provided, create one
  if (is.null(new_colname)) {
    new_colname <- paste0(age_col, "_18_cat")
  }

  # Paste "_d" for the new dummy column
  new_colname_d <- paste0(new_colname, "_d")

  df <- dplyr::mutate(
    df,
    # Labels class
    "{new_colname}" := dplyr::case_when(
      !!rlang::sym(age_col) %in% int_undefined ~ char_undefined,
      !!rlang::sym(age_col) < 18 ~ "below_18",
      !!rlang::sym(age_col) >= 18 ~ "above_18",
      .default = NA_character_
    ),
    # Dummy 1 or 0 column
    "{new_colname_d}" := dplyr::case_when(
      !!rlang::sym(new_colname) == char_undefined ~ NA_integer_,
      # Replace values below 18 by 1
      !!rlang::sym(new_colname) == "above_18" ~ 1,
      # Replace values above 18 by 0
      !!rlang::sym(new_colname) == "below_18" ~ 0,
      .default = NA_integer_
    )
  )

  return(df)
}
