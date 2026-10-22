# ---- add_expenditure_water_share_income ----

make_df <- function(water = 10, income = 200) {
  dplyr::tibble(
    cm_expenditure_frequent_water = water,
    cm_income_total = income
  )
}

test_that("add_expenditure_water_share_income adds expected columns with defaults", {
  result <- add_expenditure_water_share_income(make_df())
  expect_true(
    "cm_expenditure_frequent_water_share_income" %in% colnames(result)
  )
  expect_true(
    "cm_expenditure_frequent_water_share_income_d" %in% colnames(result)
  )
})

test_that("default recall periods are 30d / 30d (share = water / income)", {
  # 10 against an income of 200 gives a share of 0.05
  result <- add_expenditure_water_share_income(make_df(
    water = 10,
    income = 200
  ))
  expect_equal(result$cm_expenditure_frequent_water_share_income, 0.05)
})

test_that("default catastrophic_threshold is 0.05: below → 0, at → 1, above → 1", {
  # threshold at water = 5 for income = 100
  df <- dplyr::tibble(
    cm_expenditure_frequent_water = c(4, 5, 6),
    cm_income_total = rep(100, 3)
  )
  result <- add_expenditure_water_share_income(df)
  expect_equal(
    result$cm_expenditure_frequent_water_share_income_d,
    c(0L, 1L, 1L)
  )
})

# ---- Zero-income households (#689) ----

test_that("zero income with water expenditure above 0: share is 1 and flag is 1", {
  result <- add_expenditure_water_share_income(make_df(water = 10, income = 0))
  expect_equal(result$cm_expenditure_frequent_water_share_income, 1)
  expect_equal(result$cm_expenditure_frequent_water_share_income_d, 1L)
})

test_that("zero income with zero water expenditure: share is NA and flag is 0", {
  result <- add_expenditure_water_share_income(make_df(water = 0, income = 0))
  expect_true(is.na(result$cm_expenditure_frequent_water_share_income))
  expect_equal(result$cm_expenditure_frequent_water_share_income_d, 0L)
})

test_that("zero income with NA water expenditure: share is NA and flag is NA", {
  result <- add_expenditure_water_share_income(
    make_df(water = NA_real_, income = 0)
  )
  expect_true(is.na(result$cm_expenditure_frequent_water_share_income))
  expect_true(is.na(result$cm_expenditure_frequent_water_share_income_d))
})

test_that("share is NA when income is NA", {
  result <- add_expenditure_water_share_income(make_df(
    water = 10,
    income = NA_real_
  ))
  expect_true(is.na(result$cm_expenditure_frequent_water_share_income))
})

test_that("errors on missing water expenditure column", {
  df <- dplyr::tibble(cm_income_total = 200)
  expect_error(add_expenditure_water_share_income(df))
})

test_that("errors on missing income column", {
  df <- dplyr::tibble(cm_expenditure_frequent_water = 10)
  expect_error(add_expenditure_water_share_income(df))
})
