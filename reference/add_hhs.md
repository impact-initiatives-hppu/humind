# Add the household hunger scale to the dataset

Add the household hunger scale to the dataset

## Usage

``` r
add_hhs(
  .dataset,
  fsl_hhs_nofoodhh = "fsl_hhs_nofoodhh",
  fsl_hhs_nofoodhh_freq = "fsl_hhs_nofoodhh_freq",
  fsl_hhs_sleephungry = "fsl_hhs_sleephungry",
  fsl_hhs_sleephungry_freq = "fsl_hhs_sleephungry_freq",
  fsl_hhs_alldaynight = "fsl_hhs_alldaynight",
  fsl_hhs_alldaynight_freq = "fsl_hhs_alldaynight_freq",
  yes_answer = "yes",
  no_answer = "no",
  rarely_answer = "rarely",
  sometimes_answer = "sometimes",
  often_answer = "often"
)
```

## Arguments

- .dataset:

  Main Dataset

- fsl_hhs_nofoodhh:

  The name of the column "In the past 4 weeks (30 days), was there ever
  no food to eat of any kind in your house because of lack of resources
  to get food?". It has to be a string.

- fsl_hhs_nofoodhh_freq:

  The name of the column "How often did this happen in the past (4
  weeks/30 days)?". It has to be a string.

- fsl_hhs_sleephungry:

  The name of the column "In the past 4 weeks (30 days), did you or any
  household member go to sleep at night hungry because there was not
  enough food?". It has to be a string.

- fsl_hhs_sleephungry_freq:

  The name of the column "How often did this happen in the past (4
  weeks/30 days)?". It has to be a string.

- fsl_hhs_alldaynight:

  The name of the column "In the past 4 weeks (30 days), did you or any
  household member go a whole day and night without eating anything at
  all because there was not enough food?". It has to be a string.

- fsl_hhs_alldaynight_freq:

  The name of the column "How often did this happen in the past (4
  weeks/30 days)?". It has to be a string.

- yes_answer:

  Value used for "yes"

- no_answer:

  Value used for the "no"

- rarely_answer:

  Value used for "rarely"

- sometimes_answer:

  Value used for "sometimes"

- often_answer:

  Value used for "often"

## Value

It returns the dataframe with 12 extras columns: recoded hhs questions,
score for the 3 sets of questions (from 0 to 2), the HHS score (from 0
to 6), the HHS category and the HHS IPC category

## Examples

``` r
{
  input_data <- data.frame(
    fsl_hhs_nofoodhh = c("no", "yes", "no", "no", "no"),
    fsl_hhs_nofoodhh_freq = c(NA_character_, "rarely",
     NA_character_, NA_character_, NA_character_),
    fsl_hhs_sleephungry = c("no", "no", "yes", "no", "no"),
    fsl_hhs_sleephungry_freq = c(NA_character_, NA_character_,
     "often", NA_character_, NA_character_),
    fsl_hhs_alldaynight = c("no", "no", "yes", "yes", "yes"),
    fsl_hhs_alldaynight_freq = c(NA_character_, NA_character_,
     "often", "rarely", "sometimes")
  )

  add_hhs(
    .dataset = input_data,
    fsl_hhs_nofoodhh = "fsl_hhs_nofoodhh",
    fsl_hhs_nofoodhh_freq = "fsl_hhs_nofoodhh_freq",
    fsl_hhs_sleephungry = "fsl_hhs_sleephungry",
    fsl_hhs_sleephungry_freq = "fsl_hhs_sleephungry_freq",
    fsl_hhs_alldaynight = "fsl_hhs_alldaynight",
    fsl_hhs_alldaynight_freq = "fsl_hhs_alldaynight_freq",
    yes_answer = "yes",
    no_answer = "no",
    rarely_answer = "rarely",
    sometimes_answer = "sometimes",
    often_answer = "often"
  )
}
#>   fsl_hhs_nofoodhh fsl_hhs_nofoodhh_freq fsl_hhs_sleephungry
#> 1               no                  <NA>                  no
#> 2              yes                rarely                  no
#> 3               no                  <NA>                 yes
#> 4               no                  <NA>                  no
#> 5               no                  <NA>                  no
#>   fsl_hhs_sleephungry_freq fsl_hhs_alldaynight fsl_hhs_alldaynight_freq
#> 1                     <NA>                  no                     <NA>
#> 2                     <NA>                  no                     <NA>
#> 3                    often                 yes                    often
#> 4                     <NA>                 yes                   rarely
#> 5                     <NA>                 yes                sometimes
#>   fsl_hhs_nofoodhh_recoded fsl_hhs_nofoodhh_freq_recoded
#> 1                        0                             0
#> 2                        1                             1
#> 3                        0                             0
#> 4                        0                             0
#> 5                        0                             0
#>   fsl_hhs_sleephungry_recoded fsl_hhs_sleephungry_freq_recoded
#> 1                           0                                0
#> 2                           0                                0
#> 3                           1                                2
#> 4                           0                                0
#> 5                           0                                0
#>   fsl_hhs_alldaynight_recoded fsl_hhs_alldaynight_freq_recoded fsl_hhs_comp1
#> 1                           0                                0             0
#> 2                           0                                0             1
#> 3                           1                                2             0
#> 4                           1                                1             0
#> 5                           1                                1             0
#>   fsl_hhs_comp2 fsl_hhs_comp3 fsl_hhs_score fsl_hhs_cat_ipc  fsl_hhs_cat
#> 1             0             0             0            None Little to No
#> 2             0             0             1          Little Little to No
#> 3             2             2             4          Severe       Severe
#> 4             0             1             1          Little Little to No
#> 5             0             1             1          Little Little to No
```
