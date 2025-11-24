# Add a correct schooling age to the loop

Add a correct schooling age to the loop

## Usage

``` r
add_loop_edu_ind_age_corrected(
  loop,
  main,
  id_col_loop = "uuid",
  id_col_main = "uuid",
  survey_start_date = "start",
  school_year_start_month = 9,
  ind_age = "ind_age",
  month = NULL,
  schooling_start_age = 5
)

add_loop_edu_ind_schooling_age_d_to_main(
  main,
  loop,
  ind_schooling_age_d = "edu_ind_schooling_age_d",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
```

## Arguments

- loop:

  A data frame of individual-level data.

- main:

  A data frame of household-level data.

- id_col_loop:

  Column name for the unique identifier in the loop dataset.

- id_col_main:

  Column name for the unique identifier in the main dataset.

- survey_start_date:

  Survey start date column name in main.

- school_year_start_month:

  The month when the school year has started.

- ind_age:

  The individual age column.

- month:

  If not NULL, an integer between 1 and 12 which will be used as the
  month of data collection for all households.

- schooling_start_age:

  The age at which we assign the value 1 to edu_ind_schooling_age_d.
  Default is 5.

- ind_schooling_age_d:

  Column name for the dummy variable of the schooling age class.

## Value

2 new columns: "edu_ind_age_corrected" with the corrected individual
age, and a dummy variable edu_ind_schooling_age_d
