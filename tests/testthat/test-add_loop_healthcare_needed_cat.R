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

test_that("lifesaving column is skipped with warning when ind_healthcare_type is absent", {
  loop <- dplyr::tibble(
    uuid = 1:2,
    health_ind_healthcare_needed = c("yes", "no"),
    health_ind_healthcare_received = c("no", "no")
  )
  expect_warning(
    result <- add_loop_healthcare_needed_cat(loop),
    "does not exist"
  )
  expect_false("health_ind_healthcare_needed_lifesaving_yes_unmet" %in% colnames(result))
})

test_that("lifesaving column is computed when ind_healthcare_type exists", {
  loop <- dplyr::tibble(
    uuid = 1:5,
    health_ind_healthcare_needed = c("yes", "yes", "yes", "no", "yes"),
    health_ind_healthcare_received = c("no", "no", "yes", "no", "no"),
    health_ind_healthcare_needed_type = c("a", "a", "a", NA, "a"),
    `health_ind_healthcare_needed_type/consultation_acute` = c(1L, 0L, 1L, 0L, 0L),
    `health_ind_healthcare_needed_type/consultation_chronic` = c(0L, 0L, 0L, 0L, 0L),
    `health_ind_healthcare_needed_type/trauma` = c(0L, 0L, 0L, 0L, 0L),
    `health_ind_healthcare_needed_type/emergency_surgery` = c(0L, 0L, 0L, 0L, 0L),
    `health_ind_healthcare_needed_type/natal_services` = c(0L, 0L, 0L, 0L, 0L),
    `health_ind_healthcare_needed_type/safe_delivery` = c(0L, 1L, 0L, 0L, 0L),
    .name_repair = "minimal"
  )
  result <- add_loop_healthcare_needed_cat(loop)
  expect_true("health_ind_healthcare_needed_lifesaving_yes_unmet" %in% colnames(result))
  # uuid 1: unmet + lifesaving type → 1
  # uuid 2: unmet + lifesaving type → 1
  # uuid 3: met need → unmet=0 → 0
  # uuid 4: no need → unmet=0 → 0
  # uuid 5: unmet + no lifesaving type → 0
  expect_equal(result$health_ind_healthcare_needed_lifesaving_yes_unmet, c(1, 1, 0, 0, 0))
})

test_that("lifesaving column is NA when healthcare need is DNK/PNTA", {
  loop <- dplyr::tibble(
    uuid = 1:2,
    health_ind_healthcare_needed = c("dnk", "pnta"),
    health_ind_healthcare_received = c("no", "no"),
    health_ind_healthcare_needed_type = c(NA_character_, NA_character_),
    `health_ind_healthcare_needed_type/consultation_acute` = c(0L, 0L),
    `health_ind_healthcare_needed_type/consultation_chronic` = c(0L, 0L),
    `health_ind_healthcare_needed_type/trauma` = c(0L, 0L),
    `health_ind_healthcare_needed_type/emergency_surgery` = c(0L, 0L),
    `health_ind_healthcare_needed_type/natal_services` = c(0L, 0L),
    `health_ind_healthcare_needed_type/safe_delivery` = c(0L, 0L),
    .name_repair = "minimal"
  )
  result <- add_loop_healthcare_needed_cat(loop)
  expect_true(all(is.na(result$health_ind_healthcare_needed_lifesaving_yes_unmet)))
})

test_that("add_loop_healthcare_needed_cat_to_main aggregates lifesaving column when present", {
  loop_base <- dplyr::tibble(
    uuid = 1:3,
    health_ind_healthcare_needed = c("yes", "yes", "no"),
    health_ind_healthcare_received = c("no", "yes", "no"),
    health_ind_healthcare_needed_type = c("a", "a", NA_character_),
    `health_ind_healthcare_needed_type/consultation_acute` = c(1L, 0L, 0L),
    `health_ind_healthcare_needed_type/consultation_chronic` = c(0L, 0L, 0L),
    `health_ind_healthcare_needed_type/trauma` = c(0L, 0L, 0L),
    `health_ind_healthcare_needed_type/emergency_surgery` = c(0L, 0L, 0L),
    `health_ind_healthcare_needed_type/natal_services` = c(0L, 0L, 0L),
    `health_ind_healthcare_needed_type/safe_delivery` = c(0L, 0L, 0L),
    .name_repair = "minimal"
  )
  main <- dplyr::tibble(uuid = 1:3)
  loop_result <- add_loop_healthcare_needed_cat(loop_base)
  result <- add_loop_healthcare_needed_cat_to_main(main, loop_result)
  expect_true("health_ind_healthcare_needed_lifesaving_yes_unmet_n" %in% colnames(result))
  expect_equal(result$health_ind_healthcare_needed_lifesaving_yes_unmet_n, c(1, 0, 0))
})

test_that("add_loop_healthcare_needed_cat_to_main skips lifesaving with warning when column absent", {
  loop_base <- dplyr::tibble(
    uuid = 1:2,
    health_ind_healthcare_needed = c("yes", "no"),
    health_ind_healthcare_received = c("no", "no")
  )
  main <- dplyr::tibble(uuid = 1:2)
  loop_result <- suppressWarnings(add_loop_healthcare_needed_cat(loop_base))
  expect_warning(
    result <- add_loop_healthcare_needed_cat_to_main(main, loop_result),
    "does not exist"
  )
  expect_false("health_ind_healthcare_needed_lifesaving_yes_unmet_n" %in% colnames(result))
})
