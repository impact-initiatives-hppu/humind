#' @title Add summarized individual WG-SS data to the household data
#'
#' @param roster A data frame of individual-level data.
#' @param hh A data frame of household-level data.
#' @param id_col Survey unique identifier column (must be present in both roster and hh).
#' @param wgq_disability Dummy from roster. One group from the SS was reported as A lot of difficulty or Cannot do at all.
#' @param wgq_disability_3 Dummy from roster. One group from the SS was reported as A lot of difficulty.
#' @param wgq_disability_4 Dummy from roster. One group from the SS was reported as Cannot do at all.
#' @param wgq_vision_3 Dummy from roster. Group vision was reported as A lot of difficulty.
#' @param wgq_hearing_3 Dummy from roster. Group hearing was reported as A lot of difficulty.
#' @param wgq_mobility_3 Dummy from roster. Group mobility was reported as A lot of difficulty.
#' @param wgq_cognition_3 Dummy from roster. Group cognition was reported as A lot of difficulty.
#' @param wgq_self_care_3 Dummy from roster. Group self care was reported as A lot of difficulty.
#' @param wgq_communication_3 Dummy from roster. Group communication was reported as A lot of difficulty.
#' @param wgq_vision_4 Dummy from roster. Group vision was reported as Cannot do at all.
#' @param wgq_hearing_4 Dummy from roster. Group hearing was reported as Cannot do at all.
#' @param wgq_mobility_4 Dummy from roster. Group mobility was reported as Cannot do at all.
#' @param wgq_cognition_4 Dummy from roster. Group cognition was reported as Cannot do at all.
#' @param wgq_self_care_4 Dummy from roster. Group self care was reported as Cannot do at all.
#' @param wgq_communication_4 Dummy from roster. Group communication was reported as Cannot do at all.
#'
#' @return hh with fifteen new columns: each component dummy for levels 3 and 4, disability level 3, level 4, and level 3 and 4 together (summarized by household).
#'
#' @details To be used after `roster_wgq_ss()`
#'
#' @export
add_roster_wgq_ss <- function(roster,
                              hh,
                              id_col = "uuid",
                              wgq_disability = "wgq_disability",
                              wgq_disability_3 = "wgq_disability_3",
                              wgq_disability_4 = "wgq_disability_4",
                              wgq_vision_3 = "wgq_vision_3",
                              wgq_hearing_3 = "wgq_hearing_3",
                              wgq_mobility_3 = "wgq_mobility_3",
                              wgq_cognition_3 = "wgq_cognition_3",
                              wgq_self_care_3 = "wgq_self_care_3",
                              wgq_communication_3 = "wgq_communication_3",
                              wgq_vision_4 = "wgq_vision_4",
                              wgq_hearing_4 = "wgq_hearing_4",
                              wgq_mobility_4 = "wgq_mobility_4",
                              wgq_cognition_4 = "wgq_cognition_4",
                              wgq_self_care_4 = "wgq_mobility_4",
                              wgq_communication_4 = "wgq_communication_4"
){

  #------ Check for id_col
  id_col_name <- rlang::as_name(rlang::enquo(id_col))
  if_not_in_stop(roster, id_col_name, "roster", "id_col")
  if_not_in_stop(hh, id_col_name, "hh", "id_col")

  #------ Check if values exists and are 0-1 dummies

  wgq_cols <- rlang::enquos(
    wgq_disability,
    wgq_disability_3,
    wgq_disability_4,
    wgq_vision_3,
    wgq_hearing_3,
    wgq_mobility_3,
    wgq_cognition_3,
    wgq_self_care_3,
    wgq_communication_3,
    wgq_vision_4,
    wgq_hearing_4,
    wgq_mobility_4,
    wgq_cognition_4,
    wgq_self_care_4,
    wgq_communication_4
  )
  wgq_cols <- purrr::map_chr(wgq_cols, rlang::as_name)

  are_values_in_set(roster, wgq_cols, 0:1)



  #------ Summarize wgq
  roster <- roster |>
    dplyr::group_by({{ id_col }}) |>
    dplyr::summarize(
      wgq_communication_3 = sum(wgq_communication_3, na.rm = TRUE),
      wgq_communication_4 = sum(wgq_communication_4, na.rm = TRUE),
      wgq_vision_3 = sum(wgq_vision_3, na.rm = TRUE),
      wgq_vision_4 = sum(wgq_vision_4, na.rm = TRUE),
      wgq_hearing_3 = sum(wgq_hearing_3, na.rm = TRUE),
      wgq_hearing_4 = sum(wgq_hearing_4, na.rm = TRUE),
      wgq_mobility_3 = sum(wgq_mobility_3, na.rm = TRUE),
      wgq_mobility_4 = sum(wgq_mobility_4, na.rm = TRUE),
      wgq_self_care_3 = sum(wgq_self_care_3, na.rm = TRUE),
      wgq_self_care_4 = sum(wgq_self_care_4, na.rm = TRUE),
      wgq_cognition_3 = sum(wgq_cognition_3, na.rm = TRUE),
      wgq_cognition_4 = sum(wgq_cognition_4, na.rm = TRUE),
      wgq_disability_3 = sum(wgq_disability_3, na.rm = TRUE),
      wgq_disability_4 = sum(wgq_disability_4, na.rm = TRUE),
      wgq_disability = sum(wgq_disability, na.rm = TRUE)
    ) |>
    dplyr::ungroup()

  #------ Remove columns from hh that are present in roster but id_col
  hh <- impactR::diff_tibbles(hh, roster, {{ id_col }})

  #------
  hh <- dplyr::left_join(hh, roster, by = id_col_name)

  return(hh)

}
