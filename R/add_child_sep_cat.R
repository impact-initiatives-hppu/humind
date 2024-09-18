#' Add child separation categories
#'
#' @param df A data frame.
#' @param child_sep Child separation yes/no question.
#' @param child_sep_yes Value for yes.
#' @param child_sep_no Value for no.
#' @param child_sep_undefined Vector of undefined responses.
#' @param child_sep_reason Follow-up question for the reasons of child separation.
#' @param child_sep_reason_non_severe Values of non-severe reasons.
#' @param child_sep_reason_severe Values of severe reasons.
#' @param child_sep_reason_very_severe Values of very severe reasons.
#' @param child_sep_reason_undefined Values of undefined reasons.
#' @param sep Separator for the child_sep_reason columns.
#'
#' @export
add_child_sep_cat <- function(
    df,
    child_sep = "prot_child_sep",
    child_sep_yes = "yes",
    child_sep_no = "no",
    child_sep_undefined = c("pnta", "dnk"),
    child_sep_reason = "prot_child_sep_reason",
    child_sep_reason_non_severe = c("left_study"),
    child_sep_reason_severe = c("left_employment", "left_married"),
    child_sep_reason_very_severe = c("left_armed_groups", "kidnapped", "missing", "detained", "stayed_in_origin", "separated_displacement"),
    child_sep_reason_undefined = c("other", "dnk", "pnta"),
    sep = "/"){

  #------ Checks


  # Check if the variable is in the data frame
  if_not_in_stop(df, child_sep, "df")
  if_not_in_stop(df, child_sep_reason, "df")

  # Are cols from child_sep_reason
  are_values_in_set(df, child_sep, c(child_sep_yes, child_sep_no, child_sep_undefined))

  # Prep choices
  child_sep_reason_d_severe <- paste0(child_sep_reason, sep, child_sep_reason_severe)
  child_sep_reason_d_very_severe <- paste0(child_sep_reason, sep, child_sep_reason_very_severe)
  child_sep_reason_d_undefined <- paste0(child_sep_reason, sep, child_sep_reason_undefined)
  child_sep_reason_d_non_severe <- paste0(child_sep_reason, sep, child_sep_reason_non_severe)

  # Check if columns are in df
  if_not_in_stop(df, c(child_sep_reason_d_severe, child_sep_reason_d_very_severe, child_sep_reason_d_undefined, child_sep_reason_d_non_severe), "df")

  # Check if columns are in set
  are_values_in_set(df, c(child_sep_reason_d_severe, child_sep_reason_d_very_severe, child_sep_reason_d_undefined, child_sep_reason_d_non_severe), c(0, 1))

  # Check that child_sep yes and child sep no is of length 1
  if (length(child_sep_yes) != 1 | length(child_sep_no) != 1) {
    rlang::abort("yes and no must be of length 1.")
  }

  #------ Recode

  df <- dplyr::mutate(
    df,
    prot_child_sep_cat = dplyr::case_when(
      !!rlang::sym(child_sep) == child_sep_no ~ "none",
      !!rlang::sym(child_sep) %in% child_sep_undefined ~ "undefined",
      !!rlang::sym(child_sep) == child_sep_yes & dplyr::if_any(dplyr::all_of(child_sep_reason_d_undefined), \(x) x == 1) ~ "undefined",
      !!rlang::sym(child_sep) == child_sep_yes & dplyr::if_any(dplyr::all_of(child_sep_reason_d_very_severe), \(x) x == 1) ~ "at_least_one_very_severe",
      !!rlang::sym(child_sep) == child_sep_yes & dplyr::if_any(dplyr::all_of(child_sep_reason_d_severe), \(x) x == 1) ~ "at_least_one_severe",
      !!rlang::sym(child_sep) == child_sep_yes & dplyr::if_any(dplyr::all_of(child_sep_reason_d_non_severe), \(x) x == 1) ~ "at_least_one_non_severe",
      .default = NA_character_
    )
  )

  return(df)

}
