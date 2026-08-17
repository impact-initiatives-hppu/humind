# Drop columns from main that are also computed in loop

Before joining loop-derived columns into main, drop any column names
main already shares with loop (e.g. from a prior run), except the two id
columns used for the join.

## Usage

``` r
drop_shared_loop_cols(main, loop, id_col_main, id_col_loop)
```

## Arguments

- main:

  A data frame (household-level)

- loop:

  A data frame (individual-level, already summarized)

- id_col_main:

  Column name for the unique identifier in main

- id_col_loop:

  Column name for the unique identifier in loop

## Value

main, with shared non-id columns dropped
