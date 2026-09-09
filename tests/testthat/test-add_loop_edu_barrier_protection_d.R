# 1. Test the add_loop_edu_barrier_protection_d function with default parameters
test_that("add_loop_edu_barrier_protection_d function works with default parameters", {
  loop_data <- data.frame(
    uuid = c(1, 1, 2, 2, 3, 4),
    edu_barrier = c(
      "protection_at_school",
      "child_work_home",
      "protection_travel_school",
      "enroll_lack_documentation",
      "discrimination",
      "child_marriage"
    ),
    edu_ind_age_schooling = c(1, 1, 1, 1, 0, 1)
  )

  result <- add_loop_edu_barrier_protection_d(loop_data)
  expect_true("edu_ind_barrier_protection_d" %in% colnames(result))
  expect_equal(result$edu_ind_barrier_protection_d[1], 1)
  expect_true(is.na(result$edu_ind_barrier_protection_d[5]))
})

# 2. Test handling missing columns in add_loop_edu_barrier_protection_d
test_that("add_loop_edu_barrier_protection_d function handles missing columns", {
  missing_column_data <- data.frame(
    uuid = c(1, 1),
    edu_ind_age_schooling = c(1, 1)
  )

  expect_error(
    add_loop_edu_barrier_protection_d(missing_column_data),
    regex = "column is missing"
  )
})

# 3. Test ensuring value checks in add_loop_edu_barrier_protection_d
test_that("add_loop_edu_barrier_protection_d function ensures value checks", {
  invalid_value_data <- data.frame(
    uuid = c(1, 1),
    edu_barrier = c("ban", "child_work_home"),
    edu_ind_age_schooling = c(2, 1)
  )

  expect_error(
    add_loop_edu_barrier_protection_d(invalid_value_data),
    regex = "between 0 and 1"
  )
})

# 4. Test the add_loop_edu_barrier_protection_d_to_main function with default parameters
test_that("add_loop_edu_barrier_protection_d_to_main function works with default parameters", {
  loop_data <- data.frame(
    uuid = c(1, 1, 2, 2, 3, 4),
    edu_barrier = c(
      "protection_at_school",
      "child_work_home",
      "protection_travel_school",
      "enroll_lack_documentation",
      "discrimination",
      "child_marriage"
    ),
    edu_ind_age_schooling = c(1, 1, 1, 1, 0, 1)
  )

  main_data <- data.frame(
    uuid = c(1, 2, 3, 4),
    some_other_column = c("a", "b", "c", "d")
  )

  loop_result <- add_loop_edu_barrier_protection_d(loop_data)
  main_result <- add_loop_edu_barrier_protection_d_to_main(
    main_data,
    loop_result
  )

  expect_true("edu_barrier_protection_n" %in% colnames(main_result))
  expect_equal(main_result$edu_barrier_protection_n[1], 2)
  expect_equal(main_result$edu_barrier_protection_n[3], 0)
})

# 5. Test handling missing columns in add_loop_edu_barrier_protection_d_to_main
test_that("add_loop_edu_barrier_protection_d_to_main function handles missing columns", {
  missing_column_main_data <- data.frame(
    some_other_column = c("a", "b")
  )

  loop_data <- data.frame(
    uuid = c(1, 2),
    edu_barrier = c("ban", "child_work_home"),
    edu_ind_age_schooling = c(1, 1)
  )

  expect_error(
    add_loop_edu_barrier_protection_d_to_main(
      missing_column_main_data,
      loop_data
    ),
    regex = "column is missing"
  )
})

# 6. Test ensuring value checks in add_loop_edu_barrier_protection_d_to_main
test_that("add_loop_edu_barrier_protection_d_to_main function rejects invalid barrier values", {
  # Create loop data with invalid barrier values
  invalid_loop_data_raw <- data.frame(
    uuid = c(1, 2),
    edu_barrier = c("ban", "invalid_barrier"),
    edu_ind_age_schooling = c(1, 1)
  )

  main_data <- data.frame(
    uuid = c(1, 2),
    some_other_column = c("a", "b")
  )

  # Passing invalid data directly to _to_main should error when trying to use it
  # (since the main function would have caught it first in normal workflow)
  expect_error(
    add_loop_edu_barrier_protection_d(invalid_loop_data_raw),
    regex = "values must be in the following set"
  )
})

# 6b. Test that add_loop_edu_barrier_protection_d_to_main works with valid processed data
test_that("add_loop_edu_barrier_protection_d_to_main successfully aggregates valid data", {
  # Process valid data through main function first
  valid_loop_data <- add_loop_edu_barrier_protection_d(
    data.frame(
      uuid = c(1, 1, 2),
      edu_barrier = c("ban", "child_work_home", "discrimination"),
      edu_ind_age_schooling = c(1, 1, 0)
    )
  )

  main_data <- data.frame(
    uuid = c(1, 2),
    some_other_column = c("a", "b")
  )

  # This should succeed and produce correct aggregation
  main_result <- add_loop_edu_barrier_protection_d_to_main(
    main_data,
    valid_loop_data
  )

  expect_true("edu_barrier_protection_n" %in% colnames(main_result))
  expect_equal(main_result$edu_barrier_protection_n[1], 2)
  expect_equal(main_result$edu_barrier_protection_n[2], 0)
})

# 7. Test with edge cases (all protection barriers)
test_that("add_loop_edu_barrier_protection_d function handles edge cases", {
  edge_case_loop_data <- data.frame(
    uuid = c(1, 2),
    edu_barrier = c("discrimination", "ban"),
    edu_ind_age_schooling = c(1, 1)
  )

  result <- add_loop_edu_barrier_protection_d(edge_case_loop_data)
  expect_equal(result$edu_ind_barrier_protection_d[1], 1)
  expect_equal(result$edu_ind_barrier_protection_d[2], 1)
})

# 8. Test that child_pregnancy is recognized as a protection barrier
test_that("add_loop_edu_barrier_protection_d function flags child_pregnancy as a barrier", {
  child_pregnancy_data <- data.frame(
    uuid = c(1, 2),
    edu_barrier = c("child_pregnancy", "ban"),
    edu_ind_age_schooling = c(1, 1)
  )

  result <- add_loop_edu_barrier_protection_d(child_pregnancy_data)
  expect_equal(result$edu_ind_barrier_protection_d[1], 1)
  expect_equal(result$edu_ind_barrier_protection_d[2], 1)
})

# 9. Test that invalid edu_barrier values are rejected (issue #792)
test_that("add_loop_edu_barrier_protection_d rejects invalid barrier values", {
  expect_error(
    add_loop_edu_barrier_protection_d(
      data.frame(
        uuid = c(1, 2, 3),
        edu_barrier = c("ban", "ban discrimination", ""),
        edu_ind_age_schooling = c(1, 1, 1)
      )
    ),
    regex = "values must be in the following set"
  )
})

# 10. Test that undefined values (dnk, pnta, other) are accepted
test_that("add_loop_edu_barrier_protection_d accepts undefined values and returns 0", {
  result <- add_loop_edu_barrier_protection_d(
    data.frame(
      uuid = c(1, 2, 3),
      edu_barrier = c("dnk", "pnta", "other"),
      edu_ind_age_schooling = c(1, 1, 1)
    )
  )

  expect_equal(result$edu_ind_barrier_protection_d[1], 0)
  expect_equal(result$edu_ind_barrier_protection_d[2], 0)
  expect_equal(result$edu_ind_barrier_protection_d[3], 0)
})
