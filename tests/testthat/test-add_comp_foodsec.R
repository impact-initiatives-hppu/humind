library(testthat)
library(dplyr)

# Create dummy data
df_dummy <- data.frame(
  fsl_fc_phase = c("Phase 1 FC", "Phase 2 FC", "Phase 3 FC", "Phase 4 FC", "Phase 5 FC", NA)
)

# Define tests
test_that("add_comp_foodsec function works correctly with default parameters", {
  result <- add_comp_foodsec(df_dummy)
  expect_equal(result$comp_foodsec_score, c(1, 2, 3, 4, 5, NA))
})

test_that("add_comp_foodsec handles undefined values correctly", {
  df_test <- df_dummy
  df_test$fsl_fc_phase <- "undefined"
  expect_error(add_comp_foodsec(df_test), class = "error")
})

test_that("add_comp_foodsec handles NA values correctly", {
  df_test <- df_dummy
  result <- add_comp_foodsec(df_test)
  expect_true(is.na(result$comp_foodsec_score[6]))
})

test_that("add_comp_foodsec throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-fsl_fc_phase)
  expect_error(add_comp_foodsec(df_test), class = "error")
})

test_that("add_comp_foodsec assigns in need status correctly", {
  result <- add_comp_foodsec(df_dummy)
  expect_equal(result$comp_foodsec_in_need, c(0, 0, 1, 1, 1, NA))
})


