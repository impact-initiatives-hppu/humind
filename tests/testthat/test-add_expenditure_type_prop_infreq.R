library(testthat)
library(dplyr)


# Dummy data for testing
dummy_data <- data.frame(
  uuid = 1:4,
  cm_expenditure_infrequent_shelter = c(100, 200, 300, 400),
  cm_expenditure_infrequent_nfi = c(150, 250, 350, 450),
  cm_expenditure_infrequent_health = c(50, 100, 150, 200),
  cm_expenditure_infrequent_education = c(80, 160, 240, 320),
  cm_expenditure_infrequent_debt = c(60, 120, 180, 240),
  cm_expenditure_infrequent_other = c(40, 80, 120, 160)
)

# 1. Test the function with default parameters
test_that("add_expenditure_type_prop_infreq function works with default parameters", {
  result <- add_expenditure_type_prop_infreq(dummy_data)

  # Check if proportion columns are added
  expected_cols <- paste0(colnames(dummy_data)[-1], "_prop")
  expect_true(all(expected_cols %in% colnames(result)))

  # Check if proportions are calculated correctly
  total_expenditure <- rowSums(dummy_data[,-1])
  for (col in colnames(dummy_data)[-1]) {
    prop_col <- paste0(col, "_prop")
    expect_equal(result[[prop_col]], dummy_data[[col]] / total_expenditure)
  }
})

# 2. Test handling of missing columns
missing_column_data <- dummy_data %>% select(-cm_expenditure_infrequent_shelter)

test_that("add_expenditure_type_prop_infreq function handles missing columns", {
  expect_error(add_expenditure_type_prop_infreq(missing_column_data))
})

# 3. Test correct handling of zero total expenditures
zero_expenditure_data <- dummy_data
zero_expenditure_data[, -1] <- 0

test_that("add_expenditure_type_prop_infreq function handles zero total expenditures correctly", {
  result <- add_expenditure_type_prop_infreq(zero_expenditure_data)
  expected_cols <- paste0(colnames(dummy_data)[-1], "_prop")

  for (col in expected_cols) {
    expect_true(all(is.na(result[[col]])))
  }
})

# 4. Test correct calculation with varying values
varying_data <- data.frame(
  uuid = 1:2,
  cm_expenditure_infrequent_shelter = c(100, 0),
  cm_expenditure_infrequent_nfi = c(0, 200),
  cm_expenditure_infrequent_health = c(50, 50),
  cm_expenditure_infrequent_education = c(0, 0),
  cm_expenditure_infrequent_debt = c(0, 0),
  cm_expenditure_infrequent_other = c(0, 0)
)

test_that("add_expenditure_type_prop_infreq function handles varying values correctly", {
  result <- add_expenditure_type_prop_infreq(varying_data)
  expect_equal(result$cm_expenditure_infrequent_shelter_prop[1], 2/3)
  expect_equal(result$cm_expenditure_infrequent_nfi_prop[2], 4/5)
})

# 5. Test correct handling of negative values
negative_value_data <- dummy_data
negative_value_data[1, -1] <- -100

test_that("add_expenditure_type_prop_infreq function handles negative values correctly", {
  result <- add_expenditure_type_prop_infreq(negative_value_data)
  total_expenditure <- rowSums(negative_value_data[,-1])
  for (col in colnames(negative_value_data)[-1]) {
    prop_col <- paste0(col, "_prop")
    expect_equal(result[[prop_col]], negative_value_data[[col]] / total_expenditure)
  }
})

