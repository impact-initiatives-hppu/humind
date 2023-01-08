#' @title FC phase - Food Consumption phase according to the FCM
#'
#' @param df A data frame.
#' @param fcm_cell Food consumption matrix cell - 1 to 45.
#'
#' @return Two columns: the food consumption phase number (fcp) and the category (fcp_cat)
#'
#' @export
fcp <- function(df,
                fcm_cell = "fcm_cell"){

  #------ Checks for matrix cell
  fcm_cell_col <- rlang::as_name(rlang::enquo(fcm_cell))
  are_values_in_set(df, fcm_cell_col, 1:45)

  df <- dplyr::mutate(
    df,
    fcp = dplyr::case_when(
      {{ fcm_cell }} %in% c(1,6) ~ 1,
      {{ fcm_cell }} %in% c(2, 3, 7, 11, 12, 16, 17, 18, 21, 22, 26, 31, 32, 36) ~ 2,
      {{ fcm_cell }} %in% c(4, 5, 8, 9, 13, 19, 20, 23, 24, 27, 28, 33, 34, 37, 38, 41, 42, 43) ~ 3,
      {{ fcm_cell }} %in% c(10, 14, 15, 25, 29, 35, 39, 40, 44) ~ 4,
      {{ fcm_cell }} %in% c(30, 45) ~ 5,
      TRUE ~ NA_real_))

  df <- dplyr::mutate(
    df,
    fcp_cat = dplyr::case_when(
      fcp == 1 ~ "Phase 1 FC",
      fcp == 2 ~ "Phase 2 FC",
      fcp == 3 ~ "Phase 3 FC",
      fcp == 4 ~ "Phase 4 FC",
      fcp == 5 ~ "Phase 5 FC",
      TRUE ~ NA_character_
    ))

  return(df)
}
