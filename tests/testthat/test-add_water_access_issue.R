# Helper: one row with all dummy columns set to 0 by default
make_df <- function(
  too_far = 0L,
  difficult_use = 0L,
  disability = 0L,
  safety = 0L,
  safety_travel = 0L,
  waiting_time = 0L,
  not_available = 0L,
  too_expensive = 0L,
  no_containers = 0L,
  dnk = 0L,
  pnta = 0L,
  other = 0L,
  source = "piped_water"
) {
  dplyr::tibble(
    wash_drinking_water_source = source,
    wash_water_access_issue = "no_problem_access_water",
    `wash_water_access_issue/waterpoints_too_far` = too_far,
    `wash_water_access_issue/waterpoints_difficult_use` = difficult_use,
    `wash_water_access_issue/disability_no_access_waterpoints` = disability,
    `wash_water_access_issue/safety_concerns_waterpoints` = safety,
    `wash_water_access_issue/safety_concerns_travel_waterpoints` = safety_travel,
    `wash_water_access_issue/excessive_waiting_time_waterpoints` = waiting_time,
    `wash_water_access_issue/water_not_available_market` = not_available,
    `wash_water_access_issue/water_too_expensive` = too_expensive,
    `wash_water_access_issue/not_enough_containers` = no_containers,
    `wash_water_access_issue/dnk` = dnk,
    `wash_water_access_issue/pnta` = pnta,
    `wash_water_access_issue/other` = other,
    .name_repair = "minimal"
  )
}


#########################################
### add_water_access_issue_physical
#########################################

test_that("add_water_access_issue_physical returns wash_water_access_issue_physical_d", {
  result <- add_water_access_issue_physical(make_df())
  expect_true("wash_water_access_issue_physical_d" %in% colnames(result))
})

test_that("output is integer type", {
  result <- add_water_access_issue_physical(make_df())
  expect_type(result$wash_water_access_issue_physical_d, "integer")
})

test_that("add_water_access_issue_physical is 0L when no physical option selected", {
  result <- add_water_access_issue_physical(make_df())
  expect_equal(result$wash_water_access_issue_physical_d, 0L)
})

test_that("add_water_access_issue_physical is 1L for each physical option individually", {
  df <- dplyr::bind_rows(
    make_df(too_far = 1L),
    make_df(difficult_use = 1L),
    make_df(disability = 1L),
    make_df(safety = 1L),
    make_df(safety_travel = 1L),
    make_df(waiting_time = 1L)
  )
  result <- add_water_access_issue_physical(df)
  expect_equal(result$wash_water_access_issue_physical_d, rep(1L, 6))
})

test_that("add_water_access_issue_physical is NA for each undefined option", {
  df <- dplyr::bind_rows(
    make_df(dnk = 1L),
    make_df(pnta = 1L),
    make_df(other = 1L)
  )
  result <- add_water_access_issue_physical(df)
  expect_true(all(is.na(result$wash_water_access_issue_physical_d)))
})

test_that("add_water_access_issue_physical is NA when water source is 'none'", {
  result <- add_water_access_issue_physical(make_df(source = "none"))
  expect_true(is.na(result$wash_water_access_issue_physical_d))
})

test_that("add_water_access_issue_physical errors when base column is missing", {
  df <- dplyr::select(make_df(), -wash_water_access_issue)
  expect_error(add_water_access_issue_physical(df))
})

test_that("add_water_access_issue_physical errors when a dummy column is missing", {
  df <- dplyr::select(
    make_df(),
    -`wash_water_access_issue/waterpoints_too_far`
  )
  expect_error(add_water_access_issue_physical(df))
})


#########################################
### add_water_access_issue_financial
#########################################

test_that("add_water_access_issue_financial returns wash_water_access_issue_financial_d", {
  result <- add_water_access_issue_financial(make_df())
  expect_true("wash_water_access_issue_financial_d" %in% colnames(result))
})

test_that("output is integer type", {
  result <- add_water_access_issue_financial(make_df())
  expect_type(result$wash_water_access_issue_financial_d, "integer")
})

test_that("add_water_access_issue_financial is 0L when no financial option selected", {
  result <- add_water_access_issue_financial(make_df())
  expect_equal(result$wash_water_access_issue_financial_d, 0L)
})

test_that("add_water_access_issue_financial is 1L for each financial option individually", {
  df <- dplyr::bind_rows(
    make_df(not_available = 1L),
    make_df(too_expensive = 1L),
    make_df(no_containers = 1L)
  )
  result <- add_water_access_issue_financial(df)
  expect_equal(result$wash_water_access_issue_financial_d, rep(1L, 3))
})

test_that("add_water_access_issue_financial is NA for each undefined option", {
  df <- dplyr::bind_rows(
    make_df(dnk = 1L),
    make_df(pnta = 1L),
    make_df(other = 1L)
  )
  result <- add_water_access_issue_financial(df)
  expect_true(all(is.na(result$wash_water_access_issue_financial_d)))
})

test_that("add_water_access_issue_financial is NA when water source is 'none'", {
  result <- add_water_access_issue_financial(make_df(source = "none"))
  expect_true(is.na(result$wash_water_access_issue_financial_d))
})

test_that("add_water_access_issue_financial errors when base column is missing", {
  df <- dplyr::select(make_df(), -wash_water_access_issue)
  expect_error(add_water_access_issue_financial(df))
})

test_that("add_water_access_issue_financial errors when a dummy column is missing", {
  df <- dplyr::select(
    make_df(),
    -`wash_water_access_issue/water_too_expensive`
  )
  expect_error(add_water_access_issue_financial(df))
})
