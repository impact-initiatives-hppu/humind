# Calculate Food Security Sectoral Composite Score and Need Indicators

This function calculates a food security sectoral composite score based
on the FCLCM phase. It assigns a score from 1 to 5 corresponding to the
FCLCM phase, and determines if a household is in need or in severe need
of food security assistance.

Prerequisite food security functions must be run before this function:

- [`add_fcs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcs.md)

- [`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md)

- [`add_rcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_rcsi.md)

- [`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md)

- [`add_fclcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fclcm_phase.md)

## Usage

``` r
add_comp_foodsec(
  df,
  fclcm_phase = "fclcm_phase",
  phase1 = "Phase 1 FCLC",
  phase2 = "Phase 2 FCLC",
  phase3 = "Phase 3 FCLC",
  phase4 = "Phase 4 FCLC",
  phase5 = "Phase 5 FCLC"
)
```

## Arguments

- df:

  A data frame.

- fclcm_phase:

  Column name for the FCLCM phase.

- phase1:

  Label for Phase 1 FCLC.

- phase2:

  Label for Phase 2 FCLC.

- phase3:

  Label for Phase 3 FCLC.

- phase4:

  Label for Phase 4 FCLC.

- phase5:

  Label for Phase 5 FCLC.

## Value

A data frame with additional columns:

- comp_foodsec_score: Food security composite score (1-5)

- comp_foodsec_in_need: Binary indicator for being in need of food
  security assistance

- comp_foodsec_in_severe_need: Binary indicator for being in severe need
  of food security assistance
