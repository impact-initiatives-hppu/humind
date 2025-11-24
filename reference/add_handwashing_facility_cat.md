# Add Handwashing Facility Category

This function categorizes handwashing facilities into "Basic,"
"Limited," or "No facility" based on survey data. It evaluates various
parameters related to the availability of handwashing facilities and the
presence of soap and water.

## Usage

``` r
add_handwashing_facility_cat(
  df,
  survey_modality = "survey_modality",
  survey_modality_in_person = c("in_person"),
  survey_modality_remote = c("remote"),
  facility = "wash_handwashing_facility",
  facility_yes = c("available_fixed_in_dwelling", "available_fixed_in_plot",
    "available_fixed_or_mobile"),
  facility_no = "none",
  facility_no_permission = "no_permission",
  facility_undefined = c("other", "pnta"),
  facility_observed_water = "wash_handwashing_facility_observed_water",
  facility_observed_water_yes = "water_available",
  facility_observed_water_no = c("water_not_available"),
  facility_observed_soap = "wash_soap_observed",
  facility_observed_soap_yes = "yes_soap_shown",
  facility_observed_soap_no = c("no"),
  facility_observed_soap_undefined = c("other", "pnta"),
  facility_reported = "wash_handwashing_facility_reported",
  facility_reported_yes = c("fixed_dwelling", "fixed_yard", "mobile"),
  facility_reported_no = c("none"),
  facility_reported_undefined = c("other", "dnk", "pnta"),
  facility_reported_water = "wash_handwashing_facility_water_reported",
  facility_reported_water_yes = "yes",
  facility_reported_water_no = c("no"),
  facility_reported_water_undefined = c("dnk", "pnta"),
  facility_reported_soap = "wash_soap_reported",
  facility_reported_soap_yes = "yes",
  facility_reported_soap_no = c("no"),
  facility_reported_soap_undefined = c("dnk", "pnta"),
  soap_type_observed = "wash_soap_observed_type",
  soap_type_observed_yes = c("soap", "detergent"),
  soap_type_observed_no = c("ash_mud_sand"),
  soap_type_observed_undefined = c("dnk", "pnta", "other"),
  soap_type_reported = "wash_soap_reported_type",
  soap_type_reported_yes = c("soap", "detergent"),
  soap_type_reported_no = c("ash_mud_sand"),
  soap_type_reported_undefined = c("dnk", "pnta", "other")
)
```

## Arguments

- df:

  A data frame containing the survey data.

- survey_modality:

  Column name for the survey modality (e.g., "survey_modality").

- survey_modality_in_person:

  Options for the in-person survey modality.

- survey_modality_remote:

  Options for the remote survey modality.

- facility:

  Column name for the observed handwashing facility (e.g.,
  "wash_handwashing_facility").

- facility_yes:

  Response code(s) indicating availability (e.g., "available").

- facility_no:

  Response code indicating unavailability (e.g., "none").

- facility_no_permission:

  Response code for cases with no permission to observe.

- facility_undefined:

  Response code(s) for undefined situations.

- facility_observed_water:

  Column name for observed water availability (e.g.,
  "wash_handwashing_facility_observed_water").

- facility_observed_water_yes:

  Response code indicating water is available.

- facility_observed_water_no:

  Response code(s) indicating water is not available.

- facility_observed_soap:

  Column name for observed soap availability.

- facility_observed_soap_yes:

  Response code indicating soap is available (observed).

- facility_observed_soap_no:

  Response code(s) indicating soap is not available (observed).

- facility_observed_soap_undefined:

  Response code(s) for undefined observed soap situations.

- facility_reported:

  Column name for reported handwashing facility (used in
  remote/no-permission cases).

- facility_reported_yes:

  Response code(s) indicating facility is available (reported).

- facility_reported_no:

  Response code(s) indicating no facility is available (reported).

- facility_reported_undefined:

  Response code(s) for undefined reported facility situations.

- facility_reported_water:

  Column name for reported water availability under no permission or
  remote conditions.

- facility_reported_water_yes:

  Response code(s) indicating water is available under no permission or
  remote conditions.

- facility_reported_water_no:

  Response code(s) indicating water is not available under no permission
  or remote conditions.

- facility_reported_water_undefined:

  Response code(s) for undefined water situations under no permission or
  remote conditions.

- facility_reported_soap:

  Column name for reported soap availability under no permission or
  remote conditions.

- facility_reported_soap_yes:

  Response code(s) indicating soap is available under no permission or
  remote conditions.

- facility_reported_soap_no:

  Response code(s) indicating soap is not available under no permission
  or remote conditions.

- facility_reported_soap_undefined:

  Response code(s) for undefined soap situations under no permission or
  remote conditions.

- soap_type_observed:

  Column name for the type of soap (observed).

- soap_type_observed_yes:

  Response code(s) indicating soap is observed

- soap_type_observed_no:

  Response code(s) indicating soap is NOT observed

- soap_type_observed_undefined:

  Response code(s) for undefined situations.

- soap_type_reported:

  Column name for the type of soap (reported).

- soap_type_reported_yes:

  Response code(s) indicating soap is available.

- soap_type_reported_no:

  Response code(s) indicating soap is NOT available.

- soap_type_reported_undefined:

  Response code(s) for undefined situations.

## Value

A data frame with an additional column
'wash_handwashing_facility_jmp_cat': Categorized handwashing facilities:
"Basic," "Limited," or "No Facility."

## Details

The function checks for the presence and validity of all required
columns and values in the input data frame. It ensures that all
parameters are documented and used in the logic. The categorization
follows JMP (Joint Monitoring Programme) standards for handwashing
facilities.
