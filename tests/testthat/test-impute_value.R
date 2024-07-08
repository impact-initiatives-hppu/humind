library(testthat)
library(dplyr)
library(tidyr)
library(rlang)
library(limma)

test_that("impute_value works with default parameters", {
  df <- data.frame(
    var1 = c(1, 2, NA, 4),
    var2 = c(NA, 2, 3, NA)
  )

  result <- impute_value(df, vars = c("var1", "var2"), value = 0)

  expected <- data.frame(
    var1 = c(1, 2, 0, 4),
    var2 = c(0, 2, 3, 0)
  )

  expect_equal(result, expected)
})

test_that("impute_value handles all NA values", {
  df <- data.frame(
    var1 = c(NA_real_, NA_real_, NA_real_),
    var2 = c(NA_real_, NA_real_, NA_real_)
  )

  result <- impute_value(df, vars = c("var1", "var2"), value = 0)

  expected <- data.frame(
    var1 = c(0, 0, 0),
    var2 = c(0, 0, 0)
  )

  expect_equal(result, expected)
})

test_that("impute_value handles missing columns", {
  df <- data.frame(
    var1 = c(1, 2, NA, 4)
  )

  expect_error(impute_value(df, vars = c("var1", "var2"), value = 0), class = "error")
})

test_that("impute_median works with default parameters", {
  df <- data.frame(
    var1 = c(1, 2, NA, 4),
    var2 = c(NA, 2, 3, NA)
  )

  result <- impute_median(df, vars = c("var1", "var2"))

  expected <- data.frame(
    var1 = c(1, 2, 2, 4),
    var2 = c(2, 2, 3, 2)
  )

  expect_equal(result, expected)
})

test_that("impute_median handles grouping", {
  df <- data.frame(
    group = c("A", "A", "B", "B"),
    var1 = c(1, NA, 2, NA),
    var2 = c(NA, 2, 3, NA)
  )

  result <- impute_median(df, vars = c("var1", "var2"), group = "group")

  expected <- data.frame(
    group = c("A", "A", "B", "B"),
    var1 = c(1, 1, 2, 2),
    var2 = c(2, 2, 3, 3)
  )

  expect_equal(result, expected)
})

test_that("impute_median handles weighted median", {
  df <- data.frame(
    var1 = c(1, 2, NA, 4),
    var2 = c(NA, 2, 3, NA),
    weight = c(1, 2, 1, 2)
  )

  result <- impute_median(df, vars = c("var1", "var2"), weighted = TRUE, weight = "weight")

  expected <- data.frame(
    var1 = c(1, 2, 2, 4),
    var2 = c(2, 2, 3, 2),
    weight = c(1, 2, 1, 2)
  )

  expect_equal(result, expected)
})

test_that("impute_median handles missing columns", {
  df <- data.frame(
    var1 = c(1, 2, NA, 4)
  )

  expect_error(impute_median(df, vars = c("var1", "var2")), class = "error")
})

test_that("impute_median handles non-numeric variables", {
  df <- data.frame(
    var1 = c("a", "b", NA, "d"),
    var2 = c(NA, 2, 3, NA)
  )

  expect_error(impute_median(df, vars = c("var1", "var2")), class = "error")
})
