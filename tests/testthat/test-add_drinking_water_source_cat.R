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


#########################################
### add_drinking_water_source_cat
#########################################

test_that("add_drinking_water_source_cat returns expected column and covers all categories", {
  result <- add_drinking_water_source_cat(dummy_data)
  expect_true("wash_drinking_water_source_cat" %in% colnames(result))
  expect_setequal(
    unique(result$wash_drinking_water_source_cat),
    c("improved", "unimproved", "surface_water", "undefined")
  )
})

test_that("add_drinking_water_source_cat handles undefined drinking water source", {
  df_undefined <- dummy_data %>% mutate(wash_drinking_water_source = "other")
  result <- add_drinking_water_source_cat(df_undefined)
  expect_equal(unique(result$wash_drinking_water_source_cat), "undefined")
})


#########################################
### add_drinking_water_time_cat
#########################################

test_that("add_drinking_water_time_cat returns expected column", {
  result <- add_drinking_water_time_cat(dummy_data)
  expect_true("wash_drinking_water_time_cat" %in% colnames(result))
})

test_that("add_drinking_water_time_cat errors on invalid integer values", {
  df_invalid <- dummy_data
  df_invalid$wash_drinking_water_time_int[2] <- -5
  expect_error(add_drinking_water_time_cat(df_invalid), class = "error")
})


#########################################
### add_drinking_water_quality_jmp_cat
#########################################

test_that("add_drinking_water_quality_jmp_cat returns expected column", {
  df <- dummy_data %>%
    add_drinking_water_source_cat() %>%
    add_drinking_water_time_cat() %>%
    add_drinking_water_time_threshold_cat()
  result <- add_drinking_water_quality_jmp_cat(df)
  expect_true("wash_drinking_water_quality_jmp_cat" %in% colnames(result))
})


#########################################
### add_drinking_water_unimproved_no_treatment
#########################################

make_df_treatment <- function(source_cat = "improved", safer_yn = "yes") {
  dplyr::tibble(
    wash_drinking_water_source_cat = source_cat,
    wash_drinking_water_safer_yn = safer_yn
  )
}

test_that("add_drinking_water_unimproved_no_treatment adds expected column", {
  result <- add_drinking_water_unimproved_no_treatment(make_df_treatment())
  expect_true(
    "wash_drinking_water_unimproved_no_treatment_d" %in% colnames(result)
  )
})

test_that("output is integer type", {
  result <- add_drinking_water_unimproved_no_treatment(make_df_treatment())
  expect_type(result$wash_drinking_water_unimproved_no_treatment_d, "integer")
})

test_that("is 1L when source is unimproved and no treatment", {
  result <- add_drinking_water_unimproved_no_treatment(
    make_df_treatment(source_cat = "unimproved", safer_yn = "no")
  )
  expect_equal(result$wash_drinking_water_unimproved_no_treatment_d, 1L)
})

test_that("is 1L when source is surface_water and no treatment", {
  result <- add_drinking_water_unimproved_no_treatment(
    make_df_treatment(source_cat = "surface_water", safer_yn = "no")
  )
  expect_equal(result$wash_drinking_water_unimproved_no_treatment_d, 1L)
})

test_that("is 0L when source is improved regardless of treatment", {
  df <- dplyr::bind_rows(
    make_df_treatment(source_cat = "improved", safer_yn = "yes"),
    make_df_treatment(source_cat = "improved", safer_yn = "no")
  )
  result <- add_drinking_water_unimproved_no_treatment(df)
  expect_equal(result$wash_drinking_water_unimproved_no_treatment_d, c(0L, 0L))
})

test_that("is 0L when source is unimproved but household treats water", {
  result <- add_drinking_water_unimproved_no_treatment(
    make_df_treatment(source_cat = "unimproved", safer_yn = "yes")
  )
  expect_equal(result$wash_drinking_water_unimproved_no_treatment_d, 0L)
})

test_that("is NA when source category is undefined", {
  result <- add_drinking_water_unimproved_no_treatment(
    make_df_treatment(source_cat = "undefined", safer_yn = "no")
  )
  expect_true(is.na(result$wash_drinking_water_unimproved_no_treatment_d))
})

test_that("is NA when source category is NA", {
  result <- add_drinking_water_unimproved_no_treatment(
    make_df_treatment(source_cat = NA_character_, safer_yn = "no")
  )
  expect_true(is.na(result$wash_drinking_water_unimproved_no_treatment_d))
})

test_that("is NA when safer_yn is NA", {
  result <- add_drinking_water_unimproved_no_treatment(
    make_df_treatment(source_cat = "unimproved", safer_yn = NA_character_)
  )
  expect_true(is.na(result$wash_drinking_water_unimproved_no_treatment_d))
})

test_that("is NA when safer_yn is dnk or pnta (undefined)", {
  df <- dplyr::bind_rows(
    make_df_treatment(source_cat = "unimproved", safer_yn = "dnk"),
    make_df_treatment(source_cat = "unimproved", safer_yn = "pnta")
  )
  result <- add_drinking_water_unimproved_no_treatment(
    df,
    drinking_water_safer_undefined = c("dnk", "pnta")
  )
  expect_true(all(is.na(result$wash_drinking_water_unimproved_no_treatment_d)))
})

test_that("errors when drinking_water_source_cat column is missing", {
  df <- dplyr::tibble(wash_drinking_water_safer_yn = "no")
  expect_error(add_drinking_water_unimproved_no_treatment(df))
})

test_that("errors when drinking_water_safer_yn column is missing", {
  df <- dplyr::tibble(wash_drinking_water_source_cat = "unimproved")
  expect_error(add_drinking_water_unimproved_no_treatment(df))
})
