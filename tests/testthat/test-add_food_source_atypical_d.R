test_that("add_food_source_atypical_d creates the output columns", {
  df <- data.frame(fsl_source_food_ranked = "purchase_cash")

  result <- add_food_source_atypical_d(df)

  expect_true("fsl_food_source_main" %in% colnames(result))
  expect_true("fsl_food_source_atypical_d" %in% colnames(result))
})

test_that("add_food_source_atypical_d keeps the first-ranked source", {
  df <- data.frame(
    fsl_source_food_ranked = c("gift purchase_cash", "purchase_cash", NA, "")
  )

  result <- add_food_source_atypical_d(df)

  expect_equal(result$fsl_food_source_main, c("gift", "purchase_cash", NA, NA))
})

test_that("add_food_source_atypical_d classifies the first-ranked source", {
  df <- data.frame(
    fsl_source_food_ranked = c(
      "hunting purchase_cash",
      "gathering",
      "exchange",
      "borrow",
      "gift",
      "begging",
      "own_production",
      "purchase_cash",
      "purchase_credit",
      "assistance_in_kind purchase_cash",
      "assistance_cva"
    )
  )

  result <- add_food_source_atypical_d(df)

  expect_equal(
    result$fsl_food_source_atypical_d,
    c(1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0)
  )
})

test_that("add_food_source_atypical_d only uses the first-ranked source", {
  df <- data.frame(
    fsl_source_food_ranked = c(
      "purchase_cash gift",
      "own_production hunting"
    )
  )

  result <- add_food_source_atypical_d(df)

  expect_equal(result$fsl_food_source_atypical_d, c(0, 0))
})

test_that("add_food_source_atypical_d treats undefined sources as NA", {
  df <- data.frame(
    fsl_source_food_ranked = c("other purchase_cash", "dnk", "pnta")
  )

  result <- add_food_source_atypical_d(df)

  expect_true(all(is.na(result$fsl_food_source_atypical_d)))
})

test_that("add_food_source_atypical_d treats missing sources as NA", {
  df <- data.frame(fsl_source_food_ranked = c(NA, "", "   "))

  result <- add_food_source_atypical_d(df)

  expect_true(all(is.na(result$fsl_food_source_atypical_d)))
})

test_that("add_food_source_atypical_d respects a custom rank separator", {
  df <- data.frame(
    fsl_source_food_ranked = c("gift;purchase_cash", "purchase_cash;gift")
  )

  result <- add_food_source_atypical_d(df, rank_sep = ";")

  expect_equal(result$fsl_food_source_atypical_d, c(1, 0))
})

test_that("add_food_source_atypical_d treats a regex metacharacter separator literally", {
  df <- data.frame(
    fsl_source_food_ranked = c("gift.purchase_cash", "purchase_cash.gift")
  )

  result <- add_food_source_atypical_d(df, rank_sep = ".")

  expect_equal(result$fsl_food_source_main, c("gift", "purchase_cash"))
  expect_equal(result$fsl_food_source_atypical_d, c(1, 0))
})

test_that("add_food_source_atypical_d keeps unrelated columns and rows", {
  df <- data.frame(
    uuid = c("hh1", "hh2"),
    fsl_source_food_ranked = c("gift", "assistance_cva")
  )

  result <- add_food_source_atypical_d(df)

  expect_equal(result$uuid, c("hh1", "hh2"))
  expect_equal(nrow(result), 2)
})

test_that("add_food_source_atypical_d composes with add_food_source_assistance_d", {
  df <- data.frame(
    fsl_source_food_ranked = c("gift", "assistance_cva", "purchase_cash")
  )

  df <- add_food_source_assistance_d(df)
  expect_warning(
    result <- add_food_source_atypical_d(df),
    regex = "fsl_food_source_main already exists in df"
  )

  expect_equal(
    result$fsl_food_source_main,
    c("gift", "assistance_cva", "purchase_cash")
  )
  expect_equal(result$fsl_food_source_atypical_d, c(1, 0, 0))
  expect_equal(result$fsl_food_source_assistance_d, c(0, 1, 0))
})

test_that("add_food_source_atypical_d errors on a missing source column", {
  df <- data.frame(uuid = "hh1")

  expect_error(
    add_food_source_atypical_d(df),
    regex = "column is missing"
  )
})

test_that("add_food_source_atypical_d errors on an unknown response code", {
  df <- data.frame(fsl_source_food_ranked = "mystery_source")

  expect_error(
    add_food_source_atypical_d(df),
    regex = "All values must be in the following set"
  )
})

test_that("add_food_source_atypical_d rejects overlapping classification sets", {
  df <- data.frame(fsl_source_food_ranked = "hunting")

  expect_error(
    add_food_source_atypical_d(df, non_atypical = c("purchase_cash", "hunting")),
    regex = "disjunct"
  )
})

test_that("add_food_source_atypical_d warns when fsl_food_source_main exists", {
  df <- data.frame(
    fsl_source_food_ranked = "purchase_cash",
    fsl_food_source_main = "old_source"
  )

  expect_warning(
    add_food_source_atypical_d(df),
    regex = "fsl_food_source_main already exists in df"
  )
})

test_that("add_food_source_atypical_d warns when the output column exists", {
  df <- data.frame(
    fsl_source_food_ranked = "purchase_cash",
    fsl_food_source_atypical_d = 0
  )

  expect_warning(
    add_food_source_atypical_d(df),
    regex = "fsl_food_source_atypical_d already exists in df"
  )
})

test_that("add_food_source_atypical_d replaces an existing output column", {
  df <- data.frame(
    fsl_source_food_ranked = "gift",
    fsl_food_source_atypical_d = 0
  )

  result <- suppressWarnings(add_food_source_atypical_d(df))

  expect_equal(result$fsl_food_source_atypical_d, 1)
})
