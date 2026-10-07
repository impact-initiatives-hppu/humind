# Add Livestock Significant Decrease Dummy Variables

For each livestock type, creates a binary (1/0/NA) dummy indicating
whether the household experienced a significant decrease (`threshold` or
more) in livestock size between last year and now. Also produces a
composite dummy that is 1 if any livestock type shows a significant
decrease.

If the required columns for a livestock type are absent from `df`, an
error is thrown.

## Usage

``` r
add_livestock_significant_decrease_d(
  df,
  livestock = c("oxen", "camel", "cattle", "horse", "mule", "donkey", "sheep", "goat",
    "poultry"),
  prefix = "fsl_",
  n_now_suffix = "_n_now",
  n_ly_suffix = "_n_ly",
  threshold = 0.5
)
```

## Arguments

- df:

  A data frame of household-level data.

- livestock:

  Character vector of livestock type names. Column names are built as
  `<prefix><type><n_now_suffix>` and `<prefix><type><n_ly_suffix>`.

- prefix:

  Column name prefix. Default `"fsl_"`.

- n_now_suffix:

  Suffix for the current count column. Default `"_n_now"`.

- n_ly_suffix:

  Suffix for the last-year count column. Default `"_n_ly"`.

- threshold:

  Proportion decrease threshold at or above which a decrease is
  considered significant. Default `0.5` (i.e. a decrease of 50% or
  more).

## Value

A data frame with additional columns:

- `<prefix><type>_significant_decrease_d` for each livestock type: 1 if
  herd decreased by `threshold` or more; 0 if not; NA if either count is
  NA.

- `<prefix>livestock_significant_decrease_d`: 1 if any type dummy is 1;
  0 if none is 1 and at least one is non-NA; NA if all type dummies are
  NA.

## Details

ANA 2025 INDICATOR ID: IND043 2026 METRIC ID: TBD
