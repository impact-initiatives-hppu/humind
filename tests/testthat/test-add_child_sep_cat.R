library(testthat)
library(dplyr)

# Sample data for testing
df <- tibble::tibble(
  id = 1:4,
  prot_child_sep = c("yes", "no", "pnta", "yes"),
  prot_child_sep_reason = c("left_study", "left_married", "other", "left_armed_groups"),
  "prot_child_sep_reason/left_study" = c(1, 0, 0, 0),
  "prot_child_sep_reason/left_married" = c(0, 1, 0, 0),
  "prot_child_sep_reason/left_armed_groups" = c(0, 0, 0, 1),
  "prot_child_sep_reason/other" = c(0, 0, 1, 0),
  "prot_child_sep_reason/left_employment" = c(0, 0, 0, 0),
  "prot_child_sep_reason/kidnapped" = c(0, 0, 0, 0),
  "prot_child_sep_reason/missing" = c(0, 0, 0, 0),
  "prot_child_sep_reason/detained" = c(0, 0, 0, 0),
  "prot_child_sep_reason/stayed_in_origin" = c(0, 0, 0, 0),
  "prot_child_sep_reason/separated_displacement" = c(0, 0, 0, 0),
  "prot_child_sep_reason/dnk" = c(0, 0, 0, 0),
  "prot_child_sep_reason/pnta" = c(0, 0, 0, 0)
)

test_that("add_child_sep_cat correctly categorizes child separation", {
  result <- add_child_sep_cat(df)

  expect_equal(result$prot_child_sep_cat[1], "at_least_non_severe")
  expect_equal(result$prot_child_sep_cat[2], "none")
  expect_equal(result$prot_child_sep_cat[3], "undefined")
  expect_equal(result$prot_child_sep_cat[4], "at_least_very_severe")
})

test_that("add_child_sep_cat handles undefined child separation responses", {
  df_undefined <- df
  df_undefined$prot_child_sep <- c("pnta", "dnk", "pnta", "dnk")

  result <- add_child_sep_cat(df_undefined)

  expect_true(all(result$prot_child_sep_cat == "undefined"))
})

test_that("add_child_sep_cat correctly handles severity of reasons", {
  df_severe <- df
  df_severe$prot_child_sep_reason <- c("left_study", "left_employment", "left_armed_groups", "kidnapped")
  df_severe[["prot_child_sep_reason/left_employment"]] <- c(0, 1, 0, 0)
  df_severe[["prot_child_sep_reason/kidnapped"]] <- c(0, 0, 0, 1)

  result <- add_child_sep_cat(df_severe)

  expect_equal(result$prot_child_sep_cat[1], "at_least_non_severe")
  expect_equal(result$prot_child_sep_cat[2], "at_least_severe")
  expect_equal(result$prot_child_sep_cat[3], "at_least_very_severe")
  expect_equal(result$prot_child_sep_cat[4], "at_least_very_severe")
})

test_that("add_child_sep_cat handles edge cases", {
  df_edge <- df[1:2,]
  df_edge$prot_child_sep <- c("yes", "yes")
  df_edge$prot_child_sep_reason <- c("other", "missing")
  df_edge[["prot_child_sep_reason/other"]] <- c(1, 0)
  df_edge[["prot_child_sep_reason/missing"]] <- c(0, 1)

  result <- add_child_sep_cat(df_edge)

  expect_equal(result$prot_child_sep_cat[1], "undefined")
  expect_equal(result$prot_child_sep_cat[2], "at_least_very_severe")
})
