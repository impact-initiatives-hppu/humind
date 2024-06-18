library(testthat)
library(tibble)
library(humind)

# Sample Data
df <- tibble(
  id = 1:10,
  age = c(5, 15, 25, 35, 45, 55, 65, 75, 85, 95)
)

test_that("add_age_cat works as expected with default parameters", {
  result <- add_age_cat(df, "age")
  expect_true("age_cat" %in% names(result))
  expect_equal(length(unique(result$age_cat)), length(seq(0, 120, by = 5)) + 1,
               info = "Number of unique categories should match the number of breaks + 1")
})

test_that("add_age_cat works with custom parameters", {
  custom_breaks <- c(0, 20, 40, 60, 80, 100)
  custom_labels <- c("0-20", "21-40", "41-60", "61-80", "81-100")
  result <- add_age_cat(df, "age", breaks = custom_breaks, labels = custom_labels)
  expect_true("age_cat" %in% names(result))
  expect_equal(levels(result$age_cat), custom_labels,
               info = "Levels of age_cat should match custom_labels")
})

test_that("add_age_cat handles undefined values correctly", {
  df_with_undefined <- tibble(id = 1:3, age = c(-999, 25, 999))
  result <- add_age_cat(df_with_undefined, "age")
  expect_equal(result$age_cat[1], "undefined",
               info = "Undefined values should be replaced with 'undefined'")
})