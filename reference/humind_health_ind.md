# Dummy MSNA health loop data

Dummy individual-level health data modeled on the 2026 MSNA guidance,
used to illustrate the `humind` sector-by-sector MSNI pipeline in
[`vignette("msni-workflow")`](https://impact-initiatives-hppu.github.io/humind/articles/msni-workflow.md).

## Usage

``` r
humind_health_ind
```

## Format

A data frame with 30,300 rows and 3 variables:

- \_submission\_\_uuid:

  Join key back to
  [humind_main](https://impact-initiatives-hppu.github.io/humind/reference/humind_main.md)'s
  `_uuid`.

- health_ind_healthcare_needed:

  Whether the individual needed healthcare.

- health_ind_healthcare_received:

  Whether the individual received the healthcare they needed.

## Source

Dummy data modeled on the 2026 MSNA guidance, for demonstration purposes
only.
