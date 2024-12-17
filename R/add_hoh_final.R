#' @title Update Head of Household Information
#'
#' @description This function updates the head of household (HoH) gender and age information based on whether the respondent is the HoH or not.
#' If the respondent is the HoH, their gender and age are used; otherwise, the existing HoH information is retained.
#'
#' @param df The input dataframe.
#' @param resp_hoh_yn The column name for whether the respondent is the head of household (HoH) yes/no indicator.
#' @param yes The value for 'yes' in the 'resp_hoh_yn' column.
#' @param no The value for 'no' in the 'resp_hoh_yn' column.
#' @param hoh_gender The column name for the household (HoH) gender.
#' @param hoh_age The column name for the household (HoH) age.
#' @param resp_gender The column name for the respondent (resp) gender.
#' @param resp_age The column name for the respondent (resp) age.
#'
#' @return A modified dataframe with updated columns:
#' 
#' * hoh_gender: Updated head of household gender.
#' * hoh_age: Updated head of household age.
#'
#' @export
add_hoh_final <- function(df, resp_hoh_yn = "resp_hoh_yn", yes = "yes", no = "no", hoh_gender =  "hoh_gender", hoh_age = "hoh_age", resp_gender = "resp_gender", resp_age = "resp_age"){

  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(df, c(resp_hoh_yn, hoh_gender, hoh_age, resp_gender, resp_age), "df")

  # Are values in set, hoh_yn in hoh_yn_codes
  are_values_in_set(df, resp_hoh_yn, c(yes, no))

  # Check that age columns are numeric
  are_cols_numeric(df, c(hoh_age, resp_age))


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
