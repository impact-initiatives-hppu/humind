# Load required libraries
library(testthat)
library(dplyr)

# Create dummy data for testing
loop_data <- tibble(
  uuid = c("id1", "id2", "id3", "id4"),
  ind_age = c(10, 12, 18, 3)
)

main_data <- tibble(
  uuid = c("id1", "id2", "id3", "id4"),
  start = as.Date(c("2023-01-15", "2023-02-20", "2023-03-25", "2023-04-30"))
)

test_that("Function runs with default parameters", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  expect_true("edu_ind_age_corrected" %in% colnames(result))
  expect_true("edu_ind_schooling_age_d" %in% colnames(result))
})

test_that("Function handles specific month correctly", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data, month = 3)
  expect_true(all(result$month == 3))
})

test_that("Function handles school year start month correctly", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data, school_year_start_month = 1)
  expect_equal(result$edu_ind_age_corrected, c(10, 12, NA, NA))
})

test_that("Function handles missing age values", {
  loop_data_na <- loop_data
  loop_data_na$ind_age[1] <- NA
  result <- add_loop_edu_ind_age_corrected(loop_data_na, main_data)
  expect_true(any(is.na(result$edu_ind_age_corrected)))
})

test_that("Function handles missing columns", {
  loop_data_missing_col <- loop_data %>%
    select(-ind_age)
  expect_error(add_loop_edu_ind_age_corrected(loop_data_missing_col, main_data))
})

test_that("Function calculates schooling age dummy variable correctly", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  expect_equal(result$edu_ind_schooling_age_d, c(1, 1, 0, 0))
})

test_that("Function adds correct columns to main data frame", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  main_result <- add_loop_edu_ind_schooling_age_d_to_main(main_data, result)
  expect_true("edu_schooling_age_n" %in% colnames(main_result))
})

test_that("Function calculates number of school-age children correctly", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  main_result <- add_loop_edu_ind_schooling_age_d_to_main(main_data, result)
  expect_equal(main_result$edu_schooling_age_n, c(1, 1, 0, 0))
})

