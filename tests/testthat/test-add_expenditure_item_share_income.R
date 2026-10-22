# ---- add_expenditure_type_share_income ----

make_df <- function(health = 20, income = 200) {
  dplyr::tibble(
    cm_expenditure_infrequent_health = health,
    cm_income_total = income
  )
}

# ---- Output columns ----

test_that("add_expenditure_type_share_income adds _share_income column", {
  result <- add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_true(
    "cm_expenditure_infrequent_health_share_income" %in% colnames(result)
  )
})

test_that("add_expenditure_type_share_income adds _share_income_d column", {
  result <- add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_true(
    "cm_expenditure_infrequent_health_share_income_d" %in% colnames(result)
  )
})

test_that("output column names are dynamic based on expenditure_type", {
  df <- dplyr::tibble(cm_expenditure_other = 10, cm_income_total = 100)
  result <- add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_other",
    income_total = "cm_income_total"
  )
  expect_true("cm_expenditure_other_share_income" %in% colnames(result))
  expect_true("cm_expenditure_other_share_income_d" %in% colnames(result))
})

# ---- Share calculation ----

test_that("_share_income equals expenditure / income when recall periods are equal", {
  # spending of 20 over 30 days against an income of 200 over 30 days
  # gives a share of 20/200 equals 0.1
  result <- add_expenditure_type_share_income(
    make_df(health = 20, income = 200),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_equal(result$cm_expenditure_infrequent_health_share_income, 0.1)
})

test_that("_share_income is NA for zero-income household with zero expenditure", {
  result <- add_expenditure_type_share_income(
    make_df(health = 0, income = 0),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_true(is.na(result$cm_expenditure_infrequent_health_share_income))
})

test_that("_share_income is NA when income is NA", {
  result <- add_expenditure_type_share_income(
    make_df(health = 20, income = NA_real_),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_true(is.na(result$cm_expenditure_infrequent_health_share_income))
})

test_that("_share_income is NA when expenditure is NA", {
  result <- add_expenditure_type_share_income(
    make_df(health = NA_real_, income = 200),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_true(is.na(result$cm_expenditure_infrequent_health_share_income))
})

# ---- Zero-income households (#689) ----

test_that("zero income with expenditure above 0: share is 1 and flag is 1", {
  result <- add_expenditure_type_share_income(
    make_df(health = 30, income = 0),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_equal(result$cm_expenditure_infrequent_health_share_income, 1)
  expect_equal(result$cm_expenditure_infrequent_health_share_income_d, 1L)
})

test_that("zero income with zero expenditure: share is NA and flag is 0", {
  result <- add_expenditure_type_share_income(
    make_df(health = 0, income = 0),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_equal(result$cm_expenditure_infrequent_health_share_income_d, 0L)
})

test_that("zero income with NA expenditure: share is NA and flag is NA", {
  result <- add_expenditure_type_share_income(
    make_df(health = NA_real_, income = 0),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_true(is.na(result$cm_expenditure_infrequent_health_share_income))
  expect_true(is.na(result$cm_expenditure_infrequent_health_share_income_d))
})

# ---- Dummy flag ----

test_that("_share_income_d is 0 when share < catastrophic_threshold", {
  # 9 against 100 gives a share of 0.09, below the 0.10 threshold
  result <- add_expenditure_type_share_income(
    make_df(health = 9, income = 100),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    catastrophic_threshold = 0.10
  )
  expect_equal(result$cm_expenditure_infrequent_health_share_income_d, 0L)
})

test_that("_share_income_d is 1 when share == catastrophic_threshold", {
  # 10 against 100 gives a share of 0.10
  result <- add_expenditure_type_share_income(
    make_df(health = 10, income = 100),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    catastrophic_threshold = 0.10
  )
  expect_equal(result$cm_expenditure_infrequent_health_share_income_d, 1L)
})

test_that("_share_income_d is 1 when share > catastrophic_threshold", {
  # 30 against 100 gives a share of 0.30, above the 0.10 threshold
  result <- add_expenditure_type_share_income(
    make_df(health = 30, income = 100),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    catastrophic_threshold = 0.10
  )
  expect_equal(result$cm_expenditure_infrequent_health_share_income_d, 1L)
})

test_that("_share_income_d is NA when share is NA", {
  result <- add_expenditure_type_share_income(
    make_df(health = 20, income = NA_real_),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_true(is.na(result$cm_expenditure_infrequent_health_share_income_d))
})

test_that("_share_income_d is integer type", {
  result <- add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  )
  expect_type(result$cm_expenditure_infrequent_health_share_income_d, "integer")
})

test_that("catastrophic_threshold is respected with custom value", {
  df <- dplyr::tibble(
    cm_expenditure_infrequent_health = c(24, 25, 26),
    cm_income_total = rep(100, 3)
  )
  result <- add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    catastrophic_threshold = 0.25
  )
  expect_equal(
    result$cm_expenditure_infrequent_health_share_income_d,
    c(0L, 1L, 1L)
  )
})

# ---- Recall period normalisation ----

test_that("different recall periods normalise correctly", {
  # expenditure of 60 over 180 days gives 1 per 3 days
  # income of 100 over 30 days gives 100 per 30 days
  # the recall-normalised share compares them: 1 per 3 vs 100 per 30 → 0.10
  df <- dplyr::tibble(
    cm_expenditure_infrequent_health = 60,
    cm_income_total = 100
  )
  result <- add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    expenditure_recall_period = 180,
    income_recall_period = 30
  )
  expect_equal(
    result$cm_expenditure_infrequent_health_share_income,
    60 * 30 / (100 * 180)
  )
})

test_that("recall period normalisation affects catastrophic flag", {
  # health = 60/180d, income = 100/30d → share = 0.10 → just at threshold
  df <- dplyr::tibble(
    cm_expenditure_infrequent_health = c(59, 60, 61),
    cm_income_total = rep(100, 3)
  )
  result <- add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    expenditure_recall_period = 180,
    income_recall_period = 30,
    catastrophic_threshold = 0.10
  )
  expect_equal(
    result$cm_expenditure_infrequent_health_share_income_d,
    c(0L, 1L, 1L)
  )
})

# ---- Errors ----

test_that("errors on missing expenditure column", {
  df <- dplyr::tibble(cm_income_total = 200)
  expect_error(add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  ))
})

test_that("errors on missing income column", {
  df <- dplyr::tibble(cm_expenditure_infrequent_health = 20)
  expect_error(add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  ))
})

test_that("errors on non-numeric expenditure column", {
  df <- dplyr::tibble(
    cm_expenditure_infrequent_health = "high",
    cm_income_total = 200
  )
  expect_error(add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  ))
})

test_that("errors on non-numeric income column", {
  df <- dplyr::tibble(
    cm_expenditure_infrequent_health = 20,
    cm_income_total = "high"
  )
  expect_error(add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  ))
})

test_that("errors on negative expenditure values", {
  df <- dplyr::tibble(
    cm_expenditure_infrequent_health = -10,
    cm_income_total = 200
  )
  expect_error(add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  ))
})

test_that("errors on negative income values", {
  df <- dplyr::tibble(
    cm_expenditure_infrequent_health = 20,
    cm_income_total = -100
  )
  expect_error(add_expenditure_type_share_income(
    df,
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total"
  ))
})

test_that("errors on non-positive expenditure_recall_period", {
  expect_error(add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    expenditure_recall_period = 0
  ))
  expect_error(add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    expenditure_recall_period = -30
  ))
})

test_that("errors on non-positive income_recall_period", {
  expect_error(add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    income_recall_period = 0
  ))
  expect_error(add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    income_recall_period = -30
  ))
})

test_that("errors on catastrophic_threshold outside (0, 1)", {
  expect_error(add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    catastrophic_threshold = 0
  ))
  expect_error(add_expenditure_type_share_income(
    make_df(),
    expenditure_type = "cm_expenditure_infrequent_health",
    income_total = "cm_income_total",
    catastrophic_threshold = 1
  ))
})
