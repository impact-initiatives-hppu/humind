#' @title rCSI - reduced Coping Strategy Index
#'
#' @param df A data frame
#' @param rcsi_lesspreferred Component column: Rely on less preferred and less expensive food
#' @param rcsi_borrowfood Component column: Borrow food or rely on help from friends or relatives
#' @param rcsi_limitportion Component column: Limit portion size at mealtime
#' @param rcsi_restrict Component column: Restrict consumption by adults in order for small children to eat
#' @param rcsi_reducemeals Component column: Reduce the number of meals eaten in a day
#'
#' @return Seven new columns: each component weight (rcsi_w_*), rCSI score (rcsi_score) and categories (rcsi_cat).
#'
#' @export
rcsi <- function(df,
                 rcsi_lesspreferred = "rcsi_lesspreferred",
                 rcsi_borrowfood = "rcsi_borrowfood",
                 rcsi_limitportion = "rcsi_limitportion",
                 rcsi_restrict = "rcsi_restrict",
                 rcsi_reducemeals = "rcsi_reducemeals") {

  #------ Enquo and get character names
  rcsi_cols <- rlang::enquos(rcsi_lesspreferred, rcsi_borrowfood, rcsi_limitportion, rcsi_restrict, rcsi_reducemeals)
  rcsi_cols <- purrr::map_chr(rcsi_cols, rlang::as_name)

  #------ Check values ranges and numeric type
  are_values_in_set(df, rcsi_cols, 0:7)

  #------ Prepare vector of weighting values
  rcsi_w_cols <- c("rcsi_w_lesspreferred", "rcsi_w_borrowfood", "rcsi_w_limitportion", "rcsi_w_restrict", "rcsi_w_reducemeals")

  #------ Add weighting columns
  df <- dplyr::mutate(
    df,
    rcsi_w_lesspreferred = {{ rcsi_lesspreferred }} * 1,
    rcsi_w_borrowfood = {{ rcsi_borrowfood }} * 2,
    rcsi_w_limitportion = {{ rcsi_limitportion }} * 1,
    rcsi_w_restrict = {{ rcsi_restrict }} * 3,
    rcsi_w_reducemeals = {{ rcsi_reducemeals }} * 1
  )

  #------ rCSI score
  df <- dplyr::mutate(
    df,
    rcsi_score = rowSums(
      dplyr::across(
        dplyr::all_of(rcsi_w_cols)
      ),
      na.rm = FALSE
    )
  )

  #------ rCSI category
  df <- dplyr::mutate(
    df,
    rcsi_cat = dplyr::case_when(
      rcsi_score <= 3 ~ "No to Low",
      rcsi_score <= 18 ~ "Medium",
      rcsi_score <= 1000 ~ "Severe",
      .default = NA_character_
    )
  )

  return(df)
}
