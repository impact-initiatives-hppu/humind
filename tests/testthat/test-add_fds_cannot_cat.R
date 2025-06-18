# Load required libraries
library(dplyr)
library(testthat)
library(tibble)

# ---- The function under test (reference, not redefined here) ----
# add_fds_cannot_cat is assumed to be already available in your environment

# ---- Example data ----
test_df <- tibble(
  snfi_fds_cooking = c("no", "yes", "no_need", "pnta", "yes"),
  snfi_fds_sleeping = c("yes", "no", "pnta", "yes", "no"),
  snfi_fds_storing = c("yes_no_issues", "no", "yes_issues", "pnta", "no"),
  energy_lighting_source = c("solar", "none", "pnta", "dnk", "none")
)

# ---- Tests ----
test_that("add_fds_cannot_cat works as expected", {
  result <- add_fds_cannot_cat(test_df)

  # Check new columns exist
  expect_true(all(c(
    "snfi_fds_cooking", "snfi_fds_sleeping", "snfi_fds_storing", "energy_lighting_source",
    "snfi_fds_cooking_d", "snfi_fds_sleeping_d", "snfi_fds_storing_d", "energy_lighting_source_d",
    "snfi_fds_cannot_n", "snfi_fds_cannot_cat"
  ) %in% names(result)))

  # Check correct recoding for cooking
  expect_equal(result$snfi_fds_cooking, c("yes", "no_cannot", "no_no_need", "undefined", "no_cannot"))

  # Check correct recoding for sleeping
  expect_equal(result$snfi_fds_sleeping, c("yes", "no_cannot", "undefined", "yes", "no_cannot"))

  # Check correct recoding for storing
  expect_equal(result$snfi_fds_storing, c("yes", "no_cannot", "yes", "undefined", "no_cannot"))

  # Check correct recoding for lighting
  expect_equal(result$energy_lighting_source, c("solar", "none", "undefined", "undefined", "none"))

  # Check binary dummy columns
  expect_equal(result$snfi_fds_cooking_d, c(0, 1, 0, NA, 1))
  expect_equal(result$snfi_fds_sleeping_d, c(0, 1, NA, 0, 1))
  expect_equal(result$snfi_fds_storing_d, c(0, 1, 0, NA, 1))
  expect_equal(result$energy_lighting_source_d, c(0, 1, NA, NA, 1))

  # Check snfi_fds_cannot_n calculation
  expect_equal(result$snfi_fds_cannot_n, c(0, 4, NA, NA, 4))

  # Check snfi_fds_cannot_cat categorization
  expect_equal(result$snfi_fds_cannot_cat, c("none", "4_tasks", NA, NA, "4_tasks"))
})

test_that("add_fds_cannot_cat errors if columns missing", {
  df_missing <- test_df[, -1]
  expect_error(add_fds_cannot_cat(df_missing), "Missing columns")
})

cat("All tests passed!\n")
