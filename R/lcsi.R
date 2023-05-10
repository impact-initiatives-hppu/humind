#' @title LCSI - Livelihood Coping Strategy Index
#'
#' @param df A data frame
#' @param lcsi_stress_1  Component column: Stress strategy 1
#' @param lcsi_stress_2 Component column: Stress strategy 2
#' @param lcsi_stress_3 Component column: Stress strategy 3
#' @param lcsi_stress_4 Component column: Stress strategy 4
#' @param lcsi_crisis_1 Component column: Crisis strategy 1
#' @param lcsi_crisis_2 Component column: Crisis strategy 2
#' @param lcsi_crisis_3 Component column: Crisis strategy 3
#' @param lcsi_emergency_1 Component column: Emergency strategy 1
#' @param lcsi_emergency_2 Component column: Emergency strategy 2
#' @param lcsi_emergency_3 Component column: Emergency strategy 3
#' @param level_codes Character vector of responses codes, including first in the following order: Yes", "No, exhausted", "No, no need", "No, not applicable", e.g. c("yes", "exhausted", "no_need", "not_applicable")
#' @param with_exhaustion Boolean. Is the exhaustion of strategies ("No, exhausted") accounted for?
#'
#' @return Fourteen new columns: each strategy recoded (lcsi_stress_*, lcsi_crisis_*, lcsi_emergency_*), a dummy for each category (lcsi_stress, lcsi_crisis, lcsi_emergency), and the category (lcsi_cat).
#'
#' @export
lcsi <- function(
    df,
    lcsi_stress_1 = "lcsi_stress_1",
    lcsi_stress_2 = "lcsi_stress_2",
    lcsi_stress_3 = "lcsi_stress_3",
    lcsi_stress_4 = "lcsi_stress_4",
    lcsi_crisis_1 = "lcsi_crisis_1",
    lcsi_crisis_2 = "lcsi_crisis_2",
    lcsi_crisis_3 = "lcsi_crisis_3",
    lcsi_emergency_1 = "lcsi_emergency_1",
    lcsi_emergency_2 = "lcsi_emergency_2",
    lcsi_emergency_3 = "lcsi_emergency_3",
    level_codes = c("yes", "exhausted", "no_need", "not_applicable"),
    with_exhaustion = TRUE) {


  #------ Enquos
  lcsi_comp_cols <- rlang::enquos(
    lcsi_stress_1, lcsi_stress_2, lcsi_stress_3, lcsi_stress_4,
    lcsi_crisis_1, lcsi_crisis_2, lcsi_crisis_3,
    lcsi_emergency_1, lcsi_emergency_2, lcsi_emergency_3)
  lcsi_comp_cols <- purrr::map_chr(lcsi_comp_cols, rlang::as_name)


  #------ Are level1_codes and level2_codes in set
  are_values_in_set(df, lcsi_comp_cols, level_codes)

  #------ Helper for recoding
  lcsi_recoding <- function(var, level_codes, with_exhaustion = with_exhaustion){

    if(with_exhaustion) {
      dplyr::case_when(
        {{ var }} %in% level_codes[1:2] ~ 1,
        {{ var }} %in% level_codes[3:4] ~ 0,
        TRUE ~ NA_real_)
    } else if (!with_exhaustion) {
      dplyr::case_when(
        {{ var }} %in% level_codes[1] ~ 1,
        {{ var }} %in% level_codes[2:4] ~ 0,
        TRUE ~ NA_real_)
    }
  }

  # Prepare new column names
  lcsi_stress_cols <- c("lcsi_stress_1", "lcsi_stress_2", "lcsi_stress_3", "lcsi_stress_4")
  lcsi_crisis_cols <- c("lcsi_crisis_1", "lcsi_crisis_2", "lcsi_crisis_3")
  lcsi_emergency_cols <- c("lcsi_emergency_1", "lcsi_emergency_2", "lcsi_emergency_3")

  lcsi_stress_agg_col <- "lcsi_stress"
  lcsi_crisis_agg_col <- "lcsi_crisis"
  lcsi_emergency_agg_col <- "lcsi_emergency"

  lcsi_cat <- "lcsi_cat"

  if (!with_exhaustion) {
    lcsi_stress_cols <- lapply(lcsi_stress_cols, \(x) stringr::str_c(x, "_no_exhaustion"))
    lcsi_crisis_cols <- lapply(lcsi_crisis_cols, \(x) stringr::str_c(x, "_no_exhaustion"))
    lcsi_emergency_cols <- lapply(lcsi_emergency_cols, \(x) stringr::str_c(x, "_no_exhaustion"))

    lcsi_stress_agg_col <-  lapply(lcsi_stress_agg_col, \(x) stringr::str_c(x, "_no_exhaustion"))
    lcsi_crisis_agg_col <-  lapply(lcsi_stress_agg_col, \(x) stringr::str_c(x, "_no_exhaustion"))
    lcsi_emergency_agg_col <-  lapply(lcsi_stress_agg_col, \(x) stringr::str_c(x, "_no_exhaustion"))

    lcsi_cat <- lapply(lcsi_cat, \(x) stringr::str_c(x, "no_exhaustion"))
  }

  #------ Recode LCS component columns
  df <- dplyr::mutate(
    df,
    "{lcsi_stress_cols[1]}" := lcsi_recoding({{ lcsi_stress_1 }}, level_codes),
    "{lcsi_stress_cols[2]}" := lcsi_recoding({{ lcsi_stress_2 }}, level_codes),
    "{lcsi_stress_cols[3]}" := lcsi_recoding({{ lcsi_stress_3 }}, level_codes),
    "{lcsi_stress_cols[4]}" := lcsi_recoding({{ lcsi_stress_4 }}, level_codes),
    "{lcsi_crisis_cols[1]}" := lcsi_recoding({{ lcsi_crisis_1 }}, level_codes),
    "{lcsi_crisis_cols[2]}" := lcsi_recoding({{ lcsi_crisis_2 }}, level_codes),
    "{lcsi_crisis_cols[3]}" := lcsi_recoding({{ lcsi_crisis_3 }}, level_codes),
    "{lcsi_emergency_cols[1]}" := lcsi_recoding({{ lcsi_emergency_1 }}, level_codes),
    "{lcsi_emergency_cols[2]}" := lcsi_recoding({{ lcsi_emergency_2 }}, level_codes),
    "{lcsi_emergency_cols[3]}" := lcsi_recoding({{ lcsi_emergency_3 }}, level_codes)
  )

  #------ LCS per emergency level
  df <- dplyr::mutate(
    df,
    "{lcsi_stress_agg_col}" =  ifelse(
      rowSums(dplyr::across(dplyr::all_of(lcsi_stress_cols)), na.rm = FALSE) >= 1,
      1,
      0),
    "{lcsi_crisis_agg_col}" =  ifelse(
      rowSums(dplyr::across(dplyr::all_of(lcsi_crisis_cols)), na.rm = FALSE) >= 1,
      1,
      0),
    "{lcsi_emergency_agg_col}" = ifelse(
      rowSums(dplyr::across(dplyr::all_of(lcsi_emergency_cols)), na.rm = FALSE) >= 1,
      1,
      0)
  )

  #------ LCS categories
  df <- dplyr::mutate(
    df,
    "{lcsi_cat}" :=  dplyr::case_when(
      !!lcsi_emergency_agg_col == 1 ~ "Emergency",
      !!lcsi_crisis_agg_col == 1 ~ "Crisis",
      !!lcsi_stress_agg_col == 1 ~ "Stress",
      !!lcsi_stress_agg_col == 0 & !!lcsi_crisis_agg_col == 0 & !!lcsi_emergency_agg_col == 0 ~ "None",
      TRUE ~ NA_character_))

  return(df)
}
