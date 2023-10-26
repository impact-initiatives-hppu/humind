#' Sanitation facility classification
#'
#' [sanitation_facility()] recodes the types of sanitation facilities, [sharing_sanitation_facility()] recodes the number of people sharing the sanitation facility, and [sanitation_facility_score()] classify each household on a 5-point scale.
#'
#' @param df A data frame.
#' @param sanitation_facility Component column: Sanitation facility types.
#' @param improved Character vector of responses codes, such as "Composting toilet" or "Pour flush toilet", e.g., c("composting toilet", "pour_flush_toilet").
#' @param unimproved Character vector of responses codes, such as "Bucket" or "Hanging latrine", e.g., c("bucket", "hanging_latrine").
#' @param open_defecation Character vector of responses codes, such as "Open defecation", e.g., c("open_defecation").
#' @param na Character vector of responses codes, that do not fit any category, e.g., c("other").
#'
#' @return Three new columns: a recoded column of sanitation facilities between improved, unimproved and open defecation  (sanitation_facility_recoded), if not null a recoded column of the number of persons sharing the facility (sharing_sanitation_facility_recoded), a 5-point scale from 1 to 5 (sanitation_facility_class).
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
                                improved,
                                unimproved,
                                open_defecation,
                                na
) {

  #------ Check values ranges
  are_values_in_set(df, sanitation_facility, c(improved, unimproved, open_defecation, na))

  #------ Recode sanitation facility
  df <- dplyr::mutate(
    df,
    sanitation_facility_cat = dplyr::case_when(
      !!rlang::sym(sanitation_facility) %in% open_defecation ~ "open_defecation",
      !!rlang::sym(sanitation_facility) %in% unimproved ~ "unimproved",
      !!rlang::sym(sanitation_facility) %in% improved ~ "improved",
      .default = NA_character_)
  )

  return(df)
}



#' @rdname sanitation_facility
#'
#' @param sharing_sanitation_facility Component column: Number of people with whom the facility is shared.
#'
#' @export
sharing_sanitation_facility <- function(df,
                                       sharing_sanitation_facility = "sharing_sanitation_facility"
) {

  #------ Check values ranges
  are_cols_numeric(df, sharing_sanitation_facility)

  #------ Recode sanitation facility
  df <- dplyr::mutate(
      df,
      sharing_sanitation_facility_cat = dplyr::case_when(
        !!rlang::sym(sharing_sanitation_facility) >= 50 ~ "50_and_above",
        !!rlang::sym(sharing_sanitation_facility) >= 20 ~ "20_to_49",
        !!rlang::sym(sharing_sanitation_facility) >= 0 ~ "19_and_below",
        .default = NA_character_)
    )

  return(df)
}



#' @rdname sanitation_facility
#'
#' @param sanitation_facility_cat Component column: categories of sanitation facilities.
#' @param sanitation_facility_levels Sanitation facilities levels - in that order: improved, unimproved, open defecation.
#' @param sharing_sanitation_facility_cat Component column: categories of the number of people sharing sanitation facilities.
#' @param sharing_sanitation_facility_levels Sharing sanitation facilities levels - in that order: 19 and below, 20 to 49, 50 and above.
#'
#' @export
sanitation_facility_score <- function(df,
                                        sanitation_facility_cat = "sanitation_facility_cat",
                                        sanitation_facility_levels = c("improved", "unimproved", "open_defecation"),
                                        sharing_sanitation_facility_cat = "sharing_sanitation_facility_cat",
                                        sharing_sanitation_facility_levels = c("19_and_below", "20_to_49", "50_and_above")
){


  #------ 5-point scale
  df <- dplyr::mutate(
    df,
    sanitation_facility_score = dplyr::case_when(
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[3] ~ 5,
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[2]  ~ 4,
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[1] & sharing_sanitation_facility_cat == sharing_sanitation_facility_levels[3] ~ 3,
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[1] & sharing_sanitation_facility_cat == sharing_sanitation_facility_levels[2] ~ 2,
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[1] & sharing_sanitation_facility_cat == sharing_sanitation_facility_levels[1] ~ 1,
      .default = NA_real_)
  )

  return(df)
}
