test_that("add_loop_wgq_ss errors when required columns are missing", {
  df <- data.frame(
    ind_age = c(10, 12, 7, 6, 20),
    wgq_vision = c(
      "cannot_do_at_all",
      "some_difficulty",
      "no_difficulty",
      "a_lot_of_difficulty",
      "pnta"
    ),
    wgq_hearing = c(
      "a_lot_of_difficulty",
      "no_difficulty",
      "cannot_do_at_all",
      "some_difficulty",
      "dnk"
    ),
    wgq_mobility = c(
      "no_difficulty",
      "a_lot_of_difficulty",
      "some_difficulty",
      "cannot_do_at_all",
      "no_difficulty"
    ),
    wgq_cognition = c(
      "some_difficulty",
      "cannot_do_at_all",
      "a_lot_of_difficulty",
      "no_difficulty",
      "no_difficulty"
    )
  )

  expect_error(
    add_loop_wgq_ss(df),
    class = "rlang_error"
  )
  expect_error(
    add_loop_wgq_ss(df),
    "The following columns are missing in"
  )
  expect_error(
    add_loop_wgq_ss(df),
    "wgq_self_care.*wgq_communication"
  )
})

test_that("add_loop_wgq_ss errors when values are outside the allowed set", {
  df <- data.frame(
    ind_age = c(10, 12, 7, 6, 20),
    wgq_vision = c(
      "cannot_do_at_all",
      "some_difficulty",
      "no_difficulty",
      "a_lot_of_difficulty",
      "invalid_value"
    ),
    wgq_hearing = c(
      "a_lot_of_difficulty",
      "no_difficulty",
      "cannot_do_at_all",
      "some_difficulty",
      "dnk"
    ),
    wgq_mobility = c(
      "no_difficulty",
      "a_lot_of_difficulty",
      "some_difficulty",
      "cannot_do_at_all",
      "no_difficulty"
    ),
    wgq_cognition = c(
      "some_difficulty",
      "cannot_do_at_all",
      "a_lot_of_difficulty",
      "no_difficulty",
      "no_difficulty"
    ),
    wgq_self_care = c(
      "cannot_do_at_all",
      "some_difficulty",
      "no_difficulty",
      "a_lot_of_difficulty",
      "pnta"
    ),
    wgq_communication = c(
      "a_lot_of_difficulty",
      "no_difficulty",
      "cannot_do_at_all",
      "some_difficulty",
      "dnk"
    )
  )

  expect_error(
    add_loop_wgq_ss(df),
    class = "rlang_error"
  )
  expect_error(
    add_loop_wgq_ss(df),
    "All columns must be in the following set: no_difficulty, some_difficulty, a_lot_of_difficulty, cannot_do_at_all, dnk, pnta"
  )
  expect_error(
    add_loop_wgq_ss(df),
    "wgq_vision: invalid_value"
  )
})

test_that("add_loop_wgq_ss_to_main works correctly", {
  main <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C")
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3),
    wgq_dis_4 = c(1, 0, 0, 1, 0),
    wgq_dis_3 = c(0, 1, 0, 0, 1),
    wgq_dis_2 = c(0, 0, 1, 0, 0),
    wgq_dis_1 = c(1, 1, 1, 0, 1),
    ind_age_above_5 = c(1, 1, 1, 1, 1)
  )

  result <- add_loop_wgq_ss_to_main(main, loop)

  expected <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C"),
    wgq_dis_4_n = c(1, 0, 1),
    wgq_dis_3_n = c(1, 0, 1),
    wgq_dis_2_n = c(0, 1, 0),
    wgq_dis_1_n = c(2, 1, 1),
    ind_age_above_5_n = c(2, 1, 2),
    wgq_dis_4_at_least_one = c(1, 0, 1),
    wgq_dis_3_at_least_one = c(1, 0, 1),
    wgq_dis_2_at_least_one = c(0, 1, 0),
    wgq_dis_1_at_least_one = c(1, 1, 1)
  )

  expect_equal(result, expected)
})

test_that("add_loop_wgq_ss_to_main errors when required columns are missing", {
  main <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C")
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3),
    wgq_dis_4 = c(1, 0, 0, 1, 0)
  )

  expect_error(
    add_loop_wgq_ss_to_main(main, loop),
    class = "rlang_error"
  )
  expect_error(
    add_loop_wgq_ss_to_main(main, loop),
    "The following columns are missing in"
  )
  expect_error(
    add_loop_wgq_ss_to_main(main, loop),
    "wgq_dis_3.*wgq_dis_2.*wgq_dis_1"
  )
})

test_that("add_loop_wgq_ss_to_main errors when disability values are outside the set", {
  main <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C")
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3),
    wgq_dis_4 = c(1, 0, 0, 1, 0),
    wgq_dis_3 = c(0, 1, 0, 0, 1),
    wgq_dis_2 = c(0, 0, 1, 0, 0),
    wgq_dis_1 = c(1, 1, 1, 0, "invalid_value"),
    ind_age_above_5 = c(1, 1, 1, 1, 1)
  )

  expect_error(
    add_loop_wgq_ss_to_main(main, loop),
    class = "rlang_error"
  )
  expect_error(
    add_loop_wgq_ss_to_main(main, loop),
    "All columns must be in the following set: 0, 1"
  )
  expect_error(
    add_loop_wgq_ss_to_main(main, loop),
    "wgq_dis_1: invalid_value"
  )
})

test_that("add_loop_wgq_ss_to_main warns about existing columns", {
  main <- data.frame(
    uuid = c(1, 2, 3),
    other_col = c("A", "B", "C"),
    wgq_dis_4_n = c(0, 0, 0)
  )

  loop <- data.frame(
    uuid = c(1, 1, 2, 3, 3),
    wgq_dis_4 = c(1, 0, 0, 1, 0),
    wgq_dis_3 = c(0, 1, 0, 0, 1),
    wgq_dis_2 = c(0, 0, 1, 0, 0),
    wgq_dis_1 = c(1, 1, 1, 0, 1),
    ind_age_above_5 = c(1, 1, 1, 1, 1)
  )

  expect_warning(
    add_loop_wgq_ss_to_main(main, loop),
    "wgq_dis_4_n already exists in 'main'. It will be replaced."
  )
})

test_that("add_loop_wgq_ss computes level binaries, sums, and disability cut-offs", {
  no <- "no_difficulty"
  some <- "some_difficulty"
  lot <- "a_lot_of_difficulty"
  cant <- "cannot_do_at_all"

  df <- data.frame(
    ind_age = c(10, 3, 10, 10, 10, 7),
    wgq_vision = c(cant, no, some, some, "dnk", "pnta"),
    wgq_hearing = c(cant, no, some, no, "dnk", "pnta"),
    wgq_mobility = c(cant, no, lot, no, "dnk", "pnta"),
    wgq_cognition = c(cant, no, no, no, "dnk", "pnta"),
    wgq_self_care = c(cant, no, no, no, "dnk", "pnta"),
    wgq_communication = c(cant, no, no, no, "dnk", "pnta"),
    stringsAsFactors = FALSE
  )

  result <- add_loop_wgq_ss(df)

  expected <- data.frame(
    ind_age_above_5 = c(1, 0, 1, 1, 1, 1),
    wgq_vision_cannot_do_d = c(1, NA, 0, 0, 0, 0),
    wgq_vision_lot_of_difficulty_d = c(0, NA, 0, 0, 0, 0),
    wgq_vision_some_difficulty_d = c(0, NA, 1, 1, 0, 0),
    wgq_vision_no_difficulty_d = c(0, NA, 0, 0, 0, 0),
    wgq_cannot_do_n = c(6, NA, 0, 0, 0, 0),
    wgq_lot_of_difficulty_n = c(0, NA, 1, 0, 0, 0),
    wgq_some_difficulty_n = c(0, NA, 2, 1, 0, 0),
    wgq_no_difficulty_n = c(0, NA, 3, 5, 0, 0),
    wgq_dis_4 = c(1, NA, 0, 0, 0, 0),
    wgq_dis_3 = c(1, NA, 1, 0, 0, 0),
    wgq_dis_2 = c(1, NA, 1, 0, 0, 0),
    wgq_dis_1 = c(1, NA, 1, 1, 0, 0)
  )

  expect_equal(
    result[, colnames(expected)],
    expected
  )
})

test_that("add_loop_wgq_ss respects custom level arguments", {
  no <- "no"
  some <- "some"
  lot <- "lot"
  cant <- "cannot"

  df <- data.frame(
    ind_age = c(10, 10),
    wgq_vision = c(cant, no),
    wgq_hearing = c(cant, some),
    wgq_mobility = c(cant, lot),
    wgq_cognition = c(cant, no),
    wgq_self_care = c(cant, no),
    wgq_communication = c(cant, no),
    stringsAsFactors = FALSE
  )

  result <- add_loop_wgq_ss(
    df,
    no_difficulty = no,
    some_difficulty = some,
    lot_of_difficulty = lot,
    cannot_do = cant
  )

  expect_equal(result$wgq_cannot_do_n, c(6, 0))
  expect_equal(result$wgq_lot_of_difficulty_n, c(0, 1))
  expect_equal(result$wgq_some_difficulty_n, c(0, 1))
  expect_equal(result$wgq_no_difficulty_n, c(0, 4))
  expect_equal(result$wgq_dis_4, c(1, 0))
  expect_equal(result$wgq_dis_3, c(1, 1))
  expect_equal(result$wgq_dis_2, c(1, 1))
  expect_equal(result$wgq_dis_1, c(1, 1))
})

test_that("add_loop_wgq_ss errors when level arguments are not length 1", {
  df <- data.frame(
    ind_age = 10,
    wgq_vision = "no_difficulty",
    wgq_hearing = "no_difficulty",
    wgq_mobility = "no_difficulty",
    wgq_cognition = "no_difficulty",
    wgq_self_care = "no_difficulty",
    wgq_communication = "no_difficulty"
  )

  expect_error(
    add_loop_wgq_ss(df, no_difficulty = c("no_difficulty", "other")),
    class = "rlang_error"
  )
  expect_error(
    add_loop_wgq_ss(df, no_difficulty = c("no_difficulty", "other")),
    "no_difficulty, some_difficulty, lot_of_difficulty, cannot_do must be of length 1"
  )
})
