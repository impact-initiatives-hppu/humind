# Combine and Recode Shelter Types

This function combines both shelter types questions and recodes the type
of shelter into categories such as "none", "inadequate", "adequate", or
"undefined".

## Usage

``` r
add_shelter_type_cat(
  df,
  shelter_type = "snfi_shelter_type",
  sl_none = "none",
  sl_collective_center = "collective_center",
  sl_undefined = "pnta",
  shelter_type_individual = "snfi_shelter_type_individual",
  adequate = c("house", "apartment"),
  inadequate = c("makeshift", "unfinished_building", "tent"),
  undefined = c("pnta", "other", "dnk")
)
```

## Arguments

- df:

  A data frame containing shelter type information.

- shelter_type:

  Component column: Shelter type categories.

- sl_none:

  Character vector of responses codes for none/sleeping in the open that
  are skipped.

- sl_collective_center:

  Character vector of responses codes for collective center that are
  skipped.

- sl_undefined:

  Character vector of undefined responses codes (e.g. "Prefer not to
  answer") that are skipped.

- shelter_type_individual:

  Component column: Individual shelter types.

- adequate:

  Character vector of responses codes for adequate shelter types.

- inadequate:

  Character vector of responses codes for inadequate shelter types.

- undefined:

  Character vector of responses codes for undefined shelter types.

## Value

A data frame with an additional column:

- snfi_shelter_type_cat: Categorized shelter type: "none", "inadequate",
  "adequate", or "undefined".
