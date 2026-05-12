# Helper: one row with all dummy columns; override any param to set a specific scenario
make_df <- function(
  not_private = 0L,
  too_far = 0L,
  difficult_access = 0L,
  dangerous = 0L,
  disabilities = 0L,
  not_segregated = 0L,
  groups = 0L,
  dnk = 0L,
  pnta = 0L,
  other = 0L,
  facility = "pit_latrine_slab"
) {
  dplyr::tibble(
    wash_sanitation_facility = facility,
    wash_sanitation_access_issue = "no_problem",
    `wash_sanitation_access_issue/sanitation_not_private` = not_private,
    `wash_sanitation_access_issue/sanitation_too_far` = too_far,
    `wash_sanitation_access_issue/sanitation_difficult_access` = difficult_access,
    `wash_sanitation_access_issue/sanitation_dangerous_access` = dangerous,
    `wash_sanitation_access_issue/disabilities_no_access_sanitation` = disabilities,
    `wash_sanitation_access_issue/sanitation_not_segregated_gender` = not_segregated,
    `wash_sanitation_access_issue/groups_no_access_sanitation` = groups,
    `wash_sanitation_access_issue/dnk` = dnk,
    `wash_sanitation_access_issue/pnta` = pnta,
    `wash_sanitation_access_issue/other` = other,
    .name_repair = "minimal"
  )
}


#########################################
### add_sanitation_access_issue_physical
#########################################

test_that("add_sanitation_access_issue_physical returns wash_sanitation_access_issue_physical_d", {
  result <- add_sanitation_access_issue_physical(make_df())
  expect_true("wash_sanitation_access_issue_physical_d" %in% colnames(result))
})

test_that("output is integer type", {
  result <- add_sanitation_access_issue_physical(make_df())
  expect_type(result$wash_sanitation_access_issue_physical_d, "integer")
})

test_that("add_sanitation_access_issue_physical is 0L when no physical option selected", {
  result <- add_sanitation_access_issue_physical(make_df())
  expect_equal(result$wash_sanitation_access_issue_physical_d, 0L)
})

test_that("add_sanitation_access_issue_physical is 1L for each physical option individually", {
  df <- dplyr::bind_rows(
    make_df(not_private = 1L),
    make_df(too_far = 1L),
    make_df(difficult_access = 1L),
    make_df(dangerous = 1L),
    make_df(disabilities = 1L)
  )
  result <- add_sanitation_access_issue_physical(df)
  expect_equal(result$wash_sanitation_access_issue_physical_d, rep(1L, 5))
})

test_that("add_sanitation_access_issue_physical is NA for each undefined option", {
  df <- dplyr::bind_rows(
    make_df(dnk = 1L),
    make_df(pnta = 1L),
    make_df(other = 1L)
  )
  result <- add_sanitation_access_issue_physical(df)
  expect_true(all(is.na(result$wash_sanitation_access_issue_physical_d)))
})

test_that("add_sanitation_access_issue_physical is NA when sanitation_facility is 'none'", {
  result <- add_sanitation_access_issue_physical(make_df(facility = "none"))
  expect_true(is.na(result$wash_sanitation_access_issue_physical_d))
})

test_that("add_sanitation_access_issue_physical errors when base column is missing", {
  df <- dplyr::select(make_df(), -wash_sanitation_access_issue)
  expect_error(add_sanitation_access_issue_physical(df))
})

test_that("add_sanitation_access_issue_physical errors when a dummy column is missing", {
  df <- dplyr::select(
    make_df(),
    -`wash_sanitation_access_issue/sanitation_too_far`
  )
  expect_error(add_sanitation_access_issue_physical(df))
})


#########################################
### add_sanitation_access_issue_social
#########################################

test_that("add_sanitation_access_issue_social returns wash_sanitation_access_issue_social_d", {
  result <- add_sanitation_access_issue_social(make_df())
  expect_true("wash_sanitation_access_issue_social_d" %in% colnames(result))
})

test_that("output is integer type", {
  result <- add_sanitation_access_issue_social(make_df())
  expect_type(result$wash_sanitation_access_issue_social_d, "integer")
})

test_that("add_sanitation_access_issue_social is 0L when no social option selected", {
  result <- add_sanitation_access_issue_social(make_df())
  expect_equal(result$wash_sanitation_access_issue_social_d, 0L)
})

test_that("add_sanitation_access_issue_social is 1L for each social option individually", {
  df <- dplyr::bind_rows(
    make_df(not_segregated = 1L),
    make_df(groups = 1L)
  )
  result <- add_sanitation_access_issue_social(df)
  expect_equal(result$wash_sanitation_access_issue_social_d, rep(1L, 2))
})

test_that("add_sanitation_access_issue_social is NA for each undefined option", {
  df <- dplyr::bind_rows(
    make_df(dnk = 1L),
    make_df(pnta = 1L),
    make_df(other = 1L)
  )
  result <- add_sanitation_access_issue_social(df)
  expect_true(all(is.na(result$wash_sanitation_access_issue_social_d)))
})

test_that("add_sanitation_access_issue_social is NA when sanitation_facility is 'none'", {
  result <- add_sanitation_access_issue_social(make_df(facility = "none"))
  expect_true(is.na(result$wash_sanitation_access_issue_social_d))
})

test_that("add_sanitation_access_issue_social errors when base column is missing", {
  df <- dplyr::select(make_df(), -wash_sanitation_access_issue)
  expect_error(add_sanitation_access_issue_social(df))
})
