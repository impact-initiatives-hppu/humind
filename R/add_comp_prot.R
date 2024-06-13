#' Protection composite - add score and dummy for in need
#'
#' @param df A data frame.
#' @param child_sep_cat Column name for child separation category.
#' @param child_sep_cat_levels Levels for child separation category.
#' @param concern_freq_cope Column name for concern frequency cope.
#' @param concern_freq_displaced Column name for concern frequency displaced.
#' @param concern_hh_freq_kidnapping Column name for concern household frequency kidnapping.
#' @param concern_hh_freq_discrimination Column name for concern household frequency discrimination.
#' @param concern_levels Levels for concern variables.
#'
#' @export
add_comp_prot <- function(
  df,
  child_sep_cat = "prot_child_sep_cat",
  child_sep_cat_levels = c("none", "at_least_one_very_severe", "at_least_one_severe", "at_least_one_non_severe", "undefined"),
  concern_freq_cope = "prot_concern_freq_cope",
  concern_freq_displaced = "prot_concern_freq_displaced",
  concern_hh_freq_kidnapping = "prot_concern_hh_freq_kidnapping",
  concern_hh_freq_discrimination = "prot_concern_hh_freq_discrimination",
  concern_levels = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta")){

    #------ Checks

    # Check if the variables are in the data frame
    if_not_in_stop(df, c(child_sep_cat, concern_freq_cope, concern_freq_displaced, concern_hh_freq_kidnapping, concern_hh_freq_discrimination), "df")

    # Check if values are in set
    are_values_in_set(df, child_sep_cat, child_sep_cat_levels)
    are_values_in_set(df, c(concern_freq_cope, concern_freq_displaced, concern_hh_freq_kidnapping, concern_hh_freq_discrimination), concern_levels)

    # Check length of levels
    if (length(child_sep_cat_levels) != 5) {rlang::abort("child_sep_cat_levels must be of length 5.")}
    if (length(concern_levels) != 6) {rlang::abort("concern_levels must be of length 6.")}

    #------ Recode

    # Compute score for separated children
    df <- dplyr::mutate(
      df,
      comp_prot_child_sep_cat = dplyr::case_when(
        !!rlang::sym(child_sep_cat) %in% "none" ~ 1,
        !!rlang::sym(child_sep_cat) %in% "very_severe" ~ 5,
        !!rlang::sym(child_sep_cat) %in% "severe" ~ 4,
        !!rlang::sym(child_sep_cat) %in% "non_severe" ~ 1,
        !!rlang::sym(child_sep_cat) %in% "undefined" ~ NA_character_,
        .default = NA_character_
      )
    )

    # Compute the score for concerns
    # weight for each level: always is 4, several times is 3, once or twice is 2, never is 1, dnk and pnta are NA
    df <- dplyr::mutate(
      df,
      comp_prot_score_concern_freq_cope = dplyr::case_when(
        !!rlang::sym(concern_freq_cope) %in% "always" ~ 4,
        !!rlang::sym(concern_freq_cope) %in% "several_times" ~ 3,
        !!rlang::sym(concern_freq_cope) %in% "once_or_twice" ~ 2,
        !!rlang::sym(concern_freq_cope) %in% "never" ~ 1,
        !!rlang::sym(concern_freq_cope) %in% c("dnk", "pnta") ~ NA_real_,
        .default = NA_real_
      ),
      comp_prot_score_concern_freq_displaced = dplyr::case_when(
        !!rlang::sym(concern_freq_displaced) %in% "always" ~ 4,
        !!rlang::sym(concern_freq_displaced) %in% "several_times" ~ 3,
        !!rlang::sym(concern_freq_displaced) %in% "once_or_twice" ~ 2,
        !!rlang::sym(concern_freq_displaced) %in% "never" ~ 1,
        !!rlang::sym(concern_freq_displaced) %in% c("dnk", "pnta") ~ NA_real_,
        .default = NA_real_
      ),
      comp_prot_score_concern_hh_freq_kidnapping = dplyr::case_when(
        !!rlang::sym(concern_hh_freq_kidnapping) %in% "always" ~ 4,
        !!rlang::sym(concern_hh_freq_kidnapping) %in% "several_times" ~ 3,
        !!rlang::sym(concern_hh_freq_kidnapping) %in% "once_or_twice" ~ 2,
        !!rlang::sym(concern_hh_freq_kidnapping) %in% "never" ~ 1,
        !!rlang::sym(concern_hh_freq_kidnapping) %in% c("dnk", "pnta") ~ NA_real_,
        .default = NA_real_
      ),
      comp_prot_score_concern_hh_freq_discrimination = dplyr::case_when(
        !!rlang::sym(concern_hh_freq_discrimination) %in% "always" ~ 4,
        !!rlang::sym(concern_hh_freq_discrimination) %in% "several_times" ~ 3,
        !!rlang::sym(concern_hh_freq_discrimination) %in% "once_or_twice" ~ 2,
        !!rlang::sym(concern_hh_freq_discrimination) %in% "never" ~ 1,
        !!rlang::sym(concern_hh_freq_discrimination) %in% c("dnk", "pnta") ~ NA_real_,
        .default = NA_real_)
    )

    # now sum across with the following threshold: 11 and above = 5, 8 to 10 = 4, 5 to 7 = 3, 2 to 4 = 2, 1 = 1, NA = NA
    df <- sum_vars(
      df,
      !!!rlang::syms(c("comp_prot_concern_freq_cope", "comp_prot_concern_freq_displaced", "comp_prot_concern_hh_freq_kidnapping", "comp_prot_concern_hh_freq_discrimination")),
      "comp_prot_score_concern",
      na_rm = FALSE,
      imputation = "none")

    # Compute final concern score
    df <- dplyr::mutate(
      df,
      comp_prot_score_concern = dplyr::case_when(
        comp_prot_score_concern >= 11 ~ 5,
        comp_prot_score_concern >= 8 & comp_prot_score_concern <= 10 ~ 4,
        comp_prot_score_concern >= 5 & comp_prot_score_concern <= 7 ~ 3,
        comp_prot_score_concern >= 2 & comp_prot_score_concern <= 4 ~ 2,
        comp_prot_score_concern == 1 ~ 1,
        .default = NA_character_
      )
    )


    # Get the score for protection
    df <- sum_vars(
      df,
      c("comp_prot_child_sep_cat", "comp_prot_score_concern"),
      "comp_prot_score",
      na_rm = FALSE,
      imputation = "none"
    )

    # Is in need?
    df <- is_in_need(
      df,
      "comp_prot_score",
      "comp_prot_in_need"
    )

    return(df)

    }
