# Dummy data for testing
dummy_data <- data.frame(
  edu_schooling_age_n = c(0, 10, 5, 7, 0, 2),
  edu_no_access_n = c(0, 1, 0, 2, 0, 0),
  edu_barrier_protection_n = c(0, 1, 0, 0, 0, 0),
  edu_disrupted_attack_n = c(0, 0, 1, 0, 0, 0),
  edu_disrupted_hazards_n = c(0, 1, 0, 0, 0, 0),
  edu_disrupted_displaced_n = c(0, 1, 0, 2, 0, 0),
  edu_disrupted_teacher_n = c(0, 0, 0, 0, 0, 1)
)


# 1. Test the function with default parameters
test_that("Function works with default parameters", {
  result <- add_comp_edu(dummy_data)
  expect_true("comp_edu_score_disrupted" %in% colnames(result))
  expect_true("comp_edu_score_attendance" %in% colnames(result))
  expect_true("comp_edu_score" %in% colnames(result))
  expect_true("comp_edu_in_need" %in% colnames(result))
  expect_true("comp_edu_in_severe_need" %in% colnames(result))
})

# 2. Test handling missing columns
missing_column_data <- dummy_data %>% select(-edu_no_access_n)

test_that("Function handles missing columns", {
  expect_error(add_comp_edu(missing_column_data))
})

# 3. Test ensuring numeric checks
non_numeric_data <- dummy_data
non_numeric_data$edu_no_access_n <- as.character(
  non_numeric_data$edu_no_access_n
)

test_that("Function ensures numeric checks", {
  expect_error(add_comp_edu(non_numeric_data))
})

# 4. Test correctness of computed scores
test_that("Function computes correct scores", {
  result <- add_comp_edu(dummy_data)

  # Check comp_edu_score_disrupted
  expect_equal(result$comp_edu_score_disrupted, c(1, 3, 4, 3, 1, 2))

  # Check comp_edu_score_attendance
  expect_equal(result$comp_edu_score_attendance, c(1, 4, 1, 3, 1, 1))

  # Check comp_edu_score
  expect_equal(result$comp_edu_score, c(1, 4, 4, 3, 1, 2))

  # Check comp_edu_in_need
  expect_equal(result$comp_edu_in_need, c(0, 1, 1, 1, 0, 0))

  # Check comp_edu_in_severe_need
  expect_equal(result$comp_edu_in_severe, c(0, 1, 1, 0, 0, 0))
})


# 5. Test with edge cases (e.g., all zeros, all ones)
edge_case_data <- data.frame(
  edu_schooling_age_n = c(0, 1),
  edu_no_access_n = c(0, 1),
  edu_barrier_protection_n = c(0, 1),
  edu_disrupted_attack_n = c(0, 1),
  edu_disrupted_hazards_n = c(0, 1),
  edu_disrupted_displaced_n = c(0, 1),
  edu_disrupted_teacher_n = c(0, 1)
)

test_that("Function handles edge cases", {
  result <- add_comp_edu(edge_case_data)

  # Check for all zeros
  expect_equal(result$comp_edu_score_disrupted[1], 1)
  expect_equal(result$comp_edu_score_attendance[1], 1)
  expect_equal(result$comp_edu_score[1], 1)

  # Check for all ones
  expect_equal(result$comp_edu_score_disrupted[2], 4)
  expect_equal(result$comp_edu_score_attendance[2], 4)
  expect_equal(result$comp_edu_score[2], 4)
})
