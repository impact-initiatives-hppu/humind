#' Calculating FEWSNET Food Consumption-Livelihood Coping Matrix
#'
#' @param .dataset Main Dataset
#' @param fc_phase_var Column name containing food consumption phase.
#' @param fc_phase_1 The name of the value "Phase 1 FC" (by default) in the food consumption phase.
#' @param fc_phase_2 The name of the value "Phase 2 FC" (by default) in the food consumption phase.
#' @param fc_phase_3 The name of the value "Phase 3 FC" (by default) in the food consumption phase.
#' @param fc_phase_4 The name of the value "Phase 4 FC" (by default) in the food consumption phase.
#' @param fc_phase_5 The name of the value "Phase 5 FC" (by default) in the food consumption phase.
#' @param lcs_cat_var Column name containing livelihood coping category.
#' @param lcs_cat_none The name of the value "None" (by default) in the livelihood coping category.
#' @param lcs_cat_stress The name of the value "Stress" (by default) in the livelihood coping category.
#' @param lcs_cat_crisis The name of the value "Crisis" (by default) in the livelihood coping category.
#' @param lcs_cat_emergency The name of the value "Emergency" (by default) in the livelihood coping category.
#' @return Returns a dataframe with a additional column for FCLC phase.
#' @export
#'
#' @examples
#' test_df <- data.frame(
#'   fsl_lcsi_cat = c("None", "Stress"),
#'   fsl_fc_phase = c("Phase 1 FC", "Phase 2 FC")
#' )
#' test_df |> add_fclcm_phase()
add_fclcm_phase <- function(
  .dataset,
  fc_phase_var = "fsl_fc_phase",
  fc_phase_1 = "Phase 1 FC",
  fc_phase_2 = "Phase 2 FC",
  fc_phase_3 = "Phase 3 FC",
  fc_phase_4 = "Phase 4 FC",
  fc_phase_5 = "Phase 5 FC",
  lcs_cat_var = "fsl_lcsi_cat",
  lcs_cat_none = "None",
  lcs_cat_stress = "Stress",
  lcs_cat_crisis = "Crisis",
  lcs_cat_emergency = "Emergency"
) {
  ## Throw an error if a dataset wasn't provided as a first argument
  if (!is.data.frame(.dataset)) {
    stop("First argument should be a dataset")
  }
  if (nrow(.dataset) == 0) {
    stop("Dataset is empty")
  }

  fews_vars <- c(fc_phase_var, lcs_cat_var)

  ## Test if all columns are in the dataset
  if (!all(fews_vars %in% names(.dataset))) {
    stop("Missing fews columns")
  }

  if (
    !all(
      .dataset[[lcs_cat_var]] %in%
        c(lcs_cat_none, lcs_cat_stress, lcs_cat_crisis, lcs_cat_emergency, NA)
    )
  ) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      lcs_cat_var,
      paste0(
        unique(.dataset[[lcs_cat_var]][
          !.dataset[[lcs_cat_var]] %in%
            c(
              lcs_cat_none,
              lcs_cat_stress,
              lcs_cat_crisis,
              lcs_cat_emergency,
              NA
            )
        ]),
        collapse = "/"
      )
    ))
  }

  if (
    !all(
      .dataset[[fc_phase_var]] %in%
        c(fc_phase_1, fc_phase_2, fc_phase_3, fc_phase_4, fc_phase_5, NA)
    )
  ) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fc_phase_var,
      paste0(
        unique(.dataset[[fc_phase_var]][
          !.dataset[[fc_phase_var]] %in%
            c(fc_phase_1, fc_phase_2, fc_phase_3, fc_phase_4, fc_phase_5, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (all(c(fc_phase_var, lcs_cat_var) %in% names(.dataset))) {
    .dataset <- .dataset |>
      dplyr::mutate(
        fclcm_phase = dplyr::case_when(
          is.na(!!rlang::sym(fc_phase_var)) ~ NA,
          is.na(!!rlang::sym(lcs_cat_var)) ~ NA,
          !!rlang::sym(fc_phase_var) == fc_phase_1 &
            !!rlang::sym(lcs_cat_var) %in%
              c(lcs_cat_none, lcs_cat_stress) ~ "Phase 1 FCLC",
          (!!rlang::sym(fc_phase_var) == fc_phase_1 &
            !!rlang::sym(lcs_cat_var) == lcs_cat_crisis) |
            !!rlang::sym(fc_phase_var) == fc_phase_2 &
              !!rlang::sym(lcs_cat_var) %in%
                c(lcs_cat_none, lcs_cat_stress) ~ "Phase 2 FCLC",
          (!!rlang::sym(fc_phase_var) == fc_phase_1 &
            !!rlang::sym(lcs_cat_var) == lcs_cat_emergency) |
            (!!rlang::sym(fc_phase_var) == fc_phase_2 &
              !!rlang::sym(lcs_cat_var) %in%
                c(lcs_cat_crisis, lcs_cat_emergency)) |
            (!!rlang::sym(fc_phase_var) == fc_phase_3 &
              !!rlang::sym(lcs_cat_var) %in%
                c(
                  lcs_cat_none,
                  lcs_cat_stress,
                  lcs_cat_crisis
                )) ~ "Phase 3 FCLC",
          (!!rlang::sym(fc_phase_var) == fc_phase_3 &
            !!rlang::sym(lcs_cat_var) == lcs_cat_emergency) |
            !!rlang::sym(fc_phase_var) == fc_phase_4 ~ "Phase 4 FCLC",
          !!rlang::sym(fc_phase_var) == fc_phase_5 ~ "Phase 5 FCLC",
          TRUE ~ NA
        )
      )
  }
  .dataset
}
