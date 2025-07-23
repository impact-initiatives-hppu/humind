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
  pnta = "pnta"
) {
  params <- as.list(environment())
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

  # Renaming the weights_mapping names to match user input
  user_answer_options <- params[names(weights_mapping)]
  sm_col_names <- stringr::str_glue(
    "{prot_needs_3_movement}{sep}{user_answer_options}"
  )
  names(weights_mapping) <- sm_col_names

  if_not_in_stop(df, sm_col_names, "df")
  are_values_in_set(df, sm_col_names, c(0, 1))

  weights_df <- df |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(sm_col_names),
        \(x) {
          x * weights_mapping[[dplyr::cur_column()]]
        }
      )
    )
  weights_df <- sum_vars(
    weights_df,
    vars = sm_col_names,
    new_colname = "comp_prot_score_prot_needs_3",
    na_rm = TRUE
  )
  weights_df <- weights_df |>
    dplyr::mutate(
      comp_prot_score_needs_1 = pmin(
        .data[["comp_prot_score_prot_needs_3"]] + 1,
        4
      )
    )
  composite_cols <- c("comp_prot_score_needs_1", "comp_prot_score_prot_needs_3")
  dplyr::bind_cols(
    df,
    dplyr::select(weights_df, dplyr::all_of(composite_cols))
  ) |>
    dplyr::relocate(
      dplyr::all_of(composite_cols),
      .after = tail(sm_col_names, 1)
    )
}
