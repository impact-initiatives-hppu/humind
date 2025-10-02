# Build dummy data for access to rights and services indicator
q1 <- "prot_needs_1_services"
q2 <- "prot_needs_1_justice"

opts1 <- c(
  "yes_healthcare",
  "yes_schools",
  "yes_gov_services",
  "yes_other_services",
  "no",
  "dnk",
  "pnta"
)
opts2 <- c(
  "yes_identity_documents",
  "yes_counselling_legal",
  "yes_property_docs",
  "yes_gov_services",
  "yes_other_services",
  "no",
  "dnk",
  "pnta"
)

# Generate per-question dummy frames
dummy_services <- generate_survey_choice_combinations(
  question_name = q1,
  answer_options = opts1,
  stand_alone_opts = c("dnk", "pnta", "no"),
  sep = "/"
)

dummy_justice <- generate_survey_choice_combinations(
  question_name = q2,
  answer_options = opts2,
  stand_alone_opts = c("dnk", "pnta", "no"),
  sep = "/"
)

# Cartesian product of both questions
dummy_df <- expand_grid(
  dummy_services,
  dummy_justice,
  .name_repair = "unique_quiet"
) |>
  dplyr::as_tibble()

test_that("the non-default separator does not affect the behavior", {
  expect_no_error(
    suppressWarnings(add_prot_score_rights(
      dplyr::rename_with(
        dummy_df,
        ~ stringr::str_replace(.x, "/", ".")
      ),
      sep = "."
    ))
  )

  expect_error(
    suppressWarnings(add_prot_score_rights(
      dummy_df,
      sep = "."
    ))
  )
})

# -----------------------------
# Tests for the composite function: Ability to Access Rights and Services
# -----------------------------

test_that("adds three composite columns without weighted vars", {
  res <- suppressWarnings(add_prot_score_rights(dummy_df))

  expect_true(all(
    c(
      "comp_prot_score_prot_needs_1_services",
      "comp_prot_score_prot_needs_1_justice",
      "comp_prot_score_rights"
    ) %in%
      names(res)
  ))

  expect_false(any(stringr::str_detect(names(res), "_w$")))
})

test_that("includes weighted vars when .keep_weighted = TRUE", {
  res_w <- suppressWarnings(add_prot_score_rights(
    dummy_df,
    .keep_weighted = TRUE
  ))

  raw_cols <- c(
    glue::glue("{q1}/{opts1}"),
    glue::glue("{q2}/{opts2}")
  )
  expected_w <- glue::glue("{raw_cols}_w")

  expect_true(all(expected_w %in% names(res_w)))
})

test_that("weighted columns follow the expected 0/NA pattern", {
  res_w <- suppressWarnings(add_prot_score_rights(
    dummy_df,
    .keep_weighted = TRUE
  ))

  # "no" always yields 0
  expect_equal(unique(res_w[[glue::glue("{q1}/no_w")]]), 0)
  expect_equal(unique(res_w[[glue::glue("{q2}/no_w")]]), 0)

  # "dnk" and "pnta" always yield NA
  expect_true(all(is.na(res_w[[glue::glue("{q1}/dnk_w")]])))
  expect_true(all(is.na(res_w[[glue::glue("{q1}/pnta_w")]])))
  expect_true(all(is.na(res_w[[glue::glue("{q2}/dnk_w")]])))
  expect_true(all(is.na(res_w[[glue::glue("{q2}/pnta_w")]])))
})

test_that("composite severity is bounded 1–4", {
  res <- suppressWarnings(add_prot_score_rights(dummy_df))

  expect_true(all(res$comp_prot_score_rights >= 1, na.rm = TRUE))
  expect_true(all(res$comp_prot_score_rights <= 4, na.rm = TRUE))
})

test_that("sub-dimensions are NA when DNK or PNTA selected", {
  dnk <- "dnk"
  pnta <- "pnta"

  res <- suppressWarnings(add_prot_score_rights(
    dummy_df,
    prot_needs_1_services = q1,
    prot_needs_1_justice = q2,
    dnk = dnk,
    pnta = pnta
  ))

  flagged_services <- (dummy_df[[glue::glue("{q1}/{dnk}")]] == 1 |
    dummy_df[[glue::glue("{q1}/{pnta}")]] == 1)
  expect_true(all(is.na(res$comp_prot_score_prot_needs_1_services[
    flagged_services
  ])))

  flagged_justice <- (dummy_df[[glue::glue("{q2}/{dnk}")]] == 1 |
    dummy_df[[glue::glue("{q2}/{pnta}")]] == 1)
  expect_true(all(is.na(res$comp_prot_score_prot_needs_1_justice[
    flagged_justice
  ])))
})

test_that("when both sub-dimensions are NA the composite is NA but not otherwise", {
  dnk <- "dnk"
  pnta <- "pnta"

  res <- suppressWarnings(add_prot_score_rights(
    dummy_df,
    prot_needs_1_services = q1,
    prot_needs_1_justice = q2,
    dnk = dnk,
    pnta = pnta
  ))

  flagged_services <- (dummy_df[[glue::glue("{q1}/{dnk}")]] == 1 |
    dummy_df[[glue::glue("{q1}/{pnta}")]] == 1)

  flagged_justice <- (dummy_df[[glue::glue("{q2}/{dnk}")]] == 1 |
    dummy_df[[glue::glue("{q2}/{pnta}")]] == 1)

  flagged_both <- flagged_services & flagged_justice

  expect_true(all(is.na(res$comp_prot_score_rights[flagged_both])))

  flagged_only_services <- flagged_services & !flagged_justice
  expect_true(all(!is.na(res$comp_prot_score_rights[flagged_only_services])))

  flagged_only_justice <- !flagged_services & flagged_justice
  expect_true(all(!is.na(res$comp_prot_score_rights[flagged_only_justice])))
})

test_that("a warning is raised when both sub-dimensions are NA", {
  testthat::expect_warning(
    add_prot_score_rights(
      dummy_df,
      prot_needs_1_services = q1,
      prot_needs_1_justice = q2,
      dnk = "dnk",
      pnta = "pnta"
    ),
    "Missing input scores detected"
  )
})
