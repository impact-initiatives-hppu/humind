library(stringr)
library(dplyr)
library(tidyr)

generate_survey_choice_combinations <- function(
  question_name,
  answer_options,
  stand_alone_opts = c("dnk", "pnta"),
  sep = "/",
  min_choices = 1,
  max_choices = length(answer_options) - 1
) {
  invalid <- setdiff(stand_alone_opts, answer_options)
  if (length(invalid) > 0) {
    stop(
      "These stand_alone_opts are not in answer_options: ",
      paste(invalid, collapse = ", ")
    )
  }
  # 1. Build column names
  cols <- stringr::str_glue("{question_name}{sep}{answer_options}")

  # 2. All binary combos
  df <- expand.grid(rep(list(0:1), length(cols))) |>
    rlang::set_names(cols) |>
    as.data.frame()

  # 3. Count selections
  df$tot <- rowSums(df)

  # 4. Filter by total count
  df <- df |>
    dplyr::filter(tot >= min_choices, tot <= max_choices)

  # 5. Enforce stand‑alone constraints
  sa_cols <- stringr::str_glue("{question_name}/{stand_alone_opts}")

  for (col in sa_cols) {
    df <- df |>
      dplyr::filter(!(.data[[col]] == 1 & tot > 1))
  }

  df
}

apply_skip_logic <- function(df) {
  df %>%
    mutate(
      obs_allowed = survey_modality != "remote", # TRUE/FALSE
      observed_facility_valid = !is.na(wash_handwashing_facility) & # force non-NA
        wash_handwashing_facility %in%
          c(
            "available_fixed_in_dwelling",
            "available_fixed_in_plot",
            "available_fixed_or_mobile"
          ),
      reported_relevant = (survey_modality == "remote") |
        (!is.na(wash_handwashing_facility) &
          wash_handwashing_facility == "no_permission")
    ) %>%
    filter(
      # Q630: observed facility asked iff NOT remote
      ifelse(
        obs_allowed,
        !is.na(wash_handwashing_facility),
        is.na(wash_handwashing_facility)
      ),

      # Q631 & Q633: observed water/soap only when in-person AND facility is valid
      ifelse(
        obs_allowed & observed_facility_valid,
        !is.na(wash_handwashing_facility_observed_water) &
          !is.na(wash_soap_observed),
        is.na(wash_handwashing_facility_observed_water) &
          is.na(wash_soap_observed)
      ),

      # Q583, Q636, Q601: reported branch iff remote OR no_permission
      ifelse(
        reported_relevant,
        !is.na(wash_handwashing_facility_reported) &
          !is.na(wash_handwashing_facility_water_reported) &
          !is.na(wash_soap_reported),
        is.na(wash_handwashing_facility_reported) &
          is.na(wash_handwashing_facility_water_reported) &
          is.na(wash_soap_reported)
      )
    ) %>%
    dplyr::select(
      survey_modality,
      wash_handwashing_facility,
      wash_handwashing_facility_observed_water,
      wash_soap_observed,
      wash_handwashing_facility_reported,
      wash_handwashing_facility_water_reported,
      wash_soap_reported
    )
}

gen_wash_df <- function() {
  survey_modality <- c(
    "in_person",
    "remote"
  )

  wash_handwashing_facility <- c(
    "available_fixed_in_dwelling",
    "available_fixed_in_plot",
    "available_fixed_or_mobile",
    "none",
    "no_permission",
    "other",
    NA
  )
  wash_handwashing_facility_observed_water <- c(
    "water_available",
    "water_not_available",
    "water_available",
    NA
  )

  wash_soap_observed <- c(
    "yes_soap_shown",
    "no",
    NA
  )

  wash_handwashing_facility_reported <- c(
    "fixed_dwelling",
    "none",
    "mobile",
    "other",
    NA
  )

  wash_handwashing_facility_water_reported <- c(
    "yes",
    "no",
    "yes",
    "dnk",
    NA
  )

  wash_soap_reported <- c(
    "yes",
    "no",
    "yes",
    "dnk",
    NA
  )

  exhaustive_df <- tidyr::expand_grid(
    survey_modality,
    wash_handwashing_facility,
    wash_handwashing_facility_observed_water,
    wash_soap_observed,
    wash_handwashing_facility_reported,
    wash_handwashing_facility_water_reported,
    wash_soap_reported
  ) |>
    apply_skip_logic()
  return(exhaustive_df)
}
