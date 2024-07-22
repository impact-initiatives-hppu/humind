library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data_infreq <- data.frame(
  uuid = 1:4,
  cm_expenditure_infrequent = c("dnk", "pnta", "none", "valid"),
  cm_expenditure_infrequent_shelter = c(NA, NA, NA, 500),
  cm_expenditure_infrequent_nfi = c(NA, NA, NA, 300),
  cm_expenditure_infrequent_health = c(NA, NA, NA, 400),
  cm_expenditure_infrequent_education = c(NA, NA, NA, 200),
  cm_expenditure_infrequent_debt = c(NA, NA, NA, 100),
  cm_expenditure_infrequent_other = c(NA, NA, NA, 50)
)

# 1. Test the function with default parameters
test_that("add_expenditure_type_zero_infreq function works with default parameters", {
  result <- add_expenditure_type_zero_infreq(dummy_data_infreq)

  # Check if zero is assigned correctly
  expect_equal(result$cm_expenditure_infrequent_shelter[1:3], c(0, 0, 0))
  expect_equal(result$cm_expenditure_infrequent_shelter[4], 500)
  expect_equal(result$cm_expenditure_infrequent_nfi[1:3], c(0, 0, 0))
  expect_equal(result$cm_expenditure_infrequent_nfi[4], 300)
  expect_equal(result$cm_expenditure_infrequent_health[1:3], c(0, 0, 0))
  expect_equal(result$cm_expenditure_infrequent_health[4], 400)
  expect_equal(result$cm_expenditure_infrequent_education[1:3], c(0, 0, 0))
  expect_equal(result$cm_expenditure_infrequent_education[4], 200)
  expect_equal(result$cm_expenditure_infrequent_debt[1:3], c(0, 0, 0))
  expect_equal(result$cm_expenditure_infrequent_debt[4], 100)
  expect_equal(result$cm_expenditure_infrequent_other[1:3], c(0, 0, 0))
  expect_equal(result$cm_expenditure_infrequent_other[4], 50)
})

# 2. Test handling of non-skipped values
non_skipped_data_infreq <- dummy_data_infreq
non_skipped_data_infreq$cm_expenditure_infrequent <- c("valid", "valid", "valid", "valid")

test_that("add_expenditure_type_zero_infreq function does not alter non-skipped values", {
  result <- add_expenditure_type_zero_infreq(non_skipped_data_infreq)

  # Check if non-skipped values are left unchanged
  expect_equal(result$cm_expenditure_infrequent_shelter, c(NA, NA, NA, 500))
  expect_equal(result$cm_expenditure_infrequent_nfi, c(NA, NA, NA, 300))
  expect_equal(result$cm_expenditure_infrequent_health, c(NA, NA, NA, 400))
  expect_equal(result$cm_expenditure_infrequent_education, c(NA, NA, NA, 200))
  expect_equal(result$cm_expenditure_infrequent_debt, c(NA, NA, NA, 100))
  expect_equal(result$cm_expenditure_infrequent_other, c(NA, NA, NA, 50))
})

# 3. Test handling of missing columns
missing_column_data_infreq <- dummy_data_infreq %>% select(-cm_expenditure_infrequent_shelter)

test_that("add_expenditure_type_zero_infreq function handles missing columns", {
  expect_error(add_expenditure_type_zero_infreq(missing_column_data_infreq))
})

# 4. Test correct handling of undefined values
undefined_value_data_infreq <- dummy_data_infreq
undefined_value_data_infreq$cm_expenditure_infrequent <- c("invalid", "pnta", "none", "valid")

test_that("add_expenditure_type_zero_infreq function handles undefined values correctly", {
  result <- add_expenditure_type_zero_infreq(undefined_value_data_infreq)

  # Check if zero is assigned correctly for defined values
  expect_equal(result$cm_expenditure_infrequent_shelter[2:3], c(0, 0))
  expect_equal(result$cm_expenditure_infrequent_shelter[4], 500)
})
