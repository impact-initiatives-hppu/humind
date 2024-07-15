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
  facility_reported = "wash_handwashing_facility_reported",
  facility_reported_yes = c("fixed_dwelling", "fixed_yard", "mobile"),
  facility_reported_no = c("none"),
  facility_reported_undefined = c("other", "dnk", "pnta"),
  observed_soap = "wash_handwashing_facility_observed_soap",
  observed_soap_yes = "soap_available",
  observed_soap_no = "soap_not_available",
  observed_soap_alternative = "alternative_available",
  observed_water = "wash_handwashing_facility_observed_water",
  observed_water_yes = "water_available",
  observed_water_no = "water_not_available"){

  #------ Checks

  # Check that variables are in df
  if_not_in_stop(df, c(survey_modality, facility, facility_reported, observed_soap, observed_water), "df")

  # Checks that values are in set 
  are_values_in_set(df, survey_modality, c(survey_modality_in_person, survey_modality_remote))
  are_values_in_set(df, facility, c(facility_yes, facility_no, facility_no_permission, facility_undefined))
  are_values_in_set(df, facility_reported, c(facility_reported_yes, facility_reported_no, facility_reported_undefined))
  are_values_in_set(df, observed_soap, c(observed_soap_yes, observed_soap_no, observed_soap_alternative))
  are_values_in_set(df, observed_water, c(observed_water_yes, observed_water_no))

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



  #------ Recode option 1: Process for In-person modality with permission to see

  df_in_person <- dplyr::filter(df, !!rlang::sym(survey_modality) %in% survey_modality_in_person & !!rlang::sym(facility) %in% facility_yes)
  df_in_person <- dplyr::mutate(
    df_in_person,
    wash_handwashing_facility_yn = dplyr::case_when(
      !!rlang::sym(facility) == facility_yes ~ 1,
      !!rlang::sym(facility) == facility_no ~ 0,
      .default = NA_real_
    ),
    wash_soap_yn = dplyr::case_when(
      !!rlang::sym(observed_soap) == observed_soap_yes ~ 1,
      !!rlang::sym(observed_soap) %in% c(observed_soap_no, observed_soap_alternative) ~ 0,
      .default = NA_real_
    ),
    wash_handwashing_facility_jmp_cat = dplyr::case_when(
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 & !!rlang::sym(observed_water) == observed_water_yes ~ "basic",
      wash_handwashing_facility_yn == 1 & (wash_soap_yn == 0 | !!rlang::sym(observed_water) == observed_water_no) ~ "limited",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 & !!rlang::sym(observed_water) == observed_water_no ~ "limited",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 0 & !!rlang::sym(observed_water) == observed_water_yes ~ "limited",
      wash_handwashing_facility_yn == 0 ~ "no_facility",
      .default = NA_character_
    ))

  # Option 2: Process for Remote modality or No permission to see
  df_remote <-dplyr::filter(df, !!rlang::sym(survey_modality) %in% survey_modality_remote | !!rlang::sym(facility) %in% facility_no_permission)
  df_remote <- dplyr::mutate(
    df_remote,
    wash_handwashing_facility_yn = dplyr::case_when(
      !!rlang::sym(facility_reported) %in% facility_reported_yes ~ 1,
      !!rlang::sym(facility_reported)  %in% facility_reported_no ~ 0,
      .default = NA_real_
    ),
    wash_soap_yn = dplyr::case_when(
      !!rlang::sym(observed_soap) == observed_soap_yes ~ 1,
      !!rlang::sym(observed_soap) %in% c(observed_soap_no, observed_soap_alternative) ~ 0,
      .default = NA_real_
    ),
    wash_handwashing_facility_jmp_cat = dplyr::case_when(
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 ~ "basic",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 0 ~ "limited",
      wash_handwashing_facility_yn == 0 ~ "no_facility",
      .default = NA_character_
    )
  )

  # Combine both processed data frames
  df <- dplyr::bind_rows(df_in_person, df_remote)

  return(df)
}
