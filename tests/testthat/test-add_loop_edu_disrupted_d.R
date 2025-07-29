# Dummy data for testing
dummy_loop_data <- data.frame(
  uuid = c(1, 1, 2, 2, 3, 4),
  edu_disrupted_attack = c("yes", "no", "dnk", "pnta", "yes", "no"),
  edu_disrupted_hazards = c("no", "yes", "yes", "dnk", "pnta", "yes"),
  edu_disrupted_displaced = c("dnk", "pnta", "no", "yes", "no", "yes"),
  edu_disrupted_teacher = c("pnta", "dnk", "yes", "no", "yes", "no"),
  edu_ind_schooling_age_d = c(1, 1, 1, 1, 0, 1)
)

dummy_main_data <- data.frame(
  uuid = c(1, 2, 3, 4),
  some_other_column = c("a", "b", "c", "d")
)

# 1. Test the add_loop_edu_disrupted_d function with default parameters
test_that("add_loop_edu_disrupted_d function works with default parameters", {
  result <- add_loop_edu_disrupted_d(dummy_loop_data)
  expect_true(all(
    c(
      "edu_disrupted_attack_d",
      "edu_disrupted_hazards_d",
      "edu_disrupted_displaced_d",
      "edu_disrupted_teacher_d"
    ) %in%
      colnames(result)
  ))
  expect_equal(result$edu_disrupted_attack_d[1], 1)
  expect_equal(result$edu_disrupted_hazards_d[1], 0)
  expect_equal(result$edu_disrupted_displaced_d[1], NA_real_)
  expect_equal(result$edu_disrupted_teacher_d[1], NA_real_)
})

# 2. Test handling missing columns in add_loop_edu_disrupted_d
missing_column_data <- dummy_loop_data %>% select(-edu_disrupted_attack)

test_that("add_loop_edu_disrupted_d function handles missing columns", {
  expect_error(add_loop_edu_disrupted_d(missing_column_data))
})

# 3. Test ensuring value checks in add_loop_edu_disrupted_d
invalid_value_data <- dummy_loop_data
invalid_value_data$edu_ind_schooling_age_d <- 2

test_that("add_loop_edu_disrupted_d function ensures value checks", {
  expect_error(add_loop_edu_disrupted_d(invalid_value_data))
})

# 4. Test the add_loop_edu_disrupted_d_to_main function with default parameters
test_that("add_loop_edu_disrupted_d_to_main function works with default parameters", {
  loop_result <- add_loop_edu_disrupted_d(dummy_loop_data)
  main_result <- add_loop_edu_disrupted_d_to_main(dummy_main_data, loop_result)
  expect_true(all(
    c(
      "edu_disrupted_attack_n",
      "edu_disrupted_hazards_n",
      "edu_disrupted_displaced_n",
      "edu_disrupted_teacher_n"
    ) %in%
      colnames(main_result)
  ))
  expect_equal(main_result$edu_disrupted_attack_n[1], 1)
  expect_equal(main_result$edu_disrupted_hazards_n[1], 1)
  expect_equal(main_result$edu_disrupted_displaced_n[1], 0)
  expect_equal(main_result$edu_disrupted_teacher_n[1], 0)
})

# 5. Test handling missing columns in add_loop_edu_disrupted_d_to_main
missing_column_main_data <- dummy_main_data %>% select(-uuid)

test_that("add_loop_edu_disrupted_d_to_main function handles missing columns", {
  expect_error(add_loop_edu_disrupted_d_to_main(
    missing_column_main_data,
    dummy_loop_data
  ))
})

# 6. Test ensuring value checks in add_loop_edu_disrupted_d_to_main
test_that("add_loop_edu_disrupted_d_to_main function ensures value checks", {
  invalid_value_loop_data <- dummy_loop_data
  invalid_value_loop_data$edu_ind_schooling_age_d <- 2
  expect_error(loop_result <- add_loop_edu_disrupted_d(invalid_value_loop_data))

  invalid_value_loop_data <- add_loop_edu_disrupted_d(dummy_loop_data)
  invalid_value_loop_data$edu_disrupted_displaced_d <- 2
  expect_error(add_loop_edu_disrupted_d_to_main(
    dummy_main_data,
    invalid_value_loop_data
  ))
})

# 7. Test with edge cases (e.g., all zeros, all ones)
edge_case_loop_data <- data.frame(
  uuid = c(1, 2),
  edu_disrupted_attack = c("no", "no"),
  edu_disrupted_hazards = c("no", "no"),
  edu_disrupted_displaced = c("no", "no"),
  edu_disrupted_teacher = c("no", "no"),
  edu_ind_schooling_age_d = c(1, 1)
)

test_that("add_loop_edu_disrupted_d function handles edge cases", {
  result <- add_loop_edu_disrupted_d(edge_case_loop_data)
  expect_equal(result$edu_disrupted_attack_d, c(0, 0))
  expect_equal(result$edu_disrupted_hazards_d, c(0, 0))
  expect_equal(result$edu_disrupted_displaced_d, c(0, 0))
  expect_equal(result$edu_disrupted_teacher_d, c(0, 0))
})
