library(testthat)
library(dplyr)
library(rlang)

# Mock the helper functions if_not_in_stop and are_values_in_set
#if_not_in_stop <- function(df, cols, df_name) {
#  missing_cols <- setdiff(cols, colnames(df))
#  if (length(missing_cols) > 0) {
#    stop(paste("The following columns are not present in", df_name, ":", paste(missing_cols, collapse = ", ")), call. = FALSE)
#  }
#}
#
#are_values_in_set <- function(df, cols, valid_values) {
#  invalid_values <- unique(unlist(sapply(df[cols], function(col) setdiff(unique(col), valid_values))))
#  if (length(invalid_values) > 0) {
#    stop(paste("The following values are not valid in the specified columns:", paste(invalid_values, collapse = ", ")), call. = FALSE)
#  }
#}

# Mock add_loop_age_dummy function
#add_loop_age_dummy <- function(loop, ind_age, lb, ub, new_colname) {
#  loop %>% mutate(!!new_colname := ifelse(between(!!sym(ind_age), lb, ub), 1, 0))
#}

# Mock sum_vars function
#sum_vars <- function(df, vars, new_colname) {
#  df %>% mutate(!!new_colname := rowSums(select(df, all_of(vars)), na.rm = TRUE))
#}

test_that("add_loop_wgq_ss works with different levels of difficulty", {
  df <- data.frame(
    ind_age = c(10, 12, 7, 6, 20),
    wgq_vision = c("cannot_do", "some_difficulty", "no_difficulty", "lot_of_difficulty", "pnta"),
    wgq_hearing = c("lot_of_difficulty", "no_difficulty", "cannot_do", "some_difficulty", "dnk"),
    wgq_mobility = c("no_difficulty", "lot_of_difficulty", "some_difficulty", "cannot_do", "no_difficulty"),
    wgq_cognition = c("some_difficulty", "cannot_do", "lot_of_difficulty", "no_difficulty", "no_difficulty"),
    wgq_self_care = c("cannot_do", "some_difficulty", "no_difficulty", "lot_of_difficulty", "pnta"),
    wgq_communication = c("lot_of_difficulty", "no_difficulty", "cannot_do", "some_difficulty", "dnk")
  )

  result <- add_loop_wgq_ss(df)

  expected <- data.frame(
    ind_age = c(10, 12, 7, 6, 20),
    wgq_vision = c("cannot_do", "some_difficulty", "no_difficulty", "lot_of_difficulty", "pnta"),
    wgq_hearing = c("lot_of_difficulty", "no_difficulty", "cannot_do", "some_difficulty", "dnk"),
    wgq_mobility = c("no_difficulty", "lot_of_difficulty", "some_difficulty", "cannot_do", "no_difficulty"),
    wgq_cognition = c("some_difficulty", "cannot_do", "lot_of_difficulty", "no_difficulty", "no_difficulty"),
    wgq_self_care = c("cannot_do", "some_difficulty", "no_difficulty", "lot_of_difficulty", "pnta"),
    wgq_communication = c("lot_of_difficulty", "no_difficulty", "cannot_do", "some_difficulty", "dnk"),
    ind_age_above_5 = c(1, 1, 1, 1, 1),
    wgq_vision_cannot_do_d = c(1, 0, 0, 0, NA),
    wgq_hearing_cannot_do_d = c(0, 0, 1, 0, NA),
    wgq_mobility_cannot_do_d = c(0, 0, 0, 1, 0),
    wgq_cognition_cannot_do_d = c(0, 1, 0, 0, 0),
    wgq_self_care_cannot_do_d = c(1, 0, 0, 0, NA),
    wgq_communication_cannot_do_d = c(0, 0, 1, 0, NA),
    wgq_vision_lot_of_difficulty_d = c(0, 0, 0, 1, NA),
    wgq_hearing_lot_of_difficulty_d = c(1, 0, 0, 0, NA),
    wgq_mobility_lot_of_difficulty_d = c(0, 1, 0, 0, 0),
    wgq_cognition_lot_of_difficulty_d = c(0, 0, 1, 0, 0),
    wgq_self_care_lot_of_difficulty_d = c(0, 0, 0, 1, NA),
    wgq_communication_lot_of_difficulty_d = c(1, 0, 0, 0, NA),
    wgq_vision_some_difficulty_d = c(0, 1, 0, 0, NA),
    wgq_hearing_some_difficulty_d = c(0, 0, 0, 1, NA),
    wgq_mobility_some_difficulty_d = c(0, 0, 1, 0, 0),
    wgq_cognition_some_difficulty_d = c(1, 0, 0, 0, 0),
    wgq_self_care_some_difficulty_d = c(0, 1, 0, 0, NA),
    wgq_communication_some_difficulty_d = c(0, 0, 0, 1, NA),
    wgq_vision_no_difficulty_d = c(0, 0, 1, 0, NA),
    wgq_hearing_no_difficulty_d = c(0, 1, 0, 0, NA),
    wgq_mobility_no_difficulty_d = c(1, 0, 0, 0, 1),
    wgq_cognition_no_difficulty_d = c(0, 0, 0, 1, 1),
    wgq_self_care_no_difficulty_d = c(0, 0, 1, 0, NA),
    wgq_communication_no_difficulty_d = c(0, 1, 0, 0, NA),
    wgq_cannot_do_n = c(2, 1, 2, 1, 0),
    wgq_lot_of_difficulty_n = c(2, 1, 1, 1, 0),
    wgq_some_difficulty_n = c(1, 2, 1, 1, 0),
    wgq_no_difficulty_n = c(1, 1, 2, 1, 2),
    wgq_cannot_do_d = c(1, 1, 1, 1, 0),
    wgq_lot_of_difficulty_d = c(1, 1, 1, 1, 0),
    wgq_some_difficulty_d = c(1, 1, 1, 1, 0),
    wgq_no_difficulty_d = c(1, 1, 1, 1, 1),
    wgq_dis_4 = c(1, 1, 1, 1, 0),
    wgq_dis_3 = c(1, 1, 1, 1, 0),
    wgq_dis_2 = c(1, 1, 1, 1, 0),
    wgq_dis_1 = c(1, 1, 1, 1, 0)
  )

  expect_equal(result, expected)
})

test_that("add_loop_wgq_ss handles missing columns", {
  df <- data.frame(
    ind_age = c(10, 12, 7, 6, 20),
    wgq_vision = c("cannot_do", "some_difficulty", "no_difficulty", "lot_of_difficulty", "pnta"),
    wgq_hearing = c("lot_of_difficulty", "no_difficulty", "cannot_do", "some_difficulty", "dnk"),
    wgq_mobility = c("no_difficulty", "lot_of_difficulty", "some_difficulty", "cannot_do", "no_difficulty"),
    wgq_cognition = c("some_difficulty", "cannot_do", "lot_of_difficulty", "no_difficulty", "no_difficulty")
  )

  expect_error(add_loop_wgq_ss(df), "Missing columns\n• The following columns are missing in `loop`:  wgq_vision, wgq_self_care, and wgq_communication")
})

test_that("add_loop_wgq_ss handles invalid values", {
  df <- data.frame(
    ind_age = c(10, 12, 7, 6, 20),
    wgq_vision = c("cannot_do", "some_difficulty", "no_difficulty", "lot_of_difficulty", "invalid_value"),
    wgq_hearing = c("lot_of_difficulty", "no_difficulty", "cannot_do", "some_difficulty", "dnk"),
    wgq_mobility = c("no_difficulty", "lot_of_difficulty", "some_difficulty", "cannot_do", "no_difficulty"),
    wgq_cognition = c("some_difficulty", "cannot_do", "lot_of_difficulty", "no_difficulty", "no_difficulty"),
    wgq_self_care = c("cannot_do", "some_difficulty", "no_difficulty", "lot_of_difficulty", "pnta"),
    wgq_communication = c("lot_of_difficulty", "no_difficulty", "cannot_do", "some_difficulty", "dnk")
  )

  expect_error(add_loop_wgq_ss(df), "Missing columns\n• The following column is missing in `loop`:  wgq_vision")
})

test_that("add_loop_wgq_ss_to_main works correctly", {
  main <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C")
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3),
    wgq_dis_4 = c(1, 0, 0, 1, 0),
    wgq_dis_3 = c(0, 1, 0, 0, 1),
    wgq_dis_2 = c(0, 0, 1, 0, 0),
    wgq_dis_1 = c(1, 1, 1, 0, 1),
    ind_age_above_5 = c(1, 1, 1, 1, 1)
  )

  result <- add_loop_wgq_ss_to_main(main, loop)

  expected <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C"),
    wgq_dis_4_n = c(1, 0, 1),
    wgq_dis_3_n = c(1, 0, 1),
    wgq_dis_2_n = c(0, 1, 0),
    wgq_dis_1_n = c(1, 1, 0),
    ind_age_above_5_n = c(2, 1, 2),
    wgq_dis_4_at_least_one = c(1, 0, 1),
    wgq_dis_3_at_least_one = c(1, 0, 1),
    wgq_dis_2_at_least_one = c(1, 1, 1),
    wgq_dis_1_at_least_one = c(1, 1, 1)
  )

  expect_equal(result, expected)
})

test_that("add_loop_wgq_ss_to_main handles missing columns", {
  main <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C")
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3),
    wgq_dis_4 = c(1, 0, 0, 1, 0)
  )

  expect_error(add_loop_wgq_ss_to_main(main, loop), "Missing columns\n• The following columns are missing in `loop`: wgq_dis_3, wgq_dis_2, and wgq_dis_1")
})

test_that("add_loop_wgq_ss_to_main handles invalid values", {
  main <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C")
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3),
    wgq_dis_4 = c(1, 0, 0, 1, 0),
    wgq_dis_3 = c(0, 1, 0, 0, 1),
    wgq_dis_2 = c(0, 0, 1, 0, 0),
    wgq_dis_1 = c(1, 1, 1, 0, "invalid_value"),
    ind_age_above_5 = c(1, 1, 1, 1, 1)
  )

  expect_error(add_loop_wgq_ss_to_main(main, loop), "All columns must be in the following set: 0, 1\nℹ The following columns have values out of the set Please check.\nwgq_dis_1\n✖ The values out of the set are:\nwgq_dis_1: invalid_value")
})

test_that("add_loop_wgq_ss_to_main warns about existing columns", {
  main <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C"),
    wgq_dis_4_n = c(0, 0, 0)
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3),
    wgq_dis_4 = c(1, 0, 0, 1, 0),
    wgq_dis_3 = c(0, 1, 0, 0, 1),
    wgq_dis_2 = c(0, 0, 1, 0, 0),
    wgq_dis_1 = c(1, 1, 1, 0, 1),
    ind_age_above_5 = c(1, 1, 1, 1, 1)
  )

  expect_warning(
    add_loop_wgq_ss_to_main(main, loop),
    "wgq_dis_4_n already exists in 'main'. It will be replaced."
  )
})
