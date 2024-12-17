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
#' @param facility_yes Response code indicating availability (e.g., "available").
#' @param facility_no Response code indicating unavailability (e.g., "none").
#' @param facility_no_permission Response code for cases with no permission to observe.
#' @param facility_undefined Response code for undefined situations.
#' @param facility_observed_water Column name for observed water availability (e.g., "wash_handwashing_facility_observed_water").
#' @param facility_observed_water_yes Response code indicating water is available.
#' @param facility_observed_water_no Response code indicating water is not available.
#' @param facility_observed_soap Column name for observed soap availability (e.g., "wash_handwashing_facility_observed_soap").
#' @param facility_observed_soap_yes Response code indicating soap is available.
#' @param facility_observed_soap_no Response code indicating soap is not available.
#' @param facility_observed_soap_alternative Response code for alternative cleaning agents.
#' @param facility_reported Column name for reported handwashing facilities (e.g., "wash_handwashing_facility_reported").
#' @param facility_reported_yes Response codes indicating reported availability (e.g., "fixed_dwelling", "fixed_yard", "mobile").
#' @param facility_reported_no Response code indicating reported unavailability (e.g., "none").
#' @param facility_reported_undefined Response codes for undefined reports.
#' @param facility_reported_no_permission_soap Column name for reported soap availability under no permission conditions.
#' @param facility_reported_no_permission_soap_yes Response codes indicating soap is shown under no permission conditions.
#' @param facility_reported_no_permission_soap_no Response code indicating soap is not shown under no permission conditions.
#' @param facility_reported_no_permission_soap_undefined Response codes for undefined situations under no permission conditions.
#' @param facility_reported_no_permission_soap_type Column name for the type of soap reported under no permission conditions.
#' @param facility_reported_no_permission_soap_type_yes Response codes indicating type of soap is shown.
#' @param facility_reported_no_permission_soap_type_no Response code indicating type of soap is not shown.
#' @param facility_reported_no_permission_soap_type_undefined Response codes for undefined types of soap reported under no permission conditions.
#' @param facility_reported_remote_soap Column name for remote cases reporting soap availability.
#' @param facility_reported_remote_soap_yes Response code indicating soap is available in remote cases.
#' @param facility_reported_remote_soap_no Response code indicating soap is not available in remote cases.
#' @param facility_reported_remote_soap_undefined Response codes for undefined situations in remote cases.
#' @param facility_reported_remote_soap_type Column name for the type of soap reported in remote cases.
#' @param facility_reported_remote_soap_type_yes Response codes indicating type of soap is available in remote cases.
#' @param facility_reported_remote_soap_type_no Response code indicating type of soap is not available in remote cases.
#' @param facility_reported_remote_soap_type_undefined Response codes for undefined types of soap reported in remote cases.
#'
#' @return A data frame with an additional column 'wash_handwashing_facility_jmp_cat': Categorized handwashing facilities: "Basic," "Limited," or "No Facility."
#'
#' @export
add_handwashing_facility_cat <- function(
  df,
  survey_modality = "survey_modality",
  survey_modality_in_person = c("in_person"),
  survey_modality_remote = c("remote"),
  facility = "wash_handwashing_facility",
  facility_yes = "available",
  facility_no = "none",
  facility_no_permission = "no_permission",
  facility_undefined = "other",
  facility_observed_water = "wash_handwashing_facility_observed_water",
  facility_observed_water_yes = "water_available",
  facility_observed_water_no = "water_not_available",
  facility_observed_soap = "wash_handwashing_facility_observed_soap",
  facility_observed_soap_yes = "soap_available",
  facility_observed_soap_no = "soap_not_available",
  facility_observed_soap_alternative = "alternative_available",
  facility_reported = "wash_handwashing_facility_reported",
  facility_reported_yes = c("fixed_dwelling", "fixed_yard", "mobile"),
  facility_reported_no = c("none"),
  facility_reported_undefined = c("other", "dnk", "pnta"),
  facility_reported_no_permission_soap = "wash_soap_observed",
  facility_reported_no_permission_soap_yes = c("yes_soap_shown", "yes_soap_not_shown"),
  facility_reported_no_permission_soap_no = "no",
  facility_reported_no_permission_soap_undefined = c("dnk", "pnta"),
  facility_reported_no_permission_soap_type = "wash_soap_observed_type",
  facility_reported_no_permission_soap_type_yes = c("soap", "detergent"),
  facility_reported_no_permission_soap_type_no = "ash_mud_sand",
  facility_reported_no_permission_soap_type_undefined = c("other", "dnk", "pnta"),
  facility_reported_remote_soap = "wash_soap_reported",
  facility_reported_remote_soap_yes = "yes",
  facility_reported_remote_soap_no = "no",
  facility_reported_remote_soap_undefined = c("dnk", "pnta"),
  facility_reported_remote_soap_type = "wash_soap_reported_type",
  facility_reported_remote_soap_type_yes = c("soap", "detergent"),
  facility_reported_remote_soap_type_no = c("ash_mud_sand"),
  facility_reported_remote_soap_type_undefined = c("other", "dnk", "pnta")
    ){

  #------ Checks

  # Check that variables are in df
  if_not_in_stop(df, c(survey_modality, facility, facility_observed_water, facility_observed_soap, facility_reported, facility_reported_no_permission_soap, facility_reported_no_permission_soap_type, facility_reported_remote_soap, facility_reported_remote_soap_type), "df")

  # Checks that values are in set
  are_values_in_set(df, survey_modality, c(survey_modality_in_person, survey_modality_remote))
  are_values_in_set(df, facility, c(facility_yes, facility_no, facility_no_permission, facility_undefined))
  are_values_in_set(df, facility_observed_water, c(facility_observed_water_yes, facility_observed_water_no))
  are_values_in_set(df, facility_observed_soap, c(facility_observed_soap_yes, facility_observed_soap_no, facility_observed_soap_alternative))
  are_values_in_set(df, facility_reported, c(facility_reported_yes, facility_reported_no, facility_reported_undefined))
  are_values_in_set(df, facility_reported_no_permission_soap, c(facility_reported_no_permission_soap_yes, facility_reported_no_permission_soap_no, facility_reported_no_permission_soap_undefined))
  are_values_in_set(df, facility_reported_no_permission_soap_type, c(facility_reported_no_permission_soap_type_yes, facility_reported_no_permission_soap_type_no, facility_reported_no_permission_soap_type_undefined))
  are_values_in_set(df, facility_reported_remote_soap, c(facility_reported_remote_soap_yes, facility_reported_remote_soap_no, facility_reported_remote_soap_undefined))
  are_values_in_set(df, facility_reported_remote_soap_type, c(facility_reported_remote_soap_type_yes, facility_reported_remote_soap_type_no, facility_reported_remote_soap_type_undefined))

  # Check lengths
  # - length 1 of facility_yes
  if (length(facility_yes) != 1) {
    rlang::abort("facility_yes should be of length 1.")
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
  if (length(facility_undefined) != 1) {
    rlang::abort("facility_undefined should be of length 1.")
  }
  # - length 1 of facility_observed_soap_yes
  if (length(facility_observed_soap_yes) != 1) {
    rlang::abort("facility_observed_soap_yes should be of length 1.")
  }
  # - length 1 of facility

df <- dplyr::mutate(
  df,
  wash_handwashing_facility_jmp_cat = dplyr::case_when(
    # Option 1: In-person modality with permission
    !!rlang::sym(survey_modality) %in% survey_modality_in_person &
        !(!!rlang::sym(facility) %in% facility_no_permission) ~
        dplyr::case_when(
          # Undefined
          !!rlang::sym(facility) == facility_undefined ~ "undefined",
          # No facility, then "no_facility"
          !!rlang::sym(facility) == facility_no ~ "no_facility",
          # Yes facility + Soap and water are available, then "basic"
          !!rlang::sym(facility) == facility_yes &
            !!rlang::sym(facility_observed_water) ==
              facility_observed_water_yes &
            !!rlang::sym(facility_observed_soap) == facility_observed_soap_yes
          ~ "basic",
          # Yes facility + Soap or water is not available, then "limited"
          !!rlang::sym(facility) == facility_yes & !!rlang::sym(facility_observed_water) == (facility_observed_water_no) | !!rlang::sym(facility_observed_soap) %in% c(facility_observed_soap_no, facility_observed_soap_alternative) ~ "limited",
          TRUE ~ NA_character_
        ),
    # Option 2: Remote modality or  with no permission
      !!rlang::sym(survey_modality) %in% survey_modality_remote |
        !!rlang::sym(facility) %in% facility_no_permission ~
        dplyr::case_when(
        # facility reported is undefined, then "undefined"
        !!rlang::sym(facility_reported) %in% facility_reported_undefined ~
          "undefined",
        # facility reported is "none", then "no_facility"
        !!rlang::sym(facility_reported) %in% facility_reported_no ~
          "no_facility",
        # facility reported is yes, then "limited"
        !!rlang::sym(facility_reported) %in% facility_reported_yes ~
          "limited",
          TRUE ~ NA_character_
        ),
      TRUE ~ NA_character_
    )
  )



  return(df)
}
