#' @title Add Household Water Insecurity Experiences (HWISE) Score
#'
#' @description Computes the total `hwise4_score` (0–12) from the four HWISE
#'   survey items (water quantity), and maps it to a WASH component score
#'   for water quantity (`comp_wash_score_water_quantity`, 1–5). The four
#'   items are internally recoded to numeric scores but are only exposed in
#'   the output (as `_score`-suffixed columns) when `.keep_recoded = TRUE`.
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
#' @param .keep_recoded Logical, whether to keep the recoded numeric HWISE
#'   columns (ending in `_score`) in the output data frame. Default is FALSE.
#'
#' @return `.df` with new columns:
#'
#' * The four HWISE columns recoded to numeric scores (0–3, NA for dnk/pnta),
#'   suffixed with `_score` (only kept in the output if `.keep_recoded = TRUE`).
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
#' result <- add_hwise(df)
#' dplyr::select(result, hwise4_score, comp_wash_score_water_quantity)
#'
#' # keep the per-item recoded scores (ending in `_score`)
#' result_recoded <- add_hwise(df, .keep_recoded = TRUE)
#' dplyr::select(result_recoded, dplyr::matches("_score$"))
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
  na.rm = FALSE,
  .keep_recoded = FALSE
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

  are_values_in_set(
    .df,
    c(wash_hwise_drink, wash_hwise_hands, wash_hwise_plans, wash_hwise_worry),
    c(
      hwise_never,
      hwise_rarely,
      hwise_sometimes,
      hwise_often,
      hwise_always,
      hwise_dnk,
      hwise_pnta
    )
  )

  hwise_mapping <- dplyr::tribble(
    ~from           , ~to      ,
    hwise_never     ,        0 ,
    hwise_rarely    ,        1 ,
    hwise_sometimes ,        2 ,
    hwise_often     ,        3 ,
    hwise_always    ,        3 ,
    hwise_dnk       , NA_real_ ,
    hwise_pnta      , NA_real_
  )

  hwise_col_names <- c(
    wash_hwise_drink,
    wash_hwise_hands,
    wash_hwise_plans,
    wash_hwise_worry
  )
  recoded_cols <- paste0(hwise_col_names, "_score")

  recoded_df <- .df |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(hwise_col_names),
        ~ dplyr::recode_values(
          .x,
          from = hwise_mapping$from,
          to = hwise_mapping$to
        ),
        .names = "{.col}_score"
      ),
      hwise4_score = rowSums(
        dplyr::pick(dplyr::all_of(recoded_cols)),
        na.rm = na.rm
      ),
      comp_wash_score_water_quantity = dplyr::case_when(
        hwise4_score >= 11 ~ 5,
        hwise4_score >= 9 ~ 4,
        hwise4_score >= 7 ~ 3,
        hwise4_score >= 4 ~ 2,
        hwise4_score >= 0 ~ 1,
        .default = NA
      )
    )

  # decide which new columns to bind back
  composite_cols <- c("hwise4_score", "comp_wash_score_water_quantity")
  new_cols <- if (.keep_recoded) {
    c(recoded_cols, composite_cols)
  } else {
    composite_cols
  }

  # bind and relocate
  dplyr::bind_cols(
    .df,
    dplyr::select(recoded_df, dplyr::all_of(new_cols))
  ) |>
    dplyr::relocate(
      dplyr::all_of(new_cols),
      .after = tail(hwise_col_names, 1)
    )
}
