#' @title HWISE scores - Brief Household Water Insecurity Experiences (HWISE-4) Scale
#'
#' @param df A data frame
#' @param hwise_worry Component column: Worry
#' @param hwise_plans Component column: Plans
#' @param hwise_hands Component column: Hands
#' @param hwise_drink Component column: Drink
#' @param level_codes Character vector of responses codes, including first in the following order: "Never (0 times)", "Rarely (1–2 times)", "Sometimes (3–10 times)", "Often (11-20 times)", "Always (more than 20 times)", "Do not know", "Prefer not to answer", "Not applicable", e.g. c("never", "rarely", "sometimes", "often", "always", "do_not_now", "prefer_not_to_answer", "not_applicable")
#'
#' @return Eight new columns: each component score (hwise_brief_score_*), the overall score (hwise_brief_score), dummy for water insecurity (hwise_brief_insecure), the broader categories (hwise_brief_cat), the detailed categories (hwise_cat_details).
#'
#' @importFrom rlang `:=`
#'
#' @export
hwise_brief <- function(df, hwise_worry, hwise_plans, hwise_hands, hwise_drink, level_codes){

  #------ Enquos
  hwise_comp_cols <- rlang::enquos(hwise_worry, hwise_plans, hwise_hands, hwise_drink)
  hwise_comp_cols <- purrr::map_chr(hwise_comp_cols, rlang::as_name)

  #------ Are level1_codes and level2_codes in set
  are_values_in_set(df, hwise_comp_cols, level_codes)

  hwise_recoding <- - function(var, level_codes){

    dplyr::case_when(
      {{ var }} %in% level_codes[1] ~ 0,
      {{ var }} %in% level_codes[2] ~ 1,
      {{ var }} %in% level_codes[3] ~ 2,
      {{ var }} %in% level_codes[4:5] ~ 3,
      .default = NA_real_)
  }

  # Prepare column names
  hwise_score_cols <- c("hwise_brief_worry_score", "hwise_brief_plans_score", "hwise_brief_hands_score", "hwise_brief_drink_score")

  df <- dplyr::mutate(
    df,
    "{hwise_score_cols[1]}" := hwise_recoding({{ hwise_worry }}),
    "{hwise_score_cols[2]}" := hwise_recoding({{ hwise_plans }}),
    "{hwise_score_cols[3]}" := hwise_recoding({{ hwise_hands }}),
    "{hwise_score_cols[4]}" := hwise_recoding({{ hwise_drink }})
  )

  #------ HWISE overall score
  df <- dplyr::mutate(
    df,
    "hwise_brief_score" =  rowSums(dplyr::across(dplyr::all_of(hwise_score_cols)), na.rm = FALSE))

  #------ HWISE overall thresholds
  df <- dplyr::mutate(
    df,
    "hwise_brief_insecure" := dplyr::case_when(
      hwise_brief_score >= 4 ~ 1,
      hwise_brief_score >= 0 ~ 0,
      .default = NA_real_),
    "hwise_brief_cat" := dplyr::case_when(
      hwise_brief_score >= 4 ~ "Water secure",
      hwise_brief_score >= 0 ~ "Water insecure",
      .default = NA_character_
    ),
    "hwise_brief_details" := dplyr::case_when(
      hwise_brief_score >= 10 ~ "10 to 12",
      hwise_brief_score >= 7 ~ "7 to 9",
      hwise_brief_score >= 4 ~ "4 to 6",
      hwise_brief_score >= 0 ~ "0 to 3",
      .default = NA_character_
    ))


}
