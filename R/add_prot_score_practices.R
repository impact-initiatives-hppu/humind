#' Add composite score for Ability to Participate in Safe Practices and Activities
#'
#' Creates weighted scores for two multi-choice questions about threats affecting household members’ ability to engage in activities and social interactions.
#' Then computes an overall severity category (1–4) from the combined scores.
#'
#' @param df A data frame containing binary indicator columns. Each question has multiple "option" columns named using the pattern \code{question\(sep\)option_suffix}.
#' @param sep Separator between question names and suffixes in the column names. Defaults to "/".
#' @param prot_needs_2_activities Name of the first question (activities). Default: "prot_needs_2_activities".
#' @param yes_work Answer option name for "Yes, it affected the ability to work" option. Default: "yes_work".
#' @param yes_livelihood Answer option name for "Yes, it affected the general access to livelihood" column. Default: "yes_livelihood". "Yes, it affected the general access to livelihood" option. Default: "yes_livelihood".
#' @param yes_safety Answer option name for "Yes, it affected the ability to seek safety" column. Default: "yes_safety". "Yes, it affected the ability to seek safety" option. Default: "yes_safety".
#' @param yes_farm Answer option name for "Yes, it affected the ability to farm" column. Default: "yes_farm". "Yes, it affected the ability to farm" option. Default: "yes_farm".
#' @param yes_water Answer option name for "Yes, it affected the ability to collect water" column. Default: "yes_water". "Yes, it affected the ability to collect water" option. Default: "yes_water".
#' @param yes_other_activities Answer option name for "Yes, it affected other activities needed to meet needs" column. Default: "yes_other_activities". "Yes, it affected other activities needed to meet needs" option. Default: "yes_other_activities".
#' @param yes_free_choices Answer option name for "Yes, it affected the ability to make free choices" column. Default: "yes_free_choices". "Yes, it affected the ability to make free choices" option. Default: "yes_free_choices".
#' @param prot_needs_2_social Name of the second question (social interactions). Default: "prot_needs_2_social".
#' @param yes_visiting_family Answer option name for "Yes, visiting family members" column. Default: "yes_visiting_family". "Yes, visiting family members" option. Default: "yes_visiting_family".
#' @param yes_visiting_friends Answer option name for "Yes, visiting friends" column. Default: "yes_visiting_friends". "Yes, visiting friends" option. Default: "yes_visiting_friends".
#' @param yes_community_events Answer option name for "Yes, attending community events" column. Default: "yes_community_events". "Yes, attending community events" option. Default: "yes_community_events".
#' @param yes_joining_groups Answer option name for "Yes, joining groups or public gatherings" column. Default: "yes_joining_groups". "Yes, joining groups or public gatherings" option. Default: "yes_joining_groups".
#' @param yes_other_social Answer option name for "Yes, participating in other social activities" column. Default: "yes_other_social". "Yes, participating in other social activities" option. Default: "yes_other_social".
#' @param yes_child_recreation Answer option name for "Yes, children's recreational activities" column. Default: "yes_child_recreation". "Yes, children's recreational activities" option. Default: "yes_child_recreation".
#' @param yes_decision_making Answer option name for "Yes, participating in decision making bodies" column. Default: "yes_decision_making". "Yes, participating in decision making bodies" option. Default: "yes_decision_making".
#' @param no Answer option name for "No" column. Default: "no". "No" option. Default: "no".
#' @param dnk Answer option name for "Don't know" column (treated as NA). Default: "dnk". "Don't know" option (treated as NA). Default: "dnk".
#' @param pnta Answer option name for "Prefer not to answer" column (treated as NA). Default: "pnta". "Prefer not to answer" option (treated as NA). Default: "pnta".
#' @param .keep_weighted Logical; if TRUE, retains the intermediate weighted columns (suffix "_w"). Default: FALSE.
#' @return The input data frame with three new composite-score columns:
#'   \itemize{
#'     \item \code{comp_prot_score_prot_needs_2_activities}: weighted sum of activity-related options.
#'     \item \code{comp_prot_score_prot_needs_2_social}: weighted sum of social-related options.
#'     \item \code{comp_prot_score_practices}: overall severity (1–4) based on combined score.
#'   }
#'  Plus optional weighted columns (suffix "_w") if \code{.keep_weighted = TRUE}.
#' @export
add_prot_score_practices <- function(
  df,
  sep = "/",
  prot_needs_2_activities = "prot_needs_2_activities",
  yes_work = "yes_work",
  yes_livelihood = "yes_livelihood",
  yes_safety = "yes_safety",
  yes_farm = "yes_farm",
  yes_water = "yes_water",
  yes_other_activities = "yes_other_activities",
  yes_free_choices = "yes_free_choices",
  prot_needs_2_social = "prot_needs_2_social",
  yes_visiting_family = "yes_visiting_family",
  yes_visiting_friends = "yes_visiting_friends",
  yes_community_events = "yes_community_events",
  yes_joining_groups = "yes_joining_groups",
  yes_other_social = "yes_other_social",
  yes_child_recreation = "yes_child_recreation",
  yes_decision_making = "yes_decision_making",
  no = "no",
  dnk = "dnk",
  pnta = "pnta",
  .keep_weighted = FALSE
) {
  params <- as.list(environment())

  weights_acts <- c(
    yes_work = 1,
    yes_livelihood = 1,
    yes_safety = 1,
    yes_farm = 1,
    yes_water = 1,
    yes_other_activities = 2,
    yes_free_choices = 1,
    no = 0,
    dnk = NA,
    pnta = NA
  )

  acts_opts <- params[names(weights_acts)]
  acts_raw <- stringr::str_glue("{prot_needs_2_activities}{sep}{acts_opts}")
  names(weights_acts) <- acts_raw

  weights_soc <- c(
    yes_visiting_family = 1,
    yes_visiting_friends = 1,
    yes_community_events = 1,
    yes_joining_groups = 1,
    yes_other_social = 1,
    yes_child_recreation = 1,
    yes_decision_making = 1,
    no = 0,
    dnk = NA,
    pnta = NA
  )

  soc_opts <- params[names(weights_soc)]
  soc_raw <- stringr::str_glue("{prot_needs_2_social}{sep}{soc_opts}")
  names(weights_soc) <- soc_raw

  weights_mapping <- c(weights_acts, weights_soc)
  all_raw <- names(weights_mapping)
  w_cols <- stringr::str_glue("{all_raw}_w")

  if_not_in_stop(df, all_raw, "df")
  are_values_in_set(df, all_raw, c(0, 1))

  weights_df <- df |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(all_raw),
        ~ .x * weights_mapping[[dplyr::cur_column()]],
        .names = "{.col}_w"
      )
    )

  acts_w <- stringr::str_glue("{acts_raw}_w")
  soc_w <- stringr::str_glue("{soc_raw}_w")
  weights_df <- weights_df |>
    sum_vars(
      vars = acts_w,
      new_colname = "comp_prot_score_prot_needs_2_activities",
      na_rm = TRUE
    ) |>
    sum_vars(
      vars = soc_w,
      new_colname = "comp_prot_score_prot_needs_2_social",
      na_rm = TRUE
    ) |>
    dplyr::mutate(
      comp_prot_score_prot_needs_2_activities = dplyr::case_when(
        comp_prot_score_prot_needs_2_activities == 0 &
          (.data[[glue::glue("{prot_needs_2_activities}/{dnk}")]] == 1 |
            .data[[glue::glue("{prot_needs_2_activities}/{pnta}")]] == 1) ~
          NA_real_,
        TRUE ~ comp_prot_score_prot_needs_2_activities
      ),
      comp_prot_score_prot_needs_2_social = dplyr::case_when(
        comp_prot_score_prot_needs_2_social == 0 &
          (.data[[glue::glue("{prot_needs_2_social}/{dnk}")]] == 1 |
            .data[[glue::glue("{prot_needs_2_social}/{pnta}")]] == 1) ~
          NA_real_,
        TRUE ~ comp_prot_score_prot_needs_2_social
      )
    )

  weights_df <- weights_df |>
    dplyr::mutate(
      .both_na = is.na(.data[["comp_prot_score_prot_needs_2_activities"]]) &
        is.na(.data[["comp_prot_score_prot_needs_2_social"]]),
      .sum = rowSums(
        cbind(
          .data[["comp_prot_score_prot_needs_2_activities"]],
          .data[["comp_prot_score_prot_needs_2_social"]]
        ),
        na.rm = TRUE
      ),
      .sum = dplyr::if_else(.data[[".both_na"]], NA_real_, .data[[".sum"]]),
      comp_prot_score_practices = dplyr::case_when(
        .both_na ~ NA_real_,
        .sum >= 4 ~ 4,
        .sum >= 2 ~ 3,
        .sum >= 1 ~ 2,
        .sum == 0 ~ 1,
        TRUE ~ NA_real_
      )
    ) |>
    dplyr::select(-dplyr::all_of(c(".sum", ".both_na")))

  # bind back composite and optionally weighted cols
  comp_cols <- c(
    "comp_prot_score_prot_needs_2_activities",
    "comp_prot_score_prot_needs_2_social",
    "comp_prot_score_practices"
  )
  new_cols <- if (.keep_weighted) c(w_cols, comp_cols) else comp_cols

  df |>
    dplyr::bind_cols(dplyr::select(weights_df, dplyr::all_of(new_cols))) |>
    dplyr::relocate(
      dplyr::all_of(new_cols),
      .after = tail(all_raw, 1)
    )
}
