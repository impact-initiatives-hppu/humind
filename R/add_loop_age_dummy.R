#' @title Add Age and Gender Dummy Variables for Demographics Loop
#'
#' @description This set of functions adds dummy variables for age classes and gender in the demographics loop, and optionally sums these dummies to the main dataset.
#' It includes four main functions: [add_loop_age_dummy()], [add_loop_age_dummy_to_main()], [add_loop_age_gender_dummy()], and [add_loop_age_gender_dummy_to_main()].
#'
#' @param loop A data frame of individual-level data.
#' @param ind_age Column name for individual age.
#' @param lb Lower bound for the age class.
#' @param ub Upper bound for the age class.
#' @param new_colname New column name for the dummy variable. If NULL, then the default is "ind_age_lb_ub" or "ind_dummy_n" or "ind_age_gender_lb_ub" or "ind_age_gender_dummy_n" depending on the function used.
#' @param main A data frame of household-level data.
#' @param ind_age_dummy Column name for the dummy variable of the age class.
#' @param id_col_main Column name for the unique identifier in the main dataset.
#' @param id_col_loop Column name for the unique identifier in the loop dataset.
#' @param ind_gender Column name for individual gender.
#' @param gender Response options of interest, e.g. "Female".
#' @param ind_age_gender_dummy Column name for the dummy variable of the age-gender class.
#'
#' @return Depending on the function used:
#'
#' * add_loop_age_dummy: Returns the loop data frame with an additional column for the age dummy variable.
#' * add_loop_age_dummy_to_main: Returns the main data frame with an additional column for the sum of age dummy variables.
#' * add_loop_age_gender_dummy: Returns the loop data frame with an additional column for the age-gender dummy variable.
#' * add_loop_age_gender_dummy_to_main: Returns the main data frame with an additional column for the sum of age-gender dummy variables.
#'
#' @export
add_loop_age_dummy <- function(
  loop,
  ind_age = "ind_age",
  lb = 5,
  ub = 18,
  new_colname = NULL
) {
  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(loop, ind_age, "loop")

  # Check if ind_age is numeric
  are_cols_numeric(loop, ind_age)

  # Create new column name
  if (is.null(new_colname)) {
    new_colname <- paste0(ind_age, "_", lb, "_", ub)
  }

  # Check if newcolname exists in the dataframe, if yes throw a warning for replacement
  if (new_colname %in% names(loop)) {
    rlang::warn(paste0(
      new_colname,
      " already exists in the data frame. It will be replaced."
    ))
  }

  #------ Compute

  # Create dummy
  loop <- dplyr::mutate(
    loop,
    "{new_colname}" := dplyr::case_when(
      !!rlang::sym(ind_age) >= lb & !!rlang::sym(ind_age) <= ub ~ 1,
      .default = 0
    )
  )

  return(loop)
}

#' @rdname add_loop_age_dummy
#'
#' @param main A data frame of household-level data.
#' @param ind_age_dummy Column name for the dummy variable of the age class.
#' @param id_col_main Column name for the unique identifier in the main dataset.
#' @param id_col_loop Column name for the unique identifier in the loop dataset.
#'
#' @export
add_loop_age_dummy_to_main <- function(
  main,
  loop,
  ind_age_dummy = "ind_age_5_18",
  id_col_main = "uuid",
  id_col_loop = "uuid",
  new_colname = NULL
) {
  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(loop, c(ind_age_dummy, id_col_loop), "loop")
  if_not_in_stop(main, id_col_main, "main")

  # Create new column name
  if (is.null(new_colname)) {
    new_colname <- paste0(ind_age_dummy, "_n")
  }

  # Check if all values from ind_age_dummy are (0,1)
  are_values_in_set(loop, ind_age_dummy, c(0, 1))

  # Check if newcolname exists in the dataframe, if yes throw a warning for replacement
  if (new_colname %in% names(main)) {
    rlang::warn(paste0(
      new_colname,
      " already exists in the data frame. It will be replaced."
    ))
  }

  #------ Compute

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Sum the dummy variable
  loop <- dplyr::summarize(
    loop,
    "{new_colname}" := sum(!!rlang::sym(ind_age_dummy))
  )

  # Remove columns in main that exists in loop, but the grouping ones
  main <- impactR.utils::df_diff(main, loop, !!rlang::sym(id_col_main))

  # Merge the loop to the main dataset
  main <- dplyr::left_join(
    main,
    loop,
    by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop))
  )

  # Return main
  return(main)
}

#' @rdname add_loop_age_dummy
#'
#' @param ind_gender Column name for individual gender.
#' @param gender Response options of interest, e.g. "Female".
#'
#' @export
add_loop_age_gender_dummy <- function(
  loop,
  ind_age = "ind_age",
  lb = 5,
  ub = 18,
  ind_gender = "ind_gender",
  gender = "female",
  new_colname = NULL
) {
  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(loop, c(ind_age, ind_gender), "loop")

  # Check if ind_age is numeric
  are_cols_numeric(loop, ind_age)

  # Create new column name
  if (is.null(new_colname)) {
    new_colname <- paste0(ind_age, "_", gender, "_", lb, "_", ub)
  }

  # Check if newcolname exists in the dataframe, if yes throw a warning for replacement
  if (new_colname %in% names(loop)) {
    rlang::warn(paste0(
      new_colname,
      " already exists in the data frame. It will be replaced."
    ))
  }

  #------ Compute

  # Create dummy
  loop <- dplyr::mutate(
    loop,
    "{new_colname}" := dplyr::case_when(
      !!rlang::sym(ind_age) >= lb &
        !!rlang::sym(ind_age) <= ub &
        !!rlang::sym(ind_gender) %in% gender ~
        1,
      .default = 0
    )
  )

  return(loop)
}

#' @rdname add_loop_age_dummy
#' @param ind_age_gender_dummy Column name for the dummy variable of the age-gender class.
#'
#' @export
add_loop_age_gender_dummy_to_main <- function(
  main,
  loop,
  ind_age_gender_dummy = "ind_age_female_5_18",
  id_col_main = "uuid",
  id_col_loop = "uuid",
  new_colname = NULL
) {
  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(loop, c(ind_age_gender_dummy, id_col_loop), "loop")
  if_not_in_stop(main, id_col_main, "main")

  # Check if all values from ind_age_gender_dummy are (0,1)
  are_values_in_set(loop, ind_age_gender_dummy, c(0, 1))

  # Create new column name
  if (is.null(new_colname)) {
    new_colname <- paste0(ind_age_gender_dummy, "_n")
  }

  # Check if newcolname exists in the dataframe, if yes throw a warning for replacement
  if (new_colname %in% names(main)) {
    rlang::warn(paste0(
      new_colname,
      " already exists in the data frame. It will be replaced."
    ))
  }

  #------ Compute

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Sum the dummy variable
  loop <- dplyr::summarize(
    loop,
    "{new_colname}" := sum(!!rlang::sym(ind_age_gender_dummy))
  )

  # Remove columns in main that exists in loop, but the grouping ones
  main <- impactR.utils::df_diff(main, loop, !!rlang::sym(id_col_main))

  # Merge the loop to the main dataset
  main <- dplyr::left_join(
    main,
    loop,
    by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop))
  )

  # Return main
  return(main)
}
