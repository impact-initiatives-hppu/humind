make_hwise_df <- function() {
  dplyr::tibble(
    wash_hwise_drink = c("never", "sometimes", "always"),
    wash_hwise_hands = c("rarely", "often", "always"),
    wash_hwise_plans = c("sometimes", "dnk", "always"),
    wash_hwise_worry = c("always", "pnta", "never")
  )
}

test_that("add_hwise runs without error on valid inputs", {
  expect_no_error(add_hwise(make_hwise_df()))
})

test_that("add_hwise errors when required columns are missing", {
  df <- make_hwise_df()
  expect_error(add_hwise(dplyr::select(df, -wash_hwise_drink)))
  expect_error(add_hwise(dplyr::select(df, -wash_hwise_hands)))
  expect_error(add_hwise(dplyr::select(df, -wash_hwise_plans)))
  expect_error(add_hwise(dplyr::select(df, -wash_hwise_worry)))
})

test_that("add_hwise errors when hwise_* params are non-scalar", {
  df <- make_hwise_df()
  expect_error(add_hwise(df, hwise_never = c("never", "jamais")))
  expect_error(add_hwise(df, hwise_dnk = c("dnk", "nsp")))
})

test_that("add_hwise errors when hwise_* params are non-character", {
  df <- make_hwise_df()
  expect_error(add_hwise(df, hwise_never = 1L))
  expect_error(add_hwise(df, hwise_rarely = 2.5))
  expect_error(add_hwise(df, hwise_dnk = TRUE))
})

test_that("add_hwise hwise4_score is the row sum of recoded columns", {
  df <- dplyr::tibble(
    wash_hwise_drink = c("never", "rarely", "sometimes", "often", "always"),
    wash_hwise_hands = c("never", "rarely", "sometimes", "often", "always"),
    wash_hwise_plans = c("never", "rarely", "sometimes", "often", "always"),
    wash_hwise_worry = c("never", "rarely", "sometimes", "often", "always")
  )
  expect_equal(add_hwise(df)$hwise4_score, c(0, 4, 8, 12, 12))
})

test_that("add_hwise comp_wash_score_water_quantity maps score to correct severity", {
  df <- dplyr::tibble(
    wash_hwise_drink = c(
      "never",
      "rarely",
      "rarely",
      "sometimes",
      "sometimes",
      "sometimes",
      "often",
      "often",
      "often",
      "often"
    ),
    wash_hwise_hands = c(
      "never",
      "rarely",
      "rarely",
      "sometimes",
      "sometimes",
      "sometimes",
      "often",
      "often",
      "often",
      "often"
    ),
    wash_hwise_plans = c(
      "never",
      "rarely",
      "rarely",
      "rarely",
      "sometimes",
      "sometimes",
      "sometimes",
      "sometimes",
      "often",
      "often"
    ),
    wash_hwise_worry = c(
      "never",
      "never",
      "rarely",
      "rarely",
      "rarely",
      "sometimes",
      "rarely",
      "sometimes",
      "sometimes",
      "often"
    )
  )
  result <- add_hwise(df)
  expect_equal(result$hwise4_score, c(0, 3, 4, 6, 7, 8, 9, 10, 11, 12))
  expect_equal(
    result$comp_wash_score_water_quantity,
    c(1, 1, 2, 2, 3, 3, 4, 4, 5, 5)
  )
})

test_that("add_hwise hwise4_score is NA when dnk/pnta present and na.rm = FALSE", {
  df <- dplyr::tibble(
    wash_hwise_drink = c("never", "never"),
    wash_hwise_hands = c("never", "never"),
    wash_hwise_plans = c("never", "never"),
    wash_hwise_worry = c("dnk", "pnta")
  )

  result <- add_hwise(df, na.rm = FALSE)

  expect_true(all(is.na(result$hwise4_score)))
  expect_true(all(is.na(result$comp_wash_score_water_quantity)))
})

test_that("add_hwise hwise4_score treats dnk/pnta as 0 when na.rm = TRUE", {
  df <- dplyr::tibble(
    wash_hwise_drink = c("rarely"),
    wash_hwise_hands = c("rarely"),
    wash_hwise_plans = c("rarely"),
    wash_hwise_worry = c("dnk")
  )

  result <- add_hwise(df, na.rm = TRUE)

  expect_equal(result$hwise4_score, 3)
  expect_equal(result$comp_wash_score_water_quantity, 1)
})

exhaustive_hwise_df <- generate_hwise_df()
exhaustive_hwise_result <- add_hwise(exhaustive_hwise_df)

test_that("property: hwise4_score is in 0-12 for all non-NA rows", {
  score <- exhaustive_hwise_result$hwise4_score
  expect_true(all(score[!is.na(score)] %in% 0:12))
})

test_that("property: comp_wash_score_water_quantity is in 1-5 for all non-NA rows", {
  sev <- exhaustive_hwise_result$comp_wash_score_water_quantity
  expect_true(all(sev[!is.na(sev)] %in% 1:5))
})

test_that("property: hwise4_score is NA iff comp_wash_score_water_quantity is NA", {
  score <- exhaustive_hwise_result$hwise4_score
  sev <- exhaustive_hwise_result$comp_wash_score_water_quantity
  expect_identical(is.na(score), is.na(sev))
})

test_that("property: hwise4_score is NA iff at least one column is dnk/pnta (na.rm = FALSE)", {
  na_codes <- c("dnk", "pnta")
  has_na_code <- apply(exhaustive_hwise_df, 1, function(row) {
    any(row %in% na_codes)
  })
  score <- exhaustive_hwise_result$hwise4_score
  expect_identical(is.na(score), has_na_code)
})

test_that("property: comp_wash_score_water_quantity is monotonically non-decreasing with hwise4_score", {
  result <- exhaustive_hwise_result[
    !is.na(exhaustive_hwise_result$hwise4_score),
  ]
  result <- result[order(result$hwise4_score), ]
  expect_true(all(diff(result$comp_wash_score_water_quantity) >= 0))
})

test_that("property: often and always are interchangeable", {
  df_always <- dplyr::mutate(
    exhaustive_hwise_df,
    dplyr::across(
      dplyr::everything(),
      ~ dplyr::if_else(.x == "often", "always", .x)
    )
  )
  composite_cols <- c("hwise4_score", "comp_wash_score_water_quantity")
  expect_identical(
    add_hwise(exhaustive_hwise_df)[composite_cols],
    add_hwise(df_always)[composite_cols]
  )
})

test_that("property: no NAs in score or severity when na.rm = TRUE", {
  result <- add_hwise(exhaustive_hwise_df, na.rm = TRUE)
  expect_false(anyNA(result$hwise4_score))
  expect_false(anyNA(result$comp_wash_score_water_quantity))
})

test_that("add_hwise recodes all hwise columns to correct numeric scores in _score columns", {
  df <- dplyr::tibble(
    wash_hwise_drink = c(
      "never",
      "rarely",
      "sometimes",
      "often",
      "always",
      "dnk",
      "pnta"
    ),
    wash_hwise_hands = c(
      "never",
      "rarely",
      "sometimes",
      "often",
      "always",
      "dnk",
      "pnta"
    ),
    wash_hwise_plans = c(
      "never",
      "rarely",
      "sometimes",
      "often",
      "always",
      "dnk",
      "pnta"
    ),
    wash_hwise_worry = c(
      "never",
      "rarely",
      "sometimes",
      "often",
      "always",
      "dnk",
      "pnta"
    )
  )

  expected <- c(0, 1, 2, 3, 3, NA, NA)

  result <- add_hwise(df, .keep_recoded = TRUE)

  expect_equal(result$wash_hwise_drink_score, expected)
  expect_equal(result$wash_hwise_hands_score, expected)
  expect_equal(result$wash_hwise_plans_score, expected)
  expect_equal(result$wash_hwise_worry_score, expected)

  # raw columns are untouched
  expect_equal(result$wash_hwise_drink, df$wash_hwise_drink)
  expect_equal(result$wash_hwise_hands, df$wash_hwise_hands)
  expect_equal(result$wash_hwise_plans, df$wash_hwise_plans)
  expect_equal(result$wash_hwise_worry, df$wash_hwise_worry)
})

test_that("add_hwise preserves raw HWISE columns and omits _score columns by default", {
  df <- dplyr::tibble(
    wash_hwise_drink = c("never", "rarely", "sometimes"),
    wash_hwise_hands = c("never", "rarely", "sometimes"),
    wash_hwise_plans = c("never", "rarely", "sometimes"),
    wash_hwise_worry = c("never", "rarely", "sometimes")
  )

  result <- add_hwise(df)

  expect_equal(result$wash_hwise_drink, df$wash_hwise_drink)
  expect_equal(result$wash_hwise_hands, df$wash_hwise_hands)
  expect_equal(result$wash_hwise_plans, df$wash_hwise_plans)
  expect_equal(result$wash_hwise_worry, df$wash_hwise_worry)
  expect_false(any(
    c(
      "wash_hwise_drink_score",
      "wash_hwise_hands_score",
      "wash_hwise_plans_score",
      "wash_hwise_worry_score"
    ) %in%
      names(result)
  ))
})

test_that(".keep_recoded controls whether _score columns appear", {
  df <- dplyr::tibble(
    wash_hwise_drink = c("never", "rarely"),
    wash_hwise_hands = c("never", "rarely"),
    wash_hwise_plans = c("never", "rarely"),
    wash_hwise_worry = c("never", "rarely")
  )

  expected_score_cols <- paste0(
    c(
      "wash_hwise_drink",
      "wash_hwise_hands",
      "wash_hwise_plans",
      "wash_hwise_worry"
    ),
    "_score"
  )

  res_def <- add_hwise(df)
  expect_false(any(expected_score_cols %in% names(res_def)))

  res_keep <- add_hwise(df, .keep_recoded = TRUE)
  expect_true(all(expected_score_cols %in% names(res_keep)))
})

test_that("add_hwise recodes correctly when non-default hwise_* params are supplied", {
  df <- dplyr::tibble(
    wash_hwise_drink = c(
      "jamais",
      "rarement",
      "parfois",
      "souvent",
      "toujours",
      "nsp",
      "prnr"
    ),
    wash_hwise_hands = c(
      "jamais",
      "rarement",
      "parfois",
      "souvent",
      "toujours",
      "nsp",
      "prnr"
    ),
    wash_hwise_plans = c(
      "jamais",
      "rarement",
      "parfois",
      "souvent",
      "toujours",
      "nsp",
      "prnr"
    ),
    wash_hwise_worry = c(
      "jamais",
      "rarement",
      "parfois",
      "souvent",
      "toujours",
      "nsp",
      "prnr"
    )
  )

  result <- add_hwise(
    df,
    hwise_never = "jamais",
    hwise_rarely = "rarement",
    hwise_sometimes = "parfois",
    hwise_often = "souvent",
    hwise_always = "toujours",
    hwise_dnk = "nsp",
    hwise_pnta = "prnr",
    .keep_recoded = TRUE
  )

  expected_recode <- c(0, 1, 2, 3, 3, NA_real_, NA_real_)
  expect_equal(result$wash_hwise_drink_score, expected_recode)
  expect_equal(result$wash_hwise_worry_score, expected_recode)
  expect_equal(result$wash_hwise_drink, df$wash_hwise_drink)
  expect_equal(result$wash_hwise_worry, df$wash_hwise_worry)
  expect_equal(result$hwise4_score, c(0, 4, 8, 12, 12, NA, NA))
})

test_that("add_hwise errors when data contains values outside the hwise_* response set", {
  df <- dplyr::tibble(
    wash_hwise_drink = c("never", "TYPO"),
    wash_hwise_hands = c("never", "rarely"),
    wash_hwise_plans = c("never", "rarely"),
    wash_hwise_worry = c("never", "rarely")
  )
  expect_error(add_hwise(df), class = "error")
})
