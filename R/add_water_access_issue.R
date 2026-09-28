# ANA
# 2025 Indicator ID: IND098 and IND099
# 2025 Metric ID: TBD

#' @title Add Physical Water Access Issue Indicator
#'
#' @description Computes a binary variable (`wash_water_access_issue_physical_d`) that is `1L` if the household reported any physical barrier to accessing water points (too far, difficult to use, disability-related barriers, safety concerns, or excessive waiting time), `0L` if none were reported, and `NA` if the response was ambiguous (dnk/pnta/other) or any component is missing.
#'
#' @param df A data frame.
#' @param water_access_issue Base name of the select_multiple variable.
#' @param physical Character vector of responses that indicate physical access barriers.
#' @param undefined Character vector of undefined responses (dnk, pnta, other).
#' @param sep Separator between the base name and response code in binary column names.
#'
#' @return A data frame with one additional column:
#'
#' * `wash_water_access_issue_physical_d`: `1L` if any physical barrier is reported; `0L` if none; `NA` if the response is undefined or any component is missing.
#'
#' @family water_access_issue
#' @export
#'
#' @examples
#' df <- data.frame(
#'   wash_water_access_issue = c(
#'     "waterpoints_too_far", "no_problem_access_water", "dnk"
#'   ),
#'   `wash_water_access_issue/waterpoints_too_far` = c(1L, 0L, 0L),
#'   `wash_water_access_issue/waterpoints_difficult_use` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/disability_no_access_waterpoints` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/safety_concerns_waterpoints` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/safety_concerns_travel_waterpoints` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/excessive_waiting_time_waterpoints` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/dnk` = c(0L, 0L, 1L),
#'   `wash_water_access_issue/pnta` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/other` = c(0L, 0L, 0L),
#'   check.names = FALSE
#' )
#' add_water_access_issue_physical(df)
add_water_access_issue_physical <- function(
  df,
  water_access_issue = "wash_water_access_issue",
  physical = c(
    "waterpoints_too_far",
    "waterpoints_difficult_use",
    "disability_no_access_waterpoints",
    "safety_concerns_waterpoints",
    "safety_concerns_travel_waterpoints",
    "excessive_waiting_time_waterpoints"
  ),
  undefined = c("dnk", "pnta", "other"),
  sep = "/"
) {
  #------ Checks

  if_not_in_stop(df, water_access_issue, "df")

  d_physical <- paste0(water_access_issue, sep, physical)
  d_undefined <- paste0(water_access_issue, sep, undefined)
  are_values_in_set(df, c(d_physical, d_undefined), c(0, 1))

  #------ Compute

  df <- dplyr::mutate(
    df,
    wash_water_access_issue_physical_d = dplyr::case_when(
      dplyr::if_any(dplyr::all_of(d_undefined), \(x) x == 1) ~ NA_integer_,
      dplyr::if_any(dplyr::all_of(d_physical), \(x) x == 1) ~ 1L,
      dplyr::if_all(dplyr::all_of(d_physical), \(x) x == 0) ~ 0L,
      .default = NA_integer_
    )
  )

  df
}


#' @rdname add_water_access_issue_physical
#'
#' @title Add Financial Water Access Issue Indicator
#'
#' @description Computes a binary variable (`wash_water_access_issue_financial_d`) that is `1L` if the household reported any financial barrier to accessing water (water not available at market, too expensive, or insufficient storage containers), `0L` if none were reported, and `NA` if the response was ambiguous (dnk/pnta/other) or any component is missing.
#'
#' @param financial Character vector of responses that indicate financial access barriers.
#'
#' @return A data frame with one additional column:
#'
#' * `wash_water_access_issue_financial_d`: `1L` if any financial barrier is reported; `0L` if none; `NA` if the response is undefined or any component is missing.
#'
#' @family water_access_issue
#' @export
#'
#' @examples
#' df <- data.frame(
#'   wash_water_access_issue = c(
#'     "water_too_expensive", "no_problem_access_water", "dnk"
#'   ),
#'   `wash_water_access_issue/water_not_available_market` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/water_too_expensive` = c(1L, 0L, 0L),
#'   `wash_water_access_issue/not_enough_containers` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/dnk` = c(0L, 0L, 1L),
#'   `wash_water_access_issue/pnta` = c(0L, 0L, 0L),
#'   `wash_water_access_issue/other` = c(0L, 0L, 0L),
#'   check.names = FALSE
#' )
#' add_water_access_issue_financial(df)
add_water_access_issue_financial <- function(
  df,
  water_access_issue = "wash_water_access_issue",
  financial = c(
    "water_not_available_market",
    "water_too_expensive",
    "not_enough_containers"
  ),
  undefined = c("dnk", "pnta", "other"),
  sep = "/"
) {
  #------ Checks

  if_not_in_stop(df, water_access_issue, "df")

  d_financial <- paste0(water_access_issue, sep, financial)
  d_undefined <- paste0(water_access_issue, sep, undefined)
  are_values_in_set(df, c(d_financial, d_undefined), c(0, 1))

  #------ Compute

  df <- dplyr::mutate(
    df,
    wash_water_access_issue_financial_d = dplyr::case_when(
      dplyr::if_any(dplyr::all_of(d_undefined), \(x) x == 1) ~ NA_integer_,
      dplyr::if_any(dplyr::all_of(d_financial), \(x) x == 1) ~ 1L,
      dplyr::if_all(dplyr::all_of(d_financial), \(x) x == 0) ~ 0L,
      .default = NA_integer_
    )
  )

  df
}
