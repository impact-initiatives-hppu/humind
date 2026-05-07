test_that("add_food_source_d creates both output columns", {
  df <- dplyr::tibble(
    uuid = "hh1",
    `fsl_source_food/assistance_in_kind` = 0,
    `fsl_source_food/assistance_cva` = 0,
    `fsl_source_food/gathering` = 0,
    `fsl_source_food/exchange` = 0,
    `fsl_source_food/borrow` = 0,
    `fsl_source_food/gift` = 0,
    `fsl_source_food/begging` = 0
  )
  result <- add_food_source_d(df)
  expect_true("fsl_food_source_aid_d" %in% colnames(result))
  expect_true("fsl_food_source_unstable_d" %in% colnames(result))
})

test_that("add_food_source_d: all cols 0 then both dummies are 0", {
  df <- dplyr::tibble(
    uuid = "hh1",
    `fsl_source_food/assistance_in_kind` = 0,
    `fsl_source_food/assistance_cva` = 0,
    `fsl_source_food/gathering` = 0,
    `fsl_source_food/exchange` = 0,
    `fsl_source_food/borrow` = 0,
    `fsl_source_food/gift` = 0,
    `fsl_source_food/begging` = 0
  )
  result <- add_food_source_d(df)
  expect_equal(result$fsl_food_source_aid_d, 0)
  expect_equal(result$fsl_food_source_unstable_d, 0)
})

test_that("add_food_source_d: any aid col 1 then aid dummy is 1", {
  df <- dplyr::tibble(
    uuid = c("hh1", "hh2"),
    `fsl_source_food/assistance_in_kind` = c(1, 0),
    `fsl_source_food/assistance_cva` = c(0, 1),
    `fsl_source_food/gathering` = c(0, 0),
    `fsl_source_food/exchange` = c(0, 0),
    `fsl_source_food/borrow` = c(0, 0),
    `fsl_source_food/gift` = c(0, 0),
    `fsl_source_food/begging` = c(0, 0)
  )
  result <- add_food_source_d(df)
  expect_equal(result$fsl_food_source_aid_d, c(1, 1))
  expect_equal(result$fsl_food_source_unstable_d, c(0, 0))
})

test_that("add_food_source_d: any unstable col 1 then unstable dummy is 1", {
  df <- dplyr::tibble(
    uuid = c("hh1", "hh2", "hh3"),
    `fsl_source_food/assistance_in_kind` = c(0, 0, 0),
    `fsl_source_food/assistance_cva` = c(0, 0, 0),
    `fsl_source_food/gathering` = c(1, 0, 0),
    `fsl_source_food/exchange` = c(0, 1, 0),
    `fsl_source_food/borrow` = c(0, 0, 0),
    `fsl_source_food/gift` = c(0, 0, 0),
    `fsl_source_food/begging` = c(0, 0, 1)
  )
  result <- add_food_source_d(df)
  expect_equal(result$fsl_food_source_aid_d, c(0, 0, 0))
  expect_equal(result$fsl_food_source_unstable_d, c(1, 1, 1))
})

test_that("add_food_source_d: all aid cols NA then aid dummy is NA", {
  df <- dplyr::tibble(
    uuid = "hh1",
    `fsl_source_food/assistance_in_kind` = NA_real_,
    `fsl_source_food/assistance_cva` = NA_real_,
    `fsl_source_food/gathering` = 0,
    `fsl_source_food/exchange` = 0,
    `fsl_source_food/borrow` = 0,
    `fsl_source_food/gift` = 0,
    `fsl_source_food/begging` = 0
  )
  result <- add_food_source_d(df)
  expect_true(is.na(result$fsl_food_source_aid_d))
  expect_equal(result$fsl_food_source_unstable_d, 0)
})

test_that("add_food_source_d: some NA but none is 1 then dummy is NA", {
  df <- dplyr::tibble(
    uuid = "hh1",
    `fsl_source_food/assistance_in_kind` = 0,
    `fsl_source_food/assistance_cva` = NA_real_,
    `fsl_source_food/gathering` = NA_real_,
    `fsl_source_food/exchange` = 0,
    `fsl_source_food/borrow` = 0,
    `fsl_source_food/gift` = 0,
    `fsl_source_food/begging` = 0
  )
  result <- add_food_source_d(df)
  expect_true(is.na(result$fsl_food_source_aid_d))
  expect_true(is.na(result$fsl_food_source_unstable_d))
})

test_that("add_food_source_d: one is 1 even if others are NA then dummy is 1", {
  df <- dplyr::tibble(
    uuid = "hh1",
    `fsl_source_food/assistance_in_kind` = NA_real_,
    `fsl_source_food/assistance_cva` = 1,
    `fsl_source_food/gathering` = 1,
    `fsl_source_food/exchange` = NA_real_,
    `fsl_source_food/borrow` = NA_real_,
    `fsl_source_food/gift` = NA_real_,
    `fsl_source_food/begging` = NA_real_
  )
  result <- add_food_source_d(df)
  expect_equal(result$fsl_food_source_aid_d, 1)
  expect_equal(result$fsl_food_source_unstable_d, 1)
})

test_that("add_food_source_d: error if required cols missing", {
  df <- dplyr::tibble(uuid = "hh1", `fsl_source_food/gathering` = 0)
  expect_error(add_food_source_d(df))
})

test_that("add_food_source_d: warning if output col already exists", {
  df <- dplyr::tibble(
    uuid = "hh1",
    `fsl_source_food/assistance_in_kind` = 0,
    `fsl_source_food/assistance_cva` = 0,
    `fsl_source_food/gathering` = 0,
    `fsl_source_food/exchange` = 0,
    `fsl_source_food/borrow` = 0,
    `fsl_source_food/gift` = 0,
    `fsl_source_food/begging` = 0,
    fsl_food_source_aid_d = 99
  )
  expect_warning(add_food_source_d(df))
})

test_that("add_food_source_d: sep parameter works", {
  df <- dplyr::tibble(
    uuid = "hh1",
    `fsl_source_food.assistance_in_kind` = 0,
    `fsl_source_food.assistance_cva` = 1,
    `fsl_source_food.gathering` = 0,
    `fsl_source_food.exchange` = 0,
    `fsl_source_food.borrow` = 0,
    `fsl_source_food.gift` = 0,
    `fsl_source_food.begging` = 0
  )
  result <- add_food_source_d(df, sep = ".")
  expect_equal(result$fsl_food_source_aid_d, 1)
  expect_equal(result$fsl_food_source_unstable_d, 0)
})
