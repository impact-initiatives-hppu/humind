# Add Dummy Variable for 'In Need' Status

This set of functions adds new binary variables indicating if a score is
above certain thresholds. `is_in_need()` adds a variable for scores
above 3 (indicating "in need"), while `is_in_severe_need()` adds a
variable for scores above 4 (indicating "in severe need").

## Usage

``` r
is_in_need(df, score, new_colname = NULL)

is_in_severe_need(df, score, new_colname = NULL)
```

## Arguments

- df:

  A dataframe containing the score variable.

- score:

  The variable containing the score on a 1-5 scale.

- new_colname:

  The name of the new column. If NULL, the function will create a new
  column with the name 'score_in_need' or 'score_in_severe_need'.

## Value

A dataframe with an additional column:

- new_colname: A binary variable indicating if the score meets the
  threshold for being "in need" (1) or not (0).
