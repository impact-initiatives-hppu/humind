library(testthat)
library(dplyr)

# Sample data for testing
df <- tibble::tibble(
  id = 1:5,
  etc_access_to_phone = c("smartphone", "feature_phone", "basic_phone", "none", "dnk"),
  `etc_access_to_phone/smartphone` = c(1, 0, 0, 0, 0),
  `etc_access_to_phone/feature_phone` = c(0, 1, 0, 0, 0),
  `etc_access_to_phone/basic_phone` = c(0, 0, 1, 0, 0),
  `etc_access_to_phone/none` = c(0, 0, 0, 1, 0),
  `etc_access_to_phone/dnk` = c(0, 0, 0, 0, 1),
  `etc_access_to_phone/pnta` = c(0, 0, 0, 0, 0),
  `etc_access_to_phone/other` = c(0, 0, 0, 0, 0),
  etc_coverage_internet = c("internet", "only_sms", "no_coverage", "voice_no_internet", "dnk")
)

test_that("add_access_to_phone_best correctly categorizes phone access", {
  result <- add_access_to_phone_best(df)

  expect_equal(result$etc_access_to_phone_best, c("smartphone", "feature_phone", "basic_phone", "none", "undefined"))
})

test_that("add_access_to_phone_coverage correctly categorizes network coverage", {
  result <- add_access_to_phone_best(df)
  result <- add_access_to_phone_coverage(result)

  expect_equal(result$etc_access_to_phone_coverage, c("internet_smartphone", "no_internet_or_basic_phone", "no_coverage_or_no_phone", "no_internet_or_basic_phone", "undefined"))
})

test_that("add_access_to_phone_best handles undefined phone responses", {
  df_undefined <- df
  df_undefined$`etc_access_to_phone/smartphone` <- c(0, 0, 0, 0, 0)
  df_undefined$`etc_access_to_phone/feature_phone` <- c(0, 0, 0, 0, 0)
  df_undefined$`etc_access_to_phone/basic_phone` <- c(0, 0, 0, 0, 0)
  df_undefined$`etc_access_to_phone/none` <- c(0, 0, 0, 0, 0)
  df_undefined$`etc_access_to_phone/dnk` <- c(1, 1, 1, 1, 1)
  df_undefined$`etc_access_to_phone/pnta` <- c(0, 0, 0, 0, 0)
  df_undefined$`etc_access_to_phone/other` <- c(0, 0, 0, 0, 0)

  result <- add_access_to_phone_best(df_undefined)

  expect_true(all(result$etc_access_to_phone_best == "undefined"))
})

test_that("add_access_to_phone_coverage handles undefined coverage responses", {
  df_undefined <- df
  df_undefined$etc_coverage_internet <- c("dnk", "pnta", "other", "dnk", "pnta")

  result <- add_access_to_phone_best(df_undefined)
  result <- add_access_to_phone_coverage(result)

  expect_true(all(result$etc_access_to_phone_coverage == "undefined"))
})

test_that("add_access_to_phone_coverage handles edge cases", {
  df_edge <- tibble::tibble(
    id = 1:2,
    etc_access_to_phone = c("smartphone", "basic_phone"),
    `etc_access_to_phone/smartphone` = c(1, 0),
    `etc_access_to_phone/feature_phone` = c(0, 0),
    `etc_access_to_phone/basic_phone` = c(0, 1),
    `etc_access_to_phone/none` = c(0, 0),
    `etc_access_to_phone/dnk` = c(0, 0),
    `etc_access_to_phone/pnta` = c(0, 0),
    `etc_access_to_phone/other` = c(0, 0),

    etc_coverage_internet = c("internet", "no_coverage")
  )

  result <- add_access_to_phone_best(df_edge)
  result <- add_access_to_phone_coverage(result)

  expect_equal(result$etc_access_to_phone_coverage[1], "internet_smartphone")
  expect_equal(result$etc_access_to_phone_coverage[2], "no_coverage_or_no_phone")
})
