# Add Categories for a Numeric Variable

This function categorizes a numeric column in a dataframe based on
specified breaks and labels. It can handle undefined values and provides
options for customizing the categorization process.

## Usage

``` r
num_cat(
  df,
  num_col,
  breaks,
  labels = NULL,
  int_undefined = c(-999, 999),
  char_undefined = "Unknown",
  new_colname = NULL,
  plus_last = FALSE,
  above_last = FALSE
)
```

## Arguments

- df:

  A dataframe containing the numeric column to be categorized.

- num_col:

  The column name to recategorize.

- breaks:

  A vector of cut points for categorization.

- labels:

  A vector of labels for the categories. If NULL, labels are
  automatically generated.

- int_undefined:

  A vector of numeric values to be replaced by char_undefined.

- char_undefined:

  A character string to replace int_undefined values.

- new_colname:

  The name of the new column. If NULL, it's automatically generated.

- plus_last:

  Logical, whether to add a "+" to the last category.

- above_last:

  Logical, whether to add a category for values above the last break.

## Value

A dataframe with an additional column:

- new_colname: A new column containing the categorized values of the
  original numeric column.
