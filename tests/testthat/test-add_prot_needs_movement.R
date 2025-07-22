gen_dummy_sm <- function() {
  question_name <- "prot_needs_3_movement"

  answer_options <- c(
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

  sm_names <- stringr::str_glue(
    "{question_name}/{answer_options}"
  )

  sim_df <- expand.grid(rep(list(0:1), length(sm_names))) |>
    rlang::set_names(sm_names) |>
    as.data.frame()

  sim_df$tot <- rowSums(sim_df)

  mut_ex <- c(
    "prot_needs_3_movement/dnk",
    "prot_needs_3_movement/pnta"
  )

  sim_df <- dplyr::filter(
    sim_df,
    `prot_needs_3_movement/dnk` + `prot_needs_3_movement/pnta` <= 1,
    tot < 14,
    tot > 0,
    !(`prot_needs_3_movement/pnta` == 1 & tot > 1),
    !(`prot_needs_3_movement/dnk` == 1 & tot > 1)
  )
  return(sim_df)
}

dummy_df <- gen_dummy_sm()


test_that("column names checked correctly", {
  expect_no_error(
    add_prot_needs_movement(dummy_df)
  )

  # Should error if the column names are not as expected
  modified_dummy_sm <- gen_dummy_sm() |>
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
