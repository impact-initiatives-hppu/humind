#' Education sectoral composite - add score and dummy for in need
#'
#' @param df A data frame.
#' @param ind_schooling_age_d_n Column name for the number of children of schooling age.
#' @param ind_no_access_d_n Column name for the number of children with no access to education.
#' @param ind_barrier_protection_d_n Column name for the number of children with barriers to protection.
#' @param occupation_d_n Column name for the number of children with disrupted education due to the school being occupied by armed groups
#' @param hazards_d_n Column name for the number of children with disrupted education due to hazards.
#' @param displaced_d_n Column name for the number of children with disrupted education due to a recent displacement.
#' @param teacher_d_n Column name for the number of children with disrupted education due to teachers' absence.
#'
#' @export
add_comp_edu <- function(
    df,
    ind_schooling_age_d_n = "edu_ind_schooling_age_d_n",
    ind_no_access_d_n = "edu_ind_no_access_d_n",
    ind_barrier_protection_d_n = "ind_barrier_protection_d_n",
    occupation_d_n = "edu_disrupted_occupation_d_n",
    hazards_d_n = "edu_disrupted_hazards_d_n",
    displaced_d_n = "edu_disrupted_displaced_d_n",
    teacher_d_n = "edu_disrupted_teacher_d_n"
    ){

  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(df, c(ind_schooling_age_d_n, ind_no_access_d_n, ind_barrier_protection_d_n, occupation_d_n, hazards_d_n, displaced_d_n, teacher_d_n), "df")
  # Check if values are numeric
  are_cols_numeric(df, c(ind_schooling_age_d_n, ind_no_access_d_n, ind_barrier_protection_d_n, occupation_d_n, hazards_d_n, displaced_d_n, teacher_d_n))

  #------ Recode

  # Compute score for disrupted education
  df <- dplyr::mutate(
    df,
    comp_edu_score_disrupted = dplyr::case_when(
      # No school-aged child
      !!rlang::sym(ind_schooling_age_d_n) == 0 ~ 0,
      # Remaining
      !!rlang::sym(occupation_d_n) >= 1 ~ 4,
      !!rlang::sym(hazards_d_n) >= 1 | !!rlang::sym(displaced_d_n) > 1 ~ 3,
      !!rlang::sym(teacher_d_n) >= 1 ~ 2,
      # All equal to 0
      !!rlang::sym(occupation_d_n) == 0 & !!rlang::sym(hazards_d_n) == 0 & !!rlang::sym(displaced_d_n) == 0 & !!rlang::sym(teacher_d_n) == 0 ~ 1,

      .default = NA_real_
    )
  )

  # Compute score for attendance and barriers
  df <- dplyr::mutate(
    df,
    comp_edu_score_attendance = dplyr::case_when(
      # No school-aged child
      !!rlang::sym(ind_schooling_age_d_n) == 0 ~ 0,
      # Non-attendance and protection barriers
      !!rlang::sym(ind_no_access_d_n) >= 1 | !!rlang::sym(ind_barrier_protection_d_n) >= 1 ~ 4,
      # Non attendance only
      !!rlang::sym(ind_no_access_d_n) >= 1 ~ 3,
      # All attending
      !!rlang::sym(ind_no_access_d_n) == 0 ~ 0,
      .default = NA_real_
    )
  )

  # Compute total score = max
  df <- impactR.utils::row_optimum(
    df,
    c("comp_edu_score_disrupted", "comp_edu_score_attendance"),
    max_name = "comp_edu_score",
    na_rm = TRUE
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



}
