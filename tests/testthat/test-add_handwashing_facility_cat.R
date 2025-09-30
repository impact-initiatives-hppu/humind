test_df <- dplyr::tibble(
  survey_modality = c(
    "in_person",
    "in_person",
    "in_person",
    "in_person",
    "remote",
    "remote",
    "in_person",
    "in_person"
  ),
  wash_handwashing_facility = c(
    "available_fixed_in_dwelling",
    "available_fixed_in_plot",
    "available_fixed_in_plot",
    "none",
    "available_fixed_or_mobile",
    "none",
    "no_permission",
    "other"
  ),
  wash_handwashing_facility_observed_water = c(
    "water_available",
    "water_not_available",
    "water_available",
    "water_available",
    NA,
    NA,
    NA,
    "water_available"
  ),
  wash_soap_observed = c(
    "yes_soap_shown",
    "yes_soap_shown",
    "no",
    "yes_soap_shown",
    NA,
    NA,
    NA,
    "yes_soap_shown"
  ),
  wash_handwashing_facility_reported = c(
    NA,
    NA,
    NA,
    NA,
    "fixed_dwelling",
    "none",
    "mobile",
    "other"
  ),
  wash_handwashing_facility_water_reported = c(
    NA,
    NA,
    NA,
    NA,
    "yes",
    "no",
    "yes",
    "dnk"
  ),
  wash_soap_reported = c(
    NA,
    NA,
    NA,
    NA,
    "yes",
    "no",
    "yes",
    "dnk"
  ),
  # NEW: defaults keep prior expectations unchanged
  wash_soap_observed_type = NA_character_,
  wash_soap_reported_type = NA_character_
)

test_that("add_handwashing_facility_cat categorizes correctly", {
  expected <- c(
    "basic",
    "limited",
    "limited",
    "no_facility",
    "basic",
    "no_facility",
    "basic",
    NA
  )
  result_df <- add_handwashing_facility_cat(test_df)
  expect_equal(result_df$wash_handwashing_facility_jmp_cat, expected)
})


survey_modality <- c(
  "in_person",
  "remote"
)

wash_handwashing_facility <- c(
  "available_fixed_in_dwelling",
  "available_fixed_in_plot",
  "available_fixed_or_mobile",
  "none",
  "no_permission",
  "other"
)
wash_handwashing_facility_observed_water <- c(
  "water_available",
  "water_not_available",
  "water_available",
  NA
)

wash_soap_observed <- c(
  "yes_soap_shown",
  "no",
  NA
)


wash_handwashing_facility_reported <- c(
  "fixed_dwelling",
  "none",
  "mobile",
  "other",
  NA
)

wash_handwashing_facility_water_reported <- c(
  "yes",
  "no",
  "yes",
  "dnk",
  NA
)

wash_soap_reported <- c(
  "yes",
  "no",
  "yes",
  "dnk",
  NA
)
wash_soap_observed_type <- c(NA_character_)
wash_soap_reported_type <- c(NA_character_)

exhaustive_df <- tidyr::expand_grid(
  survey_modality,
  wash_handwashing_facility,
  wash_handwashing_facility_observed_water,
  wash_soap_observed,
  wash_handwashing_facility_reported,
  wash_handwashing_facility_water_reported,
  wash_soap_reported,
  wash_soap_observed_type,
  wash_soap_reported_type,
)

test_that("Response codes with multiple answer options do not affect the result when provided", {
  result_scalar <- add_handwashing_facility_cat(
    exhaustive_df,
    facility_observed_water_no = "water_not_available",
    facility_observed_soap_no = "no",
    facility_reported_no = "none",
    facility_reported_water_no = "no",
    facility_reported_soap_no = "no"
  )

  # Did not include 'facility_no' because the code will raise an error
  # and it already checks that it is exactly one value
  result_vector <- add_handwashing_facility_cat(
    exhaustive_df,
    facility_observed_water_no = c("water_not_available", "indifferent"),
    facility_observed_soap_no = c("no", "indifferent"),
    facility_reported_no = c("none", "indifferent"),
    facility_reported_water_no = c("no", "indifferent"),
    facility_reported_soap_no = c("no", "indifferent")
  )

  expect_equal(result_scalar, result_vector)
})

test_that("answer options in the 'no' vectors get treated as 'no'", {
  #TODO: expand this to all *_no arguments
  default_soap_no <- "no"
  soap_no <- c(default_soap_no, "mud")
  wash_soap_observed <- c(
    "yes_soap_shown",
    soap_no,
    NA
  )

  wash_soap_reported <- c(
    "yes",
    "yes",
    soap_no,
    "dnk",
    NA
  )
  exhaustive_df <- tidyr::expand_grid(
    survey_modality,
    wash_handwashing_facility,
    wash_handwashing_facility_observed_water,
    wash_soap_observed,
    wash_handwashing_facility_reported,
    wash_handwashing_facility_water_reported,
    wash_soap_reported,
    wash_soap_observed_type,
    wash_soap_reported_type
  )

  result <- add_handwashing_facility_cat(
    exhaustive_df,
    facility_observed_soap_no = soap_no,
    facility_reported_soap_no = soap_no
  )

  exhaustive_df_mutated <- exhaustive_df |>
    dplyr::mutate(
      wash_soap_observed = dplyr::case_when(
        wash_soap_observed %in% soap_no ~ default_soap_no,
        TRUE ~ wash_soap_observed
      ),
      wash_soap_reported = dplyr::case_when(
        wash_soap_reported %in% soap_no ~ default_soap_no,
        TRUE ~ wash_soap_reported
      )
    )
  # we check that all else being equal, a change of a 'no' option to a literal 'no' yields the same results
  result_mutated <- add_handwashing_facility_cat(exhaustive_df_mutated)
  expect_equal(
    result$wash_handwashing_facility_jmp_cat,
    result_mutated$wash_handwashing_facility_jmp_cat
  )
})

test_that("outputs are within allowed set", {
  out <- add_handwashing_facility_cat(
    exhaustive_df
  )$wash_handwashing_facility_jmp_cat
  expect_true(all(
    is.na(out) | out %in% c("basic", "limited", "no_facility", "undefined")
  ))
})

test_that("reported yes + NA water or soap returns 'limited'", {
  df <- dplyr::tibble(
    survey_modality = "remote",
    wash_handwashing_facility = "available_fixed_or_mobile", # irrelevant on reported path
    wash_handwashing_facility_observed_water = NA,
    wash_soap_observed = NA,
    wash_handwashing_facility_reported = "fixed_dwelling", # YES
    wash_handwashing_facility_water_reported = c(NA, "yes", NA),
    wash_soap_reported = c("yes", NA, NA),
    wash_soap_observed_type = NA_character_,
    wash_soap_reported_type = NA_character_
  )

  out <- add_handwashing_facility_cat(df)$wash_handwashing_facility_jmp_cat
  # cases: (NA, yes) -> limited; (yes, NA) -> limited; (NA, NA) -> limited
  expect_identical(out, c("limited", "limited", "limited"))
})

test_that("reported ash/mud/sand soap type demotes 'basic' to 'limited'", {
  df <- dplyr::tibble(
    survey_modality = "remote",
    wash_handwashing_facility = "available_fixed_in_plot", # ignored on reported
    wash_handwashing_facility_observed_water = NA,
    wash_soap_observed = NA,
    wash_handwashing_facility_reported = "mobile", # YES
    wash_handwashing_facility_water_reported = "yes",
    wash_soap_reported = "yes",
    wash_soap_observed_type = NA_character_,
    wash_soap_reported_type = c("soap", "detergent", "ash_mud_sand")
  )

  # default args already include:
  #   soap_type_reported_yes = c("soap","detergent")
  #   soap_type_reported_no  = c("ash_mud_sand")
  out <- add_handwashing_facility_cat(df)$wash_handwashing_facility_jmp_cat
  expect_identical(out, c("basic", "basic", "limited"))
})

test_that("observed ash/mud/sand soap type demotes 'basic' to 'limited'", {
  df <- dplyr::tibble(
    survey_modality = "in_person",
    wash_handwashing_facility = "available_fixed_in_dwelling",
    wash_handwashing_facility_observed_water = "water_available",
    wash_soap_observed = "yes_soap_shown",
    wash_handwashing_facility_reported = NA,
    wash_handwashing_facility_water_reported = NA,
    wash_soap_reported = NA,
    wash_soap_observed_type = "ash_mud_sand",
    wash_soap_reported_type = NA_character_
  )

  out <- add_handwashing_facility_cat(
    df,
    # allow the observed type column to carry "ash_mud_sand" as a known code
    soap_type_observed_no = c("no", "ash_mud_sand")
  )$wash_handwashing_facility_jmp_cat

  expect_identical(out, "limited")
})

test_that("reported soap type does not affect observed path", {
  df <- dplyr::tibble(
    survey_modality = "in_person",
    wash_handwashing_facility = "available_fixed_in_dwelling",
    wash_handwashing_facility_observed_water = "water_available",
    wash_soap_observed = "yes_soap_shown",
    wash_handwashing_facility_reported = NA,
    wash_handwashing_facility_water_reported = NA,
    wash_soap_reported = NA,
    wash_soap_observed_type = NA_character_,
    wash_soap_reported_type = "ash_mud_sand" # should NOT leak into observed
  )
  out <- add_handwashing_facility_cat(df)$wash_handwashing_facility_jmp_cat
  expect_identical(out, "basic")
})

test_that("observed soap type does not affect reported path", {
  df <- dplyr::tibble(
    survey_modality = "remote",
    wash_handwashing_facility = "available_fixed_in_plot",
    wash_handwashing_facility_observed_water = NA,
    wash_soap_observed = NA,
    wash_handwashing_facility_reported = "mobile",
    wash_handwashing_facility_water_reported = "yes",
    wash_soap_reported = "yes",
    wash_soap_observed_type = "ash_mud_sand", # should NOT leak into reported
    wash_soap_reported_type = "soap"
  )
  out <- add_handwashing_facility_cat(df)$wash_handwashing_facility_jmp_cat
  expect_identical(out, "basic")
})
