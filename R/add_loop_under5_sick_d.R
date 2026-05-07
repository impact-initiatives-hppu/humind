#' ANA function
#' 2025 INDICATOR ID: IND015, IND016, IND017
#' 2026 METRIC ID: TBD

#' @title Add Under-5 Sick Dummy Variables to Individual Data
#'
#' @description Adds dummy (0/1/NA) variables for illness and illness type to
#' individual-level loop data. Illness type columns are derived from
#' select_multiple binary columns built as `<ind_under5_sick_symptoms><sep><choice>`.
#'
#' @param loop A data frame of individual-level data.
#' @param ind_under5_sick_yn Column name for the sick yes/no question.
#' @param ind_under5_sick_yn_yes Level for "yes".
#' @param ind_under5_sick_yn_no Level for "no".
#' @param ind_under5_sick_yn_dnk Level for "don't know".
#' @param ind_under5_sick_yn_pnta Level for "prefer not to answer".
#' @param ind_under5_sick_symptoms Base column name for the select_multiple symptoms question.
#' @param ind_under5_sick_symptoms_respiratory Character vector of choice names for respiratory
#'   symptoms (combined with `ind_under5_sick_symptoms` and `sep`). The dummy is 1 if the
#'   individual is sick AND any of these symptom columns is 1.
#' @param ind_under5_sick_symptoms_watery Character vector of choice names for watery diarrhoea
#'   symptoms (combined with `ind_under5_sick_symptoms` and `sep`). The dummy is 1 if the
#'   individual is sick AND any of these symptom columns is 1.
#' @param sep Separator between the base column name and the choice name. Default `"/"`.
#'
#' @return A data frame with additional columns:
#'
#' * nut_ind_under5_sick_yes_d: Dummy variable (1/0/NA) for under-5 sick.
#' * nut_ind_under5_sick_yes_respiratory_d: Dummy variable (1/0/NA) for sick with any respiratory
#'   symptom. 1 = sick and any respiratory column is 1; 0 = not sick, or sick and all
#'   respiratory columns are 0; NA otherwise.
#' * nut_ind_under5_sick_yes_watery_d: Dummy variable (1/0/NA) for sick with any watery
#'   diarrhoea symptom. Same logic as above.
#'
#' @export
add_loop_under5_sick_d <- function(
  loop,
  ind_under5_sick_yn = "nut_ind_under5_sick_yn",
  ind_under5_sick_yn_yes = "yes",
  ind_under5_sick_yn_no = "no",
  ind_under5_sick_yn_dnk = "dnk",
  ind_under5_sick_yn_pnta = "pnta",
  ind_under5_sick_symptoms = "nut_ind_under5_sick_symptoms",
  ind_under5_sick_symptoms_respiratory = "cough",
  ind_under5_sick_symptoms_watery = "diarrhoea",
  sep = "/"
) {
  #------ Checks

  # Build binary column name vectors from base + sep + choices
  respiratory_col_names <- paste0(
    ind_under5_sick_symptoms,
    sep,
    ind_under5_sick_symptoms_respiratory
  )
  watery_col_names <- paste0(
    ind_under5_sick_symptoms,
    sep,
    ind_under5_sick_symptoms_watery
  )

  # required columns are in loop
  if_not_in_stop(
    loop,
    c(ind_under5_sick_yn, respiratory_col_names, watery_col_names),
    "loop"
  )

  # Get levels vector for yn
  ind_under5_sick_yn_levels <- c(
    ind_under5_sick_yn_yes,
    ind_under5_sick_yn_no,
    ind_under5_sick_yn_dnk,
    ind_under5_sick_yn_pnta
  )

  # values are in set
  are_values_in_set(loop, ind_under5_sick_yn, ind_under5_sick_yn_levels)
  are_values_in_set(loop, c(respiratory_col_names, watery_col_names), c(0, 1))

  # Warn if output columns already exist
  if ("nut_ind_under5_sick_yes_d" %in% colnames(loop)) {
    rlang::warn(
      "nut_ind_under5_sick_yes_d already exists in loop. It will be replaced."
    )
  }
  if ("nut_ind_under5_sick_yes_respiratory_d" %in% colnames(loop)) {
    rlang::warn(
      "nut_ind_under5_sick_yes_respiratory_d already exists in loop. It will be replaced."
    )
  }
  if ("nut_ind_under5_sick_yes_watery_d" %in% colnames(loop)) {
    rlang::warn(
      "nut_ind_under5_sick_yes_watery_d already exists in loop. It will be replaced."
    )
  }

  #------ Compute

  yn_col <- rlang::sym(ind_under5_sick_yn)

  loop <- dplyr::mutate(
    loop,
    # Sick dummy
    nut_ind_under5_sick_yes_d = dplyr::case_when(
      !!yn_col == ind_under5_sick_yn_no ~ 0,
      !!yn_col == ind_under5_sick_yn_yes ~ 1,
      !!yn_col %in%
        c(ind_under5_sick_yn_dnk, ind_under5_sick_yn_pnta) ~ NA_real_,
      .default = NA_real_
    ),
    # Respiratory: 1 if sick AND any respiratory col is 1;
    # 0 if not sick, or sick and all respiratory cols are 0 (none NA);
    # NA otherwise
    nut_ind_under5_sick_yes_respiratory_d = dplyr::case_when(
      nut_ind_under5_sick_yes_d == 0 ~ 0,
      nut_ind_under5_sick_yes_d == 1 &
        rowSums(
          dplyr::pick(dplyr::all_of(respiratory_col_names)) == 1,
          na.rm = TRUE
        ) >
          0 ~ 1,
      nut_ind_under5_sick_yes_d == 1 &
        rowSums(is.na(dplyr::pick(dplyr::all_of(respiratory_col_names)))) ==
          0 ~ 0,
      .default = NA_real_
    ),
    # Watery: same logic with watery cols
    nut_ind_under5_sick_yes_watery_d = dplyr::case_when(
      nut_ind_under5_sick_yes_d == 0 ~ 0,
      nut_ind_under5_sick_yes_d == 1 &
        rowSums(
          dplyr::pick(dplyr::all_of(watery_col_names)) == 1,
          na.rm = TRUE
        ) >
          0 ~ 1,
      nut_ind_under5_sick_yes_d == 1 &
        rowSums(is.na(dplyr::pick(dplyr::all_of(watery_col_names)))) == 0 ~ 0,
      .default = NA_real_
    )
  )

  return(loop)
}


#' @rdname add_loop_under5_sick_d
#'
#' @title Add Under-5 Sick Counts to Main Dataset
#'
#' @description Aggregates individual-level under-5 sick dummy variables to the
#' household level by summing them per household.
#'
#' @param main A data frame of household-level data.
#' @param loop A data frame of individual-level data.
#' @param ind_under5_sick_yes_d Binary variable for under-5 sick.
#' @param ind_under5_sick_yes_respiratory_d Binary variable for sick with respiratory symptom.
#' @param ind_under5_sick_yes_watery_d Binary variable for sick with watery diarrhoea symptom.
#' @param id_col_main Column name for the unique identifier in `main`.
#' @param id_col_loop Column name for the unique identifier in `loop`.
#'
#' @return A data frame with additional columns:
#'
#' * nut_ind_under5_sick_yes_d_n: Count of under-5 sick individuals per household.
#' * nut_ind_under5_sick_yes_respiratory_d_n: Count with respiratory symptom per household.
#' * nut_ind_under5_sick_yes_watery_d_n: Count with watery diarrhoea symptom per household.
#'
#' @export
add_loop_under5_sick_d_to_main <- function(
  main,
  loop,
  ind_under5_sick_yes_d = "nut_ind_under5_sick_yes_d",
  ind_under5_sick_yes_respiratory_d = "nut_ind_under5_sick_yes_respiratory_d",
  ind_under5_sick_yes_watery_d = "nut_ind_under5_sick_yes_watery_d",
  id_col_main = "uuid",
  id_col_loop = "uuid"
) {
  #------ Checks

  vars <- c(
    ind_under5_sick_yes_d,
    ind_under5_sick_yes_respiratory_d,
    ind_under5_sick_yes_watery_d
  )

  # vars are in loop
  if_not_in_stop(loop, vars, "loop")

  # id_cols are in df
  if_not_in_stop(main, id_col_main, "main")
  if_not_in_stop(loop, id_col_loop, "loop")

  # values are in set
  are_values_in_set(loop, vars, c(0, 1))

  #  new colnames
  vars_n <- paste0(vars, "_n")

  # Warn if output cols already exist in main
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
  if (vars_n[3] %in% colnames(main)) {
    rlang::warn(paste0(
      vars_n[3],
      " already exists in 'main'. It will be replaced."
    ))
  }

  #------ Compute

  # Sum the dummy variables per household
  loop_vars <- dplyr::summarize(
    dplyr::group_by(loop, !!rlang::sym(id_col_loop)),
    dplyr::across(
      dplyr::all_of(vars),
      \(x) sum(x, na.rm = FALSE),
      .names = "{.col}_n"
    )
  )

  # Remove overlapping cols from main (except uuid cols), then join
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
