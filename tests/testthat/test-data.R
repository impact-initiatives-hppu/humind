library(testthat)
library(dplyr)

# Test for dummy_raw_data
test_that("dummy_raw_data is correctly structured", {
  expect_is(dummy_raw_data, "list")
  expect_named(dummy_raw_data, c("main", "roster", "edu_ind", "health_ind", "nut_ind"))

  # Test each component
  expect_is(dummy_raw_data$main, "data.frame")
  expect_is(dummy_raw_data$roster, "tbl_df")
  expect_is(dummy_raw_data$edu_ind, "tbl_df")
  expect_is(dummy_raw_data$health_ind, "tbl_df")
  expect_is(dummy_raw_data$nut_ind, "tbl_df")

  # Check for expected columns in each dataset
  expect_true("instance_name" %in% names(dummy_raw_data$main))
  expect_true("person_id" %in% names(dummy_raw_data$roster))
  expect_true("edu_person_id" %in% names(dummy_raw_data$edu_ind))
  expect_true("health_person_id" %in% names(dummy_raw_data$health_ind))
  expect_true("nut_person_id" %in% names(dummy_raw_data$nut_ind))

  # Check for non-empty datasets
  expect_gt(nrow(dummy_raw_data$main), 0)
  expect_gt(nrow(dummy_raw_data$roster), 0)
  expect_gt(nrow(dummy_raw_data$edu_ind), 0)
  expect_gt(nrow(dummy_raw_data$health_ind), 0)
  expect_gt(nrow(dummy_raw_data$nut_ind), 0)
})

# Test relationships between datasets
test_that("Relationships between datasets are consistent", {

  # Check if all individual_ids in edu_ind, health_ind, and nut_ind are in roster
  expect_true(all(unique(dummy_raw_data$edu_ind$edu_person_id) %in% dummy_raw_data$roster$person_id))
  expect_true(all(unique(dummy_raw_data$health_ind$health_person_id) %in% dummy_raw_data$roster$person_id))
  expect_true(all(unique(dummy_raw_data$nut_ind$nut_person_id) %in% dummy_raw_data$roster$person_id))

})

# Test data quality
test_that("Data quality checks pass", {
  # Check for missing values in key identifier columns
  expect_false(any(is.na(dummy_raw_data$main$instance_name)))
  expect_false(any(is.na(dummy_raw_data$roster$person_id)))

  # Check for duplicate identifiers
  expect_equal(nrow(dummy_raw_data$main), n_distinct(dummy_raw_data$main$instance_name))
  expect_equal(nrow(dummy_raw_data$roster), n_distinct(dummy_raw_data$roster$person_id))

  # Check for logical consistencies (example)
  if ("age" %in% names(dummy_raw_data$roster)) {
    expect_true(all(dummy_raw_data$roster$age >= 0))
  }

})
