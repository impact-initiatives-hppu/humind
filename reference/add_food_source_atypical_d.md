# Add Atypical First-Ranked Food Source Dummy Variable

Creates a binary (1/0/NA) dummy variable indicating whether a
household's first-ranked (main) food source is atypical/emergency. The
first-ranked source is taken from the ranked food-source question
(`fsl_source_food_ranked`), whose value is an ordered, space-separated
list of choice names.

## Usage

``` r
add_food_source_atypical_d(
  df,
  source_food = "fsl_source_food_ranked",
  atypical = c("hunting", "gathering", "exchange", "borrow", "gift", "begging"),
  non_atypical = c("own_production", "purchase_cash", "purchase_credit",
    "assistance_in_kind", "assistance_cva"),
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

- atypical:

  Character vector of choice names for atypical/emergency food sources.
  The dummy is `1` when the first-ranked source is in this set. Must not
  overlap `non_atypical` or `undefined`.

- non_atypical:

  Character vector of known, valid non-atypical food sources. The dummy
  is `0` when the first-ranked source is in this set. Must not overlap
  `atypical` or `undefined`.

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

- fsl_food_source_atypical_d: 1 if the first-ranked food source is
  atypical; 0 if it is a known non-atypical source; `NA` if it cannot be
  classified.

## Details

ANA function 2025 INDICATOR ID: IND053 2026 METRIC ID: TBD

## Examples

``` r
df <- data.frame(
  fsl_source_food_ranked = c(
    "hunting purchase_cash",
    "purchase_cash own_production",
    "other purchase_cash",
    NA
  )
)
add_food_source_atypical_d(df)
#>         fsl_source_food_ranked fsl_food_source_main fsl_food_source_atypical_d
#> 1        hunting purchase_cash              hunting                          1
#> 2 purchase_cash own_production        purchase_cash                          0
#> 3          other purchase_cash                other                         NA
#> 4                         <NA>                 <NA>                         NA
```
