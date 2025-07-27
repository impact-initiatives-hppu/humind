# Load required packages
library(testthat)
library(dplyr)

# Test data frame with all cases
df <- data.frame(
  "snfi_shelter_damage/none" = c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  "snfi_shelter_damage/minor" = c(0, 1, 1, 0, 0, 1, 0, 0, 0, 0),
  "snfi_shelter_damage/major" = c(0, 0, 1, 1, 0, 0, 1, 0, 0, 0),
  "snfi_shelter_damage/damage_windows_doors" = c(0, 0, 0, 1, 1, 0, 1, 1, 0, 0),
  "snfi_shelter_damage/damage_floors" = c(0, 0, 0, 0, 1, 0, 0, 1, 1, 0),
  "snfi_shelter_damage/damage_walls" = c(0, 0, 0, 0, 0, 1, 0, 1, 1, 0),
  "snfi_shelter_damage/total_collapse" = c(0, 0, 0, 1, 0, 0, 1, 0, 1, 0),
  "snfi_shelter_damage/other" = c(0, 0, 0, 0, 0, 0, 0, 1, 0, 0),
  "snfi_shelter_damage/dnk" = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
  "snfi_shelter_damage/pnta" = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  check.names = FALSE
)

# Expected output for each row (worst case scenario)
expected <- c(
  "No damage", # 1. only none
  "Damaged", # 2. only minor
  "Partial collapse or destruction", # 3. minor + major (major should take precedence)
  "Total collapse or destruction", # 4. major + damage_windows_doors + total_collapse (total should take precedence)
  "Damaged", # 5. minor + damage_windows_doors + damage_floors
  "Damaged", # 6. minor + damage_walls
  "Total collapse or destruction", # 7. major + total_collapse (total should take precedence)
  "Damaged", # 8. damage_windows_doors + damage_floors + damage_walls + other (should be Damaged, Undefined is ignored)
  "Total collapse or destruction", # 9. damage_floors + damage_walls + total_collapse (total should take precedence)
  "Undefined" # 10. only dnk
)

test_that("add_shelter_damage_cat worst case scenario is respected", {
  result <- add_shelter_damage_cat(df)
  expect_equal(result$snfi_shelter_damage_cat, expected)
})

# Test: Error if required columns are missing
test_that("add_shelter_damage_cat errors if required columns are missing", {
  df_missing <- data.frame(
    "snfi_shelter_damage/none" = c(1, 0),
    check.names = FALSE
  )
  expect_error(add_shelter_damage_cat(df_missing[, 1, drop = FALSE]))
})

# Test: Error if values are not 0/1
test_that("add_shelter_damage_cat errors if values are not 0/1", {
  df_bad <- df
  df_bad[1, 1] <- 2
  expect_error(add_shelter_damage_cat(df_bad))
})

# 1. All columns zero (no response selected)
test_that("add_shelter_damage_cat returns NA or Undefined if no response selected", {
  df_zeros <- as.data.frame(matrix(0, nrow = 2, ncol = ncol(df)))
  colnames(df_zeros) <- colnames(df)
  result <- add_shelter_damage_cat(df_zeros)
  expect_true(all(result$snfi_shelter_damage_cat %in% c(NA, "Undefined")))
})

# 2. Multiple codes in the same category set to 1 (e.g. two 'damaged' columns)
test_that("add_shelter_damage_cat handles multiple codes in the same category", {
  df_multi <- df[2, ]
  df_multi[
    1,
    c(
      "snfi_shelter_damage/damage_windows_doors",
      "snfi_shelter_damage/damage_floors"
    )
  ] <- 1
  result <- add_shelter_damage_cat(df_multi)
  expect_true(result$snfi_shelter_damage_cat[1] == "Damaged")
})

# 3. NA in some columns
test_that("add_shelter_damage_cat propagates NA if present in input", {
  df_na <- df
  df_na[1, 1] <- NA
  result <- add_shelter_damage_cat(df_na)
  expect_true(is.na(result$snfi_shelter_damage_cat[1]))
})

# 4. Different column order
test_that("add_shelter_damage_cat does not depend on column order", {
  df_rev <- df[, rev(seq_len(ncol(df)))]
  result1 <- add_shelter_damage_cat(df)
  result2 <- add_shelter_damage_cat(df_rev)
  expect_equal(result1$snfi_shelter_damage_cat, result2$snfi_shelter_damage_cat)
})

# 5. Extra unused columns
test_that("add_shelter_damage_cat ignores extra columns not expected", {
  df_extra <- df
  df_extra$unrelated <- 1:10
  result <- add_shelter_damage_cat(df_extra)
  expect_equal(result$snfi_shelter_damage_cat, expected)
})

# 6. Constraint: selecting 'no damage', 'dnk', or 'pnta' with any other option triggers a warning
test_that("add_shelter_damage_cat emits a warning if constraint is violated", {
  df_logic <- df[1:2, ]
  # Row 1: both 'none' and 'minor' selected
  df_logic[1, "snfi_shelter_damage/none"] <- 1
  df_logic[1, "snfi_shelter_damage/minor"] <- 1
  # Row 2: both 'dnk' and 'major' selected
  df_logic[2, "snfi_shelter_damage/dnk"] <- 1
  df_logic[2, "snfi_shelter_damage/major"] <- 1
  expect_warning(
    add_shelter_damage_cat(df_logic),
    regexp = "violate the constraint: cannot select 'no damage', 'don't know', or 'prefer not to answer' with any other option"
  )
})

# 7. Empty data frame
test_that("add_shelter_damage_cat returns an empty data frame if input is empty", {
  df_empty <- df[0, ]
  result <- add_shelter_damage_cat(df_empty)
  expect_equal(nrow(result), 0)
})
