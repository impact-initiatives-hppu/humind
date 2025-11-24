# Add Income Source Amounts as Proportions of Total Income

This function calculates the proportion of each income source relative
to the total income. It also computes the total income from all sources.

Prerequisite function:

- add_income_source_zero_to_sl.R

## Usage

``` r
add_income_source_prop(
  df,
  income_souce_salaried_n = "cm_income_source_salaried_n",
  income_source_casual_n = "cm_income_source_casual_n",
  income_source_own_business_n = "cm_income_source_own_business_n",
  income_source_own_production_n = "cm_income_source_own_production_n",
  income_source_social_benefits_n = "cm_income_source_social_benefits_n",
  income_source_rent_n = "cm_income_source_rent_n",
  income_source_remittances_n = "cm_income_source_remittances_n",
  income_source_assistance_n = "cm_income_source_assistance_n",
  income_source_support_friends_n = NULL,
  income_source_donation_n = NULL,
  income_source_other_n = "cm_income_source_other_n"
)
```

## Arguments

- df:

  A data frame containing income source columns

- income_souce_salaried_n:

  Column name for salaried income amount

- income_source_casual_n:

  Column name for casual income amount

- income_source_own_business_n:

  Column name for own business income amount

- income_source_own_production_n:

  Column name for own production income amount

- income_source_social_benefits_n:

  Column name for social benefits income amount

- income_source_rent_n:

  Column name for rent income amount

- income_source_remittances_n:

  Column name for remittances income amount

- income_source_assistance_n:

  Column name for assistance income amount

- income_source_support_friends_n:

  Column name for support from friends income amount

- income_source_donation_n:

  Column name for donation income amount

- income_source_other_n:

  Column name for other income amount

## Value

A data frame with additional columns:

- cm_income_total: Total income from all sources.

- \*\_prop: Proportion of each income source relative to total income
  (e.g., cm_income_source_salaried_n_prop).

## Details on loans

Loans (income_source_support_friends_n and income_source_donation_n) are
considered to be a cash influx. Yet they do not count as a formal income
source. While it is good practice to collect these figures as part of
this module, they should not be included in the total income
calculation. This is why their default value here is NULL.
