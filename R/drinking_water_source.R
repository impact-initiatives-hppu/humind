#' Drinking water source classification
#'
#' [drinking_water_source()] recodes the types of water sources, [time_to_fetch_water()] the time to fetch water according to a chosen threshold, and [drinking_water_source_score()] classify each household/individual on a 5-point scale.
#'
#' @param df A data frame.
#' @param drinking_water_source Component column: Water source types.
#' @param improved Character vector of responses codes, such as "Protected well" or "Public tap", e.g., c("protected_well", "public_tap").
#' @param unimproved Character vector of responses codes, such as "Unprotected well" or "Unprotected spring", e.g., c("unprotected_well", "unprotected_spring").
#' @param surface_water Character vector of responses codes, such as "Lake" or "River, e.g., c("lake", "river").
#' @param na Character vector of responses codes, that do not fit any category, e.g., c("other").

#'
#' @return A dataframe with a new column. For [drinking_water_source()], a recoded column of water sources between improved, unimproved and surface water (drinking_water_source_cat); for [time_to_fetch_water()], a recoded column of times to fetch water according to the chosen thresholds (time_to_fetch_water_cat); for [drinking_water_source_score()], a 5-point scale from 1 to 5 (drinking_water_source_score).
#'
#' @section Details on the 5-point scale:
#'
#' The classification is computed as follows:
#'
#' * Level 5: Surface water;
#' * Level 4: Unimproved water source;
#' * Level 3: Improved water source with more than 30 minutes return time;
#' * Level 2: Improved water source within 30 minutes return time;
#' * Level 1: Improved water source on premises.
#'
#' @export
drinking_water_source <- function(df,
                                  drinking_water_source = "drinking_water_source",
                                  improved,
                                  unimproved,
                                  surface_water,
                                  na) {


  #------ Check values set
  are_values_in_set(df, drinking_water_source, c(improved, unimproved, surface_water, na))

  #------ Recode water sources
  df <- dplyr::mutate(
    df,
    drinking_water_source_cat = dplyr::case_when(
      !!rlang::sym(drinking_water_source) %in% surface_water ~ "surface_water",
      !!rlang::sym(drinking_water_source) %in% unimproved ~ "unimproved",
      !!rlang::sym(drinking_water_source) %in% improved ~ "improved",
      .default = NA_character_)
  )

  return(df)

}



#' @rdname drinking_water_source
#'
#' @param time_to_fetch_water Component column: Time to fetch water.
#' @param above_threshold Character vector of responses codes, such as "30 minutes to 59 minutes" or "1 hour and above", e.g., c("30mins_to_59mins", "1hour_above").
#' @param below_threshold Character vector of responses codes, such as "5 to 14 minutes" or "15 minutes to 29 minutes", e.g., c("5mins_to_14mins", "15mins_to_29mins").
#' @param premises Character vector of responses codes, such as "On premises", e.g., c("premises").
#'
#' @export
time_to_fetch_water <- function(df,
                                time_to_fetch_water,
                                above_threshold,
                                below_threshold,
                                premises,
                                na) {

  #------ Check values set
  are_values_in_set(df, time_to_fetch_water, c(above_threshold, below_threshold, premises, na ))


  #------ Recode time to fetch
  df <- dplyr::mutate(
    df,
    time_to_fetch_water_cat = dplyr::case_when(
      !!rlang::sym(time_to_fetch_water) %in% above_threshold ~ "above_threshold",
      !!rlang::sym(time_to_fetch_water) %in% below_threshold ~ "below_threshold",
      !!rlang::sym(time_to_fetch_water) %in% premises ~ "premises",
      .default = NA_character_)
  )

}


#' @rdname drinking_water_source
#'
#' @param drinking_water_source_cat Component column: categories of drinking water sources.
#' @param drinking_water_source_levels Drinking water sources levels - in that order: improved, unimproved, surface water.
#' @param time_to_fetch_water_cat Component column: categories of time to fetch water.
#' @param time_to_fetch_water_levels Time to fetch water levels - in that order: premises, below the threshold, above the threshold.
#'
#' @export
drinking_water_source_score <- function(df,
                                        drinking_water_source_cat = "drinking_water_source_cat",
                                        drinking_water_source_levels = c("improved", "unimproved", "surface_water"),
                                        time_to_fetch_water_cat = "time_to_fetch_water_cat",
                                        time_to_fetch_water_levels = c("premises", "below_threshold", "above_threshold")
) {


  #------ Check values set
  are_values_in_set(df, drinking_water_source_cat, drinking_water_source_levels)
  are_values_in_set(df, time_to_fetch_water_cat, time_to_fetch_water_levels)

  #------ 5-point scale
  df <- dplyr::mutate(
    df,
    drinking_water_source_score = dplyr::case_when(
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_levels[3] ~ 5,
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_levels[2] ~ 4,
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_levels[1] & !!rlang::sym(time_to_fetch_water_cat) == time_to_fetch_water_levels[3] ~ 3,
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_levels[1] & !!rlang::sym(time_to_fetch_water_cat) == time_to_fetch_water_levels[2] ~ 2,
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_levels[1] & !!rlang::sym(time_to_fetch_water_cat) == time_to_fetch_water_levels[1] ~ 1,
      .default = NA_real_)
  )

  return(df)

}

