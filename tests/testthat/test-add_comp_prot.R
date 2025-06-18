library(testthat)
library(dplyr)

# Create dummy data
df_dummy <- data.frame(
  prot_concern_freq_cope = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta"),
  prot_concern_freq_displaced = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta"),
  prot_concern_hh_freq_kidnapping = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta"),
  prot_concern_hh_freq_discrimination = c("never", "once_or_twice", "several_times", "always", "dnk", "pnta")
)

test_that("add_comp_prot function works correctly with default parameters", {
  result <- add_comp_prot(df_dummy)

  # Check individual scores
  expect_equal(result$comp_prot_score_concern_freq_cope, c(0, 1, 2, 3, NA, NA))
  expect_equal(result$comp_prot_score_concern_freq_displaced, c(0, 1, 2, 3, NA, NA))
  expect_equal(result$comp_prot_score_concern_hh_freq_kidnapping, c(0, 1, 2, 3, NA, NA))
  expect_equal(result$comp_prot_score_concern_hh_freq_discrimination, c(0, 1, 2, 3, NA, NA))

  # Check comp_prot_risk_always_d (1 if any score is 3)
  expect_equal(result$comp_prot_risk_always_d, c(0, 0, 0, 1, NA, NA))

  # Check comp_prot_score_concern (sum thresholds)
  expect_equal(result$comp_prot_score_concern, c(1, 3, 3, 4, NA, NA))  # Sums: 0,4,8,12

  # Check final composite score
  expect_equal(result$comp_prot_score, result$comp_prot_score_concern)

  # Check need indicators (assuming is_in_need flags scores >=2)
  expect_equal(result$comp_prot_in_need, c(0, 1, 1, 1, NA, NA))
  expect_equal(result$comp_prot_in_acute_need, c(0, 0, 0, 1, NA, NA))  # Assuming acute need is score >=4
})

test_that("add_comp_prot handles edge cases", {
  # Test with all "always" responses
  df_all_always <- data.frame(
    prot_concern_freq_cope = rep("always", 3),
    prot_concern_freq_displaced = rep("always", 3),
    prot_concern_hh_freq_kidnapping = rep("always", 3),
    prot_concern_hh_freq_discrimination = rep("always", 3)
  )
  result <- add_comp_prot(df_all_always)
  expect_equal(result$comp_prot_score, rep(4, 3))  # Sum =12 → score=4

  # Test with all "never" responses
  df_all_never <- df_all_always %>% mutate(across(everything(), ~"never"))
  result <- add_comp_prot(df_all_never)
  expect_equal(result$comp_prot_score, rep(1, 3))  # Sum=0 → score=1
})

