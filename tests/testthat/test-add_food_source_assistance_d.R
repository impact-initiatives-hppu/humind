test_that("add_food_source_assistance_d creates the output columns", {
  df <- data.frame(fsl_source_food_ranked = "purchase_cash")

  result <- add_food_source_assistance_d(df)

  expect_true("fsl_food_source_main" %in% colnames(result))
  expect_true("fsl_food_source_assistance_d" %in% colnames(result))
})

test_that("add_food_source_assistance_d keeps the first-ranked source", {
  df <- data.frame(
    fsl_source_food_ranked = c("gift purchase_cash", "purchase_cash", NA, "")
  )

  result <- add_food_source_assistance_d(df)

  expect_equal(result$fsl_food_source_main, c("gift", "purchase_cash", NA, NA))
})

test_that("add_food_source_assistance_d classifies the first-ranked source", {
  df <- data.frame(
    fsl_source_food_ranked = c(
      "assistance_in_kind purchase_cash",
      "assistance_cva",
      "own_production",
      "purchase_cash",
      "purchase_credit",
      "hunting",
      "gathering",
      "exchange",
      "borrow",
      "gift",
      "begging"
    )
  )

  result <- add_food_source_assistance_d(df)

  expect_equal(
    result$fsl_food_source_assistance_d,
    c(1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )
})

test_that("add_food_source_assistance_d only uses the first-ranked source", {
  df <- data.frame(
    fsl_source_food_ranked = c(
      "purchase_cash assistance_in_kind",
      "own_production assistance_cva"
    )
  )

  result <- add_food_source_assistance_d(df)

  expect_equal(result$fsl_food_source_assistance_d, c(0, 0))
})

test_that("add_food_source_assistance_d treats undefined sources as NA", {
  df <- data.frame(
    fsl_source_food_ranked = c("other purchase_cash", "dnk", "pnta")
  )

  result <- add_food_source_assistance_d(df)

  expect_true(all(is.na(result$fsl_food_source_assistance_d)))
})

test_that("add_food_source_assistance_d treats missing sources as NA", {
  df <- data.frame(fsl_source_food_ranked = c(NA, "", "   "))

  result <- add_food_source_assistance_d(df)

  expect_true(all(is.na(result$fsl_food_source_assistance_d)))
})

test_that("add_food_source_assistance_d respects a custom rank separator", {
  df <- data.frame(
    fsl_source_food_ranked = c(
      "assistance_cva;purchase_cash",
      "purchase_cash;assistance_cva"
    )
  )

  result <- add_food_source_assistance_d(df, rank_sep = ";")

  expect_equal(result$fsl_food_source_assistance_d, c(1, 0))
})

test_that("add_food_source_assistance_d treats a regex metacharacter separator literally", {
  df <- data.frame(
    fsl_source_food_ranked = c(
      "assistance_cva.purchase_cash",
      "purchase_cash.assistance_cva"
    )
  )

  result <- add_food_source_assistance_d(df, rank_sep = ".")

  expect_equal(
    result$fsl_food_source_main,
    c("assistance_cva", "purchase_cash")
  )
  expect_equal(result$fsl_food_source_assistance_d, c(1, 0))
})

test_that("add_food_source_assistance_d keeps unrelated columns and rows", {
  df <- data.frame(
    uuid = c("hh1", "hh2"),
    fsl_source_food_ranked = c("assistance_cva", "gift")
  )

  result <- add_food_source_assistance_d(df)

  expect_equal(result$uuid, c("hh1", "hh2"))
  expect_equal(nrow(result), 2)
})

test_that("add_food_source_assistance_d composes with add_food_source_atypical_d", {
  df <- data.frame(
    fsl_source_food_ranked = c("gift", "assistance_cva", "purchase_cash")
  )

  df <- add_food_source_atypical_d(df)
  expect_warning(
    result <- add_food_source_assistance_d(df),
    regex = "fsl_food_source_main already exists in df"
  )

  expect_equal(
    result$fsl_food_source_main,
    c("gift", "assistance_cva", "purchase_cash")
  )
  expect_equal(result$fsl_food_source_assistance_d, c(0, 1, 0))
  expect_equal(result$fsl_food_source_atypical_d, c(1, 0, 0))
})

test_that("add_food_source_assistance_d errors on a missing source column", {
  df <- data.frame(uuid = "hh1")

  expect_error(
    add_food_source_assistance_d(df),
    regex = "column is missing"
  )
})

test_that("add_food_source_assistance_d errors on an unknown response code", {
  df <- data.frame(fsl_source_food_ranked = "mystery_source")

  expect_error(
    add_food_source_assistance_d(df),
    regex = "All values must be in the following set"
  )
})

test_that("add_food_source_assistance_d rejects overlapping classification sets", {
  df <- data.frame(fsl_source_food_ranked = "assistance_cva")

  expect_error(
    add_food_source_assistance_d(
      df,
      non_assistance = c("purchase_cash", "assistance_cva")
    ),
    regex = "disjunct"
  )
})

test_that("add_food_source_assistance_d warns when fsl_food_source_main exists", {
  df <- data.frame(
    fsl_source_food_ranked = "purchase_cash",
    fsl_food_source_main = "old_source"
  )

  expect_warning(
    add_food_source_assistance_d(df),
    regex = "fsl_food_source_main already exists in df"
  )
})

test_that("add_food_source_assistance_d warns when the output column exists", {
  df <- data.frame(
    fsl_source_food_ranked = "purchase_cash",
    fsl_food_source_assistance_d = 0
  )

  expect_warning(
    add_food_source_assistance_d(df),
    regex = "fsl_food_source_assistance_d already exists in df"
  )
})

test_that("add_food_source_assistance_d replaces an existing output column", {
  df <- data.frame(
    fsl_source_food_ranked = "assistance_cva",
    fsl_food_source_assistance_d = 0
  )

  result <- suppressWarnings(add_food_source_assistance_d(df))

  expect_equal(result$fsl_food_source_assistance_d, 1)
})
