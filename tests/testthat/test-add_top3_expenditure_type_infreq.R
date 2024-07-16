# Load necessary libraries
library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data_infreq <- data.frame(
  uuid = 1:4,
  cm_expenditure_infrequent = c("dnk", "pnta", "none", "spent"),
  cm_expenditure_infrequent_shelter = c(NA, NA, NA, 100),
  cm_expenditure_infrequent_nfi = c(NA, NA, NA, 200),
  cm_expenditure_infrequent_health = c(NA, NA, NA, 150),
  cm_expenditure_infrequent_education = c(NA, NA, NA, 300),
  cm_expenditure_infrequent_debt = c(NA, NA, NA, 50),
  cm_expenditure_infrequent_other = c(NA, NA, NA, 25)
)

# 1. Test the function with default parameters
test_that("add_expenditure_type_zero_infreq function works with default parameters", {
  result <- add_expenditure_type_zero_infreq(dummy_data_infreq)

  # Check if the skipped expenditures are set to zero
  expected_result <- dummy_data_infreq
  expected_result[1:3, 3:8] <- 0

  expect_equal(result, expected_result)
})

# 2. Test handling of different undefined values
undefined_values_data <- dummy_data_infreq
undefined_values_data$cm_expenditure_infrequent <- c("unknown", "no_answer", "null", "spent")

test_that("add_expenditure_type_zero_infreq function handles different undefined values", {
  result <- add_expenditure_type_zero_infreq(
    undefined_values_data,
    undefined = c("unknown", "no_answer", "null")
  )

  # Check if the skipped expenditures are set to zero
  expected_result <- undefined_values_data
  expected_result[1:3, 3:8] <- 0

  expect_equal(result, expected_result)
})

# 3. Test handling of missing columns
missing_column_data_infreq <- dummy_data_infreq %>% select(-cm_expenditure_infrequent_shelter)

test_that("add_expenditure_type_zero_infreq function handles missing columns", {
  expect_error(add_expenditure_type_zero_infreq(missing_column_data_infreq))
})

# 4. Test that expenditure types are numeric
non_numeric_data_infreq <- dummy_data_infreq
non_numeric_data_infreq$cm_expenditure_infrequent_shelter <- as.character(non_numeric_data_infreq$cm_expenditure_infrequent_shelter)

test_that("add_expenditure_type_zero_infreq function checks for numeric expenditure types", {
  expect_error(add_expenditure_type_zero_infreq(non_numeric_data_infreq))
})
