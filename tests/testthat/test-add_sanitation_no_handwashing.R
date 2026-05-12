# ---- add_sanitation_no_handwashing ----

make_df <- function(
  sanitation_jmp = "basic",
  handwashing_jmp = "basic"
) {
  dplyr::tibble(
    wash_sanitation_facility_jmp_cat = sanitation_jmp,
    wash_handwashing_facility_jmp_cat = handwashing_jmp
  )
}


#########################################
### add_sanitation_no_handwashing
#########################################

test_that("adds wash_sanitation_no_handwashing_d column", {
  result <- add_sanitation_no_handwashing(make_df())
  expect_true("wash_sanitation_no_handwashing_d" %in% colnames(result))
})

test_that("output is integer type", {
  result <- add_sanitation_no_handwashing(make_df())
  expect_type(result$wash_sanitation_no_handwashing_d, "integer")
})

test_that("is 1L when sanitation is open_defecation and no handwashing facility", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_jmp = "open_defecation", handwashing_jmp = "no_facility")
  )
  expect_equal(result$wash_sanitation_no_handwashing_d, 1L)
})

test_that("is 1L when sanitation is unimproved and no handwashing facility", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_jmp = "unimproved", handwashing_jmp = "no_facility")
  )
  expect_equal(result$wash_sanitation_no_handwashing_d, 1L)
})

test_that("is 0L when sanitation is improved regardless of handwashing", {
  df <- dplyr::bind_rows(
    make_df(sanitation_jmp = "basic", handwashing_jmp = "no_facility"),
    make_df(sanitation_jmp = "limited", handwashing_jmp = "no_facility")
  )
  result <- add_sanitation_no_handwashing(df)
  expect_equal(result$wash_sanitation_no_handwashing_d, c(0L, 0L))
})

test_that("is 0L when sanitation is unimproved but handwashing facility exists", {
  df <- dplyr::bind_rows(
    make_df(sanitation_jmp = "unimproved", handwashing_jmp = "basic"),
    make_df(sanitation_jmp = "unimproved", handwashing_jmp = "limited")
  )
  result <- add_sanitation_no_handwashing(df)
  expect_equal(result$wash_sanitation_no_handwashing_d, c(0L, 0L))
})

test_that("is NA when sanitation category is undefined", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_jmp = "undefined", handwashing_jmp = "no_facility")
  )
  expect_true(is.na(result$wash_sanitation_no_handwashing_d))
})

test_that("is NA when handwashing category is undefined", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_jmp = "unimproved", handwashing_jmp = "undefined")
  )
  expect_true(is.na(result$wash_sanitation_no_handwashing_d))
})

test_that("is NA when sanitation category is NA", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_jmp = NA_character_, handwashing_jmp = "no_facility")
  )
  expect_true(is.na(result$wash_sanitation_no_handwashing_d))
})

test_that("is NA when handwashing category is NA", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_jmp = "unimproved", handwashing_jmp = NA_character_)
  )
  expect_true(is.na(result$wash_sanitation_no_handwashing_d))
})

test_that("errors when sanitation_jmp_cat column is missing", {
  df <- dplyr::tibble(wash_handwashing_facility_jmp_cat = "basic")
  expect_error(add_sanitation_no_handwashing(df))
})

test_that("errors when handwashing_jmp_cat column is missing", {
  df <- dplyr::tibble(wash_sanitation_facility_jmp_cat = "basic")
  expect_error(add_sanitation_no_handwashing(df))
})
