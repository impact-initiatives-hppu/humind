# Prepare Washington Group Short Set (WG-SS) Disability Indicators

This function prepares dummy variables for each WG-SS component (vision,
hearing, mobility, cognition, self-care, communication) and their levels
(no difficulty, some difficulty, a lot of difficulty, cannot do at all).
It combines them into sum scores for each level and creates disability
binary cut-offs variables.

## Usage

``` r
add_loop_wgq_ss(
  loop,
  ind_age = "ind_age",
  vision = "wgq_vision",
  hearing = "wgq_hearing",
  mobility = "wgq_mobility",
  cognition = "wgq_cognition",
  self_care = "wgq_self_care",
  communication = "wgq_communication",
  no_difficulty = "no_difficulty",
  some_difficulty = "some_difficulty",
  lot_of_difficulty = "lot_of_difficulty",
  cannot_do = "cannot_do",
  undefined = c("dnk", "pnta")
)

add_loop_wgq_ss_to_main(
  main,
  loop,
  wgq_dis_4 = "wgq_dis_4",
  wgq_dis_3 = "wgq_dis_3",
  wgq_dis_2 = "wgq_dis_2",
  wgq_dis_1 = "wgq_dis_1",
  ind_age_above_5 = "ind_age_above_5",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
```

## Arguments

- loop:

  A data frame of individual-level data.

- ind_age:

  The individual age column.

- vision:

  Vision component column.

- hearing:

  Hearing component column.

- mobility:

  Mobility component column.

- cognition:

  Cognition component column.

- self_care:

  Self-care component column.

- communication:

  Communication component column.

- no_difficulty:

  Level for no difficulty.

- some_difficulty:

  Level for some difficulty.

- lot_of_difficulty:

  Level for a lot of difficulty.

- cannot_do:

  Level for cannot do at all.

- undefined:

  Vector of undefined responses, such as Prefer not to answer and Don't
  know.

- main:

  A data frame of household-level data.

- wgq_dis_4:

  Column name for the disability 4 cut-offs binary.

- wgq_dis_3:

  Column name for the disability 3 cut-offs binary.

- wgq_dis_2:

  Column name for the disability 2 cut-offs binary.

- wgq_dis_1:

  Column name for the disability 1 cut-offs binary.

- ind_age_above_5:

  Column name for the age above 5 dummy in the individual-level dataset.

- id_col_main:

  Column name for the unique identifier in the main dataset.

- id_col_loop:

  Column name for the unique identifier in the loop dataset.

## Value

A data frame with additional columns:

- \*\_cannot_do_d: Binary indicators for "cannot do" level for each
  component.

- \*\_lot_of_difficulty_d: Binary indicators for "a lot of difficulty"
  level for each component.

- \*\_some_difficulty_d: Binary indicators for "some difficulty" level
  for each component.

- \*\_no_difficulty_d: Binary indicators for "no difficulty" level for
  each component.

- wgq_cannot_do_n: Sum of "cannot do" indicators across all components.

- wgq_lot_of_difficulty_n: Sum of "a lot of difficulty" indicators
  across all components.

- wgq_some_difficulty_n: Sum of "some difficulty" indicators across all
  components.

- wgq_no_difficulty_n: Sum of "no difficulty" indicators across all
  components.

- wgq_cannot_do_d: Binary indicator for any "cannot do" across all
  components.

- wgq_lot_of_difficulty_d: Binary indicator for any "a lot of
  difficulty" across all components.

- wgq_some_difficulty_d: Binary indicator for any "some difficulty"
  across all components.

- wgq_no_difficulty_d: Binary indicator for any "no difficulty" across
  all components.

- wgq_dis_4: Disability cut-off 4: any domain coded as "cannot do at
  all".

- wgq_dis_3: Disability cut-off 3: any domain coded as "a lot of
  difficulty" or "cannot do at all".

- wgq_dis_2: Disability cut-off 2: at least 2 domains coded as "some
  difficulty" or any domain coded as "a lot of difficulty" or "cannot do
  at all".

- wgq_dis_1: Disability cut-off 1: at least one domain coded as "some
  difficulty", "a lot of difficulty", or "cannot do at all".
