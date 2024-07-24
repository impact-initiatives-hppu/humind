library(testthat)
library(dplyr)

# Sample data for testing
df <- data.frame(
  snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta"),
  snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "pnta", "dnk"),
  snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "pnta"),
  snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "dnk"),
  energy_lighting_source = c("none", "other", "candle", "pnta", "dnk")
)

test_that("add_fds_cannot_cat works with default parameters", {
  result <- add_fds_cannot_cat(df)

  expected <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "undefined"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "undefined", "undefined"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "undefined"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "undefined"),
    energy_lighting_source = c("none", "other", "candle", "undefined", "undefined"),
    snfi_fds_cooking_d = c(1, 0, 0, 0, NA),
    snfi_fds_sleeping_d = c(0, 1, 0, NA, NA),
    snfi_fds_storing_d = c(1, 1, 0, 0, NA),
    snfi_fds_personal_hygiene_d = c(0, 0, 1, 1, NA),
    energy_lighting_source_d = c(1, 0, 0, NA, NA),
    snfi_fds_cannot_n = c(3, 2, 1, NA, NA),
    snfi_fds_cannot_cat = c("2_to_3_tasks", "2_to_3_tasks", "1_task", NA, NA)
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
    snfi_fds_cooking = c("undefined", "undefined", "undefined", "undefined"),
    snfi_fds_sleeping = c("undefined", "undefined", "undefined", "undefined"),
    snfi_fds_storing = c("undefined", "undefined", "undefined", "undefined"),
    snfi_fds_personal_hygiene = c("undefined", "undefined", "undefined", "undefined"),
    energy_lighting_source = c("undefined", "undefined", "undefined", "undefined"),
    snfi_fds_cooking_d = c(NA, NA, NA, NA),
    snfi_fds_sleeping_d = c(NA, NA, NA, NA),
    snfi_fds_storing_d = c(NA, NA, NA, NA),
    snfi_fds_personal_hygiene_d = c(NA, NA, NA, NA),
    energy_lighting_source_d = c(NA, NA, NA, NA),
    snfi_fds_cannot_n = c(NA, NA, NA, NA),
    snfi_fds_cannot_cat = c(NA, NA, NA, NA)
  )

  expect_equal(result, expected)
})

test_that("add_fds_cannot_cat handles missing columns", {
  df <- data.frame(
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "pnta")
  )

  expect_error(add_fds_cannot_cat(df), class = "error")
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
    snfi_fds_cooking = c("no_cannot", "yes_issues", "yes_no_issues", "no_no_need", "undefined"),
    snfi_fds_sleeping = c("yes_no_issues", "no_cannot", "yes_issues", "undefined", "undefined"),
    snfi_fds_storing = c("no_cannot", "no_cannot", "yes_no_issues", "yes_issues", "undefined"),
    snfi_fds_personal_hygiene = c("yes_issues", "yes_issues", "no_cannot", "no_cannot", "undefined"),
    energy_lighting_source = c("none", "other", "candle", "undefined", "undefined"),
    snfi_fds_cooking_d = c(1, 0, 0, 0, NA),
    snfi_fds_sleeping_d = c(0, 1, 0, NA, NA),
    snfi_fds_storing_d = c(1, 1, 0, 0, NA),
    snfi_fds_personal_hygiene_d = c(0, 0, 1, 1, NA),
    energy_lighting_source_d = c(1, 0, 0, NA, NA),
    snfi_fds_cannot_n = c(3, 2, 1, NA, NA),
    snfi_fds_cannot_cat = c("2_to_3_tasks", "2_to_3_tasks", "1_task", NA, NA)
  )

  expect_equal(result, expected)
})
