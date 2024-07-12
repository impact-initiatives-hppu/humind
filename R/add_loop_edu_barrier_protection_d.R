#' Add a variable for child protection barriers to education
#'
#' [add_loop_edu_barrier_protection_d] adds a dummy variable to the individual-level data frame for all school-aged children, taking 1 if the child faces a protection barrier and 0 otherwise. [add_loop_edu_barrier_protection_d_to_main] aggregates the dummy variable to the household-level data frame.
#'
#' @param loop A data frame of individual-level data for the loop.
#' @param barriers Column name for the child protection barrier category.
#' @param protection_issues Vector of protection issues RESPONSE CODES.
#' @param ind_schooling_age_d Column name for the dummy variable of schooling age.
#'
#' @export
add_loop_edu_barrier_protection_d <- function(
    loop,
    barriers = "edu_barrier",
    protection_issues = c("protection_at_school", "protection_travel_school", "child_work_home", "child_work_outside", "child_armed_group", "child_marriage", "ban", "enroll_lack_documentation", "discrimination"),
    ind_schooling_age_d = "edu_ind_schooling_age_d"
){

  #----- Checks

  # Check if the variable is in the data frame
  if_not_in_stop(loop, barriers, "loop")
  if_not_in_stop(loop, ind_schooling_age_d, "loop")

  # Check that ind_schooling_age 0:1
  are_values_in_range(loop, ind_schooling_age_d, 0, 1)

  # Warn if edu_ind_barrier_cat exists in loop and will be replaced
  if ("edu_ind_barrier_child_prot_d" %in% colnames(loop)) {
    rlang::warn("edu_ind_barrier_child_prot_d already exists in loop. It will be replaced.")
  }

  #------ Recode

  loop <- dplyr::mutate(
    loop,
    # Level 4-5 categories --- dummy for protection and unable_severe
    edu_ind_barrier_protection_d = dplyr::case_when(
      !!rlang::sym(ind_schooling_age_d) == 0 ~ NA_real_,
      !!rlang::sym(barriers) %in% protection_issues ~ 1,
      .default = 0)
  )

  return(loop)

}

#' @rdname add_loop_edu_barrier_protection_d
#'
#' @param main A data frame of household-level data.
#' @param ind_barrier_protection_d Column name for the dummy variable of the child protection barrier category.
#' @param id_col_main Column name for the unique identifier in the main dataset.
#' @param id_col_loop Column name for the unique identifier in the loop dataset.
#'
#' @export
add_loop_edu_barrier_protection_d_to_main <- function(
    main,
    loop,
    ind_barrier_protection_d = "edu_ind_barrier_protection_d",
    id_col_main = "uuid",
    id_col_loop = "uuid"){

  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(loop, ind_barrier_protection_d, "loop")
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(loop, id_col_loop, "loop")

  # Check if new_colname exists in the dataframe, if yes throw a warning for replacement
  ind_barrier_protection_d_n <- paste0(ind_barrier_protection_d, "_n")
  if (ind_barrier_protection_d_n %in% colnames(main)) {
    rlang::warn(paste0(ind_barrier_protection_d_n, " already exists in the data frame. It will be replaced."))
  }

  #------ Compute

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Sum the dummy variable
  loop <- dplyr::summarize(
    loop,
    edu_barrier_protection_n := sum(!!rlang::sym(ind_barrier_protection_d), na.rm = TRUE)
  )

  # Remove columns in main that exists in loop, but the grouping ones
  main <- impactR.utils::df_diff(main, loop, !!rlang::sym(id_col_main))

  # Join loop to main
  main <- dplyr::left_join(main, loop, by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop)))

  return(main)

}
