dummy_df <- generate_survey_choice_combinations(
  question_name = "prot_needs_3_movement",
  answer_options = c(
    "no_changes_feel_unsafe",
    "no_safety_concerns",
    "women_girls_avoid_places",
    "men_avoid_places",
    "boys_avoid_places",
    "women_girls_avoid_night",
    "men_avoid_night",
    "boys_avoid_night",
    "girls_boys_avoid_school",
    "different_routes",
    "avoid_markets",
    "avoid_public_offices",
    "avoid_fields",
    "other_safety_measures",
    "dnk",
    "pnta"
  ),
  stand_alone_opts = c("dnk", "pnta", "no_safety_concerns"),
  sep = "/"
)

test_that("column names checked correctly", {
  expect_no_error(
    add_prot_score_movement(dummy_df)
  )

  # Should error if the column names are not as expected
  modified_dummy_sm <- dummy_df |>
    dplyr::rename_with(.fn = \(x) stringr::str_replace(x, "/", "_"))
  expect_error(
    add_prot_score_movement(modified_dummy_sm)
  )

  # If the user has a different name for an answer option, by default it should error
  non_default_dummy_sm <- dummy_df |>
    dplyr::rename(`prot_needs_3_movement/dnk2` = `prot_needs_3_movement/dnk`)
  expect_error(
    add_prot_score_movement(non_default_dummy_sm)
  )

  # If the user provides the renamed answer, it should not error
  expect_no_error(
    add_prot_score_movement(non_default_dummy_sm, dnk = "dnk2")
  )
})

test_that("._keep_weighted controls whether _w columns appear", {
  # by default no weighted cols
  res_def <- add_prot_score_movement(dummy_df)
  expect_false(any(grepl("_w$", names(res_def))))

  # when requested, we get one _w column per raw indicator
  res_w <- add_prot_score_movement(dummy_df, .keep_weighted = TRUE)
  opts <- c(
    "no_changes_feel_unsafe",
    "no_safety_concerns",
    "women_girls_avoid_places",
    "men_avoid_places",
    "boys_avoid_places",
    "women_girls_avoid_night",
    "men_avoid_night",
    "boys_avoid_night",
    "girls_boys_avoid_school",
    "different_routes",
    "avoid_markets",
    "avoid_public_offices",
    "avoid_fields",
    "other_safety_measures",
    "dnk",
    "pnta"
  )
  expected_w_cols <- paste0("prot_needs_3_movement/", opts, "_w")
  expect_true(all(expected_w_cols %in% names(res_w)))
})

test_that("weighting done correctly (in the _w columns)", {
  res <- add_prot_score_movement(dummy_df, .keep_weighted = TRUE)

  # The weight for `no_safety_concerns` is 0
  expect_equal(max(res$`prot_needs_3_movement/no_safety_concerns_w`), 0)
  expect_equal(min(res$`prot_needs_3_movement/no_safety_concerns_w`), 0)

  # The weight for `dnk`, `pnta`, and `other_safety_measures` is NA
  expect_true(all(is.na(res$`prot_needs_3_movement/dnk_w`)))
  expect_true(all(is.na(res$`prot_needs_3_movement/pnta_w`)))
  expect_true(all(is.na(res$`prot_needs_3_movement/other_safety_measures_w`)))
})

test_that("composite value calculated correctly and NA for dnk/pnta rows", {
  res <- add_prot_score_movement(dummy_df)

  expect_true("comp_prot_score_prot_needs_3" %in% names(res))
  expect_true("comp_prot_score_movement" %in% names(res))

  dnk_rows <- dummy_df[["prot_needs_3_movement/dnk"]] == 1
  pnta_rows <- dummy_df[["prot_needs_3_movement/pnta"]] == 1
  flagged <- dnk_rows | pnta_rows

  good_rows <- !flagged
  expect_true(all(res$comp_prot_score_movement[good_rows] >= 1, na.rm = TRUE))
  expect_true(all(res$comp_prot_score_movement[good_rows] <= 4, na.rm = TRUE))

  expect_true(all(is.na(res$comp_prot_score_movement[flagged])))
})

test_that("scoring thresholds are correct", {
  res <- add_prot_score_movement(dummy_df, .keep_weighted = TRUE)

  # For rows with a known raw sum, verify the composite score
  # sum = 0 then comp_prot_score_movement = 1
  # sum = 1 then comp_prot_score_movement = 2
  # sum >= 2 and < 4 then comp_prot_score_movement = 3
  # sum >= 4 then comp_prot_score_movement = 4

  non_flagged <- res[!is.na(res$comp_prot_score_movement), ]

  sum_0 <- non_flagged$comp_prot_score_prot_needs_3 == 0
  sum_1 <- non_flagged$comp_prot_score_prot_needs_3 == 1
  sum_2_3 <- non_flagged$comp_prot_score_prot_needs_3 >= 2 &
    non_flagged$comp_prot_score_prot_needs_3 < 4
  sum_4plus <- non_flagged$comp_prot_score_prot_needs_3 >= 4

  expect_true(all(non_flagged$comp_prot_score_movement[sum_0] == 1))
  expect_true(all(non_flagged$comp_prot_score_movement[sum_1] == 2))
  expect_true(all(non_flagged$comp_prot_score_movement[sum_2_3] == 3))
  expect_true(all(non_flagged$comp_prot_score_movement[sum_4plus] == 4))
})

test_that("flexible weights are applied correctly", {
  # default weights
  res_def <- add_prot_score_movement(dummy_df, .keep_weighted = TRUE)
  # men_avoid_places default weight is 1
  expect_equal(
    max(res_def$`prot_needs_3_movement/men_avoid_places_w`, na.rm = TRUE),
    1
  )
  # boys_avoid_places weight is 2 (not flexible)
  expect_equal(
    max(res_def$`prot_needs_3_movement/boys_avoid_places_w`, na.rm = TRUE),
    2
  )
  # men_avoid_night default weight is 1
  expect_equal(
    max(res_def$`prot_needs_3_movement/men_avoid_night_w`, na.rm = TRUE),
    1
  )
  # boys_avoid_night weight is 2 (not flexible)
  expect_equal(
    max(res_def$`prot_needs_3_movement/boys_avoid_night_w`, na.rm = TRUE),
    2
  )

  # override weights
  res_ov <- add_prot_score_movement(
    dummy_df,
    men_avoid_places_weight = 0,
    men_avoid_night_weight = 2,
    .keep_weighted = TRUE
  )
  expect_equal(
    max(res_ov$`prot_needs_3_movement/men_avoid_places_w`, na.rm = TRUE),
    0
  )
  expect_equal(
    max(res_ov$`prot_needs_3_movement/men_avoid_night_w`, na.rm = TRUE),
    2
  )
})

test_that("weight parameters are validated", {
  expect_error(
    add_prot_score_movement(dummy_df, men_avoid_places_weight = 3),
    "must be a single number between 0 and 2"
  )
  expect_error(
    add_prot_score_movement(dummy_df, men_avoid_places_weight = -1),
    "must be a single number between 0 and 2"
  )
  expect_error(
    add_prot_score_movement(dummy_df, men_avoid_night_weight = 3),
    "must be a single number between 0 and 2"
  )
  expect_error(
    add_prot_score_movement(dummy_df, men_avoid_night_weight = "a"),
    "must be a single number between 0 and 2"
  )
})
