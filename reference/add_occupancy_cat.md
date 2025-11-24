# Add Category of Occupancy Arrangement and Tenure Security

This function categorizes occupancy arrangements and eviction risk into
high, medium, or low risk, and then creates a new column for overall
tenure security, taking the maximum risk from both.

## Usage

``` r
add_occupancy_cat(
  df,
  occupancy = "hlp_occupancy",
  occupancy_high_risk = c("no_agreement"),
  occupancy_medium_risk = c("rented", "hosted_free"),
  occupancy_low_risk = c("ownership"),
  occupancy_undefined = c("dnk", "pnta", "other"),
  eviction = "hlp_risk_eviction",
  eviction_high_risk = "yes",
  eviction_low_risk = "no",
  eviction_undefined = c("dnk", "pnta")
)
```

## Arguments

- df:

  A data frame containing occupancy arrangement data.

- occupancy:

  Component column: Occupancy arrangement.

- occupancy_high_risk:

  Character vector of high risk occupancy arrangements.

- occupancy_medium_risk:

  Character vector of medium risk occupancy arrangements.

- occupancy_low_risk:

  Character vector of low risk occupancy arrangements.

- occupancy_undefined:

  Character vector of undefined response codes (e.g. "Prefer not to
  answer").

- eviction:

  Component column: Eviction risk.

- eviction_high_risk:

  Character vector of high risk eviction responses.

- eviction_low_risk:

  Character vector of low risk eviction responses.

- eviction_undefined:

  Character vector of undefined eviction responses.

## Value

A data frame with additional columns:

- hlp_occupancy_cat: Categorized occupancy arrangement: "high_risk",
  "medium_risk", "low_risk", or "undefined".

- hlp_eviction_cat: Categorized eviction risk: "high_risk", "low_risk",
  or "undefined".

- hlp_tenure_security: Maximum risk between hlp_occupancy_cat and
  hlp_eviction_cat.
