# Add Physical Water Access Issue Indicator

Computes a binary variable
(`wash_water_access_issue_physical_infrastructure_d`) that is `1L` if
the household reported any physical or infrastructure-related barrier to
accessing water points (too far, difficult to use, disability-related
barriers, safety concerns, excessive waiting time, not segregated by
gender, some groups lacking access, an out-of-service source,
intermittent/infrequent service, closed water points, or not enough
containers), `0L` if none were reported, and `NA` if the response was
ambiguous (dnk/pnta/other) or any component is missing.

Computes a binary variable
(`wash_water_access_issue_financial_market_d`) that is `1L` if the
household reported any financial or market-related barrier to accessing
water (water not available at the market, or too expensive), `0L` if
none were reported, and `NA` if the response was ambiguous
(dnk/pnta/other) or any component is missing.

## Usage

``` r
add_water_access_issue_physical(
  df,
  water_access_issue = "wash_water_access_issue",
  physical = c("waterpoints_too_far", "waterpoints_difficult_use",
    "disability_no_access_waterpoints", "safety_concerns_waterpoints",
    "safety_concerns_travel_waterpoints", "excessive_waiting_time_waterpoints",
    "water_source_not_segregated_gender", "groups_no_access_waterpoints",
    "water_source_not_functional", "intermittent_infrequent_service",
    "waterpoints_not_functioning_closed", "not_enough_containers"),
  undefined = c("dnk", "pnta", "other"),
  sep = "/"
)

add_water_access_issue_financial(
  df,
  water_access_issue = "wash_water_access_issue",
  financial = c("water_not_available_market", "water_too_expensive"),
  undefined = c("dnk", "pnta", "other"),
  sep = "/"
)
```

## Arguments

- df:

  A data frame.

- water_access_issue:

  Base name of the select_multiple variable.

- physical:

  Character vector of responses that indicate physical or
  infrastructure-related access barriers.

- undefined:

  Character vector of undefined responses (dnk, pnta, other).

- sep:

  Separator between the base name and response code in binary column
  names.

- financial:

  Character vector of responses that indicate financial or
  market-related access barriers.

## Value

A data frame with one additional column:

- `wash_water_access_issue_physical_infrastructure_d`: `1L` if any
  physical or infrastructure-related barrier is reported; `0L` if none;
  `NA` if the response is undefined or any component is missing.

A data frame with one additional column:

- `wash_water_access_issue_financial_market_d`: `1L` if any financial or
  market-related barrier is reported; `0L` if none; `NA` if the response
  is undefined or any component is missing.

## ANA indicator

Metric IDs `MET099` (physical/infrastructure; legacy indicator ID
`IND097`) and `MET100` (financial/market; legacy indicator ID `IND098`).

## Examples

``` r
df <- data.frame(
  wash_water_access_issue = c(
    "waterpoints_too_far", "no_problem_access_water", "dnk"
  ),
  `wash_water_access_issue/waterpoints_too_far` = c(1L, 0L, 0L),
  `wash_water_access_issue/waterpoints_difficult_use` = c(0L, 0L, 0L),
  `wash_water_access_issue/disability_no_access_waterpoints` = c(0L, 0L, 0L),
  `wash_water_access_issue/safety_concerns_waterpoints` = c(0L, 0L, 0L),
  `wash_water_access_issue/safety_concerns_travel_waterpoints` = c(0L, 0L, 0L),
  `wash_water_access_issue/excessive_waiting_time_waterpoints` = c(0L, 0L, 0L),
  `wash_water_access_issue/water_source_not_segregated_gender` = c(0L, 0L, 0L),
  `wash_water_access_issue/groups_no_access_waterpoints` = c(0L, 0L, 0L),
  `wash_water_access_issue/water_source_not_functional` = c(0L, 0L, 0L),
  `wash_water_access_issue/intermittent_infrequent_service` = c(0L, 0L, 0L),
  `wash_water_access_issue/waterpoints_not_functioning_closed` = c(0L, 0L, 0L),
  `wash_water_access_issue/not_enough_containers` = c(0L, 0L, 0L),
  `wash_water_access_issue/dnk` = c(0L, 0L, 1L),
  `wash_water_access_issue/pnta` = c(0L, 0L, 0L),
  `wash_water_access_issue/other` = c(0L, 0L, 0L),
  check.names = FALSE
)
add_water_access_issue_physical(df)
#>   wash_water_access_issue wash_water_access_issue/waterpoints_too_far
#> 1     waterpoints_too_far                                           1
#> 2 no_problem_access_water                                           0
#> 3                     dnk                                           0
#>   wash_water_access_issue/waterpoints_difficult_use
#> 1                                                 0
#> 2                                                 0
#> 3                                                 0
#>   wash_water_access_issue/disability_no_access_waterpoints
#> 1                                                        0
#> 2                                                        0
#> 3                                                        0
#>   wash_water_access_issue/safety_concerns_waterpoints
#> 1                                                   0
#> 2                                                   0
#> 3                                                   0
#>   wash_water_access_issue/safety_concerns_travel_waterpoints
#> 1                                                          0
#> 2                                                          0
#> 3                                                          0
#>   wash_water_access_issue/excessive_waiting_time_waterpoints
#> 1                                                          0
#> 2                                                          0
#> 3                                                          0
#>   wash_water_access_issue/water_source_not_segregated_gender
#> 1                                                          0
#> 2                                                          0
#> 3                                                          0
#>   wash_water_access_issue/groups_no_access_waterpoints
#> 1                                                    0
#> 2                                                    0
#> 3                                                    0
#>   wash_water_access_issue/water_source_not_functional
#> 1                                                   0
#> 2                                                   0
#> 3                                                   0
#>   wash_water_access_issue/intermittent_infrequent_service
#> 1                                                       0
#> 2                                                       0
#> 3                                                       0
#>   wash_water_access_issue/waterpoints_not_functioning_closed
#> 1                                                          0
#> 2                                                          0
#> 3                                                          0
#>   wash_water_access_issue/not_enough_containers wash_water_access_issue/dnk
#> 1                                             0                           0
#> 2                                             0                           0
#> 3                                             0                           1
#>   wash_water_access_issue/pnta wash_water_access_issue/other
#> 1                            0                             0
#> 2                            0                             0
#> 3                            0                             0
#>   wash_water_access_issue_physical_infrastructure_d
#> 1                                                 1
#> 2                                                 0
#> 3                                                NA
df <- data.frame(
  wash_water_access_issue = c(
    "water_too_expensive", "no_problem_access_water", "dnk"
  ),
  `wash_water_access_issue/water_not_available_market` = c(0L, 0L, 0L),
  `wash_water_access_issue/water_too_expensive` = c(1L, 0L, 0L),
  `wash_water_access_issue/dnk` = c(0L, 0L, 1L),
  `wash_water_access_issue/pnta` = c(0L, 0L, 0L),
  `wash_water_access_issue/other` = c(0L, 0L, 0L),
  check.names = FALSE
)
add_water_access_issue_financial(df)
#>   wash_water_access_issue wash_water_access_issue/water_not_available_market
#> 1     water_too_expensive                                                  0
#> 2 no_problem_access_water                                                  0
#> 3                     dnk                                                  0
#>   wash_water_access_issue/water_too_expensive wash_water_access_issue/dnk
#> 1                                           1                           0
#> 2                                           0                           0
#> 3                                           0                           1
#>   wash_water_access_issue/pnta wash_water_access_issue/other
#> 1                            0                             0
#> 2                            0                             0
#> 3                            0                             0
#>   wash_water_access_issue_financial_market_d
#> 1                                          1
#> 2                                          0
#> 3                                         NA
```
