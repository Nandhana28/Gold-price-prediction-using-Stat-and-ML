library(testthat)

source("../utils/indicators.R", local = TRUE)

test_that("ema calculates correctly", {
  x <- c(10, 10, 10, 10, 10)
  res <- ema(x, 3)
  expect_equal(res, 10)
})
