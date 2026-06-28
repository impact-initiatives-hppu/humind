#' Add LCSI
#'
#' Function to calculate Livelihood Coping Strategy Index (LCSI)
#'
#' @param .dataset Main Dataset
#' @param fsl_lcsi_stress1 the name of the variable that indicates the first stress LCSI strategy
#' @param fsl_lcsi_stress2 the name of the variable that indicates the second stress LCSI strategy
#' @param fsl_lcsi_stress3 the name of the variable that indicates the third stress LCSI strategy
#' @param fsl_lcsi_stress4 the name of the variable that indicates the fourth stress LCSI strategy
#' @param fsl_lcsi_crisis1 the name of the variable that indicates the first crisis LCSI strategy
#' @param fsl_lcsi_crisis2 the name of the variable that indicates the second crisis LCSI strategy
#' @param fsl_lcsi_crisis3 the name of the variable that indicates the third crisis LCSI strategy
#' @param fsl_lcsi_emergency1 the name of the variable that indicates the first emergency LCSI strategy
#' @param fsl_lcsi_emergency2 the name of the variable that indicates the second emergency LCSI strategy
#' @param fsl_lcsi_emergency3 the name of the variable that indicates the third emergency LCSI strategy
#' @param yes_val A character value in the dataset associated with "Yes, used this coping strategy in the last 30 days."
#' @param no_val A character value in the dataset associated with "No, have not used this coping strategy in the last 30 days."
#' @param exhausted_val A character value in the dataset associated with "No, haven't used in the last 30 days because I've exhausted this coping strategy in the last 6 or 12 months."
#' @param not_applicable_val A character value in the dataset associated with "This coping strategy is not applicable for the household.
#'
#' @return Returns a dataframe with added columns for LCSI indicators.
#' - fsl_csi_x_yes : 1 means one of the of the x strategies was used (*yes_val*)
#' - fsl_lcsi_x_exhaust: 1 means one of the x strategies was exhausted and could not be used (*exhausted_val*)
#' - fsl_lcsi_x: 1 means one of the x strategies was if either used (*yes_val*) or exhausted (*exhausted_val*)
#' Where x is stress, crisis or emergency
#' - fsl_lcsi_cat_yes : the highest category between the fsl_lcsi_x_yes
#' - fsl_lcsi_cat_exhaust: the highest category between the fsl_lcsi_x_exhaust
#' - fsl_lcsi_cat: the highest category between the fsl_lcsi_x
#' @export
#'
#' @examples{
#'   input_data1 <- data.frame(fsl_lcsi_stress1 = c("No", "No", "Exhausted", "Not Applicable", "No"),
#'   fsl_lcsi_stress2 = c("No", "Yes", "Not Applicable", "No", "No"),
#'   fsl_lcsi_stress3 = c("Not Applicable", "Not Applicable", "Yes", "No", "No"),
#'   fsl_lcsi_stress4 = c("Not Applicable", "No", "Yes", "Yes", "No"),
#'   fsl_lcsi_crisis1 = c("No", "Not Applicable", "Yes", "Exhausted", "No"),
#'   fsl_lcsi_crisis2 = c("No", "No", "No", "No", "No"),
#'   fsl_lcsi_crisis3 = c("No", "No", "Yes", "Not Applicable", "No"),
#'   fsl_lcsi_emergency1 = c("No", "Not Applicable", "Not Applicable", "No", "No"),
#'   fsl_lcsi_emergency2 = c("No", "Not Applicable", "Yes", "Not Applicable", "No"),
#'   fsl_lcsi_emergency3 = c("Not Applicable", "No", "Not Applicable", "No", "Exhausted"))
#'
#' add_lcsi(.dataset = input_data1,
#' yes_val = "Yes",
#' no_val = "No",
#' exhausted_val = "Exhausted",
#' not_applicable_val = "Not Applicable")
#'
#' }
add_lcsi <- function(
  .dataset,
  fsl_lcsi_stress1 = "fsl_lcsi_stress1",
  fsl_lcsi_stress2 = "fsl_lcsi_stress2",
  fsl_lcsi_stress3 = "fsl_lcsi_stress3",
  fsl_lcsi_stress4 = "fsl_lcsi_stress4",
  fsl_lcsi_crisis1 = "fsl_lcsi_crisis1",
  fsl_lcsi_crisis2 = "fsl_lcsi_crisis2",
  fsl_lcsi_crisis3 = "fsl_lcsi_crisis3",
  fsl_lcsi_emergency1 = "fsl_lcsi_emergency1",
  fsl_lcsi_emergency2 = "fsl_lcsi_emergency2",
  fsl_lcsi_emergency3 = "fsl_lcsi_emergency3",
  yes_val = "yes",
  no_val = "no_had_no_need",
  exhausted_val = "no_exhausted",
  not_applicable_val = "not_applicable"
) {
  ## Throw an error if a dataset wasn't provided as a first argument
  if (!is.data.frame(.dataset)) {
    stop("First argument should be a dataset")
  }
  if (nrow(.dataset) == 0) {
    stop("Dataset is empty")
  }
  lcsi_vars <- c(
    fsl_lcsi_stress1,
    fsl_lcsi_stress2,
    fsl_lcsi_stress3,
    fsl_lcsi_stress4,
    fsl_lcsi_crisis1,
    fsl_lcsi_crisis2,
    fsl_lcsi_crisis3,
    fsl_lcsi_emergency1,
    fsl_lcsi_emergency2,
    fsl_lcsi_emergency3
  )
  ## Test if all columns are in the dataset
  if (!all(lcsi_vars %in% names(.dataset))) {
    stop("Missing lcsi columns")
  }

  lcsi_cat_values <- c(yes_val, no_val, exhausted_val, not_applicable_val)
  if (!all(.dataset[[fsl_lcsi_stress1]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_stress1,
      paste0(
        unique(.dataset[[fsl_lcsi_stress1]][
          !.dataset[[fsl_lcsi_stress1]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_stress2]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_stress2,
      paste0(
        unique(.dataset[[fsl_lcsi_stress2]][
          !.dataset[[fsl_lcsi_stress2]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_stress3]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_stress3,
      paste0(
        unique(.dataset[[fsl_lcsi_stress3]][
          !.dataset[[fsl_lcsi_stress3]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_stress4]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_stress4,
      paste0(
        unique(.dataset[[fsl_lcsi_stress4]][
          !.dataset[[fsl_lcsi_stress4]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_crisis1]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_crisis1,
      paste0(
        unique(.dataset[[fsl_lcsi_crisis1]][
          !.dataset[[fsl_lcsi_crisis1]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_crisis2]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_crisis2,
      paste0(
        unique(.dataset[[fsl_lcsi_crisis2]][
          !.dataset[[fsl_lcsi_crisis2]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_crisis3]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_crisis3,
      paste0(
        unique(.dataset[[fsl_lcsi_crisis3]][
          !.dataset[[fsl_lcsi_crisis3]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_emergency1]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_emergency1,
      paste0(
        unique(.dataset[[fsl_lcsi_emergency1]][
          !.dataset[[fsl_lcsi_emergency1]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_emergency2]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_emergency2,
      paste0(
        unique(.dataset[[fsl_lcsi_emergency2]][
          !.dataset[[fsl_lcsi_emergency2]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }
  if (!all(.dataset[[fsl_lcsi_emergency3]] %in% c(lcsi_cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_lcsi_emergency3,
      paste0(
        unique(.dataset[[fsl_lcsi_emergency3]][
          !.dataset[[fsl_lcsi_emergency3]] %in% c(lcsi_cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  .dataset <- .dataset |>
    dplyr::mutate(
      fsl_lcsi_stress_yes = dplyr::case_when(
        is.na(!!rlang::sym(fsl_lcsi_stress1)) ~ NA,
        !!rlang::sym(fsl_lcsi_stress1) == yes_val |
          !!rlang::sym(fsl_lcsi_stress2) == yes_val |
          !!rlang::sym(fsl_lcsi_stress3) == yes_val |
          !!rlang::sym(fsl_lcsi_stress4) == yes_val ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_stress_exhaust = dplyr::case_when(
        is.na(!!rlang::sym(fsl_lcsi_stress1)) ~ NA,
        !!rlang::sym(fsl_lcsi_stress1) == exhausted_val |
          !!rlang::sym(fsl_lcsi_stress2) == exhausted_val |
          !!rlang::sym(fsl_lcsi_stress3) == exhausted_val |
          !!rlang::sym(fsl_lcsi_stress4) == exhausted_val ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_stress = dplyr::case_when(
        is.na(fsl_lcsi_stress_yes) & is.na(fsl_lcsi_stress_exhaust) ~ NA,
        fsl_lcsi_stress_yes == "1" | fsl_lcsi_stress_exhaust == "1" ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_crisis_yes = dplyr::case_when(
        is.na(!!rlang::sym(fsl_lcsi_crisis1)) ~ NA,
        !!rlang::sym(fsl_lcsi_crisis1) == yes_val |
          !!rlang::sym(fsl_lcsi_crisis2) == yes_val |
          !!rlang::sym(fsl_lcsi_crisis3) == yes_val ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_crisis_exhaust = dplyr::case_when(
        is.na(!!rlang::sym(fsl_lcsi_crisis1)) ~ NA,
        !!rlang::sym(fsl_lcsi_crisis1) == exhausted_val |
          !!rlang::sym(fsl_lcsi_crisis2) == exhausted_val |
          !!rlang::sym(fsl_lcsi_crisis3) == exhausted_val ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_crisis = dplyr::case_when(
        is.na(fsl_lcsi_crisis_yes) & is.na(fsl_lcsi_crisis_exhaust) ~ NA,
        fsl_lcsi_crisis_yes == "1" | fsl_lcsi_crisis_exhaust == "1" ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_emergency_yes = dplyr::case_when(
        is.na(!!rlang::sym(fsl_lcsi_emergency1)) ~ NA,
        !!rlang::sym(fsl_lcsi_emergency1) == yes_val |
          !!rlang::sym(fsl_lcsi_emergency2) == yes_val |
          !!rlang::sym(fsl_lcsi_emergency3) == yes_val ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_emergency_exhaust = dplyr::case_when(
        is.na(!!rlang::sym(fsl_lcsi_emergency1)) ~ NA,
        !!rlang::sym(fsl_lcsi_emergency1) == exhausted_val |
          !!rlang::sym(fsl_lcsi_emergency2) == exhausted_val |
          !!rlang::sym(fsl_lcsi_emergency3) == exhausted_val ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_emergency = dplyr::case_when(
        is.na(fsl_lcsi_emergency_yes) & is.na(fsl_lcsi_emergency_exhaust) ~ NA,
        fsl_lcsi_emergency_yes == "1" | fsl_lcsi_emergency_exhaust == "1" ~ "1",
        TRUE ~ "0"
      ),
      fsl_lcsi_cat_yes = dplyr::case_when(
        fsl_lcsi_stress_yes != "1" &
          fsl_lcsi_crisis_yes != "1" &
          fsl_lcsi_emergency_yes != "1" ~ "None",
        fsl_lcsi_stress_yes == "1" &
          fsl_lcsi_crisis_yes != "1" &
          fsl_lcsi_emergency_yes != "1" ~ "Stress",
        fsl_lcsi_crisis_yes == "1" & fsl_lcsi_emergency_yes != "1" ~ "Crisis",
        fsl_lcsi_emergency_yes == "1" ~ "Emergency",
        TRUE ~ NA
      ),
      fsl_lcsi_cat_exhaust = dplyr::case_when(
        fsl_lcsi_stress_exhaust != "1" &
          fsl_lcsi_crisis_exhaust != "1" &
          fsl_lcsi_emergency_exhaust != "1" ~ "None",
        fsl_lcsi_stress_exhaust == "1" &
          fsl_lcsi_crisis_exhaust != "1" &
          fsl_lcsi_emergency_exhaust != "1" ~ "Stress",
        fsl_lcsi_crisis_exhaust == "1" &
          fsl_lcsi_emergency_exhaust != "1" ~ "Crisis",
        fsl_lcsi_emergency_exhaust == "1" ~ "Emergency",
        TRUE ~ NA
      ),
      fsl_lcsi_cat = dplyr::case_when(
        fsl_lcsi_stress != "1" &
          fsl_lcsi_crisis != "1" &
          fsl_lcsi_emergency != "1" ~ "None",
        fsl_lcsi_stress == "1" &
          fsl_lcsi_crisis != "1" &
          fsl_lcsi_emergency != "1" ~ "Stress",
        fsl_lcsi_crisis == "1" & fsl_lcsi_emergency != "1" ~ "Crisis",
        fsl_lcsi_emergency == "1" ~ "Emergency",
        TRUE ~ NA
      )
    )

  .dataset
}
