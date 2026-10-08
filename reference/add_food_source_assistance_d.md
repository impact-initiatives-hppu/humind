# Add Humanitarian Assistance First-Ranked Food Source Dummy Variable

Creates a binary (1/0/NA) dummy variable indicating whether a
household's first-ranked (main) food source is humanitarian assistance.
The first-ranked source is taken from the ranked food-source question
(`fsl_source_food_ranked`), whose value is an ordered, space-separated
list of choice names.

## Usage

``` r
add_food_source_assistance_d(
  df,
  source_food = "fsl_source_food_ranked",
  assistance = c("assistance_in_kind", "assistance_cva"),
  non_assistance = c("own_production", "purchase_cash", "purchase_credit", "hunting",
    "gathering", "exchange", "borrow", "gift", "begging"),
  undefined = c("other", "dnk", "pnta"),
  rank_sep = " "
)
```

## Arguments

- df:

  A data frame of household-level data.

- source_food:

  Column name for the ranked food-source question. Its value is an
  ordered, space-separated list of choice names; the first entry is the
  household's main food source.

- assistance:

  Character vector of choice names for humanitarian assistance food
  sources. The dummy is `1` when the first-ranked source is in this set.
  Must not overlap `non_assistance` or `undefined`.

- non_assistance:

  Character vector of known, valid non-assistance food sources. The
  dummy is `0` when the first-ranked source is in this set. Must not
  overlap `assistance` or `undefined`.

- undefined:

  Character vector of non-substantive responses (e.g. `other`, `dnk`,
  `pnta`). The dummy is `NA` when the first-ranked source is in this
  set, and also when it is missing.

- rank_sep:

  Separator between ranked choices in `source_food`. Default `" "`.

## Value

A data frame with additional columns:

- fsl_food_source_main: The first-ranked (main) food source, or `NA`
  when missing.

- fsl_food_source_assistance_d: 1 if the first-ranked food source is
  humanitarian assistance; 0 if it is a known non-assistance source;
  `NA` if it cannot be classified.

## Details

ANA function 2025 INDICATOR ID: IND052 2026 METRIC ID: TBD

## Examples

``` r
df <- data.frame(
  fsl_source_food_ranked = c(
    "assistance_in_kind purchase_cash",
    "purchase_cash own_production",
    "other purchase_cash",
    NA
  )
)
add_food_source_assistance_d(df)
#>             fsl_source_food_ranked fsl_food_source_main
#> 1 assistance_in_kind purchase_cash   assistance_in_kind
#> 2     purchase_cash own_production        purchase_cash
#> 3              other purchase_cash                other
#> 4                             <NA>                 <NA>
#>   fsl_food_source_assistance_d
#> 1                            1
#> 2                            0
#> 3                           NA
#> 4                           NA
```
