# Load necessary libraries
library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data_infreq <- data.frame(
  uuid = 1:4,
  cm_expenditure_frequent = c("no", "no", "no", "no"),
  cm_expenditure_infrequent = c("spent", "spent", "spent", "spent"),
  cm_expenditure_infrequent_shelter = c(100, 100, 100, 100),
  cm_expenditure_infrequent_nfi = c(0, 50, 50, 200),
  cm_expenditure_infrequent_health = c(0, 10, 50, 150),
  cm_expenditure_infrequent_education = c(50, 0, 0, 300),
  cm_expenditure_infrequent_debt = c(0, 0, 0, 50),
  cm_expenditure_infrequent_clothing = c(0, 0, 200, 25),
  cm_expenditure_infrequent_other = c(0, 0, 10, 25)
)

# ---- Run function ----
result <- add_expenditure_type_infreq_rank(
  df = dummy_data_infreq,
  expenditure_infreq_types = c(
    "cm_expenditure_infrequent_shelter",
    "cm_expenditure_infrequent_nfi",
    "cm_expenditure_infrequent_health",
    "cm_expenditure_infrequent_education",
    "cm_expenditure_infrequent_debt",
    "cm_expenditure_infrequent_clothing",
    "cm_expenditure_infrequent_other"
  ),
  id_col = "uuid"
)

# ---- Expected Results ----
expected_top1 <- c(
  "cm_expenditure_infrequent_shelter",
  "cm_expenditure_infrequent_shelter",
  "cm_expenditure_infrequent_clothing",
  "cm_expenditure_infrequent_education"
)
expected_top2 <- c(
  "cm_expenditure_infrequent_education",
  "cm_expenditure_infrequent_nfi",
  "cm_expenditure_infrequent_shelter",
  "cm_expenditure_infrequent_nfi"
)
expected_top3 <- c(
  NA,
  "cm_expenditure_infrequent_health",
  "cm_expenditure_infrequent_nfi",
  "cm_expenditure_infrequent_health"
)

# ---- Unit Tests ----
test_that("Top 3 infrequent expenditure types are correctly ranked for all rows (vectorized)", {
  expect_equal(result$cm_infreq_expenditure_top1, expected_top1)
  expect_equal(result$cm_infreq_expenditure_top2, expected_top2)
  expect_equal(result$cm_infreq_expenditure_top3, expected_top3)
})
