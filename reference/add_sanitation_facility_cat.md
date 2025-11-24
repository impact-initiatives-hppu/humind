# Sanitation Facility Classification

This set of functions classifies sanitation facilities according to
various criteria. It includes functions to categorize sanitation
facility types, sharing status, number of individuals sharing, and JMP
(Joint Monitoring Programme) classification.

This function recodes the sharing status of sanitation facilities based
on user responses. It categorizes whether the facility is shared or not
shared and handles cases where the facility was skipped.

This function calculates the number of households sharing a sanitation
facility and categorizes them based on predefined thresholds. It also
handles the household size and survey weights in calculations.

This function combines the previous two functions to recode the
sanitation facility into a JMP classification. It also includes
information about whether the facility is shared or not shared.

## Usage

``` r
add_sanitation_facility_cat(
  df,
  sanitation_facility = "wash_sanitation_facility",
  improved = c("flush_piped_sewer", "flush_septic_tank", "flush_pit_latrine",
    "flush_dnk_where", "pit_latrine_slab", "twin_pit_latrine_slab",
    "ventilated_pit_latrine_slab", "container", "compost"),
  unimproved = c("flush_open_drain", "flush_elsewhere", "pit_latrine_wo_slab", "bucket",
    "hanging_toilet", "plastic_bag"),
  none = "none",
  undefined = c("other", "dnk", "pnta")
)

add_sharing_sanitation_facility_cat(
  df,
  sharing_sanitation_facility = "wash_sanitation_facility_sharing_yn",
  yes = "yes",
  no = "no",
  undefined = c("dnk", "pnta"),
  sanitation_facility = "wash_sanitation_facility",
  skipped_sanitation_facility = NULL
)

add_sharing_sanitation_facility_n_ind(
  df,
  sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat",
  sharing_sanitation_facility_cat_shared = "shared",
  sharing_sanitation_facility_cat_not_shared = "not_shared",
  sharing_sanitation_facility_cat_not_applicable = "not_applicable",
  sharing_sanitation_facility_cat_undefined = "undefined",
  sanitation_facility_sharing_n = "wash_sanitation_facility_sharing_n",
  hh_size = "hh_size",
  weight = "weight"
)

add_sanitation_facility_jmp_cat(
  df,
  sanitation_facility_cat = "wash_sanitation_facility_cat",
  sanitation_facility_cat_improved = "improved",
  sanitation_facility_cat_unimproved = "unimproved",
  sanitation_facility_cat_none = "none",
  sanitation_facility_cat_undefined = "undefined",
  sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat",
  sharing_sanitation_facility_cat_shared = "shared",
  sharing_sanitation_facility_cat_not_shared = "not_shared",
  sharing_sanitation_facility_cat_not_applicable = "not_applicable",
  sharing_sanitation_facility_cat_undefined = "undefined"
)
```

## Arguments

- df:

  A data frame containing both sanitation facility types and sharing
  status information.

- sanitation_facility:

  Column name for sanitation facility types.

- improved:

  Character vector of response codes for Improved facilities.

- unimproved:

  Character vector of response codes for Unimproved facilities.

- none:

  Character vector of response codes for No sanitation facility/Open
  defecation.

- undefined:

  Character vector of response codes indicating undefined responses
  (e.g., c("dnk", "pnta")).

- sharing_sanitation_facility:

  Component column: Number of people with whom the facility is shared.

- yes:

  Character vector of response codes for Yes.

- no:

  Character vector of response codes for No.

- skipped_sanitation_facility:

  Character vector of response codes for skipped sanitation facility.

- sharing_sanitation_facility_cat:

  Component column: Sharing status of sanitation facility recoded.

- sharing_sanitation_facility_cat_shared:

  Level: Shared sanitation facility.

- sharing_sanitation_facility_cat_not_shared:

  Level: Not shared sanitation facility.

- sharing_sanitation_facility_cat_not_applicable:

  Level: Not applicable sharing status.

- sharing_sanitation_facility_cat_undefined:

  Level: Undefined sharing status.

- sanitation_facility_sharing_n:

  Component column: Number of households sharing the sanitation
  facility.

- hh_size:

  Column name for household size.

- weight:

  Column name for survey weights.

- sanitation_facility_cat:

  Component column: Sanitation facility types recoded.

- sanitation_facility_cat_improved:

  Level: Improved sanitation facility.

- sanitation_facility_cat_unimproved:

  Level: Unimproved sanitation facility.

- sanitation_facility_cat_none:

  Level: No sanitation facility.

- sanitation_facility_cat_undefined:

  Level: Undefined sanitation facility.

## Value

A data frame with an additional column:

- wash_sanitation_facility_cat: Categorized sanitation facility: "none",
  "unimproved", "improved", or "undefined".

A data frame with an additional column:

- wash_sharing_sanitation_facility_cat: Categorized sharing status:
  "shared", "not_shared", or "not_applicable".

A data frame with an additional column:

- wash_sharing_sanitation_n_ind: Categorized number of individuals
  sharing a sanitation facility.

A data frame with an additional column:

- wash_sanitization_jmp_cat: Categorized JMP classification based on
  both type and sharing status.
