library(testthat)
library(dplyr)
library(rlang)

# Mock the helper functions if_not_in_stop and are_cols_numeric
if_not_in_stop <- function(df, cols, df_name) {
  missing_cols <- setdiff(cols, colnames(df))
  if (length(missing_cols) > 0) {
    stop(paste("The following columns are not present in", df_name, ":", paste(missing_cols, collapse = ", ")), call. = FALSE)
  }
}

are_cols_numeric <- function(df, col) {
  if (!is.numeric(df[[col]])) {
    stop(paste(col, "must be numeric"), call. = FALSE)
  }
}

are_values_in_set <- function(df, col, valid_values) {
  invalid_values <- setdiff(unique(df[[col]]), valid_values)
  if (length(invalid_values) > 0) {
    stop(paste("The following values in", col, "are not valid:", paste(invalid_values, collapse = ", ")), call. = FALSE)
  }
}

test_that("add_loop_age_dummy works with default parameters", {
  loop <- data.frame(
    ind_age = c(10, 15, 20, 5, 30)
  )

  result <- add_loop_age_dummy(loop)

  expected <- data.frame(
    ind_age = c(10, 15, 20, 5, 30),
    ind_age_5_18 = c(1, 1, 0, 1, 0)
  )

  expect_equal(result, expected)
})

test_that("add_loop_age_dummy works with specified age range", {
  loop <- data.frame(
    ind_age = c(10, 15, 20, 25, 30)
  )

  result <- add_loop_age_dummy(loop, lb = 15, ub = 25)

  expected <- data.frame(
    ind_age = c(10, 15, 20, 25, 30),
    ind_age_15_25 = c(0, 1, 1, 1, 0)
  )

  expect_equal(result, expected)
})

test_that("add_loop_age_gender_dummy works with default parameters", {
  loop <- data.frame(
    ind_age = c(10, 15, 20, 5, 30),
    ind_gender = c("female", "female", "male", "female", "male")
  )

  result <- add_loop_age_gender_dummy(loop)

  expected <- data.frame(
    ind_age = c(10, 15, 20, 5, 30),
    ind_gender = c("female", "female", "male", "female", "male"),
    ind_age_female_5_18 = c(1, 1, 0, 1, 0)
  )

  expect_equal(result, expected)
})

test_that("add_loop_age_gender_dummy works with specified gender", {
  loop <- data.frame(
    ind_age = c(10, 15, 20, 25, 30),
    ind_gender = c("female", "female", "male", "female", "male")
  )

  result <- add_loop_age_gender_dummy(loop, lb = 15, ub = 25, gender = "male")

  expected <- data.frame(
    ind_age = c(10, 15, 20, 25, 30),
    ind_gender = c("female", "female", "male", "female", "male"),
    ind_age_male_15_25 = c(0, 0, 1, 0, 0)
  )

  expect_equal(result, expected)
})

test_that("add_loop_age_dummy_to_main works with default parameters", {
  main <- data.frame(
    uuid = c(1, 2, 3)
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3, 3),
    ind_age_5_18 = c(1, 1, 0, 1, 1, 0)
  )

  result <- add_loop_age_dummy_to_main(main, loop)

  expected <- data.frame(
    uuid = c(1, 2, 3),
    ind_age_5_18_n = c(2, 0, 2)
  )

  expect_equal(result, expected)
})

test_that("add_loop_age_gender_dummy_to_main works with default parameters", {
  main <- data.frame(
    uuid = c(1, 2, 3)
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3, 3),
    ind_age_female_5_18 = c(1, 1, 0, 1, 1, 0)
  )

  result <- add_loop_age_gender_dummy_to_main(main, loop)

  expected <- data.frame(
    uuid = c(1, 2, 3),
    ind_age_female_5_18_n = c(2, 0, 2)
  )

  expect_equal(result, expected)
})

