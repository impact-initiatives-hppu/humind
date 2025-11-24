# Create Dummy Variables and Count Across if Above Zero

This function creates dummy variables for each input column, setting 1
if the value is above zero, 0 if it's zero, and NA if it's below zero.
It then sums these dummy variables to create a count.

## Usage

``` r
count_if_above_zero(df, vars, new_colname)
```

## Arguments

- df:

  A data frame containing the columns to be processed.

- vars:

  Vector of column names to be processed.

- new_colname:

  The name of the new column that will contain the count.

## Value

A data frame with additional columns:

- "\*\_d": Dummy variables for each input column, where 'star' is the
  original column name.

- new_colname: A new column containing the count of values above zero
  across the specified variables.
