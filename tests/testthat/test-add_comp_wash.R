# Load necessary libraries
library(testthat)
library(dplyr)

library(testthat)
library(dplyr)

# Create a sample dataset
df_sample <- tibble::tibble(
  setting = c("camp", "urban", "rural"),
  wash_drinking_water_quantity = c("always", "often", "rarely"),
  wash_drinking_water_quality_jmp_cat = c("surface_water", "unimproved", "limited"),
  wash_sanitation_facility_jmp_cat = c("open_defecation", "basic", "unimproved"),
  wash_sanitation_facility_cat = c("none", "improved", "unimproved"),
  wash_sharing_sanitation_facility_n_ind = c("50_and_above", "20_to_49", "19_and_below"),
  wash_sharing_sanitation_facility_cat = c("shared", "not_shared", "not_applicable"),
  wash_handwashing_facility_jmp_cat = c("no_facility", "basic", "limited")
)

# Test 1: Test drinking water quantity scores
test_that("Drinking water quantity scoring works correctly", {
  df_result <- add_comp_wash(df_sample, drinking_water_quantity = "wash_drinking_water_quantity", drinking_water_quantity_always = "always", drinking_water_quantity_often = "often", drinking_water_quantity_sometimes = "sometimes", drinking_water_quantity_rarely = "rarely", drinking_water_quantity_never = "never", drinking_water_quantity_dnk = "dnk", drinking_water_quantity_pnta = "pnta")

  expected_result <- c(5, 4, 2)  # Always -> 5, Often -> 4, Rarely -> 2

  expect_equal(df_result$comp_wash_score_water_quantity, expected_result)
})

# Test 2: Test drinking water quality scores based on setting
test_that("Drinking water quality scoring works based on setting", {
  df_result <- add_comp_wash(df_sample, setting = "setting", drinking_water_quality_jmp_cat = "wash_drinking_water_quality_jmp_cat", drinking_water_quality_jmp_cat_surface_water = "surface_water", drinking_water_quality_jmp_cat_unimproved = "unimproved", drinking_water_quality_jmp_cat_limited = "limited", drinking_water_quality_jmp_cat_basic = "basic", drinking_water_quality_jmp_cat_safely_managed = "safely_managed", drinking_water_quality_jmp_cat_undefined = "undefined")

  expected_result <- c(5, 3, 2)  # Surface water (camp) -> 5, Unimproved (urban) -> 3, Limited (rural) -> 2

  expect_equal(df_result$comp_wash_score_water_quality, expected_result)
})

# Test 3: Test sanitation score for different settings
test_that("Sanitation scoring works correctly for different settings", {
  df_result <- add_comp_wash(df_sample, setting = "setting", sanitation_facility_jmp_cat = "wash_sanitation_facility_jmp_cat", sanitation_facility_cat = "wash_sanitation_facility_cat", sanitation_facility_n_ind = "wash_sharing_sanitation_facility_n_ind", sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat")

  expected_result <- c(5, 1, 2)  # None (camp) -> 5, Improved & Shared (urban) -> 1, Unimproved (rural) -> 2

  expect_equal(df_result$comp_wash_score_sanitation, expected_result)
})

# Test 4: Test hygiene scoring for different settings
test_that("Hygiene scoring works correctly", {
  df_result <- add_comp_wash(df_sample, setting = "setting", handwashing_facility_jmp_cat = "wash_handwashing_facility_jmp_cat", handwashing_facility_jmp_cat_no_facility = "no_facility", handwashing_facility_jmp_cat_limited = "limited", handwashing_facility_jmp_cat_basic = "basic", handwashing_facility_jmp_cat_undefined = "undefined")

  expected_result <- c(3, 1, 2)  # No facility (camp) -> 3, Basic (urban) -> 1, Limited (rural) -> 2

  expect_equal(df_result$comp_wash_score_hygiene, expected_result)
})

# Test 5: Test final composite score calculation
test_that("Composite WASH score calculation works correctly", {
  df_result <- add_comp_wash(df_sample, setting = "setting", drinking_water_quantity = "wash_drinking_water_quantity", drinking_water_quality_jmp_cat = "wash_drinking_water_quality_jmp_cat", sanitation_facility_jmp_cat = "wash_sanitation_facility_jmp_cat", sanitation_facility_cat = "wash_sanitation_facility_cat", sanitation_facility_n_ind = "wash_sharing_sanitation_facility_n_ind", sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat", handwashing_facility_jmp_cat = "wash_handwashing_facility_jmp_cat")

  expected_result <- c(5, 4, 2)  # Max of (water quantity, water quality, sanitation, hygiene) for each row

  expect_equal(df_result$comp_wash_score, expected_result)
})

# Test 6: Test if 'is_in_need' and 'is_in_acute_need' flags are correctly set
test_that("Need flags work correctly", {
  df_result <- add_comp_wash(df_sample, setting = "setting", drinking_water_quantity = "wash_drinking_water_quantity", drinking_water_quality_jmp_cat = "wash_drinking_water_quality_jmp_cat", sanitation_facility_jmp_cat = "wash_sanitation_facility_jmp_cat", sanitation_facility_cat = "wash_sanitation_facility_cat", sanitation_facility_n_ind = "wash_sharing_sanitation_facility_n_ind", sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat", handwashing_facility_jmp_cat = "wash_handwashing_facility_jmp_cat")

  # Check for the 'comp_wash_in_need' and 'comp_wash_in_acute_need' columns.
  expect_true("comp_wash_in_need" %in% colnames(df_result))
  expect_true("comp_wash_in_acute_need" %in% colnames(df_result))
})


