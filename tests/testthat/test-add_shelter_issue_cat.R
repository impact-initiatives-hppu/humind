# Load testthat
library(testthat)

# ---- Test Data ----
test_df <- data.frame(
  snfi_shelter_issue = rep(NA, 6),
  snfi_shelter_issue_lack_privacy       = c(1, 0, 0, 0, 0, 0),
  snfi_shelter_issue_lack_space         = c(0, 1, 0, 0, 0, 0),
  snfi_shelter_issue_temperature        = c(0, 1, 1, 0, 0, 0),
  snfi_shelter_issue_ventilation        = c(0, 0, 1, 0, 0, 0),
  snfi_shelter_issue_vectors            = c(0, 0, 0, 1, 0, 0),
  snfi_shelter_issue_no_natural_light   = c(0, 0, 0, 0, 1, 0),
  snfi_shelter_issue_leak               = c(0, 0, 0, 0, 0, 1),
  snfi_shelter_issue_lock               = c(0, 0, 0, 0, 0, 0),
  snfi_shelter_issue_lack_lighting      = c(0, 0, 0, 0, 0, 0),
  snfi_shelter_issue_difficulty_move    = c(0, 0, 0, 0, 0, 0),
  snfi_shelter_issue_lack_space_laundry = c(0, 0, 0, 0, 0, 0),
  snfi_shelter_issue_none               = c(0, 0, 0, 0, 0, 1),
  snfi_shelter_issue_dnk                = c(0, 0, 0, 1, 0, 0),
  snfi_shelter_issue_pnta               = c(0, 0, 0, 0, 1, 0),
  snfi_shelter_issue_other              = c(0, 0, 1, 0, 0, 0)
)

# ---- Run the function ----
result <- add_shelter_issue_cat(
  df = test_df,
  shelter_issue = "snfi_shelter_issue",
  none = "none",
  issues = c("lack_privacy", "lack_space", "temperature", "ventilation", "vectors",
             "no_natural_light", "leak", "lock", "lack_lighting", "difficulty_move",
             "lack_space_laundry"),
  undefined = c("dnk", "pnta"),
  other = c("other"),
  sep = "_"
)

# ---- Unit Tests ----
test_that("snfi_shelter_issue_n is calculated correctly", {
  expect_equal(result$snfi_shelter_issue_n, c(1, 2, NA, NA, NA, 0))
})

test_that("snfi_shelter_issue_cat is categorized correctly", {
  expect_equal(result$snfi_shelter_issue_cat,
               c("1_to_3", "1_to_3", "other", "undefined", "undefined", "none"))
})

