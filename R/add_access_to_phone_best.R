#' Access to phone and coverage
#'
#' [add_access_to_phone] recodes the best type of phone accessible in the household. [add_access_to_phone_coverage()] recodes the coverage network type and the best type of phone owned in the household.
#' @param df The input data frame
#' @param access_to_phone The name of the column that contains the access to phone information.
#' @param none The value for no phone.
#' @param smartphone The value for smartphone.
#' @param feature_phone The value for feature phone.
#' @param basic_phone The value for basic phone.
#' @param dnk The value for do not know.
#' @param pnta The value for prefer not to answer.
#' @param other The value for other.
#' @param sep Separator for the binary columns.
#'
#' @export
add_access_to_phone_best <- function(
    df,
    access_to_phone = "etc_access_to_phone",
    none = "none",
    smartphone = "smartphone",
    feature_phone = "feature_phone",
    basic_phone = "basic_phone",
    dnk = "dnk",
    pnta = "pnta",
    other = "other",
    sep = "/"
    ){

  #------ Checks

  # Check if col_access is present in dataframe
  if_not_in_stop(df, access_to_phone, "df")

  # Prep choices
  access_to_phone_d_smartphone <- paste0(access_to_phone, sep, smartphone)
  access_to_phone_d_feature_phone <- paste0(access_to_phone, sep, feature_phone)
  access_to_phone_d_basic_phone <- paste0(access_to_phone, sep, basic_phone)
  access_to_phone_d_none <- paste0(access_to_phone, sep, none)
  access_to_phone_d_dnk <- paste0(access_to_phone, sep, dnk)
  access_to_phone_d_pnta <- paste0(access_to_phone, sep, pnta)
  access_to_phone_d_other <- paste0(access_to_phone, sep, other)

  # All cols
  access_to_phone_d_vars <- c(access_to_phone_d_smartphone, access_to_phone_d_feature_phone, access_to_phone_d_basic_phone, access_to_phone_d_none, access_to_phone_d_dnk, access_to_phone_d_pnta, access_to_phone_d_other)

  # Check if columns are in the dataset
  if_not_in_stop(df, access_to_phone_d_vars, "df")

  # Check that columns are in set 0:1
  are_values_in_set(df, access_to_phone_d_vars, c(0, 1))

  #------ Recode

  df <- df %>%
    mutate(
      etc_access_to_phone_best = case_when(
        !!sym(access_to_phone_d_smartphone) == 1 ~ "smartphone"
        !!sym(access_to_phone_d_feature_phone) == 1 ~ "feature_phone",
        !!sym(access_to_phone_d_basic_phone) == 1 ~ "basic_phone",
        !!sym(access_to_phone_d_none) == 1 ~ "none",
        !!sym(access_to_phone_d_dnk) == 1 ~ "undefined",
        !!sym(access_to_phone_d_pnta) == 1 ~ "undefined",
        !!sym(access_to_phone_d_other) == 1 ~ "undefined"
        .default = NA_character_
      )
    )

  return(df)
}

#' @rdname add_access_to_phone_best
#'
#' @param coverage_internet Network coverage column.
#' @param coverage_none Value for no coverage.
#' @param coverage_no_internet Vector of values for no internet.
#' @param coverage_internet Value for internet.
#'
#'
#' @export
add_access_to_phone_coverage <- function(
    df,
    coverage_internet = "etc_coverage_internet",
    coverage_none = "no_coverage",
    coverage_no_internet=c("only_sms", "voice_no_internet"),
    coverage_internet="internet",
    coverage_undefined = c("dnk", "pnta", "other"),
    access_to_phone_best = "etc_access_to_phone_best",
    access_to_phone_none = "none",
    access_to_basic_phone = "basic_phone",
    access_to_feature_phone = "feature_phone",
    access_to_smartphone = "smartphone",
    access_to_undefined = "undefined"
){

  #------ Checks

  # Check if col_coverage_internet and col_access are present in dataframe
  if_not_in_stop(df, coverage_internet, "df")
  if_not_in_stop(df, access_to_phone_best, "df")

  # Check that coverage_none, and all access_ are of length 1
  if (length(coverage_none) != 1) rlang::abort("coverage_none must be of length 1")
  if (length(access_to_phone_none) != 1) rlang::abort("access_to_phone_none must be of length 1")
  if (length(access_to_basic_phone) != 1) rlang::abort("access_to_basic_phone must be of length 1")
  if (length(access_to_feature_phone) != 1) rlang::abort("access_to_feature_phone must be of length 1")
  if (length(access_to_smartphone) != 1) rlang::abort("access_to_smartphone must be of length 1")
  if (length(access_to_undefined) != 1) rlang::abort("access_to_undefined must be of length 1")

  # Check if all values are in set
  are_values_in_set(df, coverage_internet, c(coverage_none, coverage_no_internet, coverage_internet, coverage_undefined))
  are_values_in_set(df, access_to_phone_best, c(access_to_phone_none, accss_to_basic_phone, access_to_feature_phone, access_to_smartphone, access_to_undefined))

df <- dplyr::mutate(
  df,
  etc_acess_to_phone_coverage = dplyr::case_when(
    # no_coverage_or_phone
    !!rlang::sym(coverage_internet) %in% coverage_none | !!rlang::sym(access_to_phone_best) %in% access_to_phone_none ~ "no_coverage_or_no_phone",
    # no_internet_or_basic_phone
    !!rlang::sym(coverage_internet) %in% coverage_no_internet | !!rlang::sym(access_to_phone_best) %in% c(access_to_basic_phone) ~ "no_internet_or_basic_phone",
    # internet_feature_phone
    !!rlang::sym(coverage_internet) %in% coverage_internet & !!rlang::sym(access_to_phone_best) %in% c(access_to_feature_phone) ~ "internet_feature_phone",
    # internet_smartphone
    !!rlang::sym(coverage_internet) %in% coverage_internet & !!rlang::sym(access_to_phone_best) %in% c(access_to_smartphone) ~ "internet_smartphone",
    # undefined
    (!!rlang::sym(coverage_internet) %in% c(coverage_undefined)) | (!!rlang::sym(access_to_phone_best) %in% c(access_to_undefined)) ~ "undefined",
      .default = NA_character_)
  )

  return(df)
}
