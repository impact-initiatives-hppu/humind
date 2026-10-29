# Add Physical/Safety Sanitation Access Issue

Computes a binary variable
(`wash_sanitation_access_issue_physical_safety_d`) that is 1 if the
household reported any physical or safety-related challenge in accessing
sanitation facilities (not private, too far, difficult to reach,
dangerous, disability-related, not segregated by gender, or some groups
excluded), 0 if none were reported, and NA if the response was ambiguous
(dnk/pnta/other). The sanitation facility type is not used: households
reporting no facility are classified from their access-issue responses
like any other household.

Computes a binary variable
(`wash_sanitation_access_issue_hygiene_functionality_d`) that is 1 if
the household reported any hygiene or functionality challenge in
accessing sanitation facilities (too crowded, not functioning/full,
unclean/unhygienic), 0 if none were reported, and NA if the response was
ambiguous (dnk/pnta/other). The sanitation facility type is not used:
households reporting no facility are classified from their access-issue
responses like any other household.

## Usage

``` r
add_sanitation_access_issue_physical_safety(
  df,
  sanitation_access_issue = "wash_sanitation_access_issue",
  physical_safety = c("sanitation_not_private", "sanitation_too_far",
    "sanitation_difficult_access", "sanitation_dangerous_access",
    "disabilities_no_access_sanitation", "sanitation_not_segregated_gender",
    "groups_no_access_sanitation"),
  undefined = c("dnk", "pnta", "other"),
  sanitation_facility = "wash_sanitation_facility",
  none = "none",
  sep = "/"
)

add_sanitation_access_issue_hygiene_functionality(
  df,
  sanitation_access_issue = "wash_sanitation_access_issue",
  hygiene_functionality = c("lack_sanitation_facilities_crowded",
    "sanitation_not_functioning_full", "sanitation_unclean_unhygienic"),
  undefined = c("dnk", "pnta", "other"),
  sanitation_facility = "wash_sanitation_facility",
  none = "none",
  sep = "/"
)
```

## Arguments

- df:

  A data frame.

- sanitation_access_issue:

  Base name of the select_multiple variable.

- physical_safety:

  Character vector of responses that indicate physical or safety-related
  access challenges.

- undefined:

  Character vector of undefined responses (dnk, pnta, other).

- sanitation_facility:

  Column name for the sanitation facility type. Kept for completeness;
  not used to determine the output.

- none:

  Response code for no sanitation facility (open defecation). Kept for
  completeness; not used to determine the output.

- sep:

  Separator for the binary columns.

- hygiene_functionality:

  Character vector of responses that indicate hygiene or functionality
  access challenges.

## Value

A data frame with one additional column:

- wash_sanitation_access_issue_physical_safety_d which takes 1L if any
  physical/safety challenge is reported; 0L if no physical/safety
  challenge is reported; NA if the response is undefined.

A data frame with one additional column:

- wash_sanitation_access_issue_hygiene_functionality_d which takes 1L if
  any hygiene/functionality challenge is reported; 0L if no
  hygiene/functionality challenge is reported; NA if the response is
  undefined.

## ANA indicator

Metric IDs `MET139` (physical/safety) and `MET140`
(hygiene/functionality).

## Examples

``` r
df <- data.frame(
  wash_sanitation_facility = "pit_latrine_slab",
  wash_sanitation_access_issue = c(
    "sanitation_too_far", "no_problem", "dnk"
  ),
  `wash_sanitation_access_issue/sanitation_not_private` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/sanitation_too_far` = c(1L, 0L, 0L),
  `wash_sanitation_access_issue/sanitation_difficult_access` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/sanitation_dangerous_access` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/disabilities_no_access_sanitation` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/sanitation_not_segregated_gender` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/groups_no_access_sanitation` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/dnk` = c(0L, 0L, 1L),
  `wash_sanitation_access_issue/pnta` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/other` = c(0L, 0L, 0L),
  check.names = FALSE
)
add_sanitation_access_issue_physical_safety(df)
#>   wash_sanitation_facility wash_sanitation_access_issue
#> 1         pit_latrine_slab           sanitation_too_far
#> 2         pit_latrine_slab                   no_problem
#> 3         pit_latrine_slab                          dnk
#>   wash_sanitation_access_issue/sanitation_not_private
#> 1                                                   0
#> 2                                                   0
#> 3                                                   0
#>   wash_sanitation_access_issue/sanitation_too_far
#> 1                                               1
#> 2                                               0
#> 3                                               0
#>   wash_sanitation_access_issue/sanitation_difficult_access
#> 1                                                        0
#> 2                                                        0
#> 3                                                        0
#>   wash_sanitation_access_issue/sanitation_dangerous_access
#> 1                                                        0
#> 2                                                        0
#> 3                                                        0
#>   wash_sanitation_access_issue/disabilities_no_access_sanitation
#> 1                                                              0
#> 2                                                              0
#> 3                                                              0
#>   wash_sanitation_access_issue/sanitation_not_segregated_gender
#> 1                                                             0
#> 2                                                             0
#> 3                                                             0
#>   wash_sanitation_access_issue/groups_no_access_sanitation
#> 1                                                        0
#> 2                                                        0
#> 3                                                        0
#>   wash_sanitation_access_issue/dnk wash_sanitation_access_issue/pnta
#> 1                                0                                 0
#> 2                                0                                 0
#> 3                                1                                 0
#>   wash_sanitation_access_issue/other
#> 1                                  0
#> 2                                  0
#> 3                                  0
#>   wash_sanitation_access_issue_physical_safety_d
#> 1                                              1
#> 2                                              0
#> 3                                             NA
df <- data.frame(
  wash_sanitation_facility = "pit_latrine_slab",
  wash_sanitation_access_issue = c(
    "sanitation_unclean_unhygienic", "no_problem", "dnk"
  ),
  `wash_sanitation_access_issue/lack_sanitation_facilities_crowded` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/sanitation_not_functioning_full` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/sanitation_unclean_unhygienic` = c(1L, 0L, 0L),
  `wash_sanitation_access_issue/dnk` = c(0L, 0L, 1L),
  `wash_sanitation_access_issue/pnta` = c(0L, 0L, 0L),
  `wash_sanitation_access_issue/other` = c(0L, 0L, 0L),
  check.names = FALSE
)
add_sanitation_access_issue_hygiene_functionality(df)
#>   wash_sanitation_facility  wash_sanitation_access_issue
#> 1         pit_latrine_slab sanitation_unclean_unhygienic
#> 2         pit_latrine_slab                    no_problem
#> 3         pit_latrine_slab                           dnk
#>   wash_sanitation_access_issue/lack_sanitation_facilities_crowded
#> 1                                                               0
#> 2                                                               0
#> 3                                                               0
#>   wash_sanitation_access_issue/sanitation_not_functioning_full
#> 1                                                            0
#> 2                                                            0
#> 3                                                            0
#>   wash_sanitation_access_issue/sanitation_unclean_unhygienic
#> 1                                                          1
#> 2                                                          0
#> 3                                                          0
#>   wash_sanitation_access_issue/dnk wash_sanitation_access_issue/pnta
#> 1                                0                                 0
#> 2                                0                                 0
#> 3                                1                                 0
#>   wash_sanitation_access_issue/other
#> 1                                  0
#> 2                                  0
#> 3                                  0
#>   wash_sanitation_access_issue_hygiene_functionality_d
#> 1                                                    1
#> 2                                                    0
#> 3                                                   NA
```
