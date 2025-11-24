# Add Education Disruption Categories

This function adds education disruption binaries to individual-level
data and summarizes them at the household level. It includes two main
functions: `add_loop_edu_disrupted_d()` for individual-level data and
`add_loop_edu_disrupted_d_to_main()` for household-level data.

Prerequisite function:

- add_loop_edu_ind_age_corrected.R

## Usage

``` r
add_loop_edu_disrupted_d(
  df,
  attack = "edu_disrupted_attack",
  hazards = "edu_disrupted_hazards",
  displaced = "edu_disrupted_displaced",
  teacher = "edu_disrupted_teacher",
  levels = c("yes", "no", "dnk", "pnta"),
  ind_schooling_age_d = "edu_ind_schooling_age_d"
)

add_loop_edu_disrupted_d_to_main(
  main,
  loop,
  attack_d = "edu_disrupted_attack_d",
  hazards_d = "edu_disrupted_hazards_d",
  displaced_d = "edu_disrupted_displaced_d",
  teacher_d = "edu_disrupted_teacher_d",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
```

## Arguments

- df:

  A data frame containing individual-level education data.

- attack:

  Column name for attack disruption. NULL if dimension is not present in
  the data frame.

- hazards:

  Column name for hazards disruption.

- displaced:

  Column name for displaced disruption.

- teacher:

  Column name for teacher disruption.

- levels:

  Vector of levels for the disruption variables.

- ind_schooling_age_d:

  Column name for the dummy variable of the schooling age class.

- main:

  A data frame of household-level data.

- loop:

  A data frame of individual-level data.

- attack_d:

  Column name for the dummy variable of the attack dimension. NULL if
  dimension is not present in the data frame.

- hazards_d:

  Column name for the dummy variable of the hazards dimension.

- displaced_d:

  Column name for the dummy variable of the displaced dimension.

- teacher_d:

  Column name for the dummy variable of the teacher dimension.

- id_col_main:

  Column name for the unique identifier in the main dataset.

- id_col_loop:

  Column name for the unique identifier in the loop dataset.

## Value

A data frame with additional columns:

- \*\_d: Binary columns for each disruption type (e.g.,
  edu_disrupted_attack_d).

A data frame with additional columns:

- edu_disrupted\_\*\_n: Count of individuals experiencing each type of
  education disruption (e.g., edu_disrupted_hazards_n).
