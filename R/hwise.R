#' @title HWISE scores - Household Water Insecurity Experiences (HWISE) Scale
#'
#' @param df A data frame
#' @param hwise_worry Component column: Worry.
#' @param hwise_interrupt Component column: Interrupt.
#' @param hwise_clothes Component column: Clothes.
#' @param hwise_plans Component column: Plans.
#' @param hwise_food Component column: Food.
#' @param hwise_hands Component column: Hands.
#' @param hwise_body Component column: Body.
#' @param hwise_drink Component column: Drink.
#' @param hwise_angry Component column: Angry.
#' @param hwise_sleep Component column: Sleep.
#' @param hwise_none Component column: None.
#' @param hwise_shame Component column: Shame.
#' @param level_codes Character vector of responses codes, including first in the following order: "Never (0 times)", "Rarely (1–2 times)", "Sometimes (3–10 times)", "Often (11-20 times)", "Always (more than 20 times)", "Do not know", "Prefer not to answer", "Not applicable", e.g. c("never", "rarely", "sometimes", "often", "always", "do_not_know", "prefer_not_to_answer", "not_applicable").
#'
#' @importFrom rlang :=
#'
#' @return Sixteen new columns: each component score (hwise_score_*), the overall score (hwise_score), dummy for water insecurity (hwise_insecure), the broader categories (hwise_cat), the detailed categories (hwise_cat_details).
#'
#' @export
hwise <- function(df,
                  hwise_worry = "hwise_worry",
                  hwise_interrupt = "hwise_interrupt",
                  hwise_clothes = "hwise_clothes",
                  hwise_plans = "hwise_plans",
                  hwise_food = "hwise_food",
                  hwise_hands = "hwise_hands",
                  hwise_body = "hwise_body",
                  hwise_drink = "hwise_drink",
                  hwise_angry = "hwise_angry",
                  hwise_sleep = "hwise_sleep",
                  hwise_none = "hwise_none",
                  hwise_shame = "hwise_shame",
                  level_codes = c("never", "rarely", "sometimes", "often", "always", "do_not_know", "prefer_not_to_answer", "not_applicable")){

  #------ Enquos
  hwise_comp_cols <- rlang::enquos(
    hwise_worry, hwise_interrupt, hwise_clothes, hwise_plans, hwise_food, hwise_hands,
    hwise_body, hwise_drink, hwise_angry, hwise_sleep, hwise_none, hwise_shame)
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
  hwise_score_cols <- c("hwise_worry_score", "hwise_interrupt_score", "hwise_clothes_score", "hwise_plans_score", "hwise_food_score", "hwise_hands_score", "hwise_body_score", "hwise_drink_score", "hwise_angry_score", "hwise_sleep_score", "hwise_none_score", "hwise_shame_score")

  df <- dplyr::mutate(
    df,
    "{hwise_score_cols[1]}" := hwise_recoding({{ hwise_worry }}),
    "{hwise_score_cols[2]}" := hwise_recoding({{ hwise_interrupt }}),
    "{hwise_score_cols[3]}" := hwise_recoding({{ hwise_clothes }}),
    "{hwise_score_cols[4]}" := hwise_recoding({{ hwise_plans }}),
    "{hwise_score_cols[5]}" := hwise_recoding({{ hwise_food }}),
    "{hwise_score_cols[6]}" := hwise_recoding({{ hwise_hands }}),
    "{hwise_score_cols[7]}" := hwise_recoding({{ hwise_body }}),
    "{hwise_score_cols[8]}" := hwise_recoding({{ hwise_drink }}),
    "{hwise_score_cols[9]}" := hwise_recoding({{ hwise_angry }}),
    "{hwise_score_cols[10]}" := hwise_recoding({{ hwise_sleep }}),
    "{hwise_score_cols[11]}" := hwise_recoding({{ hwise_none }}),
    "{hwise_score_cols[12]}" := hwise_recoding({{ hwise_shame }})
    )

  #------ HWISE overall score
  df <- dplyr::mutate(
    df,
    "hwise_score" =  rowSums(dplyr::across(dplyr::all_of(hwise_score_cols)), na.rm = FALSE))

  #------ HWISE overall thresholds
  df <- dplyr::mutate(
    df,
    "hwise_insecure" :=
      dplyr::case_when(
        hwise_score >= 12 ~ 1,
        hwise_score >= 0 ~ 0,
        .default = NA_real_),
    "hwise_cat" := dplyr::case_when(
      hwise_score >= 12 ~ "Water secure",
      hwise_score >= 0 ~ "Water insecure",
      .default = NA_character_
    ),
    "hwise_cat_details" := dplyr::case_when(
      hwise_score >= 20 ~ "20 and higher",
      hwise_score >= 16 ~ "16 to 19",
      hwise_score >= 12 ~ "12 to 15",
      hwise_score >= 8 ~ "8 to 11",
      hwise_score >= 4 ~ "4 to 7",
      hwise_score >= 0 ~ "0 to 3",
      .default = NA_character_
    ))


}
