# ANA
# 2025 Indicator ID: TBD
# 2025 Metric ID: TBD

#' @title Add Skilled Birth Attendance to Individual Data
#'
#' @description Computes two binary variables at the individual level for women of reproductive age (15–49): whether the woman had a live birth in the last two years, and whether that birth was attended by skilled health personnel (doctor, nurse, or midwife).
#'
#' @param loop A data frame of individual-level data.
#' @param ind_gender Column name for the gender of the individual.
#' @param ind_gender_female Response code for female.
#' @param ind_age Column name for the age of the individual.
#' @param ind_age_min Minimum age for reproductive age range (inclusive). Default: `15`.
#' @param ind_age_max Maximum age for reproductive age range (inclusive). Default: `49`.
#' @param health_pregnancy_2years_yn Column name for whether the woman had a live birth in the last two years.
#' @param health_pregnancy_2years_yes Response code for yes.
#' @param health_pregnancy_2years_no Response code for no.
#' @param health_pregnancy_2years_undefined Character vector of undefined response codes (dnk, pnta).
#' @param health_birth_assistance Column name for who assisted with the delivery.
#' @param health_birth_assistance_skilled Character vector of response codes for skilled health personnel (doctor, nurse, or midwife).
#' @param health_birth_assistance_lessskilled Character vector of response codes for less-skilled birth assistance (traditional birth attendant, relative/friend, or none).
#' @param health_birth_assistance_undefined Character vector of undefined response codes (dnk, pnta, other).
#'
#' @return A data frame with two additional columns:
#'
#' * `health_ind_live_birth_2years_d`: `1L` if woman aged 15–49 with a live birth in the last two years; `0L` otherwise (including men and women outside age range); `NA_integer_` if age/gender missing or pregnancy response is undefined.
#' * `health_ind_skilled_birth_attendance_d`: `1L` if live birth and attended by skilled personnel; `0L` if live birth and not attended by skilled personnel; `NA_integer_` if no live birth, birth assistance response is undefined, or live birth status is NA.
#'
#' @export
add_loop_skilled_birth_attendance <- function(
  loop,
  ind_gender = "ind_gender",
  ind_gender_female = "female",
  ind_age = "ind_age",
  ind_age_min = 15,
  ind_age_max = 49,
  health_pregnancy_2years_yn = "health_pregnancy_2years_yn",
  health_pregnancy_2years_yes = "yes",
  health_pregnancy_2years_no = "no",
  health_pregnancy_2years_undefined = c("dnk", "pnta"),
  health_birth_assistance = "health_birth_assistance",
  health_birth_assistance_skilled = c("doctor", "nurse", "midwife"),
  health_birth_assistance_lessskilled = c(
    "traditional_birth_attendant",
    "relative_friend",
    "none"
  ),
  health_birth_assistance_undefined = c("dnk", "pnta", "other")
) {
  #------ Checks

  if_not_in_stop(
    loop,
    c(ind_gender, ind_age, health_pregnancy_2years_yn, health_birth_assistance),
    "loop"
  )
  are_cols_numeric(loop, ind_age)
  are_values_in_set(
    loop,
    health_pregnancy_2years_yn,
    c(
      health_pregnancy_2years_yes,
      health_pregnancy_2years_no,
      health_pregnancy_2years_undefined
    )
  )

  are_values_in_set(
    loop,
    health_birth_assistance,
    c(
      health_birth_assistance_skilled,
      health_birth_assistance_lessskilled,
      health_birth_assistance_undefined
    )
  )

  #------ Compute

  loop <- dplyr::mutate(
    loop,
    # gender and age dummy
    health_ind_gender_female_above_age_d = case_when(
      is.na(.data[[ind_gender]]) | is.na(.data[[ind_age]]) ~ NA_integer_,
      .data[[ind_gender]] != ind_gender_female ~ 0L,
      .data[[ind_age]] < ind_age_min | .data[[ind_age]] > ind_age_max ~ 0L,
      .default = 1L
    ),
    # live_birth in last 2 years dummy
    health_ind_live_birth_2years_d = dplyr::case_when(
      is.na(.data[["health_ind_gender_female_above_age_d"]]) ~ NA_integer_,
      .data[["health_ind_gender_female_above_age_d"]] == 0L ~ 0L,
      .data[[health_pregnancy_2years_yn]] %in%
        health_pregnancy_2years_undefined ~ NA_integer_,
      .data[[health_pregnancy_2years_yn]] == health_pregnancy_2years_yes ~ 1L,
      .data[[health_pregnancy_2years_yn]] == health_pregnancy_2years_no ~ 0L,
      .default = NA_integer_
    ),
    # skilled birth attendance dummy
    health_ind_skilled_birth_attendance_d = dplyr::case_when(
      is.na(.data[["health_ind_live_birth_2years_d"]]) ~ NA_integer_,
      .data[["health_ind_live_birth_2years_d"]] == 0L ~ 0L,
      .data[[health_birth_assistance]] %in%
        health_birth_assistance_undefined ~ NA_integer_,
      .data[[health_birth_assistance]] %in%
        health_birth_assistance_skilled ~ 1L,
      .data[[health_birth_assistance]] %in%
        health_birth_assistance_lessskilled ~ 0L,
      .default = NA_integer_
    )
  )

  return(loop)
}


#' @rdname add_loop_skilled_birth_attendance
#'
#' @title Aggregate Skilled Birth Attendance to Household Level
#'
#' @description Aggregates individual-level skilled birth attendance indicators to the household level by summing the binary dummy variables per household.
#'
#' @param main A data frame of household-level data.
#' @param loop A data frame of individual-level data (output of `add_loop_skilled_birth_attendance()`).
#' @param ind_live_birth_2years Column name for the live birth dummy in loop.
#' @param ind_skilled_birth_attendance Column name for the skilled birth attendance dummy in loop.
#' @param id_col_main Column name for the unique identifier in the main data frame.
#' @param id_col_loop Column name for the unique identifier in the loop data frame.
#'
#' @return A data frame with two additional columns:
#'
#' * `health_ind_live_birth_2years_n`: Count of women aged 15–49 with a live birth in the last two years per household.
#' * `health_ind_skilled_birth_attendance_n`: Count of women with a skilled birth attendance per household.
#'
#' @export
add_loop_skilled_birth_attendance_to_main <- function(
  main,
  loop,
  ind_live_birth_2years = "health_ind_live_birth_2years_d",
  ind_skilled_birth_attendance = "health_ind_skilled_birth_attendance_d",
  id_col_main = "uuid",
  id_col_loop = "uuid"
) {
  #------ Checks

  vars <- c(ind_live_birth_2years, ind_skilled_birth_attendance)
  if_not_in_stop(loop, vars, "loop")
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(loop, id_col_loop, "loop")
  are_values_in_set(loop, vars, c(0, 1))

  vars_n <- c(
    "health_ind_live_birth_2years_n",
    "health_ind_skilled_birth_attendance_n"
  )
  if (vars_n[1] %in% colnames(main)) {
    rlang::warn(paste0(
      vars_n[1],
      " already exists in 'main'. It will be replaced."
    ))
  }
  if (vars_n[2] %in% colnames(main)) {
    rlang::warn(paste0(
      vars_n[2],
      " already exists in 'main'. It will be replaced."
    ))
  }

  #------ Compute

  loop_vars <- dplyr::summarize(
    loop,
    health_ind_live_birth_2years_n = sum(
      .data[[ind_live_birth_2years]],
      na.rm = FALSE
    ),
    health_ind_skilled_birth_attendance_n = sum(
      .data[[ind_skilled_birth_attendance]],
      na.rm = FALSE
    ),
    .by = dplyr::all_of(id_col_loop)
  )

  cols_uuids <- c(id_col_main, id_col_loop)
  cols_from_loop_in_main <- setdiff(
    intersect(colnames(loop_vars), colnames(main)),
    cols_uuids
  )
  main <- dplyr::select(main, -dplyr::all_of(cols_from_loop_in_main))

  main <- dplyr::left_join(
    main,
    loop_vars,
    by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop))
  )

  return(main)
}
