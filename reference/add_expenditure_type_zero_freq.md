# Add Zero for Skipped Frequent Expenditure Types

This function adds zero values to frequent expenditure types that were
skipped in the survey. Frequent expenditures are defined as those with a
30-day recall period. The function also ensures that when no expenditure
is reported, all expenditure types are set to zero.

## Usage

``` r
add_expenditure_type_zero_freq(
  df,
  expenditure_freq = "cm_expenditure_frequent",
  none = "none",
  undefined = c("dnk", "pnta"),
  expenditure_freq_types = c("cm_expenditure_frequent_food",
    "cm_expenditure_frequent_rent", "cm_expenditure_frequent_water",
    "cm_expenditure_frequent_nfi", "cm_expenditure_frequent_utilities",
    "cm_expenditure_frequent_fuel", "cm_expenditure_frequent_transportation",
    "cm_expenditure_frequent_communication", "cm_expenditure_frequent_other")
)
```

## Arguments

- df:

  A data frame containing expenditure data.

- expenditure_freq:

  A character string. The name of the column that contains the frequent
  expenditures.

- none:

  The value for no expenditure.

- undefined:

  A character vector. The values that indicate that the frequent
  expenditures type was skipped.

- expenditure_freq_types:

  A character vector. The names of the columns that contain the amount
  of frequent expenditures types.

## Value

A data frame with updated expenditure columns: columns specified in
expenditure_freq_types are updated with zeros for skipped entries.
