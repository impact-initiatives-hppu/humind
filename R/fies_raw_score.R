#' FIES - Food Insecurity Experience Scale analysis
#'
#' `fies_raw_score()` calculates the raw score of the FIES. For parameter estimates and assessment statistics with a Rasch model thanks to package `RM.weights`, see `impactR.analysis::fies_estimates()` (under construction).
#'
#' @param df A data frame
#' @param fies_worried Component column: Worried about not having enough food to eat.
#' @param fies_healthy Component column: Unable to eat healthy or nutritious food.
#' @param fies_fewfoods Component column: Ate only a few kinds of foods.
#' @param fies_skipped Component column: Skip a meal.
#' @param fies_ateless Component column: Ate less than thought to should.
#' @param fies_ranout Component column: Ran out of food.
#' @param fies_hungry Component column: Hungry without eating.
#' @param fies_wholeday Component column: No eating for a whole day.
#' @param level_codes Character vector of responses codes, including first in the following order: "Yes", "No", "Do not know", "Prefer not to answer", e.g., c("yes", "no", "do_not_know", "prefer_not_to_answer")

#'
#' @return Nine new columns: each component dummy variable if "Yes" (fies_*_d) and FIES raw score (fiew_raw_score).
#'
#' @details THe recall period can be different (30 days or 12 months) depending on the research's objectives (food insecurity or population monitoring for instance).
#'
#' @export
fies_raw_score <- function(df,
                           fies_worried = "fies_worried",
                           fies_healthy = "fies_healthy",
                           fies_fewfoods = "fies_fewfoods",
                           fies_skipped = "fies_skipped",
                           fies_ateless = "fies_ateless",
                           fies_ranout = "fies_ranout",
                           fies_hungry = "fies_hungry",
                           fies_wholeday = "fies_wholeday",
                           level_codes = c("yes", "no" ,"do_not_know", "prefer_not_to_answer")) {

  #------ Enquo and get character names
  fies_cols <- rlang::enquos(fies_worried, fies_healthy, fies_fewfoods, fies_skipped, fies_ateless, fies_ranout, fies_hungry, fies_wholeday)
  fies_cols <- purrr::map_chr(fies_cols, rlang::as_name)
  fies_cols_d <- paste0(fies_cols, "_d")

  #------ Check values ranges and numeric type
  are_values_in_set(df, fies_cols, level_codes)

  #------ Add dummy columns
  df <- dplyr::mutate(
    df,
    dplyr::across(
      .cols = fies_cols,
      .fns = \(x) ifelse(x == level_codes[1], 1, 0),
      .names = "{.col}_d"))

  #------ FIES raw score
  df <- dplyr::mutate(
    df,
    fies_raw_score = rowSums(
      dplyr::across(
        dplyr::all_of(fies_cols_d)
      ),
      na.rm = FALSE
    )
  )

  return(df)
}
