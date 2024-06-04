#' Prepare dummy variables for each WG-SS component (individual data)
#'
#' @param loop A data frame of individual-level data.
#' @param ind_age The individual age column.
#' @param vision Vision component column.
#' @param hearing Hearing component column.
#' @param mobility Mobility component column.
#' @param cognition Cognition component column.
#' @param self_care Self-care component column.
#' @param communication Communication component column.
#' @param levels Character vector of responses codes, including first in the following order: "No difficulty", "Some difficulty", "A lot of difficulty", "Cannot do at all", e.g. c("no_difficulty", "some_difficulty", "lot_of_difficulty", "cannot_do").
#'
#' @return Fifteen new columns: each component dummy for levels 3 and 4, disability level 3, level 4, and level 3 and 4 together.
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
    levels = c("no_difficulty", "some_difficulty", "lot_of_difficulty", "cannot_do", "dnk", "pnta")){

  #------ Checks

  # Get vars
  wgq_vars <- c(vision, hearing, mobility, cognition, self_care, communication)
  wgq_vars_3 <- paste0(wgq_vars, "_3")
  wgq_vars_4 <- paste0(wgq_vars, "_4")

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

  # Add level 3 dummies
  loop <- dplyr::mutate(
    loop,
    dplyr::across(
      wgq_vars,
      \(x) dplyr::case_when(
        ind_age_above_5 == 0 ~ NA_real_,
        ind_age_above_5 == 1 & x %in% levels[5:6] ~ NA_real_,
        ind_age_above_5 == 1 & x == levels[3] ~  1,
        ind_age_above_5 == 1 & x == levels[4] ~ 0,
        ind_age_above_5 == 1 & x %in% levels[1:2] ~ 0,
        .default = NA_real_
      ),
      .names = "{.col}_3"
    )
  )

  # Add level 4 dummies
  loop <- dplyr::mutate(
    loop,
    dplyr::across(
      wgq_vars,
      \(x) dplyr::case_when(
        ind_age_above_5 == 0 ~ NA_real_,
        ind_age_above_5 == 1 & x %in% levels[5:6] ~ NA_real_,
        ind_age_above_5 == 1 & x == levels[4] ~ 1,
        ind_age_above_5 == 1 & x %in% levels[1:3] ~ 0,
        .default = NA_real_
      ),
      .names = "{.col}_4"
    )
  )

  # Add total dis level 3 dummies
  loop <- dplyr::mutate(
    loop,
    wgq_dis_3 = dplyr::case_when(
      dplyr::if_any(wgq_vars_3, \(x) x == 1) ~ 1,
      dplyr::if_all(wgq_vars_3, \(x) x == 0) ~ 0,
      .default = NA_real_
    )
  )

  # Add total dis level 4 dummies
  loop <- dplyr::mutate(
    loop,
    wgq_dis_4 = dplyr::case_when(
      dplyr::if_any(wgq_vars_4, \(x) x == 1) ~ 1,
      dplyr::if_all(wgq_vars_4, \(x) x == 0) ~ 0,
      .default = NA_real_
    )
  )

  loop <- dplyr::mutate(
    loop,
    wgq_dis = dplyr::case_when(
      wgq_dis_3 == 1 | wgq_dis_4 == 1 ~ 1,
      wgq_dis_3 == 0 & wgq_dis_4 == 0 ~ 0,
      .default = NA_real_
    )
  )

  return(loop)
}


#' @rdname add_loop_wgq_ss
#'
#' @param main A data frame of household-level data.
#' @param wgq_dis Column name for the disability dummy in the individual-level dataset.
#' @param ind_age_above_5 Column name for the age above 5 dummy in the individual-level dataset.
#' @param id_col_main Column name for the unique identifier in the main dataset.
#' @param id_col_loop Column name for the unique identifier in the loop dataset.
#'
#' @export
add_loop_wgq_ss_to_main <- function(
    main,
    loop,
    wgq_dis = "wgq_dis",
    ind_age_above_5 = "ind_age_above_5",
    id_col_main = "uuid",
    id_col_loop = "uuid"){

  #------ Checks

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

  if (wgq_dis_n %in% colnames(main)) {
    rlang::warn(paste0(wgq_dis_n, " already exists in 'main'. It will be replaced."))
  }
  if (ind_age_above_5_n %in% colnames(main)) {
    rlang::warn(paste0(ind_age_above_5_n, " already exists in 'main'. It will be replaced."))
  }


  #------ Compute

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Sum the dummy variable
  loop <- dplyr::summarize(
    loop,
    "{wgq_dis_n}" := sum(!!rlang::sym(wgq_dis), na.rm = TRUE),
    "{ind_age_above_5_n}" := sum(!!rlang::sym(ind_age_above_5), na.rm = TRUE)
  )

  # Remove columns in main that exists in loop, but the grouping ones
  main <- impactR.utils::df_diff(main, loop, !!rlang::sym(id_col_main))

  # Merge the loop to the main dataset
  main <- dplyr::left_join(main, loop, by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop)))

  # Return main
  return(main)

}
