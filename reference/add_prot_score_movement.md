# add_prot_score_movement

add_prot_score_movement

## Usage

``` r
add_prot_score_movement(
  df,
  sep = "/",
  prot_needs_3_movement = "prot_needs_3_movement",
  no_changes_feel_unsafe = "no_changes_feel_unsafe",
  no_safety_concerns = "no_safety_concerns",
  women_girls_avoid_places = "women_girls_avoid_places",
  men_boys_avoid_places = "men_boys_avoid_places",
  women_girls_avoid_night = "women_girls_avoid_night",
  men_boys_avoid_night = "men_boys_avoid_night",
  girls_boys_avoid_school = "girls_boys_avoid_school",
  different_routes = "different_routes",
  avoid_markets = "avoid_markets",
  avoid_public_offices = "avoid_public_offices",
  avoid_fields = "avoid_fields",
  other_safety_measures = "other_safety_measures",
  dnk = "dnk",
  pnta = "pnta",
  .keep_weighted = FALSE
)
```

## Arguments

- df:

  Data frame containing the survey data.

- sep:

  Separator for the binary columns, default is "/".

- prot_needs_3_movement:

  Column name

- no_changes_feel_unsafe:

  answer option

- no_safety_concerns:

  answer option

- women_girls_avoid_places:

  answer option

- men_boys_avoid_places:

  answer option

- women_girls_avoid_night:

  answer option

- men_boys_avoid_night:

  answer option

- girls_boys_avoid_school:

  answer option

- different_routes:

  answer option

- avoid_markets:

  answer option

- avoid_public_offices:

  answer option

- avoid_fields:

  answer option

- other_safety_measures:

  answer option

- dnk:

  answer option

- pnta:

  answer option

- .keep_weighted:

  Logical, whether to keep the weighted columns in the output data
  frame. Default is FALSE.

## Value

data frame with additional columns:

- comp_prot_score_prot_needs_3

- comp_prot_score_movement
