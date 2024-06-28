library(testthat)
library(dplyr)
library(purrr)
library(rlang)

# Sample data for testing
df <- data.frame(
  dummy1 = c(0, 1, 0, NA, 1),
  dummy2 = c(1, 0, NA, 0, 1),
  dummy3 = c(0, 1, 1, 0, NA)
)

# Test with default parameters
test_that("add_dummy_from_dummies works with default parameters", {
  result <- add_dummy_from_dummies(df, dummy1, dummy2, dummy3)
  expected <- c(1, 1, 1, 0, 1)
  expect_equal(result$dummy_from_dummies, expected)
})

# Test with na_to_zero set to TRUE
test_that("add_dummy_from_dummies works with na_to_zero = TRUE", {
  result <- add_dummy_from_dummies(df, dummy1, dummy2, dummy3, na_to_zero = TRUE)
  expected <- c(1, 1, 1, 0, 1)
  expect_equal(result$dummy_from_dummies, expected)
})

# Test with na_to_zero set to FALSE
test_that("add_dummy_from_dummies works with na_to_zero = FALSE", {
  result <- add_dummy_from_dummies(df, dummy1, dummy2, dummy3, na_to_zero = FALSE)
  expected <- c(1, 1, NA, 0, 1)
  expect_equal(result$dummy_from_dummies, expected)
})

# Test with missing columns
test_that("add_dummy_from_dummies handles missing columns", {
  df_missing <- df[, -3]  # Remove dummy3
  expect_error(add_dummy_from_dummies(df_missing, dummy1, dummy2, dummy3), class = "error")
})

# Test with non-numeric values
test_that("add_dummy_from_dummies handles non-numeric values", {
  df_non_numeric <- df
  df_non_numeric$dummy1 <- c("a", "b", "c", "d", "e")
  expect_error(add_dummy_from_dummies(df_non_numeric, dummy1, dummy2, dummy3), class = "error")
})

# Test with all undefined values
test_that("add_dummy_from_dummies handles all undefined values", {
  df_undefined <- data.frame(
    dummy1 = c(NA, NA, NA),
    dummy2 = c(NA, NA, NA),
    dummy3 = c(NA, NA, NA)
  )
  result <- add_dummy_from_dummies(df_undefined, dummy1, dummy2, dummy3, na_to_zero = TRUE)
  expected <- c(0, 0, 0)
  expect_equal(result$dummy_from_dummies, expected)
})

# Test with only one dummy column
test_that("add_dummy_from_dummies works with one dummy column", {
  result <- add_dummy_from_dummies(df, dummy1)
  expected <- c(0, 1, 0, NA, 1)
  expect_equal(result$dummy_from_dummies, expected)
})

# Test with custom dummy_name
test_that("add_dummy_from_dummies works with custom dummy_name", {
  result <- add_dummy_from_dummies(df, dummy_name = "custom_dummy", dummy1, dummy2, dummy3)
  expected <- c(1, 1, 1, 0, 1)
  expect_equal(result$custom_dummy, expected)
})
