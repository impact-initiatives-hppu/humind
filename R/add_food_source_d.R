#' ANA
#' 2025 INDICATOR ID: IND052 and IND053
#' 2026 METRIC ID: TBD

#' @title Add Food Source Dummy Variables
#'
#' @description Creates two binary (1/0/NA) dummy variables indicating whether a
#' household relied on humanitarian assistance or atypical food sources during the
#' recall period. Binary columns for each choice are built as `<source_food><sep><choice>`.
#'
#' @param df A data frame of household-level data.
#' @param source_food Base column name for the select_multiple food source question.
#' @param aid Character vector of choice names for humanitarian assistance food sources.
#' @param unstable Character vector of choice names for atypical/unstable food sources.
#' @param sep Separator between the base column name and the choice name. Default `"/"`.
#'
#' @return A data frame with two additional columns:
#'
#' * fsl_food_source_aid_d: 1 if any humanitarian assistance food source column is 1; 0 if all aid columns are 0; NA otherwise.
#' * fsl_food_source_unstable_d: 1 if any atypical food source column is 1;  0 if all unstable columns are 0; NA otherwise.
#'
#' @export
add_food_source_d <- function(
  df,
  source_food = "fsl_source_food",
  aid = c(
    "assistance_in_kind",
    "assistance_cva"
  ),
  unstable = c(
    "gathering",
    "exchange",
    "borrow",
    "gift",
    "begging"
  ),
  sep = "/"
) {
  #------ Checks

  # Build binary column name vectors
  aid_cols <- paste0(source_food, sep, aid)
  unstable_cols <- paste0(source_food, sep, unstable)

  # required columns are in df
  if_not_in_stop(df, c(aid_cols, unstable_cols), "df")

  # values are in set {0, 1}
  are_values_in_set(df, c(aid_cols, unstable_cols), c(0, 1))

  # Warn if output columns already exist
  if ("fsl_food_source_aid_d" %in% colnames(df)) {
    rlang::warn(
      "fsl_food_source_aid_d already exists in df. It will be replaced."
    )
  }
  if ("fsl_food_source_unstable_d" %in% colnames(df)) {
    rlang::warn(
      "fsl_food_source_unstable_d already exists in df. It will be replaced."
    )
  }

  #------ Compute

  df <- dplyr::mutate(
    df,
    fsl_food_source_aid_d = dplyr::case_when(
      rowSums(dplyr::pick(dplyr::all_of(aid_cols)) == 1, na.rm = TRUE) > 0 ~ 1,
      rowSums(is.na(dplyr::pick(dplyr::all_of(aid_cols)))) == 0 ~ 0,
      .default = NA_real_
    ),
    fsl_food_source_unstable_d = dplyr::case_when(
      rowSums(dplyr::pick(dplyr::all_of(unstable_cols)) == 1, na.rm = TRUE) > 0 ~ 1,
      rowSums(is.na(dplyr::pick(dplyr::all_of(unstable_cols)))) == 0 ~ 0,
      .default = NA_real_
    )
  )

  return(df)
}
