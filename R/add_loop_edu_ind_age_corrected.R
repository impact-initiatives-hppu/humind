#' Add a correct schooling age to the loop
#'
#' @param loop A data frame of individual-level data.
#' @param main A data frame of individual-level data.
#' @param id_col_loop  Survey unique identifier column name in loop.
#' @param id_col_main  Survey unique identifier column name in main.
#' @param survey_start_date  Survey start date column name in main.
#' @param school_year_start_month  The month when the school year has started.
#' @param ind_age  The individual age column.
#' @param month  If not NULL, an integer between 1 and 12 which will be used as the month of data collection for all households.
#' @param schooling_start_age The age at which we assign the value 1 to edu_ind_schooling_age_d. Default is 5.
#' @return 2 new columns: "edu_ind_age_corrected" with the corrected individual age, and a dummy variable edu_ind_schooling_age_d
#'
#' @export
add_loop_edu_ind_age_corrected <- function(loop,
                                           main,
                                           id_col_loop = "uuid",
                                           id_col_main = "uuid",
                                           survey_start_date = "start",
                                           school_year_start_month = 9,
                                           ind_age = "ind_age",
                                           month = NULL,
                                           schooling_start_age = 5) {

  #------ Initial checks

  # Check if the variable is in the data frame
  if_not_in_stop(loop, id_col_loop, "loop")
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(main, survey_start_date, "main")
  if_not_in_stop(loop, ind_age, "loop")

  # Check if ind_age is numeric
  are_cols_numeric(loop, ind_age)

  # Check if survey_start_date is a date in main
  # To do

  #------ Prepare month of data collection var

  # Convert the survey start date column to month OR use the provided param 'month'
  if (is.null(month)){
    # Prepare month date
    main <- dplyr::mutate(main, month = as.integer(format(as.Date(!!rlang::sym(survey_start_date)), "%m")))
    main <- dplyr::select(main, dplyr::all_of(c(id_col_main, "month")))
    # Check that month values are between 1 and 12, if not abort
    are_values_in_set(main, "month", 1:12)
    # Remove "month" from loop if it exists
    if("month" %in% colnames(loop)){
      # warn for removal
      rlang::warn("'month' already exists in 'loop', replacing it.")
      # Remove
      loop <- dplyr::select(loop, -dplyr::all_of("month"))
    }
    # Join main to loop, setNames used to dynamically set the column names for the join operation.
    loop <- dplyr::left_join(loop, main, by = stats::setNames(id_col_main, id_col_loop))
  } else {
    # Check that month is a number between 1 and 12, if no abort
    if (!(month %in% c(1:12))) rlang::abort("month must be between 1 and 12")
    # Add "month" as a column to loop
    loop <- dplyr::mutate(loop, month = month)
  }

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

  #Final classification --- NAing with below schooling_start_age or under 17
  loop <- dplyr::mutate(
    loop,
    edu_ind_age_corrected = dplyr::case_when(
      !!rlang::sym("edu_ind_age_corrected") < schooling_start_age | !!rlang::sym("edu_ind_age_corrected") > 17 ~ NA_real_,
      .default = !!rlang::sym("edu_ind_age_corrected")
    )
  )

  # Add a dummy variable, 1 if the individual is a school child, 0 otherwise
  loop <- dplyr::mutate(
    loop,
    edu_ind_schooling_age_d = dplyr::case_when(
      is.na(!!rlang::sym("edu_ind_age_corrected")) ~ 0,
      !!rlang::sym("edu_ind_age_corrected") < schooling_start_age | !!rlang::sym("edu_ind_age_corrected") > 17 ~ 0,
      .default = 1
    )
  )

  return(loop)
}

#' @rdname add_loop_edu_ind_age_corrected
#'
#' @param main A data frame of household-level data.
#' @param loop A data frame of individual-level data.
#' @param ind_schooling_age_d Column name for the dummy variable of the schooling age class.
#' @param id_col_main Column name for the unique identifier in the main dataset.
#' @param id_col_loop Column name for the unique identifier in the loop dataset.
#'
#' @export
add_loop_edu_ind_schooling_age_d_to_main <- function(
    main,
    loop,
    ind_schooling_age_d = "edu_ind_schooling_age_d",
    id_col_main = "uuid",
    id_col_loop = "uuid") {

  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(loop, c(ind_schooling_age_d), "loop")
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(loop, id_col_loop, "loop")

  # Check if new_colname exists in the dataframe, if yes throw a warning for replacement
  ind_schooling_age_d_n <- paste0(ind_schooling_age_d, "_n")

  if (ind_schooling_age_d_n %in% colnames(main)) {
    rlang::warn(paste0(ind_schooling_age_d_n, " already exists in the data frame. It will be replaced."))
  }

  #------ Compute

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Sum the schooling age dummy variable
  loop <- dplyr::summarise(loop, edu_schooling_age_n = sum(!!rlang::sym(ind_schooling_age_d), na.rm = TRUE))

  # Join loop to main
  main <- dplyr::left_join(main, loop, by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop)))

  return(main)
}
