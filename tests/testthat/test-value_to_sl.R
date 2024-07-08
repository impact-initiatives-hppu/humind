library(testthat)
library(dplyr)

# Sample data for testing
df <- tibble::tibble(
  id = 1:4,
  var = c("a", "b", NA, "d"),
  sl_var1 = c(NA, 2, NA, 4),
  sl_var2 = c(NA, NA, 3, 4)
)

test_that("value_to_sl adds sl_value correctly", {
  result <- value_to_sl(df, var = "var", undefined = c("a", "d"), sl_vars = c("sl_var1", "sl_var2"), sl_value = 10)

  expect_equal(result$sl_var1, c(NA, 2, 10, NA))
  expect_equal(result$sl_var2, c(NA, NA, 10, NA))
})

test_that("value_to_sl skips adding sl_value when var is undefined", {
  result <- value_to_sl(df, var = "var", undefined = c("a", "d"), sl_vars = c("sl_var1", "sl_var2"), sl_value = 10)

  expect_equal(result$sl_var1, c(NA, 2, 10, NA)) # Check that values are correctly unchanged where var is "a" or "d"
  expect_equal(result$sl_var2, c(NA, NA, 10, NA))
})

test_that("value_to_sl handles non-NA sl_vars correctly", {
  result <- value_to_sl(df, var = "var", undefined = NULL, sl_vars = c("sl_var1", "sl_var2"), sl_value = 10)

  expect_equal(result$sl_var1, c(10, 2, 10, 10))
  expect_equal(result$sl_var2, c(10, 10, 3, 10))
})

test_that("value_to_sl adds suffix to new variable names", {
  result <- value_to_sl(df, var = "var", undefined = NULL, sl_vars = c("sl_var1", "sl_var2"), sl_value = 10, suffix = "_new")

  expect_equal(result$sl_var1_new, c(10, 2, 10, 10))
  expect_equal(result$sl_var2_new, c(10, 10, 3, 10))
  expect_true(all(c("sl_var1_new", "sl_var2_new") %in% names(result)))
})
