# Add Under-5 Sick Dummy Variables to Individual Data

Adds dummy (0/1/NA) variables for illness and illness type to
individual-level loop data. Illness type columns are derived from
select_multiple binary columns built as
`<ind_under5_sick_symptoms><sep><choice>`.

Aggregates individual-level under-5 sick dummy variables to the
household level. Members who are not eligible (not under 5) are ignored.
A household is blank when it has no eligible member, and also when any
eligible member has an unknown answer, so that only households with a
known count enter the percentage.

## Usage

``` r
add_loop_under5_sick_d(
  loop,
  ind_under5_sick_yn = "nut_ind_under5_sick_yn",
  ind_under5_sick_yn_yes = "yes",
  ind_under5_sick_yn_no = "no",
  ind_under5_sick_yn_dnk = "dnk",
  ind_under5_sick_yn_pnta = "pnta",
  ind_under5_sick_symptoms = "nut_ind_under5_sick_symptoms",
  ind_under5_sick_symptoms_respiratory = "cough",
  ind_under5_sick_symptoms_watery = "diarrhoea",
  ind_under5_sick_symptoms_undefined = c("dnk", "pnta"),
  sep = "/"
)

add_loop_under5_sick_d_to_main(
  main,
  loop,
  ind_under5_sick_yes_d = "nut_ind_under5_sick_yes_d",
  ind_under5_sick_yes_respiratory_d = "nut_ind_under5_sick_yes_respiratory_d",
  ind_under5_sick_yes_watery_d = "nut_ind_under5_sick_yes_watery_d",
  ind_under5_eligible = "nut_ind_age_0_4",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
```

## Arguments

- loop:

  A data frame of individual-level data.

- ind_under5_sick_yn:

  Column name for the sick yes/no question.

- ind_under5_sick_yn_yes:

  Level for "yes".

- ind_under5_sick_yn_no:

  Level for "no".

- ind_under5_sick_yn_dnk:

  Level for "don't know".

- ind_under5_sick_yn_pnta:

  Level for "prefer not to answer".

- ind_under5_sick_symptoms:

  Base column name for the select_multiple symptoms question.

- ind_under5_sick_symptoms_respiratory:

  Character vector of choice names for respiratory symptoms (combined
  with `ind_under5_sick_symptoms` and `sep`). The dummy is 1 if the
  individual is sick AND any of these symptom columns is 1.

- ind_under5_sick_symptoms_watery:

  Character vector of choice names for watery diarrhoea symptoms
  (combined with `ind_under5_sick_symptoms` and `sep`). The dummy is 1
  if the individual is sick AND any of these symptom columns is 1.

- ind_under5_sick_symptoms_undefined:

  Character vector of choice names for non-substantive symptom responses
  (combined with `ind_under5_sick_symptoms` and `sep`). A sick
  individual with any of these selected is coded `NA` for the type
  dummies, not `0`.

- sep:

  Separator between the base column name and the choice name. Default
  `"/"`.

- main:

  A data frame of household-level data.

- ind_under5_sick_yes_d:

  Binary variable for under-5 sick.

- ind_under5_sick_yes_respiratory_d:

  Binary variable for sick with respiratory symptom.

- ind_under5_sick_yes_watery_d:

  Binary variable for sick with watery diarrhoea symptom.

- ind_under5_eligible:

  Column name for the under-5 eligibility flag (`1` for a child under 5,
  `0` otherwise).

- id_col_main:

  Column name for the unique identifier in `main`.

- id_col_loop:

  Column name for the unique identifier in `loop`.

## Value

A data frame with additional columns:

- nut_ind_under5_sick_yes_d: Dummy variable (1/0/NA) for under-5 sick.

- nut_ind_under5_sick_yes_respiratory_d: Dummy variable (1/0/NA) for
  sick with any respiratory symptom. 1 = sick and any respiratory column
  is 1; 0 = not sick, or sick and all respiratory columns are 0; NA when
  sick status is unknown or a non-substantive symptom response is
  selected.

- nut_ind_under5_sick_yes_watery_d: Dummy variable (1/0/NA) for sick
  with any watery diarrhoea symptom. Same logic as above.

A data frame with additional columns:

- nut_ind_under5_sick_yes_d_n: Count of under-5 sick individuals per
  household, or `NA` when the household has no under-5 child or an
  eligible child's answer is unknown.

- nut_ind_under5_sick_yes_respiratory_d_n: Count of under-5 with
  respiratory infection symptom per household.

- nut_ind_under5_sick_yes_watery_d_n: Count of under-5 with watery
  diarrhoea symptom per household.

## Details

ANA function 2025 INDICATOR ID: IND015, IND016, IND017 2026 METRIC ID:
TBD
