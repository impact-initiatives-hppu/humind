# Add Income Source Categories, Count, and Ranking Top 3

This function categorizes income sources, counts them by type, and ranks
the top 3 income sources. It also adds categories for emergency,
unstable, stable, and other income sources.

Prerequisite function:

- add_income_source_zero_to_sl.R

## Usage

``` r
add_income_source_rank(
  df,
  emergency = c("cm_income_source_assistance_n", "cm_income_source_support_friends_n",
    "cm_income_source_donation_n"),
  unstable = c("cm_income_source_casual_n", "cm_income_source_social_benefits_n",
    "cm_income_source_rent_n", "cm_income_source_remittances_n"),
  stable = c("cm_income_source_salaried_n", "cm_income_source_own_business_n",
    "cm_income_source_own_production_n"),
  other = "cm_income_source_other_n",
  id_col = "uuid"
)
```

## Arguments

- df:

  A data frame containing income source information.

- emergency:

  A vector of column names containing emergency income sources.

- unstable:

  A vector of column names containing unstable income sources.

- stable:

  A vector of column names containing stable income sources.

- other:

  The name of the column containing other income sources.

- id_col:

  The name of the column containing the unique identifier.

## Value

A data frame with additional columns:

- cm_income_source_emergency_n: Count of emergency income sources.

- cm_income_source_unstable_n: Count of unstable income sources.

- cm_income_source_stable_n: Count of stable income sources.

- cm_income_source_other_n: Count of other income sources.

- cm_income_source_top1: Top income source.

- cm_income_source_top2: Second top income source.

- cm_income_source_top3: Third top income source.
