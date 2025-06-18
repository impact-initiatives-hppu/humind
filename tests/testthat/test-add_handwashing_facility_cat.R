library(testthat)
library(dplyr)

test_that("add_handwashing_facility_cat categorizes correctly", {
  test_df <- dplyr::tibble(
    survey_modality = c("in_person", "in_person", "in_person", "in_person", "remote", "remote", "in_person", "in_person"),
    wash_handwashing_facility = c(
      "available_fixed_in_dwelling",
      "available_fixed_in_plot",
      "available_fixed_in_plot",
      "none",
      "available_fixed_or_mobile",
      "none",
      "no_permission",
      "other"
    ),
    wash_handwashing_facility_observed_water = c(
      "water_available", "water_not_available", "water_available", "water_available", NA, NA, NA, "water_available"
    ),
    wash_soap_observed = c(
      "yes_soap_shown", "yes_soap_shown", "no", "yes_soap_shown", NA, NA, NA, "yes_soap_shown"
    ),
    wash_handwashing_facility_reported = c(
      NA, NA, NA, NA, "fixed_dwelling", "none", "mobile", "other"
    ),
    wash_handwashing_facility_water_reported = c(
      NA, NA, NA, NA, "yes", "no", "yes", "dnk"
    ),
    wash_soap_reported = c(
      NA, NA, NA, NA, "yes", "no", "yes", "dnk"
    )
  )
  expected <- c(
    "basic", "limited", "limited", "no_facility",
    "basic", "limited", "basic", "undefined"
  )
  result_df <- add_handwashing_facility_cat(test_df)
  expect_equal(result_df$wash_handwashing_facility_jmp_cat, expected)
})
