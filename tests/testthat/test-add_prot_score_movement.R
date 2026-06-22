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

test_that("comp_prot_score_movement maps raw sum to correct 1-4 severity", {
  all_opts <- c(
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
  all_cols <- paste0("prot_needs_3_movement/", all_opts)
  base_row <- setNames(
    as.data.frame(matrix(0L, 1L, length(all_cols))),
    all_cols
  )

  # sum = 0 (no_safety_concerns weight 0) -> score 1
  r0 <- base_row
  r0$`prot_needs_3_movement/no_safety_concerns` <- 1L
  expect_equal(add_prot_score_movement(r0)$comp_prot_score_movement, 1)

  # sum = 1 (different_routes weight 1) -> score 2
  r1 <- base_row
  r1$`prot_needs_3_movement/different_routes` <- 1L
  expect_equal(add_prot_score_movement(r1)$comp_prot_score_movement, 2)

  # sum = 3 (no_changes_feel_unsafe=1 + women_girls_avoid_places=2) -> score 3
  r3 <- base_row
  r3$`prot_needs_3_movement/no_changes_feel_unsafe` <- 1L
  r3$`prot_needs_3_movement/women_girls_avoid_places` <- 1L
  expect_equal(add_prot_score_movement(r3)$comp_prot_score_movement, 3)

  # sum = 4 (women_girls_avoid_places=2 + boys_avoid_places=2) -> score 4
  r4 <- base_row
  r4$`prot_needs_3_movement/women_girls_avoid_places` <- 1L
  r4$`prot_needs_3_movement/boys_avoid_places` <- 1L
  expect_equal(add_prot_score_movement(r4)$comp_prot_score_movement, 4)
})

test_that("flexible weight params reject invalid values and accept valid ones", {
  for (invalid in list(3, -1, 1.5, "a", NULL, NA)) {
    expect_error(
      add_prot_score_movement(dummy_df, weight_men_avoid_places = invalid),
      regexp = "weight_men_avoid_places"
    )
    expect_error(
      add_prot_score_movement(dummy_df, weight_men_avoid_night = invalid),
      regexp = "weight_men_avoid_night"
    )
  }

  for (valid in list(0, 1, 2)) {
    expect_no_error(add_prot_score_movement(
      dummy_df,
      weight_men_avoid_places = valid
    ))
    expect_no_error(add_prot_score_movement(
      dummy_df,
      weight_men_avoid_night = valid
    ))
  }
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
