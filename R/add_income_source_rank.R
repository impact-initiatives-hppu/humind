#' @title Add Income Source Categories, Count, and Ranking Top 3
#'
#' @description This function categorizes income sources, counts them by type, and ranks the top 3 income sources.
#' It also adds categories for emergency, unstable, stable, and other income sources.
#'
#' Prerequisite function:
#'
#' * add_income_source_zero_to_sl.R
#'
#' @param df A data frame containing income source information.
#' @param emergency A vector of column names containing emergency income sources.
#' @param unstable A vector of column names containing unstable income sources.
#' @param stable A vector of column names containing stable income sources.
#' @param other The name of the column containing other income sources.
#' @param id_col The name of the column containing the unique identifier.
#'
#' @return A data frame with additional columns:
#' * cm_income_source_emergency_n: Count of emergency income sources.
#' * cm_income_source_unstable_n: Count of unstable income sources.
#' * cm_income_source_stable_n: Count of stable income sources.
#' * cm_income_source_other_n: Count of other income sources.
#' * cm_income_source_top1: Top income source.
#' * cm_income_source_top2: Second top income source.
#' * cm_income_source_top3: Third top income source.
#'
#' @export
add_income_source_rank <- function(
  df,
  emergency = c(
    "cm_income_source_assistance_n",
    "cm_income_source_support_friends_n",
    "cm_income_source_donation_n"
  ),
  unstable = c(
    "cm_income_source_casual_n",
    "cm_income_source_social_benefits_n",
    "cm_income_source_rent_n",
    "cm_income_source_remittances_n"
  ),
  stable = c(
    "cm_income_source_salaried_n",
    "cm_income_source_own_business_n",
    "cm_income_source_own_production_n"
  ),
  other = "cm_income_source_other_n",
  id_col = "uuid"
) {
  #------ Checks

  # Check that all are variables in the dataset
  if_not_in_stop(df, c(emergency, unstable, stable, other), "df")

  # Check that all are numeric
  are_cols_numeric(df, c(emergency, unstable, stable, other))

  #------ Compute the number of all income sources

  # Emergency
  df <- count_if_above_zero(df, emergency, "cm_income_source_emergency_n")

  # Unstable
  df <- count_if_above_zero(df, unstable, "cm_income_source_unstable_n")

  # Stable
  df <- count_if_above_zero(df, stable, "cm_income_source_stable_n")

  # Other
  df <- count_if_above_zero(df, other, "cm_income_source_other_n")

  # Ranking
  df <- rank_top3_vars(
    df = df,
    vars = c(emergency, unstable, stable, other),
    new_colname_top1 = "cm_income_source_top1",
    new_colname_top2 = "cm_income_source_top2",
    new_colname_top3 = "cm_income_source_top3",
    id_col = id_col
  )

  # Add final category:

  # Handy function - Recode income sources
  income_source_cat_rec <- function(
    df,
    var,
    emergency,
    unstable,
    stable,
    undefined
  ) {
    dplyr::mutate(
      df,
      "{var}" := dplyr::case_when(
        !!rlang::sym(var) %in% emergency ~ "emergency",
        !!rlang::sym(var) %in% unstable ~ "unstable",
        !!rlang::sym(var) %in% stable ~ "stable",
        !!rlang::sym(var) %in% other ~ "other",
        .default = NA_character_
      )
    )
  }

  # Recode income sources across cm_income_source_top* columns
  df <- income_source_cat_rec(
    df,
    "cm_income_source_top1",
    emergency,
    unstable,
    stable,
    other
  )
  df <- income_source_cat_rec(
    df,
    "cm_income_source_top2",
    emergency,
    unstable,
    stable,
    other
  )
  df <- income_source_cat_rec(
    df,
    "cm_income_source_top3",
    emergency,
    unstable,
    stable,
    other
  )

  return(df)
}
