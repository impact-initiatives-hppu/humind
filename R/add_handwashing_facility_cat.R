#' Add frequent expenditure type amount as proportions of total frequent expenditure
#'
#' @param df Data frame containing the survey data.
#' @param survey_modality Column name for the survey modality - e.g., "survey_modality".
#' @param survey_modality_in_person Options for the in-person survey modality.
#' @param survey_modality_remote Options for the remote survey modality.
#' @param facility Column name for the observed handwashing facility - e.g., "wash_handwashing_facility".
#' @param facility_yes Response code for yes.
#' @param facility_no Response code for no.
#' @param facility_no_permission Response code for no permission.
#' @param facility_undefined Response code for undefined.
#' @param facility_reported Column name for the reported handwashing facility - e.g., "wash_handwashing_facility_reported".
#' @param facility_reported_yes Response code for yes.
#' @param facility_reported_no Response code for no.
#' @param facility_reported_undefined Response code for undefined.
#' @param observed_soap Column name for observed soap availability - e.g., "wash_handwashing_facility_observed_soap".
#' @param observed_soap_yes Response code for yes.
#' @param observed_soap_no Response code for no.
#' @param observed_soap_alternative Response code for alternatives.
#' @param observed_water Column name for observed water availability - e.g., "wash_handwashing_facility_observed_water".
#' @param observed_water_yes Response code for yes.
#' @param observed_water_no Response code for no.
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
  # - length 1 of observed_soap_yes
  if (length(observed_soap_yes) != 1) {
    rlang::abort("observed_soap_yes should be of length 1.")
  }

  df <- dplyr::mutate(
    df,
    wash_handwashing_facility_jmp_cat = dplyr::case_when(
      # Option 1: Process for In-person modality with permission to see
      !!rlang::sym(survey_modality) %in% survey_modality_in_person & !(!!rlang::sym(facility) %in% facility_no_permission) ~ dplyr::case_when(
          # Undefined 
          !!rlang::sym(facility) == facility_undefined ~ "undefined",
          # No facility, then "no_facility"
          !!rlang::sym(facility) == facility_no ~ "no_facility",
          # Soap and water are available, then "basic"
          !!rlang::sym(facility) == facility_yes & !!rlang::sym(observed_water) == observed_water_yes & !!rlang::sym(observed_soap) == observed_soap_yes ~ "basic",
          # Soap or water is not available, then "limited"
          !!rlang::sym(facility) == facility_yes & !!rlang::sym(observed_water) == c(observed_water_no) | !!rlang::sym(observed_soap) %in% c(observed_soap_no, observed_soap_alternative) ~ "limited"
    ),
      # If remote facility reported is "none", then "no_facility"
    (!!rlang::sym(survey_modality) %in% survey_modality_remote) |  (!!rlang::sym(survey_modality) %in% survey_modality_in_person & !!rlang::sym(facility) %in% facility_no_permission) ~
      dplyr::case_when(
        # facility reported is "none", then "no_facility"
        !!rlang::sym(facility_reported) %in% facility_reported_none ~ "no_facility",
        # facility reported is undefined, then "undefined"
        !!rlang::sym(facility_reported) %in% facility_reported_undefined ~ "undefined",
        # facility reported is yes, then "limited"
        !!rlang::sym(facility_reported) %in% facility_reported_yes ~ "limited"
      )
    ),
    .default = NA_character_
  )


  return(df)
}
