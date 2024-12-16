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
#' @param occupancy_cat Column name for occupancy.
#' @param occupancy_cat_high_risk Level for high risk occupancy.
#' @param occupancy_cat_medium_risk Level for medium risk occupancy.
#' @param occupancy_cat_low_risk Level for low risk occupancy.
#' @param occupancy_cat_undefined Level for undefined occupancy.
#' @param fds_cannot_cat Column name for fds cannot.
#' @param fds_cannot_cat_4_to_5 Level for 4 to 5 tasks that cannot be done.
#' @param fds_cannot_cat_2_to_3 Level for 2 to 3 tasks that cannot be done.
#' @param fds_cannot_cat_1 Level for 1 task that cannot be done.
#' @param fds_cannot_cat_none Level for no tasks that cannot be done.
#' @param fds_cannot_cat_undefined Level for undefined fds cannot.
#'
#' @return A data frame with added columns:
#' * comp_snfi_score_shelter_type_cat: Score based on shelter type
#' * comp_snfi_score_shelter_issue_cat: Score based on shelter issues
#' * comp_snfi_score_occupancy_cat: Score based on occupancy status
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
    occupancy_cat = "hlp_occupancy_cat",
    occupancy_cat_high_risk = "high_risk",
    occupancy_cat_medium_risk = "medium_risk",
    occupancy_cat_low_risk = "low_risk",
    occupancy_cat_undefined = "undefined",
    fds_cannot_cat = "snfi_fds_cannot_cat",
    fds_cannot_cat_4_to_5 = "4_to_5_tasks",
    fds_cannot_cat_2_to_3 = "2_to_3_tasks",
    fds_cannot_cat_1 = "1_task",
    fds_cannot_cat_none = "none",
    fds_cannot_cat_undefined = "undefined"
){

  #----- Checks

  # Check that columns are in df
  if_not_in_stop(df, c(shelter_type_cat, shelter_issue_cat, occupancy_cat, fds_cannot_cat), "df")

  # Create levels vectors
  shelter_type_cat_levels <- c(shelter_type_cat_none, shelter_type_cat_inadequate, shelter_type_cat_adequate, shelter_type_cat_undefined)
  shelter_issue_cat_levels <- c(shelter_issue_cat_7_to_8, shelter_issue_cat_4_to_6, shelter_issue_cat_1_to_3, shelter_issue_cat_none, shelter_issue_cat_undefined, shelter_issue_cat_other)
  occupancy_cat_levels <- c(occupancy_cat_high_risk, occupancy_cat_medium_risk, occupancy_cat_low_risk, occupancy_cat_undefined)
  fds_cannot_cat_levels <- c(fds_cannot_cat_4_to_5, fds_cannot_cat_2_to_3, fds_cannot_cat_1, fds_cannot_cat_none, fds_cannot_cat_undefined)

  # Checks that shelter_type_cat are in levels
  are_values_in_set(df, shelter_type_cat, shelter_type_cat_levels)

  #Checks that shelter issues are in levels
  are_values_in_set(df, shelter_issue_cat, shelter_issue_cat_levels)

  # Checks that occupancy cat are in levels
  are_values_in_set(df, occupancy_cat, occupancy_cat_levels)

  # Check that fds_cannot_cat are in levels
  are_values_in_set(df, fds_cannot_cat, fds_cannot_cat_levels)

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

  # Compute score for occupancy
  df <- dplyr::mutate(
    df,
    comp_snfi_score_occupancy_cat = dplyr::case_when(
      !!rlang::sym(occupancy_cat) == occupancy_cat_high_risk ~ 3,
      !!rlang::sym(occupancy_cat) == occupancy_cat_medium_risk ~ 2,
      !!rlang::sym(occupancy_cat) == occupancy_cat_low_risk ~ 1,
      !!rlang::sym(occupancy_cat) == occupancy_cat_undefined ~ NA_real_,
      .default = NA_real_
    )
  )

  # Compute score for fds cannot
  df <- dplyr::mutate(
    df,
    comp_snfi_score_fds_cannot_cat = dplyr::case_when(
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_4_to_5 ~ 4,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_2_to_3 ~ 3,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_1 ~ 2,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_none ~ 1,
      !!rlang::sym(fds_cannot_cat) == fds_cannot_cat_undefined ~ NA_real_,
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
