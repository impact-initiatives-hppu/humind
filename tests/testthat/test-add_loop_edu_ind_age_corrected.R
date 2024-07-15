library(testthat)
library(dplyr)

# Dummy data for testing
dummy_loop_data <- data.frame(
  uuid = c(1, 1, 2, 2, 3, 4),
  ind_age = c(6, 8, 10, 12, 4, 18)
)

dummy_main_data <- data.frame(
  uuid = c(1, 2, 3, 4),
  start = as.Date(c("2021-09-01", "2021-09-01", "2021-09-01", "2021-09-01"))
)

# 1. Test the add_loop_edu_ind_age_corrected function with default parameters
test_that("add_loop_edu_ind_age_corrected function works with default parameters", {
  result <- add_loop_edu_ind_age_corrected(dummy_loop_data, dummy_main_data)
  expect_true(all(c("edu_ind_age_corrected", "edu_ind_schooling_age_d") %in% colnames(result)))
  expect_equal(result$edu_ind_age_corrected[1], 6)
  expect_equal(result$edu_ind_schooling_age_d[1], 1)
})

# 2. Test handling missing columns in add_loop_edu_ind_age_corrected
missing_column_data <- dummy_loop_data %>% select(-ind_age)

test_that("add_loop_edu_ind_age_corrected function handles missing columns", {
  expect_error(add_loop_edu_ind_age_corrected(missing_column_data, dummy_main_data))
})

# 3. Test ensuring numeric age column in add_loop_edu_ind_age_corrected
non_numeric_age_data <- dummy_loop_data
non_numeric_age_data$ind_age <- as.character(non_numeric_age_data$ind_age)

test_that("add_loop_edu_ind_age_corrected function ensures numeric age column", {
  expect_error(add_loop_edu_ind_age_corrected(non_numeric_age_data, dummy_main_data))
})

# 4. Test the add_loop_edu_ind_schooling_age_d_to_main function with default parameters
test_that("add_loop_edu_ind_schooling_age_d_to_main function works with default parameters", {
  corrected_loop <- add_loop_edu_ind_age_corrected(dummy_loop_data, dummy_main_data)
  main_result <- add_loop_edu_ind_schooling_age_d_to_main(dummy_main_data, corrected_loop)
  expect_true("edu_schooling_age_n" %in% colnames(main_result))
  expect_equal(main_result$edu_schooling_age_n[1], 2)
})

# 5. Test handling missing columns in add_loop_edu_ind_schooling_age_d_to_main
missing_column_main_data <- dummy_main_data %>% select(-uuid)

test_that("add_loop_edu_ind_schooling_age_d_to_main function handles missing columns", {
  expect_error(add_loop_edu_ind_schooling_age_d_to_main(missing_column_main_data, dummy_loop_data))
})

# 6. Test correct age adjustment
test_that("add_loop_edu_ind_age_corrected function adjusts ages correctly", {
  result <- add_loop_edu_ind_age_corrected(dummy_loop_data, dummy_main_data)
  expect_equal(result$edu_ind_age_corrected[2], 8)
  expect_equal(result$edu_ind_age_corrected[3], 10)
})

# 7. Test correct schooling age dummy variable creation
test_that("add_loop_edu_ind_age_corrected function creates correct schooling age dummy variable", {
  result <- add_loop_edu_ind_age_corrected(dummy_loop_data, dummy_main_data)
  expect_equal(result$edu_ind_schooling_age_d[5], 0)
  expect_equal(result$edu_ind_schooling_age_d[6], 0)
})

# 8. Test edge cases (e.g., age exactly on boundaries)
edge_case_loop_data <- data.frame(
  uuid = c(1, 2, 3, 4),
  ind_age = c(5, 17, 4, 18)
)

test_that("add_loop_edu_ind_age_corrected function handles edge cases", {
  result <- add_loop_edu_ind_age_corrected(edge_case_loop_data, dummy_main_data)
  expect_equal(result$edu_ind_age_corrected[1], 5)
  expect_equal(result$edu_ind_age_corrected[2], 17)
  expect_equal(result$edu_ind_schooling_age_d[1], 1)
  expect_equal(result$edu_ind_schooling_age_d[2], 1)
  expect_equal(result$edu_ind_age_corrected[3], NA_real_)
  expect_equal(result$edu_ind_schooling_age_d[3], 0)
})
