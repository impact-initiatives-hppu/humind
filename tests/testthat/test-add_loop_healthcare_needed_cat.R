# tests/testthat/test-add_loop_healthcare_needed_cat.R

library(testthat)
library(dplyr)

# Sample data for testing
loop <- data.frame(
  uuid = c(1, 2, 3, 4, 5, 6),
  health_ind_healthcare_needed = c("yes", "no", "dnk", "pnta", "yes", "no"),
  health_ind_healthcare_received = c("no", "yes", "dnk", "pnta", "yes", "no"),
  wgq_dis = c(1, 0, NA, NA, 1, 0),
  ind_age = c(25, 30, 2, 8, 12, 40),
  stringsAsFactors = FALSE
)

main <- data.frame(
  uuid = c(1, 2, 3, 4, 5, 6),
  stringsAsFactors = FALSE
)

# Test with default parameters for add_loop_healthcare_needed_cat
test_that("add_loop_healthcare_needed_cat works with default parameters", {
  result <- add_loop_healthcare_needed_cat(loop)
  expect_true(all(c("health_ind_healthcare_needed_d", "health_ind_healthcare_received_d",
                    "health_ind_healthcare_needed_cat", "health_ind_healthcare_needed_no",
                    "health_ind_healthcare_needed_yes_unmet", "health_ind_healthcare_needed_yes_met") %in% colnames(result)))
})

# Test with wgq_dis parameter for add_loop_healthcare_needed_cat
test_that("add_loop_healthcare_needed_cat works with wgq_dis parameter", {
  result <- add_loop_healthcare_needed_cat(loop, wgq_dis = "wgq_dis")
  expect_true(all(c("health_ind_healthcare_needed_no_wgq_dis", "health_ind_healthcare_needed_yes_unmet_wgq_dis",
                    "health_ind_healthcare_needed_yes_met_wgq_dis") %in% colnames(result)))
})

# Test if healthcare needed categories are calculated correctly
test_that("healthcare needed categories are calculated correctly", {
  result <- add_loop_healthcare_needed_cat(loop)
  expect_equal(result$health_ind_healthcare_needed_cat, c("yes_unmet_need", "no_need", NA, NA, "yes_met_need", "no_need"))
})

# Test if wgq_dis is correctly handled for children under 5
test_that("wgq_dis is correctly handled for children under 5", {
  loop_with_children <- loop
  loop_with_children$wgq_dis[loop_with_children$ind_age < 5] <- 1
  expect_error(add_loop_healthcare_needed_cat(loop_with_children, wgq_dis = "wgq_dis"), "If ind_age is below 5, then wgq_dis should be NA.")
})

# Test with default parameters for add_loop_healthcare_needed_cat_main
test_that("add_loop_healthcare_needed_cat_main works with default parameters", {
  loop_result <- add_loop_healthcare_needed_cat(loop)
  result <- add_loop_healthcare_needed_cat_to_main(main, loop_result)
  expect_true(all(c("health_ind_healthcare_needed_no_n", "health_ind_healthcare_needed_yes_unmet_n",
                    "health_ind_healthcare_needed_yes_met_n") %in% colnames(result)))
})

# Test with wgq_dis parameters for add_loop_healthcare_needed_cat_main
test_that("add_loop_healthcare_needed_cat_main works with wgq_dis parameters", {
  loop_result <- add_loop_healthcare_needed_cat(loop, wgq_dis = "wgq_dis")
  result <- add_loop_healthcare_needed_cat_to_main(
    main,
    loop_result,
    ind_healthcare_needed_no_wgq_dis = "health_ind_healthcare_needed_no_wgq_dis",
    ind_healthcare_needed_yes_unmet_wgq_dis = "health_ind_healthcare_needed_yes_unmet_wgq_dis",
    ind_healthcare_needed_yes_met_wgq_dis = "health_ind_healthcare_needed_yes_met_wgq_dis")
  expect_true(all(c("health_ind_healthcare_needed_no_wgq_dis_n", "health_ind_healthcare_needed_yes_unmet_wgq_dis_n",
                    "health_ind_healthcare_needed_yes_met_wgq_dis_n") %in% colnames(result)))
})

# Test if id columns are correctly handled
test_that("id columns are correctly handled", {
  expect_error(add_loop_healthcare_needed_cat_to_main(main, loop, id_col_main = "uuid", id_col_loop = "missing_id"), class = "error")
  expect_error(add_loop_healthcare_needed_cat_to_main(main, loop, id_col_main = "missing_id", id_col_loop = "uuid"), class = "error")
})

# Test if main data frame correctly joins with loop data frame
test_that("main data frame correctly joins with loop data frame", {
  loop_result <- add_loop_healthcare_needed_cat(loop)
  result <- add_loop_healthcare_needed_cat_to_main(main, loop_result)
  expect_equal(result$health_ind_healthcare_needed_no_n, c(0, 1, 0, 0, 0, 1))
  expect_equal(result$health_ind_healthcare_needed_yes_unmet_n, c(1, 0, 0, 0, 0, 0))
  expect_equal(result$health_ind_healthcare_needed_yes_met_n, c(0, 0, 0, 0, 1, 0))
})
