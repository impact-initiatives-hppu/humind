# Calculate Health Composite Score and Need Indicators

This function calculates a health composite score based on healthcare
access and needs. It considers whether individuals needed healthcare,
whether they accessed it if needed, and optionally takes into account
disability status. The function then determines if a household is in
need or in severe need of health assistance based on the calculated
score.

Prerequisite functions:

- add_loop_healthcare_needed_cat.R

## Usage

``` r
add_comp_health(
  df,
  ind_healthcare_needed_no_n = "health_ind_healthcare_needed_no_n",
  ind_healthcare_needed_yes_unmet_n = "health_ind_healthcare_needed_yes_unmet_n",
  ind_healthcare_needed_yes_met_n = "health_ind_healthcare_needed_yes_met_n"
)
```

## Arguments

- df:

  A data frame.

- ind_healthcare_needed_no_n:

  Column name for the number of individuals who did not need to access
  healthcare.

- ind_healthcare_needed_yes_unmet_n:

  Column name for the number of individuals who needed to access
  healthcare but did not.

- ind_healthcare_needed_yes_met_n:

  Column name for the number of individuals who needed to access
  healthcare and did.

## Value

A data frame with additional columns:

- comp_health_score: Health composite score (1-4)

- comp_health_in_need: Binary indicator for being in need of health
  assistance

- comp_health_in_severe_need: Binary indicator for being in severe need
  of health assistance
