# Add Healthcare Needed Category to Individual Data

This function adds healthcare need categories to individual-level data,
including disability information if provided. It creates dummy variables
for different healthcare need scenarios and optionally includes
disability-specific indicators.

This function aggregates individual-level healthcare need data to the
household level, including disability-specific information if provided.

## Usage

``` r
add_loop_healthcare_needed_cat(
  loop,
  ind_healthcare_needed = "health_ind_healthcare_needed",
  ind_healthcare_needed_no = "no",
  ind_healthcare_needed_yes = "yes",
  ind_healthcare_needed_dnk = "dnk",
  ind_healthcare_needed_pnta = "pnta",
  ind_healthcare_received = "health_ind_healthcare_received",
  ind_healthcare_received_no = "no",
  ind_healthcare_received_yes = "yes",
  ind_healthcare_received_dnk = "dnk",
  ind_healthcare_received_pnta = "pnta",
  ind_age = "ind_age"
)

add_loop_healthcare_needed_cat_to_main(
  main,
  loop,
  ind_healthcare_needed_no = "health_ind_healthcare_needed_no",
  ind_healthcare_needed_yes_unmet = "health_ind_healthcare_needed_yes_unmet",
  ind_healthcare_needed_yes_met = "health_ind_healthcare_needed_yes_met",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
```

## Arguments

- loop:

  A data frame of individual-level data.

- ind_healthcare_needed:

  The name of the variable that indicates if healthcare is needed.

- ind_healthcare_needed_no:

  The binary variable that indicates if healthcare is not needed.

- ind_healthcare_needed_yes:

  Level for "yes" in ind_healthcare_needed.

- ind_healthcare_needed_dnk:

  Level for "don't know" in ind_healthcare_needed.

- ind_healthcare_needed_pnta:

  Level for "prefer not to answer" in ind_healthcare_needed.

- ind_healthcare_received:

  The name of the variable that indicates if healthcare is received.

- ind_healthcare_received_no:

  Level for "no" in ind_healthcare_received.

- ind_healthcare_received_yes:

  Level for "yes" in ind_healthcare_received.

- ind_healthcare_received_dnk:

  Level for "don't know" in ind_healthcare_received.

- ind_healthcare_received_pnta:

  Level for "prefer not to answer" in ind_healthcare_received.

- ind_age:

  The name of the variable that indicates the age of the individual.

- main:

  A data frame of household-level data.

- ind_healthcare_needed_yes_unmet:

  The binary variable that indicates if healthcare is needed but unmet.

- ind_healthcare_needed_yes_met:

  The binary variable that indicates if healthcare is needed and met.

- id_col_main:

  The column name for the unique identifier in the main data frame.

- id_col_loop:

  The column name for the unique identifier in the loop data frame.

## Value

A data frame with additional columns:

- health_ind_healthcare_needed_d: Dummy variable for healthcare needed.

- health_ind_healthcare_received_d: Dummy variable for healthcare
  received.

- health_ind_healthcare_needed_cat: Categorized healthcare need:
  "no_need", "yes_unmet_need", or "yes_met_need".

- health_ind_healthcare_needed_no: Dummy variable for no healthcare
  need.

- health_ind_healthcare_needed_yes_unmet: Dummy variable for unmet
  healthcare need.

- health_ind_healthcare_needed_yes_met: Dummy variable for met
  healthcare need.

A data frame with additional columns:

- health_ind_healthcare_needed_no_n: Count of individuals not needing
  healthcare.

- health_ind_healthcare_needed_yes_unmet_n: Count of individuals with
  unmet healthcare needs.

- health_ind_healthcare_needed_yes_met_n: Count of individuals with met
  healthcare needs.
