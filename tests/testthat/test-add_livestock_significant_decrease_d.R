test_that("add_livestock_significant_decrease_d creates all 8 dummy cols and composite", {
  df <- dplyr::tibble(
    uuid = "hh1",
    fsl_oxen_n_now = 5,
    fsl_oxen_n_ly = 10,
    fsl_camel_n_now = 5,
    fsl_camel_n_ly = 10,
    fsl_cattle_n_now = 5,
    fsl_cattle_n_ly = 10,
    fsl_horse_n_now = 5,
    fsl_horse_n_ly = 10,
    fsl_mule_n_now = 5,
    fsl_mule_n_ly = 10,
    fsl_sheep_n_now = 5,
    fsl_sheep_n_ly = 10,
    fsl_goat_n_now = 5,
    fsl_goat_n_ly = 10,
    fsl_poultry_n_now = 5,
    fsl_poultry_n_ly = 10
  )
  result <- add_livestock_significant_decrease_d(df)

  for (type in c(
    "oxen",
    "camel",
    "cattle",
    "horse",
    "mule",
    "sheep",
    "goat",
    "poultry"
  )) {
    expect_true(
      paste0("fsl_", type, "_significant_decrease_d") %in% colnames(result)
    )
  }
  expect_true("fsl_livestock_significant_decrease_d" %in% colnames(result))
})

test_that("add_livestock_significant_decrease_d: n_now < 50% of n_ly then 1", {
  # 70% decrease (3 from 10) -> 1
  df <- dplyr::tibble(fsl_sheep_n_now = 3, fsl_sheep_n_ly = 10)
  result <- add_livestock_significant_decrease_d(df, livestock = "sheep")
  expect_equal(result$fsl_sheep_significant_decrease_d, 1)
})

test_that("add_livestock_significant_decrease_d: n_now exactly 50% of n_ly then 1 (>= threshold)", {
  # 50% decrease (5 from 10) -> 1 (matches >= logic)
  df <- dplyr::tibble(fsl_sheep_n_now = 5, fsl_sheep_n_ly = 10)
  result <- add_livestock_significant_decrease_d(df, livestock = "sheep")
  expect_equal(result$fsl_sheep_significant_decrease_d, 1)
})

test_that("add_livestock_significant_decrease_d: n_now > 50% of n_ly then 0", {
  # 20% decrease (8 from 10) -> 0
  df <- dplyr::tibble(fsl_sheep_n_now = 8, fsl_sheep_n_ly = 10)
  result <- add_livestock_significant_decrease_d(df, livestock = "sheep")
  expect_equal(result$fsl_sheep_significant_decrease_d, 0)
})

test_that("add_livestock_significant_decrease_d: n_ly is 0 then 0", {
  # If you had 0 and now have 0, no decrease occurred.
  # NOTE: Ensure your function code returns 0 here, not NA.
  df <- dplyr::tibble(fsl_sheep_n_now = 0, fsl_sheep_n_ly = 0)
  result <- add_livestock_significant_decrease_d(df, livestock = "sheep")
  expect_equal(result$fsl_sheep_significant_decrease_d, 0)
})

test_that("add_livestock_significant_decrease_d: n_now NA then NA", {
  df <- dplyr::tibble(fsl_sheep_n_now = NA_real_, fsl_sheep_n_ly = 10)
  result <- add_livestock_significant_decrease_d(df, livestock = "sheep")
  expect_true(is.na(result$fsl_sheep_significant_decrease_d))
})

test_that("add_livestock_significant_decrease_d: n_ly NA then NA", {
  df <- dplyr::tibble(fsl_sheep_n_now = 3, fsl_sheep_n_ly = NA_real_)
  result <- add_livestock_significant_decrease_d(df, livestock = "sheep")
  expect_true(is.na(result$fsl_sheep_significant_decrease_d))
})

test_that("add_livestock_significant_decrease_d: missing livestock cols errors", {
  df <- dplyr::tibble(uuid = "hh1", fsl_sheep_n_now = 3, fsl_sheep_n_ly = 10)

  expect_error(
    add_livestock_significant_decrease_d(
      df,
      livestock = c("sheep", "goat")
    ),
    "missing in"
  )
})

test_that("add_livestock_significant_decrease_d: threshold parameter respected", {
  df <- dplyr::tibble(fsl_sheep_n_now = 6, fsl_sheep_n_ly = 10)
  # 40% decrease — not >= 50% threshold
  expect_equal(
    add_livestock_significant_decrease_d(
      df,
      livestock = "sheep"
    )$fsl_sheep_significant_decrease_d,
    0
  )
  # same data with 30% threshold (40% >= 30%) -> 1
  expect_equal(
    add_livestock_significant_decrease_d(
      df,
      livestock = "sheep",
      threshold = 0.3
    )$fsl_sheep_significant_decrease_d,
    1
  )
})

test_that("add_livestock_significant_decrease_d: warning if dummy output col already exists", {
  df <- dplyr::tibble(
    fsl_sheep_n_now = 3,
    fsl_sheep_n_ly = 10,
    fsl_sheep_significant_decrease_d = 99
  )
  expect_warning(
    add_livestock_significant_decrease_d(df, livestock = "sheep"),
    "already exist"
  )
})

test_that("add_livestock_significant_decrease_d: warning if composite output col already exists", {
  df <- dplyr::tibble(
    fsl_sheep_n_now = 3,
    fsl_sheep_n_ly = 10,
    fsl_livestock_significant_decrease_d = 99
  )
  expect_warning(
    add_livestock_significant_decrease_d(df, livestock = "sheep"),
    "already exist"
  )
})

test_that("add_livestock_significant_decrease_d composite: any == 1 then 1", {
  df <- dplyr::tibble(
    fsl_sheep_n_now = 2,
    fsl_sheep_n_ly = 10, # 1
    fsl_goat_n_now = 8,
    fsl_goat_n_ly = 10 # 0
  )
  result <- add_livestock_significant_decrease_d(
    df,
    livestock = c("sheep", "goat")
  )
  expect_equal(result$fsl_livestock_significant_decrease_d, 1)
})

test_that("add_livestock_significant_decrease_d composite: none == 1, some NA then 0", {
  df <- dplyr::tibble(
    fsl_sheep_n_now = 8,
    fsl_sheep_n_ly = 10, # 0
    fsl_goat_n_now = NA_real_,
    fsl_goat_n_ly = 10 # NA
  )
  result <- add_livestock_significant_decrease_d(
    df,
    livestock = c("sheep", "goat")
  )
  expect_equal(result$fsl_livestock_significant_decrease_d, 0)
})

test_that("add_livestock_significant_decrease_d composite: all NA then NA", {
  df <- dplyr::tibble(
    fsl_sheep_n_now = NA_real_,
    fsl_sheep_n_ly = NA_real_,
    fsl_goat_n_now = NA_real_,
    fsl_goat_n_ly = NA_real_
  )
  result <- add_livestock_significant_decrease_d(
    df,
    livestock = c("sheep", "goat")
  )
  expect_true(is.na(result$fsl_livestock_significant_decrease_d))
})

test_that("add_livestock_significant_decrease_d composite: mix of 1, 0, and NA results in 1", {
  # Critical test: Ensure 1 overrides NA and 0
  df <- dplyr::tibble(
    fsl_sheep_n_now = 2,
    fsl_sheep_n_ly = 10, # 1
    fsl_goat_n_now = NA_real_,
    fsl_goat_n_ly = 10, # NA
    fsl_cow_n_now = 8,
    fsl_cow_n_ly = 10 # 0
  )
  result <- add_livestock_significant_decrease_d(
    df,
    livestock = c("sheep", "goat", "cow")
  )
  expect_equal(result$fsl_livestock_significant_decrease_d, 1)
})

test_that("add_livestock_significant_decrease_d errors on negative values", {
  # are_values_in_range should catch this
  df <- dplyr::tibble(fsl_sheep_n_now = -1, fsl_sheep_n_ly = 10)
  expect_error(
    add_livestock_significant_decrease_d(df, livestock = "sheep"),
    "outside the range"
  )
})

test_that("add_livestock_significant_decrease_d errors if threshold is invalid", {
  df <- dplyr::tibble(fsl_sheep_n_now = 5, fsl_sheep_n_ly = 10)

  # Not numeric
  expect_error(add_livestock_significant_decrease_d(
    df,
    livestock = "sheep",
    threshold = "high"
  ))

  # Length > 1
  expect_error(add_livestock_significant_decrease_d(
    df,
    livestock = "sheep",
    threshold = c(0.5, 0.6)
  ))

  # < 0
  expect_error(add_livestock_significant_decrease_d(
    df,
    livestock = "sheep",
    threshold = -0.1
  ))

  # > 1
  expect_error(add_livestock_significant_decrease_d(
    df,
    livestock = "sheep",
    threshold = 1.1
  ))
})
