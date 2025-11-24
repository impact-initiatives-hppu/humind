# Add Education Access Dummy Variables

This function adds dummy variables to an individual-level dataframe for
all school-aged children. It creates a variable (`edu_ind_access_d`)
that indicates whether the child accessed school (1 if accessed, 0
otherwise) and another variable (`edu_ind_no_access_d`) that indicates
no access to school.

Prerequisite function:

- add_loop_edu_ind_age_corrected.R

## Usage

``` r
add_loop_edu_access_d(
  loop,
  ind_access = "edu_access",
  yes = "yes",
  no = "no",
  pnta = "pnta",
  dnk = "dnk",
  ind_schooling_age_d = "edu_ind_schooling_age_d"
)

add_loop_edu_access_d_to_main(
  main,
  loop,
  ind_access_d = "edu_ind_access_d",
  ind_no_access_d = "edu_ind_no_access_d",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
```

## Arguments

- loop:

  A data frame of individual-level data for the loop.

- ind_access:

  Column name for education access.

- yes:

  Value indicating access to education (e.g., "yes").

- no:

  Value indicating no access to education (e.g., "no").

- pnta:

  Value indicating not applicable (e.g., "pnta").

- dnk:

  Value indicating don't know (e.g., "dnk").

- ind_schooling_age_d:

  Column name for the dummy variable indicating schooling age.

- main:

  A data frame of household-level data.

- ind_access_d:

  Column name for education access (binary).

- ind_no_access_d:

  Column name for education no access (binary).

- id_col_main:

  Column name for the unique identifier in the main dataset.

- id_col_loop:

  Column name for the unique identifier in the loop dataset.

## Value

A data frame with additional columns:

- edu_ind_access_d: Dummy variable indicating access to education (1 if
  accessed, 0 otherwise).

- edu_ind_no_access_d: Dummy variable indicating no access to education
  (1 if not accessed, 0 otherwise).
