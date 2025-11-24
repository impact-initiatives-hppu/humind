# Categorize Age and Create Age-Related Variables

This function provides two main functionalities:

1.  `add_age_cat()`: Adds age categories to a dataframe based on
    specified breaks.

2.  `add_age_18_cat()`: Adds age categories and a dummy variable for
    below and above 18 years old.

## Usage

``` r
add_age_cat(
  df,
  age_col,
  breaks = c(0, 18, 60, 120),
  labels = NULL,
  int_undefined = c(-999, 999),
  char_undefined = "undefined",
  new_colname = NULL
)

add_age_18_cat(
  df,
  age_col,
  int_undefined = c(-999, 999),
  char_undefined = "undefined",
  new_colname = NULL
)
```

## Arguments

- df:

  A dataframe.

- age_col:

  The column name to recategorize.

- breaks:

  A vector of cut points.

- labels:

  A vector of labels. If NULL, the labels will be the breaks.

- int_undefined:

  A vector of values undefined (such as -999, 999) to replace by
  char_undefined.

- char_undefined:

  A character to replace int_undefined values, often values
  corresponding to Don't know or Prefer not to answer.

- new_colname:

  The name of the new column. If NULL, it adds "\_cat" to the age_col
  (or "\_18_cat for `add_age_18_cat()`).

## Value

- For `add_age_cat()`: A dataframe with an additional column containing
  the age categories.

- For `add_age_18_cat()`: A dataframe with two additional columns: one
  with categories (below_18, above_18) and one with a dummy variable (0
  for below 18, 1 for above 18).
