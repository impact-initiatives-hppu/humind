# Sample data for testing
df <- data.frame(
  var1 = c(1, 2, 3, NA, 5),
  var2 = c(6, NA, 8, 9, 10),
  var3 = c(11, 12, NA, 14, 15),
  weight = c(1, 2, 3, 4, 5),
  group = c("A", "B", "A", "B", "A")
)

df_missing_var <- data.frame(
  var1 = c(1, 2, 3, NA, 5),
  var2 = c(6, NA, 8, 9, 10)
)


# Test cases
test_that("sum_vars works with default parameters", {
  df_result <- sum_vars(df, c("var1", "var2"), "sum_var")
  expect_equal(df_result$sum_var, c(7, NA, 11, NA, 15))
})

test_that("sum_vars handles missing columns", {
  expect_error(sum_vars(df_missing_var, c("var1", "var2", "var3"), "sum_var"), class = "error")
})

test_that("sum_vars handles imputation with 'value'", {
  df_result <- sum_vars(df, c("var1", "var2", "var3"), "sum_var", imputation = "value", value = 0)
  expect_equal(df_result$sum_var, c(18, 14, 11, 23, 30))
})

test_that("sum_vars handles imputation with 'median'", {
  df_result <- sum_vars(df, c("var1", "var2", "var3"), "sum_var", imputation = "median")
  expect_true("sum_var" %in% names(df_result))
})

#test_that("sum_vars handles imputation with 'weighted.median'", {
#  df_result <- sum_vars(df, c("var1", "var2", "var3"), "sum_var", imputation = "weighted.median", weight = "weight")
#  expect_true("sum_var" %in% names(df_result))
#})

test_that("sum_vars creates a new column with custom name", {
  df_result <- sum_vars(df, c("var1", "var2"), "custom_sum_var")
  expect_equal(names(df_result), c("var1", "var2", "var3", "weight", "group", "custom_sum_var"))
})

test_that("sum_vars handles NA removal", {
  df_result <- sum_vars(df, c("var1", "var2"), "sum_var", na_rm = TRUE)
  expect_equal(df_result$sum_var, c(7, 2, 11, 9, 15))
})

test_that("sum_vars throws error for unrecognized imputation method", {
  expect_error(sum_vars(df, c("var1", "var2"), "sum_var", imputation = "unknown"), class = "error")
})

test_that("sum_vars throws error for unimplemented weighted median imputation", {
  expect_error(sum_vars(df, c("var1", "var2", "var3"), "sum_var", imputation = "weighted.median", weight = "weight"))
})
