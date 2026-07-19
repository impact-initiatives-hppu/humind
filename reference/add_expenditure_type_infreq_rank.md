# Rank Top 3 Infrequent Expenditure Types

This function ranks the top 3 most infrequent expenditure types for each
household based on the amount spent on various categories. It adds new
columns to the input data frame indicating the top 3 infrequent
expenditure types.

Prerequisite function:

- add_expenditure_type_zero_infreq.R

## Usage

``` r
add_expenditure_type_infreq_rank(
  df,
  expenditure_infreq_types = c("cm_expenditure_infrequent_shelter",
    "cm_expenditure_infrequent_nfi", "cm_expenditure_infrequent_health",
    "cm_expenditure_infrequent_education", "cm_expenditure_infrequent_debt",
    "cm_expenditure_infrequent_clothing", "cm_expenditure_infrequent_other"),
  id_col = "uuid"
)
```

## Arguments

- df:

  A data frame containing infrequent expenditure data for households.

- expenditure_infreq_types:

  A character vector. The names of the columns that contain the amount
  of infrequent expenditures types.

- id_col:

  The name of the column that contains the unique identifier.

## Value

A data frame with additional columns:

- cm_infreq_expenditure_top1: The most infrequent expenditure type.

- cm_infreq_expenditure_top2: The second most infrequent expenditure
  type.

- cm_infreq_expenditure_top3: The third most infrequent expenditure
  type.

## Details

Rank Top 3 Infrequent Expenditure Types
