# tests/testthat/test-sanitation_facility_classification.R

library(testthat)
library(dplyr)


# Sample data for testing
df <- data.frame(
  wash_sanitation_facility = c("flush_piped_sewer", "flush_open_drain", "none", "other", "pit_latrine_wo_slab"),
  wash_sanitation_facility_sharing_yn = c("yes", "no", "dnk", "yes", "no"),
  wash_sanitation_facility_sharing_n = c(5, 1, 0, 10, 2),
  hh_size = c(4, 5, 3, 6, 4),
  weight = c(1.5, 2.0, 1.0, 2.5, 1.8),
  stringsAsFactors = FALSE
)

# Test add_sanitation_facility_cat function
test_that("add_sanitation_facility_cat works correctly", {
  result <- add_sanitation_facility_cat(df)
  expect_true("wash_sanitation_facility_cat" %in% colnames(result))
  expect_equal(result$wash_sanitation_facility_cat, c("improved", "unimproved", "none", "undefined", "unimproved"))
})

# Test add_sharing_sanitation_facility_cat function
test_that("add_sharing_sanitation_facility_cat works correctly", {
  result <- add_sharing_sanitation_facility_cat(df)
  expect_true("wash_sharing_sanitation_facility_cat" %in% colnames(result))
  expect_equal(result$wash_sharing_sanitation_facility_cat, c("shared", "not_shared", "undefined", "shared", "not_shared"))
})

# Test add_sharing_sanitation_facility_num_ind function
test_that("add_sharing_sanitation_facility_num_ind works correctly", {
  mean_hh_size <- stats::weighted.mean(df$hh_size, df$weight, na.rm = TRUE)
  df_test <- add_sanitation_facility_cat(df)
  df_test <- add_sharing_sanitation_facility_cat(df_test)
  result <- add_sharing_sanitation_facility_num_ind(df_test)
  expected_sharing_n <- (df$wash_sanitation_facility_sharing_n - 1) * mean_hh_size + df$hh_size
  # [2] and [4] Not shared so only hhsize
  expected_sharing_n[2] <- df$hh_size[2]
  expected_sharing_n[5] <- df$hh_size[5]
  # [3] Undefined so NA
  expected_sharing_n[3] <- NA
  expect_true("wash_sharing_sanitation_facility_n_ind" %in% colnames(result))
  expect_equal(result$wash_sanitation_facility_sharing_n, expected_sharing_n)
  expect_equal(result$wash_sharing_sanitation_facility_n_ind, c("19_and_below", "19_and_below", "19_and_below", "20_to_49", "19_and_below"))
})

# Test add_sanitation_facility_jmp_cat function
test_that("add_sanitation_facility_jmp_cat works correctly", {
  df <- add_sanitation_facility_cat(df)
  df <- add_sharing_sanitation_facility_cat(df)
  result <- add_sanitation_facility_jmp_cat(df)
  expect_true("wash_sanitation_facility_jmp_cat" %in% colnames(result))
  expect_equal(result$wash_sanitation_facility_jmp_cat, c("limited", "unimproved", "open_defecation", "undefined", "unimproved"))
})
