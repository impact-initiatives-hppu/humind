# Create a sample dataset
df_sample <- dplyr::tibble(
  setting = c("camp", "urban", "rural"),
  comp_wash_score_water_quantity = c(5, 4, 2),
  wash_drinking_water_quality_jmp_cat = c(
    "surface_water",
    "unimproved",
    "limited"
  ),
  wash_sanitation_facility_jmp_cat = c(
    "open_defecation",
    "basic",
    "unimproved"
  ),
  wash_sanitation_facility_cat = c("none", "improved", "unimproved"),
  wash_sharing_sanitation_facility_n_ind = c(
    "50_and_above",
    "20_to_49",
    "19_and_below"
  ),
  wash_sharing_sanitation_facility_cat = c(
    "shared",
    "not_shared",
    "not_applicable"
  ),
  wash_handwashing_facility_jmp_cat = c("no_facility", "basic", "limited")
)

# Test 1: comp_wash_score_water_quantity is passed through from add_hwise()
test_that("comp_wash_score_water_quantity is taken from the pre-computed input column", {
  df_result <- add_comp_wash(df_sample)
  expect_equal(df_result$comp_wash_score_water_quantity, c(5, 4, 2))
})

# Test 2: Test drinking water quality scores based on setting
test_that("Drinking water quality scoring works based on setting", {
  df_result <- add_comp_wash(
    df_sample,
    setting = "setting",
    drinking_water_quality_jmp_cat = "wash_drinking_water_quality_jmp_cat",
    drinking_water_quality_jmp_cat_surface_water = "surface_water",
    drinking_water_quality_jmp_cat_unimproved = "unimproved",
    drinking_water_quality_jmp_cat_limited = "limited",
    drinking_water_quality_jmp_cat_basic = "basic",
    drinking_water_quality_jmp_cat_safely_managed = "safely_managed",
    drinking_water_quality_jmp_cat_undefined = "undefined"
  )

  expected_result <- c(4, 3, 2) # Surface water (camp) -> 4, Unimproved (urban) -> 3, Limited (rural) -> 2

  expect_equal(df_result$comp_wash_score_water_quality, expected_result)
})

# Test 3: Test sanitation score for different settings
test_that("Sanitation scoring works correctly for different settings", {
  df_result <- add_comp_wash(
    df_sample,
    setting = "setting",
    sanitation_facility_jmp_cat = "wash_sanitation_facility_jmp_cat",
    sanitation_facility_cat = "wash_sanitation_facility_cat",
    sanitation_facility_n_ind = "wash_sharing_sanitation_facility_n_ind",
    sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat"
  )

  expected_result <- c(5, 1, 2) # None (camp) -> 5, Improved & Shared (urban) -> 1, Unimproved (rural) -> 2

  expect_equal(df_result$comp_wash_score_sanitation, expected_result)
})

# Test 4: Test hygiene scoring for different settings
test_that("Hygiene scoring works correctly", {
  df_result <- add_comp_wash(
    df_sample,
    setting = "setting",
    handwashing_facility_jmp_cat = "wash_handwashing_facility_jmp_cat",
    handwashing_facility_jmp_cat_no_facility = "no_facility",
    handwashing_facility_jmp_cat_limited = "limited",
    handwashing_facility_jmp_cat_basic = "basic",
    handwashing_facility_jmp_cat_undefined = "undefined"
  )

  expected_result <- c(3, 1, 2) # No facility (camp) -> 3, Basic (urban) -> 1, Limited (rural) -> 2

  expect_equal(df_result$comp_wash_score_hygiene, expected_result)
})

# Test 5: Test final composite score calculation
test_that("Composite WASH score calculation works correctly", {
  df_result <- add_comp_wash(df_sample)

  expected_result <- c(5, 4, 2) # Max of (water quantity, water quality, sanitation, hygiene) for each row

  expect_equal(df_result$comp_wash_score, expected_result)
})

# Test 6: Test if 'is_in_need' and 'is_in_severe_need' flags are correctly set
test_that("Need flags work correctly", {
  df_result <- add_comp_wash(df_sample)

  # Check for the 'comp_wash_in_need' and 'comp_wash_in_severe_need' columns.
  expect_true("comp_wash_in_need" %in% colnames(df_result))
  expect_true("comp_wash_in_severe_need" %in% colnames(df_result))
})

# Test with undefined values for `comp_wash_score_water_quantity`
undefined_water_quantity_data <- data.frame(
  setting = c("camp", "urban", "rural", "camp"),
  comp_wash_score_water_quantity = c(NA, NA, 1, 5),
  wash_drinking_water_quality_jmp_cat = c(
    "basic",
    "limited",
    "unimproved",
    "safely_managed"
  ),
  wash_sanitation_facility_jmp_cat = c(
    "basic",
    "limited",
    "unimproved",
    "basic"
  ),
  wash_sanitation_facility_cat = c(
    "improved",
    "unimproved",
    "none",
    "undefined"
  ),
  wash_sharing_sanitation_facility_n_ind = c(
    "19_and_below",
    "20_to_49",
    "50_and_above",
    NA
  ),
  wash_sharing_sanitation_facility_cat = c(
    "shared",
    "shared",
    "shared",
    "undefined"
  ),
  wash_handwashing_facility_jmp_cat = c(
    "basic",
    "limited",
    "no_facility",
    "undefined"
  )
)

test_that("Function handles undefined water quantity correctly", {
  result <- add_comp_wash(undefined_water_quantity_data)
  expect_equal(result$comp_wash_score_water_quantity, c(NA, NA, 1, 5))
})

test_that("integration: add_hwise() |> add_comp_wash() produces correct comp_wash_score", {
  df <- dplyr::tibble(
    setting = c("camp", "urban", "rural"),
    wash_hwise_drink = c("always", "often", "rarely"),
    wash_hwise_hands = c("always", "sometimes", "never"),
    wash_hwise_plans = c("always", "sometimes", "never"),
    wash_hwise_worry = c("always", "often", "never"),
    wash_drinking_water_quality_jmp_cat = c(
      "surface_water",
      "unimproved",
      "limited"
    ),
    wash_sanitation_facility_jmp_cat = c(
      "open_defecation",
      "basic",
      "unimproved"
    ),
    wash_sanitation_facility_cat = c("none", "improved", "unimproved"),
    wash_sharing_sanitation_facility_n_ind = c(
      "50_and_above",
      "20_to_49",
      "19_and_below"
    ),
    wash_sharing_sanitation_facility_cat = c(
      "shared",
      "not_shared",
      "not_applicable"
    ),
    wash_handwashing_facility_jmp_cat = c("no_facility", "basic", "limited")
  )

  result <- df |> add_hwise() |> add_comp_wash()

  # always+always+always+always = 12 -> severity 5 (camp)
  # often+sometimes+sometimes+often = 3+2+2+3 = 10 -> severity 4 (urban)
  # rarely+never+never+never = 1+0+0+0 = 1 -> severity 1 (rural)
  expect_equal(result$hwise4_score, c(12, 10, 1))
  expect_equal(result$comp_wash_score_water_quantity, c(5, 4, 1))

  expect_equal(result$comp_wash_score, c(5, 4, 2))
})

# Test data for 2026 new logic verification
new_logic_data <- data.frame(
  setting = c("camp", "camp", "camp", "urban", "rural", "rural"),
  comp_wash_score_water_quantity = rep(1, 6),
  wash_drinking_water_quality_jmp_cat = c(
    "basic",
    "limited",
    "unimproved",
    "basic",
    "unimproved",
    "safely_managed"
  ),
  wash_sanitation_facility_jmp_cat = c(
    rep("basic", 5),
    "open_defecation"
  ),
  wash_sanitation_facility_cat = c(
    rep("improved", 5),
    "none"
  ),
  wash_sharing_sanitation_facility_n_ind = rep("19_and_below", 6),
  wash_sharing_sanitation_facility_cat = rep("not_shared", 6),
  wash_handwashing_facility_jmp_cat = rep("basic", 6)
)

test_that("Water quality 2026 new logic is correctly implemented", {
  result <- add_comp_wash(new_logic_data)

  expected <- c(1, 2, 3, 1, 3, 1)

  expect_equal(result$comp_wash_score_water_quality, expected)
})

test_that("Rural sanitation open_defecation 2026 new logic is correctly implemented", {
  result <- add_comp_wash(new_logic_data)

  expect_equal(result$comp_wash_score_sanitation[6], 3)
})

# Test with invalid sanitation facility categories
invalid_sanitation_data <- undefined_water_quantity_data
invalid_sanitation_data$wash_sanitation_facility_jmp_cat <- c(
  "invalid",
  "basic",
  "limited",
  "open_defecation"
)

test_that("Function handles invalid sanitation facility categories", {
  expect_error(add_comp_wash(invalid_sanitation_data), class = "error")
})

test_that("comp_wash_score respects a non-default comp_wash_score_water_quantity column name", {
  df <- dplyr::tibble(
    setting = c("camp", "urban", "rural"),
    my_water_qty = c(5L, 4L, 2L),
    wash_drinking_water_quality_jmp_cat = c(
      "surface_water",
      "unimproved",
      "limited"
    ),
    wash_sanitation_facility_jmp_cat = c(
      "open_defecation",
      "basic",
      "unimproved"
    ),
    wash_sanitation_facility_cat = c("none", "improved", "unimproved"),
    wash_sharing_sanitation_facility_n_ind = c(
      "50_and_above",
      "20_to_49",
      "19_and_below"
    ),
    wash_sharing_sanitation_facility_cat = c(
      "shared",
      "not_shared",
      "not_applicable"
    ),
    wash_handwashing_facility_jmp_cat = c("no_facility", "basic", "limited")
  )

  result <- add_comp_wash(df, comp_wash_hwise_score = "my_water_qty")

  expect_equal(result$comp_wash_score, c(5, 4, 2))
})

test_that("add_comp_wash errors when water quantity score is out of 1-5 range", {
  df <- df_sample
  df$comp_wash_score_water_quantity <- c(6, 4, 2)
  expect_error(add_comp_wash(df), class = "error")
})
