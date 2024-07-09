#' Add education disruption categories
#'
#' [add_loop_edu_disrupted_d()] adds the education disruption and binaries and [add_loop_edu_disrupted_d_to_main()] adds the education disruption summarised binaries and the category to the main dataset.
#'
#' @param df A data frame.
#' @param occupation Column name for occupation disruption.
#' @param hazards Column name for hazards disruption.
#' @param displaced Column name for displaced disruption.
#' @param teacher Column name for teacher disruption.
#' @param levels Vector of levels for the disruption variables.
#' @param ind_schooling_age_d Column name for the dummy variable of the schooling age class.
#'
#' @export
add_loop_edu_disrupted_d <- function(
    df,
    occupation = "edu_disrupted_occupation",
    hazards = "edu_disrupted_hazards",
    displaced = "edu_disrupted_displaced",
    teacher = "edu_disrupted_teacher",
    levels = c("yes", "no", "dnk", "pnta"),
    ind_schooling_age_d = "edu_ind_schooling_age_d"
){

  #----- Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, c(occupation, hazards, displaced, teacher), "df")
  if_not_in_stop(df, ind_schooling_age_d, "df")

  # Check if values are in set
  are_values_in_set(df, c(occupation, hazards, displaced, teacher), levels)

  # Check that ind_schooling_age 0:1
  are_values_in_range(df, ind_schooling_age_d, 0, 1)

  # Length of levels is 4
  if (length(levels) != 4) {rlang::abort("levels must be of length 4.")}

  # Check if new colnames are in main and throw a warning if it is
  occupation_d <- paste0(occupation, "_d")
  hazards_d <- paste0(hazards, "_d")
  displaced_d <- paste0(displaced, "_d")
  teacher_d <- paste0(teacher, "_d")
  if (occupation_d %in% colnames(df)) {
    rlang::warn(paste0(occupation_d, " already exists in df. It will be replaced."))
  }
  if (hazards_d %in% colnames(df)) {
    rlang::warn(paste0(hazards_d, " already exists in df. It will be replaced."))
  }
  if (displaced_d %in% colnames(df)) {
    rlang::warn(paste0(displaced_d, " already exists in df. It will be replaced."))
  }
  if (teacher_d %in% colnames(df)) {
    rlang::warn(paste0(teacher_d, " already exists in df. It will be replaced."))
  }
  if ("edu_ind_disrupted_cat" %in% colnames(df)) {
    rlang::warn("edu_ind_disrupted_cat already exists in df. It will be replaced.")
  }

  #------ Recode

  # Let's create dummies for each dimension
  df <- dplyr::mutate(
    df,
    dplyr::across(
      dplyr::all_of(c(occupation, hazards, displaced, teacher)),
      \(x) dplyr::case_when(
        !!rlang::sym("ind_schooling_age_d") == 0 ~ NA_real_,
        x == levels[1] ~ 1,
        x == levels[2] ~ 0,
        x %in% levels[3:4] ~ NA_real_,
        TRUE ~ NA_real_
      ),
      .names = "{.col}_d"
    )
  )

  return(df)
}

#' @rdname add_loop_edu_disrupted_d
#'
#' @param main A data frame of household-level data.
#' @param loop A data frame of individual-level data.
#' @param occupation_d Column name for the dummy variable of the occupation dimension.
#' @param hazards_d Column name for the dummy variable of the hazards dimension.
#' @param displaced_d Column name for the dummy variable of the displaced dimension.
#' @param teacher_d Column name for the dummy variable of the teacher dimension.
#' @param id_col_main Column name for the unique identifier in the main dataset.
#' @param id_col_loop Column name for the unique identifier in the loop dataset.
#'
#' @export
add_loop_edu_disrupted_d_to_main <- function(
    main,
    loop,
    occupation_d = "edu_disrupted_occupation_d",
    hazards_d = "edu_disrupted_hazards_d",
    displaced_d = "edu_disrupted_displaced_d",
    teacher_d = "edu_disrupted_teacher_d",
    id_col_main = "uuid",
    id_col_loop = "uuid"
    ){

  #----- Checks

  # Check if the variables are in the data frame
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(loop, id_col_loop, "loop")
  if_not_in_stop(main, c(occupation_d, hazards_d, displaced_d, teacher_d), "main")

  # Check if dummies are 0 and 1
  are_values_in_set(loop, c(occupation_d, hazards_d, displaced_d, teacher_d), 0:1)

  # Check if new colnames are in main and throw a warning if it is
  occupation_d_n <- paste0(occupation_d, "_n")
  hazards_d_n <- paste0(hazards_d, "_n")
  displaced_d_n <- paste0(displaced_d, "_n")
  teacher_d_n <- paste0(teacher_d, "_n")
  if (occupation_d_n %in% colnames(main)) {
    rlang::warn(paste0(occupation_d_n, " already exists in main. It will be replaced."))
  }

  #----- Merge

  # Group loop by id_col_loop
  loop <- dplyr::group_by(loop, !!rlang::sym(id_col_loop))

  # Summarize to paste _n
  loop <- dplyr::summarize(
    loop,
    "{occupation_d}_n" = sum(!!rlang::sym(occupation_d), na.rm = TRUE),
    "{hazards_d}_n" = sum(!!rlang::sym(hazards_d), na.rm = TRUE),
    "{displaced_d}_n" = sum(!!rlang::sym(displaced_d), na.rm = TRUE),
    "{teacher_d}_n" = sum(!!rlang::sym(teacher_d), na.rm = TRUE)
  )

  # Remove columns in main that exists in loop, but the grouping ones
  main <- impactR.utils::df_diff(main, loop, !!rlang::sym(id_col_main))

  # Join
  main <- dplyr::left_join(main, loop, by = dplyr::join_by(!!rlang::sym(id_col_main) == !!rlang::sym(id_col_loop)))

  return(main)

}
