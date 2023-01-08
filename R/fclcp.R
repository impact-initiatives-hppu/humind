#' @title FEWS NET Food Consumption-Livelihood Coping Phase
#'
#' @param df A data frame.
#' @param fcp The food consumption phase column.
#' @param lcsi_cat The Livelihood Coping Strategies categories column.
#' @param lcsi_levels LCSI levels in that order: "None", "Stress", "Crisis", "Emergency.
#'
#' @return Two new columns with the FEWS NET Food Consumption-Livelihood Coping matrix phases: numbers (fclp) and categories (fclp_cat).
#'
#' @export
fclcp <- function(df,
                  fcp,
                  lcsi_cat,
                  lcsi_levels = c("None", "Stress", "Crisis", "Emergency")){

  #------ Checks for levels
  fcp_col <- rlang::as_name(rlang::enquo(fcp))
  are_values_in_set(df, fcp_col, 1:5)

  lcsi_cat_col <- rlang::as_name(rlang::enquo(lcsi_cat))
  are_values_in_set(df, lcsi_cat_col, lcsi_levels)

  #------ Add fclp score
  df <- dplyr::mutate(
    df,
    fclcp = dplyr::case_when(
      {{ fcp }} == 1 & {{ lcsi_cat }} == lcsi_levels[1] ~ 1,
      {{ fcp }} == 1 & {{ lcsi_cat }} == lcsi_levels[2] ~ 1,
      {{ fcp }} == 1 & {{ lcsi_cat }} == lcsi_levels[3] ~ 2,
      {{ fcp }} == 1 & {{ lcsi_cat }} == lcsi_levels[4] ~ 3,
      {{ fcp }} == 2 & {{ lcsi_cat }} == lcsi_levels[1] ~ 2,
      {{ fcp }} == 2 & {{ lcsi_cat }} == lcsi_levels[2] ~ 2,
      {{ fcp }} == 2 & {{ lcsi_cat }} == lcsi_levels[3] ~ 3,
      {{ fcp }} == 2 & {{ lcsi_cat }} == lcsi_levels[4] ~ 3,
      {{ fcp }} == 3 & {{ lcsi_cat }} == lcsi_levels[1] ~ 3,
      {{ fcp }} == 3 & {{ lcsi_cat }} == lcsi_levels[2] ~ 3,
      {{ fcp }} == 3 & {{ lcsi_cat }} == lcsi_levels[3] ~ 3,
      {{ fcp }} == 3 & {{ lcsi_cat }} == lcsi_levels[4] ~ 4,
      {{ fcp }} == 4 & {{ lcsi_cat }} == lcsi_levels[1] ~ 4,
      {{ fcp }} == 4 & {{ lcsi_cat }} == lcsi_levels[2] ~ 4,
      {{ fcp }} == 4 & {{ lcsi_cat }} == lcsi_levels[3] ~ 4,
      {{ fcp }} == 4 & {{ lcsi_cat }} == lcsi_levels[4] ~ 4,
      {{ fcp }} == 5 ~ 5,
      TRUE ~ NA_real_
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
      TRUE ~ NA_character_
    ))

  return(df)
}
