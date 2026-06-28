# Create dummy data
df_dummy <- data.frame(
  fclcm_phase = c(
    "Phase 1 FCLC",
    "Phase 2 FCLC",
    "Phase 3 FCLC",
    "Phase 4 FCLC",
    "Phase 5 FCLC",
    NA
  )
)

# Define tests
test_that("add_comp_foodsec function works correctly with default parameters", {
  result <- add_comp_foodsec(df_dummy)
  expect_equal(result$comp_foodsec_score, c(1, 2, 3, 4, 5, NA))
})

test_that("add_comp_foodsec handles undefined values correctly", {
  df_test <- df_dummy
  df_test$fclcm_phase <- "undefined"
  expect_error(add_comp_foodsec(df_test), class = "error")
})

test_that("add_comp_foodsec handles NA values correctly", {
  df_test <- df_dummy
  result <- add_comp_foodsec(df_test)
  expect_true(is.na(result$comp_foodsec_score[6]))
})

test_that("add_comp_foodsec throws error for missing columns", {
  df_test <- df_dummy
  df_test <- df_test |> select(-fclcm_phase)
  expect_error(add_comp_foodsec(df_test), class = "error")
})

test_that("add_comp_foodsec assigns in need status correctly", {
  result <- add_comp_foodsec(df_dummy)
  expect_equal(result$comp_foodsec_in_need, c(0, 0, 1, 1, 1, NA))
})

test_that("full food security pipeline works end-to-end", {
  df <- data.frame(
    fsl_fcs_cereal = c(7, 1, 3, 2),
    fsl_fcs_legumes = c(7, 1, 1, 2),
    fsl_fcs_veg = c(7, 7, 1, 2),
    fsl_fcs_fruit = c(7, 7, 1, 2),
    fsl_fcs_meat = c(7, 1, 1, 2),
    fsl_fcs_dairy = c(7, 1, 1, 2),
    fsl_fcs_sugar = c(7, 1, 1, 2),
    fsl_fcs_oil = c(7, 1, 1, 2),
    fsl_hhs_nofoodhh = c("no", "no", "yes", "no"),
    fsl_hhs_nofoodhh_freq = c(NA, NA, "sometimes", NA),
    fsl_hhs_sleephungry = c("no", "no", "no", "no"),
    fsl_hhs_sleephungry_freq = c(NA, NA, NA, NA),
    fsl_hhs_alldaynight = c("no", "no", "no", "no"),
    fsl_hhs_alldaynight_freq = c(NA, NA, NA, NA),
    fsl_rcsi_lessquality = c(0, 1, 3, 7),
    fsl_rcsi_borrow = c(0, 0, 0, 7),
    fsl_rcsi_mealsize = c(0, 0, 3, 7),
    fsl_rcsi_mealadult = c(0, 0, 0, 7),
    fsl_rcsi_mealnb = c(0, 0, 0, 7),
    fsl_lcsi_stress1 = c(
      "no_had_no_need",
      "yes",
      "no_had_no_need",
      "no_had_no_need"
    ),
    fsl_lcsi_stress2 = c(
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need"
    ),
    fsl_lcsi_stress3 = c(
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need"
    ),
    fsl_lcsi_stress4 = c(
      "no_had_no_need",
      "no_had_no_need",
      "yes",
      "no_had_no_need"
    ),
    fsl_lcsi_crisis1 = c(
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need"
    ),
    fsl_lcsi_crisis2 = c(
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need"
    ),
    fsl_lcsi_crisis3 = c(
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need"
    ),
    fsl_lcsi_emergency1 = c(
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need"
    ),
    fsl_lcsi_emergency2 = c(
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need"
    ),
    fsl_lcsi_emergency3 = c(
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need",
      "no_had_no_need"
    )
  )

  result <- df |>
    add_fcs(cutoffs = "normal") |>
    add_hhs() |>
    add_rcsi() |>
    add_lcsi() |>
    add_fcm_phase() |>
    add_fclcm_phase() |>
    add_comp_foodsec()

  expect_true("comp_foodsec_score" %in% names(result))
  expect_true("comp_foodsec_in_need" %in% names(result))
  expect_true("comp_foodsec_in_severe_need" %in% names(result))
})
