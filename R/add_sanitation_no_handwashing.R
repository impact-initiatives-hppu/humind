# ANA
# 2025 Indicator ID: New
# 2025 Metric ID: TBD

#' @title Add No Improved Sanitation and No Handwashing Facility Indicator
#'
#' @description Flags households without access to improved sanitation AND without any handwashing facility. Output is `NA` when either the sanitation or handwashing category is undefined.
#'
#' Prerequisites: `add_sanitation_facility_jmp_cat()` and `add_handwashing_facility_cat()` must have been run first.
#'
#' @param df A data frame.
#' @param sanitation_jmp_cat Column name for the JMP sanitation category (output of `add_sanitation_facility_jmp_cat()`).
#' @param sanitation_facility_jmp_open_defecation Response code for open defecation (no sanitation facility).
#' @param sanitation_facility_jmp_unimproved Response code for unimproved sanitation facility.
#' @param sanitation_facility_jmp_limited Response code for limited sanitation facility.
#' @param sanitation_facility_jmp_basic Response code for basic sanitation facility.
#' @param sanitation_facility_jmp_undefined Response code for undefined sanitation category.
#' @param handwashing_jmp_cat Column name for the JMP handwashing facility category (output of `add_handwashing_facility_cat()`).
#' @param handwashing_facility_jmp_no_facility Response code for no handwashing facility.
#' @param handwashing_facility_jmp_basic Response code for basic handwashing facility.
#' @param handwashing_facility_jmp_limited Response code for limited handwashing facility.
#' @param handwashing_facility_jmp_undefined Response code for undefined handwashing category.
#'
#' @return A data frame with one additional column:
#'
#' * `wash_sanitation_no_handwashing_d`: `1L` if open defecation or unimproved sanitation and no handwashing facility; `0L` otherwise; `NA_integer_` if either category is `NA` or undefined.
#'
#' @export
add_sanitation_no_handwashing <- function(
  df,
  sanitation_jmp_cat = "wash_sanitation_facility_jmp_cat",
  sanitation_facility_jmp_open_defecation = "open_defecation",
  sanitation_facility_jmp_unimproved = "unimproved",
  sanitation_facility_jmp_limited = "limited",
  sanitation_facility_jmp_basic = "basic",
  sanitation_facility_jmp_undefined = "undefined",
  handwashing_jmp_cat = "wash_handwashing_facility_jmp_cat",
  handwashing_facility_jmp_no_facility = "no_facility",
  handwashing_facility_jmp_basic = "basic",
  handwashing_facility_jmp_limited = "limited",
  handwashing_facility_jmp_undefined = "undefined"
) {
  #------ Checks

  if_not_in_stop(df, sanitation_jmp_cat, "df")
  if_not_in_stop(df, handwashing_jmp_cat, "df")

  #------ Compute

  df <- dplyr::mutate(
    df,
    wash_sanitation_no_handwashing_d = dplyr::case_when(
      is.na(.data[[sanitation_jmp_cat]]) ~ NA_integer_,
      is.na(.data[[handwashing_jmp_cat]]) ~ NA_integer_,
      .data[[sanitation_jmp_cat]] %in% sanitation_facility_jmp_undefined ~ NA_integer_,
      .data[[handwashing_jmp_cat]] %in% handwashing_facility_jmp_undefined ~ NA_integer_,
      .data[[sanitation_jmp_cat]] %in% c(
        sanitation_facility_jmp_open_defecation,
        sanitation_facility_jmp_unimproved
      ) &
        .data[[handwashing_jmp_cat]] == handwashing_facility_jmp_no_facility ~ 1L,
      .default = 0L
    )
  )

  return(df)
}
