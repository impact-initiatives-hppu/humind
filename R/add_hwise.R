#' @title Add Household Water Insecurity Experiences (HWISE) Score
#'
#' @description Recodes the four HWISE survey items (water quantity) to numeric
#'   scores, computes the total `hwise4_score` (0–12), and maps it to a WASH
#'   component score for water quantity (`comp_wash_score_water_quantity`, 1–5).
#'
#' @param .df A data frame containing the four HWISE columns.
#' @param wash_hwise_drink Column name for: *"In the last 4 weeks, how
#'   frequently has there NOT been as much water to drink as you would like for
#'   you or anyone in your household?"*
#' @param wash_hwise_hands Column name for: *"In the last 4 weeks, how
#'   frequently have you or anyone in your household had to go without washing
#'   hands after dirty activities (e.g., defecating or changing diapers,
#'   cleaning animal dung) because of problems with water?"*
#' @param wash_hwise_plans Column name for: *"In the last 4 weeks how often did
#'   you have to change schedules or plans because of problems with water?"*
#' @param wash_hwise_worry Column name for: *"In the last 4 weeks how often did
#'   you or anyone in your household worry that you would not have enough water
#'   for all of your needs?"*
#' @param hwise_never Response code for "Never (0 days)" (scored 0).
#' @param hwise_rarely Response code for "Rarely (1–2 days)" (scored 1).
#' @param hwise_sometimes Response code for "Some days (3–10 days)" (scored 2).
#' @param hwise_often Response code for "Often (11–20 days)" (scored 3).
#' @param hwise_always Response code for "Always (more than 20 days)" (scored 3).
#' @param hwise_dnk Response code for "Don't know" (scored NA).
#' @param hwise_pnta Response code for "Prefer not to answer" (scored NA).
#' @param na.rm Logical. If `TRUE`, `dnk`/`pnta` responses are treated as 0
#'   when summing the total score. Default `FALSE`.
#'
#' @return `.df` with three new columns:
#'
#' * The four HWISE columns recoded to numeric scores (0–3, NA for dnk/pnta).
#' * `hwise4_score`: row sum of the four recoded columns (0–12).
#' * `comp_wash_score_water_quantity`: WASH severity score (1–5):
#'   1 = score 0–3, 2 = 4–6, 3 = 7–8, 4 = 9–10, 5 = 11+.
#'
#' @seealso [add_comp_wash()]
#'
#' @export
#'
#' @examples
#' df <- dplyr::tibble(
#'   wash_hwise_drink = c("never",     "sometimes", "often"),
#'   wash_hwise_hands = c("rarely",    "often",     "always"),
#'   wash_hwise_plans = c("sometimes", "often",     "always"),
#'   wash_hwise_worry = c("never",     "sometimes", "always")
#' )
#'
#' add_hwise(df)
add_hwise <- function(
  .df,
  wash_hwise_drink = "wash_hwise_drink",
  wash_hwise_hands = "wash_hwise_hands",
  wash_hwise_plans = "wash_hwise_plans",
  wash_hwise_worry = "wash_hwise_worry",
  hwise_never = "never",
  hwise_rarely = "rarely",
  hwise_sometimes = "sometimes",
  hwise_often = "often",
  hwise_always = "always",
  hwise_dnk = "dnk",
  hwise_pnta = "pnta",
  na.rm = FALSE
) {
  # Check variable presence in the data frame
  if_not_in_stop(
    .df,
    c(
      wash_hwise_drink,
      wash_hwise_hands,
      wash_hwise_plans,
      wash_hwise_worry
    ),
    ".df"
  )

  # Check answer options
  hwise_answer_options <- list(
    hwise_never,
    hwise_rarely,
    hwise_sometimes,
    hwise_often,
    hwise_always,
    hwise_dnk,
    hwise_pnta
  )

  all_scalar <- sapply(hwise_answer_options, checkmate::test_scalar)
  if (!all(all_scalar)) {
    cli::cli_abort("All of the {.arg hwise_*} parameters must be scalars")
  }
  all_character <- sapply(hwise_answer_options, checkmate::test_character)

  if (!all(all_character)) {
    cli::cli_abort(
      "All of the {.arg hwise_*} parameters must be of type character"
    )
  }

  hwise_mapping <- dplyr::tribble(
    ~from       , ~to ,
    "never"     ,   0 ,
    "rarely"    ,   1 ,
    "sometimes" ,   2 ,
    "often"     ,   3 ,
    "always"    ,   3 ,
    "dnk"       , NA  ,
    "pnta"      , NA
  )

  hwise_cols <- rlang::syms(
    c(wash_hwise_drink, wash_hwise_hands, wash_hwise_plans, wash_hwise_worry)
  )

  .df |>
    dplyr::mutate(
      dplyr::across(
        c(!!!hwise_cols),
        ~ dplyr::recode_values(
          .x,
          from = hwise_mapping$from,
          to = hwise_mapping$to
        )
      ),

      hwise4_score = rowSums(dplyr::pick(c(!!!hwise_cols)), na.rm = na.rm),
      comp_wash_score_water_quantity = dplyr::case_when(
        hwise4_score >= 11 ~ 5,
        hwise4_score >= 9 ~ 4,
        hwise4_score >= 7 ~ 3,
        hwise4_score >= 4 ~ 2,
        hwise4_score >= 0 ~ 1,
        .default = NA
      )
    )
}
