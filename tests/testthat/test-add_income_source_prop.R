library(testthat)
library(dplyr)
library(humind)

test_that("Correct column names are added to the output", {
  df <- data.frame(
    cm_income_source_salaried_n = c(100, 200),
    cm_income_source_casual_n = c(50, 100),
    cm_income_source_own_business_n = c(0, 50),
    cm_income_source_own_production_n = c(10, 20),
    cm_income_source_social_benefits_n = c(5, 10),
    cm_income_source_rent_n = c(15, 30),
    cm_income_source_remittances_n = c(25, 50),
    cm_income_source_assistance_n = c(0, 0),
    cm_income_source_support_friends_n = c(5, 10),
    cm_income_source_donation_n = c(0, 0),
    cm_income_source_other_n = c(5, 10)
  )

  result <- add_income_source_prop(df)

  expected_columns <- c(
    "cm_income_source_salaried_n", "cm_income_source_casual_n",
    "cm_income_source_own_business_n", "cm_income_source_own_production_n",
    "cm_income_source_social_benefits_n", "cm_income_source_rent_n",
    "cm_income_source_remittances_n", "cm_income_source_assistance_n",
    "cm_income_source_support_friends_n", "cm_income_source_donation_n",
    "cm_income_source_other_n", "cm_income_total",
    "cm_income_source_salaried_n_prop", "cm_income_source_casual_n_prop",
    "cm_income_source_own_business_n_prop", "cm_income_source_own_production_n_prop",
    "cm_income_source_social_benefits_n_prop", "cm_income_source_rent_n_prop",
    "cm_income_source_remittances_n_prop", "cm_income_source_assistance_n_prop",
    "cm_income_source_support_friends_n_prop", "cm_income_source_donation_n_prop",
    "cm_income_source_other_n_prop"
  )

  expect_equal(colnames(result), expected_columns)
})

#---------------------------------------------------------------------------------
test_that("Proportions are calculated correctly", {
  df <- data.frame(
    cm_income_source_salaried_n = c(100, 200),
    cm_income_source_casual_n = c(50, 100),
    cm_income_source_own_business_n = c(0, 50),
    cm_income_source_own_production_n = c(10, 20),
    cm_income_source_social_benefits_n = c(5, 10),
    cm_income_source_rent_n = c(15, 30),
    cm_income_source_remittances_n = c(25, 50),
    cm_income_source_assistance_n = c(0, 0),
    cm_income_source_support_friends_n = c(5, 10),
    cm_income_source_donation_n = c(0, 0),
    cm_income_source_other_n = c(5, 10)
  )

  result <- add_income_source_prop(df)

  expect_equal(result$cm_income_source_salaried_n_prop, df$cm_income_source_salaried_n / result$cm_income_total)
  expect_equal(result$cm_income_source_casual_n_prop, df$cm_income_source_casual_n / result$cm_income_total)
  expect_equal(result$cm_income_source_own_business_n_prop, df$cm_income_source_own_business_n / result$cm_income_total)
  expect_equal(result$cm_income_source_own_production_n_prop, df$cm_income_source_own_production_n / result$cm_income_total)
  expect_equal(result$cm_income_source_social_benefits_n_prop, df$cm_income_source_social_benefits_n / result$cm_income_total)
  expect_equal(result$cm_income_source_rent_n_prop, df$cm_income_source_rent_n / result$cm_income_total)
  expect_equal(result$cm_income_source_remittances_n_prop, df$cm_income_source_remittances_n / result$cm_income_total)
  expect_equal(result$cm_income_source_assistance_n_prop, df$cm_income_source_assistance_n / result$cm_income_total)
  expect_equal(result$cm_income_source_support_friends_n_prop, df$cm_income_source_support_friends_n / result$cm_income_total)
  expect_equal(result$cm_income_source_donation_n_prop, df$cm_income_source_donation_n / result$cm_income_total)
  expect_equal(result$cm_income_source_other_n_prop, df$cm_income_source_other_n / result$cm_income_total)
})
#---------------------------------------------------------------------------------
test_that("Handles zero total income correctly", {
  df <- data.frame(
    cm_income_source_salaried_n = c(0, 0),
    cm_income_source_casual_n = c(0, 0),
    cm_income_source_own_business_n = c(0, 0),
    cm_income_source_own_production_n = c(0, 0),
    cm_income_source_social_benefits_n = c(0, 0),
    cm_income_source_rent_n = c(0, 0),
    cm_income_source_remittances_n = c(0, 0),
    cm_income_source_assistance_n = c(0, 0),
    cm_income_source_support_friends_n = c(0, 0),
    cm_income_source_donation_n = c(0, 0),
    cm_income_source_other_n = c(0, 0)
  )

  result <- add_income_source_prop(df)

  expected_proportions <- rep(NA_real_, nrow(df))

  expect_equal(result$cm_income_source_salaried_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_casual_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_own_business_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_own_production_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_social_benefits_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_rent_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_remittances_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_assistance_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_support_friends_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_donation_n_prop, expected_proportions)
  expect_equal(result$cm_income_source_other_n_prop, expected_proportions)
})

#----------------------------------------------------------------------------------------
test_that("Throws an error if columns are missing", {
  df <- data.frame(
    cm_income_source_salaried_n = c(100, 200),
    cm_income_source_casual_n = c(50, 100),
    # Missing cm_income_source_own_business_n
    cm_income_source_own_production_n = c(10, 20),
    cm_income_source_social_benefits_n = c(5, 10),
    cm_income_source_rent_n = c(15, 30),
    cm_income_source_remittances_n = c(25, 50),
    cm_income_source_assistance_n = c(0, 0),
    cm_income_source_support_friends_n = c(5, 10),
    cm_income_source_donation_n = c(0, 0),
    cm_income_source_other_n = c(5, 10)
  )

  expect_error(add_income_source_prop(df), "df")
})

#----------------------------------------------------------------------------------------
test_that("Throws an error if columns are not numeric", {
  df <- data.frame(
    cm_income_source_salaried_n = c(100, 200),
    cm_income_source_casual_n = c(50, 100),
    cm_income_source_own_business_n = c("A", "B"), # Non-numeric column
    cm_income_source_own_production_n = c(10, 20),
    cm_income_source_social_benefits_n = c(5, 10),
    cm_income_source_rent_n = c(15, 30),
    cm_income_source_remittances_n = c(25, 50),
    cm_income_source_assistance_n = c(0, 0),
    cm_income_source_support_friends_n = c(5, 10),
    cm_income_source_donation_n = c(0, 0),
    cm_income_source_other_n = c(5, 10)
  )

  expect_error(add_income_source_prop(df), "numeric")
})

