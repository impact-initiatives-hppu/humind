# Sample data frame
df <- data.frame(
  uuid = 1:3,
  var1 = c(5, 2, 3),
  var2 = c(3, 5, 1),
  var3 = c(1, 3, 2)
)

test_that("rank_top3_vars correctly identifies and ranks the top three variables", {
  result <- rank_top3_vars(
    df,
    vars = c("var1", "var2", "var3"),
    new_colname_top1 = "top1",
    new_colname_top2 = "top2",
    new_colname_top3 = "top3"
  )

  expect_equal(result$top1, c("var1", "var2", "var1"))
  expect_equal(result$top2, c("var2", "var3", "var3"))
  expect_equal(result$top3, c("var3", "var1", "var2"))
})

#-------------------------------------------------------------------------------
# Sample data frame with ties
df <- data.frame(
  uuid = 1:3,
  var1 = c(5, 2, 3),
  var2 = c(5, 2, 4),
  var3 = c(1, 3, 2),
  var4 = c(2, 1, 4)
)

test_that("rank_top3_vars correctly handles ties", {
  result <- rank_top3_vars(
    df,
    vars = c("var1", "var2", "var3", "var4"),
    new_colname_top1 = "top1",
    new_colname_top2 = "top2",
    new_colname_top3 = "top3"
  )

  expect_equal(result$top1, c("var1", "var3", "var2"))
  expect_equal(result$top2, c("var2", "var1", "var4"))
  expect_equal(result$top3, c("var4", "var2", "var1"))
})

#-------------------------------------------------------------------------------

# Sample data frame with existing columns
df <- data.frame(
  uuid = 1:3,
  var1 = c(5, 2, 3),
  var2 = c(3, 5, 1),
  var3 = c(1, 3, 2),
  top1 = c("old1", "old2", "old3")
)

test_that("rank_top3_vars issues a warning when new column names already exist", {
  expect_warning(
    result <- rank_top3_vars(
      df,
      vars = c("var1", "var2", "var3"),
      new_colname_top1 = "top1",
      new_colname_top2 = "top2",
      new_colname_top3 = "top3"
    ),
    "The following variables exist in 'df' and will be replaced: top1"
  )

  expect_equal(result$top1, c("var1", "var2", "var1"))
  expect_equal(result$top2, c("var2", "var3", "var3"))
  expect_equal(result$top3, c("var3", "var1", "var2"))
})

#-------------------------------------------------------------------------------
# Sample data frame with NA values
df <- data.frame(
  uuid = 1:3,
  var1 = c(5, 2, 3),
  var2 = c(NA, 5, 1),
  var3 = c(1, NA, 2)
)

test_that("rank_top3_vars correctly handles NA values", {
  result <- rank_top3_vars(
    df,
    vars = c("var1", "var2", "var3"),
    new_colname_top1 = "top1",
    new_colname_top2 = "top2",
    new_colname_top3 = "top3"
  )

  expect_equal(result$top1, c("var1", "var2", "var1"))
  expect_equal(result$top2, c("var3", "var1", "var3"))
  expect_equal(result$top3, c(NA, NA, "var2"))
})

df_test <- rank_top3_vars(
  df,
  vars = c("var1", "var2", "var3"),
  new_colname_top1 = "top1",
  new_colname_top2 = "top2",
  new_colname_top3 = "top3"
)
