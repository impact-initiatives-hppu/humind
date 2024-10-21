#' SNFI sectoral composite - add score and dummy for in need
#'
#' @param df A data frame.
#' @param shelter_type_cat Column name for shelter type.
#' @param shelter_type_cat_levels Levels for shelter type in that order: none, inadequate, adequate, undefined.
#' @param shelter_issue_cat Column name for shelter issue.
#' @param shelter_issue_cat_levels Levels for shelter issue in that order: none, 7_to_8, 4_to_6, 1_to_3, undefined, other.
#' @param occupancy_cat Column name for occupancy.
#' @param occupancy_cat_levels Levels for occupancy in that order: high_risk, medium_risk, low_risk, undefined.
#' @param fds_cannot_cat Column name for fds cannot.
#' @param fds_cannot_cat_levels Levels for fds cannot. in that order: 4_to_5_tasks, 2_to_3_tasks, 1_task, none, undefined.
#'
#' @export
add_comp_snfi <- function(
    df,
    shelter_type_cat = "snfi_shelter_type_cat",
    shelter_type_cat_levels = c("none", "inadequate", "adequate", "undefined"),
    shelter_issue_cat = "snfi_shelter_issue_cat",
    shelter_issue_cat_levels = c("7_to_8", "4_to_6", "1_to_3", "none", "undefined", "other"),
    occupancy_cat = "hlp_occupancy_cat",
    occupancy_cat_levels = c("high_risk", "medium_risk", "low_risk", "undefined"),
    fds_cannot_cat = "snfi_fds_cannot_cat",
    fds_cannot_cat_levels = c("4_to_5_tasks", "2_to_3_tasks", "1_task", "none", "undefined")
    ){

  #----- Checks

  # Check that columns are in df
  if_not_in_stop(df, c(shelter_type_cat, shelter_issue_cat, occupancy_cat, fds_cannot_cat), "df")

  # Checks that shelter_type_cat are in levels
  are_values_in_set(df, shelter_type_cat, shelter_type_cat_levels)

  #Checks that shelter issues are in levels
  are_values_in_set(df, shelter_issue_cat, shelter_issue_cat_levels)

  # Checks that occupancy cat are in levels
  are_values_in_set(df, occupancy_cat, occupancy_cat_levels)

  # Check that fds_cannot_cat are in levels
  are_values_in_set(df, fds_cannot_cat, fds_cannot_cat_levels)

  # Check length for each
  if (length(shelter_type_cat_levels) != 4) rlang::abort("shelter_type_cat_levels must be of length 4")
  if (length(shelter_issue_cat_levels) != 5) rlang::abort("shelter_issue_cat_levels must be of length 5")
  if (length(occupancy_cat_levels) != 4) rlang::abort("occupancy_cat_levels must be of length 4")
  if (length(fds_cannot_cat_levels) != 5) rlang::abort("fds_cannot_cat_levels must be of length 5")

  #----- Recode

  # Compute score for shelter type
  df <- dplyr::mutate(
    df,
    comp_snfi_score_shelter_type_cat = dplyr::case_when(
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
    comp_snfi_score_shelter_issue_cat = dplyr::case_when(
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[1] ~ 4,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[2] ~ 3,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[3] ~ 2,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[4] ~ 1,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[5] ~ NA_real_,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_levels[6] ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for occupancy
  df <- dplyr::mutate(
    df,
    comp_snfi_score_occupancy_cat = dplyr::case_when(
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
    comp_snfi_score_fds_cannot_cat = dplyr::case_when(
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[1] ~ 4,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[2] ~ 3,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[3] ~ 2,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[4] ~ 1,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_levels[5] ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute total score = max
  df <- dplyr::mutate(
    df,
    comp_snfi_score = pmax(
      !!!rlang::syms(c("comp_snfi_score_shelter_type_cat", "comp_snfi_score_shelter_issue_cat", "comp_snfi_score_occupancy_cat", "comp_snfi_score_fds_cannot_cat")),
      na.rm = TRUE)
  )

  # Is in need?
  df <- is_in_need(
    df,
    "comp_snfi_score",
    "comp_snfi_in_need"
  )

  # Is in acute need?
  df <- is_in_acute_need(
    df,
    "comp_snfi_score",
    "comp_snfi_in_acute_need"
  )

  return(df)

}
