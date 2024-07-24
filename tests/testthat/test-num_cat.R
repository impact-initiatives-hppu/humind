# tests/testthat/test-num_cat.R

library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data <- data.frame(
  num_col = c(1, 5, 10, 15, 20, 25, -999, 999, NA)
)

# 1. Test the function with default parameters
test_that("Function works with default parameters", {
  breaks <- c(0, 10, 20)
  result <- num_cat(dummy_data, "num_col", breaks)
  expect_true("num_col_cat" %in% colnames(result))
})

# 2. Test handling undefined values
undefined_data <- data.frame(
  num_col = c(-999, 999, -999, 999)
)

test_that("Function handles undefined values", {
  breaks <- c(0, 10, 20)
  result <- num_cat(undefined_data, "num_col", breaks, int_undefined = c(-999, 999), char_undefined = "Unknown")
  expect_true(all(result$num_col_cat == "Unknown"))
})

# 3. Test with sample data containing NA values
na_data <- data.frame(
  num_col = c(1, 5, 10, 15, NA, -999, 999)
)

test_that("Function handles NA values in data", {
  breaks <- c(0, 10, 20)
  result <- num_cat(na_data, "num_col", breaks)
  expect_true(any(is.na(result$num_col_cat)))
})

# 4. Test handling missing columns
missing_column_data <- data.frame(
  other_col = c(1, 5, 10, 15)
)

test_that("Function handles missing columns", {
  breaks <- c(0, 10, 20)
  expect_error(num_cat(missing_column_data, "num_col", breaks))
})

# 5. Additional common scenarios
# Test with invalid breaks
invalid_breaks_data <- dummy_data

test_that("Function handles invalid breaks", {
  invalid_breaks <- c(0)
  expect_error(num_cat(invalid_breaks_data, "num_col", invalid_breaks))
})

# Test with invalid labels length
invalid_labels_data <- dummy_data

# Test with plus_last parameter
plus_last_data <- dummy_data

test_that("Function handles plus_last parameter", {
  breaks <- c(0, 10, 20)
  result <- num_cat(plus_last_data, "num_col", breaks, plus_last = TRUE)
  expect_true(any(grepl("\\+", result$num_col_cat)))
})

# Test with negative values
negative_values_data <- data.frame(
  num_col = c(-1, -5, -10)
)

test_that("Function handles negative values", {
  breaks <- c(0, 10, 20)
  result <- num_cat(negative_values_data, "num_col", breaks)
  expect_true(all(is.na(result$num_col_cat)))
})

# Test with custom new column name
custom_colname_data <- dummy_data

test_that("Function handles custom new column name", {
  breaks <- c(0, 10, 20)
  result <- num_cat(custom_colname_data, "num_col", breaks, new_colname = "custom_col")
  expect_true("custom_col" %in% colnames(result))
})
