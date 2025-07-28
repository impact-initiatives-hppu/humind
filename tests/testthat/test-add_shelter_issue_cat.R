test_df <- data.frame(
  snfi_shelter_issue = rep(NA, 8),
  "snfi_shelter_issue/lack_privacy" = c(1, 0, 0, 0, 0, 0, 0, 1),
  "snfi_shelter_issue/lack_space" = c(0, 1, 1, 0, 0, 0, 0, 1),
  "snfi_shelter_issue/temperature" = c(0, 1, 0, 0, 0, 0, 0, 1),
  "snfi_shelter_issue/ventilation" = c(0, 0, 1, 0, 0, 0, 0, 1),
  "snfi_shelter_issue/vectors" = c(0, 0, 0, 1, 0, 0, 0, 1),
  "snfi_shelter_issue/no_natural_light" = c(0, 0, 0, 1, 0, 0, 0, 1),
  "snfi_shelter_issue/leak" = c(0, 0, 0, 1, 0, 0, 0, 1),
  "snfi_shelter_issue/lock" = c(0, 0, 0, 1, 0, 0, 0, 1),
  "snfi_shelter_issue/lack_lighting" = c(0, 0, 0, 1, 0, 0, 0, 1),
  "snfi_shelter_issue/difficulty_move" = c(0, 0, 0, 1, 0, 0, 0, 1),
  "snfi_shelter_issue/lack_space_laundry" = c(0, 0, 0, 1, 0, 0, 0, 1),
  "snfi_shelter_issue/none" = c(0, 0, 0, 0, 0, 1, 0, 0),
  "snfi_shelter_issue/dnk" = c(0, 0, 0, 0, 0, 0, 1, 0),
  "snfi_shelter_issue/pnta" = c(0, 0, 0, 0, 0, 0, 0, 0),
  "snfi_shelter_issue/other" = c(0, 0, 0, 0, 1, 0, 0, 0),
  check.names = FALSE
)

test_that("snfi_shelter_issue_n and snfi_shelter_issue_cat are correct for all scenarios", {
  result <- add_shelter_issue_cat(
    df = test_df,
    shelter_issue = "snfi_shelter_issue",
    none = "none",
    issues = c(
      "lack_privacy",
      "lack_space",
      "temperature",
      "ventilation",
      "vectors",
      "no_natural_light",
      "leak",
      "lock",
      "lack_lighting",
      "difficulty_move",
      "lack_space_laundry"
    ),
    undefined = c("dnk", "pnta"),
    other = c("other"),
    sep = "/"
  )
  expect_equal(result$snfi_shelter_issue_n, c(1, 2, 2, 7, NA, 0, NA, 11))
  expect_equal(
    result$snfi_shelter_issue_cat,
    c(
      "1_to_3",
      "1_to_3",
      "1_to_3",
      "4_to_7",
      "other",
      "none",
      "undefined",
      "8_to_11"
    )
  )
})
