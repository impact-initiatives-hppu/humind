# Add Expenditure Type Share of Income and Catastrophic Spending Flag

Calculates the share of a single expenditure type relative to total
income normalising both to the same recall period before computing the
ratio, and flags households where that share meets or exceeds the
catastrophic threshold.

The share is computed as:
`(expenditure * income_recall_period) / (income * expenditure_recall_period)`

Prerequisite: `cm_income_total` (or the column supplied to
`income_total`) must already be present in `df`, either from the survey
directly or from
[`add_income_source_prop()`](https://impact-initiatives-hppu.github.io/humind/reference/add_income_source_prop.md).

## Usage

``` r
add_expenditure_type_share_income(
  df,
  expenditure_type,
  income_total = "cm_income_total",
  expenditure_recall_period = 30,
  income_recall_period = 30,
  catastrophic_threshold = 0.25
)
```

## Arguments

- df:

  A data frame.

- expenditure_type:

  Column name for the expenditure amount.

- income_total:

  Column name for the total household income.

- expenditure_recall_period:

  Recall period of the expenditure column in days. Default: `30`.

- income_recall_period:

  Recall period of the income column in days. Default: `30`.

- catastrophic_threshold:

  Numeric threshold above which spending is considered catastrophic
  (proportion, e.g. `0.25` for 25%). Default: `0.25`.

## Value

A data frame with two additional columns (names derived from
`expenditure_type`):

- `{expenditure_type}_share_income`: Recall-normalised share of
  expenditure relative to income; `1` for zero-income households with
  expenditure above `0`; `NA` if income or expenditure is `NA`.

- `{expenditure_type}_share_income_d`: `1L` if share \>=
  `catastrophic_threshold`, `0L` if share is below the threshold or for
  a zero-income household with zero expenditure, `NA_integer_` if income
  or share is `NA`.

## See also

Other expenditure_share_income:
[`add_expenditure_healthcare_share_income()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_healthcare_share_income.md),
[`add_expenditure_water_share_income()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_water_share_income.md)

## Examples

``` r
df <- data.frame(
  cm_expenditure_infrequent_health = c(60, 0, 30),
  cm_income_total = c(100, 200, 0)
)
add_expenditure_type_share_income(
  df,
  expenditure_type = "cm_expenditure_infrequent_health",
  income_total = "cm_income_total",
  expenditure_recall_period = 180,
  income_recall_period = 30,
  catastrophic_threshold = 0.25
)
#>   cm_expenditure_infrequent_health cm_income_total
#> 1                               60             100
#> 2                                0             200
#> 3                               30               0
#>   cm_expenditure_infrequent_health_share_income
#> 1                                           0.1
#> 2                                           0.0
#> 3                                           1.0
#>   cm_expenditure_infrequent_health_share_income_d
#> 1                                               0
#> 2                                               0
#> 3                                               1
```
