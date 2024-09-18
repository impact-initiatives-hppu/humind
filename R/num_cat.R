#' Add categories for a numeric variable
#'
#' @param df A dataframe.
#' @param num_col The column name to recategorize.
#' @param breaks A vector of cut points.
#' @param labels A vector of labels.
#' @param int_undefined A vector of values to replace by char_dontknow.
#' @param char_undefined A character to replace int_dontknow values.
#' @param new_colname The name of the new column.
#' @param plus_last Logical, whether to add a "+" to the last category.
#' @param above_last Logical, whether to add a category for values above the last break.
#'
#' @return A dataframe with a new column.
#'
#' @export
num_cat <- function(df, num_col, breaks, labels = NULL, int_undefined = c(-999, 999),
                    char_undefined = "Unknown", new_colname = NULL, plus_last = FALSE, above_last = FALSE) {
  #------ Checks

  # Check if num_col is in df
  if_not_in_stop(df, num_col, "df")

  # Check if num_col is numeric
  are_cols_numeric(df, num_col)

  # Check if int_dontknow is numeric
  if (!all(sapply(int_undefined, is.numeric))) rlang::abort("int_dontknow must only contain numeric values")

  # Check if char_dontknow is of length 1
  if (length(char_undefined) != 1) rlang::abort("char_dontknow must be of length 1")

  # Check if char_dontknow is character
  if (!is.character(char_undefined)) rlang::abort("char_dontknow must be a character")

  # Check if breaks have at least two values
  if (length(breaks) < 2) rlang::abort("breaks must have at least two values")

  # Check that above_last is logical and not NA
  if (!is.logical(above_last) || is.na(above_last)) {
    rlang::abort("above_last must be logical and not NA")
  }

  # Check if labels is of length of breaks if above_last is TRUE
  if (!is.null(labels) && length(labels) != length(breaks) && above_last) {
    rlang::warn("labels must be of length of breaks. Reverting to labels = NULL")
    labels <- NULL
  }

  # Check if labels is of length of breaks - 1 if above_last is FALSE
  if (!is.null(labels) && length(labels) != length(breaks) - 1 && !above_last) {
    rlang::warn("labels must be of length of breaks - 1. Reverting to labels = NULL")
    labels <- NULL
  }



  # Check that plus_last is logical and not NA
  if (!is.logical(plus_last) || is.na(plus_last)) {
    rlang::abort("plus_last must be logical and not NA")
  }

  # If new_colname is not provided, create one
  if (is.null(new_colname)) new_colname <- paste0(num_col, "_cat")

  #----- Create labels if NULL

  vals <- df[[num_col]]
  vals <- vals[!(vals %in% int_undefined)]
  max_val <- max(vals, na.rm = TRUE)

  # Total number of breaks
  if (above_last) breaks <- c(breaks, Inf)

  # If labels are not provided, generate them
  if (is.null(labels)) {

    labels <- sapply(1:(length(breaks) - 1), function(i) {
      lower <- breaks[i]
      upper <- breaks[i + 1]
      if (i == length(breaks) - 1 && plus_last) {
        return(paste0(lower, "+"))
      } else if (i == length(breaks) - 1 && !plus_last) {
        if (lower == max_val) return(paste0(lower, "+")) else return(paste0(lower, "-", max_val))
      } else {
        return(paste0(lower, "-", upper - 1))
      }
    })
  }

  # Create categories
  df <- dplyr::mutate(df, "{new_colname}" := dplyr::case_when(
    # Replace value in int_dontkow by char_dontknow
    !!rlang::sym(num_col) %in% int_undefined ~ char_undefined,
    # Replace values below min(breaks) by NA
    !!rlang::sym(num_col) < min(breaks) ~ NA_character_,
    # Create categories using function cut and adjusted breaks
    .default = cut(!!rlang::sym(num_col),
                   breaks = breaks,
                   labels = labels,
                   include.lowest = TRUE,
                   right = FALSE)
    )
  )

  return(df)
}
