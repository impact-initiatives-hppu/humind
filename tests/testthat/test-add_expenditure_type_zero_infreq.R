# Load required libraries
library(testthat)
library(dplyr)

# Create dummy data for testing
df <- tibble(
  cm_expenditure_frequent = c("no", "no", "no", "no", "no"),
  cm_expenditure_infrequent = c("shelter", "none", "dnk", "pnta", "education"),
  cm_expenditure_infrequent_shelter = c(500, 0, 0, 0, 0),
  cm_expenditure_infrequent_nfi = c(0, 0, 0, 0, 0),
  cm_expenditure_infrequent_health = c(0, 0, 0, 0, 0),
  cm_expenditure_infrequent_education = c(0, 0, 0, 0, 300),
  cm_expenditure_infrequent_debt = c(0, 0, 0, 0, 0),
  cm_expenditure_infrequent_clothing = c(0, 0, 0, 0, 0),
  cm_expenditure_infrequent_other = c(0, 0, 0, 0, 0)
)


test_that("Function runs with default parameters", {
  result <- add_expenditure_type_zero_infreq(df)
  expect_true(all(
    c(
      "cm_expenditure_infrequent_shelter",
      "cm_expenditure_infrequent_nfi",
      "cm_expenditure_infrequent_health",
      "cm_expenditure_infrequent_education",
      "cm_expenditure_infrequent_debt",
      "cm_expenditure_infrequent_clothing",
      "cm_expenditure_infrequent_other"
    ) %in%
      colnames(result)
  ))
})

test_that("Function runs with default parameters", {
  result <- add_expenditure_type_zero_infreq(df)
  expect_true(all(
    c(
      "cm_expenditure_infrequent_shelter",
      "cm_expenditure_infrequent_nfi",
      "cm_expenditure_infrequent_health",
      "cm_expenditure_infrequent_education",
      "cm_expenditure_infrequent_debt",
      "cm_expenditure_infrequent_clothing",
      "cm_expenditure_infrequent_other"
    ) %in%
      colnames(result)
  ))
})

test_that("Function handles 'none' correctly", {
  result <- add_expenditure_type_zero_infreq(df)
  expect_equal(result$cm_expenditure_infrequent_shelter[2], 0)
  expect_equal(result$cm_expenditure_infrequent_nfi[2], 0)
  expect_equal(result$cm_expenditure_infrequent_health[2], 0)
})

test_that("Function handles 'undefined' correctly", {
  result <- add_expenditure_type_zero_infreq(df)
  expect_equal(result$cm_expenditure_infrequent_shelter[3], 0)
  expect_equal(result$cm_expenditure_infrequent_shelter[4], 0)
  expect_equal(result$cm_expenditure_infrequent_nfi[3], 0)
  expect_equal(result$cm_expenditure_infrequent_nfi[4], 0)
})

test_that("Function handles existing values correctly", {
  result <- add_expenditure_type_zero_infreq(df)
  expect_equal(result$cm_expenditure_infrequent_shelter[1], 500)
  expect_equal(result$cm_expenditure_infrequent_education[5], 300)
})

test_that("Function handles missing columns", {
  df_missing_col <- df %>%
    select(-cm_expenditure_frequent, -cm_expenditure_infrequent_shelter)
  expect_error(add_expenditure_type_zero_infreq(df_missing_col))
})
