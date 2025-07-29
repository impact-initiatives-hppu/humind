test_that("add_msni works with default parameters", {
  df <- data.frame(
    comp_foodsec_score = c(1, 2, 3, 4, 5),
    comp_snfi_score = c(5, 4, 3, 2, 1),
    comp_wash_score = c(2, 2, 2, 2, 2),
    comp_prot_score = c(3, 3, 3, 3, 3),
    comp_health_score = c(4, 4, 4, 4, 4),
    comp_edu_score = c(5, 5, 5, 5, 5),
    comp_foodsec_in_need = c(0, 0, 1, 1, 1),
    comp_snfi_in_need = c(1, 1, 1, 0, 0),
    comp_wash_in_need = c(0, 0, 0, 0, 0),
    comp_prot_in_need = c(1, 1, 1, 1, 1),
    comp_health_in_need = c(1, 1, 1, 1, 1),
    comp_edu_in_need = c(1, 1, 1, 1, 1)
  )

  result <- humind:::add_msni(df)

  expected <- df %>%
    mutate(
      msni_score = pmax(
        comp_foodsec_score,
        comp_snfi_score,
        comp_wash_score,
        comp_prot_score,
        comp_health_score,
        comp_edu_score,
        na.rm = TRUE
      ),
      msni_in_need = ifelse(msni_score >= 3, 1, 0),
      msni_in_acute_need = ifelse(msni_score >= 4, 1, 0),
      sector_in_need_n = comp_foodsec_in_need +
        comp_snfi_in_need +
        comp_wash_in_need +
        comp_prot_in_need +
        comp_health_in_need +
        comp_edu_in_need,
      sector_needs_profile = purrr::pmap_chr(
        list(
          comp_foodsec_in_need,
          comp_snfi_in_need,
          comp_wash_in_need,
          comp_prot_in_need,
          comp_health_in_need,
          comp_edu_in_need
        ),
        function(foodsec, snfi, wash, prot, health, edu) {
          labels <- c()
          if (foodsec == 1) {
            labels <- c(labels, "Food security")
          }
          if (snfi == 1) {
            labels <- c(labels, "SNFI")
          }
          if (wash == 1) {
            labels <- c(labels, "WASH")
          }
          if (prot == 1) {
            labels <- c(labels, "Protection")
          }
          if (health == 1) {
            labels <- c(labels, "Health")
          }
          if (edu == 1) {
            labels <- c(labels, "Education")
          }
          paste(labels, collapse = " - ")
        }
      )
    )

  expect_equal(result, expected)
})


test_that("add_msni handles all possible values", {
  df <- data.frame(
    comp_foodsec_score = 1:5,
    comp_snfi_score = 1:5,
    comp_wash_score = 1:5,
    comp_prot_score = 1:5,
    comp_health_score = 1:5,
    comp_edu_score = 1:5,
    comp_foodsec_in_need = c(0, 0, 1, 1, 1),
    comp_snfi_in_need = c(0, 0, 1, 1, 1),
    comp_wash_in_need = c(0, 0, 1, 1, 1),
    comp_prot_in_need = c(0, 0, 1, 1, 1),
    comp_health_in_need = c(0, 0, 1, 1, 1),
    comp_edu_in_need = c(0, 0, 1, 1, 1)
  )

  result <- humind:::add_msni(df)

  expected <- df %>%
    mutate(
      msni_score = 1:5,
      msni_in_need = ifelse(msni_score >= 3, 1, 0),
      msni_in_acute_need = ifelse(msni_score >= 4, 1, 0),
      sector_in_need_n = c(NA, NA, 6, 6, 6),
      sector_needs_profile = purrr::pmap_chr(
        list(
          comp_foodsec_in_need,
          comp_snfi_in_need,
          comp_wash_in_need,
          comp_prot_in_need,
          comp_health_in_need,
          comp_edu_in_need
        ),
        function(foodsec, snfi, wash, prot, health, edu) {
          labels <- c()
          if (foodsec == 1) {
            labels <- c(labels, "Food security")
          }
          if (snfi == 1) {
            labels <- c(labels, "SNFI")
          }
          if (wash == 1) {
            labels <- c(labels, "WASH")
          }
          if (prot == 1) {
            labels <- c(labels, "Protection")
          }
          if (health == 1) {
            labels <- c(labels, "Health")
          }
          if (edu == 1) {
            labels <- c(labels, "Education")
          }
          p <- paste(labels, collapse = " - ")
          p <- ifelse(p == "", NA, p)
        }
      )
    )

  expect_equal(result, expected)

  # Additional checks for msni_in_acute_need
  expect_equal(result$msni_in_acute_need, c(0, 0, 0, 1, 1))
})


#test_that("add_msni handles all NA values", {
#  df <- data.frame(
#    comp_foodsec_score = c(NA, NA, NA, NA, NA),
#    comp_snfi_score = c(NA, NA, NA, NA, NA),
#    comp_wash_score = c(NA, NA, NA, NA, NA),
#    comp_prot_score = c(NA, NA, NA, NA, NA),
#    comp_health_score = c(NA, NA, NA, NA, NA),
#    comp_edu_score = c(NA, NA, NA, NA, NA)
#  )
#
#  result <- humind:::add_msni(df)
#
#  expected <- df %>%
#    mutate(msni_score = NA, msni_in_need = NA)
#
#  expect_equal(result, expected)
#})

test_that("add_msni handles missing columns", {
  df <- data.frame(
    comp_foodsec_score = c(1, 2, 3, 4, 5),
    comp_snfi_score = c(5, 4, 3, 2, 1)
  )

  expect_error(humind:::add_msni(df), class = "error")
})

test_that("add_msni handles out-of-range values", {
  df <- data.frame(
    comp_foodsec_score = c(0, 6, -1, 10, NA),
    comp_snfi_score = c(5, 4, 3, 2, 1),
    comp_wash_score = c(2, 2, 2, 2, 2),
    comp_prot_score = c(3, 3, 3, 3, 3),
    comp_health_score = c(4, 4, 4, 4, 4),
    comp_edu_score = c(5, 5, 5, 5, 5)
  )

  expect_error(humind:::add_msni(df), class = "error")
})
