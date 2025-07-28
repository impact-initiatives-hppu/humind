# Sample data for testing
df <- data.frame(
  var1 = c(1, 0, -1, 3, 0),
  var2 = c(0, 2, -2, 4, 1),
  var3 = c(1, 1, 1, 1, 1),
  stringsAsFactors = FALSE
)

# Test with default parameters
test_that("count_if_above_zero works with default parameters", {
  result <- count_if_above_zero(df, vars = c("var1", "var2"), new_colname = "count_above_zero")
  expect_true("count_above_zero" %in% colnames(result))
  expect_equal(result$count_above_zero, c(1, 1, 0, 2, 1))
})

# Test if new dummy variables are created correctly
test_that("dummy variables are created correctly", {
  result <- count_if_above_zero(df, vars = c("var1", "var2"), new_colname = "count_above_zero")
  expect_true(all(c("var1_d", "var2_d") %in% colnames(result)))
  expect_equal(result$var1_d, c(1, 0, NA, 1, 0))
  expect_equal(result$var2_d, c(0, 1, NA, 1, 1))
})

# Test if existing dummy variables are replaced with a warning
test_that("existing dummy variables are replaced with a warning", {
  df_with_dummy <- df
  df_with_dummy$var1_d <- c(1, 1, 1, 1, 1)
  expect_warning(result <- count_if_above_zero(df_with_dummy, vars = c("var1", "var2"), new_colname = "count_above_zero"),
                 class = "warning")
  expect_equal(result$var1_d, c(1, 0, NA, 1, 0))
})

# Test if new column name already exists
test_that("new column name already exists", {
  df_with_colname <- df
  df_with_colname$count_above_zero <- c(0, 0, 0, 0, 0)
  expect_warning(result <- count_if_above_zero(df_with_colname, vars = c("var1", "var2"), new_colname = "count_above_zero"),
                class = "warning")
  expect_equal(result$count_above_zero, c(1, 1, 0, 2, 1))
})

# Test if vars are numeric
test_that("vars are numeric", {
  df_non_numeric <- df
  df_non_numeric$var1 <- as.character(df_non_numeric$var1)
  expect_error(count_if_above_zero(df_non_numeric, vars = c("var1", "var2"), new_colname = "count_above_zero"),
               class = "error")
})

# Test if vars exist in df
test_that("vars exist in df", {
  expect_error(count_if_above_zero(df, vars = c("var1", "var4"), new_colname = "count_above_zero"),
               class = "error")
})
