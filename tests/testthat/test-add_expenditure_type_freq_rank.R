library(testthat)
library(dplyr)

# Dummy data for testing
dummy_data_top3 <- data.frame(
  uuid = 1:4,
  cm_expenditure_frequent_food = c(100, 200, 50, 200),
  cm_expenditure_frequent_rent = c(300, 100, 100, 50),
  cm_expenditure_frequent_water = c(50, 300, 200, 150),
  cm_expenditure_frequent_nfi = c(20, 20, 20, 20),
  cm_expenditure_frequent_utilitiues = c(10, 10, 10, 10),
  cm_expenditure_frequent_fuel = c(5, 5, 5, 5),
  cm_expenditure_frequent_transportation = c(0, 0, 0, 0),
  cm_expenditure_frequent_communication = c(0, 0, 0, 0),
  cm_expenditure_frequent_other = c(0, 0, 0, 0)
)


# 1. Test the function with default parameters
test_that("add_expenditure_type_freq_rank function works with default parameters", {
  result <- add_expenditure_type_freq_rank(dummy_data_top3)

  # Check if the top 3 expenditure types are identified correctly
  expect_equal(result$cm_freq_expenditure_top1, c("cm_expenditure_frequent_rent", "cm_expenditure_frequent_water", "cm_expenditure_frequent_water", "cm_expenditure_frequent_food"))
  expect_equal(result$cm_freq_expenditure_top2, c("cm_expenditure_frequent_food", "cm_expenditure_frequent_food", "cm_expenditure_frequent_rent", "cm_expenditure_frequent_water"))
  expect_equal(result$cm_freq_expenditure_top3, c("cm_expenditure_frequent_water", "cm_expenditure_frequent_rent", "cm_expenditure_frequent_food", "cm_expenditure_frequent_rent"))
})

# 2. Test handling of tied values
tied_values_data <- dummy_data_top3
tied_values_data$cm_expenditure_frequent_food <- c(100, 200, 50, 50)
tied_values_data$cm_expenditure_frequent_rent <- c(100, 100, 100, 50)

test_that("add_expenditure_type_freq_rank function handles tied values correctly", {
  result <- add_expenditure_type_freq_rank(tied_values_data)

  # Check if tied values are handled correctly
  expect_equal(result$cm_freq_expenditure_top1, c("cm_expenditure_frequent_food", "cm_expenditure_frequent_water", "cm_expenditure_frequent_water", "cm_expenditure_frequent_water"))
  expect_equal(result$cm_freq_expenditure_top2, c("cm_expenditure_frequent_rent", "cm_expenditure_frequent_food", "cm_expenditure_frequent_rent", "cm_expenditure_frequent_food"))
  expect_equal(result$cm_freq_expenditure_top3, c("cm_expenditure_frequent_water", "cm_expenditure_frequent_rent", "cm_expenditure_frequent_food", "cm_expenditure_frequent_rent"))
})

# 3. Test handling of missing columns
missing_column_data_top3 <- dummy_data_top3 %>% select(-cm_expenditure_frequent_food)

test_that("add_expenditure_type_freq_rank function handles missing columns", {
  expect_error(add_expenditure_type_freq_rank(missing_column_data_top3))
})

# 4. Test that expenditure types are numeric
non_numeric_data_top3 <- dummy_data_top3
non_numeric_data_top3$cm_expenditure_frequent_food <- as.character(non_numeric_data_top3$cm_expenditure_frequent_food)

test_that("add_expenditure_type_freq_rank function checks for numeric expenditure types", {
  expect_error(add_expenditure_type_freq_rank(non_numeric_data_top3))
})

