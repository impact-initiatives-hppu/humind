# Add Zero for Skipped Infrequent Expenditure Types

This function adds zero values to infrequent expenditure types that were
skipped in the survey. Infrequent expenditures are defined as those with
a 6-month recall period. The function also ensures that when no
expenditure is reported, all expenditure types are set to zero.

## Usage

``` r
add_expenditure_type_zero_infreq(
  df,
  expenditure_infreq = "cm_expenditure_frequent",
  none = "none",
  undefined = c("dnk", "pnta"),
  expenditure_infreq_types = c("cm_expenditure_infrequent_shelter",
    "cm_expenditure_infrequent_nfi", "cm_expenditure_infrequent_health",
    "cm_expenditure_infrequent_education", "cm_expenditure_infrequent_debt",
    "cm_expenditure_infrequent_clothing", "cm_expenditure_infrequent_other")
)
```

## Arguments

- df:

  A data frame containing expenditure data.

- expenditure_infreq:

  A character string. The name of the column that contains the
  infrequent expenditures.

- none:

  The value for no expenditure.

- undefined:

  A character vector. The values that indicate that the infrequent
  expenditures type was skipped.

- expenditure_infreq_types:

  A character vector. The names of the columns that contain the amount
  of infrequent expenditures types.

## Value

A data frame with updated expenditure columns: columns specified in
expenditure_infreq_types are updated with zeros for skipped entries.
