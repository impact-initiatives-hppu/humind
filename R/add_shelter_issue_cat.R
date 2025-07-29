#' @title Add Number of Shelter Issues and Related Category
#'
#' @description This function calculates the number of shelter issues and categorizes them based on predefined thresholds. It also handles undefined and other responses.
#'
#' @param df A data frame containing shelter issue data.
#' @param shelter_issue Component column: Shelter issues.
#' @param none Response code for no issue.
#' @param issues Character vector of issues.
#' @param undefined Character vector of undefined responses codes (e.g. "Prefer not to answer").
#' @param other Character vector of other responses codes (e.g. "Other").
#' @param sep Separator for the binary columns.
#'
#' @return A data frame with additional columns:
#'
#' * snfi_shelter_issue_n: Count of shelter issues.
#' * snfi_shelter_issue_cat: Categorized shelter issues: "none", "undefined", "other", "1_to_3", "4_to_7", or "8_to_11".
#'
#' @export
add_shelter_issue_cat <- function(
  df,
  shelter_issue = "snfi_shelter_issue",
  none = "none",
  issues = c(
    "lack_privacy",
    "lack_space",
    "temperature",
    "ventilation",
    "vectors",
    "no_natural_light",
    "leak",
    "lock",
    "lack_lighting",
    "difficulty_move",
    "lack_space_laundry"
  ),
  undefined = c("dnk", "pnta"),
  other = c("other"),
  sep = "/"
) {
  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, shelter_issue, "df")

  # Prep choices
  shelter_issue_d_issues <- paste0(shelter_issue, sep, issues)
  shelter_issue_d_undefined <- paste0(shelter_issue, sep, undefined)
  shelter_issue_d_other <- paste0(shelter_issue, sep, other) # add this line
  shelter_issue_d_none <- paste0(shelter_issue, sep, none)

  # Check if columns are in the dataset
  if_not_in_stop(
    df,
    c(
      shelter_issue_d_issues,
      shelter_issue_d_undefined,
      shelter_issue_d_other,
      shelter_issue_d_none
    ),
    "df"
  ) # add shelter_issue_d_other

  # Check that colimns are in set 0:1
  are_values_in_set(
    df,
    c(
      shelter_issue_d_issues,
      shelter_issue_d_undefined,
      shelter_issue_d_other,
      shelter_issue_d_none
    ),
    c(0, 1)
  ) # add shelter_issue_d_other

  # Check that none is of length 1
  if (length(none) != 1) {
    rlang::abort("none must be of length 1")
  }

  #------ Recode

  # Sum vars across issues
  df <- sum_vars(
    df,
    new_colname = "snfi_shelter_issue_n",
    vars = shelter_issue_d_issues,
    na_rm = TRUE,
    imputation = "none"
  )

  # Add "none," "undefined" and "other" information
  df <- dplyr::mutate(
    df,
    snfi_shelter_issue_n = dplyr::case_when(
      dplyr::if_any(
        dplyr::all_of(shelter_issue_d_undefined),
        \(x) x == 1
      ) ~
        -999,
      dplyr::if_any(
        dplyr::all_of(shelter_issue_d_other),
        \(x) x == 1
      ) ~
        -998,
      !!rlang::sym(shelter_issue_d_none) == 1 ~ 0,
      .default = !!rlang::sym("snfi_shelter_issue_n")
    )
  )

  # Add final recoding
  df <- dplyr::mutate(
    df,
    snfi_shelter_issue_cat = dplyr::case_when(
      !!rlang::sym("snfi_shelter_issue_n") == 0 ~ "none",
      !!rlang::sym("snfi_shelter_issue_n") == -999 ~ "undefined",
      !!rlang::sym("snfi_shelter_issue_n") == -998 ~ "other",
      !!rlang::sym("snfi_shelter_issue_n") <= 3 ~ "1_to_3",
      !!rlang::sym("snfi_shelter_issue_n") <= 7 ~ "4_to_7",
      !!rlang::sym("snfi_shelter_issue_n") <= 11 ~ "8_to_11",
      .default = NA_character_
    )
  )

  # Change -999 and -998 in snfi_shelter_issue_n to NA
  df <- dplyr::mutate(
    df,
    snfi_shelter_issue_n = dplyr::case_when(
      !!rlang::sym("snfi_shelter_issue_n") %in% c(-999, -998) ~ NA_real_,
      .default = !!rlang::sym("snfi_shelter_issue_n")
    )
  )

  return(df)
}
