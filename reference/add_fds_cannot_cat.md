# Add Functional Domestic Space Tasks Categories

This function adds categories for functional domestic space tasks based
on various input parameters. It processes cooking, sleeping, storing,
and lighting tasks, creating new columns with standardized categories
and a summary of tasks that cannot be performed.

## Usage

``` r
add_fds_cannot_cat(
  df,
  fds_cooking = "snfi_fds_cooking",
  fds_cooking_can = "no",
  fds_cooking_cannot = "yes",
  fds_cooking_no_need = "no_need",
  fds_cooking_undefined = "pnta",
  fds_sleeping = "snfi_fds_sleeping",
  fds_sleeping_can = "yes",
  fds_sleeping_cannot = "no",
  fds_sleeping_undefined = "pnta",
  fds_storing = "snfi_fds_storing",
  fds_storing_cannot = "no",
  fds_storing_can = c("yes_issues", "yes_no_issues"),
  fds_storing_undefined = "pnta",
  lighting_source = "energy_lighting_source",
  lighting_source_none = "none",
  lighting_source_undefined = c("pnta", "dnk")
)
```

## Arguments

- df:

  A data frame containing the input columns

- fds_cooking:

  Column name for cooking tasks

- fds_cooking_can:

  Value for can perform cooking tasks without issues

- fds_cooking_cannot:

  Value for facing issues when cooking

- fds_cooking_no_need:

  Value for no need to perform cooking tasks

- fds_cooking_undefined:

  Vector of undefined responses for cooking tasks

- fds_sleeping:

  Column name for sleeping tasks

- fds_sleeping_can:

  Value for can perform sleeping tasks

- fds_sleeping_cannot:

  Value for cannot perform sleeping tasks

- fds_sleeping_undefined:

  Vector of undefined responses for sleeping tasks

- fds_storing:

  Column name for storing tasks

- fds_storing_cannot:

  Value for cannot perform storing tasks

- fds_storing_can:

  Value for can perform storing tasks

- fds_storing_undefined:

  Vector of undefined responses for storing tasks

- lighting_source:

  Column name for lighting source

- lighting_source_none:

  Value for no lighting source

- lighting_source_undefined:

  Vector of undefined responses for lighting source

## Value

A data frame with additional columns:

- snfi_fds_cooking: Standardized categories for cooking tasks

- snfi_fds_sleeping: Standardized categories for sleeping tasks

- snfi_fds_storing: Standardized categories for storing tasks

- energy_lighting_source: Standardized categories for lighting source

- snfi_fds_cannot_n: Number of tasks that cannot be performed

- snfi_fds_cannot_cat: Categorized number of tasks that cannot be
  performed
