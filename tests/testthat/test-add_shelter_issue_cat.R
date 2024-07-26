library(testthat)
library(dplyr)
library(tibble)

test_that("add_shelter_issue_cat works with default parameters", {
  df <- tibble::tibble(
    snfi_shelter_issue = c("temperature", "ventilation", "leak", "lack_privacy", "none"),
    'snfi_shelter_issue/temperature' = c(1, 0, 0, 0, 0),
    'snfi_shelter_issue/ventilation' = c(0, 1, 0, 0, 0),
    'snfi_shelter_issue/leak' = c(0, 0, 1, 0, 0),
    'snfi_shelter_issue/lack_privacy' = c(0, 0, 0, 1, 0),
    'snfi_shelter_issue/lack_space' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/lock' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/lack_lighting' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/difficulty_move' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/dnk' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/pnta' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/other' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/none' = c(0, 0, 0, 0, 1)
  )

  df_result <- add_shelter_issue_cat(df)
  expect_equal(df_result$snfi_shelter_issue_n, c(1, 1, 1, 1, 0))
  expect_equal(df_result$snfi_shelter_issue_cat, c("1_to_3", "1_to_3", "1_to_3", "1_to_3", "none"))
})

test_that("add_shelter_issue_cat handles NA values", {
  df <- tibble::tibble(
    snfi_shelter_issue = c("temperature", "ventilation", "leak", "lack_privacy", "none"),
    'snfi_shelter_issue/temperature' = c(1, 0, NA, 0, 0),
    'snfi_shelter_issue/ventilation' = c(0, 1, 0, NA, 0),
    'snfi_shelter_issue/leak' = c(0, 0, 1, 0, NA),
    'snfi_shelter_issue/lack_privacy' = c(0, NA, 0, 1, 0),
    'snfi_shelter_issue/lack_space' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/lock' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/lack_lighting' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/difficulty_move' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/dnk' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/pnta' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/other' = c(0, 0, 0, 0, 0),
    'snfi_shelter_issue/none' = c(NA, 0, 0, 0, 1)
  )

  df_result <- add_shelter_issue_cat(df)
  expect_equal(df_result$snfi_shelter_issue_n, c(1, 1, 1, 1, 0))
  expect_equal(df_result$snfi_shelter_issue_cat, c("1_to_3", "1_to_3", "1_to_3", "1_to_3", "none"))
})

test_that("add_shelter_issue_cat handles undefined values", {
  df <- tibble::tibble(
    snfi_shelter_issue = c("pnta", "lack_space", "temperature", "ventilation", "leak", "lock", "lack_lighting", "difficulty_move", "dnk", "other", "none"),
    'snfi_shelter_issue/lack_space' = c(0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/temperature' = c(0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/ventilation' = c(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/leak' = c(0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/lock' = c(0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/lack_lighting' = c(0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0),
    'snfi_shelter_issue/difficulty_move' = c(0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0),
    'snfi_shelter_issue/dnk' = c(0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0),
    'snfi_shelter_issue/other' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    'snfi_shelter_issue/none' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
    'snfi_shelter_issue/lack_privacy' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/pnta' = c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),


  )

  df_result <- add_shelter_issue_cat(df)
  expect_equal(df_result$snfi_shelter_issue_n[1], -999)
  expect_equal(df_result$snfi_shelter_issue_cat[1], "undefined")
})

test_that("add_shelter_issue_cat handles multiple issues", {
  df <- tibble::tibble(
    snfi_shelter_issue = c("temperature,leak", "lack_space", "temperature", "ventilation", "leak", "lock", "lack_lighting", "difficulty_move", "dnk", "pnta", "other", "none"),
    'snfi_shelter_issue/lack_space' = c(0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/temperature' = c(1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/ventilation' = c(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/leak' = c(1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/lock' = c(0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/lack_lighting' = c(0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/difficulty_move' = c(0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0),
    'snfi_shelter_issue/dnk' = c(0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0),
    'snfi_shelter_issue/pnta' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0),
    'snfi_shelter_issue/other' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    'snfi_shelter_issue/none' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
    'snfi_shelter_issue/lack_privacy' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )

  df_result <- add_shelter_issue_cat(df)
  expect_equal(df_result$snfi_shelter_issue_n[1], 2)
  expect_equal(df_result$snfi_shelter_issue_cat[1], "1_to_3")
})

test_that("add_shelter_issue_cat handles none values correctly", {
  df <- tibble::tibble(
    snfi_shelter_issue = c("lack_privacy", "none", "temperature", "ventilation", "leak", "lock", "lack_lighting", "difficulty_move", "dnk", "pnta", "other"),
    'snfi_shelter_issue/lack_privacy' = c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/temperature' = c(0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/ventilation' = c(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/leak' = c(0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/lock' = c(0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/lack_lighting' = c(0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0),
    'snfi_shelter_issue/difficulty_move' = c(0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0),
    'snfi_shelter_issue/dnk' = c(0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0),
    'snfi_shelter_issue/pnta' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    'snfi_shelter_issue/other' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
    'snfi_shelter_issue/none' = c(0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    'snfi_shelter_issue/lack_space' = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),

  )

  df_result <- add_shelter_issue_cat(df)
  expect_equal(df_result$snfi_shelter_issue_n[2], 0)
  expect_equal(df_result$snfi_shelter_issue_cat[2], "none")
})
