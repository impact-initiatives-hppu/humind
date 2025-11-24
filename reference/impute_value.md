# Impute Missing Values

This set of functions replaces missing values in specified variables.

- `impute_value()` replaces all missing values with a specific value,
  while

- `impute_median()` replaces missing values with the (weighted) median
  of the variable.

## Usage

``` r
impute_value(df, vars, value)

impute_median(df, vars, group = NULL, weighted = FALSE, weight = NULL)
```

## Arguments

- df:

  A dataframe containing the variables to be imputed.

- vars:

  A character vector of the variables to replace NA with.

- value:

  The value to replace NA with.

- group:

  A character vector of the grouping variables.

- weighted:

  A boolean indicating whether to use the weighted median or not.

- weight:

  The weight variable.

## Value

A dataframe with imputed values:

- vars: The specified variables with missing values replaced.

A dataframe with imputed values:

- vars: The specified variables with missing values replaced by their
  respective (weighted) medians.
