q1 <- "prot_needs_2_activities"
q2 <- "prot_needs_2_social"

opts1 <- c(
  "yes_work",
  "yes_livelihood",
  "yes_safety",
  "yes_farm",
  "yes_water",
  "yes_other_activities",
  "yes_free_choices",
  "no",
  "dnk",
  "pnta"
)
opts2 <- c(
  "yes_visiting_family",
  "yes_visiting_friends",
  "yes_community_events",
  "yes_joining_groups",
  "yes_other_social",
  "yes_child_recreation",
  "yes_decision_making",
  "no",
  "dnk",
  "pnta"
)

dummy_activities <- generate_survey_choice_combinations(
  question_name = q1,
  answer_options = opts1,
  stand_alone_opts = c("dnk", "pnta", "no"),
  sep = "/"
)

dummy_social <- generate_survey_choice_combinations(
  question_name = q2,
  answer_options = opts2,
  stand_alone_opts = c("dnk", "pnta", "no"),
  sep = "/"
)

# Cartesian product of both questions
(dummy_df <- expand_grid(
  dummy_activities,
  dummy_social,
  .name_repair = "unique_quiet"
) |>
  dplyr::as_tibble())

# Tests for the composite function

test_that("adds three composite columns without weighted vars", {
  res <- add_prot_score_practices(dummy_df)

  expect_true(all(
    c(
      "comp_prot_score_prot_needs_2_activities",
      "comp_prot_score_prot_needs_2_social",
      "comp_prot_score_practices"
    ) %in%
      names(res)
  ))

  expect_false(any(str_detect(names(res), "_w$")))
})


test_that("includes weighted vars when .keep_weighted = TRUE", {
  res_w <- add_prot_score_practices(
    dummy_df,
    .keep_weighted = TRUE
  )

  raw_cols <- c(
    str_glue("{q1}/{opts1}"),
    str_glue("{q2}/{opts2}")
  )
  expected_w <- str_glue("{raw_cols}_w")

  expect_true(all(expected_w %in% names(res_w)))
})


test_that("weighted columns follow the expected 0/NA pattern", {
  res_w <- add_prot_score_practices(
    dummy_df,
    .keep_weighted = TRUE
  )

  # "no" always yields 0
  expect_equal(unique(res_w[[str_glue("{q1}/no_w")]]), 0)
  expect_equal(unique(res_w[[str_glue("{q2}/no_w")]]), 0)

  # "dnk" and "pnta" always yield NA
  expect_true(all(is.na(res_w[[str_glue("{q1}/dnk_w")]])))
  expect_true(all(is.na(res_w[[str_glue("{q1}/pnta_w")]])))
  expect_true(all(is.na(res_w[[str_glue("{q2}/dnk_w")]])))
  expect_true(all(is.na(res_w[[str_glue("{q2}/pnta_w")]])))
})


test_that("composite severity is bounded 1–4", {
  res <- add_prot_score_practices(dummy_df)

  expect_true(all(res$comp_prot_score_practices >= 1, na.rm = TRUE))
  expect_true(all(res$comp_prot_score_practices <= 4, na.rm = TRUE))
})


test_that("sub-dimensions are NA when DNK or PNTA selected", {
  dnk <- "dnk"
  pnta <- "pnta"
  q1 <- "prot_needs_2_activities"
  q2 <- "prot_needs_2_social"

  res <- add_prot_score_practices(
    dummy_df,
    prot_needs_2_activities = q1,
    prot_needs_2_social = q2,
    dnk = dnk,
    pnta = pnta
  )

  flagged_activities <- (dummy_df[[str_glue("{q1}/{dnk}")]] == 1 |
    dummy_df[[str_glue("{q1}/{pnta}")]] == 1)

  expect_true(all(is.na(res$comp_prot_score_prot_needs_2_activities[
    flagged_activities
  ])))

  flagged_social <- (dummy_df[[str_glue("{q2}/{dnk}")]] == 1 |
    dummy_df[[str_glue("{q2}/{pnta}")]] == 1)

  expect_true(all(is.na(res$comp_prot_score_prot_needs_2_social[
    flagged_social
  ])))
})


# test that when dnk or pnta are selected, the sub dimensions are NA
test_that("when both sub-dimensions are NA the composite is NA but not otherwise", {
  dnk <- "dnk"
  pnta <- "pnta"
  q1 <- "prot_needs_2_activities"
  q2 <- "prot_needs_2_social"

  res <- add_prot_score_practices(
    dummy_df,
    prot_needs_2_activities = q1,
    prot_needs_2_social = q2,
    dnk = dnk,
    pnta = pnta
  )

  flagged_activities <- (dummy_df[[str_glue("{q1}/{dnk}")]] == 1 |
    dummy_df[[str_glue("{q1}/{pnta}")]] == 1)

  flagged_social <- (dummy_df[[str_glue("{q2}/{dnk}")]] == 1 |
    dummy_df[[str_glue("{q2}/{pnta}")]] == 1)

  flagged_both <- flagged_activities & flagged_social

  expect_true(all(is.na(res$comp_prot_score_practices[
    flagged_both
  ])))

  flagged_only_activities <- flagged_activities & !flagged_social

  expect_true(all(
    !is.na(res$comp_prot_score_practices[
      flagged_only_activities
    ])
  ))

  flagged_only_social <- !flagged_activities & flagged_social

  expect_true(all(
    !is.na(res$comp_prot_score_practices[
      flagged_only_social
    ])
  ))
})
