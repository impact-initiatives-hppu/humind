
## Access to phone, by best type of phone accessible in the HH  ----------------
#' @title Access to phone, by best type of phone accessible in the HH
#' @description This function creates a new variable that indicates the best type of phone accessible in the HH.
#' @param df The input data frame
#' @param col_access The name of the column that contains the access to phone information. It should have only four possible values according to MSNA indicator bank: "smartphone", "feature_phone", "basic_phone" and "none", alongside "dnk", "pnta"
#' @return The data frame with the new variable

etc_access_phone_best <- function(
    df = main,
    choice_smartphone = "smartphone",
    choice_feature_phone = "feature_phone",
    choice_basic_phone = "basic_phone",
    choice_none = "none",
    choice_dnk = "dnk",
    choice_pnta = "pnta",
    col_access = "etc_access_to_phone"){
  
  # Check if col_access is present in dataframe
  if_not_in_stop(df, col_access, "df")
  
  # Check if all values are in set
  are_values_in_set(df, col_access, c(choice_smartphone, choice_feature_phone, choice_basic_phone, choice_none, choice_dnk, choice_pnta))
  
  df <- df %>%
    mutate(etc_access_to_phone_select_one = case_when(
      str_detect(!!sym(col_access), choice_smartphone) ~ choice_smartphone,
      str_detect(!!sym(col_access), choice_feature_phone) ~ choice_feature_phone,
      str_detect(!!sym(col_access), choice_basic_phone) ~ choice_basic_phone,
      str_detect(!!sym(col_access), choice_none) ~ choice_none,
      !!sym(col_access) == choice_dnk ~ choice_dnk,
      !!sym(col_access) == choice_pnta ~ choice_pnta,
      TRUE ~ NA_character_
    ))
  
  return(df)
}

## Network coverage and phone owned in HH combined  ----------------------
#' @title function to recode coverage network type and phone owned in HH combined
#' @description This function creates a new variable that indicates the type of network coverage and phone owned in HH combined.
#' @param df The input data frame
#' @param col_coverage_internet The name of the column that contains the coverage network type information. It should have only four possible values according to MSNA indicator bank: "only_internet", "voice_sms_internet", "only_voice", "only_sms", "no_coverage" and "dnk"
#' @param choice_no_coverage The choice value that indicates that no coverage was available.
#' @param choice_no_internet The choice value that indicates that no internet was available.
#' @param choice_internet The choice value that indicates that internet was available.
#' @param col_access The name of the column that contains the access to phone information. It should have only four possible values according to MSNA indicator bank: "smartphone", "feature_phone", "basic_phone" and "none", alongside "dnk", "pnta"
#' @param choice_no_phone The choice value that indicates that no phone was available.
#' @param choice_basic_phone The choice value that indicates that a basic phone was available.
#' @param choice_feature_phone The choice value that indicates that a feature phone was available.
#' @param choice_smartphone The choice value that indicates that a smartphone was available.
#' @param choice_dnk The choice value that indicates that the person does not know.
#' @param choice_pnta The choice value that indicates that the person prefers not to answer.
#' @return The data frame with the new variable
#' 
etc_no_coverage_or_phone <- function(df=main, 
                                     col_coverage_internet="etc_coverage_internet",
                                     choice_no_coverage="no_coverage",
                                     choice_no_internet=c("only_sms", "voice_no_internet"),
                                     choice_internet="internet",
                                     col_access="etc_access_to_phone_select_one",
                                     choice_no_phone="none",
                                     choice_basic_phone="basic_phone",
                                     choice_feature_phone="feature_phone",
                                     choice_smartphone="smartphone",
                                     choice_dnk = "dnk",
                                     choice_pnta = "pnta"
){
  
  # Check if col_coverage_internet and col_access are present in dataframe
  if_not_in_stop(df, col_coverage_internet, "df")
  if_not_in_stop(df, col_access, "df")
  
  # Check if all values are in set
  are_values_in_set(df, col_coverage_internet, c(choice_no_coverage, choice_no_internet, choice_internet, choice_dnk, choice_pnta)))
are_values_in_set(df, col_access, c(choice_no_phone, choice_basic_phone, choice_feature_phone, choice_smartphone, choice_dnk, choice_pnta))

df <- df %>%
  mutate(
    etc_coverage_phone_combined = case_when(
      !!sym(col_coverage_internet) %in% choice_no_coverage | !!sym(col_access) %in% choice_no_phone ~ "no_coverage_or_phone",
      !!sym(col_coverage_internet) %in% choice_no_internet | !!sym(col_access) %in% c(choice_basic_phone) ~ "no_internet_or_basic_phone",
      !!sym(col_coverage_internet) %in% choice_internet & !!sym(col_access) %in% c(choice_feature_phone) ~ "internet_feature_phone",
      !!sym(col_coverage_internet) %in% choice_internet & !!sym(col_access) %in% c(choice_smartphone) ~ "internet_smartphone",
      (!!sym(col_coverage_internet) %in% c(choice_dnk, choice_pnta)) | (!!sym(col_access) %in% c(choice_dnk, choice_pnta)) ~ "undefined",
      TRUE ~ NA_character_)
  )

return(df)
}