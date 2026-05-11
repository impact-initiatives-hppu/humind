# ---- add_cari: fsl_cari_current_status_cat ----

test_that("add_cari returns fsl_cari_current_status_cat column", {
  df <- dplyr::tibble(fsl_fcs_cat = "Acceptable", fsl_rcsi_score = 0)
  result <- add_cari(df)
  expect_true("fsl_cari_current_status_cat" %in% colnames(result))
})

test_that("Acceptable FCS + rCSI below 4 then 'food_secure'", {
  df <- dplyr::tibble(
    fsl_fcs_cat = rep("Acceptable", 4),
    fsl_rcsi_score = c(0, 1, 2, 3)
  )
  result <- add_cari(df)
  expect_equal(result$fsl_cari_current_status_cat, rep("food_secure", 4))
})

test_that("Acceptable FCS + rCSI at or above 4 then 'marginally_food_secure'", {
  df <- dplyr::tibble(
    fsl_fcs_cat = rep("Acceptable", 3),
    fsl_rcsi_score = c(4, 10, 18)
  )
  result <- add_cari(df)
  expect_equal(
    result$fsl_cari_current_status_cat,
    rep("marginally_food_secure", 3)
  )
})

test_that("rCSI cutoff at 4: score 3 then 'food_secure', score 4 then 'marginally_food_secure'", {
  df <- dplyr::tibble(
    fsl_fcs_cat = c("Acceptable", "Acceptable"),
    fsl_rcsi_score = c(3, 4)
  )
  result <- add_cari(df)
  expect_equal(
    result$fsl_cari_current_status_cat,
    c("food_secure", "marginally_food_secure")
  )
})

test_that("Borderline FCS then 'moderately_food_insecure' regardless of rCSI", {
  df <- dplyr::tibble(
    fsl_fcs_cat = rep("Borderline", 3),
    fsl_rcsi_score = c(0, 4, 20)
  )
  result <- add_cari(df)
  expect_equal(
    result$fsl_cari_current_status_cat,
    rep("moderately_food_insecure", 3)
  )
})

test_that("Poor FCS then 'severely_food_insecure' regardless of rCSI", {
  df <- dplyr::tibble(
    fsl_fcs_cat = rep("Poor", 3),
    fsl_rcsi_score = c(0, 4, 20)
  )
  result <- add_cari(df)
  expect_equal(
    result$fsl_cari_current_status_cat,
    rep("severely_food_insecure", 3)
  )
})

test_that("NA fsl_fcs_cat then NA output", {
  df <- dplyr::tibble(fsl_fcs_cat = NA_character_, fsl_rcsi_score = 0)
  result <- add_cari(df)
  expect_true(is.na(result$fsl_cari_current_status_cat))
})

test_that("NA fsl_rcsi_score with Acceptable FCS then NA output", {
  df <- dplyr::tibble(fsl_fcs_cat = "Acceptable", fsl_rcsi_score = NA_real_)
  result <- add_cari(df)
  expect_true(is.na(result$fsl_cari_current_status_cat))
})

test_that("NA fsl_rcsi_score with Borderline/Poor FCS then 'moderately_food_insecure'/'severely_food_insecure'", {
  df <- dplyr::tibble(
    fsl_fcs_cat = c("Borderline", "Poor"),
    fsl_rcsi_score = c(NA_real_, NA_real_)
  )
  result <- add_cari(df)
  expect_equal(
    result$fsl_cari_current_status_cat,
    c("moderately_food_insecure", "severely_food_insecure")
  )
})

test_that("add_cari errors on rCSI score out of 0-56 range", {
  df <- dplyr::tibble(fsl_fcs_cat = "Acceptable", fsl_rcsi_score = 57)
  expect_error(add_cari(df))
})

test_that("add_cari errors on missing fcs_cat column", {
  df <- dplyr::tibble(fsl_rcsi_score = 0)
  expect_error(add_cari(df))
})

test_that("add_cari errors on missing rcsi_score column", {
  df <- dplyr::tibble(fsl_fcs_cat = "Acceptable")
  expect_error(add_cari(df))
})

test_that("add_cari errors on non-numeric rcsi_score column", {
  df <- dplyr::tibble(fsl_fcs_cat = "Acceptable", fsl_rcsi_score = "high")
  expect_error(add_cari(df))
})

test_that("add_cari errors on invalid fcs_cat values", {
  df <- dplyr::tibble(fsl_fcs_cat = "Unknown", fsl_rcsi_score = 0)
  expect_error(add_cari(df))
})
