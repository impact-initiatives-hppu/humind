#' ANA function
#' 2025 INDICATOR ID: IND053
#' 2026 METRIC ID: TBD

#' @title Add Atypical First-Ranked Food Source Dummy Variable
#'
#' @description Creates a binary (1/0/NA) dummy variable indicating whether a
#' household's first-ranked (main) food source is atypical/emergency. The
#' first-ranked source is taken from the ranked food-source question
#' (`fsl_source_food_ranked`), whose value is an ordered, space-separated list
#' of choice names.
#'
#' @param df A data frame of household-level data.
#' @param source_food Column name for the ranked food-source question. Its
#'   value is an ordered, space-separated list of choice names; the first entry
#'   is the household's main food source.
#' @param atypical Character vector of choice names for atypical/emergency food
#'   sources. The dummy is `1` when the first-ranked source is in this set. Must
#'   not overlap `non_atypical` or `undefined`.
#' @param non_atypical Character vector of known, valid non-atypical food
#'   sources. The dummy is `0` when the first-ranked source is in this set. Must
#'   not overlap `atypical` or `undefined`.
#' @param undefined Character vector of non-substantive responses (e.g. `other`,
#'   `dnk`, `pnta`). The dummy is `NA` when the first-ranked source is in this
#'   set, and also when it is missing.
#' @param rank_sep Separator between ranked choices in `source_food`.
#'   Default `" "`.
#'
#' @return A data frame with additional columns:
#'
#' * fsl_food_source_main: The first-ranked (main) food source, or `NA` when
#'   missing.
#' * fsl_food_source_atypical_d: 1 if the first-ranked food source is atypical;
#'   0 if it is a known non-atypical source; `NA` if it cannot be classified.
#'
#' @examples
#' df <- data.frame(
#'   fsl_source_food_ranked = c(
#'     "hunting purchase_cash",
#'     "purchase_cash own_production",
#'     "other purchase_cash",
#'     NA
#'   )
#' )
#' add_food_source_atypical_d(df)
#'
#' @export
add_food_source_atypical_d <- function(
  df,
  source_food = "fsl_source_food_ranked",
  atypical = c(
    "hunting",
    "gathering",
    "exchange",
    "borrow",
    "gift",
    "begging"
  ),
  non_atypical = c(
    "own_production",
    "purchase_cash",
    "purchase_credit",
    "assistance_in_kind",
    "assistance_cva"
  ),
  undefined = c("other", "dnk", "pnta"),
  rank_sep = " "
) {
  #------ Checks

  # Check the ranked food-source column is present
  if_not_in_stop(df, source_food, "df")

  # The response-code sets must be mutually disjoint
  checkmate::assert_disjunct(atypical, non_atypical, .var.name = "atypical")
  checkmate::assert_disjunct(atypical, undefined, .var.name = "atypical")
  checkmate::assert_disjunct(
    non_atypical,
    undefined,
    .var.name = "non_atypical"
  )

  # Warn if output columns already exist
  if ("fsl_food_source_main" %in% colnames(df)) {
    rlang::warn(
      "fsl_food_source_main already exists in df. It will be replaced."
    )
  }
  if ("fsl_food_source_atypical_d" %in% colnames(df)) {
    rlang::warn(
      "fsl_food_source_atypical_d already exists in df. It will be replaced."
    )
  }

  #------ Extract the first-ranked (main) food source

  # Empty or whitespace-only answers are treated as missing.
  df <- dplyr::mutate(
    df,
    fsl_food_source_main = dplyr::na_if(
      stringr::word(
        stringr::str_squish(.data[[source_food]]),
        1,
        sep = stringr::fixed(rank_sep)
      ),
      ""
    )
  )

  are_values_in_set(
    df,
    "fsl_food_source_main",
    c(atypical, non_atypical, undefined)
  )

  #------ Recode

  # Table-driven recode: 1 for atypical, 0 for known non-atypical, NA otherwise
  df <- dplyr::mutate(
    df,
    fsl_food_source_atypical_d = dplyr::recode_values(
      fsl_food_source_main,
      from = c(atypical, non_atypical, undefined),
      to = c(
        rep(1, length(atypical)),
        rep(0, length(non_atypical)),
        rep(NA_real_, length(undefined))
      )
    )
  )

  df
}
