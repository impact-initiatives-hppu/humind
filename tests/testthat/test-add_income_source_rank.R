df <- data.frame(
  uuid = 1:3,
  cm_income_source_assistance_n = c(50, 0, 0),
  cm_income_source_support_friends_n = c(0, 100, 0),
  cm_income_source_donation_n = c(30, 20, 1),
  cm_income_source_casual_n = c(50, 0, 0),
  cm_income_source_social_benefits_n = c(0, 30, 0),
  cm_income_source_rent_n = c(150, 0, 80),
  cm_income_source_remittances_n = c(25, 38, 0),
  cm_income_source_salaried_n = c(300, 60, 0),
  cm_income_source_own_business_n = c(0, 0, 50),
  cm_income_source_own_production_n = c(0, 0, 20),
  cm_income_source_other_n = c(0, 60, 0)
)
test_that("add_income_source_rank returns correct structure", {
  result <- suppressWarnings(
    add_income_source_rank(df)
  )

  # Test that the result is a data frame
  expect_s3_class(result, "data.frame")

  # Test that the new columns are present
  expect_true(all(
    c(
      "cm_income_source_emergency_n",
      "cm_income_source_unstable_n",
      "cm_income_source_stable_n",
      "cm_income_source_other_n",
      "cm_income_source_top1",
      "cm_income_source_top2",
      "cm_income_source_top3"
    ) %in%
      names(result)
  ))
})

test_that("add_income_source_rank returns correct values", {
  result <- suppressWarnings(add_income_source_rank(df))

  # Test that the counts are correct
  expect_equal(result$cm_income_source_emergency_n, c(2, 2, 1))
  expect_equal(result$cm_income_source_unstable_n, c(3, 2, 1))
  expect_equal(result$cm_income_source_stable_n, c(1, 1, 2))
  expect_equal(result$cm_income_source_other_n, c(0, 1, 0))

  # Test that the final categories are correct
  expect_equal(
    result$cm_income_source_top1,
    c("stable", "emergency", "unstable")
  )
  expect_equal(result$cm_income_source_top2, c("unstable", "stable", "stable"))
  expect_equal(
    result$cm_income_source_top3,
    c("emergency", "unstable", "stable")
  )
})

test_that("add_income_source_rank handles missing columns gracefully", {
  df_missing <- df %>% select(-cm_income_source_assistance_n)
  expect_error(add_income_source_rank(df_missing), class = "error")
})

test_that("add_income_source_rank handles non-numeric columns gracefully", {
  df_non_numeric <- df %>%
    mutate(
      cm_income_source_assistance_n = as.character(
        cm_income_source_assistance_n
      )
    )
  expect_error(add_income_source_rank(df_non_numeric), class = "error")
})


# Sample data frame
df <- data.frame(
  cm_income_source_top1 = c(
    "cm_income_source_assistance_n",
    "cm_income_source_salaried_n",
    "cm_income_source_rent_n"
  ),
  cm_income_source_top2 = c(
    "cm_income_source_social_benefits_n",
    "cm_income_source_support_friends_n",
    "cm_income_source_own_business_n"
  ),
  cm_income_source_top3 = c(
    "cm_income_source_donation_n",
    "cm_income_source_own_production_n",
    "cm_income_source_other_n"
  )
)
