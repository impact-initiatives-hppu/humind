library(testthat)
library(dplyr)

test_that("add_occupancy_cat works with default parameters", {
  df <- data.frame(
    hlp_occupancy = c("no_agreement", "rented", "ownership", "dnk", "hosted_free", "pnta", "other")
  )

  result <- add_occupancy_cat(df)

  expected <- df %>%
    mutate(hlp_occupancy_cat = case_when(
      hlp_occupancy == "no_agreement" ~ "high_risk",
      hlp_occupancy %in% c("rented", "hosted_free") ~ "medium_risk",
      hlp_occupancy == "ownership" ~ "low_risk",
      hlp_occupancy %in% c("dnk", "pnta", "other") ~ "undefined",
      TRUE ~ NA_character_
    ))

  expect_equal(result, expected)
})

test_that("add_occupancy_cat handles all categories", {
  df <- data.frame(
    hlp_occupancy = c("no_agreement", "rented", "ownership", "dnk", "hosted_free", "pnta", "other")
  )

  result <- add_occupancy_cat(df)

  expected <- df %>%
    mutate(hlp_occupancy_cat = case_when(
      hlp_occupancy == "no_agreement" ~ "high_risk",
      hlp_occupancy %in% c("rented", "hosted_free") ~ "medium_risk",
      hlp_occupancy == "ownership" ~ "low_risk",
      hlp_occupancy %in% c("dnk", "pnta", "other") ~ "undefined",
      TRUE ~ NA_character_
    ))

  expect_equal(result, expected)
})

test_that("add_occupancy_cat handles all NA values", {
  df <- data.frame(
    hlp_occupancy = c(NA, NA, NA, NA, NA)
  )

  result <- add_occupancy_cat(df)

  expected <- df %>%
    mutate(hlp_occupancy_cat = NA_character_)

  expect_equal(result, expected)
})

test_that("add_occupancy_cat handles missing occupancy column", {
  df <- data.frame(
    some_other_col = c("no_agreement", "rented", "ownership", "dnk", "hosted_free")
  )

  expect_error(add_occupancy_cat(df), class = "error")
})

#test_that("add_occupancy_cat handles out-of-range values", {
#  df <- data.frame(
#    hlp_occupancy = c("unknown", "rented", "ownership", "dnk", "invalid")
#  )
#
#  result <- add_occupancy_cat(df)
#
#  expected <- df %>%
#    mutate(hlp_occupancy_cat = case_when(
#      hlp_occupancy == "no_agreement" ~ "high_risk",
#      hlp_occupancy %in% c("rented", "hosted_free") ~ "medium_risk",
#      hlp_occupancy == "ownership" ~ "low_risk",
#      hlp_occupancy %in% c("dnk", "pnta", "other") ~ "undefined",
#      TRUE ~ NA_character_
#    ))
#
#  expect_equal(result, expected)
#})
