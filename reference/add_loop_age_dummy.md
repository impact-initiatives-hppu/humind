# Add Age and Gender Dummy Variables for Demographics Loop

This set of functions adds dummy variables for age classes and gender in
the demographics loop, and optionally sums these dummies to the main
dataset. It includes four main functions: `add_loop_age_dummy()`,
`add_loop_age_dummy_to_main()`, `add_loop_age_gender_dummy()`, and
`add_loop_age_gender_dummy_to_main()`.

## Usage

``` r
add_loop_age_dummy(
  loop,
  ind_age = "ind_age",
  lb = 5,
  ub = 18,
  new_colname = NULL
)

add_loop_age_dummy_to_main(
  main,
  loop,
  ind_age_dummy = "ind_age_5_18",
  id_col_main = "uuid",
  id_col_loop = "uuid",
  new_colname = NULL
)

add_loop_age_gender_dummy(
  loop,
  ind_age = "ind_age",
  lb = 5,
  ub = 18,
  ind_gender = "ind_gender",
  gender = "female",
  new_colname = NULL
)

add_loop_age_gender_dummy_to_main(
  main,
  loop,
  ind_age_gender_dummy = "ind_age_female_5_18",
  id_col_main = "uuid",
  id_col_loop = "uuid",
  new_colname = NULL
)
```

## Arguments

- loop:

  A data frame of individual-level data.

- ind_age:

  Column name for individual age.

- lb:

  Lower bound for the age class.

- ub:

  Upper bound for the age class.

- new_colname:

  New column name for the dummy variable. If NULL, then the default is
  "ind_age_lb_ub" or "ind_dummy_n" or "ind_age_gender_lb_ub" or
  "ind_age_gender_dummy_n" depending on the function used.

- main:

  A data frame of household-level data.

- ind_age_dummy:

  Column name for the dummy variable of the age class.

- id_col_main:

  Column name for the unique identifier in the main dataset.

- id_col_loop:

  Column name for the unique identifier in the loop dataset.

- ind_gender:

  Column name for individual gender.

- gender:

  Response options of interest, e.g. "Female".

- ind_age_gender_dummy:

  Column name for the dummy variable of the age-gender class.

## Value

Depending on the function used:

- add_loop_age_dummy: Returns the loop data frame with an additional
  column for the age dummy variable.

- add_loop_age_dummy_to_main: Returns the main data frame with an
  additional column for the sum of age dummy variables.

- add_loop_age_gender_dummy: Returns the loop data frame with an
  additional column for the age-gender dummy variable.

- add_loop_age_gender_dummy_to_main: Returns the main data frame with an
  additional column for the sum of age-gender dummy variables.
