# ---- add_expenditure_healthcare_share_income ----

make_df <- function(health = 20, income = 200) {
  dplyr::tibble(
    cm_expenditure_infrequent_health = health,
    cm_income_total = income
  )
}

# ---- Zero-income households (#689) ----

test_that("zero income with health expenditure above 0: share is 1 and flag is 1", {
  result <- add_expenditure_healthcare_share_income(
    make_df(health = 30, income = 0)
  )
  expect_equal(result$cm_expenditure_infrequent_health_share_income, 1)
  expect_equal(result$cm_expenditure_infrequent_health_share_income_d, 1L)
})

test_that("zero income with zero health expenditure: share is NA and flag is 0", {
  result <- add_expenditure_healthcare_share_income(
    make_df(health = 0, income = 0)
  )
  expect_true(is.na(result$cm_expenditure_infrequent_health_share_income))
  expect_equal(result$cm_expenditure_infrequent_health_share_income_d, 0L)
})

test_that("add_expenditure_healthcare_share_income adds expected columns with defaults", {
  result <- add_expenditure_healthcare_share_income(make_df())
  expect_true(
    "cm_expenditure_infrequent_health_share_income" %in% colnames(result)
  )
  expect_true(
    "cm_expenditure_infrequent_health_share_income_d" %in% colnames(result)
  )
})

test_that("default recall periods are 180d expenditure / 30d income", {
  # The share compares daily-normalised health spending with daily income
  # health=60, income=100 → share = 60*30 / (100*180) = 1800/18000 = 0.10
  result <- add_expenditure_healthcare_share_income(
    dplyr::tibble(cm_expenditure_infrequent_health = 60, cm_income_total = 100)
  )
  expect_equal(result$cm_expenditure_infrequent_health_share_income, 0.10)
})

test_that("default catastrophic_threshold is 0.25 with 180/30 recall: below → 0, at → 1", {
  # share = health * 30 / (100 * 180); threshold 0.25 at health=150
  df <- dplyr::tibble(
    cm_expenditure_infrequent_health = c(149, 150, 151),
    cm_income_total = rep(100, 3)
  )
  result <- add_expenditure_healthcare_share_income(df)
  expect_equal(
    result$cm_expenditure_infrequent_health_share_income_d,
    c(0L, 1L, 1L)
  )
})

test_that("errors on missing health expenditure column", {
  df <- dplyr::tibble(cm_income_total = 200)
  expect_error(add_expenditure_healthcare_share_income(df))
})

test_that("errors on missing income column", {
  df <- dplyr::tibble(cm_expenditure_infrequent_health = 20)
  expect_error(add_expenditure_healthcare_share_income(df))
})
