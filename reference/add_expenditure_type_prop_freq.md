# Add Frequent Expenditure Type Amount as Proportions of Total Frequent Expenditure

This function calculates the proportion of each frequent expenditure
type relative to the total frequent expenditure. It adds new columns to
the input data frame representing these proportions.

Prerequisite function:

- add_expenditure_type_zero_freq.R

## Usage

``` r
add_expenditure_type_prop_freq(
  df,
  cm_expenditure_frequent_food = "cm_expenditure_frequent_food",
  cm_expenditure_frequent_rent = "cm_expenditure_frequent_rent",
  cm_expenditure_frequent_water = "cm_expenditure_frequent_water",
  cm_expenditure_frequent_nfi = "cm_expenditure_frequent_nfi",
  cm_expenditure_frequent_utilities = "cm_expenditure_frequent_utilities",
  cm_expenditure_frequent_fuel = "cm_expenditure_frequent_fuel",
  cm_expenditure_frequent_transportation = "cm_expenditure_frequent_transportation",
  cm_expenditure_frequent_communication = "cm_expenditure_frequent_communication",
  cm_expenditure_frequent_other = "cm_expenditure_frequent_other"
)
```

## Arguments

- df:

  A data frame containing frequent expenditure data.

- cm_expenditure_frequent_food:

  Column name for food items expenditure amount.

- cm_expenditure_frequent_rent:

  Column name for rent or shelter and/or land expenditure amount.

- cm_expenditure_frequent_water:

  Column name for water expenditure amount from all sources combined.

- cm_expenditure_frequent_nfi:

  Column name for non-food household items expenditure amount for
  regular purchase, such as hygiene items, lightbulbs, etc.

- cm_expenditure_frequent_utilities:

  Column name for utilities expenditure amount, such as electricity or
  gas connections, etc.

- cm_expenditure_frequent_fuel:

  Column name for fuel expenditure amount for cooking, for vehicles,
  etc.

- cm_expenditure_frequent_transportation:

  Column name for transportation expenditure amount, not including
  vehicle fuel.

- cm_expenditure_frequent_communication:

  Column name for communications expenditure amount, such as phone
  airtime, Internet costs, etc.

- cm_expenditure_frequent_other:

  Column name for all other frequent expenditures.

## Value

A data frame with additional columns:

- cm_expenditure_frequent_total: The total frequent expenditure amount.

- cm_expenditure_frequent_food_prop: Proportion of food expenditure.

- cm_expenditure_frequent_rent_prop: Proportion of rent expenditure.

- cm_expenditure_frequent_water_prop: Proportion of water expenditure.

- cm_expenditure_frequent_nfi_prop: Proportion of non-food items
  expenditure.

- cm_expenditure_frequent_utilities_prop: Proportion of utilities
  expenditure.

- cm_expenditure_frequent_fuel_prop: Proportion of fuel expenditure.

- cm_expenditure_frequent_transportation_prop: Proportion of
  transportation expenditure.

- cm_expenditure_frequent_communication_prop: Proportion of
  communication expenditure.

- cm_expenditure_frequent_other_prop: Proportion of other frequent
  expenditures.
