#' Function to add top 3 columns out of numeric variables
#'
#' In case of equality, this function takes precedence in the order of 'vars' as factors.
#'
#' @param df A data frame.
#' @param vars A character vector of numeric variable names.
#' @param new_colname_top1 The new column name for the top variable.
#' @param new_colname_top2 The new column name for the 2nd top variable.
#' @param new_colname_top3 The new column name for the 3rd top variable.
#' @param id_col The column name for the unique identifier.
#'
#'
#' @export
rank_top3_vars <- function(df, vars, new_colname_top1, new_colname_top2, new_colname_top3, id_col = "uuid") {

  #------ Checks

  # Check if the variables are present
  if_not_in_stop(df, vars, "df")

  # Check if vars are numeric
  are_cols_numeric(df, vars)

  # Check if the new columns are present, if yes, throw a warning
  new_vars <- c(new_colname_top1, new_colname_top2, new_colname_top3)
  new_vars_in_df <- intersect(new_vars, colnames(df))
  if (length(new_vars_in_df) > 0) {
    rlang::warn(glue::glue("The following variables exist in 'df' and will be replaced: ", glue::glue_collapse(new_vars_in_df, sep = ", ", last = " and ")))
  }

  #------Rank

  # Rank income sources for each row
  int <- tidyr::pivot_longer(
    dplyr::select(df, dplyr::all_of(c(id_col, vars))),
    vars,
    names_to = "var",
    values_to = "val")

  # Remove zeros or NAs
  int <- dplyr::filter(int, !is.na(!!rlang::sym("val")) & !!rlang::sym("val") > 0)

  # Group and summarize
  int <- dplyr::group_by(int, !!rlang::sym(id_col))
  # Group making sure that it follows col order
  # For income, the order counting stable, unstable and then emergency
  # Rational is: if amount of stable == amount of emergency, we keep stable as the source
  int <- dplyr::arrange(int, !!rlang::sym(id_col), dplyr::desc(!!rlang::sym("val")), factor(!!rlang::sym("var"), levels = vars))

  # summarize and get first, 2nd and 3rd
  int <- dplyr::summarize(
    int,
    "{new_colname_top1}" := dplyr::first(!!rlang::sym("var")),
    "{new_colname_top2}" := dplyr::nth(!!rlang::sym("var"), 2),
    "{new_colname_top3}" := dplyr::nth(!!rlang::sym("var"), 3))

  int <- dplyr::ungroup(int)

  # (Re)join
  df <- dplyr::select(df, - dplyr::any_of(c(new_colname_top1, new_colname_top2, new_colname_top3)))
  df <- dplyr::left_join(df, int, by = id_col)
  df <- dplyr::as_tibble(df)

  return(df)
}
