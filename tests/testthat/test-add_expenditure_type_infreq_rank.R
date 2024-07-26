# Load necessary libraries
library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data_infreq <- data.frame(
  uuid = 1:4,
  cm_expenditure_frequent = c("no", "no", "no", "no"),
  cm_expenditure_infrequent = c("spent", "spent", "spent", "spent"),
  cm_expenditure_infrequent_shelter = c(100, 100, 100, 100),
  cm_expenditure_infrequent_nfi = c(0, 50, 50, 200),
  cm_expenditure_infrequent_health = c(0, 10, 50, 150),
  cm_expenditure_infrequent_education = c(50, 0, 0, 300),
  cm_expenditure_infrequent_debt = c(0, 0, 0, 50),
  cm_expenditure_infrequent_other = c(0, 0, 10, 25)
)

# 1. Test the function with default parameters
test_that("add_expenditure_type_zero_infreq function works with default parameters", {
  result <- add_expenditure_type_zero_infreq(dummy_data_infreq)

    expected_result <- dummy_data_infreq

  expect_equal(result, expected_result)
})

# 2. Test handling of missing columns
missing_column_data_infreq <- dummy_data_infreq %>% select(-cm_expenditure_infrequent_shelter)

test_that("add_expenditure_type_zero_infreq function handles missing columns", {
  expect_error(add_expenditure_type_zero_infreq(missing_column_data_infreq))
})

# 3. Test that expenditure types are numeric
non_numeric_data_infreq <- dummy_data_infreq
non_numeric_data_infreq$cm_expenditure_infrequent_shelter <- as.character(non_numeric_data_infreq$cm_expenditure_infrequent_shelter)

test_that("add_expenditure_type_zero_infreq function checks for numeric expenditure types", {
  expect_error(add_expenditure_type_zero_infreq(non_numeric_data_infreq))
})
