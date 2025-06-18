#' @title Add Protection Composite Score and Need Indicators
#'
#' @description
#' This function calculates a protection composite score based on concern frequencies. Change for 2025 - child separation categories was
#' removed.
#' It also adds indicators for protection needs and acute protection needs.
#'
#' @param df A data frame containing the required variables.
#' @param concern_freq_cope Column name for concern frequency cope.
#' @param concern_freq_displaced Column name for concern frequency displaced.
#' @param concern_hh_freq_kidnapping Column name for concern household frequency kidnapping.
#' @param concern_hh_freq_discrimination Column name for concern household frequency discrimination.
#' @param concern_always Level for always concerned.
#' @param concern_several_times Level for concerned several times.
#' @param concern_once_or_twice Level for concerned once or twice.
#' @param concern_never Level for never concerned.
#' @param concern_dnk Level for don't know.
#' @param concern_pnta Level for prefer not to answer.
#'
#' @return A data frame with added columns:
#'
#' * comp_prot_score_concern_freq_cope: Score for concern frequency cope
#' * comp_prot_score_concern_freq_displaced: Score for concern frequency displaced
#' * comp_prot_score_concern_hh_freq_kidnapping: Score for concern household frequency kidnapping
#' * comp_prot_score_concern_hh_freq_discrimination: Score for concern household frequency discrimination
#' * comp_prot_risk_always_d: Indicator for at least one 'Always' response in perceived risks
#' * comp_prot_score_concern: Final concern score
#' * comp_prot_score: Overall protection composite score
#' * comp_prot_in_need: Indicator for protection need
#' * comp_prot_in_acute_need: Indicator for acute protection need
#'
#' @export
add_comp_prot <- function(
    df,
    concern_freq_cope = "prot_concern_freq_cope",
    concern_freq_displaced = "prot_concern_freq_displaced",
    concern_hh_freq_kidnapping = "prot_concern_hh_freq_kidnapping",
    concern_hh_freq_discrimination = "prot_concern_hh_freq_discrimination",
    concern_always = "always",
    concern_several_times = "several_times",
    concern_once_or_twice = "once_or_twice",
    concern_never = "never",
    concern_dnk = "dnk",
    concern_pnta = "pnta"){

  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(df, c(concern_freq_cope, concern_freq_displaced, concern_hh_freq_kidnapping, concern_hh_freq_discrimination), "df")

  # Check if values are in set
  concern_levels <- c(concern_always, concern_several_times, concern_once_or_twice, concern_never, concern_dnk, concern_pnta)

  are_values_in_set(df, c(concern_freq_cope, concern_freq_displaced, concern_hh_freq_kidnapping, concern_hh_freq_discrimination), concern_levels)

  #------ Recode

  # Compute the score for concerns
  df <- dplyr::mutate(
    df,
    comp_prot_score_concern_freq_cope = dplyr::case_when(
      !!rlang::sym(concern_freq_cope) %in% concern_always ~ 3,
      !!rlang::sym(concern_freq_cope) %in% concern_several_times ~ 2,
      !!rlang::sym(concern_freq_cope) %in% concern_once_or_twice ~ 1,
      !!rlang::sym(concern_freq_cope) %in% concern_never ~ 0,
      !!rlang::sym(concern_freq_cope) %in% c(concern_dnk, concern_pnta) ~ NA_real_,
      .default = NA_real_
    ),
    comp_prot_score_concern_freq_displaced = dplyr::case_when(
      !!rlang::sym(concern_freq_displaced) %in% concern_always ~ 3,
      !!rlang::sym(concern_freq_displaced) %in% concern_several_times ~ 2,
      !!rlang::sym(concern_freq_displaced) %in% concern_once_or_twice ~ 1,
      !!rlang::sym(concern_freq_displaced) %in% concern_never ~ 0,
      !!rlang::sym(concern_freq_displaced) %in% c(concern_dnk, concern_pnta) ~ NA_real_,
      .default = NA_real_
    ),
    comp_prot_score_concern_hh_freq_kidnapping = dplyr::case_when(
      !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_always ~ 3,
      !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_several_times ~ 2,
      !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_once_or_twice ~ 1,
      !!rlang::sym(concern_hh_freq_kidnapping) %in% concern_never ~ 0,
      !!rlang::sym(concern_hh_freq_kidnapping) %in% c(concern_dnk, concern_pnta) ~ NA_real_,
      .default = NA_real_
    ),
    comp_prot_score_concern_hh_freq_discrimination = dplyr::case_when(
      !!rlang::sym(concern_hh_freq_discrimination) %in% concern_always ~ 3,
      !!rlang::sym(concern_hh_freq_discrimination) %in% concern_several_times ~ 2,
      !!rlang::sym(concern_hh_freq_discrimination) %in% concern_once_or_twice ~ 1,
      !!rlang::sym(concern_hh_freq_discrimination) %in% concern_never ~ 0,
      !!rlang::sym(concern_hh_freq_discrimination) %in% c(concern_dnk, concern_pnta) ~ NA_real_,
      .default = NA_real_)
  )

  # Add one new integer variable called prot_risks_always_d indicating the whethere there's at least an Always response in the four perceived risks
  df <- dplyr::mutate(
    df,
    comp_prot_risk_always_d = dplyr::case_when(
      dplyr::if_any(
        c(
          "comp_prot_score_concern_freq_cope",
          "comp_prot_score_concern_freq_displaced",
          "comp_prot_score_concern_hh_freq_kidnapping",
          "comp_prot_score_concern_hh_freq_discrimination"),
        \(x) x == 3) ~ 1,
      dplyr::if_all(
        c(
          "comp_prot_score_concern_freq_cope",
          "comp_prot_score_concern_freq_displaced",
          "comp_prot_score_concern_hh_freq_kidnapping",
          "comp_prot_score_concern_hh_freq_discrimination"),
        \(x) x != 3) ~ 0,
      .default = NA_real_
    )
  )

  # now sum across with the following threshold: 11 and above = 5, 8 to 10 = 4, 5 to 7 = 3, 2 to 4 = 2, 1 = 1, NA = NA
  df <- sum_vars(
    df,
    c(
      "comp_prot_score_concern_freq_cope",
      "comp_prot_score_concern_freq_displaced",
      "comp_prot_score_concern_hh_freq_kidnapping",
      "comp_prot_score_concern_hh_freq_discrimination"
    ),
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
      comp_prot_score_concern >= 0 ~ 1,
      .default = NA_real_
    )
  )


  # Get the score for protection
  # Compute total score = comp_prot_score_concern
  df <- dplyr::mutate(
    df,
    comp_prot_score = comp_prot_score_concern
  )

  # Is in need?
  df <- is_in_need(
    df,
    "comp_prot_score",
    "comp_prot_in_need"
  )

  # Is in acute need?
  df <- is_in_acute_need(
    df,
    "comp_prot_score",
    "comp_prot_in_acute_need"
  )

  return(df)
}
