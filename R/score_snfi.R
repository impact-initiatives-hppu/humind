#' SNFI sectoral composite - add score
#'
#' @param df A data frame.
#' @param shelter_type_cat Column name for shelter type.
#' @param shelter_type_cat_levels Levels for shelter type.
#' @param shelter_issue_cat Column name for shelter issue.
#' @param shelter_issue_cat_levels Levels for shelter issue.
#' @param occupancy_cat Column name for occupancy.
#' @param occupancy_cat_levels Levels for occupancy.
#' @param fds_cannot_cat Column name for fds cannot.
#' @param fds_cannot_cat_levels Levels for fds cannot.
#'
#' @export
score_snfi <- function(
    df,
    shelter_type_cat = "snfi_shelter_type_cat",
    shelter_type_cat_levels = c("none", "inadequate", "adequate", "undefined"),
    shelter_issue_cat = "snfi_shelter_issue_cat",
    shelter_issue_cat_levels = c("none", "7_to_8", "4_to_6", "1_to_3", "undefined"),
    occupancy_cat = "hlp_occupancy_cat",
    occupancy_cat_levels = c("high_risk", "medium_risk", "low_risk", "undefined"),
    fds_cannot_cat= "snfi_fds_cannot_cat",
    fds_cannot_cat_levels = c("4_to_5_tasks", "2_to_3_tasks", "1_task", "none", "undefined")
){

  #----- Checks

  # Check that columns are in df
  if_not_in_stop(df, c(shelter_type_cat, shelter_issue_cat, occupancy_cat, fds_cannot_cat), "df")

  # Checks that shelter_type_cat are in levels
  are_values_in_set(df, shelter_type_cat, shelter_type_cat_levels)


  # Compute score for shelter type
  df <- dplyr::mutate(
    df,
    score_snfi_shelter_type_cat = dplyr::case_when(
      !!rlang::sym(shelter_type_cat) == shelter_type_cat_levels[1] ~ 5,
      !!rlang::sym(shelter_type_cat) == shelter_type_cat_levels[2] ~ 3,
      !!rlang::sym(shelter_type_cat) == shelter_type_cat_levels[3] ~ 1,
      !!rlang::sym(shelter_type_cat) == shelter_type_cat_levels[4] ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for shelter issue
  df <- dplyr::mutate(
    df,
    score_snfi_shelter_issue_cat = dplyr::case_when(
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[1] ~ 4,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[2] ~ 3,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[3] ~ 2,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[4] ~ 1,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[5] ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for occupancy
  df <- dplyr::mutate(
    df,
    score_snfi_occupancy_cat = dplyr::case_when(
      !!rlang::sym(occupancy_cat) == occupancy_cat_levels[1] ~ 3,
      !!rlang::sym(occupancy_cat) == occupancy_cat_levels[2] ~ 2,
      !!rlang::sym(occupancy_cat) == occupancy_cat_levels[3] ~ 1,
      !!rlang::sym(occupancy_cat) == occupancy_cat_levels[4] ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for fds cannot
  df <- dplyr::mutate(
    df,
    score_snfi_fds_cannot_cat = dplyr::case_when(
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[1] ~ 4,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[2] ~ 3,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[3] ~ 2,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[4] ~ 1,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[5] ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute total score = max
  df <- impactR.utils::row_optimum(
    df,
    !!!rlang::syms(c("score_snfi_shelter_type_cat", "score_snfi_shelter_issue_cat", "score_snfi_occupancy_cat", "score_snfi_fds_cannot_cat")),
    optimum = "max",
    max_name = "score_snfi",
    na_rm = TRUE
  )

  return(df)

}
