# ANA
# 2025 Indicator ID: IND160
# 2026 Metric ID: TBD

#' @title Add Indicator for Access to Health Facility in Less Than One Hour
#'
#' @description Adds a binary variable (`1L`/`0L`) for whether a household reports access to the nearest functional health facility in less than one hour on foot.
#'
#' Values must be non-negative integers. Any negative value (including undefined codes such as -999) will raise an error listing the unique offending values — recode or remove them before calling this function.
#'
#' @param df A data frame.
#' @param health_facility_time Column name for travel time (in minutes) to the nearest functional health facility.
#'
#' @return A data frame with one additional column:
#'
#' * `health_facility_less_1h`: `1L` if travel time is strictly less than 60 minutes, `0L` if 60 minutes or more, `NA_integer_` for missing values.
#'
#' @export
add_health_facility_less_1h <- function(
  df,
  health_facility_time = "health_facility_time"
) {
  #------ Checks

  # health_facility_time column exists and is integer
  are_cols_integer(df, health_facility_time)

  # negative values are not allowed — caller must clean first
  # Note: future refactor could use checkmate::assert_integerish(df[[health_facility_time]], lower = 0L)
  neg <- sort(unique(df[[health_facility_time]][
    !is.na(df[[health_facility_time]]) & df[[health_facility_time]] < 0
  ]))
  if (length(neg) > 0) {
    cli::cli_abort(c(
      "{.val {health_facility_time}} contains negative values.",
      "i" = "Unique negative values found: {neg}.",
      "i" = "Recode or remove them before calling this function (e.g. recode -999 'don't know' to NA)."
    ))
  }

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
