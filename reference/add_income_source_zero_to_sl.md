# Add Zero to Income Sources When Skipped

This function adds zero to income source columns when the main income
source was skipped or undefined. It also ensures that all income sources
are zero when the main income source is "none".

## Usage

``` r
add_income_source_zero_to_sl(
  df,
  income_source = "cm_income_source",
  none = "none",
  undefined = c("dnk", "pnta"),
  income_sources = c("cm_income_source_salaried_n", "cm_income_source_casual_n",
    "cm_income_source_own_business_n", "cm_income_source_own_production_n",
    "cm_income_source_social_benefits_n", "cm_income_source_rent_n",
    "cm_income_source_remittances_n", "cm_income_source_assistance_n",
    "cm_income_source_support_friends_n", "cm_income_source_donation_n",
    "cm_income_source_other_n")
)
```

## Arguments

- df:

  A data frame containing income source information.

- income_source:

  A character string. The name of the column that contains the main
  income source.

- none:

  A character string. The value that indicates that no income source was
  selected.

- undefined:

  A character vector. The values that indicate that the income source
  was undefined or skipped.

- income_sources:

  A character vector. The names of the columns that contain the amount
  of income from various sources.

## Value

A data frame with updated income source columns:

- income_sources: All specified income source columns are updated to
  zero when the main income source is skipped, undefined, or none.
