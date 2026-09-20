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


test_that("the non-default separator does not affect the behavior", {
  expect_no_error(
    suppressWarnings(add_prot_score_practices(
      dplyr::rename_with(
        dummy_df,
        ~ stringr::str_replace(.x, "/", ".")
      ),
      sep = "."
    ))
  )

  expect_error(
    suppressWarnings(add_prot_score_practices(
      dummy_df,
      sep = "."
    ))
  )
})


# Tests for the composite function

test_that("adds three composite columns without weighted vars", {
  res <- suppressWarnings(add_prot_score_practices(dummy_df))

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
  res_w <- suppressWarnings(add_prot_score_practices(
    dummy_df,
    .keep_weighted = TRUE
  ))

  raw_cols <- c(
    str_glue("{q1}/{opts1}"),
    str_glue("{q2}/{opts2}")
  )
  expected_w <- str_glue("{raw_cols}_w")

  expect_true(all(expected_w %in% names(res_w)))
})


test_that("weighted columns follow the expected 0/NA pattern", {
  res_w <- suppressWarnings(add_prot_score_practices(
    dummy_df,
    .keep_weighted = TRUE
  ))

  # "no" always yields 0
  expect_equal(unique(res_w[[str_glue("{q1}/no_w")]]), 0)
  expect_equal(unique(res_w[[str_glue("{q2}/no_w")]]), 0)

  # "dnk" and "pnta" always yield NA
  expect_true(all(is.na(res_w[[str_glue("{q1}/dnk_w")]])))
  expect_true(all(is.na(res_w[[str_glue("{q1}/pnta_w")]])))
  expect_true(all(is.na(res_w[[str_glue("{q2}/dnk_w")]])))
  expect_true(all(is.na(res_w[[str_glue("{q2}/pnta_w")]])))

  # "yes_other_activities" and "yes_other_social" always yield NA
  expect_true(all(is.na(res_w[[str_glue("{q1}/yes_other_activities_w")]])))
  expect_true(all(is.na(res_w[[str_glue("{q2}/yes_other_social_w")]])))
})


one_hot_row <- function(target_q, target_opt, sep = "/") {
  row <- c(
    rlang::set_names(
      as.list(rep(0L, length(opts1))),
      as.character(stringr::str_glue("{q1}{sep}{opts1}"))
    ),
    rlang::set_names(
      as.list(rep(0L, length(opts2))),
      as.character(stringr::str_glue("{q2}{sep}{opts2}"))
    )
  )
  row[[as.character(stringr::str_glue("{target_q}{sep}{target_opt}"))]] <- 1L
  dplyr::as_tibble(row)
}

test_that("selecting only `yes_other_activities`/`yes_other_social` behaves like `no`: it counts as 0 rather than forcing the sub-dimension to NA", {
  fixture <- dplyr::bind_rows(
    dplyr::mutate(
      one_hot_row(q1, "yes_other_activities"),
      scenario = "activities_other"
    ),
    dplyr::mutate(one_hot_row(q1, "no"), scenario = "activities_no"),
    dplyr::mutate(
      one_hot_row(q2, "yes_other_social"),
      scenario = "social_other"
    ),
    dplyr::mutate(one_hot_row(q2, "no"), scenario = "social_no")
  )

  res <- suppressWarnings(add_prot_score_practices(fixture))

  activities_other <- dplyr::filter(res, scenario == "activities_other")
  activities_no <- dplyr::filter(res, scenario == "activities_no")
  expect_equal(activities_other$comp_prot_score_prot_needs_2_activities, 0)
  expect_equal(
    activities_other$comp_prot_score_prot_needs_2_activities,
    activities_no$comp_prot_score_prot_needs_2_activities
  )

  social_other <- dplyr::filter(res, scenario == "social_other")
  social_no <- dplyr::filter(res, scenario == "social_no")
  expect_equal(social_other$comp_prot_score_prot_needs_2_social, 0)
  expect_equal(
    social_other$comp_prot_score_prot_needs_2_social,
    social_no$comp_prot_score_prot_needs_2_social
  )
})


test_that("composite severity is bounded 1–4", {
  res <- suppressWarnings(add_prot_score_practices(dummy_df))

  expect_true(all(res$comp_prot_score_practices >= 1, na.rm = TRUE))
  expect_true(all(res$comp_prot_score_practices <= 4, na.rm = TRUE))
})


test_that("sub-dimensions are NA when DNK or PNTA selected", {
  dnk <- "dnk"
  pnta <- "pnta"
  q1 <- "prot_needs_2_activities"
  q2 <- "prot_needs_2_social"

  res <- suppressWarnings(add_prot_score_practices(
    dummy_df,
    prot_needs_2_activities = q1,
    prot_needs_2_social = q2,
    dnk = dnk,
    pnta = pnta
  ))

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

  res <- suppressWarnings(add_prot_score_practices(
    dummy_df,
    prot_needs_2_activities = q1,
    prot_needs_2_social = q2,
    dnk = dnk,
    pnta = pnta
  ))

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

# test that a warning is raised either of the sub-dimensions are NA
test_that("a warning is raised when both sub-dimensions are NA", {
  dnk <- "dnk"
  pnta <- "pnta"
  q1 <- "prot_needs_2_activities"
  q2 <- "prot_needs_2_social"

  testthat::expect_warning(
    add_prot_score_practices(
      dummy_df,
      prot_needs_2_activities = q1,
      prot_needs_2_social = q2,
      dnk = dnk,
      pnta = pnta
    ),
    "Missing input scores detected"
  )
})
