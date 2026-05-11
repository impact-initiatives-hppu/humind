# Test data
df <- data.frame(
  col1 = c(1, 2, 3, 4, NA),
  col2 = c("a", "b", "c", "d", NA),
  col3 = c(7, 8, 9, 10, NA),
  col4 = c(3, 4, 5, 6, NA),
  col5 = c(NA, NA, NA, NA, NA)
)

df_all_na <- data.frame(
  col1 = c(NA, NA, NA, NA, NA),
  col2 = c(NA, NA, NA, NA, NA)
)

df_missing_cols <- data.frame(
  col1 = c(1, 2, 3, 4),
  col2 = c(5, 6, 7, 8)
)

df_non_numeric <- data.frame(
  col1 = c("a", "b", "c"),
  col2 = c(1, 2, 3)
)


########################
### are_cols_numeric
########################

test_that("are_cols_numeric works with default parameters", {
  expect_true(humind:::are_cols_numeric(df, c("col1", "col3", "col4")))
})

test_that("are_cols_numeric handles non-numeric columns", {
  expect_error(
    humind:::are_cols_numeric(df, c("col1", "col2")),
    class = "error"
  )
})

test_that("are_cols_numeric handles missing columns", {
  expect_error(
    humind:::are_cols_numeric(df, c("col1", "col6")),
    class = "error"
  )
})

test_that("are_cols_numeric handles all NA columns", {
  expect_error(humind:::are_cols_numeric(df_all_na, c("col1")), class = "error")
})

##########################
### are_values_in_range
##########################

test_that("are_values_in_range works with default parameters", {
  expect_true(humind:::are_values_in_range(df, c("col1", "col3", "col4")))
})

test_that("are_values_in_range handles values out of range", {
  df_out_of_range <- df
  df_out_of_range$col3[1] <- 10
  expect_error(
    humind:::are_values_in_range(df_out_of_range, c("col3")),
    class = "error"
  )
})

test_that("are_values_in_range handles missing columns", {
  expect_error(
    humind:::are_values_in_range(df, c("col1", "col6")),
    class = "error"
  )
})

#############################
### are_values_in_set
#############################

test_that("are_values_in_set works with default parameters", {
  expect_true(humind:::are_values_in_set(
    df,
    c("col2"),
    set = c("a", "b", "c", "d", NA)
  ))
})

test_that("are_values_in_set handles values out of set", {
  df_out_of_set <- df
  df_out_of_set$col2[1] <- "e"
  expect_error(
    humind:::are_values_in_set(
      df_out_of_set,
      c("col2"),
      set = c("a", "b", "c", "d", NA)
    ),
    class = "error"
  )
})

test_that("are_values_in_set handles missing columns", {
  expect_error(
    humind:::are_values_in_set(
      df,
      c("col1", "col6"),
      set = c("a", "b", "c", "d", NA)
    ),
    class = "error"
  )
})

test_that("are_values_in_set handles all NA columns", {
  expect_true(humind:::are_values_in_set(
    df_all_na,
    c("col1", "col2"),
    set = c("a", "b", "c", "d", NA)
  ))
})

##############################
## subvec_in and subvec_not_in
##############################

test_that("subvec_in works correctly", {
  expect_equal(humind:::subvec_in(c(1, 2, 3), c(2, 3)), c(2, 3))
})

test_that("subvec_not_in works correctly", {
  expect_equal(humind:::subvec_not_in(c(1, 2, 3), c(2, 3)), 1)
})

################################
### if_not_in_stop
################################

test_that("if_not_in_stop handles missing columns correctly", {
  expect_error(
    humind:::if_not_in_stop(df, c("col1", "col6"), "df"),
    class = "error"
  )
})

test_that("if_not_in_stop works with all columns present", {
  expect_silent(humind:::if_not_in_stop(df, c("col1", "col2"), "df"))
})

test_that("if_not_in_stop works with custom argument", {
  expect_error(
    humind:::if_not_in_stop(df, c("col1", "col6"), "df", arg = "test_arg"),
    class = "error"
  )
})

test_that("if_not_in_stop stops when input is not a data.frame", {
  expect_error(
    humind:::if_not_in_stop(
      "not_a_df",
      c("col1", "col6"),
      "df",
      df_name = "test_arg"
    ),
    class = "error",
    regexp = "test_arg must be a data.frame"
  )
})


########################
### is_df
########################

test_that("is_df handles non-data.frame input", {
  expect_error(
    humind:::is_df("not_a_df", "test_arg"),
    class = "error",
    regexp = "Input test_arg must be a data.frame."
  )
})

test_that("is_df works with data.frame input", {
  expect_true(humind:::is_df(df, "test_arg"))
  expect_silent(humind:::is_df(df, "test_arg"))
})
