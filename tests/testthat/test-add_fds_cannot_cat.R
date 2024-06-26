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

# Mock the sum_vars function
sum_vars <- function(df, new_colname, vars, na_rm, imputation) {
  df[[new_colname]] <- rowSums(df[vars], na.rm = na_rm)
  return(df)
}

test_that("add_fds_cannot_cat works with default parameters", {
  df <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "pnta", "dnk"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "pnta"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "dnk"),
    energy_lighting_source = c("none", "other", "candle", "pnta", "dnk")
  )

  result <- add_fds_cannot_cat(df)

  expected <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "pnta", "dnk"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "pnta"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "dnk"),
    energy_lighting_source = c("none", "other", "candle", "pnta", "dnk"),
    snfi_fds_cooking_d = c(1, 0, 0, 0, NA),
    snfi_fds_sleeping_d = c(0, 1, 0, NA, NA),
    snfi_fds_storing_d = c(1, 1, 0, 0, NA),
    snfi_fds_personal_hygiene_d = c(0, 0, 1, 1, NA),
    energy_lighting_source_d = c(0, NA, 1, NA, NA),
    snfi_fds_cannot_n = c(2, 2, 1, 1, 0),
    snfi_fds_cannot_cat = c("2_to_3_tasks", "2_to_3_tasks", "1_task", "1_task", "none")
  )

  expect_equal(result, expected)
})

test_that("add_fds_cannot_cat handles all undefined values", {
  df <- data.frame(
    snfi_fds_cooking = c("pnta", "dnk", "pnta", "dnk"),
    snfi_fds_sleeping = c("pnta", "dnk", "pnta", "dnk"),
    snfi_fds_storing = c("pnta", "dnk", "pnta", "dnk"),
    snfi_fds_personal_hygiene = c("pnta", "dnk", "pnta", "dnk"),
    energy_lighting_source = c("pnta", "dnk", "pnta", "dnk")
  )

  result <- add_fds_cannot_cat(df)

  expected <- data.frame(
    snfi_fds_cooking = c("pnta", "dnk", "pnta", "dnk"),
    snfi_fds_sleeping = c("pnta", "dnk", "pnta", "dnk"),
    snfi_fds_storing = c("pnta", "dnk", "pnta", "dnk"),
    snfi_fds_personal_hygiene = c("pnta", "dnk", "pnta", "dnk"),
    energy_lighting_source = c("pnta", "dnk", "pnta", "dnk"),
    snfi_fds_cooking_d = c(NA, NA, NA, NA),
    snfi_fds_sleeping_d = c(NA, NA, NA, NA),
    snfi_fds_storing_d = c(NA, NA, NA, NA),
    snfi_fds_personal_hygiene_d = c(NA, NA, NA, NA),
    energy_lighting_source_d = c(NA, NA, NA, NA),
    snfi_fds_cannot_n = c(0, 0, 0, 0),
    snfi_fds_cannot_cat = c("none", "none", "none", "none")
  )

  expect_equal(result, expected)
})

test_that("add_fds_cannot_cat handles missing columns", {
  df <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta")
  )

  expect_error(add_fds_cannot_cat(df), "Missing columns\n• The following columns are missing in `df`: snfi_fds_sleeping, snfi_fds_storing, and snfi_fds_personal_hygiene")
})

test_that("add_fds_cannot_cat handles non-numeric variables", {
  df <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "pnta", "dnk"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "pnta"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "dnk"),
    energy_lighting_source = c("none", "other", "candle", "pnta", "dnk")
  )

  result <- add_fds_cannot_cat(df)

  expected <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "pnta", "dnk"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "pnta"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "dnk"),
    energy_lighting_source = c("none", "other", "candle", "pnta", "dnk"),
    snfi_fds_cooking_d = c(1, 0, 0, 0, NA),
    snfi_fds_sleeping_d = c(0, 1, 0, NA, NA),
    snfi_fds_storing_d = c(1, 1, 0, 0, NA),
    snfi_fds_personal_hygiene_d = c(0, 0, 1, 1, NA),
    energy_lighting_source_d = c(0, NA, 1, NA, NA),
    snfi_fds_cannot_n = c(2, 2, 1, 1, 0),
    snfi_fds_cannot_cat = c("2_to_3_tasks", "2_to_3_tasks", "1_task", "1_task", "none")
  )

  expect_equal(result, expected)
})
