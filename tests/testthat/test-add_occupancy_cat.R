# Example data frame covering all combinations
example_df <- data.frame(
  hlp_occupancy = c(
    "no_agreement",
    "rented",
    "hosted_free",
    "ownership",
    "dnk",
    "pnta",
    "other",
    NA
  ),
  hlp_risk_eviction = c(
    "yes",
    "no",
    "dnk",
    "pnta",
    "yes",
    "no",
    NA,
    "dnk"
  )
)

# Run function

# ---- Unit Tests ----
test_that("hlp_occupancy_cat is correctly assigned for all combinations", {
  expected <- c(
    "high_risk",
    "medium_risk",
    "medium_risk",
    "low_risk",
    "undefined",
    "undefined",
    "undefined",
    NA
  )
  result <- add_occupancy_cat(example_df)
  expect_equal(result$hlp_occupancy_cat, expected)
})

test_that("hlp_eviction_cat is correctly assigned for all combinations", {
  expected <- c(
    "high_risk",
    "low_risk",
    "undefined",
    "undefined",
    "high_risk",
    "low_risk",
    NA,
    "undefined"
  )
  result <- add_occupancy_cat(example_df)
  expect_equal(result$hlp_eviction_cat, expected)
})

test_that("hlp_tenure_security is correctly assigned for all combinations", {
  expected <- c(
    "high_risk",
    "medium_risk",
    "medium_risk",
    "low_risk",
    "high_risk",
    "low_risk",
    "undefined",
    "undefined"
  )
  result <- add_occupancy_cat(example_df)
  expect_equal(result$hlp_tenure_security, expected)
})

test_that("Function handles missing columns with error", {
  df_missing <- data.frame(hlp_occupancy = c("no_agreement", "rented"))
  expect_error(add_occupancy_cat(df_missing), class = "error")
  df_missing2 <- data.frame(hlp_risk_eviction = c("yes", "no"))
  expect_error(add_occupancy_cat(df_missing2), class = "error")
})

test_that("Function errors on out-of-range values for occupancy or eviction", {
  df_out <- data.frame(
    hlp_occupancy = c("unknown", "invalid", NA),
    hlp_risk_eviction = c("maybe", "unknown", NA)
  )
  expect_error(add_occupancy_cat(df_out), class = "error")
})

# Edge case: all NA

test_that("Function handles all NA values", {
  df_na <- data.frame(
    hlp_occupancy = rep(NA, 5),
    hlp_risk_eviction = rep(NA, 5)
  )
  result_na <- add_occupancy_cat(df_na)
  expected <- rep(NA_character_, 5)
  expect_equal(result_na$hlp_occupancy_cat, expected)
  expect_equal(result_na$hlp_eviction_cat, expected)
  expect_equal(result_na$hlp_tenure_security, expected)
})
