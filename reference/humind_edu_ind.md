# Dummy demo MSNA education loop data

Dummy individual-level education data modeled on the 2026 MSNA guidance,
used to illustrate the `humind` sector-by-sector MSNI pipeline in
[`vignette("msni-workflow")`](https://impact-initiatives-hppu.github.io/humind/articles/msni-workflow.md).

## Usage

``` r
humind_edu_ind
```

## Format

A data frame with 26,630 rows and 8 variables:

- \_submission\_\_uuid:

  Join key back to
  [humind_main](https://impact-initiatives-hppu.github.io/humind/reference/humind_main.md)'s
  `_uuid`.

- edu_ind_age:

  Individual's age, in years.

- edu_access:

  Whether the individual is currently attending education.

- edu_barrier:

  Barriers to education access.

- edu_disrupted_attack, edu_disrupted_hazards, edu_disrupted_displaced,
  edu_disrupted_teacher:

  Reasons education was disrupted.

## Source

Dummy data modeled on the 2026 MSNA guidance, for demonstration purposes
only.
