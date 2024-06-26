library(testthat)
library(dplyr)
library(tidyr)
library(rlang)

# Mock the helper functions if_not_in_stop and are_values_in_set
if_not_in_stop <- function(df, cols, df_name) {
  missing_cols <- setdiff(cols, colnames(df))
  if (length(missing_cols) > 0) {
    stop(paste("The following columns are not present in", df_name, ":", paste(missing_cols, collapse = ", ")), call. = FALSE)
  }
}

are_values_in_set <- function(df, col, valid_values) {
  invalid_values <- setdiff(unique(df[[col]]), valid_values)
  if (length(invalid_values) > 0) {
    stop(paste("The following values in", col, "are not valid:", paste(invalid_values, collapse = ", ")), call. = FALSE)
  }
}

test_that("add_hoh_final works with default parameters", {
  df <- data.frame(
    resp_hoh_yn = c("yes", "no", "yes", "no", "yes"),
    hoh_gender = c("male", "female", "female", "male", "male"),
    hoh_age = c(45, 50, 60, 70, 30),
    resp_gender = c("female", "male", "male", "female", "female"),
    resp_age = c(40, 35, 55, 65, 25)
  )

  result <- add_hoh_final(df)

  expected <- data.frame(
    resp_hoh_yn = c("yes", "no", "yes", "no", "yes"),
    hoh_gender = c("female", "female", "male", "male", "female"),
    hoh_age = c(40, 50, 55, 70, 25),
    resp_gender = c("female", "male", "male", "female", "female"),
    resp_age = c(40, 35, 55, 65, 25)
  )

  expect_equal(result, expected)
})

test_that("add_hoh_final handles all yes and no values", {
  df <- data.frame(
    resp_hoh_yn = c("yes", "yes", "no", "no"),
    hoh_gender = c("male", "female", "male", "female"),
    hoh_age = c(45, 50, 60, 70),
    resp_gender = c("female", "female", "male", "male"),
    resp_age = c(40, 35, 55, 65)
  )

  result <- add_hoh_final(df)

  expected <- data.frame(
    resp_hoh_yn = c("yes", "yes", "no", "no"),
    hoh_gender = c("female", "female", "male", "female"),
    hoh_age = c(40, 35, 60, 70),
    resp_gender = c("female", "female", "male", "male"),
    resp_age = c(40, 35, 55, 65)
  )

  expect_equal(result, expected)
})

test_that("add_hoh_final handles NA values", {
  df <- data.frame(
    resp_hoh_yn = c("yes", "no", NA),
    hoh_gender = c("male", "female", "male"),
    hoh_age = c(45, 50, 60),
    resp_gender = c("female", "male", "female"),
    resp_age = c(40, 35, 55)
  )

  result <- add_hoh_final(df)

  expected <- data.frame(
    resp_hoh_yn = c("yes", "no", NA),
    hoh_gender = c("female", "female", NA),
    hoh_age = c(40, 50, NA),
    resp_gender = c("female", "male", "female"),
    resp_age = c(40, 35, 55)
  )

  expect_equal(result, expected)
})

test_that("add_hoh_final handles missing columns", {
  df <- data.frame(
    resp_hoh_yn = c("yes", "no", "yes")
  )

  expect_error(add_hoh_final(df), "Missing columns\n• The following columns are missing in `df`: hoh_gender, hoh_age, resp_gender, and resp_age")
})

test_that("add_hoh_final handles non-numeric age variables", {
  df <- data.frame(
    resp_hoh_yn = c("yes", "no", "yes"),
    hoh_gender = c("male", "female", "female"),
    hoh_age = c("45", "50", "60"),
    resp_gender = c("female", "male", "male"),
    resp_age = c("40", "35", "55")
  )

  result <- add_hoh_final(df)

  expected <- data.frame(
    resp_hoh_yn = c("yes", "no", "yes"),
    hoh_gender = c("female", "female", "male"),
    hoh_age = c(40, 50, 55),
    resp_gender = c("female", "male", "male"),
    resp_age = c(40, 35, 55)
  )

  expect_equal(result, expected)
})

