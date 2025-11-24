# Add Category of Shelter damage (Optional SNFI dimension)

This function categorizes the shelter damage category based on provided
criteria.

## Usage

``` r
add_shelter_damage_cat(
  df,
  sep = "/",
  snfi_shelter_damage = "snfi_shelter_damage",
  none = "none",
  minor = "minor",
  major = "major",
  damage_windows_doors = "damage_windows_doors",
  damage_floors = "damage_floors",
  damage_walls = "damage_walls",
  total_collapse = "total_collapse",
  other = "other",
  dnk = "dnk",
  pnta = "pnta"
)
```

## Arguments

- df:

  Data frame containing the survey data.

- sep:

  Separator for the binary columns, default is "/".

- snfi_shelter_damage:

  Column name

- none:

  answer option

- minor:

  answer option

- major:

  answer option

- damage_windows_doors:

  answer option

- damage_floors:

  answer option

- damage_walls:

  answer option

- total_collapse:

  answer option

- other:

  answer option

- dnk:

  answer option

- pnta:

  answer option

## Value

A data frame with an additional column:

- snfi_shelter_damage_cat: Categorized shelter damages: "No damage",
  "Damaged", "Partial collapse or destruction", "Total collapse or
  destruction", or "Undefined".
