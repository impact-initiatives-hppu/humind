# ANA
# 2025 Indicator ID: IND098 and IND099
# 2025 Metric ID: TBD

#' @title Add Physical Water Access Issue Indicator
#'
#' @description
#' Computes a binary variable (`wash_water_access_issue_physical_d`) that is
#' `1` if the household reported any physical barrier to accessing water points
#' (too far, difficult to use, disability-related barriers, or excessive waiting
#' time), `0` if none were reported, and `NA` if the response was ambiguous
#' (dnk/pnta/other) or the household has no water source (`wash_drinking_water_source = 'none'`).
#'
#' @param df A data frame.
#' @param water_access_issue Base name of the select_multiple variable.
#' @param physical Character vector of responses that indicate physical access
#'   barriers.
#' @param undefined Character vector of undefined responses (dnk, pnta, other).
#' @param water_source Column name for the water source type.
#' @param none Response code for no water source.
#' @param sep Separator between the base name and response code in binary
#'   column names.
#'
#' @return A data frame with one additional column:
#'
#' * `wash_water_access_issue_physical_d`: `1` if any physical barrier is
#'   reported; `0` if none; `NA` if undefined response or no water source.
#'
#' @family water_access_issue
#' @export
add_water_access_issue_physical <- function(
  df,
  water_access_issue = "wash_water_access_issue",
  physical = c(
    "waterpoints_too_far",
    "waterpoints_difficult_use",
    "disability_no_access_waterpoints",
    "excessive_waiting_time_waterpoints"
  ),
  undefined = c("dnk", "pnta", "other"),
  water_source = "wash_drinking_water_source",
  none = "none",
  sep = "/"
) {
  #------ Checks

  if_not_in_stop(df, water_access_issue, "df")
  if_not_in_stop(df, water_source, "df")

  d_physical <- paste0(water_access_issue, sep, physical)
  d_undefined <- paste0(water_access_issue, sep, undefined)
  are_values_in_set(df, c(d_physical, d_undefined), c(0, 1))

  #------ Compute

  df <- dplyr::mutate(
    df,
    wash_water_access_issue_physical_d = dplyr::case_when(
      .data[[water_source]] %in% none ~ NA_real_,
      dplyr::if_any(dplyr::all_of(d_undefined), \(x) x == 1) ~ NA_real_,
      dplyr::if_any(dplyr::all_of(d_physical), \(x) x == 1) ~ 1,
      .default = 0
    )
  )

  return(df)
}


#' @rdname add_water_access_issue_physical
#'
#' @title Add Financial Water Access Issue Indicator
#'
#' @description
#' Computes a binary variable (`wash_water_access_issue_financial_d`) that is
#' `1` if the household reported any financial barrier to accessing water
#' (water not available at market, too expensive, or insufficient storage
#' containers), `0` if none were reported, and `NA` if the response was
#' ambiguous (dnk/pnta/other) or the household has no water source
#' (`wash_drinking_water_source = 'none'`).
#'
#' @param financial Character vector of responses that indicate financial access
#'   barriers.
#'
#' @return A data frame with one additional column:
#'
#' * `wash_water_access_issue_financial_d`: `1` if any financial barrier is
#'   reported; `0` if none; `NA` if undefined response or no water source.
#'
#' @family water_access_issue
#' @export
add_water_access_issue_financial <- function(
  df,
  water_access_issue = "wash_water_access_issue",
  financial = c(
    "water_not_available_market",
    "water_too_expensive",
    "not_enough_containers"
  ),
  undefined = c("dnk", "pnta", "other"),
  water_source = "wash_drinking_water_source",
  none = "none",
  sep = "/"
) {
  #------ Checks

  if_not_in_stop(df, water_access_issue, "df")
  if_not_in_stop(df, water_source, "df")

  d_financial <- paste0(water_access_issue, sep, financial)
  d_undefined <- paste0(water_access_issue, sep, undefined)
  are_values_in_set(df, c(d_financial, d_undefined), c(0, 1))

  #------ Compute

  df <- dplyr::mutate(
    df,
    wash_water_access_issue_financial_d = dplyr::case_when(
      .data[[water_source]] %in% none ~ NA_real_,
      dplyr::if_any(dplyr::all_of(d_undefined), \(x) x == 1) ~ NA_real_,
      dplyr::if_any(dplyr::all_of(d_financial), \(x) x == 1) ~ 1,
      .default = 0
    )
  )

  return(df)
}
