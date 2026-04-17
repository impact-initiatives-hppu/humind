df <- dplyr::tibble(
  health_facility_time = c(0, 30, 59, 60, 90, 120, NA_real_)
)

test_that("values strictly below 60 minutes are coded 1", {
  result <- add_health_facility_less_1h(df)
  expect_equal(result$health_facility_less_1h[1:3], c(1, 1, 1))
})

test_that("values at or above 60 minutes are coded 0", {
  result <- add_health_facility_less_1h(df)
  expect_equal(result$health_facility_less_1h[4:6], c(0, 0, 0))
})

test_that("fractional values are handled correctly", {
  df_frac <- dplyr::tibble(health_facility_time = c(59.9, 60.0, 60.1))
  result <- add_health_facility_less_1h(df_frac)
  expect_equal(result$health_facility_less_1h, c(1, 0, 0))
})

test_that("NA inputs produce NA output", {
  result <- add_health_facility_less_1h(df)
  expect_true(is.na(result$health_facility_less_1h[7]))
})

test_that("default undefined code -999 is recoded to NA via the < 0 branch", {
  df_undef <- dplyr::tibble(health_facility_time = c(30, -999))
  result <- add_health_facility_less_1h(df_undef)
  expect_equal(result$health_facility_less_1h, c(1, NA_real_))
})

test_that("custom positive undefined code is recoded to NA", {
  df_undef <- dplyr::tibble(health_facility_time = c(30, 999))
  result <- add_health_facility_less_1h(df_undef, undefined = 999)
  expect_equal(result$health_facility_less_1h, c(1, NA_real_))
})

test_that("negative values other than -999 are recoded to NA", {
  df_neg <- dplyr::tibble(health_facility_time = c(30, -1, -42))
  result <- add_health_facility_less_1h(df_neg)
  expect_equal(
    result$health_facility_less_1h,
    c(1, NA_real_, NA_real_)
  )
})

test_that("missing column raises an error", {
  expect_error(
    add_health_facility_less_1h(
      df,
      health_facility_time = "missing_col"
    ),
    class = "error"
  )
})

test_that("non-numeric column raises an error", {
  df_chr <- dplyr::tibble(health_facility_time = c("30", "60", "90"))
  expect_error(
    add_health_facility_less_1h(df_chr),
    class = "error"
  )
})
