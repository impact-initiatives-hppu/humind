#' @title Add Handwashing Facility Category
#'
#' @description This function categorizes handwashing facilities into "Basic," "Limited," or "No facility" based on survey data.
#' It evaluates various parameters related to the availability of handwashing facilities and the presence of soap and water.
#'
#' @param df A data frame containing the survey data.
#' @param survey_modality Column name for the survey modality (e.g., "survey_modality").
#' @param survey_modality_in_person Options for the in-person survey modality.
#' @param survey_modality_remote Options for the remote survey modality.
#' @param facility Column name for the observed handwashing facility (e.g., "wash_handwashing_facility").
#' @param facility_yes Response code(s) indicating availability (e.g., "available").
#' @param facility_no Response code indicating unavailability (e.g., "none").
#' @param facility_no_permission Response code for cases with no permission to observe.
#' @param facility_undefined Response code(s) for undefined situations.
#' @param facility_observed_water Column name for observed water availability (e.g., "wash_handwashing_facility_observed_water").
#' @param facility_observed_water_yes Response code indicating water is available.
#' @param facility_observed_water_no Response code indicating water is not available.
#' @param facility_observed_soap Column name for observed soap availability.
#' @param facility_observed_soap_yes Response code indicating soap is available (observed).
#' @param facility_observed_soap_no Response code indicating soap is not available (observed).
#' @param facility_observed_soap_undefined Response code(s) for undefined observed soap situations.
#' @param facility_reported Column name for reported handwashing facility (used in remote/no-permission cases).
#' @param facility_reported_yes Response code(s) indicating facility is available (reported).
#' @param facility_reported_no Response code(s) indicating no facility is available (reported).
#' @param facility_reported_undefined Response code(s) for undefined reported facility situations.
#' @param facility_reported_water Column name for reported water availability under no permission or remote conditions.
#' @param facility_reported_water_yes Response code(s) indicating water is available under no permission or remote conditions.
#' @param facility_reported_water_no Response code indicating water is not available under no permission or remote conditions.
#' @param facility_reported_water_undefined Response code(s) for undefined water situations under no permission or remote conditions.
#' @param facility_reported_soap Column name for reported soap availability under no permission or remote conditions.
#' @param facility_reported_soap_yes Response code(s) indicating soap is available under no permission or remote conditions.
#' @param facility_reported_soap_no Response code indicating soap is not available under no permission or remote conditions.
#' @param facility_reported_soap_undefined Response code(s) for undefined soap situations under no permission or remote conditions.
#'
#' @return A data frame with an additional column 'wash_handwashing_facility_jmp_cat': Categorized handwashing facilities: "Basic," "Limited," or "No Facility."
#'
#' @details
#' The function checks for the presence and validity of all required columns and values in the input data frame. It ensures that all parameters are documented and used in the logic. The categorization follows JMP (Joint Monitoring Programme) standards for handwashing facilities.
#'
#' @export
add_handwashing_facility_cat <- function(
  df,
  survey_modality = "survey_modality",
  survey_modality_in_person = c("in_person"),
  survey_modality_remote = c("remote"),
  facility = "wash_handwashing_facility",
  facility_yes = c(
    "available_fixed_in_dwelling",
    "available_fixed_in_plot",
    "available_fixed_or_mobile"
  ),
  facility_no = "none",
  facility_no_permission = "no_permission",
  facility_undefined = c("other", "pnta"),
  facility_observed_water = "wash_handwashing_facility_observed_water",
  facility_observed_water_yes = "water_available",
  facility_observed_water_no = "water_not_available",
  facility_observed_soap = "wash_soap_observed",
  facility_observed_soap_yes = "yes_soap_shown",
  facility_observed_soap_no = "no",
  facility_observed_soap_undefined = c("other", "pnta"),
  facility_reported = "wash_handwashing_facility_reported",
  facility_reported_yes = c("fixed_dwelling", "fixed_yard", "mobile"),
  facility_reported_no = c("none"),
  facility_reported_undefined = c("other", "dnk", "pnta"),
  facility_reported_water = "wash_handwashing_facility_water_reported",
  facility_reported_water_yes = "yes",
  facility_reported_water_no = "no",
  facility_reported_water_undefined = c("dnk", "pnta"),
  facility_reported_soap = "wash_soap_reported",
  facility_reported_soap_yes = "yes",
  facility_reported_soap_no = "no",
  facility_reported_soap_undefined = c("dnk", "pnta")
) {
  #------ Checks

  # Check that variables are in df
  if_not_in_stop(
    df,
    c(
      survey_modality,
      facility,
      facility_observed_water,
      facility_observed_soap,
      facility_reported,
      facility_reported_water,
      facility_reported_soap
    ),
    "df"
  )

  # Checks that values are in set
  are_values_in_set(
    df,
    survey_modality,
    c(survey_modality_in_person, survey_modality_remote)
  )
  are_values_in_set(
    df,
    facility,
    c(facility_yes, facility_no, facility_no_permission, facility_undefined)
  )
  are_values_in_set(
    df,
    facility_observed_water,
    c(facility_observed_water_yes, facility_observed_water_no)
  )
  are_values_in_set(
    df,
    facility_observed_soap,
    c(
      facility_observed_soap_yes,
      facility_observed_soap_no,
      facility_observed_soap_undefined
    )
  )
  are_values_in_set(
    df,
    facility_reported,
    c(facility_reported_yes, facility_reported_no, facility_reported_undefined)
  )
  are_values_in_set(
    df,
    facility_reported_water,
    c(
      facility_reported_water_yes,
      facility_reported_water_no,
      facility_reported_water_undefined
    )
  )
  are_values_in_set(
    df,
    facility_reported_soap,
    c(
      facility_reported_soap_yes,
      facility_reported_soap_no,
      facility_reported_soap_undefined
    )
  )

  # Check lengths
  # - length of facility_yes
  if (length(facility_yes) < 1) {
    rlang::abort("facility_yes must contain at least one valid response code.")
  }
  # - length of facility_no
  if (length(facility_no) != 1) {
    rlang::abort("facility_no should be of length 1.")
  }
  # - length of facility_no_permission
  if (length(facility_no_permission) != 1) {
    rlang::abort("facility_no_permission should be of length 1.")
  }
  # - length of facility_undefined
  if (length(facility_undefined) < 1) {
    rlang::abort(
      "facility_undefined must contain at least one valid response code."
    )
  }

  df <- dplyr::mutate(
    df,
    wash_handwashing_facility_jmp_cat = dplyr::case_when(
      # Option 1: In-person modality with permission
      !!rlang::sym(survey_modality) %in% survey_modality_in_person &
        !(!!rlang::sym(facility) %in% facility_no_permission) ~
        dplyr::case_when(
          # Undefined
          !!rlang::sym(facility) %in% facility_undefined ~ "undefined",
          # No facility, then "no_facility"
          !!rlang::sym(facility) == facility_no ~ "no_facility",
          # Yes facility + Soap and water are available, then "basic"
          !!rlang::sym(facility) %in% facility_yes &
            !!rlang::sym(facility_observed_water) ==
              facility_observed_water_yes &
            !!rlang::sym(facility_observed_soap) == facility_observed_soap_yes ~
            "basic",
          # Yes facility + Soap or water is not available, then "limited"
          !!rlang::sym(facility) %in% facility_yes &
            (!!rlang::sym(facility_observed_water) ==
              facility_observed_water_no |
              !!rlang::sym(facility_observed_soap) ==
                facility_observed_soap_no) ~
            "limited",
          TRUE ~ NA_character_
        ),
      # Option 2: Remote modality or  with no permission
      !!rlang::sym(survey_modality) %in% survey_modality_remote |
        !!rlang::sym(facility) %in% facility_no_permission ~
        dplyr::case_when(
          # facility reported is undefined, then "undefined"
          !!rlang::sym(facility_reported) %in% facility_reported_undefined ~
            "undefined",
          # No facility + Soap and water are available, then "basic"
          !!rlang::sym(facility_reported) %in% facility_reported_yes &
            !!rlang::sym(facility_reported_water) ==
              facility_reported_water_yes &
            !!rlang::sym(facility_reported_soap) == facility_reported_soap_yes ~
            "basic",
          # No facility + Soap or water is not available, then "limited"
          !!rlang::sym(facility_reported) %in% facility_reported_no &
            (!!rlang::sym(facility_reported_water) ==
              facility_reported_water_no |
              !!rlang::sym(facility_reported_soap) ==
                facility_reported_soap_no) ~
            "limited",
          TRUE ~ NA_character_
        ),
      TRUE ~ NA_character_
    )
  )

  return(df)
}
