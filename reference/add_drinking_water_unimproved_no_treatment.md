# Add Unimproved Drinking Water and No Treatment Indicator

`add_drinking_water_unimproved_no_treatment()` flags households that
rely on an unimproved or surface water source **and** report not
treating their drinking water. The flag is `NA` when either the water
source category or the treatment response is undefined. Prerequisite:
[`add_drinking_water_source_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md)
must have been run first so that `wash_drinking_water_source_cat` is
present in `df`.

## Usage

``` r
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

- drinking_water_source_cat:

  Column name for the recoded water source category (output of
  [`add_drinking_water_source_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md)).

- drinking_water_source_cat_improved:

  Response code for improved water source category.

- drinking_water_source_cat_unimproved:

  Response code for unimproved water source category.

- drinking_water_source_cat_surface_water:

  Response code for surface water source category.

- drinking_water_source_cat_undefined:

  Response code for undefined water source category.

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

A data frame with one additional column:

- `wash_drinking_water_unimproved_no_treatment_d`: `1L` if
  unimproved/surface water source and no treatment; `0L` if improved
  source or unimproved/surface water with treatment; `NA_integer_` if
  source category or treatment response is `NA` or undefined.

## ANA indicator

Metric ID `MET113`.

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
