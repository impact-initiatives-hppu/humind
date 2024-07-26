# Load necessary libraries
library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data <- data.frame(
  setting = c("camp", "urban", "rural", NA),
  wash_drinking_water_quantity = c("always", "often", "sometimes", "rarely"),
  wash_drinking_water_quality_jmp_cat = c("safely_managed", "basic", "limited", "unimproved"),
  wash_sanitation_facility_jmp_cat = c("safely_managed", "basic", "limited", "open_defecation"),
  wash_sanitation_facility_cat = c("improved", "unimproved", "none", "undefined"),
  wash_sharing_sanitation_facility_n_ind = c("19_and_below", "20_to_49", "50_and_above", NA),
  wash_handwashing_facility_jmp_cat = c("basic", "limited", "no_facility", "undefined")
)

# 1. Test the function with default parameters
test_that("Function works with default parameters", {
  result <- add_comp_wash(dummy_data)
  expect_true("comp_wash_score" %in% colnames(result))
  expect_true("comp_wash_in_need" %in% colnames(result))
})

# 2. Test handling all values as undefined category
undefined_data <- data.frame(
  setting = rep("camp", 4),
  wash_drinking_water_quantity = rep("dnk", 4),
  wash_drinking_water_quality_jmp_cat = rep("undefined", 4),
  wash_sanitation_facility_jmp_cat = rep("undefined", 4),
  wash_sanitation_facility_cat = rep("undefined", 4),
  wash_sharing_sanitation_facility_n_ind = rep(NA, 4),
  wash_handwashing_facility_jmp_cat = rep("undefined", 4)
)

test_that("Function handles all undefined categories", {
  result <- add_comp_wash(undefined_data)
  expect_true(all(is.na(result$comp_wash_score)))
  expect_true(all(is.na(result$comp_wash_in_need)))
})

# 3. Test with sample data containing NA values
na_data <- data.frame(
  setting = c("camp", NA, "rural", "urban"),
  wash_drinking_water_quantity = c(NA, "often", "sometimes", NA),
  wash_drinking_water_quality_jmp_cat = c("safely_managed", NA, "limited", "unimproved"),
  wash_sanitation_facility_jmp_cat = c(NA, "basic", "limited", "open_defecation"),
  wash_sanitation_facility_cat = c("improved", NA, "none", "undefined"),
  wash_sharing_sanitation_facility_n_ind = c("19_and_below", "20_to_49", NA, "50_and_above"),
  wash_handwashing_facility_jmp_cat = c("basic", "limited", "no_facility", NA)
)

test_that("Function handles NA values in data", {
  result <- add_comp_wash(na_data)
  expect_true("comp_wash_score" %in% colnames(result))
  expect_true("comp_wash_in_need" %in% colnames(result))
})

# 4. Test handling missing columns
missing_column_data <- data.frame(
  setting = c("camp", "urban", "rural", "camp"),
  wash_drinking_water_quantity = c("always", "often", "sometimes", "rarely")
  # Intentionally omitting other necessary columns
)

test_that("Function handles missing columns", {
  expect_error(add_comp_wash(missing_column_data), class = "error")
})

# 5. Additional common scenarios
# Test with invalid levels
invalid_levels_data <- dummy_data
invalid_levels_data$setting <- c("invalid", "urban", "rural", "camp")

test_that("Function handles invalid levels", {
  expect_error(add_comp_wash(invalid_levels_data), class = "error")
})

# Test with duplicated column names
duplicated_column_data <- dummy_data
duplicated_column_data$wash_drinking_water_quantity <- duplicated_column_data$setting

test_that("Function handles duplicated column names", {
  expect_error(add_comp_wash(duplicated_column_data), class = "error")
})

# Test with empty data frame
empty_data <- data.frame()

test_that("Function handles empty data frame", {
  expect_error(add_comp_wash(empty_data), class = "error")
})
