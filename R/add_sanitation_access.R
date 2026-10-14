# ANA
# 2025 INDICATOR ID: IND143 and 144
# 2026 METRIC ID: TBD

#' @title Add Physical/Safety Sanitation Access Issue
#'
#' @description Computes a binary variable (`wash_sanitation_access_issue_physical_safety_d`) that is 1 if the household reported any physical or safety-related challenge in accessing sanitation facilities (not private, too far, difficult to reach, dangerous, disability-related, not segregated by gender, or some groups excluded), 0 if none were reported, and NA if the response was ambiguous (dnk/pnta/other) or the household has no sanitation facility (`wash_sanitation_facility = 'none'`).
#'
#' @param df A data frame.
#' @param sanitation_access_issue Base name of the select_multiple variable.
#' @param physical_safety Character vector of responses that indicate physical or safety-related access challenges.
#' @param undefined Character vector of undefined responses (dnk, pnta, other).
#' @param sanitation_facility Column name for the sanitation facility type.
#' @param none Response code for no sanitation facility (open defecation).
#' @param sep Separator for the binary columns.
#'
#' @return A data frame with one additional column:
#'
#' * wash_sanitation_access_issue_physical_safety_d which takes 1L if any physical/safety challenge is reported; 0L if no physical/safety challenge is reported; NA if undefined response or no facility.
#'
#' @family sanitation_access_issue
#' @export
#'
#' @examples
#' df <- data.frame(
#'   wash_sanitation_facility = "pit_latrine_slab",
#'   wash_sanitation_access_issue = c(
#'     "sanitation_too_far", "no_problem", "dnk"
#'   ),
#'   `wash_sanitation_access_issue/sanitation_not_private` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/sanitation_too_far` = c(1L, 0L, 0L),
#'   `wash_sanitation_access_issue/sanitation_difficult_access` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/sanitation_dangerous_access` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/disabilities_no_access_sanitation` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/sanitation_not_segregated_gender` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/groups_no_access_sanitation` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/dnk` = c(0L, 0L, 1L),
#'   `wash_sanitation_access_issue/pnta` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/other` = c(0L, 0L, 0L),
#'   check.names = FALSE
#' )
#' add_sanitation_access_issue_physical_safety(df)
add_sanitation_access_issue_physical_safety <- function(
  df,
  sanitation_access_issue = "wash_sanitation_access_issue",
  physical_safety = c(
    "sanitation_not_private",
    "sanitation_too_far",
    "sanitation_difficult_access",
    "sanitation_dangerous_access",
    "disabilities_no_access_sanitation",
    "sanitation_not_segregated_gender",
    "groups_no_access_sanitation"
  ),
  undefined = c("dnk", "pnta", "other"),
  sanitation_facility = "wash_sanitation_facility",
  none = "none",
  sep = "/"
) {
  #------ Checks

  # relevant base columns are in the dataset
  if_not_in_stop(df, sanitation_access_issue, "df")
  if_not_in_stop(df, sanitation_facility, "df")

  # columns are in the dataset and are binary
  d_physical_safety <- paste0(
    sanitation_access_issue,
    sep,
    physical_safety
  )
  d_undefined <- paste0(sanitation_access_issue, sep, undefined)
  are_values_in_set(df, c(d_physical_safety, d_undefined), c(0, 1))

  #------ Compute

  df <- dplyr::mutate(
    df,
    wash_sanitation_access_issue_physical_safety_d = dplyr::case_when(
      .data[[sanitation_facility]] %in% none ~ NA_integer_,
      dplyr::if_any(dplyr::all_of(d_undefined), \(x) {
        x == 1
      }) ~ NA_integer_,
      dplyr::if_any(dplyr::all_of(d_physical_safety), \(x) x == 1) ~ 1L,
      dplyr::if_all(dplyr::all_of(d_physical_safety), \(x) x == 0) ~ 0L,
      .default = NA_integer_
    )
  )

  df
}


#' @rdname add_sanitation_access_issue_physical_safety
#'
#' @title Add Hygiene/Functionality Sanitation Access Issue Indicator
#'
#' @description Computes a binary variable (`wash_sanitation_access_issue_hygiene_functionality_d`) that is 1 if the household reported any hygiene or functionality challenge in accessing sanitation facilities (too crowded, not functioning/full, unclean/unhygienic), 0 if none were reported, and NA if the response was ambiguous (dnk/pnta/other) or the household has no sanitation facility (`wash_sanitation_facility = 'none'`).
#'
#' @param hygiene_functionality Character vector of responses that indicate hygiene or functionality access challenges.
#'
#' @return A data frame with one additional column:
#'
#' * wash_sanitation_access_issue_hygiene_functionality_d which takes 1L if any hygiene/functionality challenge is reported; 0L if no hygiene/functionality challenge is reported; NA if undefined response or no facility.
#'
#' @family sanitation_access_issue
#' @export
#'
#' @examples
#' df <- data.frame(
#'   wash_sanitation_facility = "pit_latrine_slab",
#'   wash_sanitation_access_issue = c(
#'     "sanitation_unclean_unhygienic", "no_problem", "dnk"
#'   ),
#'   `wash_sanitation_access_issue/lack_sanitation_facilities_crowded` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/sanitation_not_functioning_full` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/sanitation_unclean_unhygienic` = c(1L, 0L, 0L),
#'   `wash_sanitation_access_issue/dnk` = c(0L, 0L, 1L),
#'   `wash_sanitation_access_issue/pnta` = c(0L, 0L, 0L),
#'   `wash_sanitation_access_issue/other` = c(0L, 0L, 0L),
#'   check.names = FALSE
#' )
#' add_sanitation_access_issue_hygiene_functionality(df)
add_sanitation_access_issue_hygiene_functionality <- function(
  df,
  sanitation_access_issue = "wash_sanitation_access_issue",
  hygiene_functionality = c(
    "lack_sanitation_facilities_crowded",
    "sanitation_not_functioning_full",
    "sanitation_unclean_unhygienic"
  ),
  undefined = c("dnk", "pnta", "other"),
  sanitation_facility = "wash_sanitation_facility",
  none = "none",
  sep = "/"
) {
  #------ Checks

  # relevant base columns are in the dataset
  if_not_in_stop(df, sanitation_access_issue, "df")
  if_not_in_stop(df, sanitation_facility, "df")

  # columns are in the dataset and are binary
  d_hygiene_functionality <- paste0(
    sanitation_access_issue,
    sep,
    hygiene_functionality
  )
  d_undefined <- paste0(sanitation_access_issue, sep, undefined)
  are_values_in_set(df, c(d_hygiene_functionality, d_undefined), c(0, 1))

  #------ Compute

  df <- dplyr::mutate(
    df,
    wash_sanitation_access_issue_hygiene_functionality_d = dplyr::case_when(
      .data[[sanitation_facility]] %in% none ~ NA_integer_,
      dplyr::if_any(dplyr::all_of(d_undefined), \(x) {
        x == 1
      }) ~ NA_integer_,
      dplyr::if_any(dplyr::all_of(d_hygiene_functionality), \(x) x == 1) ~ 1L,
      dplyr::if_all(dplyr::all_of(d_hygiene_functionality), \(x) x == 0) ~ 0L,
      .default = NA_integer_
    )
  )

  df
}
