library(testthat)
library(tibble)
library(humind)

# Sample Data
df <- tibble(
  id = 1:12,
  age = c(0, 5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 121)
)

test_that("add_age_cat works as expected with default parameters", {
  result <- add_age_cat(df, "age", breaks = c(0, 18, 60, 120))
  expect_true("age_cat" %in% names(result))
  expect_equal(length(unique(result$age_cat)), length(c(0, 18, 60, 120)))
})

test_that("add_age_cat assigns correct ages to correct groups", {
  custom_breaks <- c(0, 5, 10, 18, 100)
  custom_labels <- c("0-4", "5-9", "10-17", "18-99", "100+")

  result <- add_age_cat(df, "age", breaks = custom_breaks, labels = custom_labels)

  expected_categories <- c("0-4", "5-9", "10-17", "18-99", "18-99", "18-99", "18-99", "18-99", "18-99", "18-99", "18-99", "100+")

  expect_equal(result$age_cat, expected_categories,
               info = "Ages should be assigned to the correct categories")
})

test_that("add_age_cat works with custom parameters", {
  custom_breaks <- c(5, 20, 40, 60, 80, 100)
  custom_labels <- c("5-19", "20-39", "40-59", "60-79", "80-99", "100+")
  result <- add_age_cat(df, "age", breaks = custom_breaks, labels = custom_labels)
  expect_true("age_cat" %in% names(result))
  expect_equal(as.vector(na.omit(unique(result$age_cat))), custom_labels,
               info = "Levels of age_cat should match custom_labels")
})

test_that("add_age_cat handles undefined values correctly", {
  df_with_undefined <- tibble(id = 1:3, age = c(-999, 25, 999))
  result <- add_age_cat(df_with_undefined, "age")
  expect_equal(result$age_cat[1], "undefined",
               info = "Undefined values should be replaced with 'undefined'")
})

