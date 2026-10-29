#' @title Add No Improved Sanitation and No Handwashing Facility Indicator
#'
#' @description Flags households without access to improved sanitation AND without any handwashing facility. Output is `NA` when either the sanitation or handwashing category is undefined.
#'
#' Prerequisites: `add_sanitation_facility_cat()` and `add_handwashing_facility_cat()` must have been run first.
#'
#' @param df A data frame.
#' @param sanitation_facility_cat Column name for the recoded sanitation facility type (output of `add_sanitation_facility_cat()`).
#' @param sanitation_facility_cat_improved Response code for improved sanitation facility.
#' @param sanitation_facility_cat_unimproved Response code for unimproved sanitation facility.
#' @param sanitation_facility_cat_none Response code for no sanitation facility (open defecation).
#' @param sanitation_facility_cat_undefined Response code for undefined sanitation facility.
#' @param handwashing_jmp_cat Column name for the JMP handwashing facility category (output of `add_handwashing_facility_cat()`).
#' @param handwashing_facility_jmp_no_facility Response code for no handwashing facility.
#' @param handwashing_facility_jmp_limited Response code for limited handwashing facility (no water or soap).
#' @param handwashing_facility_jmp_basic Response code for basic handwashing facility (water and soap available).
#' @param handwashing_facility_jmp_undefined Response code for undefined handwashing category.
#'
#' @return A data frame with one additional column:
#'
#' * `wash_sanitation_no_handwashing_d`: `1L` if no improved sanitation (open defecation or unimproved facility) AND no handwashing facility; `0L` if the sanitation facility is improved (including a shared improved facility) or has handwashing (limited or basic); `NA_integer_` if either category is `NA` or undefined.
#'
#' @section ANA indicator:
#' Metric ID `MET150`.
#'
#' @examples
#' df <- data.frame(
#'   wash_sanitation_facility_cat = c(
#'     "improved", "improved", "unimproved", "none", "undefined"
#'   ),
#'   wash_handwashing_facility_jmp_cat = c(
#'     "no_facility", "basic", "no_facility", "no_facility", "no_facility"
#'   )
#' )
#' add_sanitation_no_handwashing(df)
#'
#' @export
add_sanitation_no_handwashing <- function(
  df,
  sanitation_facility_cat = "wash_sanitation_facility_cat",
  sanitation_facility_cat_improved = "improved",
  sanitation_facility_cat_unimproved = "unimproved",
  sanitation_facility_cat_none = "none",
  sanitation_facility_cat_undefined = "undefined",
  handwashing_jmp_cat = "wash_handwashing_facility_jmp_cat",
  handwashing_facility_jmp_no_facility = "no_facility",
  handwashing_facility_jmp_limited = "limited",
  handwashing_facility_jmp_basic = "basic",
  handwashing_facility_jmp_undefined = "undefined"
) {
  #------ Checks

  if_not_in_stop(df, sanitation_facility_cat, "df")
  if_not_in_stop(df, handwashing_jmp_cat, "df")

  sanitation_facility_cat_values <- c(
    sanitation_facility_cat_improved,
    sanitation_facility_cat_unimproved,
    sanitation_facility_cat_none,
    sanitation_facility_cat_undefined
  )
  handwashing_jmp_cat_values <- c(
    handwashing_facility_jmp_no_facility,
    handwashing_facility_jmp_limited,
    handwashing_facility_jmp_basic,
    handwashing_facility_jmp_undefined
  )

  are_values_in_set(df, sanitation_facility_cat, sanitation_facility_cat_values)
  are_values_in_set(df, handwashing_jmp_cat, handwashing_jmp_cat_values)

  #------ Compute

  df <- dplyr::mutate(
    df,
    wash_sanitation_no_handwashing_d = dplyr::case_when(
      is.na(.data[[sanitation_facility_cat]]) ~ NA_integer_,
      is.na(.data[[handwashing_jmp_cat]]) ~ NA_integer_,
      .data[[sanitation_facility_cat]] ==
        sanitation_facility_cat_undefined ~ NA_integer_,
      .data[[handwashing_jmp_cat]] ==
        handwashing_facility_jmp_undefined ~ NA_integer_,
      # 1L: no improved sanitation (unimproved facility or open defecation) AND no handwashing
      .data[[sanitation_facility_cat]] %in%
        c(sanitation_facility_cat_unimproved, sanitation_facility_cat_none) &
        .data[[handwashing_jmp_cat]] ==
          handwashing_facility_jmp_no_facility ~ 1L,
      # 0L: improved sanitation facility — condition not met regardless of handwashing
      .data[[sanitation_facility_cat]] == sanitation_facility_cat_improved ~ 0L,
      # 0L: no improved sanitation but a handwashing facility is available
      .data[[sanitation_facility_cat]] %in%
        c(sanitation_facility_cat_unimproved, sanitation_facility_cat_none) &
        .data[[handwashing_jmp_cat]] %in%
          c(
            handwashing_facility_jmp_limited,
            handwashing_facility_jmp_basic
          ) ~ 0L,
      .default = NA_integer_
    )
  )

  df
}
