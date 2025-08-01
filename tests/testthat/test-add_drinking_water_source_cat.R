# Create a comprehensive dummy data frame for testing
# Covers all possible options for drinking water source and handwashing facility

dummy_data <- dplyr::tibble(
  survey_modality = c("in_person", "remote", "in_person", "remote"),
  wash_handwashing_facility = c("available", "no_permission", "none", "other"),
  wash_handwashing_facility_observed_water = c(
    "water_available",
    "water_not_available",
    "water_available",
    NA
  ),
  wash_handwashing_facility_observed_soap = c(
    "soap_available",
    "soap_not_available",
    "alternative_available",
    NA
  ),
  wash_handwashing_facility_reported = c(
    "fixed_dwelling",
    "none",
    "dnk",
    "other"
  ),
  wash_handwashing_facility_water_reported = c(
    "water_available",
    "water_not_available",
    "dnk",
    "other"
  ),
  wash_handwashing_facility_soap_reported = c(
    "soap_available",
    "soap_not_available",
    "dnk",
    "other"
  ),
  wash_soap_observed = c("yes_soap_shown", "no", "dnk", "yes_soap_not_shown"),
  wash_soap_observed_type = c("soap", "ash_mud_sand", "other", "detergent"),
  wash_soap_reported = c("yes", "no", "dnk", "yes"),
  wash_soap_reported_type = c("soap", "ash_mud_sand", "other", "detergent"),
  wash_drinking_water_source = c(
    "piped_dwelling",
    "unprotected_well",
    "surface_water",
    "other"
  ),
  wash_drinking_water_time_yn = c(
    "water_on_premises",
    "number_minutes",
    "dnk",
    "pnta"
  ),
  wash_drinking_water_time_int = c(NA, 45, 70, 20),
  wash_drinking_water_time_sl = c(
    NA,
    "under_30_min",
    "30min_1hr",
    "more_than_1hr"
  )
)

# ---- Unit Tests ----

test_that("add_drinking_water_source_cat returns expected column and covers all categories", {
  result <- add_drinking_water_source_cat(dummy_data)
  expect_true("wash_drinking_water_source_cat" %in% colnames(result))
  expect_setequal(
    unique(result$wash_drinking_water_source_cat),
    c("improved", "unimproved", "surface_water", "undefined")
  )
})

test_that("add_drinking_water_time_cat returns expected column", {
  result <- add_drinking_water_time_cat(dummy_data)
  expect_true("wash_drinking_water_time_cat" %in% colnames(result))
})

test_that("add_drinking_water_quality_jmp_cat returns expected column", {
  df <- dummy_data %>%
    add_drinking_water_source_cat() %>%
    add_drinking_water_time_cat() %>%
    add_drinking_water_time_threshold_cat()
  result <- add_drinking_water_quality_jmp_cat(df)
  expect_true("wash_drinking_water_quality_jmp_cat" %in% colnames(result))
})

test_that("add_drinking_water_source_cat handles undefined drinking water source", {
  df_undefined <- dummy_data %>% mutate(wash_drinking_water_source = "other")
  result <- add_drinking_water_source_cat(df_undefined)
  expect_equal(unique(result$wash_drinking_water_source_cat), "undefined")
})

test_that("add_drinking_water_time_cat errors on invalid integer values", {
  df_invalid <- dummy_data
  df_invalid$wash_drinking_water_time_int[2] <- -5
  expect_error(add_drinking_water_time_cat(df_invalid), class = "error")
})
