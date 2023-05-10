#' @title FEWS NET Food Consumption Matrix cell
#'
#' @param df A data frame.
#' @param fcs_cat Food Consumption Score column.
#' @param fcs_levels Food Consumption Score categories - in that order: "Poor", "Borderline", and "Acceptable".
#' @param hhs_cat Household Hunger Scale column.
#' @param hhs_levels Household Hunger Scale categories - in that order: "None", "Little", "Moderate", "Severe", and "Very severe".
#' @param rcsi_cat reduced Coping Strategies Index column.
#' @param rcsi_levels reduced Coping Strategies Index categories - in that order: "No to Low", "Medium", and "Severe".
#'
#' @return The FEWS NET Food Consumption Cell number.
#'
#' @export
fcm_cell <- function(df,
                     fcs_cat = "fcs_cat",
                     fcs_levels = c("Acceptable", "Borderline", "Poor"),
                     hhs_cat = "hhs_cat",
                     hhs_levels = c("None", "Little", "Moderate", "Severe", "Very severe"),
                     rcsi_cat = "rcsi_cat",
                     rcsi_levels = c("No to Low", "Medium", "Severe")){

  #------ Checks for levels
  fcs_cat_col <- rlang::as_name(rlang::enquo(fcs_cat))
  are_values_in_set(df, fcs_cat_col, fcs_levels)

  hhs_cat_col <- rlang::as_name(rlang::enquo(hhs_cat))
  are_values_in_set(df, hhs_cat_col, hhs_levels)

  rcsi_cat_col <- rlang::as_name(rlang::enquo(rcsi_cat))
  are_values_in_set(df, rcsi_cat_col, rcsi_levels)


  df <- dplyr::mutate(
    df,
    fcm_cell = dplyr::case_when(
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[1] ~ 1,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[1] ~ 2,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[1] ~ 3,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[1] ~ 4,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[1] ~ 5,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[1] ~ 6,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[1] ~ 7,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[1] ~ 8,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[1] ~ 9,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[1] ~ 10,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[1] ~ 11,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[1] ~ 12,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[1] ~ 13,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[1] ~ 14,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[1] ~ 15,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[2] ~ 16,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[2] ~ 17,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[2] ~ 18,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[2] ~ 19,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[2] ~ 20,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[2] ~ 21,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[2] ~ 22,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[2] ~ 23,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[2] ~ 24,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[2] ~ 25,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[2] ~ 26,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[2] ~ 27,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[2] ~ 28,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[2] ~ 29,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[2] ~ 30,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[3] ~ 31,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[3] ~ 32,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[3] ~ 33,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[3] ~ 34,
      {{ fcs_cat }} == fcs_levels[1] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[3] ~ 35,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[3] ~ 36,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[3] ~ 37,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[3] ~ 38,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[3] ~ 39,
      {{ fcs_cat }} == fcs_levels[2] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[3] ~ 40,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[1] & {{ rcsi_cat }} == rcsi_levels[3] ~ 41,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[2] & {{ rcsi_cat }} == rcsi_levels[3] ~ 42,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[3] & {{ rcsi_cat }} == rcsi_levels[3] ~ 43,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[4] & {{ rcsi_cat }} == rcsi_levels[3] ~ 44,
      {{ fcs_cat }} == fcs_levels[3] & {{ hhs_cat }} == hhs_levels[5] & {{ rcsi_cat }} == rcsi_levels[3] ~ 45,
      .default = NA_real_
    ))

  return(df)

}
