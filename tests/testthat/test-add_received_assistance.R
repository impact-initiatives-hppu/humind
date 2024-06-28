library(testthat)
library(dplyr)

test_that("add_received_assistance works with default parameters", {
  df <- data.frame(
    aap_received_assistance_12m = c("yes", "no", "dnk", "pnta"),
    aap_received_assistance_date = c("past_30d", "1_3_months", "4_6_months", "7_12_months")
  )

  result <- add_received_assistance(df)

  expected <- data.frame(
    aap_received_assistance_12m = c("yes", "no", "dnk", "pnta"),
    aap_received_assistance_date = c("past_30d", "1_3_months", "4_6_months", "7_12_months"),
    aap_received_assistance = c("past_30d", "no", "undefined", "undefined")
  )

  expect_equal(result, expected)
})

test_that("add_received_assistance handles all undefined values", {
  df <- data.frame(
    aap_received_assistance_12m = c("dnk", "pnta", "dnk", "pnta"),
    aap_received_assistance_date = c("dnk", "pnta", "dnk", "pnta")
  )

  result <- add_received_assistance(df)

  expected <- data.frame(
    aap_received_assistance_12m = c("dnk", "pnta", "dnk", "pnta"),
    aap_received_assistance_date = c("dnk", "pnta", "dnk", "pnta"),
    aap_received_assistance = c("undefined", "undefined", "undefined", "undefined")
  )

  expect_equal(result, expected)
})

test_that("add_received_assistance handles all NA values", {
  df <- data.frame(
    aap_received_assistance_12m = c(NA, NA, NA, NA),
    aap_received_assistance_date = c(NA, NA, NA, NA)
  )

  result <- add_received_assistance(df)

  expected <- data.frame(
    aap_received_assistance_12m = c(NA, NA, NA, NA),
    aap_received_assistance_date = c(NA, NA, NA, NA),
    aap_received_assistance = c(NA, NA, NA, NA)
  )

  expect_equal(result, expected)
})

test_that("add_received_assistance give message about missing columns", {
  df <- data.frame(
    aap_received_assistance_12m = c("yes", "no", "dnk", "pnta")
  )

  expect_error(add_received_assistance(df), class = "error")
})

test_that("add_received_assistance give message about invalid values", {
  df <- data.frame(
    aap_received_assistance_12m = c("invalid", "no", "yes", "yes"),
    aap_received_assistance_date = c("past_30d", "invalid", "1_3_months", "invalid")
  )

  expect_error(add_received_assistance(df), class = "error")
})

test_that("add_received_assistance handles custom parameters", {
  df <- data.frame(
    assist_12m = c("yes", "no", "unknown", "unknown"),
    assist_date = c("past_30d", "1_3_months", "unknown", "unknown")
  )

  result <- add_received_assistance(
    df,
    received_assistance_12m = "assist_12m",
    yes = "yes",
    no = "no",
    undefined = c("unknown"),
    received_assistance_date = "assist_date",
    date_past_30d = "past_30d",
    date_1_3_months = "1_3_months",
    date_4_6_months = "4_6_months",
    date_7_12_months = "7_12_months",
    date_undefined = c("unknown")
  )

  expected <- data.frame(
    assist_12m = c("yes", "no", "unknown", "unknown"),
    assist_date = c("past_30d", "1_3_months", "unknown", "unknown"),
    aap_received_assistance = c("past_30d", "no", "undefined", "undefined")
  )

  expect_equal(result, expected)
})
