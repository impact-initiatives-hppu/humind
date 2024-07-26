library(testthat)
library(dplyr)

# Dummy data for testing
dummy_loop_data <- data.frame(
  uuid = c(1, 1, 2, 2, 3, 4),
  edu_access = c("yes", "no", "yes", "pnta", "dnk", "no"),
  edu_ind_schooling_age_d = c(1, 1, 1, 1, 0, 1)
)

dummy_main_data <- data.frame(
  uuid = c(1, 2, 3, 4),
  some_other_column = c("a", "b", "c", "d")
)

# 1. Test the add_loop_edu_access_d function with default parameters
test_that("add_loop_edu_access_d function works with default parameters", {
  result <- add_loop_edu_access_d(dummy_loop_data)
  expect_true("edu_ind_access_d" %in% colnames(result))
  expect_true("edu_ind_no_access_d" %in% colnames(result))
  expect_equal(result$edu_ind_access_d[1], 1)
  expect_equal(result$edu_ind_access_d[2], 0)
  expect_equal(result$edu_ind_no_access_d[1], 0)
  expect_equal(result$edu_ind_no_access_d[2], 1)
})

# 2. Test handling missing columns in add_loop_edu_access_d
missing_column_data <- dummy_loop_data %>% select(-edu_access)

test_that("add_loop_edu_access_d function handles missing columns", {
  expect_error(add_loop_edu_access_d(missing_column_data))
})

# 3. Test ensuring value checks in add_loop_edu_access_d
invalid_value_data <- dummy_loop_data
invalid_value_data$edu_access <- "invalid"

test_that("add_loop_edu_access_d function ensures value checks", {
  expect_error(add_loop_edu_access_d(invalid_value_data))
})

# 4. Test the add_loop_edu_access_d_to_main function with default parameters
test_that("add_loop_edu_access_d_to_main function works with default parameters", {
  loop_result <- add_loop_edu_access_d(dummy_loop_data)
  main_result <- add_loop_edu_access_d_to_main(dummy_main_data, loop_result)
  expect_true("edu_access_n" %in% colnames(main_result))
  expect_true("edu_no_access_n" %in% colnames(main_result))
  expect_equal(main_result$edu_access_n[1], 1)
  expect_equal(main_result$edu_no_access_n[1], 1)
})

# 5. Test handling missing columns in add_loop_edu_access_d_to_main
missing_column_main_data <- dummy_main_data %>% select(-uuid)

test_that("add_loop_edu_access_d_to_main function handles missing columns", {
  expect_error(add_loop_edu_access_d_to_main(missing_column_main_data, dummy_loop_data))
})

# 6. Test ensuring value checks in add_loop_edu_access_d_to_main
invalid_value_loop_data <- dummy_loop_data
invalid_value_loop_data$edu_ind_schooling_age_d <- 2

test_that("add_loop_edu_access_d_to_main function ensures value checks", {
  expect_error(add_loop_edu_access_d(invalid_value_loop_data), calss = "error")
  expect_error(add_loop_edu_access_d_to_main(dummy_main_data, loop_result), class = "error")
})

# 7. Test with edge cases (e.g., all zeros, all ones)
edge_case_loop_data <- data.frame(
  uuid = c(1, 2),
  edu_access = c("yes", "no"),
  edu_ind_schooling_age_d = c(0, 1)
)

test_that("add_loop_edu_access_d function handles edge cases", {
  result <- add_loop_edu_access_d(edge_case_loop_data)
  expect_equal(result$edu_ind_access_d[1], NA_real_)
  expect_equal(result$edu_ind_no_access_d[1], NA_real_)
})

