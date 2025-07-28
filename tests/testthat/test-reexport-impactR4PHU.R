test_that("Reexport functions are available", {
  expect_true(exists("add_hhs"))
  expect_true(exists("add_fcs"))
  expect_true(exists("add_rcsi"))
  expect_true(exists("add_lcsi"))
  expect_true(exists("add_fcm_phase"))
  expect_true(exists("add_fclcm_phase"))
})

test_that("Reexport functions are from impactR4PHU", {
  humind_ns <- asNamespace("humind")
  expected_functions <- c("add_hhs", "add_fcs", "add_rcsi", "add_lcsi", "add_fcm_phase", "add_fclcm_phase")

  for (func in expected_functions) {
    expect_true(exists(func, envir = humind_ns), info = paste("Function", func, "should exist in humind namespace"))
    expect_identical(environment(get(func, envir = humind_ns)), asNamespace("impactR4PHU"),
                     info = paste("Function", func, "should have impactR4PHU namespace as its environment"))
  }
})
