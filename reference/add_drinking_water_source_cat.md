# Add Drinking Water Quality JMP Category

This function recodes the water source and time to fetch water into a
joint JMP (Joint Monitoring Programme) category.

`add_drinking_water_unimproved_no_treatment()` flags households that
rely on an unimproved or surface water source **and** report not
treating their drinking water. The flag is `NA` when either the water
source category or the treatment response is undefined. Prerequisite:
`add_drinking_water_source_cat()` must have been run first so that
`wash_drinking_water_source_cat` is present in `df`.

## Usage

``` r
add_drinking_water_source_cat(
  df,
  drinking_water_source = "wash_drinking_water_source",
  drinking_water_source_cat_improved = c("piped_dwelling", "piped_compound",
    "piped_neighbour", "tap", "borehole", "protected_well", "well_spring",
    "rainwater_collection", "tank_truck", "cart_tank", "kiosk", "bottled_water",
    "sachet_water"),
  drinking_water_source_cat_unimproved = c("unprotected_well", "unprotected_spring"),
  drinking_water_source_cat_surface_water = "surface_water",
  drinking_water_source_cat_undefined = c("dnk", "pnta", "other")
)

add_drinking_water_time_cat(
  df,
  drinking_water_time_yn = "wash_drinking_water_time_yn",
  water_on_premises = c("water_in_dwelling", "water_in_plot"),
  number_minutes = "number_minutes",
  dnk = "dnk",
  undefined = "pnta",
  drinking_water_time_int = "wash_drinking_water_time_int",
  max_minutes = 600,
  drinking_water_time_sl = "wash_drinking_water_time_sl",
  sl_under_30_min = c("5min_or_less", "5min_15min", "15min_30min"),
  sl_30min_1hr = "30min_1hr",
  sl_more_than_1hr = "more_than_1hr",
  sl_undefined = c("dnk", "pnta"),
  drinking_water_source = "wash_drinking_water_source",
  skipped_drinking_water_source_premises = "piped_dwelling",
  skipped_drinking_water_source_undefined = c("dnk", "pnta")
)

add_drinking_water_time_threshold_cat(
  df,
  drinking_water_time_30min_cat = "wash_drinking_water_time_cat",
  drinking_water_time_30min_cat_premises = "premises",
  drinking_water_time_30min_cat_under_30min = c("under_30_min"),
  drinking_water_time_30min_cat_above_30min = c("30min_1hr", "more_than_1hr"),
  drinking_water_time_30min_cat_undefined = "undefined"
)

add_drinking_water_quality_jmp_cat(
  df,
  drinking_water_source_cat = "wash_drinking_water_source_cat",
  drinking_water_source_cat_improved = "improved",
  drinking_water_source_cat_unimproved = "unimproved",
  drinking_water_source_cat_surface_water = "surface_water",
  drinking_water_source_cat_undefined = "undefined",
  drinking_water_time_30min_cat = "wash_drinking_water_time_30min_cat",
  drinking_water_time_30min_cat_premises = "premises",
  drinking_water_time_30min_cat_under_30min = "under_30min",
  drinking_water_time_30min_cat_above_30min = "above_30min",
  drinking_water_time_30min_cat_undefined = "undefined"
)

add_drinking_water_unimproved_no_treatment(
  df,
  drinking_water_source_cat = "wash_drinking_water_source_cat",
  drinking_water_source_cat_improved = "improved",
  drinking_water_source_cat_unimproved = "unimproved",
  drinking_water_source_cat_surface_water = "surface_water",
  drinking_water_source_cat_undefined = "undefined",
  drinking_water_safer_yn = "wash_drinking_water_safer_yn",
  drinking_water_safer_yes = "yes",
  drinking_water_safer_no = "no",
  drinking_water_safer_undefined = c("dnk", "pnta")
)
```

## Arguments

- df:

  A data frame.

- drinking_water_source:

  Component column: Water source types.

- drinking_water_source_cat_improved:

  Response code for improved water source category.

- drinking_water_source_cat_unimproved:

  Response code for unimproved water source category.

- drinking_water_source_cat_surface_water:

  Response code for surface water source category.

- drinking_water_source_cat_undefined:

  Response code for undefined water source category.

- drinking_water_time_yn:

  Component column: Time to fetch water, scoping question.

- water_on_premises:

  Character vector of responses codes for water on premises.

- number_minutes:

  Character vector of responses codes for number of minutes.

- dnk:

  Character vector of responses codes for "Don't know".

- undefined:

  Character vector of responses codes for undefined information, e.g.
  "Prefer not to answer".

- drinking_water_time_int:

  Component column: Time to fetch water, integer.

- max_minutes:

  Integer, the maximum value for the time to fetch water.

- drinking_water_time_sl:

  Component column: Time to fetch water, simple choice.

- sl_under_30_min:

  Character vector of response codes for under 30 minutes, e.g.
  c("5min_or_less", "5min_15min", "15min_30min").

- sl_30min_1hr:

  Response code for 30 minutes to 1 hour.

- sl_more_than_1hr:

  Response code for more than 1 hour.

- sl_undefined:

  Character vector of responses codes for undefined information, e.g.
  "Don't know" or "Prefer not to answer".

- skipped_drinking_water_source_premises:

  Character vector of responses codes for skipped water source on
  premises, e.g. "Piped into dwelling".

- skipped_drinking_water_source_undefined:

  Character vector of responses codes for skipped water source
  undefined, e.g. "Don't know" or "Prefer not to answer".

- drinking_water_time_30min_cat:

  Component column: Time to fetch water, recoded categories.

- drinking_water_time_30min_cat_premises:

  Response code for water on premises.

- drinking_water_time_30min_cat_under_30min:

  Response code for under 30 minutes.

- drinking_water_time_30min_cat_above_30min:

  Response code for above 30 minutes.

- drinking_water_time_30min_cat_undefined:

  Response code for undefined time.

- drinking_water_source_cat:

  Column name for the recoded water source category (output of
  `add_drinking_water_source_cat()`).

- drinking_water_safer_yn:

  Column name for the water treatment scoping question
  (`select_one l_yn_dnk_pnta`).

- drinking_water_safer_yes:

  Response code for household treats water.

- drinking_water_safer_no:

  Response code for household does not treat water.

- drinking_water_safer_undefined:

  Character vector of undefined response codes for the treatment
  question.

## Value

A data frame with a new column 'wash_drinking_water_quality_jmp_cat'
containing:

- limited: Response indicating limited access to safe drinking water.

- basic: Response indicating basic access to safe drinking water.

- unimproved: Response indicating unimproved water sources.

- surface_water: Response indicating surface water sources.

- undefined: Response for undefined categories.

A data frame with one additional column:

- `wash_drinking_water_unimproved_no_treatment_d`: `1L` if
  unimproved/surface water source and no treatment; `0L` if improved
  source or unimproved/surface water with treatment; `NA_integer_` if
  source category or treatment response is `NA` or undefined.

## Examples

``` r
df <- data.frame(
  wash_drinking_water_source_cat = c("improved", "unimproved", "surface_water"),
  wash_drinking_water_safer_yn = c("yes", "no", "dnk")
)
add_drinking_water_unimproved_no_treatment(df)
#>   wash_drinking_water_source_cat wash_drinking_water_safer_yn
#> 1                       improved                          yes
#> 2                     unimproved                           no
#> 3                  surface_water                          dnk
#>   wash_drinking_water_unimproved_no_treatment_d
#> 1                                             0
#> 2                                             1
#> 3                                            NA
```
