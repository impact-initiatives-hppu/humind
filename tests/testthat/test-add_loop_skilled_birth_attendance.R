# Helpers

make_loop <- function(
  gender = "female",
  age = 25,
  pregnancy_yn = "yes",
  birth_assistance = "doctor",
  uuid = "hh1"
) {
  dplyr::tibble(
    uuid = uuid,
    ind_gender = gender,
    ind_age = age,
    health_pregnancy_2years_yn = pregnancy_yn,
    health_birth_assistance = birth_assistance
  )
}

make_main <- function(uuid = "hh1") {
  dplyr::tibble(uuid = uuid)
}


#########################################
### add_loop_skilled_birth_attendance
#########################################

test_that("adds health_ind_live_birth_2years_d and health_ind_skilled_birth_attendance_d columns", {
  result <- add_loop_skilled_birth_attendance(make_loop())
  expect_true("health_ind_live_birth_2years_d" %in% colnames(result))
  expect_true("health_ind_skilled_birth_attendance_d" %in% colnames(result))
})

test_that("output columns are integer type", {
  result <- add_loop_skilled_birth_attendance(make_loop())
  expect_type(result$health_ind_live_birth_2years_d, "integer")
  expect_type(result$health_ind_skilled_birth_attendance_d, "integer")
})

test_that("live_birth_2years_d is 1L for female aged 15-49 with yes", {
  result <- add_loop_skilled_birth_attendance(make_loop(
    gender = "female",
    age = 25,
    pregnancy_yn = "yes"
  ))
  expect_equal(result$health_ind_live_birth_2years_d, 1L)
})

test_that("live_birth_2years_d is 0L for female aged 15-49 with no", {
  result <- add_loop_skilled_birth_attendance(make_loop(
    gender = "female",
    age = 25,
    pregnancy_yn = "no"
  ))
  expect_equal(result$health_ind_live_birth_2years_d, 0L)
})

test_that("live_birth_2years_d is 0L for male", {
  result <- add_loop_skilled_birth_attendance(make_loop(
    gender = "male",
    age = 25,
    pregnancy_yn = "yes"
  ))
  expect_equal(result$health_ind_live_birth_2years_d, 0L)
})

test_that("live_birth_2years_d is 0L for female outside reproductive age (below 15)", {
  result <- add_loop_skilled_birth_attendance(make_loop(
    gender = "female",
    age = 10,
    pregnancy_yn = "yes"
  ))
  expect_equal(result$health_ind_live_birth_2years_d, 0L)
})

test_that("live_birth_2years_d is 0L for female outside reproductive age (above 49)", {
  result <- add_loop_skilled_birth_attendance(make_loop(
    gender = "female",
    age = 55,
    pregnancy_yn = "yes"
  ))
  expect_equal(result$health_ind_live_birth_2years_d, 0L)
})

test_that("live_birth_2years_d is 1L at age boundary 15 and 49", {
  df <- dplyr::bind_rows(
    make_loop(age = 15, pregnancy_yn = "yes"),
    make_loop(age = 49, pregnancy_yn = "yes")
  )
  result <- add_loop_skilled_birth_attendance(df)
  expect_equal(result$health_ind_live_birth_2years_d, c(1L, 1L))
})

test_that("live_birth_2years_d is NA when pregnancy_yn is undefined", {
  df <- dplyr::bind_rows(
    make_loop(pregnancy_yn = "dnk"),
    make_loop(pregnancy_yn = "pnta")
  )
  result <- add_loop_skilled_birth_attendance(df)
  expect_true(all(is.na(result$health_ind_live_birth_2years_d)))
})

test_that("live_birth_2years_d is NA when gender is NA", {
  result <- add_loop_skilled_birth_attendance(make_loop(gender = NA_character_))
  expect_true(is.na(result$health_ind_live_birth_2years_d))
})

test_that("live_birth_2years_d is NA when age is NA", {
  result <- add_loop_skilled_birth_attendance(make_loop(age = NA_real_))
  expect_true(is.na(result$health_ind_live_birth_2years_d))
})

test_that("skilled_birth_attendance_d is 1L for each skilled personnel option", {
  df <- dplyr::bind_rows(
    make_loop(birth_assistance = "doctor"),
    make_loop(birth_assistance = "nurse"),
    make_loop(birth_assistance = "midwife")
  )
  result <- add_loop_skilled_birth_attendance(df)
  expect_equal(result$health_ind_skilled_birth_attendance_d, c(1L, 1L, 1L))
})

test_that("skilled_birth_attendance_d is 0L for non-skilled personnel", {
  df <- dplyr::bind_rows(
    make_loop(birth_assistance = "traditional_birth_attendant"),
    make_loop(birth_assistance = "relative_friend"),
    make_loop(birth_assistance = "none")
  )
  result <- add_loop_skilled_birth_attendance(df)
  expect_equal(result$health_ind_skilled_birth_attendance_d, c(0L, 0L, 0L))
})

test_that("skilled_birth_attendance_d is NA when birth_assistance is undefined", {
  df <- dplyr::bind_rows(
    make_loop(birth_assistance = "dnk"),
    make_loop(birth_assistance = "pnta"),
    make_loop(birth_assistance = "other")
  )
  result <- add_loop_skilled_birth_attendance(df)
  expect_true(all(is.na(result$health_ind_skilled_birth_attendance_d)))
})

test_that("skilled_birth_attendance_d is 0 when gender is not female", {
  result <- add_loop_skilled_birth_attendance(make_loop(gender = "male"))
  expect_equal(result$health_ind_skilled_birth_attendance_d, 0L)
  expect_equal(result$health_ind_live_birth_2years_d, 0L)
})

test_that("skilled_birth_attendance_d is 0 when no live birth (live_birth_d = 0L)", {
  result <- add_loop_skilled_birth_attendance(make_loop(pregnancy_yn = "no"))
  expect_true(result$health_ind_skilled_birth_attendance_d == 0L)
})

test_that("skilled_birth_attendance_d is NA when live_birth_d is NA", {
  result <- add_loop_skilled_birth_attendance(make_loop(pregnancy_yn = "dnk"))
  expect_true(is.na(result$health_ind_skilled_birth_attendance_d))
})

test_that("errors when required columns are missing", {
  df <- dplyr::tibble(uuid = "hh1", ind_gender = "female")
  expect_error(add_loop_skilled_birth_attendance(df))
})


#########################################
### add_loop_skilled_birth_attendance_to_main
#########################################

test_that("adds _n columns to main", {
  loop <- add_loop_skilled_birth_attendance(make_loop())
  result <- add_loop_skilled_birth_attendance_to_main(make_main(), loop)
  expect_true("health_ind_live_birth_2years_n" %in% colnames(result))
  expect_true("health_ind_skilled_birth_attendance_n" %in% colnames(result))
})

test_that("counts are correct for a single household", {
  loop <- dplyr::bind_rows(
    make_loop(pregnancy_yn = "yes", birth_assistance = "doctor"),
    make_loop(pregnancy_yn = "yes", birth_assistance = "nurse"),
    make_loop(pregnancy_yn = "no", birth_assistance = "doctor")
  ) |>
    add_loop_skilled_birth_attendance()
  result <- add_loop_skilled_birth_attendance_to_main(make_main(), loop)
  expect_equal(result$health_ind_live_birth_2years_n, 2L)
  expect_equal(result$health_ind_skilled_birth_attendance_n, 2L)
})

test_that("errors when loop is missing required columns", {
  loop <- dplyr::tibble(uuid = "hh1")
  expect_error(add_loop_skilled_birth_attendance_to_main(make_main(), loop))
})

test_that("NA when undefined responses for pregnancy_yn", {
  loop <- dplyr::bind_rows(
    make_loop(pregnancy_yn = "dnk"),
    make_loop(pregnancy_yn = "pnta")
  ) |>
    add_loop_skilled_birth_attendance()
  expect_equal(loop$health_ind_live_birth_2years_d, c(NA_integer_, NA_integer_))
})

test_that("aggregates to NA when there are undefined responses for pregnancy_yn", {
  loop <- dplyr::bind_rows(
    make_loop(pregnancy_yn = "dnk"),
    make_loop(pregnancy_yn = "pnta")
  ) |>
    add_loop_skilled_birth_attendance()
  result <- add_loop_skilled_birth_attendance_to_main(make_main(), loop)
  expect_equal(result$health_ind_live_birth_2years_n, NA_integer_)
  expect_equal(result$health_ind_skilled_birth_attendance_n, NA_integer_)
})

test_that("aggregates to 0 when there are no live births", {
  loop <- dplyr::bind_rows(
    make_loop(pregnancy_yn = "no"),
    make_loop(pregnancy_yn = "no")
  ) |>
    add_loop_skilled_birth_attendance()
  result <- add_loop_skilled_birth_attendance_to_main(make_main(), loop)
  expect_equal(result$health_ind_live_birth_2years_n, 0L)
  expect_equal(result$health_ind_skilled_birth_attendance_n, 0L)
})
