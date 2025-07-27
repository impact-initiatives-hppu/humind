# test_add_comp_snfi.R

# Load required package
library(testthat)

# Create mock data
test_df <- data.frame(
  snfi_shelter_type_cat = c("none", "inadequate", "adequate", "undefined"),
  snfi_shelter_issue_cat = c("8_to_11", "4_to_7", "1_to_3", "none"),
  hlp_occupancy_cat = c("high_risk", "medium_risk", "low_risk", "undefined"),
  snfi_fds_cannot_cat = c("4_tasks", "2_to_3_tasks", "1_task", "none"),
  snfi_shelter_damage_cat = c("total", "part", "damaged", "none"),
  stringsAsFactors = FALSE
)

# Run the function
result_df <- add_comp_snfi(
  df = test_df,
  shelter_damage = TRUE
)

# Begin tests
test_that("Output columns are present", {
  expect_true(all(
    c(
      "comp_snfi_score_shelter_type_cat",
      "comp_snfi_score_shelter_issue_cat",
      "comp_snfi_score_tenure_security_cat",
      "comp_snfi_score_fds_cannot_cat",
      "comp_snfi_score_shelter_damage_cat",
      "comp_snfi_score",
      "comp_snfi_in_need",
      "comp_snfi_in_acute_need"
    ) %in%
      names(result_df)
  ))
})

test_that("Composite scores are correct", {
  expect_equal(result_df$comp_snfi_score_shelter_type_cat, c(5, 3, 1, NA_real_))
  expect_equal(result_df$comp_snfi_score_shelter_issue_cat, c(4, 3, 2, 1))
  expect_equal(
    result_df$comp_snfi_score_tenure_security_cat,
    c(3, 2, 1, NA_real_)
  )
  expect_equal(result_df$comp_snfi_score_fds_cannot_cat, c(4, 3, 2, 1))
  expect_equal(result_df$comp_snfi_score_shelter_damage_cat, c(4, 3, 2, 1))
})

test_that("Composite max score is correct", {
  expect_equal(result_df$comp_snfi_score, c(5, 3, 2, 1))
})
