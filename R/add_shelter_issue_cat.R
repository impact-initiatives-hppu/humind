#' Add the number of shelter issues and related category
#'
#' @param df A data frame.
#' @param shelter_issue Component column: Shelter issues.
#' @param none Response code for no issue.
#' @param issues Character vector of issues.
#' @param undefined Character vector of undefined responses codes (e.g. "Prefer not to answer").
#' @param sep Separator for the binary columns.
#'
#'@export
add_shelter_issue_cat <- function(
    df,
    shelter_issue = "snfi_shelter_issue",
    none = "none",
    issues = c("lack_privacy", "lack_space", "temperature", "ventilation", "leak", "lock", "lack_lighting", "difficulty_move"),
    undefined = c("dnk", "pnta", "other"),
    sep = "/"){

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, shelter_issue, "df")

  # Prep choices
  shelter_issue_d_issues <- paste0(shelter_issue, sep, issues)
  shelter_issue_d_undefined <- paste0(shelter_issue, sep, undefined)
  shelter_issue_d_none <- paste0(shelter_issue, sep, none)

  # Check if columns are in the dataset
  if_not_in_stop(df, c(shelter_issue_d_issues, shelter_issue_d_undefined, shelter_issue_d_none), "df")

  # Check that colimns are in set 0:1
  are_values_in_set(df, c(shelter_issue_d_issues, shelter_issue_d_undefined, shelter_issue_d_none), c(0, 1))


  # Check that none is of length 1
  if (length(none) != 1) rlang::abort("none must be of length 1")

  #------ Recode

  # Sum vars across issues
  df <- sum_vars(
    df,
    new_colname = "snfi_shelter_issue_n",
    vars = shelter_issue_d_issues,
    na_rm = FALSE,
    imputation = "none"
  )

  # Add "none" and "undefined" information
  df <- dplyr::mutate(
    df,
    snfi_shelter_issue_n = dplyr::case_when(
      dplyr::if_any(shelter_issue_d_undefined, \(x) x == 1) ~ -999,
      !!rlang::sym(shelter_issue_d_none) == 1 ~ 0,
      .default = !!rlang::sym("snfi_shelter_issue_n")
    )
  )

  # Add final recoding
  df <- dplyr::mutate(
    df,
    snfi_shelter_issue_cat = dplyr::case_when(
      snfi_shelter_issue_n == 0 ~ "none",
      snfi_shelter_issue_n == -999 ~ "undefined",
      snfi_shelter_issue_n <= 3 ~ "1_to_3",
      snfi_shelter_issue_n <= 6 ~ "4_to_6",
      snfi_shelter_issue_n <= 8 ~ "7_to_8",
      .default = NA_character_
    )
    )

  return(df)

}
