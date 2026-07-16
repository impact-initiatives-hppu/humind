# Add Protection Sectoral Composite Score and Need Indicators

This function calculates a protection sectoral composite score based on
the movement, practices, and rights & services dimension scores. It
takes the maximum of the three dimension scores as the overall
protection severity, and determines if a household is in need or in
severe need of protection assistance based on the calculated score.

Prerequisite functions:

- [`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md)

- [`add_prot_score_practices()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_practices.md)

- [`add_prot_score_rights()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_rights.md)

## Usage

``` r
add_comp_prot(df)
```

## Arguments

- df:

  A data frame containing the movement, practices, and rights & services
  dimension scores.

## Value

A data frame with additional columns:

- comp_prot_score: Protection composite score (maximum of the three
  dimension scores)

- comp_prot_in_need: Binary indicator for being in need of protection
  assistance

- comp_prot_in_severe_need: Binary indicator for being in severe need of
  protection assistance
