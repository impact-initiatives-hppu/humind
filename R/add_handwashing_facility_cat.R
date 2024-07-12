#' Add frequent expenditure type amount as proportions of total frequent expenditure
#'
#' @param df Data frame containing the survey data.
#' @param survey_modality Column name for the survey modality - e.g., "survey_modality".
#' @param survey_modality_in_person Options for the in-person survey modality.
#' @param survey_modality_remote Options for the remote survey modality.
#' @param facility Column name for the observed handwashing facility - e.g., "wash_handwashing_facility".
#' @param reported_facility Column name for the reported handwashing facility - e.g., "wash_handwashing_facility_reported".
#' @param observed_soap Column name for observed soap availability - e.g., "wash_handwashing_facility_observed_soap".
#' @param observed_soap_options Options for the soap availability variable.
#' @param observed_water Column name for observed water availability - e.g., "wash_handwashing_facility_observed_water".
#' @param observed_water_options Options for the water availability variable.
#' @param facility_options1 Options for the observed facility variable for in-person surveys.
#' @param facility_options2 Options for the observed facility variable for remote surveys or "No permission to see".
#' @param facility_reported_options Options for the reported facility variable for remote surveys.
#'
#' @export
add_handwashing_facility_cat <- function(
  df,
  survey_modality = "survey_modality",
  survey_modality_in_person = c("in_person"),
  survey_modality_remote = c("remote"),
  facility = "wash_handwashing_facility",
  reported_facility = "wash_handwashing_facility_reported",
  observed_soap = "wash_handwashing_facility_observed_soap",
  observed_soap_options = c("soap_available",
  "soap_not_available", "alternative_available"),
  observed_water = "wash_handwashing_facility_observed_water",
  observed_water_options = c("water_available", "water_not_available"),
  facility_options1 = c("available", "none"),
  facility_options2 = c("no_permission"),
  facility_reported_options = c("fixed_dwelling", "fixed_yard", "mobile", "none", "other", "dnk", "pnta")
){

  # Option 1: Process for In-person modality
  df_in_person <- dplyr::filter(df, !!rlang::sym(survey_modality) %in% survey_modality_in_person & !!rlang::sym(facility) %in% facility_options1)
  df_in_person <- dplyr::mutate(
    df_in_person,
    wash_handwashing_facility_yn = dplyr::case_when(
      !!rlang::sym(facility) == facility_options1[1] ~ 1,
      !!rlang::sym(facility) == facility_options1[2] ~ 0,
      .default = NA_real_
    ),
    wash_soap_yn = dplyr::case_when(
      !!rlang::sym(observed_soap) == observed_soap_options[1] ~ 1,
      !!rlang::sym(observed_soap) %in% observed_soap_options[-1] ~ 0,
      .default = NA_real_
    ),
    wash_handwashing_facility_jmp_cat = dplyr::case_when(
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 & !!rlang::sym(observed_water) == observed_water_options[1] ~ "basic",
      wash_handwashing_facility_yn == 1 & (wash_soap_yn == 0 | !!rlang::sym(observed_water) == observed_water_options[2]) ~ "limited",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 & !!rlang::sym(observed_water) == observed_water_options[2] ~ "limited",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 0 & !!rlang::sym(observed_water) == observed_water_options[1] ~ "limited",
      wash_handwashing_facility_yn == 0 ~ "no_facility",
      .default = NA_character_
    ))

  # Option 2: Process for Remote modality or No permission to see
  df_remote <-dplyr::filter(df, !!rlang::sym(survey_modality) %in% survey_modality_remote | !!rlang::sym(facility) %in% facility_options2)
  df_remote <- dplyr::mutate(
    df,
    wash_handwashing_facility_yn = dplyr::case_when(
      !!rlang::sym(reported_facility) %in% facility_reported_options[1:3] ~ 1,
      !!rlang::sym(reported_facility)  %in% facility_reported_options[4:5] ~ 0,
      .default = NA_real_
    ),
    wash_soap_yn = dplyr::case_when(
      !!rlang::sym(observed_soap) == observed_soap_options[1] ~ 1,
      !!rlang::sym(observed_soap) %in% observed_soap_options[-1] ~ 0,
      .default = NA_real_
    ),
    wash_handwashing_facility_jmp_cat = dplyr::case_when(
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 ~ "basic",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 0 ~ "limited",
      wash_handwashing_facility_yn == 0 ~ "no_facility",
      .default = NA_character_
    ))

  # Combine both processed data frames
  df <- dplyr::bind_rows(df_in_person, df_remote)

  return(df)
}
