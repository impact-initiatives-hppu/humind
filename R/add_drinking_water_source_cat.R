#' Drinking water source recoding
#'
#' [add_drinking_water_source_cat()] recodes the types of water sources, [add_drinking_water_time_cat()] adds the categorical time to fetch water, and [add_drinking_water_time_threshold_cat()] according to a chosen threshold. Finally, [add_drinking_water_quality_jmp_cat] recodes the water source and time to fetch water into a joint JMP category.
#'
#' @param df A data frame.
#' @param drinking_water_source Component column: Water source types.
#' @param improved Character vector of responses codes, such as "Protected well" or "Public tap", e.g., c("protected_well", "public_tap").
#' @param unimproved Character vector of responses codes, such as "Unprotected well" or "Unprotected spring", e.g., c("unprotected_well", "unprotected_spring").
#' @param surface_water Character vector of responses codes, such as "Lake" or "River, e.g., c("lake", "river").
#' @param undefined Character vector of responses codes, that do not fit any category, e.g., c("other").
#'
#' @export
add_drinking_water_source_cat <- function(df,
                                  drinking_water_source = "wash_drinking_water_source",
                                  improved = c("piped_dwelling", "piped_compound", "piped_neighbour", "tap", "borehole", "protected_well", "protected_spring", "rainwater_collection", "tank_truck", "cart_tank", "kiosk", "bottled_water", "sachet_water"),
                                  unimproved = c("unprotected_well", "unprotected_spring"),
                                  surface_water = "surface_water",
                                  undefined = c("dnk", "pnta", "other")) {


  #------ Checks

  # Check that variables exist
  if_not_in_stop(df, drinking_water_source, "df")

  # Check values set
  are_values_in_set(df, drinking_water_source, c(improved, unimproved, surface_water, undefined))

  #------ Recode water sources
  df <- dplyr::mutate(
    df,
    wash_drinking_water_source_cat = dplyr::case_when(
      !!rlang::sym(drinking_water_source) %in% surface_water ~ "surface_water",
      !!rlang::sym(drinking_water_source) %in% unimproved ~ "unimproved",
      !!rlang::sym(drinking_water_source) %in% improved ~ "improved",
      !!rlang::sym(drinking_water_source) %in% undefined ~ "undefined",
      .default = NA_character_)
  )

  return(df)

}


#' @rdname add_drinking_water_source_cat
#'
#' @param df A data frame.
#' @param drinking_water_time_yn Component column: Time to fetch water, scoping question.
#' @param water_on_premises Character vector of responses codes for water on premises.
#' @param number_minutes Character vector of responses codes for number of minutes.
#' @param dnk Character vector of responses codes for "Don't know".
#' @param undefined Character vector of responses codes for undefined information, e.g. "Prefer not to answer".
#' @param drinking_water_time_int Component column: Time to fetch water, integer.
#' @param max Integer, the maximum value for the time to fetch water.
#' @param drinking_water_time_sl Component column: Time to fetch water, simple choice.
#' @param sl_under_30_min Response code for under 30 minutes.
#' @param sl_30min_1hr Response code for 30 minutes to 1 hour.
#' @param sl_more_than_1hr Response code for more than 1 hour.
#' @param sl_undefined Character vector of responses codes for undefined information, e.g. "Don't know" or "Prefer not to answer".
#' @param drinking_water_source Component column: Water source types.
#' @param skipped_drinking_water_source_premises Character vector of responses codes for skipped water source on premises, e.g. "Piped into dwelling".
#' @param skipped_drinking_water_source_undefined Character vector of responses codes for skipped water source undefined, e.g. "Don't know" or "Prefer not to answer".
#'
#' @export
add_drinking_water_time_cat <- function(
    df,
    drinking_water_time_yn = "wash_drinking_water_time_yn",
    water_on_premises = "water_on_premises",
    number_minutes = "number_minutes",
    dnk = "dnk",
    undefined = "pnta",
    drinking_water_time_int = "wash_drinking_water_time_int",
    max = 600,
    drinking_water_time_sl = "wash_drinking_water_time_sl",
    sl_under_30_min = "under_30_min",
    sl_30min_1hr = "30min_1hr",
    sl_more_than_1hr = "more_than_1hr",
    sl_undefined = c("dnk", "pnta"),
    drinking_water_source = "wash_drinking_water_source",
    skipped_drinking_water_source_premises = "piped_dwelling",
    skipped_drinking_water_source_undefined = c("dnk", "pnta")
){

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, c(drinking_water_time_yn, drinking_water_time_int, drinking_water_time_sl, drinking_water_source), "df")

  # Check if int is integer
  are_cols_numeric(df, drinking_water_time_int)

  # Check if values are in set
  are_values_in_set(df, drinking_water_time_yn, c(water_on_premises, number_minutes, dnk, undefined))
  are_values_in_set(df, drinking_water_time_sl, c(sl_under_30_min, sl_30min_1hr, sl_more_than_1hr, sl_undefined))

  # Check if integer values are above 0 stricly
  if (any(df[[drinking_water_time_int]] <= 0, na.rm = TRUE)) {
    rlang::abort("The integer values for drinking_water_time_int must be strictly above 0.")
  }

  # Check that all inputs under_30min, above_30min_1hr, more_than_1hr are of length 1
  if (length(sl_under_30_min) != 1 | length(sl_30min_1hr) != 1 | length(sl_more_than_1hr) != 1) {
    rlang::abort("under_30_min, above_30min_1hr, more_than_1hr must be of length 1.")
  }

  #------ Recode

  # Recode time to fetch water from integer to char, < 30, ...
  df <- dplyr::mutate(
    df,
    wash_drinking_water_time_cat = dplyr::case_when(
      !!rlang::sym(drinking_water_source) %in% skipped_drinking_water_source_premises ~ "premises",
      !!rlang::sym(drinking_water_source) %in% skipped_drinking_water_source_undefined ~ "undefined",
      !!rlang::sym(drinking_water_time_yn) %in% water_on_premises ~ "premises",
      !!rlang::sym(drinking_water_time_yn) %in% number_minutes ~ dplyr::case_when(
        !!rlang::sym(drinking_water_time_int) < 30 ~ sl_under_30_min,
        !!rlang::sym(drinking_water_time_int) >= 30 & !!rlang::sym(drinking_water_time_int) < 60 ~ sl_30min_1hr,
        !!rlang::sym(drinking_water_time_int) <= 600 ~ sl_more_than_1hr
      ),
      # Fix don't know
      !!rlang::sym(drinking_water_time_yn) %in% undefined ~ "undefined",
      !!rlang::sym(drinking_water_time_yn) %in% dnk & !!rlang::sym(drinking_water_time_sl) %in% sl_undefined ~ "undefined",
      !!rlang::sym(drinking_water_time_yn) %in% dnk ~ !!rlang::sym(drinking_water_time_sl),
      .default = NA_character_
    )
  )

  return(df)

}

#' @rdname add_drinking_water_source_cat
#'
#' @param drinking_water_time_cat Component column: Time to fetch water, recoded categories.
#' @param premises Character vector of responses codes for water on premises.
#' @param under_30min Character vector of responses codes for under 30 min.
#' @param above_30min Character vector of responses codes for above 30 min.
#' @param undefined Character vector of responses codes for undefined information, e.g. "Prefer not to answer".
#'
#' @export
add_drinking_water_time_threshold_cat <- function(
    df,
    drinking_water_time_cat = "wash_drinking_water_time_cat",
    premises = "premises",
    under_30min = c("under_30_min"),
    above_30min = c( "30min_1hr", "more_than_1hr"),
    undefined = "undefined"){

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, drinking_water_time_cat, "df")

  # Check if values are in set
  are_values_in_set(df, drinking_water_time_cat, c(premises, under_30min, above_30min, undefined))

  #------ Recode
  df <- dplyr::mutate(
    df,
    wash_drinking_water_time_30min_cat = dplyr::case_when(
      !!rlang::sym(drinking_water_time_cat) %in% premises ~ "premises",
      !!rlang::sym(drinking_water_time_cat) %in% under_30min ~ "under_30min",
      !!rlang::sym(drinking_water_time_cat) %in% above_30min ~ "above_30min",
      !!rlang::sym(drinking_water_time_cat) %in% undefined ~ "undefined",
      .default = NA_character_
    )
  )

  return(df)

}

#' @rdname add_drinking_water_source_cat
#'
#' @param drinking_water_source_cat Component column: Water source categories.
#' @param drinking_water_source_cat_improved_source Response code for improved water source.
#' @param drinking_water_source_cat_unimproved_source Response code for unimproved water source.
#' @param drinking_water_source_cat_surface_water_source Response code for surface water source.
#' @param drinking_water_source_cat_undefined_source Response code for undefined water source.
#' @param drinking_water_time_30min_cat Component column: Time to fetch water, recoded categories.
#' @param drinking_water_time_30min_cat_premises Response code for water on premises.
#' @param drinking_water_time_30min_cat_under_30min Response code for under 30 minutes.
#' @param drinking_water_time_30min_cat_above_30min Response code for above 30 minutes.
#' @param drinking_water_time_30min_cat_undefined Response code for undefined time.
#'
#' @export
add_drinking_water_quality_jmp_cat <- function(
    df,
    drinking_water_source_cat = "wash_drinking_water_source_cat",
    drinking_water_source_cat_improved_source = "improved",
    drinking_water_source_cat_unimproved_source = "unimproved",
    drinking_water_source_cat_surface_water_source = "surface_water",
    drinking_water_source_cat_undefined_source = "undefined",
    drinking_water_time_30min_cat = "wash_drinking_water_time_30min_cat",
    drinking_water_time_30min_cat_premises = "premises",
    drinking_water_time_30min_cat_under_30min = "under_30min",
    drinking_water_time_30min_cat_above_30min = "above_30min",
    drinking_water_time_30min_cat_undefined = "undefined"){

  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(df, c(drinking_water_source_cat, drinking_water_time_30min_cat), "df")

  # Check if values are in set
  are_values_in_set(df, drinking_water_source_cat, c(drinking_water_source_cat_improved_source, drinking_water_source_cat_unimproved_source, drinking_water_source_cat_surface_water_source, drinking_water_source_cat_undefined_source))
  are_values_in_set(df, drinking_water_time_30min_cat, c(drinking_water_time_30min_cat, drinking_water_time_30min_cat_premises, drinking_water_time_30min_cat_under_30min, drinking_water_time_30min_cat_above_30min, drinking_water_time_30min_cat_undefined))

  #------ Recode

  df <- dplyr::mutate(
    df,
    wash_drinking_water_quality_jmp_cat = dplyr::case_when(
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_cat_surface_water_source ~ "surface_water",
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_cat_unimproved_source ~ "unimproved",
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_cat_improved_source & !!rlang::sym(drinking_water_time_30min_cat) == drinking_water_time_30min_cat_above_30min ~ "limited",
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_cat_improved_source & !!rlang::sym(drinking_water_time_30min_cat) == drinking_water_time_30min_cat_under_30min ~ "basic",
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_cat_improved_source & !!rlang::sym(drinking_water_time_30min_cat) == drinking_water_time_30min_cat_premises ~ "safely_managed",
      !!rlang::sym(drinking_water_source_cat) == drinking_water_source_cat_undefined_source ~ "undefined",
      !!rlang::sym(drinking_water_time_30min_cat) == drinking_water_time_30min_cat_undefined ~ "undefined",
      .default = NA_character_
    )
  )

  return(df)
}
