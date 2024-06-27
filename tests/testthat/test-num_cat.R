# tests/testthat/test-num_cat.R

library(testthat)
library(dplyr)

# Example test data
df <- data.frame(
  num_col = c(1, 2, 3, 4, 5, -999, 999, -1, NA)
)

# Test cases
test_that("num_cat works with default parameters", {
  df_result <- num_cat(df, num_col = "num_col", breaks = c(0, 2, 4), labels = c("Low", "Medium", "High"))
  expect_equal(df_result$num_col_cat, c("Low", "Low", "Medium", "Medium", "High", "Unkown", "Unkown", NA, NA))
})

test_that("num_cat handles missing column", {
  expect_error(num_cat(df, num_col = "missing_col", breaks = c(0, 2, 4)), "The following column is missing in `num_col`:")
})

test_that("num_cat handles non-numeric column", {
  df_non_numeric <- data.frame(non_numeric_col = c("a", "b", "c"))
  expect_error(num_cat(df_non_numeric, num_col = "non_numeric_col", breaks = c(0, 2, 4)), "All columns must be numeric.")
})

test_that("num_cat handles custom undefined values", {
  df_result <- num_cat(df, num_col = "num_col", breaks = c(0, 2, 4), labels = c("Low", "Medium", "High"), int_undefined = c(-999, 999), char_undefined = "Unknown")
  expect_equal(df_result$num_col_cat, c("Low", "Low", "Medium", "Medium", "High", "Unknown", "Unknown", NA, NA))
})

test_that("num_cat handles custom column name", {
  df_result <- num_cat(df, num_col = "num_col", breaks = c(0, 2, 4), labels = c("Low", "Medium", "High"), new_colname = "custom_col")
  expect_true("custom_col" %in% names(df_result))
  expect_equal(df_result$custom_col, c("Low", "Low", "Medium", "Medium", "High", "Unkown", "Unkown", NA, NA))
})

test_that("num_cat handles invalid int_undefined values", {
  expect_error(num_cat(df, num_col = "num_col", breaks = c(0, 2, 4), int_undefined = c("a", "b")), "int_dontknow must only contain numeric values")
})

test_that("num_cat handles invalid char_undefined values", {
  expect_error(num_cat(df, num_col = "num_col", breaks = c(0, 2, 4), char_undefined = 123), "char_dontknow must be a character")
})

test_that("num_cat handles invalid breaks", {
  expect_error(num_cat(df, num_col = "num_col", breaks = c(0)), "breaks must have at least two values")
})

test_that("num_cat handles invalid labels length", {
  expect_warning(num_cat(df, num_col = "num_col", breaks = c(0, 2, 4), labels = c("Low", "Medium")), "labels must be of length of breaks + 1. Reverting to labels = NULL")
})

test_that("num_cat handles NA values", {
  df_result <- num_cat(df, num_col = "num_col", breaks = c(0, 2, 4))
  expect_equal(df_result$num_col_cat, c("[0,2]", "[0,2]", "(2,4]", "(2,4]", "(4,5]", "Unkown", "Unkown", NA, NA))
})

test_that("num_cat handles negative values", {
  df_negative <- data.frame(num_col = c(-10, -5, 0, 5, 10))
  df_result <- num_cat(df_negative, num_col = "num_col", breaks = c(0, 5, 10), labels = c("Low", "High"))
  expect_equal(df_result$num_col_cat, c(NA, NA, "Low", "Low", "High"))
})

