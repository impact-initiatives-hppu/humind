# Add Healthcare Expenditure Share of Income

Calculates the share of infrequent healthcare expenditure relative to
total household income, normalising both to the same recall period, and
flags households with catastrophic health care spending.

This is a convenience wrapper around
[`add_expenditure_type_share_income()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_type_share_income.md)
with fixed parameters for the health expenditure module: expenditure
recall period is 180 days (6 months), income recall period is 30 days,
and the catastrophic threshold is 0.25 (25%).

Prerequisite: run
[`add_expenditure_type_zero_infreq()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_type_zero_infreq.md)
before calling this function. `cm_income_total` must also be present in
`df`, either directly from the survey or via
[`add_income_source_prop()`](https://impact-initiatives-hppu.github.io/humind/reference/add_income_source_prop.md).

## Usage

``` r
add_expenditure_healthcare_share_income(
  df,
  expenditure_type = "cm_expenditure_infrequent_health",
  total_income = "cm_income_total"
)
```

## Arguments

- df:

  A data frame.

- expenditure_type:

  Column name for infrequent health expenditure amount.

- total_income:

  Column name for total household income.

## Value

A data frame with two additional columns:

- `cm_expenditure_infrequent_health_share_income`: Recall-normalised
  health expenditure share of income; `1` for zero-income households
  with health expenditure above `0`; `NA` if income or expenditure is
  `NA`.

- `cm_expenditure_infrequent_health_share_income_d`: `1L` if
  catastrophic (share \>= 0.25), `0L` if not (or for a zero-income
  household with zero health expenditure), `NA_integer_` if income or
  share is `NA`.

## ANA indicator

Metric ID `MET169` (legacy indicator ID `IND176`).

## See also

Other expenditure_share_income:
[`add_expenditure_type_share_income()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_type_share_income.md),
[`add_expenditure_water_share_income()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_water_share_income.md)

## Examples

``` r
df <- data.frame(
  cm_expenditure_infrequent_health = c(60, 0, 30),
  cm_income_total = c(100, 200, 0)
)
add_expenditure_healthcare_share_income(df)
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
