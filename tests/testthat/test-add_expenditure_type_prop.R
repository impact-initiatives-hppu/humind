# ---- add_expenditure_type_prop ----

make_df <- function(
  food = 100, rent = 50, water = 20, nfi_freq = 10,
  utilities = 30, fuel = 15, transport = 25, comm = 5, other_freq = 10,
  shelter = 40, nfi_infreq = 20, health = 30, education = 60,
  debt = 10, clothing = 15, other_infreq = 5
) {
  dplyr::tibble(
    cm_expenditure_frequent_food = food,
    cm_expenditure_frequent_rent = rent,
    cm_expenditure_frequent_water = water,
    cm_expenditure_frequent_nfi = nfi_freq,
    cm_expenditure_frequent_utilities = utilities,
    cm_expenditure_frequent_fuel = fuel,
    cm_expenditure_frequent_transportation = transport,
    cm_expenditure_frequent_communication = comm,
    cm_expenditure_frequent_other = other_freq,
    cm_expenditure_infrequent_shelter = shelter,
    cm_expenditure_infrequent_nfi = nfi_infreq,
    cm_expenditure_infrequent_health = health,
    cm_expenditure_infrequent_education = education,
    cm_expenditure_infrequent_debt = debt,
    cm_expenditure_infrequent_clothing = clothing,
    cm_expenditure_infrequent_other = other_infreq
  )
}

# ---- Output columns ----

test_that("add_expenditure_type_prop adds cm_expenditure_total column", {
  df <- make_df()
  result <- add_expenditure_type_prop(df)
  expect_true("cm_expenditure_total" %in% colnames(result))
})

test_that("add_expenditure_type_prop adds all _prop columns", {
  df <- make_df()
  result <- add_expenditure_type_prop(df)
  expected_props <- c(
    "cm_expenditure_frequent_food_prop",
    "cm_expenditure_frequent_rent_prop",
    "cm_expenditure_frequent_water_prop",
    "cm_expenditure_frequent_nfi_prop",
    "cm_expenditure_frequent_utilities_prop",
    "cm_expenditure_frequent_fuel_prop",
    "cm_expenditure_frequent_transportation_prop",
    "cm_expenditure_frequent_communication_prop",
    "cm_expenditure_frequent_other_prop",
    "cm_expenditure_infrequent_shelter_prop",
    "cm_expenditure_infrequent_nfi_prop",
    "cm_expenditure_infrequent_health_prop",
    "cm_expenditure_infrequent_education_prop",
    "cm_expenditure_infrequent_debt_prop",
    "cm_expenditure_infrequent_clothing_prop",
    "cm_expenditure_infrequent_other_prop"
  )
  expect_true(all(expected_props %in% colnames(result)))
})

# ---- Total calculation ----

test_that("cm_expenditure_total equals sum of all 16 columns", {
  df <- make_df()
  result <- add_expenditure_type_prop(df)
  expected_total <- 100 + 50 + 20 + 10 + 30 + 15 + 25 + 5 + 10 +
    40 + 20 + 30 + 60 + 10 + 15 + 5
  expect_equal(result$cm_expenditure_total, expected_total)
})

# ---- Proportion correctness ----

test_that("proportions are relative to grand total", {
  df <- make_df()
  result <- add_expenditure_type_prop(df)
  total <- result$cm_expenditure_total
  expect_equal(result$cm_expenditure_frequent_food_prop, 100 / total)
  expect_equal(result$cm_expenditure_infrequent_health_prop, 30 / total)
})

test_that("all proportions sum to 1 when no NA", {
  df <- make_df()
  result <- add_expenditure_type_prop(df)
  prop_cols <- c(
    "cm_expenditure_frequent_food_prop",
    "cm_expenditure_frequent_rent_prop",
    "cm_expenditure_frequent_water_prop",
    "cm_expenditure_frequent_nfi_prop",
    "cm_expenditure_frequent_utilities_prop",
    "cm_expenditure_frequent_fuel_prop",
    "cm_expenditure_frequent_transportation_prop",
    "cm_expenditure_frequent_communication_prop",
    "cm_expenditure_frequent_other_prop",
    "cm_expenditure_infrequent_shelter_prop",
    "cm_expenditure_infrequent_nfi_prop",
    "cm_expenditure_infrequent_health_prop",
    "cm_expenditure_infrequent_education_prop",
    "cm_expenditure_infrequent_debt_prop",
    "cm_expenditure_infrequent_clothing_prop",
    "cm_expenditure_infrequent_other_prop"
  )
  prop_sum <- rowSums(result[prop_cols])
  expect_equal(prop_sum, 1, tolerance = 1e-10)
})

# ---- NA handling ----

test_that("proportions are NA when total expenditure is 0", {
  df <- make_df(
    food = 0, rent = 0, water = 0, nfi_freq = 0,
    utilities = 0, fuel = 0, transport = 0, comm = 0, other_freq = 0,
    shelter = 0, nfi_infreq = 0, health = 0, education = 0,
    debt = 0, clothing = 0, other_infreq = 0
  )
  result <- add_expenditure_type_prop(df)
  expect_true(is.na(result$cm_expenditure_frequent_food_prop))
  expect_true(is.na(result$cm_expenditure_infrequent_health_prop))
})

test_that("NA in one expenditure column propagates to total and props", {
  df <- make_df(food = NA_real_)
  result <- add_expenditure_type_prop(df)
  expect_true(is.na(result$cm_expenditure_total))
  expect_true(is.na(result$cm_expenditure_frequent_food_prop))
})

# ---- Errors ----

test_that("add_expenditure_type_prop errors on missing frequent column", {
  df <- make_df()
  df$cm_expenditure_frequent_food <- NULL
  expect_error(add_expenditure_type_prop(df))
})

test_that("add_expenditure_type_prop errors on missing infrequent column", {
  df <- make_df()
  df$cm_expenditure_infrequent_health <- NULL
  expect_error(add_expenditure_type_prop(df))
})

test_that("add_expenditure_type_prop errors on non-numeric column", {
  df <- make_df()
  df$cm_expenditure_frequent_food <- as.character(df$cm_expenditure_frequent_food)
  expect_error(add_expenditure_type_prop(df))
})

# NOTE: this test relies on the fix in PR #680 (branch
# 671-feature-ana-ind043-hhs-with-significant-decrease-in-livestock-production)
# where are_values_in_range errors when ANY column has out-of-range values,
# not only when ALL columns do.
test_that("add_expenditure_type_prop errors on negative expenditure values", {
  df <- make_df(food = -10)
  expect_error(add_expenditure_type_prop(df))
})
