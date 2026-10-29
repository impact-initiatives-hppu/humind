# Helper: one row with a given sanitation facility type and handwashing JMP category
make_df <- function(
  sanitation_cat = "improved",
  handwashing_jmp = "basic"
) {
  dplyr::tibble(
    wash_sanitation_facility_cat = sanitation_cat,
    wash_handwashing_facility_jmp_cat = handwashing_jmp
  )
}


#########################################
### add_sanitation_no_handwashing
#########################################

test_that("adds wash_sanitation_no_handwashing_d column", {
  result <- add_sanitation_no_handwashing(make_df())
  expect_true("wash_sanitation_no_handwashing_d" %in% colnames(result))
})

test_that("output is integer type", {
  result <- add_sanitation_no_handwashing(make_df())
  expect_type(result$wash_sanitation_no_handwashing_d, "integer")
})

# --- 1L cases: no improved sanitation (unimproved facility or open defecation)
# --- AND no handwashing facility ---

test_that("is 1L when sanitation facility is unimproved and no handwashing facility", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_cat = "unimproved", handwashing_jmp = "no_facility")
  )
  expect_equal(result$wash_sanitation_no_handwashing_d, 1L)
})

test_that("is 1L when sanitation facility is none (open defecation) and no handwashing facility", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_cat = "none", handwashing_jmp = "no_facility")
  )
  expect_equal(result$wash_sanitation_no_handwashing_d, 1L)
})

# --- 0L cases: improved sanitation facility ---

test_that("is 0L when sanitation facility is improved regardless of handwashing", {
  df <- dplyr::bind_rows(
    make_df(sanitation_cat = "improved", handwashing_jmp = "no_facility"),
    make_df(sanitation_cat = "improved", handwashing_jmp = "limited"),
    make_df(sanitation_cat = "improved", handwashing_jmp = "basic")
  )
  result <- add_sanitation_no_handwashing(df)
  expect_equal(result$wash_sanitation_no_handwashing_d, c(0L, 0L, 0L))
})

# --- 0L cases: no improved sanitation but has handwashing ---

test_that("is 0L when sanitation facility is unimproved but has limited handwashing", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_cat = "unimproved", handwashing_jmp = "limited")
  )
  expect_equal(result$wash_sanitation_no_handwashing_d, 0L)
})

test_that("is 0L when sanitation facility is unimproved but has basic handwashing", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_cat = "unimproved", handwashing_jmp = "basic")
  )
  expect_equal(result$wash_sanitation_no_handwashing_d, 0L)
})

test_that("is 0L when sanitation facility is none but has handwashing", {
  df <- dplyr::bind_rows(
    make_df(sanitation_cat = "none", handwashing_jmp = "limited"),
    make_df(sanitation_cat = "none", handwashing_jmp = "basic")
  )
  result <- add_sanitation_no_handwashing(df)
  expect_equal(result$wash_sanitation_no_handwashing_d, c(0L, 0L))
})

# --- NA cases ---

test_that("is NA when sanitation facility category is undefined", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_cat = "undefined", handwashing_jmp = "no_facility")
  )
  expect_true(is.na(result$wash_sanitation_no_handwashing_d))
})

test_that("is NA when handwashing category is undefined", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_cat = "unimproved", handwashing_jmp = "undefined")
  )
  expect_true(is.na(result$wash_sanitation_no_handwashing_d))
})

test_that("is NA when sanitation facility category is NA", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_cat = NA_character_, handwashing_jmp = "no_facility")
  )
  expect_true(is.na(result$wash_sanitation_no_handwashing_d))
})

test_that("is NA when handwashing category is NA", {
  result <- add_sanitation_no_handwashing(
    make_df(sanitation_cat = "unimproved", handwashing_jmp = NA_character_)
  )
  expect_true(is.na(result$wash_sanitation_no_handwashing_d))
})

# --- Validation errors ---

test_that("errors when sanitation_facility_cat contains unexpected value", {
  df <- make_df(sanitation_cat = "unexpected_value", handwashing_jmp = "basic")
  expect_error(add_sanitation_no_handwashing(df))
})

test_that("errors when handwashing_jmp_cat contains unexpected value", {
  df <- make_df(
    sanitation_cat = "improved",
    handwashing_jmp = "unexpected_value"
  )
  expect_error(add_sanitation_no_handwashing(df))
})

test_that("errors when sanitation_facility_cat column is missing", {
  df <- dplyr::tibble(wash_handwashing_facility_jmp_cat = "basic")
  expect_error(add_sanitation_no_handwashing(df))
})

test_that("errors when handwashing_jmp_cat column is missing", {
  df <- dplyr::tibble(wash_sanitation_facility_cat = "improved")
  expect_error(add_sanitation_no_handwashing(df))
})

# --- End-to-end: chain the prerequisites instead of hand-building them ---

# Fixture factory: generate_wash_df() covers the handwashing prerequisites, and
# the sanitation columns are added so both prerequisite functions can run.
make_wash_df_with_sanitation <- function(facility, sharing_yn) {
  df <- generate_wash_df()
  df$wash_sanitation_facility <- facility
  df$wash_sanitation_facility_sharing_yn <- sharing_yn
  df
}

test_that("chains the prerequisites (improved facility, not shared)", {
  df <- make_wash_df_with_sanitation("flush_piped_sewer", "no")

  result <- df |>
    add_sanitation_facility_cat() |>
    add_handwashing_facility_cat() |>
    add_sanitation_no_handwashing()

  expect_true("wash_sanitation_no_handwashing_d" %in% colnames(result))
  expect_true(all(result$wash_sanitation_facility_cat == "improved"))
  # improved sanitation is present, so the flag can only be 0 or NA (undefined handwashing)
  resolved <- !is.na(result$wash_handwashing_facility_jmp_cat) &
    result$wash_handwashing_facility_jmp_cat != "undefined"
  expect_true(all(result$wash_sanitation_no_handwashing_d[resolved] == 0L))
})

test_that("shared improved facility (JMP limited) is still classified as improved", {
  df <- make_wash_df_with_sanitation("flush_piped_sewer", "yes")

  result <- df |>
    add_sanitation_facility_cat() |>
    add_sharing_sanitation_facility_cat() |>
    add_sanitation_facility_jmp_cat() |>
    add_handwashing_facility_cat() |>
    add_sanitation_no_handwashing()

  # the JMP category is "limited" (improved but shared)...
  expect_true(all(result$wash_sanitation_facility_jmp_cat == "limited"))
  # ...but the facility is improved, so the indicator is 0 whenever handwashing is known
  resolved <- !is.na(result$wash_handwashing_facility_jmp_cat) &
    result$wash_handwashing_facility_jmp_cat != "undefined"
  expect_true(all(result$wash_sanitation_no_handwashing_d[resolved] == 0L))
})

test_that("improved facility with undefined sharing is classified as improved", {
  df <- make_wash_df_with_sanitation("flush_piped_sewer", "dnk")

  result <- df |>
    add_sanitation_facility_cat() |>
    add_sharing_sanitation_facility_cat() |>
    add_sanitation_facility_jmp_cat() |>
    add_handwashing_facility_cat() |>
    add_sanitation_no_handwashing()

  # the JMP category is "undefined" (sharing unknown)...
  expect_true(all(result$wash_sanitation_facility_jmp_cat == "undefined"))
  # ...yet the facility type is known to be improved, so the flag is 0
  resolved <- !is.na(result$wash_handwashing_facility_jmp_cat) &
    result$wash_handwashing_facility_jmp_cat != "undefined"
  expect_true(all(result$wash_sanitation_no_handwashing_d[resolved] == 0L))
})

test_that("chains the prerequisites (open defecation)", {
  df <- make_wash_df_with_sanitation("none", NA_character_)

  result <- df |>
    add_sanitation_facility_cat() |>
    add_handwashing_facility_cat() |>
    add_sanitation_no_handwashing()

  d <- result$wash_sanitation_no_handwashing_d
  hwj <- result$wash_handwashing_facility_jmp_cat
  expect_true(all(result$wash_sanitation_facility_cat == "none"))
  no_fac <- !is.na(hwj) & hwj == "no_facility"
  has_hw <- !is.na(hwj) & hwj %in% c("limited", "basic")
  undef <- !is.na(hwj) & hwj == "undefined"
  # every handwashing category is represented, and each drives the expected flag
  expect_true(sum(no_fac) > 0)
  expect_true(sum(has_hw) > 0)
  expect_true(sum(undef) > 0)
  expect_true(all(d[no_fac] == 1L))
  expect_true(all(d[has_hw] == 0L))
  expect_true(all(is.na(d[undef])))
})
