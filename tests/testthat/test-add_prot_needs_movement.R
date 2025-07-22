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

  # If the user has a different name for an answer option and provides the changed name, it should not error
  expect_no_error(
    add_prot_needs_movement(non_default_dummy_sm, dnk = "dnk2")
  )
})

test_that("weighting done correctly", {
  # NOTE: this test is not deterministic, it's closer to a property based test
  # NOTE: the logic of these tests is to make sure the maximum of each binary
  # column does not exceed the weight of that column. This relies on the fact
  # that the values are between 0 and 1
  res <- add_prot_needs_movement(dummy_df)
  # The weight for `no_safety_concerns` is 0, in all scenarios the maximum for this column should be 0
  expect_equal(max(res$`prot_needs_3_movement/no_safety_concerns`), 0)
  expect_equal(min(res$`prot_needs_3_movement/no_safety_concerns`), 0)

  # The weight for `dnk`, `pnta`, and `other_safety_measures` is NA, in all scenarios the max / min should be NA
  expect_true(all(is.na(res$`prot_needs_3_movement/dnk`)))
  expect_true(all(is.na(res$`prot_needs_3_movement/pnta`)))
  expect_true(all(is.na(res$`prot_needs_3_movement/other_safety_measures`)))
})

test_that("composite value calculated correctly", {
  res <- add_prot_needs_movement(dummy_df)
  expect_true("comp_prot_score_prot_needs_3" %in% names(res))

  # Final composite score should be between 0 and 4
  max_weight <- 4
  expect_true(all(res$comp_prot_score_needs_1 <= max_weight))
  expect_true(all(res$comp_prot_score_needs_1 > 0))
})
