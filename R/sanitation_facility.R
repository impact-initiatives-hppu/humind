#' Sanitation facility classification - 5-point scale
#'
#' `sanitation_facility()` recodes the types of sanitation facilities, and, if present, the number of persons sharing the facility, and classify each household/individual on a 5-point scale.
#'
#' @param df A data frame
#' @param sanitation_facility Component column: Sanitation facility types.
#' @param sanitation_facility_improved_codes Character vector of responses codes, such as "Composting toilet" or "Pour flush toilet", e.g., c("composting toilet", "pour_flush_toilet").
#' @param sanitation_facility_unimproved_codes Character vector of responses codes, such as "Bucket" or "Hanging latrine", e.g., c("bucket", "hanging_latrine").
#' @param sanitation_facility_open_defecation_codes Character vector of responses codes, such as "Open defecation", e.g., c("open_defecation").
#' @param sharing_sanitation_facility Component column: Number of people with whom the facility is shared.
#'
#' @return Three new columns: a recoded column of sanitation facilities between improved, unimproved and open defecatop,my finger  (water_source_recoded), a recoded column of times to fetch water according to the chosen thresholds (time_to_fetch_recoded), a 5-point scale from 1 to 5 (water_source_class).
#'
#' @section Details on the 5-point scale:
#'
#' The classification is computed as follows:
#'
#' * Level 5: Open defecation;
#' * Level 4: Unimproved sanitation facility;
#' * Level 3: Improved sanitation facility with more than 50 people;
#' * Level 2: Improved sanitation facility with 20 to 49 people;
#' * Level 1: Improved sanitation facility with less than 19 people.
#'
#' If `sharing_sanitation_facility` is null, then levels 4 and 5 do not change, and improved sanitation facilities assign a 1.
#'
#' @export
sanitation_facility <- function(df,
                                sanitation_facility = "sanitation_facility",
                                sanitation_facility_improved_codes = c("composting toilet", "pour_flush_toilet"),
                                sanitation_facility_unimproved_codes = c("bucket", "hanging_latrine"),
                                sanitation_facility_open_defecation_codes = c("open_defecation"),
                                sharing_sanitation_facility = NULL
) {

  #------ Check values ranges
  are_values_in_set(df, sanitation_facility, c(sanitation_facility_improved_codes, sanitation_facility_unimproved_codes, sanitation_facility_open_defecation_codes))

  if (!is.null(sharing_sanitation_facility)) are_cols_numeric(df, sharing_sanitation_facility)

  #------ Recode sanitation facility
  df <- dplyr::mutate(
    df,
    sanitation_facility_recoded = dplyr::case_when(
      {{ sanitation_facility }} %in% sanitation_facility_open_defecation_codes ~ "open_defecation",
      {{ sanitation_facility }} %in% sanitation_facility_unimproved_codes ~ "unimproved",
      {{ sanitation_facility }} %in% sanitation_facility_improved_codes ~ "improved",
      .default = NA_character_)
  )

  if(!is.null(sharing_sanitation_facility)) {

    #------ Recode time to fetch
    df <- dplyr::mutate(
      df,
      sharing_sanitation_facility_recoded = dplyr::case_when(
        {{ sharing_sanitation_facility }} >= 50 ~ "50_and_above",
        {{ sharing_sanitation_facility }} >= 20 ~ "20_to_49",
        {{ sharing_sanitation_facility }} >= 0 ~ "19_and_below",
        .default = NA_character_)
    )

    #------ 5-point scale
    df <- dplyr::mutate(
      df,
      sanitation_facility_class = dplyr::case_when(
        sanitation_facility_recoded == "open_defecation" ~ 5,
        sanitation_facility_recoded == "unimproved" ~ 4,
        sanitation_facility_recoded == "improved" & sharing_sanitation_facility_recoded == "50_and_above" ~ 3,
        sanitation_facility_recoded == "improved" & sharing_sanitation_facility_recoded == "20_to_49" ~ 2,
        sanitation_facility_recoded == "improved" & sharing_sanitation_facility_recoded == "19_and_below" ~ 1,
        .default = NA_real_)
    )


  } else {

    #------ 5-point scale
    df <- dplyr::mutate(
      df,
      sanitation_facility_class = dplyr::case_when(
        sanitation_facility_recoded == "open_defecation" ~ 5,
        sanitation_facility_recoded == "unimproved" ~ 4,
        sanitation_facility_recoded == "improved" ~ 1,
        .default = NA_real_)
    )

  }

  return(df)

}
