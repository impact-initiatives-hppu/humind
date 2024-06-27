library(testthat)
library(humind)

test_that("Reexport functions are available", {
  expect_true(exists("add_hhs"))
  expect_true(exists("add_fcs"))
  expect_true(exists("add_rcsi"))
  expect_true(exists("add_lcsi"))
  expect_true(exists("add_fcm_phase"))
  expect_true(exists("add_fclcm_phase"))
})

test_that("Reexport functions are from impactR4PHU", {
  imported_functions <- getNamespaceImports(asNamespace("humind"))$impactR4PHU
  expected_functions <- c("add_hhs", "add_fcs", "add_rcsi", "add_lcsi", "add_fcm_phase", "add_fclcm_phase")

  expect_equal(length(imported_functions), length(expected_functions))

  for (i in seq_along(expected_functions)) {
    expect_true(expected_functions[i] %in% imported_functions, info = paste0("Function '", expected_functions[i], "' is missing from the imported functions."))
  }
})
