library(tidyr)

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
  .name_repair = "unique"
) |>
  dplyr::as_tibble()

# Tests for the composite function: Ability to Access Rights and Services

test_that("adds three composite columns without weighted vars", {
  res <- add_prot_score_rights(dummy_df)

  expect_true(all(
    c(
      "comp_prot_score_prot_needs_1_services",
      "comp_prot_score_prot_needs_1_justice",
      "comp_prot_score_rights"
    ) %in%
      names(res)
  ))
  expect_false(any(str_detect(names(res), "_w$")))
})


test_that("includes weighted vars when .keep_weighted = TRUE", {
  res_w <- add_prot_score_rights(dummy_df, .keep_weighted = TRUE)

  raw_cols <- c(
    str_glue("{q1}/{opts1}"),
    str_glue("{q2}/{opts2}")
  )
  expected_w <- str_glue("{raw_cols}_w")
  expect_true(all(expected_w %in% names(res_w)))
})


test_that("weighted columns compute raw * weight correctly and group sums are accurate", {
  res_w <- add_prot_score_rights(dummy_df, .keep_weighted = TRUE)

  # Services weights: all yes_* = 1, no = 0
  expect_equal(
    res_w[[str_glue("{q1}/yes_healthcare_w")]],
    res_w[[str_glue("{q1}/yes_healthcare")]] * 1
  )
  expect_equal(
    res_w[[str_glue("{q1}/no_w")]],
    res_w[[str_glue("{q1}/no")]] * 0
  )

  # Justice weights: yes_identity_documents = 2, others yes_* = 1
  expect_equal(
    res_w[[str_glue("{q2}/yes_identity_documents_w")]],
    res_w[[str_glue("{q2}/yes_identity_documents")]] * 2
  )
  expect_equal(
    res_w[[str_glue("{q2}/yes_gov_services_w")]],
    res_w[[str_glue("{q2}/yes_gov_services")]] * 1
  )

  # Group composite sums
  srv_w_cols <- str_glue("{q1}/{opts1}_w")
  jus_w_cols <- str_glue("{q2}/{opts2}_w")
  expect_equal(
    res_w$comp_prot_score_prot_needs_1_services,
    rowSums(res_w[, srv_w_cols], na.rm = TRUE)
  )
  expect_equal(
    res_w$comp_prot_score_prot_needs_1_justice,
    rowSums(res_w[, jus_w_cols], na.rm = TRUE)
  )
})


test_that("composite severity: NA for DNK/P NTA, 1–4 for others, and non-destructive", {
  res <- add_prot_score_rights(dummy_df)

  # Identify rows where DNK or PNTA was chosen on either question
  flagged <- (dummy_df[[str_glue("{q1}/dnk")]] == 1 |
    dummy_df[[str_glue("{q1}/pnta")]] == 1 |
    dummy_df[[str_glue("{q2}/dnk")]] == 1 |
    dummy_df[[str_glue("{q2}/pnta")]] == 1)

  # Flagged rows should be NA
  expect_true(all(is.na(res$comp_prot_score_rights[flagged])))

  # Non-flagged rows should be bounded between 1 and 4
  expect_true(all(res$comp_prot_score_rights[!flagged] >= 1, na.rm = TRUE))
  expect_true(all(res$comp_prot_score_rights[!flagged] <= 4, na.rm = TRUE))

  # Non-destructive: ensure original columns are unchanged
  original_cols <- names(dummy_df)
  expect_equal(res[original_cols], dummy_df)
})
