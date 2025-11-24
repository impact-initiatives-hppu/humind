# Add Drinking Water Quality JMP Category

This function recodes the water source and time to fetch water into a
joint JMP (Joint Monitoring Programme) category.

## Usage

``` r
add_drinking_water_source_cat(
  df,
  drinking_water_source = "wash_drinking_water_source",
  drinking_water_source_cat_improved = c("piped_dwelling", "piped_compound",
    "piped_neighbour", "tap", "borehole", "protected_well", "protected_spring",
    "rainwater_collection", "tank_truck", "cart_tank", "kiosk", "bottled_water",
    "sachet_water"),
  drinking_water_source_cat_unimproved = c("unprotected_well", "unprotected_spring"),
  drinking_water_source_cat_surface_water = "surface_water",
  drinking_water_source_cat_undefined = c("dnk", "pnta", "other")
)

add_drinking_water_time_cat(
  df,
  drinking_water_time_yn = "wash_drinking_water_time_yn",
  water_on_premises = "water_on_premises",
  number_minutes = "number_minutes",
  dnk = "dnk",
  undefined = "pnta",
  drinking_water_time_int = "wash_drinking_water_time_int",
  max = 600,
  drinking_water_time_sl = "wash_drinking_water_time_sl",
  sl_under_30_min = "under_30_min",
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
```

## Arguments

- df:

  A data frame.

- drinking_water_source:

  Component column: Water source types.

- drinking_water_source_cat_improved:

  Response code for improved water source.

- drinking_water_source_cat_unimproved:

  Response code for unimproved water source.

- drinking_water_source_cat_surface_water:

  Response code for surface water source.

- drinking_water_source_cat_undefined:

  Response code for undefined water source.

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

- max:

  Integer, the maximum value for the time to fetch water.

- drinking_water_time_sl:

  Component column: Time to fetch water, simple choice.

- sl_under_30_min:

  Response code for under 30 minutes.

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

  Component column: Water source categories.

## Value

A data frame with a new column 'wash_drinking_water_quality_jmp_cat'
containing:

- limited: Response indicating limited access to safe drinking water.

- basic: Response indicating basic access to safe drinking water.

- safely_managed: Response indicating safely managed drinking water.

- unimproved: Response indicating unimproved water sources.

- surface_water: Response indicating surface water sources.

- undefined: Response for undefined categories.
