# tests/testthat/test-add_edu_access_d.R

library(testthat)
library(dplyr)
library(rlang)

# Sample data for testing
df <- data.frame(
  edu_access = c("yes", "no", "pnta", "dnk", NA, "yes"),
  ind_age_5_18 = c(1, 1, 1, 1, 0, 1),
  stringsAsFactors = FALSE
)

# Test with default parameters
test_that("add_edu_access_d works with default parameters", {
  result <- add_edu_access_d(df)
  expected <- c(1, 0, 0, 0, NA, 1)
  expect_equal(result$edu_access_d, expected)
})

# Test with different yes and no values
test_that("add_edu_access_d works with different yes and no values", {
  df2 <- data.frame(
    edu_access = c("oui", "non", "pnta", "dnk", NA, "oui"),
    ind_age_5_18 = c(1, 1, 1, 1, 0, 1),
    stringsAsFactors = FALSE
  )
  result <- add_edu_access_d(df2, edu_access = "edu_access", yes = "oui", no = "non")
  expected <- c(1, 0, 0, 0, NA, 1)
  expect_equal(result$edu_access_d, expected)
})

# Test with custom undefined values
test_that("add_edu_access_d works with custom undefined values", {
  df3 <- data.frame(
    edu_access = c("yes", "no", "unknown", "dnk", NA, "yes"),
    ind_age_5_18 = c(1, 1, 1, 1, 0, 1),
    stringsAsFactors = FALSE
  )
  result <- add_edu_access_d(df3, undefined = c("unknown", "dnk"))
  expected <- c(1, 0, 0, 0, NA, 1)
  expect_equal(result$edu_access_d, expected)
})

# Test when schooling_age_dummy is 0
test_that("add_edu_access_d handles schooling_age_dummy = 0", {
  df4 <- data.frame(
    edu_access = c("yes", "no", "pnta", "dnk", NA, "yes"),
    ind_age_5_18 = c(0, 0, 0, 0, 0, 0),
    stringsAsFactors = FALSE
  )
  result <- add_edu_access_d(df4)
  expected <- rep(NA_integer_, nrow(df4))
  expect_equal(result$edu_access_d, expected)
})

# Test with missing column
test_that("add_edu_access_d handles missing column", {
  expect_error(add_edu_access_d(df, edu_access = "missing_col"))
})

# Test with non-numeric schooling_age_dummy
test_that("add_edu_access_d handles non-numeric schooling_age_dummy", {
  df5 <- data.frame(
    edu_access = c("yes", "no", "pnta", "dnk", NA, "yes"),
    ind_age_5_18 = c("yes", "no", "yes", "no", "yes", "no"),
    stringsAsFactors = FALSE
  )
  expect_error(add_edu_access_d(df5))
})

# Test with additional edge cases
test_that("add_edu_access_d handles additional edge cases", {
  df6 <- data.frame(
    edu_access = c("yes", "no", "maybe", "dnk", NA, "yes"),
    ind_age_5_18 = c(1, 1, 1, 1, 0, 1),
    stringsAsFactors = FALSE
  )
  result <- add_edu_access_d(df6, undefined = c("maybe", "dnk"))
  expected <- c(1, 0, 0, 0, NA, 1)
  expect_equal(result$edu_access_d, expected)
})
