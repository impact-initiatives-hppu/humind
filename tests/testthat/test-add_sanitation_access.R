# Helper: one row with all dummy columns; override any param to set a specific scenario
make_df <- function(
  not_private = 0L,
  too_far = 0L,
  difficult_access = 0L,
  dangerous = 0L,
  disabilities = 0L,
  not_segregated = 0L,
  groups = 0L,
  crowded = 0L,
  not_functioning = 0L,
  unclean = 0L,
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
    `wash_sanitation_access_issue/lack_sanitation_facilities_crowded` = crowded,
    `wash_sanitation_access_issue/sanitation_not_functioning_full` = not_functioning,
    `wash_sanitation_access_issue/sanitation_unclean_unhygienic` = unclean,
    `wash_sanitation_access_issue/dnk` = dnk,
    `wash_sanitation_access_issue/pnta` = pnta,
    `wash_sanitation_access_issue/other` = other,
    .name_repair = "minimal"
  )
}


############################################################
### add_sanitation_access_issue_physical_safety
############################################################

test_that("add_sanitation_access_issue_physical_safety returns wash_sanitation_access_issue_physical_safety_d", {
  result <- add_sanitation_access_issue_physical_safety(make_df())
  expect_true(
    "wash_sanitation_access_issue_physical_safety_d" %in% colnames(result)
  )
})

test_that("output is integer type", {
  result <- add_sanitation_access_issue_physical_safety(make_df())
  expect_type(
    result$wash_sanitation_access_issue_physical_safety_d,
    "integer"
  )
})

test_that("add_sanitation_access_issue_physical_safety is 0L when no physical/safety option selected", {
  result <- add_sanitation_access_issue_physical_safety(make_df())
  expect_equal(result$wash_sanitation_access_issue_physical_safety_d, 0L)
})

test_that("add_sanitation_access_issue_physical_safety is 1L for each physical/safety option individually", {
  df <- dplyr::bind_rows(
    make_df(not_private = 1L),
    make_df(too_far = 1L),
    make_df(difficult_access = 1L),
    make_df(dangerous = 1L),
    make_df(disabilities = 1L),
    make_df(not_segregated = 1L),
    make_df(groups = 1L)
  )
  result <- add_sanitation_access_issue_physical_safety(df)
  expect_equal(
    result$wash_sanitation_access_issue_physical_safety_d,
    rep(1L, 7)
  )
})

test_that("add_sanitation_access_issue_physical_safety is NA for each undefined option", {
  df <- dplyr::bind_rows(
    make_df(dnk = 1L),
    make_df(pnta = 1L),
    make_df(other = 1L)
  )
  result <- add_sanitation_access_issue_physical_safety(df)
  expect_true(all(is.na(result$wash_sanitation_access_issue_physical_safety_d)))
})

test_that("add_sanitation_access_issue_physical_safety is NA when a component binary is missing", {
  df <- dplyr::bind_rows(
    make_df(too_far = NA_integer_),
    make_df(too_far = NA_integer_, dangerous = NA_integer_)
  )
  result <- add_sanitation_access_issue_physical_safety(df)
  expect_true(all(is.na(result$wash_sanitation_access_issue_physical_safety_d)))
})

test_that("add_sanitation_access_issue_physical_safety is NA when all component binaries are missing", {
  result <- add_sanitation_access_issue_physical_safety(
    make_df(
      not_private = NA_integer_,
      too_far = NA_integer_,
      difficult_access = NA_integer_,
      dangerous = NA_integer_,
      disabilities = NA_integer_,
      not_segregated = NA_integer_,
      groups = NA_integer_
    )
  )
  expect_true(is.na(result$wash_sanitation_access_issue_physical_safety_d))
})

test_that("add_sanitation_access_issue_physical_safety ignores a 'none' sanitation_facility", {
  result <- dplyr::bind_rows(
    make_df(too_far = 1L, facility = "none"),
    make_df(facility = "none")
  )
  result <- add_sanitation_access_issue_physical_safety(result)
  expect_equal(
    result$wash_sanitation_access_issue_physical_safety_d,
    c(1L, 0L)
  )
})

test_that("add_sanitation_access_issue_physical_safety errors when base column is missing", {
  df <- dplyr::select(make_df(), -wash_sanitation_access_issue)
  expect_error(add_sanitation_access_issue_physical_safety(df))
})

test_that("add_sanitation_access_issue_physical_safety errors when a dummy column is missing", {
  df <- dplyr::select(
    make_df(),
    -`wash_sanitation_access_issue/sanitation_too_far`
  )
  expect_error(add_sanitation_access_issue_physical_safety(df))
})


############################################################
### add_sanitation_access_issue_hygiene_functionality
############################################################

test_that("add_sanitation_access_issue_hygiene_functionality returns wash_sanitation_access_issue_hygiene_functionality_d", {
  result <- add_sanitation_access_issue_hygiene_functionality(make_df())
  expect_true(
    "wash_sanitation_access_issue_hygiene_functionality_d" %in% colnames(result)
  )
})

test_that("output is integer type", {
  result <- add_sanitation_access_issue_hygiene_functionality(make_df())
  expect_type(
    result$wash_sanitation_access_issue_hygiene_functionality_d,
    "integer"
  )
})

test_that("add_sanitation_access_issue_hygiene_functionality is 0L when no hygiene/functionality option selected", {
  result <- add_sanitation_access_issue_hygiene_functionality(make_df())
  expect_equal(
    result$wash_sanitation_access_issue_hygiene_functionality_d,
    0L
  )
})

test_that("add_sanitation_access_issue_hygiene_functionality is 1L for each hygiene/functionality option individually", {
  df <- dplyr::bind_rows(
    make_df(crowded = 1L),
    make_df(not_functioning = 1L),
    make_df(unclean = 1L)
  )
  result <- add_sanitation_access_issue_hygiene_functionality(df)
  expect_equal(
    result$wash_sanitation_access_issue_hygiene_functionality_d,
    rep(1L, 3)
  )
})

test_that("add_sanitation_access_issue_hygiene_functionality is NA for each undefined option", {
  df <- dplyr::bind_rows(
    make_df(dnk = 1L),
    make_df(pnta = 1L),
    make_df(other = 1L)
  )
  result <- add_sanitation_access_issue_hygiene_functionality(df)
  expect_true(
    all(is.na(result$wash_sanitation_access_issue_hygiene_functionality_d))
  )
})

test_that("add_sanitation_access_issue_hygiene_functionality is NA when a component binary is missing", {
  df <- dplyr::bind_rows(
    make_df(crowded = NA_integer_),
    make_df(crowded = NA_integer_, unclean = NA_integer_)
  )
  result <- add_sanitation_access_issue_hygiene_functionality(df)
  expect_true(
    all(is.na(result$wash_sanitation_access_issue_hygiene_functionality_d))
  )
})

test_that("add_sanitation_access_issue_hygiene_functionality is NA when all component binaries are missing", {
  result <- add_sanitation_access_issue_hygiene_functionality(
    make_df(
      crowded = NA_integer_,
      not_functioning = NA_integer_,
      unclean = NA_integer_
    )
  )
  expect_true(is.na(
    result$wash_sanitation_access_issue_hygiene_functionality_d
  ))
})

test_that("add_sanitation_access_issue_hygiene_functionality ignores a 'none' sanitation_facility", {
  result <- dplyr::bind_rows(
    make_df(unclean = 1L, facility = "none"),
    make_df(facility = "none")
  )
  result <- add_sanitation_access_issue_hygiene_functionality(result)
  expect_equal(
    result$wash_sanitation_access_issue_hygiene_functionality_d,
    c(1L, 0L)
  )
})

test_that("add_sanitation_access_issue_hygiene_functionality errors when base column is missing", {
  df <- dplyr::select(make_df(), -wash_sanitation_access_issue)
  expect_error(add_sanitation_access_issue_hygiene_functionality(df))
})

test_that("add_sanitation_access_issue_hygiene_functionality errors when a dummy column is missing", {
  df <- dplyr::select(
    make_df(),
    -`wash_sanitation_access_issue/lack_sanitation_facilities_crowded`
  )
  expect_error(add_sanitation_access_issue_hygiene_functionality(df))
})
