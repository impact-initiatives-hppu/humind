# Shared minimal valid row for add_cari
make_base_df <- function(
  fsl_fcs_cat = "Acceptable",
  fsl_rcsi_score = 0,
  cm_expenditure_frequent_food_prop = 0.4,
  fsl_lcsi_cat = "None"
) {
  dplyr::tibble(
    fsl_fcs_cat = fsl_fcs_cat,
    fsl_rcsi_score = fsl_rcsi_score,
    cm_expenditure_frequent_food_prop = cm_expenditure_frequent_food_prop,
    fsl_lcsi_cat = fsl_lcsi_cat
  )
}

# ---- add_cari: fsl_cari_current_status_score ----

test_that("add_cari returns fsl_cari_current_status_score column", {
  result <- add_cari(make_base_df())
  expect_true("fsl_cari_current_status_score" %in% colnames(result))
})

test_that("fsl_cari_current_status_score is integer type", {
  result <- add_cari(make_base_df())
  expect_type(result$fsl_cari_current_status_score, "integer")
})

test_that("Acceptable FCS + rCSI below 4 then score 1", {
  df <- make_base_df(fsl_fcs_cat = rep("Acceptable", 4), fsl_rcsi_score = c(0, 1, 2, 3))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_current_status_score, rep(1L, 4))
})

test_that("Acceptable FCS + rCSI at or above 4 then score 2", {
  df <- make_base_df(fsl_fcs_cat = rep("Acceptable", 3), fsl_rcsi_score = c(4, 10, 18))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_current_status_score, rep(2L, 3))
})

test_that("rCSI cutoff at 4: rCSI 3 then score 1, rCSI 4 then score 2", {
  df <- make_base_df(fsl_fcs_cat = c("Acceptable", "Acceptable"), fsl_rcsi_score = c(3, 4))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_current_status_score, c(1L, 2L))
})

test_that("Borderline FCS then score 3 regardless of rCSI", {
  df <- make_base_df(fsl_fcs_cat = rep("Borderline", 3), fsl_rcsi_score = c(0, 4, 20))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_current_status_score, rep(3L, 3))
})

test_that("Poor FCS then score 4 regardless of rCSI", {
  df <- make_base_df(fsl_fcs_cat = rep("Poor", 3), fsl_rcsi_score = c(0, 4, 20))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_current_status_score, rep(4L, 3))
})

test_that("NA fsl_fcs_cat then NA current status score", {
  result <- add_cari(make_base_df(fsl_fcs_cat = NA_character_))
  expect_true(is.na(result$fsl_cari_current_status_score))
})

test_that("NA fsl_rcsi_score with Acceptable FCS then NA current status score", {
  result <- add_cari(make_base_df(fsl_rcsi_score = NA_real_))
  expect_true(is.na(result$fsl_cari_current_status_score))
})

test_that("NA fsl_rcsi_score with Borderline/Poor FCS then scores 3/4", {
  df <- make_base_df(
    fsl_fcs_cat = c("Borderline", "Poor"),
    fsl_rcsi_score = c(NA_real_, NA_real_)
  )
  result <- add_cari(df)
  expect_equal(result$fsl_cari_current_status_score, c(3L, 4L))
})

test_that("add_cari errors on rCSI score out of 0-56 range", {
  expect_error(add_cari(make_base_df(fsl_rcsi_score = 57)))
})

test_that("add_cari errors on missing fcs_cat column", {
  expect_error(add_cari(dplyr::tibble(
    fsl_rcsi_score = 0, cm_expenditure_frequent_food_prop = 0.4, fsl_lcsi_cat = "None"
  )))
})

test_that("add_cari errors on missing rcsi_score column", {
  expect_error(add_cari(dplyr::tibble(
    fsl_fcs_cat = "Acceptable", cm_expenditure_frequent_food_prop = 0.4, fsl_lcsi_cat = "None"
  )))
})

test_that("add_cari errors on non-numeric rcsi_score column", {
  expect_error(add_cari(make_base_df(fsl_rcsi_score = "high")))
})

test_that("add_cari errors on invalid fcs_cat values", {
  expect_error(add_cari(make_base_df(fsl_fcs_cat = "Unknown")))
})

# ---- add_cari: fsl_cari_fes_prop and fsl_cari_fes_score ----

test_that("add_cari returns fsl_cari_fes_prop and fsl_cari_fes_score columns", {
  result <- add_cari(make_base_df())
  expect_true("fsl_cari_fes_prop" %in% colnames(result))
  expect_true("fsl_cari_fes_score" %in% colnames(result))
})

test_that("fsl_cari_fes_prop equals cm_expenditure_frequent_food_prop", {
  result <- add_cari(make_base_df(cm_expenditure_frequent_food_prop = 0.55))
  expect_equal(result$fsl_cari_fes_prop, 0.55)
})

test_that("fsl_cari_fes_prop is NA when cm_expenditure_frequent_food_prop is NA", {
  result <- add_cari(make_base_df(cm_expenditure_frequent_food_prop = NA_real_))
  expect_true(is.na(result$fsl_cari_fes_prop))
})

test_that("fsl_cari_fes_score is 1 when FES < 0.50", {
  result <- add_cari(make_base_df(cm_expenditure_frequent_food_prop = 0.49))
  expect_equal(result$fsl_cari_fes_score, 1L)
})

test_that("fsl_cari_fes_score is 2 when FES in [0.50, 0.65)", {
  df <- make_base_df(cm_expenditure_frequent_food_prop = c(0.50, 0.64))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_fes_score, c(2L, 2L))
})

test_that("fsl_cari_fes_score is 3 when FES in [0.65, 0.75)", {
  df <- make_base_df(cm_expenditure_frequent_food_prop = c(0.65, 0.74))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_fes_score, c(3L, 3L))
})

test_that("fsl_cari_fes_score is 4 when FES >= 0.75", {
  df <- make_base_df(cm_expenditure_frequent_food_prop = c(0.75, 1.0))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_fes_score, c(4L, 4L))
})

test_that("fsl_cari_fes_score cutoffs: 0.499→1, 0.50→2, 0.649→2, 0.65→3, 0.749→3, 0.75→4", {
  df <- make_base_df(cm_expenditure_frequent_food_prop = c(0.499, 0.50, 0.649, 0.65, 0.749, 0.75))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_fes_score, c(1L, 2L, 2L, 3L, 3L, 4L))
})

test_that("fsl_cari_fes_score is NA when FES prop is NA", {
  result <- add_cari(make_base_df(cm_expenditure_frequent_food_prop = NA_real_))
  expect_true(is.na(result$fsl_cari_fes_score))
})

test_that("fsl_cari_fes_score is integer type", {
  result <- add_cari(make_base_df())
  expect_type(result$fsl_cari_fes_score, "integer")
})

test_that("add_cari errors on missing food prop column", {
  expect_error(add_cari(dplyr::tibble(
    fsl_fcs_cat = "Acceptable", fsl_rcsi_score = 0, fsl_lcsi_cat = "None"
  )))
})

test_that("add_cari errors on non-numeric food prop column", {
  expect_error(add_cari(make_base_df(cm_expenditure_frequent_food_prop = "high")))
})

test_that("add_cari errors on food prop outside [0, 1]", {
  expect_error(add_cari(make_base_df(cm_expenditure_frequent_food_prop = 1.5)))
})

# ---- add_cari: fsl_cari_lcsi_score ----

test_that("add_cari returns fsl_cari_lcsi_score column", {
  result <- add_cari(make_base_df())
  expect_true("fsl_cari_lcsi_score" %in% colnames(result))
})

test_that("fsl_cari_lcsi_score is integer type", {
  result <- add_cari(make_base_df())
  expect_type(result$fsl_cari_lcsi_score, "integer")
})

test_that("'None' LCSI then score 1", {
  result <- add_cari(make_base_df(fsl_lcsi_cat = "None"))
  expect_equal(result$fsl_cari_lcsi_score, 1L)
})

test_that("'Stress' LCSI then score 2", {
  result <- add_cari(make_base_df(fsl_lcsi_cat = "Stress"))
  expect_equal(result$fsl_cari_lcsi_score, 2L)
})

test_that("'Crisis' LCSI then score 3", {
  result <- add_cari(make_base_df(fsl_lcsi_cat = "Crisis"))
  expect_equal(result$fsl_cari_lcsi_score, 3L)
})

test_that("'Emergency' LCSI then score 4", {
  result <- add_cari(make_base_df(fsl_lcsi_cat = "Emergency"))
  expect_equal(result$fsl_cari_lcsi_score, 4L)
})

test_that("all four LCSI levels score correctly", {
  df <- make_base_df(fsl_lcsi_cat = c("None", "Stress", "Crisis", "Emergency"))
  result <- add_cari(df)
  expect_equal(result$fsl_cari_lcsi_score, c(1L, 2L, 3L, 4L))
})

test_that("NA LCSI then NA score", {
  result <- add_cari(make_base_df(fsl_lcsi_cat = NA_character_))
  expect_true(is.na(result$fsl_cari_lcsi_score))
})

test_that("add_cari errors on missing lcsi column", {
  expect_error(add_cari(dplyr::tibble(
    fsl_fcs_cat = "Acceptable", fsl_rcsi_score = 0,
    cm_expenditure_frequent_food_prop = 0.4
  )))
})

test_that("add_cari errors on invalid lcsi values", {
  expect_error(add_cari(make_base_df(fsl_lcsi_cat = "Unknown")))
})

# ---- add_cari: fsl_cari_coping_capacity_score and fsl_cari_score ----

test_that("add_cari returns fsl_cari_coping_capacity_score and fsl_cari_score columns", {
  result <- add_cari(make_base_df())
  expect_true("fsl_cari_coping_capacity_score" %in% colnames(result))
  expect_true("fsl_cari_score" %in% colnames(result))
})

test_that("fsl_cari_coping_capacity_score is mean of FES and LCSI scores", {
  # FES score 2 (prop=0.55), LCSI score 3 (Crisis) → CC = (2+3)/2 = 2.5
  result <- add_cari(make_base_df(
    cm_expenditure_frequent_food_prop = 0.55,
    fsl_lcsi_cat = "Crisis"
  ))
  expect_equal(result$fsl_cari_coping_capacity_score, 2.5)
})

test_that("fsl_cari_score is (CS + CC) / 2 — scenario CS=4, CC=2.5 → 3.25", {
  # CS=4 (Poor FCS), FES score 3, LCSI score 2 → CC=2.5, score=(4+2.5)/2=3.25
  result <- add_cari(make_base_df(
    fsl_fcs_cat = "Poor",
    fsl_rcsi_score = 0,
    cm_expenditure_frequent_food_prop = 0.67, # FES score 3
    fsl_lcsi_cat = "Stress"                   # LCSI score 2
  ))
  expect_equal(result$fsl_cari_score, 3.25)
})

test_that("fsl_cari_score — scenario CS=4, CC=3 → 3.5", {
  # CS=4 (Poor FCS), FES score 3, LCSI score 3 → CC=3, score=(4+3)/2=3.5
  result <- add_cari(make_base_df(
    fsl_fcs_cat = "Poor",
    fsl_rcsi_score = 0,
    cm_expenditure_frequent_food_prop = 0.67, # FES score 3
    fsl_lcsi_cat = "Crisis"                   # LCSI score 3
  ))
  expect_equal(result$fsl_cari_score, 3.5)
})

test_that("fsl_cari_score — CS=1, CC=2 → 1.5", {
  # CS=1 (Acceptable FCS + rCSI<4), FES score 2, LCSI score 2 → CC=2, score=1.5
  result <- add_cari(make_base_df(
    fsl_fcs_cat = "Acceptable",
    fsl_rcsi_score = 0,
    cm_expenditure_frequent_food_prop = 0.55, # FES score 2
    fsl_lcsi_cat = "Stress"                   # LCSI score 2
  ))
  expect_equal(result$fsl_cari_score, 1.5)
})

test_that("fsl_cari_score is NA when CS is NA", {
  result <- add_cari(make_base_df(fsl_fcs_cat = NA_character_))
  expect_true(is.na(result$fsl_cari_score))
})

test_that("fsl_cari_score is NA when CC is NA", {
  result <- add_cari(make_base_df(fsl_lcsi_cat = NA_character_))
  expect_true(is.na(result$fsl_cari_score))
})

test_that("fsl_cari_score is numeric type", {
  result <- add_cari(make_base_df())
  expect_type(result$fsl_cari_score, "double")
})

test_that("fsl_cari_score is in range 1-4 for all valid inputs", {
  df <- make_base_df(
    fsl_fcs_cat = c("Acceptable", "Acceptable", "Borderline", "Poor"),
    fsl_rcsi_score = c(0, 4, 0, 0),
    cm_expenditure_frequent_food_prop = c(0.3, 0.6, 0.7, 0.8),
    fsl_lcsi_cat = c("None", "Stress", "Crisis", "Emergency")
  )
  result <- add_cari(df)
  expect_true(all(result$fsl_cari_score >= 1 & result$fsl_cari_score <= 4))
})

# ---- add_cari: fsl_cari_cat ----

test_that("add_cari returns fsl_cari_cat column", {
  result <- add_cari(make_base_df())
  expect_true("fsl_cari_cat" %in% colnames(result))
})

test_that("fsl_cari_cat is integer type", {
  result <- add_cari(make_base_df())
  expect_type(result$fsl_cari_cat, "integer")
})

test_that("fsl_cari_cat is 1 when score < 1.5", {
  # CS=1, CC=1 → score=1.0 → cat=1
  result <- add_cari(make_base_df(
    cm_expenditure_frequent_food_prop = 0.3,
    fsl_lcsi_cat = "None"
  ))
  expect_equal(result$fsl_cari_cat, 1L)
})

test_that("fsl_cari_cat is 2 when score in [1.5, 2.5)", {
  # CS=1, CC=2 → score=1.5 → cat=2
  result <- add_cari(make_base_df(
    cm_expenditure_frequent_food_prop = 0.55,
    fsl_lcsi_cat = "Stress"
  ))
  expect_equal(result$fsl_cari_cat, 2L)
})

test_that("fsl_cari_cat is 3 when score in [2.5, 3.5)", {
  # CS=4, CC=1 → score=2.5 → cat=3
  result <- add_cari(make_base_df(
    fsl_fcs_cat = "Poor", fsl_rcsi_score = 0,
    cm_expenditure_frequent_food_prop = 0.3,
    fsl_lcsi_cat = "None"
  ))
  expect_equal(result$fsl_cari_cat, 3L)
})

test_that("fsl_cari_cat is 4 when score >= 3.5", {
  # CS=4, CC=3 → score=3.5 → cat=4
  result <- add_cari(make_base_df(
    fsl_fcs_cat = "Poor", fsl_rcsi_score = 0,
    cm_expenditure_frequent_food_prop = 0.67,
    fsl_lcsi_cat = "Crisis"
  ))
  expect_equal(result$fsl_cari_cat, 4L)
})

test_that("all four fsl_cari_cat values are produced across representative inputs", {
  df <- dplyr::tibble(
    fsl_fcs_cat    = c("Acceptable", "Acceptable", "Poor", "Poor"),
    fsl_rcsi_score = c(0, 0, 0, 0),
    cm_expenditure_frequent_food_prop = c(0.3, 0.55, 0.3, 0.67),
    fsl_lcsi_cat   = c("None", "Stress", "None", "Crisis")
  )
  result <- add_cari(df)
  expect_equal(result$fsl_cari_cat, c(1L, 2L, 3L, 4L))
})

test_that("fsl_cari_cat is NA when fsl_cari_score is NA", {
  result <- add_cari(make_base_df(fsl_lcsi_cat = NA_character_))
  expect_true(is.na(result$fsl_cari_cat))
})
