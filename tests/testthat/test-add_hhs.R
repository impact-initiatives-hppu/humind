# The recoding rule is the same regardless of which of the 3 pairs it's
# applied to (R/add_hhs.R doesn't special-case any of them), so this table
# is the single source of truth for it - written once, checked once per
# pair below.

hhs_pair_cases <- tibble::tribble(
  ~case                                               , ~yn           , ~freq         , ~expected_yn_recoded , ~expected_freq_recoded , ~expected_comp ,
  "answered rarely"                                   , "yes"         , "rarely"      ,                    1 ,                      1 ,              1 ,
  "answered sometimes"                                , "yes"         , "sometimes"   ,                    1 ,                      1 ,              1 ,
  "answered often"                                    , "yes"         , "often"       ,                    1 ,                      2 ,              2 ,
  "\"no\": freq not relevant, legitimate skip"        , "no"          , NA_character_ ,                    0 ,                      0 ,              0 ,
  "yn missing: whole module skipped, legitimate skip" , NA_character_ , NA_character_ , NA_real_             , NA_real_               , NA_real_       ,
  "\"yes\" but freq missing: issue #753"              , "yes"         , NA_character_ ,                    1 , NA_real_               , NA_real_       ,
)

# The other two pairs are held "no" + NA (comp = 0) so the pair under test
# can be checked in isolation from the other two.
neutral_hhs_row <- list(
  fsl_hhs_nofoodhh = "no",
  fsl_hhs_nofoodhh_freq = NA_character_,
  fsl_hhs_sleephungry = "no",
  fsl_hhs_sleephungry_freq = NA_character_,
  fsl_hhs_alldaynight = "no",
  fsl_hhs_alldaynight_freq = NA_character_
)

# Applies hhs_pair_cases to one specific yn/_freq pair (identified by its
# column names) and checks its recoded columns and component score.
expect_hhs_pair_matches_cases <- function(yn_col, freq_col, comp_col) {
  other_cols <- neutral_hhs_row[
    !names(neutral_hhs_row) %in% c(yn_col, freq_col)
  ]
  df <- dplyr::tibble(
    !!yn_col := hhs_pair_cases$yn,
    !!freq_col := hhs_pair_cases$freq
  )
  for (col in names(other_cols)) {
    df[[col]] <- other_cols[[col]]
  }
  result <- add_hhs(df)

  expect_equal(
    result[[paste0(yn_col, "_recoded")]],
    hhs_pair_cases$expected_yn_recoded
  )
  expect_equal(
    result[[paste0(freq_col, "_recoded")]],
    hhs_pair_cases$expected_freq_recoded
  )
  expect_equal(result[[comp_col]], hhs_pair_cases$expected_comp)
}

test_that("fsl_hhs_nofoodhh / fsl_hhs_nofoodhh_freq recode as expected for every case", {
  expect_hhs_pair_matches_cases(
    "fsl_hhs_nofoodhh",
    "fsl_hhs_nofoodhh_freq",
    "fsl_hhs_comp1"
  )
})

test_that("fsl_hhs_sleephungry / fsl_hhs_sleephungry_freq recode as expected for every case", {
  expect_hhs_pair_matches_cases(
    "fsl_hhs_sleephungry",
    "fsl_hhs_sleephungry_freq",
    "fsl_hhs_comp2"
  )
})

test_that("fsl_hhs_alldaynight / fsl_hhs_alldaynight_freq recode as expected for every case", {
  expect_hhs_pair_matches_cases(
    "fsl_hhs_alldaynight",
    "fsl_hhs_alldaynight_freq",
    "fsl_hhs_comp3"
  )
})


score_cases <- tibble::tribble(
  ~fsl_hhs_nofoodhh , ~fsl_hhs_nofoodhh_freq , ~fsl_hhs_sleephungry , ~fsl_hhs_sleephungry_freq , ~fsl_hhs_alldaynight , ~fsl_hhs_alldaynight_freq , ~expected_score , ~expected_cat_ipc , ~expected_cat  ,
  "no"              , NA_character_          , "no"                 , NA_character_             , "no"                 , NA_character_             ,               0 , "None"            , "Little to No" ,
  "yes"             , "rarely"               , "no"                 , NA_character_             , "no"                 , NA_character_             ,               1 , "Little"          , "Little to No" ,
  "yes"             , "often"                , "no"                 , NA_character_             , "no"                 , NA_character_             ,               2 , "Moderate"        , "Moderate"     ,
  "yes"             , "often"                , "yes"                , "rarely"                  , "no"                 , NA_character_             ,               3 , "Moderate"        , "Moderate"     ,
  "yes"             , "often"                , "yes"                , "often"                   , "no"                 , NA_character_             ,               4 , "Severe"          , "Severe"       ,
  "yes"             , "often"                , "yes"                , "often"                   , "yes"                , "rarely"                  ,               5 , "Very Severe"     , "Severe"       ,
  "yes"             , "often"                , "yes"                , "often"                   , "yes"                , "often"                   ,               6 , "Very Severe"     , "Severe"       ,
)

test_that("fsl_hhs_score and categories are correct across the full 0-6 range", {
  df <- dplyr::select(score_cases, dplyr::starts_with("fsl_hhs"))
  result <- add_hhs(df)

  expect_equal(result$fsl_hhs_score, score_cases$expected_score)
  expect_equal(result$fsl_hhs_cat_ipc, score_cases$expected_cat_ipc)
  expect_equal(result$fsl_hhs_cat, score_cases$expected_cat)
})

# Property based tests

exhaustive_hhs_df <- generate_hhs_df()
exhaustive_hhs_result <- add_hhs(exhaustive_hhs_df)

test_that("regression: fsl_hhs_score is NA iff at least one component is NA", {
  comp_cols <- c("fsl_hhs_comp1", "fsl_hhs_comp2", "fsl_hhs_comp3")
  any_na_comp <- apply(exhaustive_hhs_result[comp_cols], 1, function(x) {
    any(is.na(x))
  })
  expect_identical(is.na(exhaustive_hhs_result$fsl_hhs_score), any_na_comp)
})

test_that("regression: fsl_hhs_score is in 0-6 for all non-NA rows", {
  score <- exhaustive_hhs_result$fsl_hhs_score
  expect_true(all(score[!is.na(score)] %in% 0:6))
})

test_that("regression: fsl_hhs_cat and fsl_hhs_cat_ipc are NA iff fsl_hhs_score is NA", {
  score <- exhaustive_hhs_result$fsl_hhs_score
  expect_identical(is.na(exhaustive_hhs_result$fsl_hhs_cat), is.na(score))
  expect_identical(is.na(exhaustive_hhs_result$fsl_hhs_cat_ipc), is.na(score))
})

test_that("fsl_hhs_score is NA (not deflated to 0) when a freq answer is genuinely missing", {
  # This case should not happen on a well coded / cleaned data set

  df <- dplyr::tibble(
    fsl_hhs_nofoodhh = "yes",
    fsl_hhs_nofoodhh_freq = NA_character_,
    fsl_hhs_sleephungry = "no",
    fsl_hhs_sleephungry_freq = NA_character_,
    fsl_hhs_alldaynight = "no",
    fsl_hhs_alldaynight_freq = NA_character_
  )
  result <- add_hhs(df)

  expect_true(is.na(result$fsl_hhs_comp1))
  expect_true(is.na(result$fsl_hhs_score))
  expect_true(is.na(result$fsl_hhs_cat))
  expect_true(is.na(result$fsl_hhs_cat_ipc))
})
