# Add Number of Shelter Issues and Related Category

This function calculates the number of shelter issues and categorizes
them based on predefined thresholds. It also handles undefined and other
responses.

## Usage

``` r
add_shelter_issue_cat(
  df,
  shelter_issue = "snfi_shelter_issue",
  none = "none",
  issues = c("lack_privacy", "lack_space", "temperature", "ventilation", "vectors",
    "no_natural_light", "leak", "lock", "lack_lighting", "difficulty_move",
    "lack_space_laundry"),
  undefined = c("dnk", "pnta"),
  other = c("other"),
  sep = "/"
)
```

## Arguments

- df:

  A data frame containing shelter issue data.

- shelter_issue:

  Component column: Shelter issues.

- none:

  Response code for no issue.

- issues:

  Character vector of issues.

- undefined:

  Character vector of undefined responses codes (e.g. "Prefer not to
  answer").

- other:

  Character vector of other responses codes (e.g. "Other").

- sep:

  Separator for the binary columns.

## Value

A data frame with additional columns:

- snfi_shelter_issue_n: Count of shelter issues.

- snfi_shelter_issue_cat: Categorized shelter issues: "none",
  "undefined", "other", "1_to_3", "4_to_7", or "8_to_11".
