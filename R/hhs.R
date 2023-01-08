#' @title HHS - Household Hunger Scale
#'
#' @param df A data frame
#' @param hhs_lev1_nofoodhh Component column: No food of any kind in the house
#' @param hhs_lev2_nofoodhh Follow-up frequency column
#' @param hhs_lev1_sleephungry Component column: Go to sleep hungry because there was not enough food
#' @param hhs_lev2_sleephungry Follow-up frequency column
#' @param hhs_lev1_alldaynight Component column: Go a whole day and night without eating
#' @param hhs_lev2_alldaynight Follow-up frequency column
#' @param level1_codes Character vector of the full set of values, and in particular "Yes" and "No" codes first (in this order), e.g. c("yes", "no")
#' @param level2_codes Character vector of the full set of values, and in particular, frequencies first, in the following order: "Rarely", "Sometimes", "Often", e.g. c("rarely", "sometimes", "often")
#'
#' @return Five new columns: each component recoded hhs_comp1, hhs_comp2, hhs_comp3, the overall score (hhs_score) and categories (hhs_cat).
#'
#' @export
hhs <- function(df,
                hhs_lev1_nofoodhh = "hhs_lev1_nofoodhh",
                hhs_lev2_nofoodhh = "hhs_lev2_nofoodhh",
                hhs_lev1_sleephungry = "hhs_lev1_sleephungry",
                hhs_lev2_sleephungry = "hhs_lev2_sleephungry",
                hhs_lev1_alldaynight = "hhs_lev1_alldaynight",
                hhs_lev2_alldaynight = "hhs_lev2_alldaynight",
                level1_codes = c("yes", "no"),
                level2_codes = c("rarely", "sometimes", "often")){

  #------ Enquos
  hhs_lev1_cols <- rlang::enquos(hhs_lev1_nofoodhh, hhs_lev1_sleephungry, hhs_lev1_alldaynight)
  hhs_lev1_cols <- purrr::map_chr(hhs_lev1_cols, rlang::as_name)

  hhs_lev2_cols <- rlang::enquos(hhs_lev2_nofoodhh, hhs_lev2_sleephungry, hhs_lev2_alldaynight)
  hhs_lev2_cols <- purrr::map_chr(hhs_lev2_cols, rlang::as_name)

  #------ Are level1_codes and level2_codes in set
  are_values_in_set(df, hhs_lev1_cols, level1_codes)
  are_values_in_set(df, hhs_lev2_cols, level2_codes)

  #------ Small helper to recode hhs
  hhs_recoding <- function(q_yes_no, q_freq, level1_codes, level2_codes){
    dplyr::case_when(
      {{ q_yes_no }} == level1_codes[2] ~ 0,
      {{ q_freq }} %in% level2_codes[1:2] ~ 1,
      {{ q_freq }} == level2_codes[3] ~ 2,
      TRUE ~ NA_real_
    )
  }

  #------ Add recoding columns
  hhs_comp_cols <- c ("hhs_comp1", "hhs_comp2", "hhs_comp3")

  #------ Recoding for component and follow-ups
  df <- dplyr::mutate(
    df,
    hhs_comp1 = hhs_recoding({{ hhs_lev1_nofoodhh }}, {{ hhs_lev2_nofoodhh }}, level1_codes, level2_codes),
    hhs_comp2 = hhs_recoding({{ hhs_lev1_sleephungry }}, {{ hhs_lev2_sleephungry }}, level1_codes, level2_codes),
    hhs_comp3 = hhs_recoding({{ hhs_lev1_alldaynight }}, {{ hhs_lev2_alldaynight }}, level1_codes, level2_codes)
    )

  #------  HHS score
  df <- dplyr::mutate(
    df,
    hhs_score = rowSums(
      dplyr::across(
        dplyr::all_of(hhs_comp_cols)
      ),
      na.rm = FALSE
    )
  )

  #------ HHS category
  df <- dplyr::mutate(
    df,
    hhs_cat = dplyr::case_when(
      hhs_score == 0 ~ "None",
      hhs_score <= 1 ~ "Little",
      hhs_score <= 3 ~ "Moderate",
      hhs_score <= 4 ~ "Severe",
      hhs_score <= 6 ~ "Very Severe",
      TRUE ~ NA_character_
    )
  )

  return(df)
}
