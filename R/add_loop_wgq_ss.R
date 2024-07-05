#' Prepare dummy variables for each WG-SS component (individual data)
#'
#' [add_loop_wgq_ss] prepares dummy variables for each WG-SS component (vision, hearing, mobility, cognition, self-care, communication) and their levels (no difficulty, some difficulty, a lot of difficulty, cannot do at all) and combines them into the sum of domains coded for each level (e.g, wgq_cannot_do_n), and disability binary cut-offs variables (wgq_dis_1, wgq_dis_2, wgq_dis_3, wgq_dis_4).
#'
#' @param loop A data frame of individual-level data.
#' @param ind_age The individual age column.
#' @param vision Vision component column.
#' @param hearing Hearing component column.
#' @param mobility Mobility component column.
#' @param cognition Cognition component column.
#' @param self_care Self-care component column.
#' @param communication Communication component column.
#' @param no_difficulty Level for no difficulty.
#' @param some_difficulty Level for some difficulty.
#' @param lot_of_difficulty Level for a lot of difficulty.
#' @param cannot_do Level for cannot do at all.
#' @param undefined Vector of undefined responses, such as Prefer not to answer and Don't know.
#'
#' @export
add_loop_wgq_ss <- function(
    loop,
    ind_age = "ind_age",
    vision =" wgq_vision",
    hearing = "wgq_hearing",
    mobility = "wgq_mobility",
    cognition = "wgq_cognition",
    self_care = "wgq_self_care",
    communication = "wgq_communication",
    no_difficulty = "no_difficulty",
    some_difficulty = "some_difficulty",
    lot_of_difficulty = "lot_of_difficulty",
    cannot_do = "cannot_do",
    undefined = c("dnk", "pnta")){

  #------ Checks

  # Get vars
  wgq_vars <- c(vision, hearing, mobility, cognition, self_care, communication)

  wgq_vars_cannot_do <- paste0(wgq_vars, "_cannot_do_d")
  wgq_vars_lot_of_difficulty <- paste0(wgq_vars, "_lot_of_difficulty_d")
  wgq_vars_some_difficulty <- paste0(wgq_vars, "_some_difficulty_d")
  wqg_vars_no_difficulty <- paste0(wgq_vars, "_no_difficulty_d")

  # Check that levels no_diff to cannot_do are of length 1
  if (length(no_difficulty) != 1 | length(some_difficulty) != 1 | length(lot_of_difficulty) != 1 | length(cannot_do) != 1) {
    rlang::abort("no_difficulty, some_difficulty, lot_of_difficulty, cannot_do must be of length 1.")
  }

  # Levels
  levels <- c(no_difficulty, some_difficulty, lot_of_difficulty, cannot_do, undefined)

  # Check if the variables are in the data frame
  if_not_in_stop(loop, ind_age, "loop")
  if_not_in_stop(loop, wgq_vars, "loop")

  # Check that values are in set
  are_values_in_set(loop, wgq_vars, levels)

  #------ Recode

  # Create age above 5 dummy
  loop <- add_loop_age_dummy(
    loop = loop,
    ind_age = ind_age,
    lb = 5,
    ub = 120,
    new_colname = "ind_age_above_5")


  # Add cannot do binaries
  loop <- dplyr::mutate(
    loop,
    dplyr::across(
      wgq_vars,
      \(x) dplyr::case_when(
        ind_age_above_5 == 0 ~ NA_real_,
        ind_age_above_5 == 1 & x %in% undefined ~ NA_real_,
        ind_age_above_5 == 1 & x == cannot_do ~ 1,
        ind_age_above_5 == 1 & x %in% c(no_difficulty, some_difficulty, lot_of_difficulty) ~ 0,
        .default = NA_real_
      ),
      .names = "{.col}_cannot_do_d"
    )
  )


  # Add lot of difficulty binaries
  loop <- dplyr::mutate(
    loop,
    dplyr::across(
      wgq_vars,
      \(x) dplyr::case_when(
        ind_age_above_5 == 0 ~ NA_real_,
        ind_age_above_5 == 1 & x %in% undefined ~ NA_real_,
        ind_age_above_5 == 1 & x == lot_of_difficulty ~  1,
        ind_age_above_5 == 1 & x %in% c( no_difficulty, some_difficulty, cannot_do) ~ 0,
        .default = NA_real_
      ),
      .names = "{.col}_lot_of_difficulty_d"
    )
  )

  # Add some difficulty binaries
  loop <- dplyr::mutate(
    loop,
    dplyr::across(
      wgq_vars,
      \(x) dplyr::case_when(
        ind_age_above_5 == 0 ~ NA_real_,
        ind_age_above_5 == 1 & x %in% undefined ~ NA_real_,
        ind_age_above_5 == 1 & x == some_difficulty ~ 1,
        ind_age_above_5 == 1 & x %in% c(no_difficulty, lot_of_difficulty, cannot_do) ~ 0,
        .default = NA_real_
      ),
      .names = "{.col}_some_difficulty_d"
    )
  )

  # Add no difficulty binaries
  loop <- dplyr::mutate(
    loop,
    dplyr::across(
      wgq_vars,
      \(x) dplyr::case_when(
        ind_age_above_5 == 0 ~ NA_real_,
        ind_age_above_5 == 1 & x %in% undefined ~ NA_real_,
        ind_age_above_5 == 1 & x == no_difficulty ~ 1,
        ind_age_above_5 == 1 & x %in% c(some_difficulty, lot_of_difficulty, cannot_do) ~ 0,
        .default = NA_real_
      ),
      .names = "{.col}_no_difficulty_d"
    )
  )


  # Add sum of cannot do across all components
  loop <- sum_vars(loop, wgq_vars_cannot_do, "wgq_cannot_do_n")

  # Add sum of lot of difficulty across all components
  loop <- sum_vars(loop, wgq_vars_lot_of_difficulty, "wgq_lot_of_difficulty_n")

  # Add sum of some difficulty across all components
  loop <- sum_vars(loop, wgq_vars_some_difficulty, "wgq_some_difficulty_n")

  # Add sum of no difficulty across all components
  loop <- sum_vars(loop, wqg_vars_no_difficulty, "wgq_no_difficulty_n")


  # Add binary cannot do across all components
  loop <- dplyr::mutate(
    loop,
    wgq_cannot_do_d = dplyr::case_when(
      dplyr::if_any(wgq_vars_cannot_do, \(x) x == 1) ~ 1,
      dplyr::if_all(wgq_vars_cannot_do, \(x) x == 0) ~ 0,
      .default = NA_real_
    )
  )

  # Add binary lot of difficulty across all components
  loop <- dplyr::mutate(
    loop,
    wgq_lot_of_difficulty_d = dplyr::case_when(
      dplyr::if_any(wgq_vars_lot_of_difficulty, \(x) x == 1) ~ 1,
      dplyr::if_all(wgq_vars_lot_of_difficulty, \(x) x == 0) ~ 0,
      .default = NA_real_
    )
  )

  # Add binary some difficulty across all components
  loop <- dplyr::mutate(
    loop,
    wgq_some_difficulty_d = dplyr::case_when(
      dplyr::if_any(wgq_vars_some_difficulty, \(x) x == 1) ~ 1,
      dplyr::if_all(wgq_vars_some_difficulty, \(x) x == 0) ~ 0,
      .default = NA_real_
    )
  )

  # Add binary no difficulty across all components
  loop <- dplyr::mutate(
    loop,
    wgq_no_difficulty_d = dplyr::case_when(
      dplyr::if_any(wqg_vars_no_difficulty, \(x) x == 1) ~ 1,
      dplyr::if_all(wqg_vars_no_difficulty, \(x) x == 0) ~ 0,
      .default = NA_real_
    )
  )

  # Add final cut-offs - disability 4 - the level of inclusion is any one domain is coded CANNOT DO AT ALL (4)
  loop <- dplyr::mutate(loop, wgq_dis_4 = !!rlang::sym("wgq_cannot_do_d"))

  # Add final cut-offs - disability 3 -  the level of inclusion is any 1 domain/question is coded A LOT OF DIFFICULTY or CANNOT DO AT ALL.
  loop <- dplyr::mutate(loop, wgq_dis_3 = dplyr::case_when(
    wgq_dis_4 == 1 ~ 1,
    wgq_lot_of_difficulty_d == 1 ~ 1,
    wgq_dis_4 == 0 & wgq_lot_of_difficulty_d == 0 ~ 0,
    .default = NA_real_
  ))

  # Add final cut-offs - disability 2 -  the level of inclusion is at least 2 domains/questions are coded SOME DIFFICULTY or any 1 domain/question is coded A LOT OF DIFFICULTY or CANNOT DO AT ALL
  loop <- dplyr::mutate(
    loop,
    wgq_dis_2 = dplyr::case_when(
      wgq_dis_4 == 1 ~ 1,
      wgq_dis_3 == 1 ~ 1,
      wgq_some_difficulty_n >= 2 ~ 1,
      wgq_dis_3 == 0 & wgq_dis_4 == 0 & wgq_some_difficulty_n < 2 ~ 0,
      .default = NA_real_
    )
  )

  # Add final cut-offs - disability 1 - the level of inclusion is at least one domain/question is coded SOME DIFFICULTY or A LOT OF DIFFICULTY or CANNOT DO AT ALL.
  loop <- dplyr::mutate(
    loop,
    wgq_dis_1 = dplyr::case_when(
      wgq_dis_4 == 1 ~ 1,
      wgq_dis_3 == 1 ~ 1,
      wgq_some_difficulty_d == 1 ~ 1,
      wgq_dis_3 == 0 & wgq_dis_4 == 0 & wgq_some_difficulty_d == 0 ~ 0,
      .default = NA_real_
    )
  )

  return(loop)
}


#' @rdname add_loop_wgq_ss
#'
#' @param main A data frame of household-level data.
#' @param wgq_dis_4 Column name for the disability 4 cut-offs binary.
#' @param wgq_dis_3 Column name for the disability 3 cut-offs binary.
#' @param wgq_dis_2 Column name for the disability 2 cut-offs binary.
#' @param wgq_dis_1 Column name for the disability 1 cut-offs binary.
#' @param ind_age_above_5 Column name for the age above 5 dummy in the individual-level dataset.
#' @param id_col_main Column name for the unique identifier in the main dataset.
#' @param id_col_loop Column name for the unique identifier in the loop dataset.
#'
#' @export
add_loop_wgq_ss_to_main <- function(
    main,
    loop,
    wgq_dis_4 = "wgq_dis_4",
    wgq_dis_3 = "wgq_dis_3",
    wgq_dis_2 = "wgq_dis_2",
    wgq_dis_1 = "wgq_dis_1",
    ind_age_above_5 = "ind_age_above_5",
    id_col_main = "uuid",
    id_col_loop = "uuid"){

  #------ Checks

  # Dis vars
  wgq_dis <- c(wgq_dis_4, wgq_dis_3, wgq_dis_2, wgq_dis_1)

  # Check if wgq dis is in loop
  if_not_in_stop(loop, wgq_dis, "loop")

  # Check if id_cols are in df
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(loop, id_col_loop, "loop")

  # Check if value is in set
  are_values_in_set(loop, wgq_dis, c(0,1))

  # Check if new colname is in main and throw a warning if it is
   wgq_dis_n <- paste0(wgq_dis, "_n")
   ind_age_above_5_n <- paste0(ind_age_above_5, "_n")

  # Warn if new columns in wgq_dis_n exists in 'main' and will be replaced (lapply wgq_dis_n)
  lapply(wgq_dis_n, \(x) {
    if (x %in% colnames(main)) {
      rlang::warn(paste0(x, " already exists in 'main'. It will be replaced."))
    }
  })


  if (ind_age_above_5_n %in% colnames(main)) {
    rlang::warn(paste0(ind_age_above_5_n, " already exists in 'main'. It will be replaced."))
  }


  #------ Compute

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Sum the dummy variable
  loop <- dplyr::summarize(
    loop,
    "{wgq_dis_n[1]}" := sum(!!rlang::sym(wgq_dis[1]), na.rm = TRUE),
    "{wgq_dis_n[2]}" := sum(!!rlang::sym(wgq_dis[2]), na.rm = TRUE),
    "{wgq_dis_n[3]}" := sum(!!rlang::sym(wgq_dis[3]), na.rm = TRUE),
    "{wgq_dis_n[4]}" := sum(!!rlang::sym(wgq_dis[4]), na.rm = TRUE),
    "{ind_age_above_5_n}" := sum(!!rlang::sym(ind_age_above_5), na.rm = TRUE)
  )

  # Add binary when at least one hh member has a difficulty in any considered dimension, for all thresholds
  loop <- dplyr::mutate(
    loop,
    dplyr::across(
      dplyr::all_of(wgq_dis_n),
      \(x) dplyr::case_when(
        x >= 1 ~ 1,
        x == 0 ~ 0,
        .default = NA_real_),
      .names = "{.col}_at_least_one"
      )
    )
  # Rename to remove the "_n"
  loop <- dplyr::rename_with(loop, ~ gsub("_n_at_least_one$", "_at_least_one", .), ends_with("_n_at_least_one"))

  # Remove columns in main that exists in loop, but the grouping ones
  main <- impactR.utils::df_diff(main, loop, !!rlang::sym(id_col_main))

  # Merge the loop to the main dataset
  main <- dplyr::left_join(main, loop, by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop)))

  # Return main
  return(main)

}
