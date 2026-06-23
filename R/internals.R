#' @title Stop statement values are not numeric
#'
#' @param df A data frame
#' @param cols A vector of column names (quoted)
#'
#' @return A stop statement
are_cols_numeric <- function(df, cols) {
  #------ Check for missing columns
  if_not_in_stop(df, cols, "df")

  classes <- purrr::map_lgl(
    dplyr::select(
      df,
      dplyr::all_of(cols)
    ),
    is.numeric
  )

  cols <- cols[!classes]

  if (!all(classes)) {
    rlang::abort(c(
      "All columns must be numeric.",
      "i" = glue::glue(
        "The following columns are not numeric. Please check.\n",
        glue::glue_collapse(cols, sep = "\n")
      )
    ))
  }

  return(TRUE)
}

#' @title Stop statement values are not in range
#'
#' @param df A data frame
#' @param cols A vector of column names (quoted)
#' @param lower Lower bound
#' @param upper Upper bound
#'
#' @return A stop statement
are_values_in_range <- function(df, cols, lower = 0, upper = 7) {
  #------ Only use on numeric columns
  are_cols_numeric(df, cols)

  ranges <- purrr::map_lgl(
    dplyr::select(
      df,
      dplyr::all_of(cols)
    ),
    \(x) {
      sum(x < lower | x > upper, na.rm = TRUE) >= 1
    }
  )

  cols <- cols[ranges]

  if (all(ranges)) {
    rlang::abort(c(
      glue::glue("All columns must be between {lower} and {upper}."),
      "i" = glue::glue(
        "The following columns have values outside the range Please check.\n",
        glue::glue_collapse(cols, sep = "\n")
      )
    ))
  }

  return(TRUE)
}


#' @title Stop statement values are not in set
#'
#' @param df A data frame
#' @param cols A vector of column names (quoted)
#' @param set A vector of values
#' @param main_message A main message
#'
#' @return A stop statement
are_values_in_set <- function(
  df,
  cols,
  set,
  main_message = "All columns must be in the following set: "
) {
  #------ Check for missing columns
  if_not_in_stop(df, cols, "df")

  #------ Values not in set
  values_lgl <- purrr::map_lgl(
    dplyr::select(
      df,
      dplyr::all_of(cols)
    ),
    \(x) {
      !all(stats::na.omit(unique(x)) %in% set)
    }
  )

  if (any(values_lgl)) {
    cols <- cols[values_lgl]
    values_chr <- names(values_lgl)

    # Get values not in set
    df_cols <- dplyr::select(df, dplyr::all_of(cols))
    values_chr <- purrr::map(df_cols, \(x) {
      x <- unique(x)
      x[!is.na(x) & !(x %in% set)]
    })

    values_chr <- purrr::imap_chr(values_chr, \(x, idx) {
      glue::glue("{idx}: {glue::glue_collapse(x, sep = ', ', last = ' and ')}")
    })

    rlang::abort(c(
      glue::glue(main_message, glue::glue_collapse(set, sep = ", ")),
      "i" = glue::glue(
        "The following columns have values out of the set Please check.\n",
        glue::glue_collapse(cols, sep = "\n")
      ),
      "x" = glue::glue(
        "The values out of the set are:\n",
        glue::glue_collapse(values_chr, sep = "\n")
      )
    ))
  }

  return(TRUE)
}


#' @title Subvec in
#'
#' @param vector A vector to subset
#' @param set A set-vector
#'
#' @return A subset of a list or a vector
subvec_in <- function(vector, set) {
  vector[vector %in% set]
}

#' @title Subvec not in
#'
#' @param vector A vector to subset
#' @param set A set-vector
#'
#' @return A subset of vector not in set
subvec_not_in <- function(vector, set) {
  vector[!(vector %in% set)]
}


#' @title Stop statement "If not in colnames" with colnames
#'
#' @param df A data frame
#' @param cols A vector of column names (quoted)
#' @param df_name Name of the data frame as it appears in the caller (e.g.
#'   `"df"`, `"loop"`). Used in error messages to identify the container.
#' @param arg Name of the caller's parameter that supplied `cols` (e.g.
#'   `"ind_age"`). When provided, the missing-column error reads "columns from
#'   `{arg}` are missing in `{df_name}`", and the non-data.frame error labels
#'   the input as `{arg}` instead of `{df_name}`. Defaults to `NULL`.
#'
#' @return `invisible(NULL)` if all `cols` are present in `df`, otherwise
#'   stops with an informative error.
#'
#' @examples
#' \dontrun{
#' my_data <- data.frame(a = 1, b = 2)
#'
#' # All columns present: returns invisibly
#' if_not_in_stop(my_data, c("a", "b"), "my_data")
#'
#' # Missing column with arg: error names both the parameter and the data frame
#' if_not_in_stop(my_data, c("a", "c"), "my_data", arg = "ind_age")
#'
#' # Non-data.frame with arg: error labels the input using arg
#' if_not_in_stop("not_a_df", c("a"), "my_data", arg = "ind_age")
#' }
if_not_in_stop <- function(df, cols, df_name, arg = NULL) {
  # check that df is a data frame
  is_df(df, arg %||% df_name)

  missing_cols <- subvec_not_in(cols, colnames(df))

  # prepare message
  if (is.null(arg)) {
    if (length(missing_cols) >= 2) {
      msg <- glue::glue("The following columns are missing in `{df_name}`: ")
    } else {
      msg <- glue::glue("The following column is missing in `{df_name}`: ")
    }
  } else {
    if (length(missing_cols) >= 2) {
      msg <- glue::glue(
        "The following columns from `{arg}` are missing in `{df_name}`: "
      )
    } else {
      msg <- glue::glue(
        "The following column from `{arg}` is missing in `{df_name}`: "
      )
    }
  }
  if (length(missing_cols) >= 1) {
    rlang::abort(
      c(
        "Missing columns",
        "*" = glue::glue(
          msg,
          glue::glue_collapse(
            missing_cols,
            sep = ", ",
            last = ", and "
          )
        )
      )
    )
  }
}


#' @title Stop statement "If input is not a data.frame"
#'
#' @param df A data frame
#' @param arg Label for `df` in the error message — typically the name of the
#'   function parameter that received `df`. When `NULL`, the message reads
#'   "Input  must be a data.frame." so callers should always pass a label.
#'
#' @return `invisible(TRUE)` if `df` is a data frame, otherwise stops with an
#'   informative error.
#'
#' @examples
#' \dontrun{
#' my_data <- data.frame(a = 1, b = 2)
#'
#' # Valid data frame: returns invisible TRUE
#' is_df(my_data, "my_data")
#'
#' # Non-data.frame: error labels the input using arg
#' is_df("not_a_df", "my_data")
#' }
is_df <- function(df, arg = NULL) {
  if (!is.data.frame(df)) {
    cli::cli_abort(
      c(
        "Input {arg} must be a data.frame.",
        "i" = "Input is of class: {class(df)}."
      )
    )
  }
  invisible(TRUE)
}
