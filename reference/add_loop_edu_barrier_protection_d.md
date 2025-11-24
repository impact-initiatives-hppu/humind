# Add Child Protection Barriers to Education Variable

This function adds a dummy variable for child protection barriers to
education in individual-level data and aggregates it to household-level
data.

Prerequisite function:

- add_loop_edu_ind_age_corrected.R

## Usage

``` r
add_loop_edu_barrier_protection_d(
  loop,
  barriers = "edu_barrier",
  protection_issues = c("protection_at_school", "protection_travel_school",
    "child_work_home", "child_work_outside", "child_armed_group", "child_marriage",
    "ban", "enroll_lack_documentation", "discrimination"),
  ind_schooling_age_d = "edu_ind_schooling_age_d"
)

add_loop_edu_barrier_protection_d_to_main(
  main,
  loop,
  ind_barrier_protection_d = "edu_ind_barrier_protection_d",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
```

## Arguments

- loop:

  A data frame of individual-level data for the loop.

- barriers:

  Column name for the child protection barrier category.

- protection_issues:

  Vector of protection issues RESPONSE CODES.

- ind_schooling_age_d:

  Column name for the dummy variable of schooling age.

- main:

  A data frame of household-level data.

- ind_barrier_protection_d:

  Column name for the dummy variable of the child protection barrier
  category.

- id_col_main:

  Column name for the unique identifier in the main dataset.

- id_col_loop:

  Column name for the unique identifier in the loop dataset.

## Value

A data frame with an additional column:

- edu_ind_barrier_protection_d: Dummy variable indicating if a
  school-aged child faces a protection barrier (1) or not (0).

A data frame with an additional column:

- edu_barrier_protection_n:

  Count of school-aged children facing protection barriers in each
  household.
