#' @title Add Indicator for Access to Health Facility in Less Than One Hour
#'
#' @description
#' Adds a binary variable (`1`/`0`) for whether a household reports access to
#' the nearest functional health facility in less than one hour on foot
#' (ANA IND160).
#'
#' Values are expected to be non-negative reals (minutes) or a negative
#' undefined code. Any negative value (including the default `-999`) is
#' recoded to `NA`.
#'
#' @param df A data frame.
#' @param health_facility_time Column name for travel time (in minutes) to
#'   the nearest functional health facility.
#' @param undefined The value representing an undefined response
#'   (default: `-999`).
#'
#' @return A data frame with one additional column:
#'
#' * `health_facility_distance_less_1hour`: Binary indicator — `1` if travel
#'   time is strictly less than 60 minutes, `0` if 60 minutes or more,
#'   `NA` for missing or negative values.
#'
#' @export
add_health_facility_less_1h <- function(
  df,
  health_facility_time = "health_facility_time",
  undefined = -999
) {
  #------ Checks

  if_not_in_stop(df, health_facility_time, "df") # nolint: object_usage_linter.
  are_cols_numeric(df, health_facility_time) # nolint: object_usage_linter.

  #------ Compute

  dplyr::mutate(
    df,
    health_facility_distance_less_1hour = dplyr::case_when(
      .data[[health_facility_time]] == undefined ~ NA_real_,
      .data[[health_facility_time]] < 0 ~ NA_real_,
      .data[[health_facility_time]] < 60 ~ 1,
      .data[[health_facility_time]] >= 60 ~ 0,
      .default = NA_real_
    )
  )
}
