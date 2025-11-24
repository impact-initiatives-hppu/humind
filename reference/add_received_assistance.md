# Add Received Assistance (Combined Calculation)

This function calculates and adds a new column for received assistance
based on two input columns: assistance received in the last 12 months
and the recall period of the assistance.

## Usage

``` r
add_received_assistance(
  df,
  received_assistance_12m = "aap_received_assistance_12m",
  yes = "yes",
  no = "no",
  undefined = c("dnk", "pnta"),
  received_assistance_date = "aap_received_assistance_date",
  date_past_30d = "past_30d",
  date_1_3_months = "1_3_months",
  date_4_6_months = "4_6_months",
  date_7_12_months = "7_12_months",
  date_undefined = c("dnk", "pnta")
)
```

## Arguments

- df:

  A data frame containing assistance information.

- received_assistance_12m:

  Column name for received assistance in the last 12 months.

- yes:

  Value for yes.

- no:

  Value for no.

- undefined:

  Vector of undefined responses.

- received_assistance_date:

  Column name for the recall period when the assistance was received.

- date_past_30d:

  Value for received assistance in the past 30 days.

- date_1_3_months:

  Value for received assistance in the last 1-3 months.

- date_4_6_months:

  Value for received assistance in the last 4-6 months.

- date_7_12_months:

  Value for received assistance in the last 7-12 months.

- date_undefined:

  Vector of undefined responses for the date of received assistance.

## Value

A data frame with an additional column:

- aap_received_assistance: Categorized received assistance: "undefined",
  "no", "past_30d", "1_3_months", "4_6_months", or "7_12_months".
