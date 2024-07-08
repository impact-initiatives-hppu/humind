#' Add healthcare needed category to loop data (incl. WGQ-SS if provided)
#'
#' @param loop A data frame of individual-level data.
#' @param ind_healthcare_needed The name of the variable that indicates if healthcare is needed.
#' @param ind_healthcare_needed_levels A character vector of levels for ind_healthcare_needed.
#' @param ind_healthcare_received The name of the variable that indicates if healthcare is received.
#' @param ind_healthcare_received_levels A character vector of levels for ind_healthcare_received.
#' @param wgq_dis The name of the variable that indicates if the individual has a disability (usual cut-offs are 3).
#' @param ind_age The name of the variable that indicates the age of the individual.
#'
#' @export
add_loop_healthcare_needed_cat <- function(
    loop,
    ind_healthcare_needed = "health_ind_healthcare_needed",
    ind_healthcare_needed_levels = c("no", "yes", "dnk", "pnta"),
    ind_healthcare_received = "health_ind_healthcare_received",
    ind_healthcare_received_levels = c("no", "yes", "dnk", "pnta"),
    wgq_dis = NULL,
    ind_age = "ind_age"){

    #------ Checks

    # Check if the variables are in the data frame
    if_not_in_stop(loop, c(ind_healthcare_needed, ind_healthcare_received), "loop")
    if (!is.null(wgq_dis)) if_not_in_stop(loop, c(wgq_dis, ind_age), "loop")

    # Check that values are in set
    are_values_in_set(loop, ind_healthcare_needed, ind_healthcare_needed_levels)
    are_values_in_set(loop, ind_healthcare_received, ind_healthcare_received_levels)

    # Check that wgq_dis have values in set 1 and 0, and if ind_age is below 5, then wgq_dis should be NA
    if (!is.null(wgq_dis)) {
      are_values_in_set(loop, wgq_dis, c(0, 1))
      if (any(loop[[ind_age]] < 5 & !is.na(loop[[wgq_dis]]))) {
        rlang::abort("If ind_age is below 5, then wgq_dis should be NA.")
      }
    }

    # Check that both are of length 4
    if (length(ind_healthcare_needed_levels) != 4 | length(ind_healthcare_received_levels) != 4) rlang::abort("Both levels must be of length 4")

    # Calculate dummy variables
    loop <- dplyr::mutate(
      loop,
      health_ind_healthcare_needed_d = dplyr::case_when(
        !!rlang::sym(ind_healthcare_needed) == ind_healthcare_needed_levels[1] ~ 0,
        !!rlang::sym(ind_healthcare_needed) == ind_healthcare_needed_levels[2] ~ 1,
        !!rlang::sym(ind_healthcare_needed) %in% ind_healthcare_needed_levels[3:4] ~ NA_real_,
        .default = NA_real_),
      health_ind_healthcare_received_d = dplyr::case_when(
        !!rlang::sym(ind_healthcare_received) == ind_healthcare_received_levels[1] ~ 0,
        !!rlang::sym(ind_healthcare_received) == ind_healthcare_received_levels[2] ~ 1,
        !!rlang::sym(ind_healthcare_received) %in% ind_healthcare_received_levels[3:4] ~ NA_real_,
        .default = NA_real_)
    )

    # Add final recoding
    loop <- dplyr::mutate(
      loop,
      health_ind_healthcare_needed_cat = dplyr::case_when(
        health_ind_healthcare_needed_d == 0 ~ "no_need",
        health_ind_healthcare_needed_d == 1 & health_ind_healthcare_received_d == 0 ~ "yes_unmet_need",
        health_ind_healthcare_needed_d == 1 & health_ind_healthcare_received_d == 1 ~ "yes_met_need",
        .default = NA_character_
        )
      )

    # Add dummy for each (no NA)
    loop <- dplyr::mutate(
      loop,
      health_ind_healthcare_needed_no = dplyr::case_when(
        health_ind_healthcare_needed_cat == "no_need" ~ 1,
        health_ind_healthcare_needed_cat %in% c("yes_met_need", "yes_unmet_need") ~ 0,
        .default = 0
      ),
      health_ind_healthcare_needed_yes_unmet = dplyr::case_when(
        health_ind_healthcare_needed_cat == "yes_unmet_need" ~ 1,
        health_ind_healthcare_needed_cat %in% c("no_need", "yes_met_need") ~ 0,
        .default = 0
      ),
      health_ind_healthcare_needed_yes_met = dplyr::case_when(
        health_ind_healthcare_needed_cat == "yes_met_need" ~ 1,
        health_ind_healthcare_needed_cat %in% c("no_need", "yes_unmet_need") ~ 0,
        .default = 0
      )
    )

    # If wgq_dis is not null had dummy if wgq_dis is 1
    if (!is.null(wgq_dis)) {
      loop <- dplyr::mutate(
        loop,
        health_ind_healthcare_needed_no_wgq_dis = dplyr::case_when(
          health_ind_healthcare_needed_no == 1 & !!rlang::sym(wgq_dis) == 1 ~ 1,
          health_ind_healthcare_needed_no == 1 & !!rlang::sym(wgq_dis) == 0 ~ 0,
          health_ind_healthcare_needed_no == 0 ~ 0,
          .default = 0
        ),
        health_ind_healthcare_needed_yes_unmet_wgq_dis = dplyr::case_when(
          health_ind_healthcare_needed_yes_unmet == 1 & !!rlang::sym(wgq_dis) == 1 ~ 1,
          health_ind_healthcare_needed_yes_unmet == 1 & !!rlang::sym(wgq_dis) == 0 ~ 0,
          health_ind_healthcare_needed_yes_unmet == 0 ~ 0,
          .default = 0
        ),
        health_ind_healthcare_needed_yes_met_wgq_dis = dplyr::case_when(
          health_ind_healthcare_needed_yes_met == 1 & !!rlang::sym(wgq_dis) == 1 ~ 1,
          health_ind_healthcare_needed_yes_met == 1 & !!rlang::sym(wgq_dis) == 0 ~ 0,
          health_ind_healthcare_needed_yes_met == 0 ~ 0,
          .default = 0
        )
      )
    }

    return(loop)
}


#' @rdname add_loop_healthcare_needed_cat
#'
#' @param main A data frame of household-level data.
#' @param loop A data frame of individual-level data.
#' @param ind_healthcare_needed_no The binary variable that indicates if healthcare is not needed.
#' @param ind_healthcare_needed_yes_unmet The binary variable that indicates if healthcare is needed but unmet.
#' @param ind_healthcare_needed_yes_met The binary variable that indicates if healthcare is needed and met.
#' @param ind_healthcare_needed_no_wgq_dis The binary variable that indicates if healthcare is not needed and the individual has a disability.
#' @param ind_healthcare_needed_yes_unmet_wgq_dis The binary variable that indicates if healthcare is needed but unmet and the individual has a disability.
#' @param ind_healthcare_needed_yes_met_wgq_dis The binary variable that indicates if healthcare is needed and met and the individual has a disability.
#' @param id_col_main The column name for the unique identifier in the main data frame.
#' @param id_col_loop The column name for the unique identifier in the loop data frame.
#'
#' @export
add_loop_healthcare_needed_cat_main <- function(
    main,
    loop,
    ind_healthcare_needed_no = "health_ind_healthcare_needed_no",
    ind_healthcare_needed_yes_unmet = "health_ind_healthcare_needed_yes_unmet",
    ind_healthcare_needed_yes_met = "health_ind_healthcare_needed_yes_met",
    ind_healthcare_needed_no_wgq_dis = NULL,
    ind_healthcare_needed_yes_unmet_wgq_dis = NULL,
    ind_healthcare_needed_yes_met_wgq_dis = NULL,
    id_col_main = "uuid",
    id_col_loop = "uuid"){

  #------ Checks

  # Check if vars are in loop
  vars <- c(ind_healthcare_needed_no, ind_healthcare_needed_yes_unmet, ind_healthcare_needed_yes_met)
  if_not_in_stop(loop, vars, "loop")
  if (!is.null(ind_healthcare_needed_no_wgq_dis)) if_not_in_stop(loop, c(ind_healthcare_needed_no_wgq_dis), "loop")
  if (!is.null(ind_healthcare_needed_yes_unmet_wgq_dis)) if_not_in_stop(loop, c(ind_healthcare_needed_yes_unmet_wgq_dis), "loop")
  if (!is.null(ind_healthcare_needed_yes_met_wgq_dis)) if_not_in_stop(loop, c(ind_healthcare_needed_yes_met_wgq_dis), "loop")

  # Check if id_cols are in df
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(loop, id_col_loop, "loop")

  # Check if values are in set
  are_values_in_set(loop, vars, c(0, 1))
  if (!is.null(ind_healthcare_needed_no_wgq_dis)) are_values_in_set(loop, ind_healthcare_needed_no_wgq_dis, c(0, 1))
  if (!is.null(ind_healthcare_needed_yes_unmet_wgq_dis)) are_values_in_set(loop, ind_healthcare_needed_yes_unmet_wgq_dis, c(0, 1))
  if (!is.null(ind_healthcare_needed_yes_met_wgq_dis)) are_values_in_set(loop, ind_healthcare_needed_yes_met_wgq_dis, c(0, 1))

  # Create new colnames
  vars_n <- paste0(vars, "_n")

  # Same for dis if not null
  if (!is.null(ind_healthcare_needed_no_wgq_dis)) new_colname_no_wgq_dis <- paste0(ind_healthcare_needed_no_wgq_dis, "_n")
  if (!is.null(ind_healthcare_needed_yes_unmet_wgq_dis)) new_colname_yes_unmet_wgq_dis <- paste0(ind_healthcare_needed_yes_unmet_wgq_dis, "_n")
  if (!is.null(ind_healthcare_needed_yes_met_wgq_dis)) new_colname_yes_met_wgq_dis <- paste0(ind_healthcare_needed_yes_met_wgq_dis, "_n")

  # Check if all these colnames are in main and throw a warning if they are
  if (vars_n[1] %in% colnames(main)) rlang::warn(paste0(vars_n[1], " already exists in 'main'. It will be replaced."))
  if (vars_n[2] %in% colnames(main)) rlang::warn(paste0(vars_n[2], " already exists in 'main'. It will be replaced."))
  if (vars_n[3] %in% colnames(main)) rlang::warn(paste0(vars_n[3], " already exists in 'main'. It will be replaced."))

  if (!is.null(ind_healthcare_needed_no_wgq_dis)) {
    if (ind_healthcare_needed_no_wgq_dis %in% colnames(main)) rlang::warn(paste0(ind_healthcare_needed_no_wgq_dis, " already exists in 'main'. It will be replaced."))
  }
  if (!is.null(ind_healthcare_needed_yes_unmet_wgq_dis)) {
    if (ind_healthcare_needed_yes_unmet_wgq_dis %in% colnames(main)) rlang::warn(paste0(ind_healthcare_needed_yes_unmet_wgq_dis, " already exists in 'main'. It will be replaced."))
  }
  if (!is.null(ind_healthcare_needed_yes_met_wgq_dis)) {
    if (ind_healthcare_needed_yes_met_wgq_dis %in% colnames(main)) rlang::warn(paste0(ind_healthcare_needed_yes_met_wgq_dis, " already exists in 'main'. It will be replaced."))
  }

  #------ Compute

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Sum the dummy variable
  loop <- dplyr::summarize(
    loop,
    dplyr::across(
      vars,
      \(x) sum(x, na.rm = FALSE),
      .names = "{.col}_n")
    )

  # Sum the dis dummy variable (if not null)
  if (!is.null(ind_healthcare_needed_no_wgq_dis)) {
    loop <- dplyr::summarize(
      loop,
      "{new_colname_no_wgq_dis}" := sum(!!rlang::sym(ind_healthcare_needed_no_wgq_dis), na.rm = FALSE)
    )
  }
  if (!is.null(ind_healthcare_needed_yes_unmet_wgq_dis)) {
    loop <- dplyr::summarize(
      loop,
      "{new_colname_yes_unmet_wgq_dis}" := sum(!!rlang::sym(ind_healthcare_needed_yes_unmet_wgq_dis), na.rm = FALSE)
    )
  }
  if (!is.null(ind_healthcare_needed_yes_met_wgq_dis)) {
    loop <- dplyr::summarize(
      loop,
      "{new_colname_yes_met_wgq_dis}" := sum(!!rlang::sym(ind_healthcare_needed_yes_met_wgq_dis), na.rm = FALSE)
    )
  }

  # Remove columns in main that exists in loop, but the grouping ones
  main <- impactR.utils::df_diff(main, loop, !!rlang::sym(id_col_main))

  # Join the data
  main <- dplyr::left_join(main, loop, by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop)))

  return(main)


}
