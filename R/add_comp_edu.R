#' @title Calculate Education Sectoral Composite Score and Need Indicators
#'
#' @description
#' This function calculates an education sectoral composite score based on various
#' education-related indicators. It computes scores for disrupted education and
#' attendance/barriers, combines them into a total score, and determines if a
#' household is in need or in acute need of educational assistance.
#'
#' Prerequisite functions:
#'
#' * add_loop_age_dummy.R
#' * add_loop_edu_barrier_protection_d.R
#' * add_loop_edu_disrupted_d.R
#' * add_loop_edu_ind_age_corrected.R
#'
#'
#' @param df A data frame.
#' @param schooling_age_n Column name for the number of children of schooling age.
#' @param no_access_n Column name for the number of children with no access to education.
#' @param barrier_protection_n Column name for the number of children with barriers to protection.
#' @param attack_n Column name for the number of children with disrupted education due to the school being occupied by armed groups
#' @param hazards_n Column name for the number of children with disrupted education due to hazards.
#' @param displaced_n Column name for the number of children with disrupted education due to a recent displacement.
#' @param teacher_n Column name for the number of children with disrupted education due to teachers' absence.
#'
#' @return A data frame with additional columns:
#'
#' * comp_edu_score_disrupted: Score for disrupted education (1-4).
#' * comp_edu_score_attendance: Score for attendance and barriers (1-4)
#' * comp_edu_score: Total education composite score (max of disrupted and attendance scores).
#' * comp_edu_in_need: Binary indicator for being in need of educational assistance.
#' * comp_edu_in_acute_need: Binary indicator for being in acute need of educational assistance.
#'
#' @export
add_comp_edu <- function(
  df,
  schooling_age_n = "edu_schooling_age_n",
  no_access_n = "edu_no_access_n",
  barrier_protection_n = "edu_barrier_protection_n",
  attack_n = "edu_disrupted_attack_n",
  hazards_n = "edu_disrupted_hazards_n",
  displaced_n = "edu_disrupted_displaced_n",
  teacher_n = "edu_disrupted_teacher_n"
) {
  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(
    df,
    c(
      schooling_age_n,
      no_access_n,
      barrier_protection_n,
      attack_n,
      hazards_n,
      displaced_n,
      teacher_n
    ),
    "df"
  )
  # Check if values are numeric
  are_cols_numeric(
    df,
    c(
      schooling_age_n,
      no_access_n,
      barrier_protection_n,
      attack_n,
      hazards_n,
      displaced_n,
      teacher_n
    )
  )

  #------ Recode

  # Compute score for disrupted education
  df <- dplyr::mutate(
    df,
    comp_edu_score_disrupted = dplyr::case_when(
      # No school-aged child
      !!rlang::sym(schooling_age_n) == 0 ~ 1,
      # Remaining
      !!rlang::sym(attack_n) >= 1 ~ 4,
      !!rlang::sym(hazards_n) >= 1 | !!rlang::sym(displaced_n) >= 1 ~ 3,
      !!rlang::sym(teacher_n) >= 1 ~ 2,
      # All equal to 0
      !!rlang::sym(attack_n) == 0 &
        !!rlang::sym(hazards_n) == 0 &
        !!rlang::sym(displaced_n) == 0 &
        !!rlang::sym(teacher_n) == 0 ~
        1,
      .default = NA_real_
    )
  )

  # Compute score for attendance and barriers
  df <- dplyr::mutate(
    df,
    comp_edu_score_attendance = dplyr::case_when(
      # No school-aged child
      !!rlang::sym(schooling_age_n) == 0 ~ 1,
      # Non-attendance and protection barriers
      !!rlang::sym(no_access_n) >= 1 & !!rlang::sym(barrier_protection_n) >= 1 ~
        4,
      # Non attendance only
      !!rlang::sym(no_access_n) >= 1 ~ 3,
      # All attending
      !!rlang::sym(no_access_n) == 0 ~ 1,
      .default = NA_real_
    )
  )

  # Compute total score = max
  df <- dplyr::mutate(
    df,
    comp_edu_score = pmax(
      !!!rlang::syms(c(
        "comp_edu_score_disrupted",
        "comp_edu_score_attendance"
      )),
      na.rm = TRUE
    )
  )

  # Is in need?
  df <- is_in_need(
    df,
    "comp_edu_score",
    "comp_edu_in_need"
  )

  # Is in acute need?
  df <- is_in_acute_need(
    df,
    "comp_edu_score",
    "comp_edu_in_acute_need"
  )

  return(df)
}
