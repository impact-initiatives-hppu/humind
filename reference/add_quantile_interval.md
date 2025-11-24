# Add Quantile Intervals to Income Variable

This function calculates weighted income quantiles and classifies
households according to these. It can handle multiple income variables
and applies weighted or unweighted quantiles based on the input.

## Usage

``` r
add_quantile_interval(
  df,
  vars,
  cut_offs = c(0, 0.2, 0.4, 0.6, 0.8, 1),
  weight = NULL
)
```

## Arguments

- df:

  A dataframe containing the income variables.

- vars:

  The variable or variables with income integer values.

- cut_offs:

  The cut-offs for computation of quantiles. The default corresponds to
  the quantiles of the distribution, based on the weighted median.

- weight:

  The sampling weights column name. If NULL, unweighted quantiles are
  calculated.

## Value

A dataframe with additional columns:

- \*\_qtl: For each input variable, a new column is added with the
  quantile interval classification. The naming format is
  'original_variable_name'\_qtl.
