#' @title Add Category of Occupancy Arrangement and Tenure Security
#'
#' @importFrom rlang .data
#'
#' @description This function categorizes occupancy arrangements and eviction
#' risk into high, medium, or low risk, and then creates a new column for
#' overall tenure security, taking the maximum risk from both.
#'
#' @param df A data frame containing occupancy arrangement data.
#' @param occupancy Component column: Occupancy arrangement.
#' @param occupancy_high_risk Character vector of high risk occupancy arrangements.
#' @param occupancy_medium_risk Character vector of medium risk occupancy arrangements.
#' @param occupancy_low_risk Character vector of low risk occupancy arrangements.
#' @param occupancy_undefined Character vector of undefined response codes (e.g. "Prefer not to answer").
#' @param eviction Component column: Eviction risk.
#' @param eviction_high_risk Character vector of high risk eviction responses.
#' @param eviction_low_risk Character vector of low risk eviction responses.
#' @param eviction_undefined Character vector of undefined eviction responses.
#'
#' @return A data frame with additional columns:
#'
#' * hlp_occupancy_cat: Categorized occupancy arrangement: "high_risk", "medium_risk", "low_risk", or "undefined".
#' * hlp_eviction_cat: Categorized eviction risk: "high_risk", "low_risk", or "undefined".
#' * hlp_tenure_security: Maximum risk between hlp_occupancy_cat and hlp_eviction_cat.
#'
#' @export
add_occupancy_cat <- function(
  df,
  occupancy = "hlp_occupancy",
  occupancy_high_risk = c("no_agreement"),
  occupancy_medium_risk = c("rented", "hosted_free"),
  occupancy_low_risk = c("ownership"),
  occupancy_undefined = c("dnk", "pnta", "other"),
  eviction = "hlp_risk_eviction",
  eviction_high_risk = "yes",
  eviction_low_risk = "no",
  eviction_undefined = c("dnk", "pnta")
) {
  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, occupancy, "df")
  if_not_in_stop(df, eviction, "df")

  # Check if values are in set
  are_values_in_set(
    df,
    occupancy,
    c(
      occupancy_high_risk,
      occupancy_medium_risk,
      occupancy_low_risk,
      occupancy_undefined
    )
  )
  are_values_in_set(
    df,
    eviction,
    c(eviction_high_risk, eviction_low_risk, eviction_undefined)
  )

  #------ Recode

  df <- dplyr::mutate(
    df,
    hlp_occupancy_cat = dplyr::case_when(
      !!rlang::sym(occupancy) %in% occupancy_high_risk ~ "high_risk",
      !!rlang::sym(occupancy) %in% occupancy_medium_risk ~ "medium_risk",
      !!rlang::sym(occupancy) %in% occupancy_low_risk ~ "low_risk",
      !!rlang::sym(occupancy) %in% occupancy_undefined ~ "undefined",
      .default = NA_character_
    )
  )

  df <- dplyr::mutate(
    df,
    hlp_eviction_cat = dplyr::case_when(
      !!rlang::sym(eviction) %in% eviction_high_risk ~ "high_risk",
      !!rlang::sym(eviction) %in% eviction_low_risk ~ "low_risk",
      !!rlang::sym(eviction) %in% eviction_undefined ~ "undefined",
      .default = NA_character_
    )
  )

  # List risk order
  risk_order <- c("high_risk", "medium_risk", "low_risk", "undefined")

  # Combine the two columns and take the maximum risk
  df <- dplyr::mutate(
    df,
    # Convert to factor with the correct order
    hlp_occupancy_cat_f = factor(
      .data[["hlp_occupancy_cat"]],
      levels = risk_order
    ),
    hlp_eviction_cat_f = factor(
      .data[["hlp_eviction_cat"]],
      levels = risk_order
    ),
    # Get the maximum risk (min level since factor is ordered high_risk < ... < undefined)
    hlp_tenure_security = dplyr::case_when(
      is.na(hlp_occupancy_cat_f) & is.na(hlp_eviction_cat_f) ~ NA_character_,
      is.na(hlp_occupancy_cat_f) ~ as.character(hlp_eviction_cat_f),
      is.na(hlp_eviction_cat_f) ~ as.character(hlp_occupancy_cat_f),
      as.integer(hlp_occupancy_cat_f) <= as.integer(hlp_eviction_cat_f) ~
        as.character(hlp_occupancy_cat_f),
      TRUE ~ as.character(hlp_eviction_cat_f)
    ),
    # Remove temporary columns
    hlp_occupancy_cat_f = NULL,
    hlp_eviction_cat_f = NULL
  )

  return(df)
}
