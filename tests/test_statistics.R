library(testthat)

# Note: Tests should be run from ChrysaNova/ folder or source appropriately
source("../utils/statistics.R", local = TRUE)

test_that("calculateStatistics handles basic input", {
  df <- data.frame(Close = c(100, 102, 101, 105, 104))
  res <- calculateStatistics(df)
  expect_true(!is.null(res))
  expect_equal(res$Mean, 102.4)
  expect_equal(res$Min, 100)
  expect_equal(res$Max, 105)
})
