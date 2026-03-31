library(testthat)

source("../utils/metrics.R", local = TRUE)

test_that("directionalAccuracy calculates correctly", {
  actual <- c(100, 105, 103)
  pred <- c(100, 104, 102)
  # Actual diffs: +5, -2 -> signs: 1, -1
  # Pred diffs: +4, -2 -> signs: 1, -1
  # Match: 100%
  res <- directionalAccuracy(actual, pred)
  expect_equal(res, 100)
})
