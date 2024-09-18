library(testthat)
library(dplyr)



test_that("add_quantile_interval works with default parameters", {

  df <- data.frame(
    num_col1 = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
    num_col2 = c(10000, 9000, 5000, 1000, 3000, 2000, 4000, 7000, 6000, 8000),
    weight = c(2, 2, 2, 2, 1, 1, 1, 1, 1, 1),
    group = c("rural", "urban"))


  result <- add_quantile_interval(df, vars = c("num_col1", "num_col2"))

  expected <- df |>
    mutate(
      num_col1_qtl = c("0%-20%", "0%-20%", "20%-40%", "20%-40%", "40%-60%", "40%-60%", "60%-80%", "60%-80%", "80%-100%", "80%-100%"),
      num_col2_qtl = c("80%-100%", "80%-100%", "40%-60%", "0%-20%", "20%-40%", "0%-20%", "20%-40%", "60%-80%", "40%-60%", "60%-80%")
    )

  expect_equal(result, expected)

})

test_that("add_quantile_interval handles all NA values", {

  df <- data.frame(
    num_col1 = c(NA_real_, NA_real_, NA_real_),
    num_col2 = c(NA_real_, NA_real_, NA_real_)
  )

  result <- add_quantile_interval(df, vars = c("num_col1", "num_col2"))

  expected <- df |>
    mutate(
      num_col1_qtl = NA_character_,
      num_col2_qtl = NA_character_
    )

  expect_equal(result, expected)

})

test_that("add_quantile_interval handles missing vars", {

  df <- data.frame(
    some_other_col = c(1, 2, 3)
  )

  expect_error(add_quantile_interval(df, vars = c("num_col1", "num_col2")), class = "error")

})

test_that("add_quantile_interval handles non-numeric columns", {

  df <- data.frame(
    num_col1 = c("a", "b", "c"),
    num_col2 = c("d", "e", "f")
  )

  expect_error(add_quantile_interval(df, vars = c("num_col1", "num_col2")), class = "error")

})

test_that("add_quantile_interval handles weights", {

  df <- data.frame(
    num_col1 = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
    num_col2 = c(10000, 9000, 5000, 1000, 3000, 2000, 4000, 7000, 6000, 8000),
    weight = c(2, 2, 2, 2, 1, 1, 1, 1, 1, 1),
    group = c("rural", "urban")
  )

  result <- add_quantile_interval(df, vars = c("num_col1", "num_col2"), weight = "weight")

  expected <- df |>
    mutate(
      num_col1_qtl = c("0%-20%", "20%-40%", "20%-40%", "40%-60%", "60%-80%", "60%-80%", "60%-80%", "80%-100%", "80%-100%", "80%-100%"),
      num_col2_qtl = c("80%-100%", "80%-100%", "40%-60%", "0%-20%", "20%-40%", "0%-20%", "20%-40%", "60%-80%", "40%-60%", "60%-80%")
    )

  expect_equal(result, expected)

})

test_that("add_quantile_interval handles missing weight column", {

  df <- data.frame(
    num_col1 = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
    num_col2 = c(10000, 9000, 5000, 1000, 3000, 2000, 4000, 7000, 6000, 8000),
    weight = c(2, 2, 2, 2, 1, 1, 1, 1, 1, 1),
    group = c("rural", "urban")
  )

  expect_error(add_quantile_interval(df, vars = c("num_col1", "num_col2"), weight = "weights"), class = "error")

})

