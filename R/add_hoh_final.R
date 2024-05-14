#' Head of household final values (from respondent skip logic)
#'
#' This function takes a dataframe and several variables related to household (hoh) and respondent (resp) information.
#' It checks if the values in the 'hoh_yn' column are in the specified 'hoh_yn_codes' set.
#' If the value is 'yes' in the 'hoh_yn' column (hoh_yn_codes[1]), it replaces the 'hoh_gender' and 'hoh_age' columns with the corresponding values.
#' If the value is 'no' in the 'hoh_yn' column, it replaces the 'hoh_gender' and 'hoh_age' columns with the 'resp_gender' and 'resp_age' columns, respectively.
#' The function returns the modified dataframe.
#'
#' @param df The input dataframe.
#' @param resp_hoh_yn The column name for whether the respondent is the head of household (hoh) yes/no indicator.
#' @param yes The value for 'yes' in the 'resp_hoh_yn' column.
#' @param no The value for 'no' in the 'resp_hoh_yn' column.
#' @param hoh_gender The column name for the household (hoh) gender.
#' @param hoh_age The column name for the household (hoh) age.
#' @param resp_gender The column name for the respondent (resp) gender.
#' @param resp_age The column name for the respondent (resp) age.
#'
#' @return The modified dataframe with updated hoh_gender and hoh_age columns.
#'
#' @export
add_hoh_final <- function(df, resp_hoh_yn = "resp_hoh_yn", yes = "yes", no = "no", hoh_gender = "hoh_gender", hoh_age = "hoh_age", resp_gender = "resp_gender", resp_age = "resp_age"){

  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(df, c(resp_hoh_yn, hoh_gender, hoh_age, resp_gender, resp_age), "df")

  # Are values in set, hoh_yn in hoh_yn_codes
  are_values_in_set(df, resp_hoh_yn, c(yes, no))

  #------ Compute

  # if hoh is yes, then hoh gender and age, else resp gender and age
  df <- dplyr::mutate(
    df,
    hoh_gender = dplyr::case_when(
      !!rlang::sym(resp_hoh_yn) %in% yes ~ !!rlang::sym(resp_gender),
      !!rlang::sym(resp_hoh_yn) %in% no ~ !!rlang::sym(hoh_gender),
      .default = NA_character_
    ),
    hoh_age = dplyr::case_when(
      !!rlang::sym(resp_hoh_yn) %in% yes  ~ !!rlang::sym(resp_age),
      !!rlang::sym(resp_hoh_yn) %in% no ~ !!rlang::sym(hoh_age),
      .default = NA_real_
    )
  )

  return(df)
}
