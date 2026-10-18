# Add Indicator for Access to Health Facility in Less Than One Hour

Adds a binary variable (`1L`/`0L`) for whether a household reports
access to the nearest functional health facility in less than one hour
on foot.

Values must be strictly positive integers. The `health_facility_time`
column is validated with
[`checkmate::assert_integerish()`](https://mllg.github.io/checkmate/reference/checkIntegerish.html):
`0`, negative codes (including `-999`), fractional values, and
non-finite values all raise an error — recode or remove them before
calling this function.

## Usage

``` r
add_health_facility_less_1h(df, health_facility_time = "health_facility_time")
```

## Arguments

- df:

  A data frame.

- health_facility_time:

  Column name for travel time (in minutes) to the nearest functional
  health facility.

## Value

A data frame with one additional column:

- `health_facility_less_1h`: `1L` if travel time is strictly less than
  60 minutes, `0L` if 60 minutes or more, `NA_integer_` for missing
  values.

## Examples

``` r
input_data <- data.frame(
  health_facility_time = c(15L, 45L, 60L, 90L, NA_integer_)
)
add_health_facility_less_1h(input_data)
#>   health_facility_time health_facility_less_1h
#> 1                   15                       1
#> 2                   45                       1
#> 3                   60                       0
#> 4                   90                       0
#> 5                   NA                      NA
```
