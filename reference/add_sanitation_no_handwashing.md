# Add No Improved Sanitation and No Handwashing Facility Indicator

Flags households without access to improved sanitation AND without any
handwashing facility. Output is `NA` when either the sanitation or
handwashing category is undefined.

Prerequisites:
[`add_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md)
and
[`add_handwashing_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_handwashing_facility_cat.md)
must have been run first.

## Usage

``` r
add_sanitation_no_handwashing(
  df,
  sanitation_facility_cat = "wash_sanitation_facility_cat",
  sanitation_facility_cat_improved = "improved",
  sanitation_facility_cat_unimproved = "unimproved",
  sanitation_facility_cat_none = "none",
  sanitation_facility_cat_undefined = "undefined",
  handwashing_jmp_cat = "wash_handwashing_facility_jmp_cat",
  handwashing_facility_jmp_no_facility = "no_facility",
  handwashing_facility_jmp_limited = "limited",
  handwashing_facility_jmp_basic = "basic",
  handwashing_facility_jmp_undefined = "undefined"
)
```

## Arguments

- df:

  A data frame.

- sanitation_facility_cat:

  Column name for the recoded sanitation facility type (output of
  [`add_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md)).

- sanitation_facility_cat_improved:

  Response code for improved sanitation facility.

- sanitation_facility_cat_unimproved:

  Response code for unimproved sanitation facility.

- sanitation_facility_cat_none:

  Response code for no sanitation facility (open defecation).

- sanitation_facility_cat_undefined:

  Response code for undefined sanitation facility.

- handwashing_jmp_cat:

  Column name for the JMP handwashing facility category (output of
  [`add_handwashing_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_handwashing_facility_cat.md)).

- handwashing_facility_jmp_no_facility:

  Response code for no handwashing facility.

- handwashing_facility_jmp_limited:

  Response code for limited handwashing facility (no water or soap).

- handwashing_facility_jmp_basic:

  Response code for basic handwashing facility (water and soap
  available).

- handwashing_facility_jmp_undefined:

  Response code for undefined handwashing category.

## Value

A data frame with one additional column:

- `wash_sanitation_no_handwashing_d`: `1L` if no improved sanitation
  (open defecation or unimproved facility) AND no handwashing facility;
  `0L` if the sanitation facility is improved (including a shared
  improved facility) or has handwashing (limited or basic);
  `NA_integer_` if either category is `NA` or undefined.

## ANA indicator

Metric ID `MET150`.

## Examples

``` r
df <- data.frame(
  wash_sanitation_facility_cat = c(
    "improved", "improved", "unimproved", "none", "undefined"
  ),
  wash_handwashing_facility_jmp_cat = c(
    "no_facility", "basic", "no_facility", "no_facility", "no_facility"
  )
)
add_sanitation_no_handwashing(df)
#>   wash_sanitation_facility_cat wash_handwashing_facility_jmp_cat
#> 1                     improved                       no_facility
#> 2                     improved                             basic
#> 3                   unimproved                       no_facility
#> 4                         none                       no_facility
#> 5                    undefined                       no_facility
#>   wash_sanitation_no_handwashing_d
#> 1                                0
#> 2                                0
#> 3                                1
#> 4                                1
#> 5                               NA
```
