# Sum Columns Row-wise

This function sums up specified columns row-wise in a dataframe, with
options for imputation of missing values and weighted calculations.

## Usage

``` r
sum_vars(
  df,
  vars,
  new_colname,
  imputation = "none",
  na_rm = FALSE,
  weight = "weight",
  value = 0,
  group = NULL
)
```

## Arguments

- df:

  A dataframe containing the columns to be summed.

- vars:

  A character vector of the columns to sum.

- new_colname:

  A character vector of the new column name.

- imputation:

  The imputation method, either none (default), value, median or
  weighted median.

- na_rm:

  A boolean indicating whether to remove missing values when summing
  across columns.

- weight:

  The weight variable to calculate weighted means or medians.

- value:

  The value to replace missing values with if imputation is "value".

- group:

  A character vector of the grouping variables.

## Value

A dataframe with an additional column:

- new_colname: the sum of the specified variables, with imputation
  applied if specified.
