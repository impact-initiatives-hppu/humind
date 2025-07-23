dummy_df <- generate_survey_choice_combinations(
  question_name = "prot_needs_3_movement",
  answer_options = c(
    "no_changes_feel_unsafe",
    "no_safety_concerns",
    "women_girls_avoid_places",
    "men_boys_avoid_places",
    "women_girls_avoid_night",
    "men_boys_avoid_night",
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
    add_prot_needs_movement(dummy_df)
  )

  # Should error if the column names are not as expected
  modified_dummy_sm <- dummy_df |>
    dplyr::rename_with(.fn = \(x) stringr::str_replace(x, "/", "_"))
  expect_error(
    add_prot_needs_movement(modified_dummy_sm)
  )

  # If the user has a different name for an answer option, by default it should error
  non_default_dummy_sm <- dummy_df |>
    dplyr::rename(`prot_needs_3_movement/dnk2` = `prot_needs_3_movement/dnk`)
  expect_error(
    add_prot_needs_movement(non_default_dummy_sm)
  )

  # If the user provides the renamed answer, it should not error
  expect_no_error(
    add_prot_needs_movement(non_default_dummy_sm, dnk = "dnk2")
  )
})

test_that("._keep_weighted controls whether _w columns appear", {
  # by default no weighted cols
  res_def <- add_prot_needs_movement(dummy_df)
  expect_false(any(grepl("_w$", names(res_def))))

  # when requested, we get one _w column per raw indicator
  res_w <- add_prot_needs_movement(dummy_df, .keep_weighted = TRUE)
  opts <- c(
    "no_changes_feel_unsafe",
    "no_safety_concerns",
    "women_girls_avoid_places",
    "men_boys_avoid_places",
    "women_girls_avoid_night",
    "men_boys_avoid_night",
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
  res <- add_prot_needs_movement(dummy_df, .keep_weighted = TRUE)

  # The weight for `no_safety_concerns` is 0
  expect_equal(max(res$`prot_needs_3_movement/no_safety_concerns_w`), 0)
  expect_equal(min(res$`prot_needs_3_movement/no_safety_concerns_w`), 0)

  # The weight for `dnk`, `pnta`, and `other_safety_measures` is NA
  expect_true(all(is.na(res$`prot_needs_3_movement/dnk_w`)))
  expect_true(all(is.na(res$`prot_needs_3_movement/pnta_w`)))
  expect_true(all(is.na(res$`prot_needs_3_movement/other_safety_measures_w`)))
})

test_that("composite value calculated correctly", {
  res <- add_prot_needs_movement(dummy_df)

  # composites always present
  expect_true("comp_prot_score_prot_needs_3" %in% names(res))
  expect_true("comp_prot_score_needs_1" %in% names(res))

  # Final composite score should be between 0 and 4
  expect_true(all(res$comp_prot_score_needs_1 <= 4))
  expect_true(all(res$comp_prot_score_needs_1 > 0))
})
