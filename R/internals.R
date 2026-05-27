#' @title Stop statement values are not integer
#'
#' @description This stop statement checks that specified columns are integer or numeric with all integer values (to not be too restrictive as the aim is not much to ensure integer values but not integer type).
#'
#'
#' @param df A data frame
#' @param cols A vector of column names (quoted)
#'
#' @return A stop statement
are_cols_integer <- function(df, cols) {
  #------ Check for missing columns
  if_not_in_stop(df, cols, "df")

  classes <- purrr::map_lgl(
    dplyr::select(
      df,
      dplyr::all_of(cols)
    ),
    \(x) is.integer(x) || (is.numeric(x) && all(x == floor(x), na.rm = TRUE))
  )

  cols <- cols[!classes]

  if (!all(classes)) {
    cli::cli_abort(
      c(
        "All columns must be integer or numeric with all integer values.",
        "i" = glue::glue(
          "The following columns are not integer or numeric with all integer values. Please check.\n",
          glue::glue_collapse(cols, sep = "\n")
        )
      )
    )
  }

  return(TRUE)
}

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
#' @param df_name Provide the tibble name as a character string
#' @param arg Default to NULL.
#'
#' @return A stop statement
if_not_in_stop <- function(df, cols, df_name, arg = NULL) {
  # check that df is a data frame
  is_df(df, df_name)

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
#' @param arg Default to NULL.
#'
#' @return A stop statement
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
