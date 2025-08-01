#' Add composite score for Ability to Access Rights and Services
#'
#' Computes weighted sums for two questions about household difficulties accessing services
#' and justice/legal resources, then derives an overall severity category (1–4).
#'
#' @param df A data frame containing binary indicator columns for both questions.
#' @param sep Separator between question code and answer option in column names. Default: "/".
#'
#' @param prot_needs_1_services Base name of services question. Default: "prot_needs_1_services".
#' @param yes_healthcare Answer option name for "Yes, accessing healthcare". Default: "yes_healthcare".
#' @param yes_schools Answer option name for "Yes, accessing schools". Default: "yes_schools".
#' @param yes_gov_services Answer option name for "Yes, accessing governmental services". Default: "yes_gov_services".
#' @param yes_other_services Answer option name for "Yes, accessing other services". Default: "yes_other_services".
#'
#' @param prot_needs_1_justice Base name of justice question. Default: "prot_needs_1_justice".
#' @param yes_identity_documents Answer option name for "Yes, accessing identity and civil documents services". Default: "yes_identity_documents".
#' @param yes_counselling_legal Answer option name for "Yes, individual counselling or legal assistance". Default: "yes_counselling_legal".
#' @param yes_property_docs Answer option name for "Yes, accessing house, land and property documentation". Default: "yes_property_docs".
#' @param yes_gov_services_justice Answer option name for "Yes, accessing governmental services". Default: "yes_gov_services".
#' @param yes_other_services_justice Answer option name for "Yes, accessing other services". Default: "yes_other_services".
#'
#' @param no Answer option name for "No". Default: "no".
#' @param dnk Answer option name for "Don't know"  Default: "dnk".
#' @param pnta Answer option name for "Prefer not to answer" Default: "pnta".
#'
#' @param .keep_weighted Logical; if TRUE, retain intermediate weighted columns with suffix `_w`. Default: FALSE.
#' @return Input data frame with three new composite-score columns:
#'   * `comp_prot_score_prot_needs_1_services`: weighted sum of services options.
#'   * `comp_prot_score_prot_needs_1_justice`: weighted sum of justice options.
#'   * `comp_prot_score_needs_1`: overall severity (1–4) based on combined score.
#'   Plus optional `_w` columns if `.keep_weighted = TRUE`.
#' @export
add_prot_score_rights <- function(
  df,
  sep = "/",
  prot_needs_1_services = "prot_needs_1_services",
  yes_healthcare = "yes_healthcare",
  yes_schools = "yes_schools",
  yes_gov_services = "yes_gov_services",
  yes_other_services = "yes_other_services",
  prot_needs_1_justice = "prot_needs_1_justice",
  yes_identity_documents = "yes_identity_documents",
  yes_counselling_legal = "yes_counselling_legal",
  yes_property_docs = "yes_property_docs",
  yes_gov_services_justice = "yes_gov_services",
  yes_other_services_justice = "yes_other_services",
  no = "no",
  dnk = "dnk",
  pnta = "pnta",

  .keep_weighted = FALSE
) {
  params <- as.list(environment())

  weights_srv <- c(
    yes_healthcare = 1,
    yes_schools = 1,
    yes_gov_services = 1,
    yes_other_services = 1,
    no = 0,
    dnk = NA,
    pnta = NA
  )
  srv_opts <- params[names(weights_srv)]

  srv_raw <- stringr::str_glue(
    "{prot_needs_1_services}{sep}{srv_opts}"
  )
  names(weights_srv) <- srv_raw

  weights_jus <- c(
    yes_identity_documents = 2,
    yes_counselling_legal = 1,
    yes_property_docs = 1,
    yes_gov_services_justice = 1,
    yes_other_services_justice = 1,
    no = 0,
    dnk = NA,
    pnta = NA
  )

  jus_opts <- params[names(weights_jus)]
  jus_raw <- stringr::str_glue(
    "{prot_needs_1_justice}{sep}{jus_opts}"
  )
  names(weights_jus) <- jus_raw

  weights_mapping <- c(weights_srv, weights_jus)
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

  srv_w <- stringr::str_glue("{srv_raw}_w")
  jus_w <- stringr::str_glue("{jus_raw}_w")
  weights_df <- sum_vars(
    weights_df,
    vars = srv_w,
    new_colname = "comp_prot_score_prot_needs_1_services",
    na_rm = TRUE
  ) |>
    sum_vars(
      vars = jus_w,
      new_colname = "comp_prot_score_prot_needs_1_justice",
      na_rm = TRUE
    )

  weights_df <- weights_df |>
    dplyr::mutate(
      comp_prot_score_needs_1 = dplyr::case_when(
        (comp_prot_score_prot_needs_1_services +
          comp_prot_score_prot_needs_1_justice) >=
          4 ~
          4,
        (comp_prot_score_prot_needs_1_services +
          comp_prot_score_prot_needs_1_justice) >=
          2 ~
          3,
        (comp_prot_score_prot_needs_1_services +
          comp_prot_score_prot_needs_1_justice) >=
          1 ~
          2,
        (comp_prot_score_prot_needs_1_services +
          comp_prot_score_prot_needs_1_justice) ==
          0 ~
          1,
        TRUE ~ NA_real_
      )
    ) |>
    # if respondent chose DNK or PNTA on either question, force final to NA
    dplyr::mutate(
      comp_prot_score_rights = dplyr::if_else(
        .data[[stringr::str_glue("{prot_needs_1_services}{sep}{dnk}")]] == 1 |
          .data[[stringr::str_glue("{prot_needs_1_services}{sep}{pnta}")]] ==
            1 |
          .data[[stringr::str_glue("{prot_needs_1_justice}{sep}{dnk}")]] == 1 |
          .data[[stringr::str_glue("{prot_needs_1_justice}{sep}{pnta}")]] == 1,
        NA_real_,
        .data[["comp_prot_score_needs_1"]]
      )
    )

  comp_cols <- c(
    "comp_prot_score_prot_needs_1_services",
    "comp_prot_score_prot_needs_1_justice",
    "comp_prot_score_rights"
  )
  new_cols <- if (.keep_weighted) c(w_cols, comp_cols) else comp_cols

  df |>
    dplyr::bind_cols(dplyr::select(weights_df, dplyr::all_of(new_cols))) |>
    dplyr::relocate(
      dplyr::all_of(new_cols),
      .after = tail(all_raw, 1)
    )
}
