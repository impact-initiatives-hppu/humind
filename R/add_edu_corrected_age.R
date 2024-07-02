#' Add a corrected schooling age  edu_ind_corrected_age with the revised and corrected individual age according to the start of the data collection wrt the start f the school-year
#' Add a column edu_is_school_child

#' @param roster A data frame of individual-level data.
#' @param household_data A data frame of hh-level data.
#' @param age_col The individual age column.
#' @param start_school_year numeric. it is the month when the school year has started.
#' @return 2 new columns with the corrected individual age definition and dummy edu_is_school_child
#' @export



add_edu_ind_age_corrected <- function(loop, main, id_col = "uuid", survey_start_date = "start", school_year_start_month = 9, ind_age = "ind_age") {
  
  # Convert the survey start date column to month
  main <- dplyr::mutate(main, month = as.integer(format(as.Date(!!rlang::sym(survey_start_date)), "%m")))
  main <- dplyr::select(main, dplyr::all_of(id_col, "month"))

  # Join main to loop
  loop <- dplyr::left_join(loop, main, by = id_col)

  # Calculate the adjusted start month number
  school_year_start_month_adj <- ifelse(school_year_start_month > 6, school_year_start_month - 12, school_year_start_month)

  # we should add a test that it's numeric instead
  # roster[[age_col]] <- as.numeric(roster[[age_col]])

  # Apply the age correction based on the month difference, handling NA in month or age
  loop <- dplyr::mutate(loop, edu_ind_age_corrected = dplyr::case_when(
    !is.na(!!rlang::sym("month")) & !is.na(!!sym(ind_age)) & (!!rlang::sym("month") - school_year_start_month_adj) > 6 ~ !!rlang::sym(ind_age) - 1,
    .default = !!rlang::sym(ind_age)
    )
  )

  #Final classification --- NAing with below 5 or under 17
  loop <- dplyr::mutate(
    loop, 
    edu_ind_age_corrected = dplyr::case_when(
      !!rlang::sym("edu_ind_age_corrected") < 5 | !!rlang::sym("edu_ind_age_corrected") > 17 ~ NA_real_,
      .default = !!rlang::sym("edu_ind_age_corrected")
    )
  )

  # Add a dummy variable, 1 if the individual is a school child, 0 otherwise
  loop <- dplyr::mutate(
    loop, 
    edu_ind_schooling_age_d = dplyr::case_when(
      is.na(!!rlang::sym("edu_ind_age_corrected")) ~ 0
      !!rlang::sym("edu_ind_age_corrected") < 5 | !!rlang::sym("edu_ind_age_corrected") > 17 ~ 0,
      .default = 1
    )
  )
  
  return (loop)
}

