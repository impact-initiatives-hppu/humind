#' @title Combine and Recode Shelter Types
#' @description This function combines both shelter types questions and recodes the type of shelter into categories such as "none", "inadequate", "adequate", or "undefined".
#' @param df A data frame containing shelter type information.
#' @param shelter_type Component column: Shelter type categories.
#' @param sl_none Character vector of responses codes for none/sleeping in the open that are skipped.
#' @param sl_collective_center Character vector of responses codes for collective center that are skipped.
#' @param sl_undefined Character vector of undefined responses codes (e.g. "Prefer not to answer") that are skipped.
#' @param shelter_type_individual Component column: Individual shelter types.
#' @param adequate Character vector of responses codes for adequate shelter types.
#' @param inadequate Character vector of responses codes for inadequate shelter types.
#' @param undefined Character vector of responses codes for undefined shelter types.
#' @return A data frame with an additional column:
#' \item{snfi_shelter_type_cat}{Categorized shelter type: "none", "inadequate", "adequate", or "undefined"}
#'
#' @export
add_shelter_type_cat <- function(
    df,
    shelter_type = "snfi_shelter_type",
    sl_none = "none",
    sl_collective_center = "collective_center",
    sl_undefined = "pnta",
    shelter_type_individual = "snfi_shelter_type_individual",
    adequate = c("house", "apartment", "tent"),
    inadequate = c("makeshift", "unfinished_building"),
    undefined = c("pnta", "other", "dnk")
){

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, shelter_type, "df")

  # Check if values are in set
  are_values_in_set(df, shelter_type_individual, c(adequate, inadequate, undefined))

  #------ Recode

  df <- dplyr::mutate(
    df,
    snfi_shelter_type_cat = dplyr::case_when(
      !!rlang::sym(shelter_type) %in% sl_none ~ "none",
      !!rlang::sym(shelter_type) %in% sl_collective_center ~ "inadequate",
      !!rlang::sym(shelter_type) %in% sl_undefined ~ "undefined",
      !!rlang::sym(shelter_type_individual) %in% adequate ~ "adequate",
      !!rlang::sym(shelter_type_individual) %in% inadequate ~ "inadequate",
      !!rlang::sym(shelter_type_individual) %in% undefined ~ "undefined",
      .default = NA_character_
    )
  )

  return(df)

}
