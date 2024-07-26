library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data <- data.frame(
  uuid = 1:4,
  cm_expenditure_frequent = c("dnk", "pnta", "none", "valid"),
  cm_expenditure_frequent_food = c(NA, NA, NA, 100),
  cm_expenditure_frequent_rent = c(NA, NA, NA, 200),
  cm_expenditure_frequent_water = c(NA, NA, NA, 50),
  cm_expenditure_frequent_nfi = c(NA, NA, NA, 80),
  cm_expenditure_frequent_utilitiues = c(NA, NA, NA, 60),
  cm_expenditure_frequent_fuel = c(NA, NA, NA, 40),
  cm_expenditure_frequent_transportation = c(NA, NA, NA, 30),
  cm_expenditure_frequent_communication = c(NA, NA, NA, 20),
  cm_expenditure_frequent_other = c(NA, NA, NA, 10)
)

# 1. Test the function with default parameters
test_that("add_expenditure_type_zero_freq function works with default parameters", {
  result <- add_expenditure_type_zero_freq(dummy_data)

  # Check if zero is assigned correctly
  expect_equal(result$cm_expenditure_frequent_food[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_food[4], 100)
  expect_equal(result$cm_expenditure_frequent_rent[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_rent[4], 200)
  expect_equal(result$cm_expenditure_frequent_water[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_water[4], 50)
  expect_equal(result$cm_expenditure_frequent_nfi[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_nfi[4], 80)
  expect_equal(result$cm_expenditure_frequent_utilitiues[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_utilitiues[4], 60)
  expect_equal(result$cm_expenditure_frequent_fuel[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_fuel[4], 40)
  expect_equal(result$cm_expenditure_frequent_transportation[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_transportation[4], 30)
  expect_equal(result$cm_expenditure_frequent_communication[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_communication[4], 20)
  expect_equal(result$cm_expenditure_frequent_other[1:3], c(NA, NA, 0))
  expect_equal(result$cm_expenditure_frequent_other[4], 10)
})

# 2. Test handling of non-skipped values
non_skipped_data <- dummy_data
non_skipped_data$cm_expenditure_frequent <- c("valid", "valid", "valid", "valid")

test_that("add_expenditure_type_zero_freq function does not alter non-skipped values", {
  result <- add_expenditure_type_zero_freq(non_skipped_data)

  # Check if non-skipped values are left unchanged
  expect_equal(result$cm_expenditure_frequent_food, c(0, 0, 0, 100))
  expect_equal(result$cm_expenditure_frequent_rent, c(0, 0, 0, 200))
  expect_equal(result$cm_expenditure_frequent_water, c(0, 0, 0, 50))
  expect_equal(result$cm_expenditure_frequent_nfi, c(0, 0, 0, 80))
  expect_equal(result$cm_expenditure_frequent_utilitiues, c(0, 0, 0, 60))
  expect_equal(result$cm_expenditure_frequent_fuel, c(0, 0, 0, 40))
  expect_equal(result$cm_expenditure_frequent_transportation, c(0, 0, 0, 30))
  expect_equal(result$cm_expenditure_frequent_communication, c(0, 0, 0, 20))
  expect_equal(result$cm_expenditure_frequent_other, c(0, 0, 0, 10))
})

# 3. Test handling of missing columns
missing_column_data <- dummy_data %>% select(-cm_expenditure_frequent_food)

test_that("add_expenditure_type_zero_freq function handles missing columns", {
  expect_error(add_expenditure_type_zero_freq(missing_column_data))
})

# 4. Test correct handling of undefined values
undefined_value_data <- dummy_data
undefined_value_data$cm_expenditure_frequent <- c("invalid", "pnta", "none", "valid")

test_that("add_expenditure_type_zero_freq function handles undefined values correctly", {
  result <- add_expenditure_type_zero_freq(undefined_value_data)

  # Check if zero is assigned correctly for defined values
  expect_equal(result$cm_expenditure_frequent_food[2:3], c(NA, 0))
  expect_equal(result$cm_expenditure_frequent_food[4], 100)
})
