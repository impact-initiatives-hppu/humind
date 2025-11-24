# Update Head of Household Information

This function updates the head of household (HoH) gender and age
information based on whether the respondent is the HoH or not. If the
respondent is the HoH, their gender and age are used; otherwise, the
existing HoH information is retained.

## Usage

``` r
add_hoh_final(
  df,
  resp_hoh_yn = "resp_hoh_yn",
  yes = "yes",
  no = "no",
  hoh_gender = "hoh_gender",
  hoh_age = "hoh_age",
  resp_gender = "resp_gender",
  resp_age = "resp_age"
)
```

## Arguments

- df:

  The input dataframe.

- resp_hoh_yn:

  The column name for whether the respondent is the head of household
  (HoH) yes/no indicator.

- yes:

  The value for 'yes' in the 'resp_hoh_yn' column.

- no:

  The value for 'no' in the 'resp_hoh_yn' column.

- hoh_gender:

  The column name for the household (HoH) gender.

- hoh_age:

  The column name for the household (HoH) age.

- resp_gender:

  The column name for the respondent (resp) gender.

- resp_age:

  The column name for the respondent (resp) age.

## Value

A modified dataframe with updated columns:

- hoh_gender: Updated head of household gender.

- hoh_age: Updated head of household age.
