#' Handwashing facility classification
#'
#' [handwashing_facility()] recodes the types of handwasing facility, and [handwashing_facility_score()] classifies each household/individual on a 2-point scale.
#'
#' @param df A data frame.
#' @param handwashing_facility Component column: Handwashing facility types.
#' @param soap_and_water Character vector of responses codes, such as "Yes, available with soap and water (seen)" , e.g., c("yes_soap_water").
#' @param none Character vector of responses codes, such as "Yes, only soap", "Yes, only water" or "No", e.g., c("no", "yes_only_soap", "yes_only_water").
#' @param na Character vector of responses codes, such as "Don't know" or "No access", e.g., c("dnk","no_access").
#'
#' @return A data frame with a new column named `handwashing_facility_cat` (for [handwashing_facility()]) and `handwashing_facility_score` (for [handwashing_facility_score()]) appended.
#' 
#' @section Details on the 2-point scale:
#'
#' The classification is computed as follows:
#'
#' * Level 2: No handwashing facility available, or only water or only soap available at handwashing facility;
#' * Level 1: Handwashing facility available with soap and water;
#'
#' @export
handwashing_facility <- function(df,
                                 handwashing_facility = "handwashing_facility",
                                 soap_and_water = c("yes_soap_water"),
                                 none = c("no", "yes_only_soap", "yes_only_water"),
                                 na = c("dnk","no_access")
) {

  #------ Check values ranges
  are_values_in_set(df, handwashing_facility, c(soap_and_water, none, na))

  df <- dplyr::mutate(
    df,
    handwashing_facility_cat = dplyr::case_when(
      !!rlang::sym(handwashing_facility) %in% none ~ "none",
      !!rlang::sym(handwashing_facility) %in% soap_and_water ~ "soap_and_water",
      .default = NA_character_)
  )

  return(df)

}

#' @rdname handwashing_facility
#' 
#' @param handwashing_facility_cat Component column: Categories of handwashing facility.
#' @param handwashing_facility_levels Handwashing facility levels - in that order: none, soap and water.
#' 
#' @export 
handwashing_facility_score <- function(df,
                                       handwashing_facility_cat = "handwashing_facility_cat",
                                       handwashing_facility_levels = c("none", "soap_and_water")
) {

  #------ Check values set
  are_values_in_set(df, handwashing_facility_cat, handwashing_facility_levels)

  #------ 2-point scale
  df <- dplyr::mutate(
    df,
    handwashing_facility_score = dplyr::case_when(
      !!rlang::sym(handwashing_facility_cat) == handwashing_facility_levels[1] ~ 2,
      !!rlang::sym(handwashing_facility_cat) == handwashing_facility_levels[2] ~ 1,
      .default = NA_real_)
  )

  return(df)

}

