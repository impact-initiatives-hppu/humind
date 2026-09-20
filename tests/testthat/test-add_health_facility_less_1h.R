df <- dplyr::tibble(
  health_facility_time = c(0L, 30L, 59L, 60L, 90L, 120L, NA_integer_)
)

test_that("values strictly below 60 minutes are coded 1L", {
  result <- add_health_facility_less_1h(df)
  expect_equal(result$health_facility_less_1h[1:3], c(1L, 1L, 1L))
})

test_that("values at or above 60 minutes are coded 0L", {
  result <- add_health_facility_less_1h(df)
  expect_equal(result$health_facility_less_1h[4:6], c(0L, 0L, 0L))
})

test_that("output is integer type", {
  result <- add_health_facility_less_1h(df)
  expect_type(result$health_facility_less_1h, "integer")
})

test_that("fractional (non-integer) values raise an error", {
  df_frac <- dplyr::tibble(health_facility_time = c(59.9, 60.0, 60.1))
  expect_error(add_health_facility_less_1h(df_frac), class = "error")
})

test_that("NA inputs produce NA output", {
  result <- add_health_facility_less_1h(df)
  expect_true(is.na(result$health_facility_less_1h[7]))
})

test_that("negative values raise an error listing unique offending values", {
  df_neg <- dplyr::tibble(health_facility_time = c(30L, -1L, -42L))
  expect_error(add_health_facility_less_1h(df_neg), class = "error")
})

test_that("-999 raises an error (not silently recoded to NA)", {
  df_undef <- dplyr::tibble(health_facility_time = c(30L, -999L))
  expect_error(add_health_facility_less_1h(df_undef), class = "error")
})

test_that("missing column raises an error", {
  expect_error(
    add_health_facility_less_1h(df, health_facility_time = "missing_col"),
    class = "error"
  )
})

test_that("non-numeric column raises an error", {
  df_chr <- dplyr::tibble(health_facility_time = c("30", "60", "90"))
  expect_error(add_health_facility_less_1h(df_chr), class = "error")
})
