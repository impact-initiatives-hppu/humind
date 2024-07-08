library(testthat)
library(dplyr)


# Create dummy data
df_dummy <- data.frame(
  wash_sanitation_facility = c("flush_piped_sewer", "bucket", "none", "other", NA),
  wash_sanitation_facility_sharing_yn = c("yes", "no", "dnk", "pnta", NA),
  wash_sanitation_facility_sharing_n = c(5, 2, 3, 4, NA),
  hh_size = c(5, 4, 3, 6, NA),
  weight = c(1, 1, 1, 1, 1),
  wash_drinking_water_source = c("protected_well", "unprotected_well", "surface_water", "dnk", NA),
  wash_drinking_water_time_yn = c("number_minutes", "water_on_premises", "dnk", "pnta", NA),
  wash_drinking_water_time_int = c(10, 0, 45, 60, NA),
  wash_drinking_water_time_sl = c("under_30_min", "premises", "dnk", "pnta", NA)
)

# Define tests
test_that("add_sanitation_facility_cat function works correctly with default parameters", {
  result <- add_sanitation_facility_cat(df_dummy)
  expect_equal(result$wash_sanitation_facility_cat, c("improved", "unimproved", "none", "undefined", NA))
})

test_that("add_sanitation_facility_cat handles undefined values correctly", {
  df_test <- df_dummy
  df_test$wash_sanitation_facility <- "dnk"
  result <- add_sanitation_facility_cat(df_test)
  expect_equal(result$wash_sanitation_facility_cat, rep("undefined", nrow(df_test)))
})

test_that("add_sanitation_facility_cat handles NA values correctly", {
  df_test <- df_dummy
  result <- add_sanitation_facility_cat(df_test)
  expect_true(is.na(result$wash_sanitation_facility_cat[5]))
})

test_that("add_sanitation_facility_cat throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-wash_sanitation_facility)
  expect_error(add_sanitation_facility_cat(df_test), class = "error")
})

test_that("add_sharing_sanitation_facility_cat function works correctly with default parameters", {
  result <- add_sharing_sanitation_facility_cat(df_dummy)
  expect_equal(result$wash_sharing_sanitation_facility_cat, c("shared", "not_shared", "undefined", "undefined", NA))
})

test_that("add_sharing_sanitation_facility_cat handles NA values correctly", {
  df_test <- df_dummy
  result <- add_sharing_sanitation_facility_cat(df_test)
  expect_true(is.na(result$wash_sharing_sanitation_facility_cat[5]))
})

test_that("add_sharing_sanitation_facility_cat throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-wash_sanitation_facility_sharing_yn)
  expect_error(add_sharing_sanitation_facility_cat(df_test))
})

test_that("add_sharing_sanitation_facility_num_ind function works correctly with default parameters", {
  df_test <- add_sharing_sanitation_facility_cat(df_dummy)
  result <- add_sharing_sanitation_facility_num_ind(df_test)
  expect_equal(result$wash_sharing_sanitation_facility_n_ind, c("19_and_below", "19_and_below", "19_and_below", "19_and_below", NA))
})

test_that("add_sharing_sanitation_facility_num_ind handles NA values correctly", {
  df_test <- add_sharing_sanitation_facility_cat(df_dummy)
  result <- add_sharing_sanitation_facility_num_ind(df_test)
  expect_true(is.na(result$wash_sharing_sanitation_facility_n_ind[5]))
})


test_that("add_sharing_sanitation_facility_num_ind throws error for missing columns", {
  df_test <- df_dummy
  expect_error(add_sharing_sanitation_facility_num_ind(df_test), "Missing columns")

  df_test <- add_sharing_sanitation_facility_cat(df_dummy)
  df_test <- df_test %>% select(-wash_sanitation_facility_sharing_n)
  expect_error(add_sharing_sanitation_facility_num_ind(df_test), class = "error")
})


test_that("add_sanitation_facility_jmp_cat function works correctly with default parameters", {
  df_test <- add_sanitation_facility_cat(df_dummy)
  df_test <- add_sharing_sanitation_facility_cat(df_test)
  result <- add_sanitation_facility_jmp_cat(df_test)
  expect_equal(result$wash_sanitation_facility_jmp_cat, c("limited", "unimproved", "open_defecation", "undefined", NA))
})

test_that("add_sanitation_facility_jmp_cat handles NA values correctly", {
  df_test <- df_dummy
  df_test <- add_sanitation_facility_cat(df_test)
  df_test <- add_sharing_sanitation_facility_cat(df_test)
  result <- add_sanitation_facility_jmp_cat(df_test)
  expect_true(is.na(result$wash_sanitation_facility_jmp_cat[5]))
})

test_that("add_sanitation_facility_jmp_cat throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-wash_sanitation_facility)
  expect_error(add_sanitation_facility_jmp_cat(df_test))
})

test_that("add_drinking_water_source_cat function works correctly with default parameters", {
  df_dummy$wash_drinking_water_time_int <- c(10, 1, 45, 60, NA)
  df_dummy$wash_drinking_water_time_sl <- c("under_30_min", "under_30_min", "more_than_1hr", "dnk", NA)
  result <- add_drinking_water_source_cat(df_dummy)
  expect_equal(result$wash_drinking_water_source_cat, c("improved", "unimproved", "surface_water", "undefined", NA))
})

test_that("add_drinking_water_source_cat handles undefined values correctly", {
  df_test <- df_dummy
  df_test$wash_drinking_water_source <- "dnk"
  result <- add_drinking_water_source_cat(df_test)
  expect_equal(result$wash_drinking_water_source_cat, rep("undefined", nrow(df_test)))
})

test_that("add_drinking_water_source_cat handles NA values correctly", {
  df_test <- df_dummy
  result <- add_drinking_water_source_cat(df_test)
  expect_true(is.na(result$wash_drinking_water_source_cat[5]))
})

test_that("add_drinking_water_source_cat throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-wash_drinking_water_source)
  expect_error(add_drinking_water_source_cat(df_test))
})

test_that("add_drinking_water_time_cat function works correctly with default parameters", {
  df_dummy$wash_drinking_water_time_int <- c(10, 1, 45, 60, NA)
  df_dummy$wash_drinking_water_time_sl <- c("under_30_min", "under_30_min", "more_than_1hr", "dnk", NA)
  result <- add_drinking_water_time_cat(df_dummy)
  expect_equal(result$wash_drinking_water_time_cat, c("under_30_min", "premises", "dnk", "undefined", NA))
})

test_that("add_drinking_water_time_cat handles NA values correctly", {
  df_dummy$wash_drinking_water_time_int <- c(10, 1, 45, 60, NA)
  df_dummy$wash_drinking_water_time_sl <- c("under_30_min", "under_30_min", "more_than_1hr", "dnk", NA)
  df_test <- df_dummy
  result <- add_drinking_water_time_cat(df_test)
  expect_true(is.na(result$wash_drinking_water_time_cat[5]))
})

test_that("add_drinking_water_time_cat throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-wash_drinking_water_time_yn)
  expect_error(add_drinking_water_time_cat(df_test))
})

test_that("add_drinking_water_time_threshold_cat function works correctly with default parameters", {
  df_dummy$wash_drinking_water_time_int <- c(10, 1, 45, 60, NA)
  df_dummy$wash_drinking_water_time_sl <- c("under_30_min", "under_30_min", "more_than_1hr", "dnk", NA)
  df_test <- add_drinking_water_time_cat(df_dummy)
  result <- add_drinking_water_time_threshold_cat(df_test)
  expect_equal(result$wash_drinking_water_time_30min_cat, c("under_30min", "premises", "under_30min", "undefined", NA))
})

test_that("add_drinking_water_time_threshold_cat handles NA values correctly", {
  df_dummy$wash_drinking_water_time_int <- c(10, 1, 45, 60, NA)
  df_dummy$wash_drinking_water_time_sl <- c("under_30_min", "under_30_min", "more_than_1hr", "dnk", NA)
  df_test <- df_dummy
  df_test <- add_drinking_water_time_cat(df_test)
  result <- add_drinking_water_time_threshold_cat(df_test)
  expect_true(is.na(result$wash_drinking_water_time_30min_cat[5]))
})

test_that("add_drinking_water_source_jmp_cat function works correctly with default parameters", {
  df_dummy$wash_drinking_water_time_int <- c(10, 1, 45, 60, NA)
  df_dummy$wash_drinking_water_time_sl <- c("under_30_min", "under_30_min", "more_than_1hr", "dnk", NA)
  df_test <- add_drinking_water_source_cat(df_dummy)
  df_test <- add_drinking_water_time_cat(df_test)
  df_test <- add_drinking_water_time_threshold_cat(df_test)
  result <- add_drinking_water_source_jmp_cat(df_test)
  expect_equal(result$wash_drinking_water_jmp_cat, c("safely_managed", "unimproved", "surface_water", "undefined", NA))
})

test_that("add_drinking_water_source_jmp_cat handles NA values correctly", {
  df_dummy$wash_drinking_water_time_int <- c(10, 1, 45, 60, NA)
  df_dummy$wash_drinking_water_time_sl <- c("under_30_min", "under_30_min", "more_than_1hr", "dnk", NA)
  df_test <- df_dummy
  df_test <- add_drinking_water_source_cat(df_test)
  df_test <- add_drinking_water_time_cat(df_test)
  df_test <- add_drinking_water_time_threshold_cat(df_test)
  result <- add_drinking_water_source_jmp_cat(df_test)
  expect_true(is.na(result$wash_drinking_water_jmp_cat[5]))
})

test_that("add_drinking_water_source_jmp_cat throws error for missing columns", {
  df_dummy$wash_drinking_water_time_int <- c(10, 1, 45, 60, NA)
  df_dummy$wash_drinking_water_time_sl <- c("under_30_min", "under_30_min", "more_than_1hr", "dnk", NA)
  df_test <- add_drinking_water_source_cat(df_dummy)
  df_test <- add_drinking_water_time_cat(df_test)
  df_test <- add_drinking_water_time_threshold_cat(df_test)
  df_test <- df_test %>% select(-wash_drinking_water_source_cat)
  expect_error(add_drinking_water_source_jmp_cat(df_test))
})

test_that("add_drinking_water_time_cat throws error for invalid time values", {
  df_invalid <- df_dummy
  df_invalid$wash_drinking_water_time_int <- c(10, 0, -5, 60, NA)
  expect_error(add_drinking_water_time_cat(df_invalid), class = "error")
})
