library(testthat)
library(dplyr)
library(rlang)
library(glue)

# Example test data
df <- data.frame(
  score = c(1, 2, 3, 4, 5),
  other_var = c("a", "b", "c", "d", "e")
)

df_missing_score <- data.frame(
  other_var = c("a", "b", "c", "d", "e")
)

df_out_of_set <- data.frame(
  score = c(0, 2, 3, 4, 6),
  other_var = c("a", "b", "c", "d", "e")
)

# Test cases
test_that("is_in_need works with default parameters", {
  df_result <- is_in_need(df, "score")
  expect_equal(names(df_result), c("score", "other_var", "score_in_need"))
  expect_equal(df_result$score_in_need, c(0, 0, 1, 1, 1))
})

test_that("is_in_need handles missing 'score' column", {
  expect_error(is_in_need(df_missing_score, "score"), class = "error")
})

test_that("is_in_need handles values out of set (1:5)", {
  expect_error(is_in_need(df_out_of_set, "score"), class = "error")
})

test_that("is_in_need creates a new column with custom name", {
  df_result <- is_in_need(df, "score", new_colname = "need_status")
  expect_equal(names(df_result), c("score", "other_var", "need_status"))
  expect_equal(df_result$need_status, c(0, 0, 1, 1, 1))
})

test_that("is_in_need warns when new column name already exists", {
  df$score_in_need <- rep(0, nrow(df))
  withCallingHandlers(
    is_in_need(df, "score"),
    warning = function(w) {
      expect_match(w$message, "score_in_need already exists in the data frame.")
    }
  )
})

