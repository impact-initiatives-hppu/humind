#' @title Prepare dummy variables for each WG-SS component (individual data)
#'
#' @param roster A data frame of individual-level data.
#' @param ind_age The individual age column.
#' @param vision Vision component column.
#' @param hearing Hearing component column.
#' @param mobility Mobility component column.
#' @param cognition Cognition component column.
#' @param self_care Self-care component column.
#' @param communication Communication component column.
#' @param level_codes Character vector of responses codes, including first in the following order: "No difficulty", "Some difficulty", "A lot of difficulty", "Cannot do at all", e.g. c("no_difficulty", "some_difficulty", "lot_of_difficulty", "cannot_do").
#'
#' @return Fifteen new columns: each component dummy for levels 3 and 4, disability level 3, level 4, and level 3 and 4 together.
#' @export
roster_wgq_ss <- function(
    roster,
    ind_age = "ind_age",
    vision =" wgq_vision",
    hearing = "wgq_hearing",
    mobility = "wgq_mobility",
    cognition = "wgq_cognition",
    self_care = "wgq_self_care",
    communication = "wgq_communication",
    level_codes = c("no_difficulty", "some_difficulty", "lot_of_difficulty", "cannot_do")){

  #------ Enquos
  wgq_cols <- rlang::enquos(vision, hearing, mobility, cognition, self_care, communication)
  wgq_cols <- purrr::map_chr(wgq_cols, rlang::as_name)

  ind_age_col <- rlang::as_name(rlang::enquo(ind_age))

  #------ Check if in_age exist
  if_not_in_stop(roster, "ind_age_col", "roster")

  #------ Are level_codes in set
  are_values_in_set(roster, wgq_cols, level_codes)

  #------ Recode level 3 and 4
  roster <- dplyr::mutate(
    roster,
    wgq_vision_3 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ vision }} != level_codes[3] ~ 0,
      {{ vision }} != level_codes[3] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_hearing_3 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ hearing }} != level_codes[3] ~ 0,
      {{ hearing }} != level_codes[3] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_mobility_3 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ mobility }} != level_codes[3] ~ 0,
      {{ mobility }} != level_codes[3] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_cognition_3 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ cognition }} != level_codes[3] ~ 0,
      {{ cognition }} != level_codes[3] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_self_care_3 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ self_care }} != level_codes[3] ~ 0,
      {{ self_care }} != level_codes[3] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_communication_3 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ communication }} != level_codes[3] ~ 0,
      {{ communication }} != level_codes[3] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_vision_4 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ vision }} != level_codes[4] ~ 0,
      {{ vision }} != level_codes[4] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_vision_4 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ vision }} != level_codes[4] ~ 0,
      {{ vision }} != level_codes[4] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_hearing_4 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ hearing }} != level_codes[4] ~ 0,
      {{ hearing }} != level_codes[4] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_mobility_4 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ mobility }} != level_codes[4] ~ 0,
      {{ mobility }} != level_codes[4] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_cognition_4 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ cognition }} != level_codes[4] ~ 0,
      {{ cognition }} != level_codes[4] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_self_care_4 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ self_care }} != level_codes[4] ~ 0,
      {{ self_care }} != level_codes[4] ~ 1,
      TRUE ~ NA_real_
    ),
    wgq_communication_4 = dplyr::case_when(
      {{ ind_age }} < 5 ~ NA_real_,
      {{ communication }} != level_codes[4] ~ 0,
      {{ communication }} != level_codes[4] ~ 1,
      TRUE ~ NA_real_
    ))

  roster <- dplyr::mutate(
    roster,
    wgq_disability_3 = dplyr::case_when(
      wgq_communication_3 == 1 | wgq_vision_3 == 1 | wgq_hearing_3 == 1 | wgq_mobility_3 == 1 | wgq_self_care_3 == 1 | wgq_cognition_3 == 1 ~ 1,
      wgq_communication_3 == 0 & wgq_vision_3 == 0 & wgq_hearing_3 == 0 & wgq_mobilite_3 == 0 & wgq_self_care_3 == 0 & wgq_cognition_3 == 0 ~ 0,
      TRUE ~ NA_real_
    ),
    wgq_disability_4 = dplyr::case_when(
      wgq_communication_4 == 1 | wgq_vision_4 == 1 | wgq_hearing_4 == 1 | wgq_mobility_4 == 1 | wgq_self_care_4 == 1 | wgq_cognition_4 == 1 ~ 1,
      wgq_communication_4 == 0 & wgq_vision_4 == 0 & wgq_hearing_4 == 0 & wgq_mobilite_4 == 0 & wgq_self_care_4 == 0 & wgq_cognition_4 == 0 ~ 0,
      TRUE ~ NA_real_
    )
  )

  roster <- dplyr::mutate(
    roster,
    wgq_disability = dplyr::case_when(
      wgq_disability_3 == 1 | wgq_disability_4 == 1 ~ 1,
      wgq_disability_3 == 0 & wgq_disability_4 == 0 ~ 0,
      TRUE ~ NA_real_
      )
  )

  return(roster)
}
