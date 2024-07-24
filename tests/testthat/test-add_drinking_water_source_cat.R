# Load required libraries
library(testthat)
library(dplyr)


# Create a dummy data frame for testing
dummy_data <- tibble(
  survey_modality = c("in_person", "remote", "in_person", "remote"),
  wash_handwashing_facility = c("available", "no_permission", "none", "other"),
  wash_handwashing_facility_observed_water = c("water_available", "water_not_available", "water_available", NA),
  wash_handwashing_facility_observed_soap = c("soap_available", "soap_not_available", "alternative_available", NA),
  wash_handwashing_facility_reported = c("fixed_dwelling", "none", "dnk", "other"),
  wash_soap_observed = c("yes_soap_shown", "no", "dnk", "yes_soap_not_shown"),
  wash_soap_observed_type = c("soap", "ash_mud_sand", "other", "detergent"),
  wash_soap_reported = c("yes", "no", "dnk", "yes"),
  wash_soap_reported_type = c("soap", "ash_mud_sand", "other", "detergent"),
  wash_drinking_water_source = c("piped_dwelling", "unprotected_well", "surface_water", "other"),
  wash_drinking_water_time_yn = c("water_on_premises", "number_minutes", "dnk", "pnta"),
  wash_drinking_water_time_int = c(NA, 45, 70, 20),
  wash_drinking_water_time_sl = c(NA, "under_30_min", "30min_1hr", "more_than_1hr")
)

test_that("Function runs with default parameters", {
  result <- add_handwashing_facility_cat(dummy_data)
  expect_true("wash_handwashing_facility_jmp_cat" %in% colnames(result))
})


test_that("Function handles missing values", {
  df_missing <- dummy_data
  df_missing$wash_handwashing_facility[1] <- NA
  result <- add_handwashing_facility_cat(df_missing)
  expect_true(any(is.na(result$wash_handwashing_facility_jmp_cat)))
})

test_that("Function handles missing columns", {
  df_missing_col <- dummy_data %>%
    select(-wash_handwashing_facility)
  expect_error(add_handwashing_facility_cat(df_missing_col), class = "error")
})

test_that("Drinking water source recoding with default parameters", {
  result <- add_drinking_water_source_cat(dummy_data)
  expect_true("wash_drinking_water_source_cat" %in% colnames(result))
})

test_that("Drinking water time recoding with default parameters", {
  result <- add_drinking_water_time_cat(dummy_data)
  expect_true("wash_drinking_water_time_cat" %in% colnames(result))
})

test_that("Drinking water quality recoding with default parameters", {
  df <- dummy_data %>%
    add_drinking_water_source_cat() %>%
    add_drinking_water_time_cat() %>%
    add_drinking_water_time_threshold_cat()
  result <- add_drinking_water_quality_jmp_cat(df)
  expect_true("wash_drinking_water_quality_jmp_cat" %in% colnames(result))
})

test_that("Function handles undefined drinking water source categories", {
  df_undefined <- dummy_data %>%
    mutate(wash_drinking_water_source = "other")
  result <- add_drinking_water_source_cat(df_undefined)
  expect_equal(unique(result$wash_drinking_water_source_cat), "undefined")
})

test_that("Function handles missing drinking water time values", {
  df_missing <- dummy_data %>%
    mutate(wash_drinking_water_time_int = NA)
  expect_error(result <- add_drinking_water_time_cat(df_missing))
})
