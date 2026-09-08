# Sample data for testing
df <- data.frame(
  wash_sanitation_facility = c(
    "flush_piped_sewer",
    "flush_piped_sewer",
    "flush_open_drain",
    "none",
    "other",
    "pit_latrine_wo_slab"
  ),
  wash_sanitation_facility_sharing_yn = c(
    "yes",
    "no",
    "no",
    NA,
    "yes",
    "no"
  ),
  wash_sanitation_facility_sharing_n = c(5, 1, 1, NA, 10, 2),
  hh_size = c(4, 5, 5, 3, 6, 4),
  weight = c(1.5, 2.0, 1, 1.0, 2.5, 1.8),
  stringsAsFactors = FALSE
)

# Test add_sanitation_facility_cat function
test_that("add_sanitation_facility_cat works correctly", {
  result <- add_sanitation_facility_cat(df)
  expect_true("wash_sanitation_facility_cat" %in% colnames(result))
  expect_equal(
    result$wash_sanitation_facility_cat,
    c("improved", "improved", "unimproved", "none", "undefined", "unimproved")
  )
})

# Test add_sharing_sanitation_facility_cat function
test_that("add_sharing_sanitation_facility_cat works correctly", {
  result <- add_sharing_sanitation_facility_cat(df)
  expect_true("wash_sharing_sanitation_facility_cat" %in% colnames(result))
  expect_equal(
    result$wash_sharing_sanitation_facility_cat,
    c(
      "shared",
      "not_shared",
      "not_shared",
      "not_applicable",
      "shared",
      "not_shared"
    )
  )
})

# Test add_sharing_sanitation_facility_num_ind function
test_that("add_sharing_sanitation_facility_num_ind works correctly", {
  mean_hh_size <- stats::weighted.mean(df$hh_size, df$weight, na.rm = TRUE)
  df_test <- add_sanitation_facility_cat(df)
  df_test <- add_sharing_sanitation_facility_cat(df_test)
  result <- add_sharing_sanitation_facility_n_ind(df_test)
  expected_sharing_n <- (df$wash_sanitation_facility_sharing_n - 1) *
    mean_hh_size +
    df$hh_size
  # [2], [3] and [6] Not shared so NA (issue #788)
  expected_sharing_n[2] <- NA
  expected_sharing_n[3] <- NA
  expected_sharing_n[6] <- NA
  # [4] No facility so NA
  expected_sharing_n[4] <- NA
  expect_true("wash_sharing_sanitation_facility_n_ind" %in% colnames(result))
  expect_equal(result$wash_sanitation_facility_sharing_n, expected_sharing_n)
  expect_equal(
    result$wash_sharing_sanitation_facility_n_ind,
    c(
      "20_to_49",
      NA,
      NA,
      NA,
      "20_to_49",
      NA
    )
  )
})

test_that("property: non-shared facilities do not receive an individual count (issue #788)", {
  df <- generate_sharing_n_ind_df()
  result <- add_sharing_sanitation_facility_n_ind(df)
  is_shared <- df$wash_sharing_sanitation_facility_cat == "shared"
  expect_true(all(is.na(result$wash_sharing_sanitation_facility_n_ind[
    !is_shared
  ])))
  expect_true(all(
    !is.na(result$wash_sharing_sanitation_facility_n_ind[is_shared])
  ))
})

test_that("snapshot: individual count classification is stable", {
  result <- add_sharing_sanitation_facility_n_ind(generate_sharing_n_ind_df())
  expect_snapshot_value(
    dplyr::select(
      result,
      wash_sharing_sanitation_facility_cat,
      wash_sharing_sanitation_facility_n_ind
    ),
    style = "json2"
  )
})

test_that("add_sharing_sanitation_facility_n_ind errors clearly on missing weight column", {
  df_test <- df |>
    add_sanitation_facility_cat() |>
    add_sharing_sanitation_facility_cat() |>
    dplyr::select(-weight)
  expect_error(
    add_sharing_sanitation_facility_n_ind(df_test),
    regexp = "Missing columns"
  )
})

# Test add_sanitation_facility_jmp_cat function
test_that("add_sanitation_facility_jmp_cat works correctly", {
  df <- add_sanitation_facility_cat(df)
  df <- add_sharing_sanitation_facility_cat(df)
  result <- add_sanitation_facility_jmp_cat(df)
  expect_true("wash_sanitation_facility_jmp_cat" %in% colnames(result))
  expect_equal(
    result$wash_sanitation_facility_jmp_cat,
    c(
      "limited",
      "basic",
      "unimproved",
      "open_defecation",
      "undefined",
      "unimproved"
    )
  )
})
