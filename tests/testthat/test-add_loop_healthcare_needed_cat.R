# Sample data for testing
loop <- data.frame(
  uuid = c(1, 2, 3, 4, 5, 6),
  health_ind_healthcare_needed = c("yes", "no", "dnk", "pnta", "yes", "no"),
  health_ind_healthcare_received = c("no", "yes", "dnk", "pnta", "yes", "no"),
  ind_age = c(25, 30, 2, 8, 12, 40),
  stringsAsFactors = FALSE
)


main <- data.frame(
  uuid = c(1, 2, 3, 4, 5, 6),
  stringsAsFactors = FALSE,
  health_ind_healthcare_needed_no_n = TRUE
)

# Test with default parameters for add_loop_healthcare_needed_cat
test_that("add_loop_healthcare_needed_cat works with default parameters", {
  result <- add_loop_healthcare_needed_cat(loop)
  expect_true(all(
    c(
      "health_ind_healthcare_needed_d",
      "health_ind_healthcare_received_d",
      "health_ind_healthcare_needed_cat",
      "health_ind_healthcare_needed_no",
      "health_ind_healthcare_needed_yes_unmet",
      "health_ind_healthcare_needed_yes_met"
    ) %in%
      colnames(result)
  ))
})

# Test if healthcare needed categories are calculated correctly
test_that("healthcare needed categories are calculated correctly", {
  result <- add_loop_healthcare_needed_cat(loop)
  expect_equal(
    result$health_ind_healthcare_needed_cat,
    c("yes_unmet_need", "no_need", NA, NA, "yes_met_need", "no_need")
  )
})


# Test with default parameters for add_loop_healthcare_needed_cat_main
test_that("add_loop_healthcare_needed_cat_main works with default parameters", {
  loop_result <- add_loop_healthcare_needed_cat(loop)
  result <- suppressWarnings(add_loop_healthcare_needed_cat_to_main(
    main,
    loop_result
  ))
  expect_true(all(
    c(
      "health_ind_healthcare_needed_no_n",
      "health_ind_healthcare_needed_yes_unmet_n",
      "health_ind_healthcare_needed_yes_met_n"
    ) %in%
      colnames(result)
  ))
})

# Test if id columns are correctly handled
test_that("id columns are correctly handled", {
  expect_error(
    add_loop_healthcare_needed_cat_to_main(
      main,
      loop,
      id_col_main = "uuid",
      id_col_loop = "missing_id"
    ),
    class = "error"
  )
  expect_error(
    add_loop_healthcare_needed_cat_to_main(
      main,
      loop,
      id_col_main = "missing_id",
      id_col_loop = "uuid"
    ),
    class = "error"
  )
})

# Test if main data frame correctly joins with loop data frame
test_that("main data frame correctly joins with loop data frame", {
  loop_result <- add_loop_healthcare_needed_cat(loop)
  result <- suppressWarnings(add_loop_healthcare_needed_cat_to_main(
    main,
    loop_result
  ))
  expect_equal(result$health_ind_healthcare_needed_no_n, c(0, 1, 0, 0, 0, 1))
  expect_equal(
    result$health_ind_healthcare_needed_yes_unmet_n,
    c(1, 0, 0, 0, 0, 0)
  )
  expect_equal(
    result$health_ind_healthcare_needed_yes_met_n,
    c(0, 0, 0, 0, 1, 0)
  )
})

# Test that it works if UUID columns are named X_UUID in main, and X_SUB_UUID in loop
test_that("it works if UUID columns are named X_UUID in main, and X_SUB_UUID in loop", {
  main$X_UUID <- c(1, 2, 3, 4, 5, 6)
  loop$X_SUB_UUID <- c(1, 2, 3, 4, 5, 6)
  loop_result <- add_loop_healthcare_needed_cat(loop)
  result <- suppressWarnings(add_loop_healthcare_needed_cat_to_main(
    main,
    loop_result,
    id_col_main = "X_UUID",
    id_col_loop = "X_SUB_UUID"
  ))
  expect_equal(result$health_ind_healthcare_needed_no_n, c(0, 1, 0, 0, 0, 1))
  expect_equal(
    result$health_ind_healthcare_needed_yes_unmet_n,
    c(1, 0, 0, 0, 0, 0)
  )
  expect_equal(
    result$health_ind_healthcare_needed_yes_met_n,
    c(0, 0, 0, 0, 1, 0)
  )
})

exhaustive_loop <- tidyr::expand_grid(
  health_ind_healthcare_needed = c("yes", "no", "dnk", "pnta", NA),
  health_ind_healthcare_received = c("yes", "no", "dnk", "pnta", NA),
  ind_age = 2:80
) |>
  mutate(uuid = row_number())


test_that("healthcare received NA causes healthcare needed cat to be NA when healthcare needed is yes", {
  test_data <- exhaustive_loop |>
    dplyr::filter(
      health_ind_healthcare_needed == "yes",
      is.na(health_ind_healthcare_received)
    )
  result <- expect_warning(
    add_loop_healthcare_needed_cat(test_data),
    "healthcare needed.+but healthcare received.+"
  )
  expect_true(all(is.na(result$health_ind_healthcare_needed_cat)))
})


test_that("dummy variables are NA when healthcare_received is NA", {
  result <- suppressWarnings(add_loop_healthcare_needed_cat(exhaustive_loop))
  flagged <- result$health_ind_healthcare_needed_d == 1 &
    is.na(result$health_ind_healthcare_received_d)
  flagged_rows <- result[flagged, ]

  expect_true(all(is.na(flagged_rows$health_ind_healthcare_needed_yes_unmet)))

  expect_true(all(is.na(flagged_rows$health_ind_healthcare_needed_yes_met)))
})

# ---- Lifesaving feature ----

# Helper: expand a healthcare-need tibble with the type binaries the function
# inspects (six life-saving options, the undefined options, and the two other
# substantive options).
make_type_df <- function(needed, received, types = list()) {
  options <- c(
    "consultation_acute",
    "consultation_chronic",
    "trauma",
    "emergency_surgery",
    "natal_services",
    "safe_delivery",
    "preventative_consultation",
    "elective_surgery",
    "other",
    "dnk",
    "pnta"
  )
  df <- dplyr::tibble(
    uuid = seq_along(needed),
    health_ind_healthcare_needed = needed,
    health_ind_healthcare_received = received,
    health_ind_healthcare_needed_type = "typed"
  )
  for (option in options) {
    value <- types[[option]]
    if (is.null(value)) {
      value <- rep(0L, length(needed))
    }
    df[[paste0("health_ind_healthcare_needed_type/", option)]] <- value
  }
  df
}

test_that("lifesaving column is skipped quietly when ind_healthcare_type is absent", {
  loop <- dplyr::tibble(
    uuid = 1:2,
    health_ind_healthcare_needed = c("yes", "no"),
    health_ind_healthcare_received = c("no", "no")
  )
  expect_no_warning(result <- add_loop_healthcare_needed_cat(loop))
  expect_false(
    "health_ind_healthcare_needed_lifesaving_yes_unmet" %in% colnames(result)
  )
})

test_that("lifesaving column warns when an explicitly named type column is absent", {
  loop <- dplyr::tibble(
    uuid = 1:2,
    health_ind_healthcare_needed = c("yes", "no"),
    health_ind_healthcare_received = c("no", "no")
  )
  expect_warning(
    add_loop_healthcare_needed_cat(loop, ind_healthcare_type = "not_a_column"),
    "does not exist"
  )
})

test_that("lifesaving column is computed from the type binaries", {
  loop <- make_type_df(
    needed = c("yes", "yes", "yes", "no", "yes"),
    received = c("no", "no", "yes", "no", "no"),
    types = list(
      consultation_acute = c(1L, 0L, 1L, 0L, 0L),
      safe_delivery = c(0L, 1L, 0L, 0L, 0L),
      preventable_consultation = c(0L, 0L, 0L, 0L, 1L)
    )
  )
  result <- add_loop_healthcare_needed_cat(loop)
  expect_true(
    "health_ind_healthcare_needed_lifesaving_yes_unmet" %in% colnames(result)
  )
  # unmet need with a life-saving type is flagged; met or no need is 0; an unmet
  # need without a life-saving type is 0
  expect_equal(
    result$health_ind_healthcare_needed_lifesaving_yes_unmet,
    c(1, 1, 0, 0, 0)
  )
})

test_that("lifesaving column is NA when the type is unknown (dnk/pnta/other)", {
  loop <- make_type_df(
    needed = c("yes", "yes", "yes"),
    received = c("no", "no", "no"),
    types = list(
      dnk = c(1L, 0L, 0L),
      pnta = c(0L, 1L, 0L),
      other = c(0L, 0L, 1L)
    )
  )
  result <- add_loop_healthcare_needed_cat(loop)
  expect_true(all(is.na(
    result$health_ind_healthcare_needed_lifesaving_yes_unmet
  )))
})

test_that("lifesaving column is 1 when a life-saving type is combined with other", {
  loop <- make_type_df(
    needed = "yes",
    received = "no",
    types = list(trauma = 1L, other = 1L)
  )
  result <- add_loop_healthcare_needed_cat(loop)
  expect_equal(result$health_ind_healthcare_needed_lifesaving_yes_unmet, 1)
})

test_that("lifesaving column is NA when the type question was not answered", {
  loop <- dplyr::tibble(
    uuid = 1L,
    health_ind_healthcare_needed = "yes",
    health_ind_healthcare_received = "no",
    health_ind_healthcare_needed_type = NA_character_,
    `health_ind_healthcare_needed_type/consultation_acute` = NA_integer_,
    `health_ind_healthcare_needed_type/consultation_chronic` = NA_integer_,
    `health_ind_healthcare_needed_type/trauma` = NA_integer_,
    `health_ind_healthcare_needed_type/emergency_surgery` = NA_integer_,
    `health_ind_healthcare_needed_type/natal_services` = NA_integer_,
    `health_ind_healthcare_needed_type/safe_delivery` = NA_integer_,
    `health_ind_healthcare_needed_type/dnk` = NA_integer_,
    `health_ind_healthcare_needed_type/pnta` = NA_integer_,
    `health_ind_healthcare_needed_type/other` = NA_integer_,
    .name_repair = "minimal"
  )
  result <- add_loop_healthcare_needed_cat(loop)
  expect_true(is.na(result$health_ind_healthcare_needed_lifesaving_yes_unmet))
})

test_that("lifesaving column is NA when healthcare need is DNK/PNTA", {
  loop <- make_type_df(
    needed = c("dnk", "pnta"),
    received = c("no", "no")
  )
  result <- add_loop_healthcare_needed_cat(loop)
  expect_true(all(is.na(
    result$health_ind_healthcare_needed_lifesaving_yes_unmet
  )))
})

test_that("add_loop_healthcare_needed_cat_to_main aggregates lifesaving column when present", {
  loop_base <- make_type_df(
    needed = c("yes", "yes", "no"),
    received = c("no", "yes", "no"),
    types = list(consultation_acute = c(1L, 0L, 0L))
  )
  main <- dplyr::tibble(uuid = 1:3)
  loop_result <- add_loop_healthcare_needed_cat(loop_base)
  result <- add_loop_healthcare_needed_cat_to_main(main, loop_result)
  expect_true(
    "health_ind_healthcare_needed_lifesaving_yes_unmet_n" %in% colnames(result)
  )
  expect_equal(
    result$health_ind_healthcare_needed_lifesaving_yes_unmet_n,
    c(1, 0, 0)
  )
})

test_that("add_loop_healthcare_needed_cat_to_main skips lifesaving quietly when column absent", {
  loop_base <- dplyr::tibble(
    uuid = 1:2,
    health_ind_healthcare_needed = c("yes", "no"),
    health_ind_healthcare_received = c("no", "no")
  )
  main <- dplyr::tibble(uuid = 1:2)
  loop_result <- add_loop_healthcare_needed_cat(loop_base)
  expect_no_warning(
    result <- add_loop_healthcare_needed_cat_to_main(main, loop_result)
  )
  expect_false(
    "health_ind_healthcare_needed_lifesaving_yes_unmet_n" %in% colnames(result)
  )
})
