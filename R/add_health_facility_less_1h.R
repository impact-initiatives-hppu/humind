# ANA
# 2025 Indicator ID: IND160
# 2026 Metric ID: TBD

#' @title Add Indicator for Access to Health Facility in Less Than One Hour
#'
#' @description Adds a binary variable (`1L`/`0L`) for whether a household reports access to the nearest functional health facility in less than one hour on foot.
#'
#' Values must be strictly positive integers. The `health_facility_time` column is validated with `checkmate::assert_integerish()`: `0`, negative codes (including `-999`), fractional values, and non-finite values all raise an error — recode or remove them before calling this function.
#'
#' @param df A data frame.
#' @param health_facility_time Column name for travel time (in minutes) to the nearest functional health facility.
#'
#' @return A data frame with one additional column:
#'
#' * `health_facility_less_1h`: `1L` if travel time is strictly less than 60 minutes, `0L` if 60 minutes or more, `NA_integer_` for missing values.
#'
#' @export
#'
#' @examples
#' input_data <- data.frame(
#'   health_facility_time = c(15L, 45L, 60L, 90L, NA_integer_)
#' )
#' add_health_facility_less_1h(input_data)
#'
add_health_facility_less_1h <- function(
  df,
  health_facility_time = "health_facility_time"
) {
  #------ Checks

  # health_facility_time column exists
  if_not_in_stop(df, health_facility_time, "df")

  # health_facility_time must be a strictly positive integer vector
  checkmate::assert_integerish(
    df[[health_facility_time]],
    lower = 1,
    any.missing = TRUE,
    .var.name = health_facility_time
  )

  #------ Compute

  dplyr::mutate(
    df,
    health_facility_less_1h = dplyr::case_when(
      is.na(.data[[health_facility_time]]) ~ NA_integer_,
      .data[[health_facility_time]] < 60L ~ 1L,
      .default = 0L
    )
  )
}
