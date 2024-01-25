#' Drinking water quantity classification - 5-point scale
#'
#' [drinking_water_quantity()] recodes the quantity of drinking availability, and [drinking_water_quantity_score()] classifies each household on a 5-point scale.
#'
#' @param df A data frame.
#' @param drinking_water_quantity Component column: Drinking water quantity.
#' @param level_codes Character vector of responses codes, including first in the following order: "Always (more than 20 times)", "Often (11-20 times)", "Sometimes (3–10 times)", "Rarely (1–2 times)", "Never (0 times)", e.g. c("always", "often", "sometimes", "rarely", "never").
#'
#' @return One new column: a 5-point scale from 1 to 5 (drinking_water_quantity_class).
#'
#' @export
drinking_water_quantity <- function(df,
                                    drinking_water_quantity = "drinking_water_quantity",
                                    level_codes =   c("always", "often", "sometimes", "rarely", "never", "dont_know")) {


  #------ Check values set
  are_values_in_set(df, drinking_water_quantity, level_codes)


  #------ Recode drinking water quantity frequencies
  df <- dplyr::mutate(
    df,
    drinking_water_quantity_cat = dplyr::case_when(
      !!rlang::sym(drinking_water_quantity) == level_codes[1] ~ "always",
      !!rlang::sym(drinking_water_quantity) == level_codes[2] ~ "often",
      !!rlang::sym(drinking_water_quantity) == level_codes[3] ~ "sometimes",
      !!rlang::sym(drinking_water_quantity) == level_codes[4] ~ "rarely",
      !!rlang::sym(drinking_water_quantity) == level_codes[5] ~ "never",
      .default = NA_character_)
  )

  return(df)

}

#' @rdname drinking_water_quantity
#'
#' @param drinking_water_quantity_cat Component column: drinking water quantity categories.
#'
#' @export
drinking_water_quantity_score <- function(df,
                                          drinking_water_quantity_cat = "drinking_water_quantity_cat",
                                          level_codes = c("always", "often", "sometimes", "rarely", "never")) {

  #------ Check values set
  are_values_in_set(df, drinking_water_quantity_cat, level_codes)

  #------ 5-point scale
  df <- dplyr::mutate(
    df,
    drinking_water_quantity_score = dplyr::case_when(
      !!rlang::sym(drinking_water_quantity_cat) == levels_codes[1] ~ 5,
      !!rlang::sym(drinking_water_quantity_cat) == levels_codes[2] ~ 4,
      !!rlang::sym(drinking_water_quantity_cat) == levels_codes[3] ~ 3,
      !!rlang::sym(drinking_water_quantity_cat) == levels_codes[4] ~ 2,
      !!rlang::sym(drinking_water_quantity_cat) == levels_codes[5] ~ 1,
      .default = NA_real_)
  )


  return(df)

}
