# Calculate Education Sectoral Composite Score and Need Indicators

This function calculates an education sectoral composite score based on
various education-related indicators. It computes scores for disrupted
education and attendance/barriers, combines them into a total score, and
determines if a household is in need or in severe need of educational
assistance.

Prerequisite functions:

- add_loop_age_dummy.R

- add_loop_edu_barrier_protection_d.R

- add_loop_edu_disrupted_d.R

- add_loop_edu_ind_age_corrected.R

## Usage

``` r
add_comp_edu(
  df,
  schooling_age_n = "edu_schooling_age_n",
  no_access_n = "edu_no_access_n",
  barrier_protection_n = "edu_barrier_protection_n",
  attack_n = "edu_disrupted_attack_n",
  hazards_n = "edu_disrupted_hazards_n",
  displaced_n = "edu_disrupted_displaced_n",
  teacher_n = "edu_disrupted_teacher_n"
)
```

## Arguments

- df:

  A data frame.

- schooling_age_n:

  Column name for the number of children of schooling age.

- no_access_n:

  Column name for the number of children with no access to education.

- barrier_protection_n:

  Column name for the number of children with barriers to protection.

- attack_n:

  Column name for the number of children with disrupted education due to
  the school being occupied by armed groups

- hazards_n:

  Column name for the number of children with disrupted education due to
  hazards.

- displaced_n:

  Column name for the number of children with disrupted education due to
  a recent displacement.

- teacher_n:

  Column name for the number of children with disrupted education due to
  teachers' absence.

## Value

A data frame with additional columns:

- comp_edu_score_disrupted: Score for disrupted education (1-4).

- comp_edu_score_attendance: Score for attendance and barriers (1-4)

- comp_edu_score: Total education composite score (max of disrupted and
  attendance scores).

- comp_edu_in_need: Binary indicator for being in need of educational
  assistance.

- comp_edu_in_severe_need: Binary indicator for being in severe need of
  educational assistance.
