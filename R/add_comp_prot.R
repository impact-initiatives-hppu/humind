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
  concern_levels = c("always", "several_times", "once_or_twice", "never", "dnk", "pnta")){

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
        !!rlang::sym(child_sep_cat) %in% child_sep_cat_levels[1] ~ 1,
        !!rlang::sym(child_sep_cat) %in% child_sep_cat_levels[2] ~ 5,
        !!rlang::sym(child_sep_cat) %in% child_sep_cat_levels[3] ~ 4,
        !!rlang::sym(child_sep_cat) %in% child_sep_cat_levels[4] ~ 2,
        !!rlang::sym(child_sep_cat) %in% child_sep_cat_levels[5] ~ NA_character_,
        .default = NA_character_
      )
    )

    # Compute the score for concerns
    # weight for each level: always is 4, several times is 3, once or twice is 2, never is 1, dnk and pnta are NA
    df <- dplyr::mutate(
      df,
      comp_prot_score_concern_freq_cope = dplyr::case_when(
        !!rlang::sym(concern_freq_cope) %in% concern_levels[1] ~ 3,
        !!rlang::sym(concern_freq_cope) %in% concern_levels[2] ~ 2,
        !!rlang::sym(concern_freq_cope) %in% concern_levels[3] ~ 1,
        !!rlang::sym(concern_freq_cope) %in% concern_levels[4] ~ 0,
        !!rlang::sym(concern_freq_cope) %in% concern_levels[5:6] ~ NA_real_,
        .default = NA_real_
      ),
      comp_prot_score_concern_freq_displaced = dplyr::case_when(
        !!rlang::sym(concern_freq_displaced) %in% concern_levels[1] ~ 3,
        !!rlang::sym(concern_freq_displaced) %in% concern_levels[2] ~ 2,
        !!rlang::sym(concern_freq_displaced) %in% concern_levels[3] ~ 1,
        !!rlang::sym(concern_freq_displaced) %in% concern_levels[4] ~ 0,
        !!rlang::sym(concern_freq_displaced) %in% concern_levels[5:6] ~ NA_real_,
        .default = NA_real_
      ),
      comp_prot_score_concern_hh_freq_kidnapping = dplyr::case_when(
        !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_levels[1] ~ 3,
        !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_levels[2] ~ 2,
        !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_levels[3] ~ 1,
        !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_levels[4] ~ 0,
        !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_levels[5:6] ~ NA_real_,
        .default = NA_real_
      ),
      comp_prot_score_concern_hh_freq_discrimination = dplyr::case_when(
        !!rlang::sym(concern_hh_freq_discrimination) %in% concern_levels[1] ~ 3,
        !!rlang::sym(concern_hh_freq_discrimination) %in% concern_levels[2] ~ 2,
        !!rlang::sym(concern_hh_freq_discrimination) %in% concern_levels[3] ~ 1,
        !!rlang::sym(concern_hh_freq_discrimination) %in% concern_levels[4] ~ 0,
        !!rlang::sym(concern_hh_freq_discrimination) %in% concern_levels[5:6] ~ NA_real_,
        .default = NA_real_)
    )

    # Add one new integer variable called prot_risks_always_d indicating the whethere there's at least an Always response in the four perceived risks
    df <- dplyr::mutate(
      df,
      comp_prot_risk_always_d = dplyr::case_when(
        dplyr::if_any(
          c(
            "comp_prot_concern_freq_cope",
            "comp_prot_concern_freq_displaced",
            "comp_prot_concern_hh_freq_kidnapping",
            "comp_prot_concern_hh_freq_discrimination"),
          \(x) x == 3) ~ 1,
        dplyr::if_all(
          c(
            "comp_prot_concern_freq_cope",
            "comp_prot_concern_freq_displaced",
            "comp_prot_concern_hh_freq_kidnapping",
            "comp_prot_concern_hh_freq_discrimination"),
          \(x) x != 3) ~ 0,
        .default = NA_real_
        )
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
        comp_prot_score_concern >= 9 ~ 4,
        comp_prot_score_concern >= 4 ~ 3,
        comp_prot_risk_always_d == 1 ~ 3,	
        comp_prot_score_concern >= 2 ~ 2,
        comp_prot_score_concern == 0 ~ 1,
        .default = NA_real_
      )
    )

    # Get the score for protection
    # Compute total score = max
    df <- impactR.utils::row_optimum(
      df,
      !!!rlang::syms(c("comp_prot_child_sep_cat", "comp_prot_score_concern")),
      optimum = "max",
      max_name = "comp_prot_score",
      na_rm = TRUE
    )
  
    # Is in need?
    df <- is_in_need(
      df,
      "comp_prot_score",
      "comp_prot_in_need"
    )

    return(df)

}
