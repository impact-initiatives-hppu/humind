#' Water source classification - 5-point scale
#'
#' `water_source()` recodes the types of water sources, the time to fetch water according to a chosen threshold, and classify each household/individual on a 5-point scale.
#'
#' @param df A data frame.
#' @param water_source Component column: Water source types.
#' @param water_source_improved_codes Character vector of responses codes, such as "Protected well" or "Public tap", e.g., c("protected_well", "public_tap").
#' @param water_source_unimproved_codes Character vector of responses codes, such as "Unprotected well" or "Unprotected spring", e.g., c("unprotected_well", "unprotected_spring").
#' @param water_source_surface_water_codes Character vector of responses codes, such as "Lake" or "River, e.g., c("lake", "river").
#' @param water_source_na_codes Character vector of responses codes, that do not fit any category, e.g., c("other").
#' @param time_to_fetch Component column: Time to fetch water.
#' @param time_to_fetch_above_threshold_codes Character vector of responses codes, such as "30 minutes to 59 minutes" or "1 hour and above", e.g., c("30mins_to_59mins", "1hour_above").
#' @param time_to_fetch_below_threshold_codes Character vector of responses codes, such as "5 to 14 minutes" or "15 minutes to 29 minutes", e.g., c("5mins_to_14mins", "15mins_to_29mins").
#' @param time_to_fetch_premises_codes Character vector of responses codes, such as "On premises", e.g., c("premises").
#' @param time_to_fetch_na_codes Character vector of responses codes, that do not fit any category, e.g., c("other").

#'
#' @return Three new columns: a recoded column of water sources between improved, unimproved and surface water (water_source_recoded), a recoded column of times to fetch water according to the chosen thresholds (time_to_fetch_recoded), a 5-point scale from 1 to 5 (water_source_class).
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
water_source <- function(df,
                         water_source = "water_source",
                         water_source_improved_codes =   c("protected_well", "public_tap"),
                         water_source_unimproved_codes =  c("unprotected_well", "unprotected_spring"),
                         water_source_surface_water_codes = c("lake", "river"),
                         water_source_na_codes = c("other"),
                         time_to_fetch = "time_to_fetch_water",
                         time_to_fetch_above_threshold_codes = c("30mins_to_59mins", "1hour_above"),
                         time_to_fetch_below_threshold_codes = c("5mins_to_14mins", "15mins_to_29mins"),
                         time_to_fetch_premises_codes = c("premises"),
                         time_to_fetch_na_codes = c("other")
) {


  #------ Check values set
  are_values_in_set(df, water_source, c(water_source_na_codes, water_source_improved_codes, water_source_unimproved_codes, water_source_surface_water_codes))
  are_values_in_set(df, time_to_fetch, c(time_to_fetch_na_codes, time_to_fetch_above_threshold_codes, time_to_fetch_below_threshold_codes, time_to_fetch_premises_codes))


  #------ Recode water sources
  df <- dplyr::mutate(
    df,
    water_source_recoded = dplyr::case_when(
      !!rlang::sym(water_source) %in% water_source_surface_water_codes ~ "surface_water",
      !!rlang::sym(water_source) %in% water_source_unimproved_codes ~ "unimproved",
      !!rlang::sym(water_source) %in% water_source_improved_codes ~ "improved",
      .default = NA_character_)
  )

  #------ Recode time to fetch
  df <- dplyr::mutate(
    df,
    time_to_fetch_recoded = dplyr::case_when(
      !!rlang::sym(time_to_fetch) %in% time_to_fetch_above_threshold_codes ~ "above_threshold",
      !!rlang::sym(time_to_fetch) %in% time_to_fetch_below_threshold_codes ~ "below_threshold",
      !!rlang::sym(time_to_fetch) %in% time_to_fetch_premises_codes ~ "premises",
      .default = NA_character_)
  )

  #------ 5-point scale
  df <- dplyr::mutate(
    df,
    water_source_class = dplyr::case_when(
      water_source_recoded == "surface_water" ~ 5,
      water_source_recoded == "unimproved" ~ 4,
      water_source_recoded == "improved" & time_to_fetch_recoded == "above_threshold" ~ 3,
      water_source_recoded == "improved" & time_to_fetch_recoded == "below_threshold" ~ 2,
      water_source_recoded == "improved" & time_to_fetch_recoded == "premises" ~ 1,
      .default = NA_real_)
  )

  return(df)

}
