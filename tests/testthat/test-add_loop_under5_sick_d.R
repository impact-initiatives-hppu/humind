test_that("add_loop_under5_sick_d creates the three expected output columns", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "yes",
    `nut_ind_under5_sick_symptoms/cough` = 1,
    `nut_ind_under5_sick_symptoms/diarrhoea` = 0
  )
  result <- add_loop_under5_sick_d(loop)
  expect_true("nut_ind_under5_sick_yes_d" %in% colnames(result))
  expect_true("nut_ind_under5_sick_yes_respiratory_d" %in% colnames(result))
  expect_true("nut_ind_under5_sick_yes_watery_d" %in% colnames(result))
})

test_that("add_loop_under5_sick_d: yn is  'no', then all three dummies are 0", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "no",
    `nut_ind_under5_sick_symptoms/cough` = NA_real_,
    `nut_ind_under5_sick_symptoms/diarrhoea` = NA_real_
  )
  result <- add_loop_under5_sick_d(loop)
  expect_equal(result$nut_ind_under5_sick_yes_d, 0)
  expect_equal(result$nut_ind_under5_sick_yes_respiratory_d, 0)
  expect_equal(result$nut_ind_under5_sick_yes_watery_d, 0)
})

test_that("add_loop_under5_sick_d: yn is  'yes', both symptoms are 1, then all three dummies are 1", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "yes",
    `nut_ind_under5_sick_symptoms/cough` = 1,
    `nut_ind_under5_sick_symptoms/diarrhoea` = 1
  )
  result <- add_loop_under5_sick_d(loop)
  expect_equal(result$nut_ind_under5_sick_yes_d, 1)
  expect_equal(result$nut_ind_under5_sick_yes_respiratory_d, 1)
  expect_equal(result$nut_ind_under5_sick_yes_watery_d, 1)
})

test_that("add_loop_under5_sick_d: yn is  'yes', both symptoms are 0, then sick are 1, others are 0", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "yes",
    `nut_ind_under5_sick_symptoms/cough` = 0,
    `nut_ind_under5_sick_symptoms/diarrhoea` = 0
  )
  result <- add_loop_under5_sick_d(loop)
  expect_equal(result$nut_ind_under5_sick_yes_d, 1)
  expect_equal(result$nut_ind_under5_sick_yes_respiratory_d, 0)
  expect_equal(result$nut_ind_under5_sick_yes_watery_d, 0)
})

test_that("add_loop_under5_sick_d: yn is 'yes', respiratory are 1 but watery are 0", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "yes",
    `nut_ind_under5_sick_symptoms/cough` = 1,
    `nut_ind_under5_sick_symptoms/diarrhoea` = 0
  )
  result <- add_loop_under5_sick_d(loop)
  expect_equal(result$nut_ind_under5_sick_yes_d, 1)
  expect_equal(result$nut_ind_under5_sick_yes_respiratory_d, 1)
  expect_equal(result$nut_ind_under5_sick_yes_watery_d, 0)
})

test_that("add_loop_under5_sick_d: yn is 'dnk', then all three dummies are NA", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "dnk",
    `nut_ind_under5_sick_symptoms/cough` = NA_real_,
    `nut_ind_under5_sick_symptoms/diarrhoea` = NA_real_
  )
  result <- add_loop_under5_sick_d(loop)
  expect_true(is.na(result$nut_ind_under5_sick_yes_d))
  expect_true(is.na(result$nut_ind_under5_sick_yes_respiratory_d))
  expect_true(is.na(result$nut_ind_under5_sick_yes_watery_d))
})

test_that("add_loop_under5_sick_d: yn is 'pnta', then all three dummies are NA", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "pnta",
    `nut_ind_under5_sick_symptoms/cough` = NA_real_,
    `nut_ind_under5_sick_symptoms/diarrhoea` = NA_real_
  )
  result <- add_loop_under5_sick_d(loop)
  expect_true(is.na(result$nut_ind_under5_sick_yes_d))
  expect_true(is.na(result$nut_ind_under5_sick_yes_respiratory_d))
  expect_true(is.na(result$nut_ind_under5_sick_yes_watery_d))
})

test_that("add_loop_under5_sick_d: yn is NA (non-under-5 row), then all three dummies = NA", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = NA_character_,
    `nut_ind_under5_sick_symptoms/cough` = NA_real_,
    `nut_ind_under5_sick_symptoms/diarrhoea` = NA_real_
  )
  result <- add_loop_under5_sick_d(loop)
  expect_true(is.na(result$nut_ind_under5_sick_yes_d))
  expect_true(is.na(result$nut_ind_under5_sick_yes_respiratory_d))
  expect_true(is.na(result$nut_ind_under5_sick_yes_watery_d))
})

test_that("add_loop_under5_sick_d: yn is 'yes' but symptom is NA, then sick is 1, symptom dummy is NA", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "yes",
    `nut_ind_under5_sick_symptoms/cough` = NA_real_,
    `nut_ind_under5_sick_symptoms/diarrhoea` = 1
  )
  result <- add_loop_under5_sick_d(loop)
  expect_equal(result$nut_ind_under5_sick_yes_d, 1)
  expect_true(is.na(result$nut_ind_under5_sick_yes_respiratory_d))
  expect_equal(result$nut_ind_under5_sick_yes_watery_d, 1)
})

test_that("add_loop_under5_sick_d: error if ind_under5_sick_yn column is missing", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    `nut_ind_under5_sick_symptoms/cough` = 1,
    `nut_ind_under5_sick_symptoms/diarrhoea` = 0
  )
  expect_error(add_loop_under5_sick_d(loop))
})

test_that("add_loop_under5_sick_d: error if symptom binary column is missing", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "yes",
    `nut_ind_under5_sick_symptoms/cough` = 1
  )
  expect_error(add_loop_under5_sick_d(loop))
})

test_that("add_loop_under5_sick_d: warning if output column already exists", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "yes",
    `nut_ind_under5_sick_symptoms/cough` = 1,
    `nut_ind_under5_sick_symptoms/diarrhoea` = 0,
    nut_ind_under5_sick_yes_d = 99
  )
  expect_warning(add_loop_under5_sick_d(loop))
})

test_that("add_loop_under5_sick_d: sep parameter controls binary column name building", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yn = "yes",
    `nut_ind_under5_sick_symptoms.cough` = 1,
    `nut_ind_under5_sick_symptoms.diarrhoea` = 0
  )
  result <- add_loop_under5_sick_d(loop, sep = ".")
  expect_equal(result$nut_ind_under5_sick_yes_d, 1)
  expect_equal(result$nut_ind_under5_sick_yes_respiratory_d, 1)
  expect_equal(result$nut_ind_under5_sick_yes_watery_d, 0)
})

test_that("add_loop_under5_sick_d_to_main aggregates counts over eligible members", {
  loop <- dplyr::tibble(
    uuid = c("hh1", "hh1", "hh2", "hh2"),
    nut_ind_age_0_4 = c(1, 1, 1, 1),
    nut_ind_under5_sick_yes_d = c(1, 0, 1, 1),
    nut_ind_under5_sick_yes_respiratory_d = c(1, 0, 0, 1),
    nut_ind_under5_sick_yes_watery_d = c(0, 0, 1, 1)
  )
  main <- dplyr::tibble(uuid = c("hh1", "hh2"))
  result <- add_loop_under5_sick_d_to_main(main, loop)
  expect_equal(result$nut_ind_under5_sick_yes_d_n[result$uuid == "hh1"], 1)
  expect_equal(result$nut_ind_under5_sick_yes_d_n[result$uuid == "hh2"], 2)
  expect_equal(
    result$nut_ind_under5_sick_yes_respiratory_d_n[result$uuid == "hh1"],
    1
  )
  expect_equal(
    result$nut_ind_under5_sick_yes_respiratory_d_n[result$uuid == "hh2"],
    1
  )
  expect_equal(
    result$nut_ind_under5_sick_yes_watery_d_n[result$uuid == "hh1"],
    0
  )
  expect_equal(
    result$nut_ind_under5_sick_yes_watery_d_n[result$uuid == "hh2"],
    2
  )
})

test_that("add_loop_under5_sick_d_to_main: non-eligible members are ignored", {
  loop <- dplyr::tibble(
    uuid = c("hh1", "hh1"),
    nut_ind_age_0_4 = c(1, 0),
    nut_ind_under5_sick_yes_d = c(1, NA_real_),
    nut_ind_under5_sick_yes_respiratory_d = c(0, NA_real_),
    nut_ind_under5_sick_yes_watery_d = c(1, NA_real_)
  )
  result <- add_loop_under5_sick_d_to_main(dplyr::tibble(uuid = "hh1"), loop)
  expect_equal(result$nut_ind_under5_sick_yes_d_n, 1)
  expect_equal(result$nut_ind_under5_sick_yes_respiratory_d_n, 0)
  expect_equal(result$nut_ind_under5_sick_yes_watery_d_n, 1)
})

test_that("add_loop_under5_sick_d_to_main: blank when the household has no eligible member", {
  loop <- dplyr::tibble(
    uuid = c("hh1", "hh1"),
    nut_ind_age_0_4 = c(0, 0),
    nut_ind_under5_sick_yes_d = c(NA_real_, NA_real_),
    nut_ind_under5_sick_yes_respiratory_d = c(NA_real_, NA_real_),
    nut_ind_under5_sick_yes_watery_d = c(NA_real_, NA_real_)
  )
  result <- add_loop_under5_sick_d_to_main(dplyr::tibble(uuid = "hh1"), loop)
  expect_true(is.na(result$nut_ind_under5_sick_yes_d_n))
  expect_true(is.na(result$nut_ind_under5_sick_yes_respiratory_d_n))
  expect_true(is.na(result$nut_ind_under5_sick_yes_watery_d_n))
})

test_that("add_loop_under5_sick_d_to_main: blank when an eligible member has an unknown answer", {
  loop <- dplyr::tibble(
    uuid = c("hh1", "hh1"),
    nut_ind_age_0_4 = c(1, 1),
    nut_ind_under5_sick_yes_d = c(1, NA_real_),
    nut_ind_under5_sick_yes_respiratory_d = c(1, NA_real_),
    nut_ind_under5_sick_yes_watery_d = c(0, NA_real_)
  )
  result <- add_loop_under5_sick_d_to_main(dplyr::tibble(uuid = "hh1"), loop)
  expect_true(is.na(result$nut_ind_under5_sick_yes_d_n))
  expect_true(is.na(result$nut_ind_under5_sick_yes_respiratory_d_n))
  expect_true(is.na(result$nut_ind_under5_sick_yes_watery_d_n))
})

test_that("add_loop_under5_sick_d_to_main: an unknown symptom blanks only that type count", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_age_0_4 = 1,
    nut_ind_under5_sick_yes_d = 1,
    nut_ind_under5_sick_yes_respiratory_d = NA_real_,
    nut_ind_under5_sick_yes_watery_d = 0
  )
  result <- add_loop_under5_sick_d_to_main(dplyr::tibble(uuid = "hh1"), loop)
  expect_equal(result$nut_ind_under5_sick_yes_d_n, 1)
  expect_true(is.na(result$nut_ind_under5_sick_yes_respiratory_d_n))
  expect_equal(result$nut_ind_under5_sick_yes_watery_d_n, 0)
})

test_that("add_loop_under5_sick_d_to_main: main-only id is blank", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_age_0_4 = 1,
    nut_ind_under5_sick_yes_d = 1,
    nut_ind_under5_sick_yes_respiratory_d = 0,
    nut_ind_under5_sick_yes_watery_d = 0
  )
  main <- dplyr::tibble(uuid = c("hh1", "hh2"))
  result <- add_loop_under5_sick_d_to_main(main, loop)
  expect_equal(result$nut_ind_under5_sick_yes_d_n[result$uuid == "hh1"], 1)
  expect_true(is.na(result$nut_ind_under5_sick_yes_d_n[result$uuid == "hh2"]))
})

test_that("add_loop_under5_sick_d_to_main: error if dummy columns not in loop", {
  loop <- dplyr::tibble(uuid = "hh1", nut_ind_age_0_4 = 1)
  expect_error(add_loop_under5_sick_d_to_main(
    dplyr::tibble(uuid = "hh1"),
    loop
  ))
})

test_that("add_loop_under5_sick_d_to_main: error if eligibility column not in loop", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_under5_sick_yes_d = 1,
    nut_ind_under5_sick_yes_respiratory_d = 0,
    nut_ind_under5_sick_yes_watery_d = 0
  )
  expect_error(add_loop_under5_sick_d_to_main(
    dplyr::tibble(uuid = "hh1"),
    loop
  ))
})

test_that("add_loop_under5_sick_d_to_main: error on out-of-set eligibility value", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_age_0_4 = 2,
    nut_ind_under5_sick_yes_d = 1,
    nut_ind_under5_sick_yes_respiratory_d = 0,
    nut_ind_under5_sick_yes_watery_d = 0
  )
  expect_error(add_loop_under5_sick_d_to_main(
    dplyr::tibble(uuid = "hh1"),
    loop
  ))
})

test_that("add_loop_under5_sick_d_to_main: warning if _n columns already in main", {
  loop <- dplyr::tibble(
    uuid = "hh1",
    nut_ind_age_0_4 = 1,
    nut_ind_under5_sick_yes_d = 1,
    nut_ind_under5_sick_yes_respiratory_d = 0,
    nut_ind_under5_sick_yes_watery_d = 0
  )
  main <- dplyr::tibble(uuid = "hh1", nut_ind_under5_sick_yes_d_n = 99)
  expect_warning(add_loop_under5_sick_d_to_main(main, loop))
})

test_that("add_loop_under5_sick_d_to_main: no eligible member and unknown answers are blank, not zero", {
  loop <- dplyr::tibble(
    uuid = c("hh1", "hh1"),
    nut_ind_age_0_4 = c(1, 1),
    nut_ind_under5_sick_yes_d = c(NA_real_, NA_real_),
    nut_ind_under5_sick_yes_respiratory_d = c(NA_real_, NA_real_),
    nut_ind_under5_sick_yes_watery_d = c(NA_real_, NA_real_)
  )
  result <- add_loop_under5_sick_d_to_main(dplyr::tibble(uuid = "hh1"), loop)
  expect_true(is.na(result$nut_ind_under5_sick_yes_d_n))
  expect_true(is.na(result$nut_ind_under5_sick_yes_respiratory_d_n))
  expect_true(is.na(result$nut_ind_under5_sick_yes_watery_d_n))
})
