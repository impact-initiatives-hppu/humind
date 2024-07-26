library(testthat)
library(dplyr)

# Helper function to create a test data frame
create_test_df <- function() {
  data.frame(
    survey_modality = c("in_person", "remote", "in_person", "in_person", "in_person", "remote"),
    wash_handwashing_facility = c("available", "no_permission", "none", "other", "available", "no_permission"),
    wash_handwashing_facility_observed_water = c("water_available", NA, NA, NA, "water_not_available", NA),
    wash_handwashing_facility_observed_soap = c("soap_available", NA, NA, NA, "soap_not_available", NA),
    wash_handwashing_facility_reported = c(NA, "fixed_dwelling", NA, NA, NA, "none"),
    wash_soap_observed = c(NA, "yes_soap_shown", NA, NA, NA, "no"),
    wash_soap_observed_type = c(NA, "soap", NA, NA, NA, "ash_mud_sand"),
    wash_soap_reported = c(NA, NA, NA, NA, NA, "no"),
    wash_soap_reported_type = c(NA, NA, NA, NA, NA, "ash_mud_sand")
  )
}

# Test the function with default parameters using a dummy data
test_that("Function works with default parameters and dummy data", {
  df <- create_test_df()
  result <- add_handwashing_facility_cat(df)

  expect_equal(nrow(result), 6)
  expect_true("wash_handwashing_facility_jmp_cat" %in% colnames(result))
})

# Test the function handling all values as undefined category
test_that("Function handles all values as undefined category", {
  df <-   data.frame(
    survey_modality = c("in_person", "remote", "in_person", "in_person", "in_person", "remote"),
    wash_handwashing_facility = c("other", "other", "other", "other", "other", "other"),
    wash_handwashing_facility_observed_water = c("water_available", NA, NA, NA, "water_not_available", NA),
    wash_handwashing_facility_observed_soap = c("soap_available", NA, NA, NA, "soap_not_available", NA),
    wash_handwashing_facility_reported = c("other", "other", "other", "other", "other", "other"),
    wash_soap_observed = c(NA, "yes_soap_shown", NA, NA, NA, "no"),
    wash_soap_observed_type = c(NA, "soap", NA, NA, NA, "ash_mud_sand"),
    wash_soap_reported = c(NA, NA, NA, NA, NA, "no"),
    wash_soap_reported_type = c(NA, NA, NA, NA, NA, "ash_mud_sand")
  )
  result <- add_handwashing_facility_cat(df)

  expect_equal(result$wash_handwashing_facility_jmp_cat, rep("undefined", 6))
})

# Test with sample data containing NA values
test_that("Function handles NA values correctly", {
  df <- create_test_df()
  result <- add_handwashing_facility_cat(df)

  expect_equal(result$wash_handwashing_facility_jmp_cat, c("basic", "limited", "no_facility", "undefined", "limited", "no_facility"))
})

# Test missing values or columns
test_that("Function handles missing values or columns", {
  df <- create_test_df() %>%
    select(-wash_handwashing_facility_observed_water)

  expect_error(add_handwashing_facility_cat(df))
})

# Test function with modified parameters
test_that("Function works with modified parameters", {
  df <- create_test_df()
  result <- add_handwashing_facility_cat(df, survey_modality = "survey_modality", facility = "wash_handwashing_facility", facility_yes = "available")

  expect_equal(result$wash_handwashing_facility_jmp_cat, c("basic", "limited", "no_facility", "undefined", "limited", "no_facility"))
})

# Test all possible categories
test_that("Function correctly assigns categories for all scenarios", {
  df <- data.frame(
    survey_modality = c("in_person", "in_person", "in_person", "in_person", "remote", "remote"),
    wash_handwashing_facility = c("available", "available", "none", "other", "no_permission", "no_permission"),
    wash_handwashing_facility_observed_water = c("water_available", "water_not_available", NA, NA, NA, NA),
    wash_handwashing_facility_observed_soap = c("soap_available", "soap_not_available", NA, NA, NA, NA),
    wash_handwashing_facility_reported = c(NA, NA, NA, NA, "fixed_dwelling", "none"),
    wash_soap_observed = c(NA, NA, NA, NA, "yes_soap_shown", "no"),
    wash_soap_observed_type = c(NA, NA, NA, NA, "soap", "ash_mud_sand"),
    wash_soap_reported = c(NA, NA, NA, NA, "yes", "no"),
    wash_soap_reported_type = c(NA, NA, NA, NA, "soap", "ash_mud_sand")
  )

  result <- add_handwashing_facility_cat(df)

  expect_equal(result$wash_handwashing_facility_jmp_cat, c("basic", "limited", "no_facility", "undefined", "limited", "no_facility"))
})

# Additional common scenarios
test_that("Function correctly processes edge cases", {
  df <- data.frame(
    survey_modality = c("in_person", "remote"),
    wash_handwashing_facility = c("available", "no_permission"),
    wash_handwashing_facility_observed_water = c("water_available", NA),
    wash_handwashing_facility_observed_soap = c("alternative_available", NA),
    wash_handwashing_facility_reported = c(NA, "fixed_dwelling"),
    wash_soap_observed = c(NA, "yes_soap_shown"),
    wash_soap_observed_type = c(NA, "soap"),
    wash_soap_reported = c(NA, "yes"),
    wash_soap_reported_type = c(NA, "soap")
  )

  result <- add_handwashing_facility_cat(df)

  expect_equal(result$wash_handwashing_facility_jmp_cat, c("limited", "limited"))
})
