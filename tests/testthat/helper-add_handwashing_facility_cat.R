prune_wash_df <- function(df) {
  fixed_hwf <- c(
    "available_fixed_in_dwelling",
    "available_fixed_in_plot",
    "available_fixed_or_mobile"
  )
  dplyr::filter(
    df,
    # wash_handwashing_facility: not(selected(${survey_modality}, 'remote'))
    (is.na(survey_modality) | survey_modality != "remote") ==
      !is.na(wash_handwashing_facility),

    # wash_handwashing_facility_observed_water:
    # selected(${wash_handwashing_facility}, one of fixed_hwf)
    (wash_handwashing_facility %in% fixed_hwf) ==
      !is.na(wash_handwashing_facility_observed_water),

    # wash_soap_observed: same trigger as above
    (wash_handwashing_facility %in% fixed_hwf) == !is.na(wash_soap_observed),

    # wash_handwashing_facility_reported:
    # selected(${survey_modality}, 'remote') OR selected(${wash_handwashing_facility}, 'no_permission')
    ((survey_modality %in% "remote") |
      (wash_handwashing_facility %in% "no_permission")) ==
      !is.na(wash_handwashing_facility_reported),

    # wash_handwashing_facility_water_reported: same trigger
    ((survey_modality %in% "remote") |
      (wash_handwashing_facility %in% "no_permission")) ==
      !is.na(wash_handwashing_facility_water_reported),

    # wash_soap_observed_type: selected(${wash_soap_observed}, 'yes_soap_shown')
    (wash_soap_observed %in% "yes_soap_shown") ==
      !is.na(wash_soap_observed_type),

    # wash_soap_reported: same trigger as *_reported
    ((survey_modality %in% "remote") |
      (wash_handwashing_facility %in% "no_permission")) ==
      !is.na(wash_soap_reported),

    # wash_soap_reported_type: selected(${wash_soap_reported}, 'yes')
    (wash_soap_reported %in% "yes") == !is.na(wash_soap_reported_type)
  )
}
generate_wash_df <- function() {
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
    NA_character_ # Can be NA because of skip logic
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

  wash_soap_observed_type <- c(
    "soap",
    "detergent",
    "ash_mud_sand",
    "other",
    "dnk",
    "pnta",
    NA_character_ # Can be NA because of skip logic
  )

  wash_soap_reported_type <- wash_soap_observed_type

  exhaustive_df <- tidyr::expand_grid(
    survey_modality,
    wash_handwashing_facility,
    wash_handwashing_facility_observed_water,
    wash_soap_observed,
    wash_handwashing_facility_reported,
    wash_handwashing_facility_water_reported,
    wash_soap_reported,
    wash_soap_observed_type,
    wash_soap_reported_type,
  ) |>
    prune_wash_df()
  exhaustive_df
}
