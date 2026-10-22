# Add Water Expenditure Share of Income

Calculates the share of frequent water expenditure relative to total
household income and flags households spending 5% or more of income on
water (catastrophic water spending).

This is a convenience wrapper around
[`add_expenditure_type_share_income()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_type_share_income.md)
with fixed parameters for the water expenditure module: both expenditure
and income recall periods are 30 days, and the catastrophic threshold is
0.05 (5%).

Prerequisite: run
[`add_expenditure_type_zero_freq()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_type_zero_freq.md)
before calling this function. `cm_income_total` must also be present in
`df`, either directly from the survey or via
[`add_income_source_prop()`](https://impact-initiatives-hppu.github.io/humind/reference/add_income_source_prop.md).

## Usage

``` r
add_expenditure_water_share_income(
  df,
  expenditure_type = "cm_expenditure_frequent_water",
  total_income = "cm_income_total"
)
```

## Arguments

- df:

  A data frame.

- expenditure_type:

  Column name for frequent water expenditure amount.

- total_income:

  Column name for total household income.

## Value

A data frame with two additional columns:

- `cm_expenditure_frequent_water_share_income`: Water expenditure share
  of income; `1` for zero-income households with water expenditure above
  `0`; `NA` if income or expenditure is `NA`.

- `cm_expenditure_frequent_water_share_income_d`: `1L` if catastrophic
  (share \>= 0.05), `0L` if not (or for a zero-income household with
  zero water expenditure), `NA_integer_` if income or share is `NA`.

## See also

Other expenditure_share_income:
[`add_expenditure_healthcare_share_income()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_healthcare_share_income.md),
[`add_expenditure_type_share_income()`](https://impact-initiatives-hppu.github.io/humind/reference/add_expenditure_type_share_income.md)

## Examples

``` r
df <- data.frame(
  cm_expenditure_frequent_water = c(4, 5, 10),
  cm_income_total = c(100, 100, 200)
)
add_expenditure_water_share_income(df)
#>   cm_expenditure_frequent_water cm_income_total
#> 1                             4             100
#> 2                             5             100
#> 3                            10             200
#>   cm_expenditure_frequent_water_share_income
#> 1                                       0.04
#> 2                                       0.05
#> 3                                       0.05
#>   cm_expenditure_frequent_water_share_income_d
#> 1                                            0
#> 2                                            1
#> 3                                            1
```
