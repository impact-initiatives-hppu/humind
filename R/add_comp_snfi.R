#' @title Add SNFI Sectoral Composite Score and Need Indicators
#'
#' @description
#' This function calculates the Shelter, NFI and HLP (SNFI) sectoral composite score
#' based on shelter type, shelter issues, occupancy status, and functional disability
#' scale (FDS) indicators. It also determines if a household is in need or in acute need
#' based on the calculated score.
#'
#' Prerequisite functions:
#' * add_shelter_issue_cat.R
#' * add_shelter_type_cat.R
#' * add_occupancy_cat.R
#' * add_fds_cannot_cat.R
#' * OPTIONAL add_shelter_damage_cat.R
#'
#'
#' @param df A data frame containing the required SNFI indicators.
#' @param shelter_type_cat Column name for shelter type.
#' @param shelter_type_cat_none Level for no shelter.
#' @param shelter_type_cat_inadequate Level for inadequate shelter.
#' @param shelter_type_cat_adequate Level for adequate shelter.
#' @param shelter_type_cat_undefined Level for undefined shelter.
#' @param shelter_issue_cat Column name for shelter issue.
#' @param shelter_issue_cat_7_to_8 Level for 7 to 8 shelter issues.
#' @param shelter_issue_cat_4_to_6 Level for 4 to 6 shelter issues.
#' @param shelter_issue_cat_1_to_3 Level for 1 to 3 shelter issues.
#' @param shelter_issue_cat_none Level for no shelter issues.
#' @param shelter_issue_cat_undefined Level for undefined shelter issues.
#' @param shelter_issue_cat_other Level for other shelter issues.
#' @param tenure_security Column name for security of tenure.
#' @param tenure_security_high_risk Level for high risk with security of tenure.
#' @param tenure_security_medium_risk Level for medium risk with security of tenure.
#' @param tenure_security_low_risk Level for low risk with security of tenure.
#' @param tenure_security_undefined Level for undefined with security of tenure.
#' @param fds_cannot_cat Column name for fds cannot.
#' @param fds_cannot_cat_4 Level for 4 tasks that cannot be done.
#' @param fds_cannot_cat_2_to_3 Level for 2 to 3 tasks that cannot be done.
#' @param fds_cannot_cat_1 Level for 1 task that cannot be done.
#' @param fds_cannot_cat_none Level for no tasks that cannot be done.
#' @param fds_cannot_cat_undefined Level for undefined fds cannot.
#' @param shelter_damage_cat Column for shelter damage.
#' @param shelter_damage_cat_none Level name for no shelter damage.
#' @param shelter_damage_cat_damaged Level name for minor damages.
#' @param shelter_damage_cat_part Level name for roof with risk of collapse.
#' @param shelter_damage_cat_total Level name for total collapse or destruction.
#' @param shelter_damage_cat_undefined Level name for undefined or unknown status for shelter damage.
#'
#' @return A data frame with added columns:
#' * comp_snfi_score_shelter_type_cat: Score based on shelter type
#' * comp_snfi_score_shelter_issue_cat: Score based on shelter issues
#' * comp_snfi_score_tenure_security_cat: Score based on security of tenure status
#' * comp_snfi_score_fds_cannot_cat: Score based on FDS
#' * comp_snfi_score: Overall SNFI composite score
#' * comp_snfi_in_need: Indicator for being in need
#' * comp_snfi_in_acute_need: Indicator for being in acute need
#'
#' @export
add_comp_snfi <- function(
    df,
    shelter_type_cat = "snfi_shelter_type_cat",
    shelter_type_cat_none = "none",
    shelter_type_cat_inadequate = "inadequate",
    shelter_type_cat_adequate = "adequate",
    shelter_type_cat_undefined = "undefined",
    shelter_issue_cat = "snfi_shelter_issue_cat",
    shelter_issue_cat_7_to_8 = "7_to_8",
    shelter_issue_cat_4_to_6 = "4_to_6",
    shelter_issue_cat_1_to_3 = "1_to_3",
    shelter_issue_cat_none = "none",
    shelter_issue_cat_undefined = "undefined",
    shelter_issue_cat_other = "other",
    tenure_security_cat = "hlp_occupancy_cat",
    tenure_security_cat_high_risk = "high_risk",
    tenure_security_cat_medium_risk = "medium_risk",
    tenure_security_cat_low_risk = "low_risk",
    tenure_security_cat_undefined = "undefined",
    fds_cannot_cat = "snfi_fds_cannot_cat",
    fds_cannot_cat_4 = "4_tasks",
    fds_cannot_cat_2_to_3 = "2_to_3_tasks",
    fds_cannot_cat_1 = "1_task",
    fds_cannot_cat_none = "none",
    fds_cannot_cat_undefined = "undefined",
    shelter_damage = FALSE,
    shelter_damage_cat = "snfi_shelter_damage_cat",
    shelter_damage_cat_none = "none",
    shelter_damage_cat_damaged = "damaged",
    shelter_damage_cat_part = "part",
    shelter_damage_cat_total = "total",
    shelter_damage_cat_undefined = "undefined"

){

  #----- Checks

  # Check that columns are in df
  if_not_in_stop(df, c(shelter_type_cat, shelter_issue_cat, tenure_security_cat, fds_cannot_cat), "df")

  # Only check for shelter damage if shelter_damage = TRUE
  if (shelter_damage) {
    if_not_in_stop(df, shelter_damage_cat, "df")
  }

  # Create levels vectors
  shelter_type_cat_levels <- c(shelter_type_cat_none, shelter_type_cat_inadequate, shelter_type_cat_adequate, shelter_type_cat_undefined)
  shelter_issue_cat_levels <- c(shelter_issue_cat_7_to_8, shelter_issue_cat_4_to_6, shelter_issue_cat_1_to_3, shelter_issue_cat_none, shelter_issue_cat_undefined, shelter_issue_cat_other)
  tenure_security_cat_levels <- c(tenure_security_cat_high_risk, tenure_security_cat_medium_risk, tenure_security_cat_low_risk, tenure_security_cat_undefined)
  fds_cannot_cat_levels <- c(fds_cannot_cat_4, fds_cannot_cat_2_to_3, fds_cannot_cat_1, fds_cannot_cat_none, fds_cannot_cat_undefined)

  # Only check shelter damage levels if shelter_damage = TRUE
  if (shelter_damage) {
    shelter_damage_cat_levels <- c(shelter_damage_cat_none, shelter_damage_cat_damaged, shelter_damage_cat_part, shelter_damage_cat_total, shelter_damage_cat_undefined)
    }

  # Checks that shelter_type_cat are in levels
  are_values_in_set(df, shelter_type_cat, shelter_type_cat_levels)

  #Checks that shelter issues are in levels
  are_values_in_set(df, shelter_issue_cat, shelter_issue_cat_levels)

  # Checks that tenure security cat are in levels
  are_values_in_set(df, tenure_security_cat, tenure_security_cat_levels)

  # Check that fds_cannot_cat are in levels
  are_values_in_set(df, fds_cannot_cat, fds_cannot_cat_levels)

  # Check that shelter_damage_cat are in levels
  if (shelter_damage) {
  are_values_in_set(df, shelter_damage_cat, shelter_damage_cat_levels)
  }

  #----- Recode

  # Compute score for shelter type
  df <- dplyr::mutate(
    df,
    comp_snfi_score_shelter_type_cat = dplyr::case_when(
      !!rlang::sym(shelter_type_cat) == shelter_type_cat_none ~ 5,
      !!rlang::sym(shelter_type_cat) == shelter_type_cat_inadequate ~ 3,
      !!rlang::sym(shelter_type_cat) == shelter_type_cat_adequate ~ 1,
      !!rlang::sym(shelter_type_cat) == shelter_type_cat_undefined ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for shelter issue
  df <- dplyr::mutate(
    df,
    comp_snfi_score_shelter_issue_cat = dplyr::case_when(
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_7_to_8 ~ 4,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_4_to_6 ~ 3,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_1_to_3 ~ 2,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_none ~ 1,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_undefined ~ NA_real_,
      !!rlang::sym(shelter_issue_cat) == shelter_issue_cat_other ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for tenure security
  df <- dplyr::mutate(
    df,
    comp_snfi_score_tenure_security_cat = dplyr::case_when(
      !!rlang::sym(tenure_security_cat) == tenure_security_cat_high_risk ~ 3,
      !!rlang::sym(tenure_security_cat) == tenure_security_cat_medium_risk ~ 2,
      !!rlang::sym(tenure_security_cat) == tenure_security_cat_low_risk ~ 1,
      !!rlang::sym(tenure_security_cat) == tenure_security_cat_undefined ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for fds cannot
  df <- dplyr::mutate(
    df,
    comp_snfi_score_fds_cannot_cat = dplyr::case_when(
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_4 ~ 4,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_2_to_3 ~ 3,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_1 ~ 2,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_none ~ 1,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_undefined ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for shelter damage
  if (shelter_damage) {
  df <- dplyr::mutate(
    df,
    comp_snfi_score_shelter_damage_cat = dplyr::case_when(
      !!rlang::sym(shelter_damage_cat) == shelter_damage_cat_total ~ 4,
      !!rlang::sym(shelter_damage_cat) == shelter_damage_cat_part ~ 3,
      !!rlang::sym(shelter_damage_cat) == shelter_damage_cat_damaged ~ 2,
      !!rlang::sym(shelter_damage_cat) == shelter_damage_cat_none ~ 1,
      !!rlang::sym(shelter_damage_cat) == shelter_damage_cat_undefined ~ NA_real_,
      .default = NA_real_
    )
  )
  }


  # Compute total score = max, only include shelter damage score if shelter_damage = TRUE
  comp_vars <- c(
    "comp_snfi_score_shelter_type_cat",
    "comp_snfi_score_shelter_issue_cat",
    "comp_snfi_score_fds_cannot_cat",
    "comp_snfi_score_tenure_security_cat"
  )
  if (shelter_damage) {
    comp_vars <- append(comp_vars, "comp_snfi_score_shelter_damage_cat", after = 4)
  }

  df <- dplyr::mutate(
    df,
    comp_snfi_score = pmax(
      !!!rlang::syms(comp_vars),
      na.rm = TRUE
    )
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
