library(testthat)
library(dplyr)

# Sample data for testing
df <- data.frame(
  snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta"),
  snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "pnta", "dnk"),
  snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "pnta"),
  snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "dnk"),
  energy_lighting_source = c("none", "other", "candle", "pnta", "dnk")
)

test_that("add_fds_cannot_cat works with default parameters", {
  result <- add_fds_cannot_cat(df)

  expected <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "undefined"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "undefined", "undefined"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "undefined"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "undefined"),
    energy_lighting_source = c("none", "other", "candle", "undefined", "undefined"),
    snfi_fds_cooking_d = c(1, 0, 0, 0, NA),
    snfi_fds_sleeping_d = c(0, 1, 0, NA, NA),
    snfi_fds_storing_d = c(1, 1, 0, 0, NA),
    snfi_fds_personal_hygiene_d = c(0, 0, 1, 1, NA),
    energy_lighting_source_d = c(1, 0, 0, NA, NA),
    snfi_fds_cannot_n = c(3, 2, 1, NA, NA),
    snfi_fds_cannot_cat = c("2_to_3_tasks", "2_to_3_tasks", "1_task", NA, NA)
  )

  expect_equal(result, expected)
})

# Test if undefined and invalid responses are handled correctly

# Define a sample dataframe for testing
sample_df <- tibble::tibble(
  snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta"),
  snfi_fds_sleeping = c("no_cannot", "yes_issues", "pnta", "yes_no_issues", "dnk"),
  snfi_fds_storing = c("no_cannot", "yes_no_issues", "yes_issues", "pnta", "dnk"),
  snfi_fds_personal_hygiene = c("no_cannot", "yes_issues", "yes_no_issues", "no_cannot", "pnta"),
  energy_lighting_source = c("none", "light", "undefined", "none", "none")
)

test_that("add_fds_cannot_cat handles undefined and invalid responses", {
  result <- add_fds_cannot_cat(
    sample_df,
    fds_cooking = "snfi_fds_cooking",
    fds_cooking_cannot = "no_cannot",
    fds_cooking_can_issues = "yes_issues",
    fds_cooking_can_no_issues = "yes_no_issues",
    fds_cooking_no_need = "no_no_need",
    fds_cooking_undefined = c("pnta", "dnk"),
    fds_sleeping = "snfi_fds_sleeping",
    fds_sleeping_cannot = "no_cannot",
    fds_sleeping_can_issues = "yes_issues",
    fds_sleeping_can_no_issues = "yes_no_issues",
    fds_sleeping_undefined = c("pnta", "dnk"),
    fds_storing = "snfi_fds_storing",
    fds_storing_cannot = "no_cannot",
    fds_storing_can_issues = "yes_issues",
    fds_storing_can_no_issues = "yes_no_issues",
    fds_storing_undefined = c("pnta", "dnk"),
    fds_personal_hygiene = "snfi_fds_personal_hygiene",
    fds_personal_hygiene_cannot = "no_cannot",
    fds_personal_hygiene_can_issues = "yes_issues",
    fds_personal_hygiene_can_no_issues = "yes_no_issues",
    fds_personal_hygiene_undefined = c("pnta", "dnk"),
    lighting_source = "energy_lighting_source",
    lighting_source_none = "none",
    lighting_source_undefined = c("pnta", "dnk")
  )

  # Check undefined values for specific columns
  expect_equal(result$snfi_fds_cooking[5], "undefined")  # Undefined cooking response for the 5th row
  expect_equal(result$snfi_fds_sleeping[3], "undefined")  # Undefined sleeping response for the 3rd row
  expect_equal(result$energy_lighting_source[3], "undefined")  # Undefined lighting source for the 3rd row
})


test_that("add_fds_cannot_cat handles missing columns", {
  df <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta")
  )

  expect_error(add_fds_cannot_cat(df), class = "error")
})

test_that("add_fds_cannot_cat handles non-numeric variables", {
  df <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "pnta", "dnk"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "pnta"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "dnk"),
    energy_lighting_source = c("none", "other", "candle", "pnta", "dnk")
  )

  result <- add_fds_cannot_cat(df)

  expected <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "undefined"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "undefined", "undefined"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "undefined"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "undefined"),
    energy_lighting_source = c("none", "other", "candle", "undefined", "undefined"),
    snfi_fds_cooking_d = c(1, 0, 0, 0, NA),
    snfi_fds_sleeping_d = c(0, 1, 0, NA, NA),
    snfi_fds_storing_d = c(1, 1, 0, 0, NA),
    snfi_fds_personal_hygiene_d = c(0, 0, 1, 1, NA),
    energy_lighting_source_d = c(1, 0, 0, NA, NA),
    snfi_fds_cannot_n = c(3, 2, 1, NA, NA),
    snfi_fds_cannot_cat = c("2_to_3_tasks", "2_to_3_tasks", "1_task", NA, NA)
  )

  expect_equal(result, expected)
})
