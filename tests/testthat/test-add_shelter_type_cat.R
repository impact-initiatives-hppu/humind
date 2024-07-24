library(testthat)
library(dplyr)

test_that("add_shelter_type_cat works with different shelter types", {
  df <- data.frame(
    snfi_shelter_type = c("none", "collective_center", "pnta", "other", "individual_shelter"),
    snfi_shelter_type_individual = c("house", "makeshift", "tent", "other", "unfinished_building")
  )

  result <- add_shelter_type_cat(df)

  expected <- data.frame(
    snfi_shelter_type = c("none", "collective_center", "pnta", "other", "individual_shelter"),
    snfi_shelter_type_individual = c("house", "makeshift", "tent", "other", "unfinished_building"),
    snfi_shelter_type_cat = c("none", "inadequate", "undefined", "undefined", "inadequate")
  )

  expect_equal(result, expected)
})

test_that("add_shelter_type_cat handles adequate and inadequate shelter types", {
  df <- data.frame(
    snfi_shelter_type = c("other", "other", "other", "other", "other"),
    snfi_shelter_type_individual = c("house", "apartment", "tent", "makeshift", "unfinished_building")
  )

  result <- add_shelter_type_cat(df)

  expected <- data.frame(
    snfi_shelter_type = c("other", "other", "other", "other", "other"),
    snfi_shelter_type_individual = c("house", "apartment", "tent", "makeshift", "unfinished_building"),
    snfi_shelter_type_cat = c("adequate", "adequate", "adequate", "inadequate", "inadequate")
  )

  expect_equal(result, expected)
})

test_that("add_shelter_type_cat handles undefined shelter types", {
  df <- data.frame(
    snfi_shelter_type = c("other", "other", "other"),
    snfi_shelter_type_individual = c("pnta", "other", "dnk")
  )

  result <- add_shelter_type_cat(df)

  expected <- data.frame(
    snfi_shelter_type = c("other", "other", "other"),
    snfi_shelter_type_individual = c("pnta", "other", "dnk"),
    snfi_shelter_type_cat = c("undefined", "undefined", "undefined")
  )

  expect_equal(result, expected)
})

test_that("add_shelter_type_cat handles missing columns", {
  df <- data.frame(
    snfi_shelter_type = c("none", "collective_center", "pnta")
  )

  expect_error(add_shelter_type_cat(df), class = "error")
})

test_that("add_shelter_type_cat handles invalid values", {
  df <- data.frame(
    snfi_shelter_type = c("none", "collective_center", "pnta"),
    snfi_shelter_type_individual = c("invalid", "makeshift", "tent")
  )

  expect_error(add_shelter_type_cat(df), class = "error")
})
