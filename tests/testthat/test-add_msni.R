# tests/testthat/test-add_msni.R

library(testthat)
library(dplyr)

test_that("add_msni works with default parameters", {
  df <- data.frame(
    comp_foodsec_score = c(1, 2, 3, 4, 5),
    comp_snfi_score = c(5, 4, 3, 2, 1),
    comp_wash_score = c(2, 2, 2, 2, 2),
    comp_prot_score = c(3, 3, 3, 3, 3),
    comp_health_score = c(4, 4, 4, 4, 4),
    comp_edu_score = c(5, 5, 5, 5, 5)
  )

  result <- add_msni(df)

  expected <- df %>%
    mutate(msni_score = pmax(comp_foodsec_score, comp_snfi_score, comp_wash_score, comp_prot_score, comp_health_score, comp_edu_score, na.rm = TRUE),
           msni_in_need = ifelse(msni_score >= 3, 1, 0))

  expect_equal(result, expected)
})

test_that("add_msni handles all possible values", {
  df <- data.frame(
    comp_foodsec_score = 1:5,
    comp_snfi_score = 1:5,
    comp_wash_score = 1:5,
    comp_prot_score = 1:5,
    comp_health_score = 1:5,
    comp_edu_score = 1:5
  )

  result <- add_msni(df)

  expected <- df %>%
    mutate(msni_score = 5, msni_in_need = ifelse(msni_score >= 3, 1, 0))

  expect_equal(result, expected)
})

test_that("add_msni handles all NA values", {
  df <- data.frame(
    comp_foodsec_score = c(NA, NA, NA, NA, NA),
    comp_snfi_score = c(NA, NA, NA, NA, NA),
    comp_wash_score = c(NA, NA, NA, NA, NA),
    comp_prot_score = c(NA, NA, NA, NA, NA),
    comp_health_score = c(NA, NA, NA, NA, NA),
    comp_edu_score = c(NA, NA, NA, NA, NA)
  )

  result <- add_msni(df)

  expected <- df %>%
    mutate(msni_score = NA, msni_in_need = NA)

  expect_equal(result, expected)
})

test_that("add_msni handles missing columns", {
  df <- data.frame(
    comp_foodsec_score = c(1, 2, 3, 4, 5),
    comp_snfi_score = c(5, 4, 3, 2, 1)
  )

  expect_error(add_msni(df), "Missing columns\n• The following columns are missing in `df`: comp_wash_score, comp_prot_score, comp_health_score, and comp_edu_score")
})

test_that("add_msni handles out-of-range values", {
  df <- data.frame(
    comp_foodsec_score = c(0, 6, -1, 10, NA),
    comp_snfi_score = c(5, 4, 3, 2, 1),
    comp_wash_score = c(2, 2, 2, 2, 2),
    comp_prot_score = c(3, 3, 3, 3, 3),
    comp_health_score = c(4, 4, 4, 4, 4),
    comp_edu_score = c(5, 5, 5, 5, 5)
  )

  expect_error(add_msni(df), "All columns must be in the following set: 1, 2, 3, 4, 5\nℹ The following columns have values out of the set Please check.\ncomp_foodsec_score\n✖ The values out of the set are:\ncomp_foodsec_score: 0, 6, -1 and 10")
})
