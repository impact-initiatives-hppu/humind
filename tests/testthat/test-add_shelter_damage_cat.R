# Load required packages
library(testthat)
library(dplyr)

# Example test data covering all categories
test_df <- data.frame(
  snfi_shelter_damage = c(
    "none",                 # No damage
    "minor",                # Damaged
    "damage_windows_doors", # Damaged
    "major",                # Partial collapse
    "total_collapse",       # Total collapse
    "dnk",                  # Undefined
    "other"                 # Undefined
  ),
  stringsAsFactors = FALSE
)

# Expected output for the new column
expected <- c(
  "none",
  "damaged",
  "damaged",
  "part",
  "total",
  "undefined",
  "undefined"
)

# Test: Correct categorization
test_that("add_shelter_damage_cat categorizes correctly", {
  result <- add_shelter_damage_cat(test_df)
  expect_equal(result$snfi_shelter_damage_cat, expected)
})

# Test: Error if column is missing
test_that("add_shelter_damage_cat errors if column missing", {
  df_missing <- data.frame(other_col = c("none", "minor"))
  expect_error(add_shelter_damage_cat(df_missing))
})

# Test: Error if value not in allowed set
test_that("add_shelter_damage_cat errors if value not in allowed set", {
  df_bad_value <- data.frame(snfi_shelter_damage = c("none", "bad_value"))
  expect_error(add_shelter_damage_cat(df_bad_value))
})
