# Create dummy data for testing
loop_data <- dplyr::tibble(
  uuid = c("id1", "id2", "id3", "id4"),
  ind_age = c(10, 12, 18, 3)
)

# id5 is intentionally absent from loop_data: the education loop only opens
# for households with at least one school-age child (the form gates the edu
# group on ind_age_schooling_n >= 1), so no loop rows exist for it.
main_data <- dplyr::tibble(
  uuid = c("id1", "id2", "id3", "id4", "id5"),
  start = as.Date(c(
    "2023-01-15",
    "2023-02-20",
    "2023-03-25",
    "2023-04-30",
    "2023-05-15"
  ))
)

test_that("Function runs with default parameters", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  expect_true("edu_ind_age_corrected" %in% colnames(result))
  expect_true("edu_ind_age_schooling" %in% colnames(result))
})

test_that("Function handles specific month correctly", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data, month = 3)
  expect_true(all(result$month == 3))
})

test_that("Function handles school year start month correctly", {
  result <- add_loop_edu_ind_age_corrected(
    loop_data,
    main_data,
    school_year_start_month = 1
  )
  expect_equal(result$edu_ind_age_corrected, c(10, 12, NA, NA))
})

test_that("Function handles missing age values", {
  loop_data_na <- loop_data
  loop_data_na$ind_age[1] <- NA
  result <- add_loop_edu_ind_age_corrected(loop_data_na, main_data)
  expect_true(any(is.na(result$edu_ind_age_corrected)))
})

test_that("Function handles missing columns", {
  loop_data_missing_col <- loop_data |>
    select(-ind_age)
  expect_error(add_loop_edu_ind_age_corrected(loop_data_missing_col, main_data))
})

test_that("Function calculates schooling age dummy variable correctly", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  expect_equal(result$edu_ind_age_schooling, c(1, 1, 0, 0))
})

test_that("Function adds correct columns to main data frame", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  main_result <- add_loop_edu_ind_schooling_age_d_to_main(main_data, result)
  expect_true("edu_schooling_age_n" %in% colnames(main_result))
})

test_that("Function calculates number of school-age children correctly", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  main_result <- add_loop_edu_ind_schooling_age_d_to_main(main_data, result)
  expect_equal(
    main_result$edu_schooling_age_n,
    c(
      1,
      1, # School-aged children
      0,
      0, # In loop but not of schooling age
      0 # No school-age children: the loop never opened for this household
    )
  )
})

test_that("To-main join returns 0 (not NA) for a household absent from the loop", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  main_result <- add_loop_edu_ind_schooling_age_d_to_main(main_data, result)
  expect_equal(
    main_result$edu_schooling_age_n[main_result$uuid == "id5"],
    0
  )
  expect_false(any(is.na(main_result$edu_schooling_age_n)))
})

test_that("In-loop zero and absent-from-loop zero are both encoded as 0", {
  result <- add_loop_edu_ind_age_corrected(loop_data, main_data)
  main_result <- add_loop_edu_ind_schooling_age_d_to_main(main_data, result)
  # id4: non-school-age member present in the loop (once open, the loop
  #   repeats over all household members): dummy 0 -> in-loop sum = 0
  # id5: no school-age children, so the loop never opened: no rows at all
  #   -> join miss coerced to 0
  expect_equal(
    main_result$edu_schooling_age_n[main_result$uuid == "id4"],
    main_result$edu_schooling_age_n[main_result$uuid == "id5"]
  )
})

# Shared data for schooling_end_age tests
# January survey dates ensure no age correction is applied
# (school_year_start_month = 9 -> adj = -3; month - adj = 4, not > 6),
# so these tests isolate the effect of schooling_end_age.
loop_data_end_age <- dplyr::tibble(
  uuid = c("id1", "id2", "id3", "id4", "id5", "id6"),
  ind_age = c(3, 5, 15, 16, 17, 18)
)

main_data_jan <- dplyr::tibble(
  uuid = c("id1", "id2", "id3", "id4", "id5", "id6"),
  start = as.Date(c(
    "2023-01-15",
    "2023-01-16",
    "2023-01-17",
    "2023-01-18",
    "2023-01-19",
    "2023-01-20"
  ))
)

test_that("schooling_end_age default keeps ages up to 17", {
  result <- add_loop_edu_ind_age_corrected(loop_data_end_age, main_data_jan)
  expect_equal(result$edu_ind_age_corrected, c(NA, 5, 15, 16, 17, NA))
  expect_equal(result$edu_ind_age_schooling, c(0, 1, 1, 1, 1, 0))
})

test_that("schooling_end_age = 16 excludes age 17", {
  result <- add_loop_edu_ind_age_corrected(
    loop_data_end_age,
    main_data_jan,
    schooling_end_age = 16
  )
  expect_equal(result$edu_ind_age_corrected, c(NA, 5, 15, 16, NA, NA))
  expect_equal(result$edu_ind_age_schooling, c(0, 1, 1, 1, 0, 0))
})

test_that("schooling_end_age = 18 includes age 18", {
  result <- add_loop_edu_ind_age_corrected(
    loop_data_end_age,
    main_data_jan,
    schooling_end_age = 18
  )
  expect_equal(result$edu_ind_age_corrected, c(NA, 5, 15, 16, 17, 18))
  expect_equal(result$edu_ind_age_schooling, c(0, 1, 1, 1, 1, 1))
})

test_that("schooling_end_age = 15 excludes ages 16 and 17", {
  result <- add_loop_edu_ind_age_corrected(
    loop_data_end_age,
    main_data_jan,
    schooling_end_age = 15
  )
  expect_equal(result$edu_ind_age_corrected, c(NA, 5, 15, NA, NA, NA))
  expect_equal(result$edu_ind_age_schooling, c(0, 1, 1, 0, 0, 0))
})
