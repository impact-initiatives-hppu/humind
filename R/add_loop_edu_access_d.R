#' @title Add Education Access Dummy Variables
#'
#' @description This function adds dummy variables to an individual-level dataframe for all school-aged children.
#' It creates a variable (`edu_ind_access_d`) that indicates whether the child accessed school (1 if accessed, 0 otherwise) and another variable (`edu_ind_no_access_d`) that indicates no access to school.
#'
#' Prerequisite function:
#'
#' * add_loop_edu_ind_age_corrected.R
#'
#' @param loop A data frame of individual-level data for the loop.
#' @param ind_access Column name for education access.
#' @param yes Value indicating access to education (e.g., "yes").
#' @param no Value indicating no access to education (e.g., "no").
#' @param pnta Value indicating not applicable (e.g., "pnta").
#' @param dnk Value indicating don't know (e.g., "dnk").
#' @param ind_schooling_age_d Column name for the dummy variable indicating schooling age.
#'
#' @return A data frame with additional columns:
#'
#' * edu_ind_access_d: Dummy variable indicating access to education (1 if accessed, 0 otherwise).
#' * edu_ind_no_access_d: Dummy variable indicating no access to education (1 if not accessed, 0 otherwise).
#'
#' @export
add_loop_edu_access_d <- function(
  loop,
  ind_access = "edu_access",
  yes = "yes",
  no = "no",
  pnta = "pnta",
  dnk = "dnk",
  ind_schooling_age_d = "edu_ind_schooling_age_d"
) {
  #----- Checks

  # Check if the variable is in the data frame
  if_not_in_stop(loop, ind_access, "loop")
  if_not_in_stop(loop, ind_schooling_age_d, "loop")

  # Check that ind_access values are in set
  are_values_in_set(loop, ind_access, c(yes, no, pnta, dnk))

  # Check that ind_schooling_age 0:1
  are_values_in_range(loop, ind_schooling_age_d, 0, 1)

  # Warn if edu_ind_access_d and edu_ind_no_access_d exists in loop and will be replaced
  if ("edu_ind_access_d" %in% colnames(loop)) {
    rlang::warn("edu_ind_access_d already exists in loop. It will be replaced.")
  }
  if ("edu_ind_no_access_d" %in% colnames(loop)) {
    rlang::warn(
      "edu_ind_no_access_d already exists in loop. It will be replaced."
    )
  }

  #Check

  #------ Recode

  loop <- dplyr::mutate(
    loop,
    edu_ind_access_d = dplyr::case_when(
      !!rlang::sym(ind_schooling_age_d) == 0 ~ NA_real_,
      !!rlang::sym(ind_schooling_age_d) == 1 & !!rlang::sym(ind_access) == yes ~
        1,
      !!rlang::sym(ind_schooling_age_d) == 1 & !rlang::sym(ind_access) == no ~
        0,
      !!rlang::sym(ind_schooling_age_d) == 1 &
        !!rlang::sym(ind_access) %in% c(pnta, dnk) ~
        NA_real_,
      .default = NA_real_
    ),
    edu_ind_no_access_d = dplyr::case_when(
      !!rlang::sym(ind_schooling_age_d) == 0 ~ NA_real_,
      !!rlang::sym(ind_schooling_age_d) == 1 & !!rlang::sym(ind_access) == yes ~
        0,
      !!rlang::sym(ind_schooling_age_d) == 1 & !rlang::sym(ind_access) == no ~
        1,
      !!rlang::sym(ind_schooling_age_d) == 1 &
        !!rlang::sym(ind_access) %in% c(pnta, dnk) ~
        NA_real_,
      .default = NA_real_
    )
  )

  return(loop)
}

#' @rdname add_loop_edu_access_d
#'
#' @param main A data frame of household-level data.
#' @param ind_access_d Column name for education access (binary).
#' @param ind_no_access_d Column name for education no access (binary).
#' @param id_col_main Column name for the unique identifier in the main dataset.
#' @param id_col_loop Column name for the unique identifier in the loop dataset.
#'
#' @export
add_loop_edu_access_d_to_main <- function(
  main,
  loop,
  ind_access_d = "edu_ind_access_d",
  ind_no_access_d = "edu_ind_no_access_d",
  id_col_main = "uuid",
  id_col_loop = "uuid"
) {
  #------ Checks

  # Check if id_cols are in df
  if_not_in_stop(loop, ind_access_d, "loop")
  if_not_in_stop(loop, ind_no_access_d, "loop")
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(loop, id_col_loop, "loop")

  # Checks that values are in range 0:1
  are_values_in_range(loop, ind_access_d, 0, 1)
  are_values_in_range(loop, ind_no_access_d, 0, 1)

  # Check if new colname is in main and throw a warning if it is
  ind_access_d_n <- paste0(ind_access_d, "_n")
  ind_no_access_d_n <- paste0(ind_no_access_d, "_n")
  if (ind_access_d_n %in% colnames(main)) {
    rlang::warn(paste0(
      ind_access_d_n,
      " already exists in the data frame. It will be replaced."
    ))
  }
  if (ind_no_access_d_n %in% colnames(main)) {
    rlang::warn(paste0(
      ind_no_access_d_n,
      " already exists in the data frame. It will be replaced."
    ))
  }

  #------ Compute

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Sum the dummy variable
  loop <- dplyr::summarize(
    loop,
    "edu_access_n" := sum(!!rlang::sym(ind_access_d), na.rm = TRUE),
    "edu_no_access_n" := sum(!!rlang::sym(ind_no_access_d), na.rm = TRUE)
  )

  # Remove columns in main that exists in loop, but the grouping ones
  main <- impactR.utils::df_diff(main, loop, !!rlang::sym(id_col_main))

  # Join the data
  main <- dplyr::left_join(
    main,
    loop,
    by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop))
  )

  # Return main
  return(main)
}
