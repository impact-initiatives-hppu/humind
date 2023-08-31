#' @title FEWS NET Food Consumption-Livelihood Coping Phase
#'
#' @param df A data frame.
#' @param fcp The food consumption phase column.
#' @param lcsi_cat_no_exhaustion The Livelihood Coping Strategies categories column without the exhaustion of strategies.
#' @param lcsi_levels LCSI levels in that order: "None", "Stress", "Crisis", "Emergency.
#'
#' @details `lcsi_cat_no_exhaustion` must be the categories column that was calculated without using the exhaustion of strategies choices when aggregating. See `lcsi()` and argument `with_exhaustion`. For calculation, see page 13 of the Fews Net matrix guidance available here: https://fews.net/sites/default/files/documents/reports/fews-net-matrix-guidance-document.pdf.
#'
#' @return Two new columns with the FEWS NET Food Consumption-Livelihood Coping matrix phases: numbers (fclp) and categories (fclp_cat).
#'
#' @export
fclcp <- function(df,
                  fcp = "fcp",
                  lcsi_cat_no_exhaustion = "lcsi_cat_no_exhaustion",
                  lcsi_levels = c("None", "Stress", "Crisis", "Emergency")){

  #------ Checks for levels
  fcp_col <- rlang::as_name(rlang::enquo(fcp))
  are_values_in_set(df, fcp_col, 1:5)

  lcsi_cat_col <- rlang::as_name(rlang::enquo(lcsi_cat_no_exhaustion))
  are_values_in_set(df, lcsi_cat_col, lcsi_levels)

  #------ Add fclp score
  df <- dplyr::mutate(
    df,
    fclcp = dplyr::case_when(
      {{ fcp }} == 1 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[1] ~ 1,
      {{ fcp }} == 1 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[2] ~ 1,
      {{ fcp }} == 1 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[3] ~ 2,
      {{ fcp }} == 1 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[4] ~ 3,
      {{ fcp }} == 2 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[1] ~ 2,
      {{ fcp }} == 2 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[2] ~ 2,
      {{ fcp }} == 2 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[3] ~ 3,
      {{ fcp }} == 2 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[4] ~ 3,
      {{ fcp }} == 3 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[1] ~ 3,
      {{ fcp }} == 3 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[2] ~ 3,
      {{ fcp }} == 3 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[3] ~ 3,
      {{ fcp }} == 3 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[4] ~ 4,
      {{ fcp }} == 4 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[1] ~ 4,
      {{ fcp }} == 4 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[2] ~ 4,
      {{ fcp }} == 4 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[3] ~ 4,
      {{ fcp }} == 4 & {{ lcsi_cat_no_exhaustion }} == lcsi_levels[4] ~ 4,
      {{ fcp }} == 5 ~ 5,
      .default = NA_real_
    ))

  #------ Add fcp phase
  df <- dplyr::mutate(
    df,
    fclcp_cat = dplyr::case_when(
      fclcp == 1 ~ "Phase 1 FCLC",
      fclcp == 2 ~ "Phase 2 FCLC",
      fclcp == 3 ~ "Phase 3 FClC",
      fclcp == 4 ~ "Phase 4 FClC",
      fclcp == 5 ~ "Phase 5 FClC",
      .default = NA_character_
    ))

  return(df)
}
