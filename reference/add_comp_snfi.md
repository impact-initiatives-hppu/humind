# Add SNFI Sectoral Composite Score and Need Indicators

This function calculates the Shelter, NFI and HLP (SNFI) sectoral
composite score based on shelter type, shelter issues, occupancy status,
and functional disability scale (FDS) indicators. It also determines if
a household is in need or in severe need based on the calculated score.

Prerequisite functions:

- add_shelter_issue_cat.R

- add_shelter_type_cat.R

- add_occupancy_cat.R

- add_fds_cannot_cat.R

- OPTIONAL add_shelter_damage_cat.R

## Usage

``` r
add_comp_snfi(
  df,
  shelter_type_cat = "snfi_shelter_type_cat",
  shelter_type_cat_none = "none",
  shelter_type_cat_inadequate = "inadequate",
  shelter_type_cat_adequate = "adequate",
  shelter_type_cat_undefined = "undefined",
  shelter_issue_cat = "snfi_shelter_issue_cat",
  shelter_issue_cat_1_to_3 = "1_to_3",
  shelter_issue_cat_4_to_7 = "4_to_7",
  shelter_issue_cat_8_to_11 = "8_to_11",
  shelter_issue_cat_none = "none",
  shelter_issue_cat_undefined = "undefined",
  shelter_issue_cat_other = "other",
  tenure_security_cat = "hlp_occupancy_cat",
  tenure_security_cat_high_risk = "high_risk",
  tenure_security_cat_medium_risk = "medium_risk",
  tenure_security_cat_low_risk = "low_risk",
  tenure_security_cat_undefined = "undefined",
  fds_cannot_cat = "snfi_fds_cannot_cat",
  fds_cannot_cat_4 = "4_tasks",
  fds_cannot_cat_2_to_3 = "2_to_3_tasks",
  fds_cannot_cat_1 = "1_task",
  fds_cannot_cat_none = "none",
  fds_cannot_cat_undefined = "undefined",
  shelter_damage = FALSE,
  shelter_damage_cat = "snfi_shelter_damage_cat",
  shelter_damage_cat_none = "none",
  shelter_damage_cat_damaged = "damaged",
  shelter_damage_cat_part = "part",
  shelter_damage_cat_total = "total",
  shelter_damage_cat_undefined = "undefined"
)
```

## Arguments

- df:

  A data frame containing the required SNFI indicators.

- shelter_type_cat:

  Column name for shelter type.

- shelter_type_cat_none:

  Level for no shelter.

- shelter_type_cat_inadequate:

  Level for inadequate shelter.

- shelter_type_cat_adequate:

  Level for adequate shelter.

- shelter_type_cat_undefined:

  Level for undefined shelter.

- shelter_issue_cat:

  Column name for shelter issue.

- shelter_issue_cat_1_to_3:

  Level for 1 to 3 shelter issues.

- shelter_issue_cat_4_to_7:

  Level for 4 to 7 shelter issues.

- shelter_issue_cat_8_to_11:

  Level for 8 to 11 shelter issues.

- shelter_issue_cat_none:

  Level for no shelter issues.

- shelter_issue_cat_undefined:

  Level for undefined shelter issues.

- shelter_issue_cat_other:

  Level for other shelter issues.

- tenure_security_cat:

  Column name for security of tenure.

- tenure_security_cat_high_risk:

  Level for high risk with security of tenure.

- tenure_security_cat_medium_risk:

  Level for medium risk with security of tenure.

- tenure_security_cat_low_risk:

  Level for low risk with security of tenure.

- tenure_security_cat_undefined:

  Level for undefined with security of tenure.

- fds_cannot_cat:

  Column name for fds cannot.

- fds_cannot_cat_4:

  Level for 4 tasks that cannot be done.

- fds_cannot_cat_2_to_3:

  Level for 2 to 3 tasks that cannot be done.

- fds_cannot_cat_1:

  Level for 1 task that cannot be done.

- fds_cannot_cat_none:

  Level for no tasks that cannot be done.

- fds_cannot_cat_undefined:

  Level for undefined fds cannot.

- shelter_damage:

  Column for shelter damage.

- shelter_damage_cat:

  Column for shelter damage category.

- shelter_damage_cat_none:

  Level name for no shelter damage.

- shelter_damage_cat_damaged:

  Level name for minor damages.

- shelter_damage_cat_part:

  Level name for roof with risk of collapse.

- shelter_damage_cat_total:

  Level name for total collapse or destruction.

- shelter_damage_cat_undefined:

  Level name for undefined or unknown status for shelter damage.

## Value

A data frame with added columns:

- comp_snfi_score_shelter_type_cat Score based on shelter type

- comp_snfi_score_shelter_issue_cat Score based on shelter issues

- comp_snfi_score_tenure_security_cat Score based on security of tenure
  status

- comp_snfi_score_fds_cannot_cat Score based on FDS

- comp_snfi_score: Overall SNFI composite score

- comp_snfi_in_need: Indicator for being in need

- comp_snfi_in_severe_need: Indicator for being in severe need
