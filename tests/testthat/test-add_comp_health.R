# Create dummy data
df_dummy <- data.frame(
  health_ind_healthcare_needed_no_n = c(0, 1, 0, 1, 0),
  health_ind_healthcare_needed_yes_unmet_n = c(1, 0, 0, 0, 0),
  health_ind_healthcare_needed_yes_met_n = c(0, 0, 1, 0, 0)
)

# Tests

test_that("add_comp_health function works correctly with default parameters", {
  result <- add_comp_health(df_dummy)
  expect_equal(result$comp_health_score, c(3, 1, 2, 1, NA))
  expect_equal(result$comp_health_in_need, c(1, 0, 0, 0, NA))
})


test_that("add_comp_health handles non-numeric values correctly", {
  df_test <- df_dummy
  df_test$health_ind_healthcare_needed_no_n[1] <- "non-numeric"
  expect_error(add_comp_health(df_test), class = "error")
})


test_that("add_comp_health throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-health_ind_healthcare_needed_no_n)
  expect_error(add_comp_health(df_test), class = "error")
})


test_that("add_comp_health assigns in need status correctly", {
  result <- add_comp_health(df_dummy)
  expect_equal(result$comp_health_in_need, c(1, 0, 0, 0, NA))
})
