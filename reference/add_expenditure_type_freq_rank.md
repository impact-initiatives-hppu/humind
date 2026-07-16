# Rank Top 3 Frequent Expenditure Types

This function ranks the top 3 most frequent expenditure types for each
household based on the amount spent on various categories. It adds new
columns to the input data frame indicating the top 3 expenditure types.

Prerequisite function:

- add_expenditure_type_zero_freq.R

## Usage

``` r
add_expenditure_type_freq_rank(
  df,
  expenditure_freq_types = c("cm_expenditure_frequent_food",
    "cm_expenditure_frequent_rent", "cm_expenditure_frequent_water",
    "cm_expenditure_frequent_nfi", "cm_expenditure_frequent_utilities",
    "cm_expenditure_frequent_fuel", "cm_expenditure_frequent_transportation",
    "cm_expenditure_frequent_communication", "cm_expenditure_frequent_other"),
  id_col = "uuid"
)
```

## Arguments

- df:

  A data frame containing expenditure data for households.

- expenditure_freq_types:

  A character vector. The names of the columns that contain the amount
  of frequent expenditures types.

- id_col:

  The name of the column that contains the unique identifier.

## Value

A data frame with additional columns:

- cm_freq_expenditure_top1: The most frequent expenditure type.

- cm_freq_expenditure_top2: The second most frequent expenditure type.

- cm_freq_expenditure_top3: The third most frequent expenditure type.
