#' Add frequent expenditure type amount as proportions of total frequent expenditure
#'
#' @param df: Data frame containing the survey data.
#' @param survey_modality: Column name for the survey modality - e.g., "survey_modality".
#' @param facility_var: Column name for the observed handwashing facility - e.g., "wash_handwashing_facility".
#' @param facility_reported_var: Column name for the reported handwashing facility - e.g., "wash_handwashing_facility_reported".
#' @param soap_var: Column name for observed soap availability - e.g., "wash_handwashing_facility_observed_soap".
#' @param water_var: Column name for observed water availability - e.g., "wash_handwashing_facility_observed_water".
#' @param facility_options1: Options for the observed facility variable for in-person surveys.
#' @param facility_options2: Options for the observed facility variable for remote surveys or "No permission to see".
#' @param facility_reported_options: Options for the reported facility variable for remote surveys.
#' @param soap_options: Options for the soap availability variable.
#' @param water_options: Options for the water availability variable.
#' @param modality_options1: Options for the in-person survey modality.
#' @param modality_options2: Options for the remote survey modality.
#'
#' @export
add_handwashing_facility_cat <- function(df,
                                         survey_modality = "survey_modality",
                                         facility_var = "wash_handwashing_facility",
                                         facility_reported_var = "wash_handwashing_facility_reported",
                                         soap_var = "wash_handwashing_facility_observed_soap",
                                         water_var = "wash_handwashing_facility_observed_water",
                                         facility_options1 = c("Fixed or mobile handwashing place in dwelling/yard/plot",
                                                               "No handwashing place in dwelling/yard/plot"),
                                         facility_options2 = c("No permission to see"),
                                         facility_reported_options = c("Fixed facility reported (sink/tap) in dwelling",
                                                                       "Fixed facility reported (sink/tap) in yard/plot",
                                                                       "Mobile object reported (bucket/jug/kettle)",
                                                                       "No handwashing place in dwelling/yard/plot",
                                                                       "Don’t know"),
                                         soap_options = c("Soap or detergent available",
                                                          "Soap or detergent not available",
                                                          "Ash / Mud / Sand"),
                                         water_options = c("Water is available",
                                                           "Water is not available"),
                                         modality_options1 = c("In person"),
                                         modality_options2 = c("Remote")
) {

  # Option 1: Process for In-person modality
  df_in_person <- df %>%
    filter({{survey_modality}} %in% modality_options1 &
             {{facility_var}} %in% facility_options1) %>%
    mutate(wash_handwashing_facility_yn = case_when(
      {{facility_var}} == facility_options1[1] ~ 1,
      {{facility_var}} == facility_options1[2] ~ 0,
      TRUE ~ NA_real_
    ),
    wash_soap_yn = case_when(
      {{soap_var}} == soap_options[1] ~ 1,
      {{soap_var}} %in% soap_options[-1] ~ 0,
      TRUE ~ NA_real_
    ),
    handwashing_facility_jmp_cat = case_when(
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 & {{water_var}} == water_options[1] ~ "Basic",
      wash_handwashing_facility_yn == 1 & (wash_soap_yn == 0 | {{water_var}} == water_options[2]) ~ "Limited",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 & {{water_var}} == water_options[2] ~ "Limited",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 0 & {{water_var}} == water_options[1] ~ "Limited",
      wash_handwashing_facility_yn == 0 ~ "No facility",
      TRUE ~ NA_character_
    ))

  # Option 2: Process for Remote modality or No permission to see
  df_remote <- df %>%
    filter({{survey_modality}} %in% modality_options2 |
             {{facility_var}} %in% facility_options2) %>%
    mutate(wash_handwashing_facility_yn = case_when(
      {{facility_reported_var}} %in% facility_reported_options[1:3] ~ 1,
      {{facility_reported_var}} %in% facility_reported_options[4:5] ~ 0,
      TRUE ~ NA_real_
    ),
    wash_soap_yn = case_when(
      {{soap_var}} == soap_options[1] ~ 1,
      {{soap_var}} %in% soap_options[-1] ~ 0,
      TRUE ~ NA_real_
    ),
    handwashing_facility_jmp_cat = case_when(
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 1 ~ "Basic",
      wash_handwashing_facility_yn == 1 & wash_soap_yn == 0 ~ "Limited",
      wash_handwashing_facility_yn == 0 ~ "No facility",
      TRUE ~ NA_character_
    ))

  # Combine both processed data frames
  df_combined <- bind_rows(df_in_person, df_remote)

  return(df_combined)
}
