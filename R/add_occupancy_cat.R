#' @title Add Category of Occupancy Arrangement
#'
#' @description This function categorizes occupancy arrangements into high, medium, or low risk based on provided criteria.
#'
#' @param df A data frame containing occupancy arrangement data.
#' @param occupancy Component column: Occupancy arrangement.
#' @param high_risk Character vector of high risk occupancy arrangements.
#' @param medium_risk Character vector of medium risk occupancy arrangements.
#' @param low_risk Character vector of low risk occupancy arrangements.
#' @param undefined Character vector of undefined response codes (e.g. "Prefer not to answer").
#'
#' @return A data frame with an additional column:
#' 
#' * hlp_occupancy_cat: Categorized occupancy arrangement: "high_risk", "medium_risk", "low_risk", or "undefined".
#'
#' @export
#'
add_occupancy_cat <- function(
    df,
    occupancy = "hlp_occupancy",
    high_risk = c("no_agreement"),
    medium_risk = c("rented", "hosted_free"),
    low_risk = c("ownership"),
    undefined = c("dnk", "pnta", "other")
    ) {

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, occupancy, "df")

  # Check if values are in set
  are_values_in_set(df, occupancy, c(high_risk, medium_risk, low_risk, undefined))

  #------ Recode

  df <- dplyr::mutate(
    df,
    hlp_occupancy_cat = dplyr::case_when(
      !!rlang::sym(occupancy) %in% high_risk ~ "high_risk",
      !!rlang::sym(occupancy) %in% medium_risk ~ "medium_risk",
      !!rlang::sym(occupancy) %in% low_risk ~ "low_risk",
      !!rlang::sym(occupancy) %in% undefined ~ "undefined",
      .default = NA_character_
    )
  )

  return(df)

}
