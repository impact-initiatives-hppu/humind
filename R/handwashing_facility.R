#' Handwashing facility classification - 5-point scale
#'
#' `handwashing_facility()` recodes the types of handwasing facility on a 2-point scale.
#'
#' @param df A data frame
#' @param handwashing_facility Component column: Handwashing facility types.
#' @param soap_and_water Character vector of responses codes, such as "Yes, available with soap and water (seen)" , e.g., c("yes_soap_water").
#' @param none Character vector of responses codes, such as "Yes, only soap", "Yes, only water" or "No", e.g., c("no", "yes_only_soap", "yes_only_water").
#' @param na Character vector of responses codes, such as "Don't know" or "No access", e.g., c("dnk","no_access").
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
                                 handwashing_facility = "handwashing_facility",
                                 soap_and_water = c("yes_soap_water"),
                                 none = c("no", "yes_only_soap", "yes_only_water"),
                                 na = c("dnk","no_access")
) {

  #------ Check values ranges
  are_values_in_set(df, handwashing_facility, c(soap_and_water, none, na))

  df <- dplyr::mutate(
    df,
    handwashing_facility_score = dplyr::case_when(
      !!rlang::sym(handwashing_facility) %in% handwashing_facility_none_codes ~ 2,
      !!rlang::sym(handwashing_facility) %in% handwashing_facility_soap_and_water_codes ~ 1,
      .default = NA_real_)
  )

  return(df)

}

