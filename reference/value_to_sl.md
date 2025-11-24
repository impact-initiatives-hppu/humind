# Add a specific value to variables that were skipped

Add a specific value to variables that were skipped

## Usage

``` r
value_to_sl(df, var, undefined = NULL, sl_vars, sl_value, suffix = "")
```

## Arguments

- df:

  A data frame.

- var:

  The name of the variable that is used for the skip logic.

- undefined:

  A character vector of values that are considered as "undefined" and
  should not be replaced in follow-up variables.

- sl_vars:

  A character vector of variable names which were skipped and should be
  replaced with a value.

- sl_value:

  The value that should be added to the skipped variables.

- suffix:

  A suffix to add to the new variable names. Default to no suffix (empty
  string).
