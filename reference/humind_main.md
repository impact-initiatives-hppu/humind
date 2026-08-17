# Dummy MSNA household (main) data

Dummy household-level data modeled on the 2026 MSNA guidance, used to
illustrate the `humind` sector-by-sector MSNI pipeline in
[`vignette("msni-workflow")`](https://impact-initiatives-hppu.github.io/humind/articles/msni-workflow.md).

## Usage

``` r
humind_main
```

## Format

A data frame with 5,408 rows and 148 variables, grouped by sector and
prefix:

- `_uuid`: household unique identifier; join key for
  [humind_health_ind](https://impact-initiatives-hppu.github.io/humind/reference/humind_health_ind.md)
  and
  [humind_edu_ind](https://impact-initiatives-hppu.github.io/humind/reference/humind_edu_ind.md)
  (via `_submission__uuid`).

- `fsl_*`: food security items (FCS, HHS, rCSI, LCSI incl.
  `_host`/`_camp` variants) – see
  [`add_fcs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcs.md),
  [`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md),
  [`add_rcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_rcsi.md),
  [`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md).

- `wash_*`: WASH items (HWISE, drinking water, sanitation, handwashing)
  – see
  [`add_hwise()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hwise.md),
  [`add_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md).

- `snfi_*`, `hlp_*`: shelter, damage, occupancy – see
  [`add_shelter_type_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_shelter_type_cat.md),
  [`add_occupancy_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_occupancy_cat.md).

- `prot_needs_*`: protection movement/practices/rights items – see
  [`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md).

- `admin1`: geography, for context only; unused by any `add_*()`.

## Source

Dummy data modeled on the 2026 MSNA guidance, for demonstration purposes
only.
