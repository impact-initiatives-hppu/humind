# Add overall Protection composite score and need flags

Assumes that per‑dimension severity scores have already been computed
and added to `df` by earlier functions:
[`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md),
[`add_prot_score_practices()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_practices.md),
and
[`add_prot_score_rights()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_rights.md).
This function performs only **Step 4** of the 2025 Protection Composite
workflow: it takes the maximum of those three existing columns to create
`comp_prot_score`, then generates binary “in need” indicators.

## Usage

``` r
add_comp_prot(df)
```

## Arguments

- df:

  A `data.frame` or `tibble` containing numeric columns:

  - `comp_prot_score_movement` – severity for movement dimension

  - `comp_prot_score_practices` – severity for practices dimension

  - `comp_prot_score_rights` – severity for rights & services dimension

  If any of these three columns are missing, the function will abort,
  reminding you to run the corresponding prep functions first.

## Value

The input `df`, with three new columns:

- `comp_prot_score` – overall protection severity (maximum of the three
  dimensions)

- `comp_prot_in_need` – binary (0/1): 1 if `comp_prot_score >= 3`, else
  0

- `comp_prot_in_severe_need` – binary (0/1): 1 if
  `comp_prot_score >= 4`, else 0

## Details

- **Column checks** via
  [`purrr::iwalk()`](https://purrr.tidyverse.org/reference/imap.html)
  ensure the three dimension scores exist.

- **Computation** uses [`pmax()`](https://rdrr.io/r/base/Extremes.html)
  (with `na.rm = FALSE`)

- **Thresholds** (3 for “in need”, 4 for “severe need”) are currently
  hard‑coded.
