library(testthat)
library(dplyr)

# Create dummy data
df_dummy <- data.frame(
  health_ind_healthcare_needed_no_n = c(0, 1, 0, 1, 0),
  health_ind_healthcare_needed_yes_unmet_n = c(1, 0, 0, 0, 0),
  health_ind_healthcare_needed_yes_met_n = c(0, 0, 1, 0, 0),
  health_ind_healthcare_needed_no_wgq_dis_n = c(0, 0, 0, 0, 1),
  health_ind_healthcare_needed_yes_unmet_wgq_dis_n = c(0, 0, 0, 1, 0),
  health_ind_healthcare_needed_yes_met_wgq_dis_n = c(0, 1, 0, 0, 0)
)

#tests
test_that("add_comp_health function works correctly with default parameters", {
  result <- add_comp_health(df_dummy)
  expect_equal(result$comp_health_score, c(3, 1, 2, 1, NA))
  expect_equal(result$comp_health_in_need, c(TRUE, FALSE, TRUE, FALSE, NA))
})

test_that("add_comp_health function works correctly with wgq_dis = TRUE", {
  result <- add_comp_health(df_dummy, wgq_dis = TRUE)
  expect_equal(result$comp_health_score, c(3, 3, 2, 4, 2))
  expect_equal(result$comp_health_in_need, c(TRUE, TRUE, TRUE, TRUE, TRUE))
})

test_that("add_comp_health handles non-numeric values correctly", {
  df_test <- df_dummy
  df_test$health_ind_healthcare_needed_no_n[1] <- "non-numeric"
  expect_error(add_comp_health(df_test), class = "error")
})

test_that("add_comp_health handles NA values correctly", {
  df_test <- df_dummy
  df_test$health_ind_healthcare_needed_no_n[1] <- NA
  result <- add_comp_health(df_test)
  expect_true(is.na(result$comp_health_score[1]))
})

test_that("add_comp_health throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-health_ind_healthcare_needed_no_n)
  expect_error(add_comp_health(df_test), class = "error")
})

test_that("add_comp_health assigns in need status correctly", {
  result <- add_comp_health(df_dummy)
  expect_equal(result$comp_health_in_need, c(TRUE, FALSE, TRUE, FALSE, NA))
})
