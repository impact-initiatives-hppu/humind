test_that("NAs are correctly handled", {
  dummy_df <- tidyr::expand_grid(
    comp_prot_score_movement = c(1:4, NA),
    comp_prot_score_practices = c(1:4, NA),
    comp_prot_score_rights = c(1:4, NA)
  )

  result <- add_comp_prot(dummy_df)

  # NOTE: From an exhaustive list of combinations, we expect only one row to have all NAs
  # For this row only, should comp_prot_score be NA
  expect_equal(sum(is.na(result$comp_prot_score)), 1)

  # For all non-NA rows, comp_prot_score should be between 1 and 4
  expect_true(min(result$comp_prot_score, na.rm = TRUE) >= 1)
  expect_true(max(result$comp_prot_score, na.rm = TRUE) <= 4)
})
