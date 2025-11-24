# Rank Top 3 Variables

This function ranks the top 3 numeric variables for each row in a data
frame. In case of equality, it takes precedence in the order of 'vars'
as factors.

## Usage

``` r
rank_top3_vars(
  df,
  vars,
  new_colname_top1,
  new_colname_top2,
  new_colname_top3,
  id_col = "uuid"
)
```

## Arguments

- df:

  A data frame containing the variables to be ranked.

- vars:

  A character vector of numeric variable names to be ranked.

- new_colname_top1:

  The new column name for the top variable.

- new_colname_top2:

  The new column name for the 2nd top variable.

- new_colname_top3:

  The new column name for the 3rd top variable.

- id_col:

  The column name for the unique identifier.

## Value

A data frame with additional columns:

- new_colname_top1: The name of the top-ranked variable for each row.

- new_colname_top2: The name of the second-ranked variable for each row.

- new_colname_top3: The name of the third-ranked variable for each row.
