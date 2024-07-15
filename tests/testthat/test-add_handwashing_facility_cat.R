library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data <- data.frame(
  uuid = 1:6,
  survey_modality = c("in_person", "in_person", "remote", "remote", "in_person", "remote"),
  wash_handwashing_facility = c("available", "none", "no_permission", "available", "available", "no_permission"),
  wash_handwashing_facility_reported = c(NA, NA, "fixed_dwelling", "fixed_yard", NA, "none"),
  wash_handwashing_facility_observed_soap = c("soap_available", "soap_not_available", NA, "alternative_available", "soap_available", NA),
  wash_handwashing_facility_observed_water = c("water_available", "water_not_available", NA, "water_available", "water_available", NA)
)

# 1. Test the function with default parameters for in-person surveys
test_that("add_handwashing_facility_cat function works with default parameters for in-person surveys", {
  result <- add_handwashing_facility_cat(dummy_data)
  expect_true(all(c("wash_handwashing_facility_yn", "wash_soap_yn", "wash_handwashing_facility_jmp_cat") %in% colnames(result)))
  expect_equal(result$wash_handwashing_facility_yn[1], 1)
  expect_equal(result$wash_handwashing_facility_yn[2], 0)
  expect_equal(result$wash_soap_yn[1], 1)
  expect_equal(result$wash_soap_yn[2], 0)
  expect_equal(result$wash_handwashing_facility_jmp_cat[1], "basic")
  expect_equal(result$wash_handwashing_facility_jmp_cat[2], "no_facility")
})

# 2. Test the function with default parameters for remote surveys
test_that("add_handwashing_facility_cat function works with default parameters for remote surveys", {
  result <- add_handwashing_facility_cat(dummy_data)
  expect_equal(result$wash_handwashing_facility_yn[3], 1)
  expect_equal(result$wash_handwashing_facility_yn[4], 1)
  expect_equal(result$wash_handwashing_facility_yn[6], 0)
  expect_equal(result$wash_soap_yn[4], 0)
  expect_equal(result$wash_handwashing_facility_jmp_cat[4], "limited")
  expect_equal(result$wash_handwashing_facility_jmp_cat[6], "no_facility")
})

# 3. Test handling of missing columns
missing_column_data <- dummy_data %>% select(-wash_handwashing_facility)

test_that("add_handwashing_facility_cat function handles missing columns", {
  expect_error(add_handwashing_facility_cat(missing_column_data))
})

# 4. Test correct categorization of handwashing facility status
test_that("add_handwashing_facility_cat function categorizes handwashing facility status correctly", {
  result <- add_handwashing_facility_cat(dummy_data)
  expect_equal(result$wash_handwashing_facility_jmp_cat[5], "basic")
})

# 5. Test edge cases for facility options and reported facility options
edge_case_data <- data.frame(
  uuid = 7:10,
  survey_modality = c("in_person", "remote", "in_person", "remote"),
  wash_handwashing_facility = c("available", "no_permission", "none", "no_permission"),
  wash_handwashing_facility_reported = c(NA, "fixed_dwelling", NA, "none"),
  wash_handwashing_facility_observed_soap = c("soap_available", NA, "soap_not_available", NA),
  wash_handwashing_facility_observed_water = c("water_not_available", NA, "water_available", NA)
)

test_that("add_handwashing_facility_cat function handles edge cases for facility options and reported facility options", {
  result <- add_handwashing_facility_cat(edge_case_data)
  expect_equal(result$wash_handwashing_facility_jmp_cat[1], "limited")
  expect_equal(result$wash_handwashing_facility_jmp_cat[2], "basic")
  expect_equal(result$wash_handwashing_facility_jmp_cat[3], "no_facility")
  expect_equal(result$wash_handwashing_facility_jmp_cat[4], "no_facility")
})

# 6. Test correct handling of alternative soap availability
alternative_soap_data <- data.frame(
  uuid = 11:12,
  survey_modality = c("in_person", "remote"),
  wash_handwashing_facility = c("available", "no_permission"),
  wash_handwashing_facility_reported = c(NA, "fixed_dwelling"),
  wash_handwashing_facility_observed_soap = c("alternative_available", NA),
  wash_handwashing_facility_observed_water = c("water_available", NA)
)

test_that("add_handwashing_facility_cat function handles alternative soap availability correctly", {
  result <- add_handwashing_facility_cat(alternative_soap_data)
  expect_equal(result$wash_handwashing_facility_jmp_cat[1], "limited")
  expect_equal(result$wash_handwashing_facility_jmp_cat[2], "basic")
})
