#' add_prot_needs_movement
#'
#' @param df Data frame containing the survey data.
#' @param sep Separator for the binary columns, default is "/".
#' @param prot_needs_3_movement Column name
#' @param no_changes_feel_unsafe answer option
#' @param no_safety_concerns answer option
#' @param women_girls_avoid_places answer option
#' @param men_boys_avoid_places answer option
#' @param women_girls_avoid_night answer option
#' @param men_boys_avoid_night answer option
#' @param girls_boys_avoid_school answer option
#' @param different_routes answer option
#' @param avoid_markets answer option
#' @param avoid_public_offices answer option
#' @param avoid_fields answer option
#' @param other_safety_measures answer option
#' @param dnk answer option
#' @param pnta answer option
#' @param .keep_weighted Logical, whether to keep the weighted columns in the output data frame. Default is FALSE.
#'
#' @return data frame with additional columns:
#' * comp_prot_score_prot_needs_3
#' * comp_prot_score_needs_1
#' @export
add_prot_needs_movement <- function(
  df,
  sep = "/",
  prot_needs_3_movement = "prot_needs_3_movement",
  no_changes_feel_unsafe = "no_changes_feel_unsafe",
  no_safety_concerns = "no_safety_concerns",
  women_girls_avoid_places = "women_girls_avoid_places",
  men_boys_avoid_places = "men_boys_avoid_places",
  women_girls_avoid_night = "women_girls_avoid_night",
  men_boys_avoid_night = "men_boys_avoid_night",
  girls_boys_avoid_school = "girls_boys_avoid_school",
  different_routes = "different_routes",
  avoid_markets = "avoid_markets",
  avoid_public_offices = "avoid_public_offices",
  avoid_fields = "avoid_fields",
  other_safety_measures = "other_safety_measures",
  dnk = "dnk",
  pnta = "pnta",
  .keep_weighted = FALSE
) {
  # capture all parameters
  params <- as.list(environment())

  # mapping of response → weight
  weights_mapping <- c(
    no_changes_feel_unsafe = 1,
    no_safety_concerns = 0,
    women_girls_avoid_places = 2,
    men_boys_avoid_places = 2,
    women_girls_avoid_night = 1,
    men_boys_avoid_night = 1,
    girls_boys_avoid_school = 2,
    different_routes = 2,
    avoid_markets = 2,
    avoid_public_offices = 2,
    avoid_fields = 2,
    other_safety_measures = NA,
    dnk = NA,
    pnta = NA
  )

  # build the raw column names
  user_answer_options <- params[names(weights_mapping)]
  sm_col_names <- stringr::str_glue(
    "{prot_needs_3_movement}{sep}{user_answer_options}"
  )
  names(weights_mapping) <- sm_col_names

  # sanity checks
  if_not_in_stop(df, sm_col_names, "df")
  are_values_in_set(df, sm_col_names, c(0, 1))

  # compute weighted indicators as new columns ending in "_w"
  weighted_cols <- paste0(sm_col_names, "_w")
  weights_df <- df |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(sm_col_names),
        ~ .x * weights_mapping[[dplyr::cur_column()]],
        .names = "{.col}_w"
      )
    )

  # aggregate into composite scores
  weights_df <- sum_vars(
    weights_df,
    vars = weighted_cols,
    new_colname = "comp_prot_score_prot_needs_3",
    na_rm = TRUE
  ) |>
    dplyr::mutate(
      comp_prot_score_needs_1 = pmin(
        .data[["comp_prot_score_prot_needs_3"]] + 1,
        4
      )
    ) |>
    dplyr::mutate(
      comp_prot_score_needs_1 = dplyr::if_else(
        .data[[stringr::str_glue("{prot_needs_3_movement}{sep}{dnk}")]] == 1 |
          .data[[stringr::str_glue("{prot_needs_3_movement}{sep}{pnta}")]] == 1,
        NA_real_,
        .data[["comp_prot_score_needs_1"]]
      )
    )

  # decide which new columns to bind back
  composite_cols <- c(
    "comp_prot_score_prot_needs_3",
    "comp_prot_score_needs_1"
  )
  if (.keep_weighted) {
    new_cols <- c(weighted_cols, composite_cols)
  } else {
    new_cols <- composite_cols
  }

  # bind and relocate
  df <- dplyr::bind_cols(
    df,
    dplyr::select(weights_df, dplyr::all_of(new_cols))
  ) |>
    dplyr::relocate(
      dplyr::all_of(new_cols),
      .after = tail(sm_col_names, 1)
    )

  df
}
