library(testthat)
library(dplyr)

# Test for dummy_raw_data
test_that("dummy_raw_data is correctly structured", {
  expect_is(dummy_raw_data, "list")
  expect_named(dummy_raw_data, c("main", "roster", "edu_ind", "health_ind", "nut_ind"))

  # Test each component
  expect_is(dummy_raw_data$main, "tbl_df")
  expect_is(dummy_raw_data$roster, "tbl_df")
  expect_is(dummy_raw_data$edu_ind, "tbl_df")
  expect_is(dummy_raw_data$health_ind, "tbl_df")
  expect_is(dummy_raw_data$nut_ind, "tbl_df")

  # Check for expected columns in each dataset
  expect_true("household_id" %in% names(dummy_raw_data$main))
  expect_true("individual_id" %in% names(dummy_raw_data$roster))
  expect_true("individual_id" %in% names(dummy_raw_data$edu_ind))
  expect_true("individual_id" %in% names(dummy_raw_data$health_ind))
  expect_true("individual_id" %in% names(dummy_raw_data$nut_ind))

  # Check for non-empty datasets
  expect_gt(nrow(dummy_raw_data$main), 0)
  expect_gt(nrow(dummy_raw_data$roster), 0)
  expect_gt(nrow(dummy_raw_data$edu_ind), 0)
  expect_gt(nrow(dummy_raw_data$health_ind), 0)
  expect_gt(nrow(dummy_raw_data$nut_ind), 0)
})

# Test for loa
test_that("loa is correctly structured", {
  expect_is(loa, "tbl_df")
  expect_gt(nrow(loa), 0)
  expect_gt(ncol(loa), 0)

  # Check for expected columns (adjust these based on your actual data)
  expected_columns <- c("indicator", "sector", "level")
  expect_true(all(expected_columns %in% names(loa)))
})

# Test for survey_update
test_that("survey_update is correctly structured", {
  expect_is(survey_update, "tbl_df")
  expect_gt(nrow(survey_update), 0)
  expect_gt(ncol(survey_update), 0)

  # Check for expected columns (adjust these based on your actual data)
  expected_columns <- c("name", "type", "label")
  expect_true(all(expected_columns %in% names(survey_update)))
})

# Test for choices_update
test_that("choices_update is correctly structured", {
  expect_is(choices_update, "tbl_df")
  expect_gt(nrow(choices_update), 0)
  expect_gt(ncol(choices_update), 0)

  # Check for expected columns (adjust these based on your actual data)
  expected_columns <- c("list_name", "name", "label")
  expect_true(all(expected_columns %in% names(choices_update)))
})

# Test relationships between datasets
test_that("Relationships between datasets are consistent", {
  # Check if all household_ids in roster are in main
  expect_true(all(unique(dummy_raw_data$roster$household_id) %in% dummy_raw_data$main$household_id))

  # Check if all individual_ids in edu_ind, health_ind, and nut_ind are in roster
  expect_true(all(unique(dummy_raw_data$edu_ind$individual_id) %in% dummy_raw_data$roster$individual_id))
  expect_true(all(unique(dummy_raw_data$health_ind$individual_id) %in% dummy_raw_data$roster$individual_id))
  expect_true(all(unique(dummy_raw_data$nut_ind$individual_id) %in% dummy_raw_data$roster$individual_id))

  # Check if all list_names in choices_update are used in survey_update
  choices_lists <- unique(choices_update$list_name)
  survey_select_ones <- survey_update %>%
    filter(type %in% c("select_one", "select_multiple")) %>%
    mutate(list_name = sub("^select_[a-z]+ ", "", type)) %>%
    pull(list_name)
  expect_true(all(choices_lists %in% survey_select_ones))
})

# Test data quality
test_that("Data quality checks pass", {
  # Check for missing values in key identifier columns
  expect_false(any(is.na(dummy_raw_data$main$household_id)))
  expect_false(any(is.na(dummy_raw_data$roster$individual_id)))

  # Check for duplicate identifiers
  expect_equal(nrow(dummy_raw_data$main), n_distinct(dummy_raw_data$main$household_id))
  expect_equal(nrow(dummy_raw_data$roster), n_distinct(dummy_raw_data$roster$individual_id))

  # Check for logical consistencies (example)
  if ("age" %in% names(dummy_raw_data$roster)) {
    expect_true(all(dummy_raw_data$roster$age >= 0))
  }

  # Check for valid categories in choices
  if ("name" %in% names(choices_update) && "list_name" %in% names(choices_update)) {
    expect_true(all(!is.na(choices_update$name)))
    expect_true(all(!is.na(choices_update$list_name)))
  }
})
