# Test data frame with all cases
df <- data.frame(
  "snfi_shelter_damage/none" = c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  "snfi_shelter_damage/minor_roof" = c(0, 1, 1, 0, 0, 1, 0, 0, 0, 0),
  "snfi_shelter_damage/major_roof" = c(0, 0, 1, 1, 0, 0, 1, 0, 0, 0),
  "snfi_shelter_damage/windows_doors" = c(0, 0, 0, 1, 1, 0, 1, 1, 0, 0),
  "snfi_shelter_damage/floors" = c(0, 0, 0, 0, 1, 0, 0, 1, 1, 0),
  "snfi_shelter_damage/walls" = c(0, 0, 0, 0, 0, 1, 0, 1, 1, 0),
  "snfi_shelter_damage/total_collapse" = c(0, 0, 0, 1, 0, 0, 1, 0, 1, 0),
  "snfi_shelter_damage/other" = c(0, 0, 0, 0, 0, 0, 0, 1, 0, 0),
  "snfi_shelter_damage/dnk" = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
  "snfi_shelter_damage/pnta" = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  check.names = FALSE
)

# Expected output for each row (worst case scenario)
expected <- c(
  "none", # 1. only none
  "damaged", # 2. only minor_roof
  "part", # 3. minor_roof + major_roof (major_roof should take precedence)
  "total", # 4. major_roof + windows_doors + total_collapse (total should take precedence)
  "damaged", # 5. minor_roof + windows_doors + floors
  "damaged", # 6. minor_roof + walls
  "total", # 7. major_roof + total_collapse (total should take precedence)
  "damaged", # 8. windows_doors + floors + walls + other (should be damaged, undefined is ignored)
  "total", # 9. floors + walls + total_collapse (total should take precedence)
  "undefined" # 10. only dnk
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
  expect_true(all(result$snfi_shelter_damage_cat %in% c(NA, "undefined")))
})

# 2. Multiple codes in the same category set to 1 (e.g. two 'damaged' columns)
test_that("add_shelter_damage_cat handles multiple codes in the same category", {
  df_multi <- df[2, ]
  df_multi[
    1,
    c(
      "snfi_shelter_damage/windows_doors",
      "snfi_shelter_damage/floors"
    )
  ] <- 1
  result <- add_shelter_damage_cat(df_multi)
  expect_true(result$snfi_shelter_damage_cat[1] == "damaged")
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
  # Row 1: both 'none' and 'minor_roof' selected
  df_logic[1, "snfi_shelter_damage/none"] <- 1
  df_logic[1, "snfi_shelter_damage/minor_roof"] <- 1
  # Row 2: both 'dnk' and 'major_roof' selected
  df_logic[2, "snfi_shelter_damage/dnk"] <- 1
  df_logic[2, "snfi_shelter_damage/major_roof"] <- 1
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
