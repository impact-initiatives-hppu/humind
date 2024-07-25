library(testthat)
library(dplyr)

# Sample data frame
df <- data.frame(
  uuid = 1:3,
  cm_income_source = c("dnk", "cm_income_source_salaried_n cm_income_source_casual_n", "none"),
  cm_income_source_salaried_n = c(NA, 500, NA),
  cm_income_source_casual_n = c(NA, 200, NA),
  cm_income_source_own_business_n = NA,
  cm_income_source_own_production_n = NA,
  cm_income_source_social_benefits_n = NA,
  cm_income_source_rent_n = NA,
  cm_income_source_remittances_n = NA,
  cm_income_source_assistance_n = NA,
  cm_income_source_support_friends_n = NA,
  cm_income_source_donation_n = NA,
  cm_income_source_other_n = NA
)

# Convert all income source columns to numeric
income_sources <- c("cm_income_source_salaried_n", "cm_income_source_casual_n",
                    "cm_income_source_own_business_n", "cm_income_source_own_production_n",
                    "cm_income_source_social_benefits_n", "cm_income_source_rent_n",
                    "cm_income_source_remittances_n", "cm_income_source_assistance_n",
                    "cm_income_source_support_friends_n", "cm_income_source_donation_n",
                    "cm_income_source_other_n")

df[income_sources] <- lapply(df[income_sources], as.numeric)


test_that("add_income_source_zero_to_sl correctly adds zero when income source was skipped", {
  result <- add_income_source_zero_to_sl(df)

  expect_equal(result$cm_income_source_salaried_n, c(NA, 500, 0))
  expect_equal(result$cm_income_source_casual_n, c(NA, 200, 0))
  expect_equal(result$cm_income_source_own_business_n, c(NA, 0, 0))
  expect_equal(result$cm_income_source_own_production_n, c(NA, 0, 0))
  # Add similar expectations for other income source columns
})

#----------------------------------------------------------------------------------------------
df_missing_columns <- data.frame(
  uuid = 1:3,
  cm_income_source_salaried_n = c(NA, 500, NA),
  cm_income_source_casual_n = c(NA, 200, NA)
)

test_that("add_income_source_zero_to_sl throws error when required columns are missing", {
  expect_error(add_income_source_zero_to_sl(df_missing_columns))
})
#----------------------------------------------------------------------------------------------
# Sample data frame with non-numeric income sources
df <- data.frame(
  uuid = 1:3,
  cm_income_source = c("dnk", "cm_income_source_salaried_n cm_income_source_casual_n", "none"),
  cm_income_source_salaried_n = c(NA, 500, NA),
  cm_income_source_casual_n = c(NA, 200, NA),
  cm_income_source_own_business_n = NA,
  cm_income_source_own_production_n = NA,
  cm_income_source_social_benefits_n = NA,
  cm_income_source_rent_n = NA,
  cm_income_source_remittances_n = NA,
  cm_income_source_assistance_n = NA,
  cm_income_source_support_friends_n = NA,
  cm_income_source_donation_n = NA,
  cm_income_source_other_n = NA
)

test_that("add_income_source_zero_to_sl throws error when income_sources are not numeric", {
  expect_error(
    add_income_source_zero_to_sl(df),
    "All columns must be numeric."
  )
})
#----------------------------------------------------------------------------------------------

 # df_test <- add_income_source_zero_to_sl(df,
 #                                          income_source = "cm_income_source",
 #                                          undefined = c("dnk", "pnta", "none"),
 #                                          income_sources = c("cm_income_source_salaried_n",
 #                                                            "cm_income_source_casual_n",
 #                                                             "cm_income_source_own_business_n",
 #                                                             "cm_income_source_own_production_n",
 #                                                            "cm_income_source_social_benefits_n",
 #                                                             "cm_income_source_rent_n",
 #                                                           "cm_income_source_remittances_n",
 #                                                             "cm_income_source_assistance_n",
 #                                                           "cm_income_source_support_friends_n",
 #                                                             "cm_income_source_donation_n",
 #                                                           "cm_income_source_other_n"))
 #
