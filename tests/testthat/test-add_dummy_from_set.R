# tests/testthat/test-add_dummy_from_set.R

library(testthat)
library(dplyr)
library(rlang)
library(stringr)

# Sample data for testing
df <- data.frame(
  text_col = c("apple", "banana", "apple banana", "cherry", NA, "grape"),
  stringsAsFactors = FALSE
)

# Test with default parameters
test_that("add_dummy_from_set works with default parameters", {
  result <- add_dummy_from_set(df, text_col, "dummy_fruit", c("apple", "banana"))
  expected <- c(1, 1, 1, 0, NA, 0)
  expect_equal(result$dummy_fruit, expected)
})

# Test with na_to_zero set to TRUE
test_that("add_dummy_from_set works with na_to_zero = TRUE", {
  result <- add_dummy_from_set(df, text_col, "dummy_fruit", c("apple", "banana"), na_to_zero = TRUE)
  expected <- c(1, 1, 1, 0, 0, 0)
  expect_equal(result$dummy_fruit, expected)
})

# Test with na_to_zero set to FALSE
test_that("add_dummy_from_set works with na_to_zero = FALSE", {
  result <- add_dummy_from_set(df, text_col, "dummy_fruit", c("apple", "banana"), na_to_zero = FALSE)
  expected <- c(1, 1, 1, 0, NA, 0)
  expect_equal(result$dummy_fruit, expected)
})

# Test with empty set
test_that("add_dummy_from_set handles empty set", {
  result <- add_dummy_from_set(df, text_col, "dummy_empty", c())
  expected <- rep(0, nrow(df))
  expect_equal(result$dummy_empty, expected)
})

# Test with missing column
test_that("add_dummy_from_set handles missing column", {
  expect_error(add_dummy_from_set(df, missing_col, "dummy_missing", c("apple", "banana")))
})

# Test with non-string column
test_that("add_dummy_from_set handles non-string column", {
  df_non_string <- data.frame(
    non_string_col = c(1, 2, 3, 4, NA, 6),
    stringsAsFactors = FALSE
  )
  expect_error(add_dummy_from_set(df_non_string, non_string_col, "dummy_non_string", c("1", "2")))
})

# Test with complex strings in set
test_that("add_dummy_from_set works with complex strings in set", {
  df_complex <- data.frame(
    text_col = c("apple", "banana", "apple banana", "cherry", NA, "grape"),
    stringsAsFactors = FALSE
  )
  result <- add_dummy_from_set(df_complex, text_col, "dummy_complex", c("apple banana", "cherry"))
  expected <- c(0, 0, 1, 1, NA, 0)
  expect_equal(result$dummy_complex, expected)
})

# Test with overlapping strings in set
test_that("add_dummy_from_set works with overlapping strings in set", {
  result <- add_dummy_from_set(df, text_col, "dummy_overlap", c("app", "apple"))
  expected <- c(1, 0, 1, 0, NA, 0)
  expect_equal(result$dummy_overlap, expected)
})
