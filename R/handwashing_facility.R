#' Handwashing facility classification - 5-point scale
#'
#' `handwashing_facility()` recodes the types of handwasing facility on a 2-point scale.
#'
#' @param df A data frame
#' @param handwashing_facility Component column: Handwashing facility types.
#' @param handwashing_facility_soap_and_water_codes Character vector of responses codes, such as "Yes, available with soap and water (seen)" , e.g., c("yes_soap_water").
#' @param handwashing_facility_none_codes Character vector of responses codes, such as "Yes, only soap", "Yes, only water" or "No", e.g., c("no", "yes_only_soap", "yes_only_water").
#' @param handwashing_facility_na_codes Character vector of responses codes, such as "Don't know" or "No access", e.g., c("dnk","no_access").
#' @param class_colname The new column name for the classification column. Default to "handwashing_facility_class".
#'
#' @return One new column: a 2-point scale from 1 to 2 (handwashing_facility_class).
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
                                 handwashing_facility = "sanitation_facility",
                                 handwashing_facility_soap_and_water_codes = c("yes_soap_water"),
                                 handwashing_facility_none_codes = c("no", "yes_only_soap", "yes_only_water"),
                                 handwashing_facility_na_codes = c("dnk","no_access"),
                                 class_colname = "handwashing_facility_class"
) {

  #------ Check values ranges
  are_values_in_set(df, handwashing_facility, c(handwashing_facility_soap_and_water_codes, handwashing_facility_none_codes, handwashing_facility_na_codes))

  df <- dplyr::mutate(
    df,
    "{class_colname}" := dplyr::case_when(
      !!rlang::sym(handwashing_facility) %in% handwashing_facility_soap_and_water_codes ~ 2,
      !!rlang::sym(handwashing_facility) %in% handwashing_facility_none_codes ~ 1,
      .default = NA_real_)
  )

  return(df)

}

