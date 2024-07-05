library(testthat)
library(dplyr)

# Create dummy data
df_dummy <- data.frame(
  prot_child_sep_cat = c("none", "at_least_one_very_severe", "at_least_one_severe", "at_least_one_non_severe", "undefined", NA),
  prot_concern_freq_cope = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta"),
  prot_concern_freq_displaced = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta"),
  prot_concern_hh_freq_kidnapping = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta"),
  prot_concern_hh_freq_discrimination = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta")
)

# Define tests
test_that("add_comp_prot function works correctly with default parameters", {
  result <- add_comp_prot(df_dummy)
  expect_equal(result$comp_prot_child_sep_cat, c(1, 5, 4, 1, NA, NA))
  expect_equal(result$comp_prot_score_concern_freq_cope, c(1, 2, 3, 4, NA, NA))
  expect_equal(result$comp_prot_score_concern_freq_displaced, c(1, 2, 3, 4, NA, NA))
  expect_equal(result$comp_prot_score_concern_hh_freq_kidnapping, c(1, 2, 3, 4, NA, NA))
  expect_equal(result$comp_prot_score_concern_hh_freq_discrimination, c(1, 2, 3, 4, NA, NA))
  expect_equal(result$comp_prot_score_concern, c(5, 10, 15, 20, NA, NA))
  expect_equal(result$comp_prot_score, c(6, 15, 19, 21, NA, NA))
})

test_that("add_comp_prot handles undefined values correctly", {
  df_test <- df_dummy
  df_test$prot_child_sep_cat <- "undefined"
  result <- add_comp_prot(df_test)
  expect_true(all(is.na(result$comp_prot_child_sep_cat)))
})

test_that("add_comp_prot handles NA values correctly", {
  df_test <- df_dummy
  df_test$prot_child_sep_cat[1] <- NA
  result <- add_comp_prot(df_test)
  expect_true(is.na(result$comp_prot_child_sep_cat[1]))
})

test_that("add_comp_prot throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test %>% select(-prot_child_sep_cat)
  expect_error(add_comp_prot(df_test), class = "error")
})

test_that("add_comp_prot assigns in need status correctly", {
  result <- add_comp_prot(df_dummy)
  expect_equal(result$comp_prot_in_need, c(FALSE, TRUE, TRUE, TRUE, NA, NA))
})

test_that("add_comp_prot handles custom category levels correctly", {
  custom_child_sep_levels <- c("none", "at_least_one_very_severe", "at_least_one_severe", "at_least_one_non_severe", "undefined")
  custom_concern_levels <- c("never", "once_or_twice", "several_times", "always", "dnk", "pnta")

  result <- add_comp_prot(
    df_dummy,
    child_sep_cat_levels = custom_child_sep_levels,
    concern_levels = custom_concern_levels
  )

  expect_equal(result$comp_prot_child_sep_cat, c(1, 5, 4, 1, NA, NA))
  expect_equal(result$comp_prot_score_concern_freq_cope, c(1, 2, 3, 4, NA, NA))
  expect_equal(result$comp_prot_score_concern_freq_displaced, c(1, 2, 3, 4, NA, NA))
  expect_equal(result$comp_prot_score_concern_hh_freq_kidnapping, c(1, 2, 3, 4, NA, NA))
  expect_equal(result$comp_prot_score_concern_hh_freq_discrimination, c(1, 2, 3, 4, NA, NA))
})

test_that("add_comp_prot handles empty dataframe", {
  df_empty <- data.frame()
  expect_error(add_comp_prot(df_empty), class = "error")
})

test_that("add_comp_prot handles single row dataframe", {
  df_single <- df_dummy[1,]
  result <- add_comp_prot(df_single)
  expect_equal(nrow(result), 1)
  expect_equal(result$comp_prot_score, 6)
})

test_that("add_comp_prot produces consistent results", {
  result1 <- add_comp_prot(df_dummy)
  result2 <- add_comp_prot(df_dummy)
  expect_equal(result1, result2)
})
