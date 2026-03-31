library(testthat)

source("../utils/lag_features.R", local = TRUE)

test_that("buildLagFeatures builds correct columns", {
  df <- data.frame(Date = Sys.Date() - 5:1, Close = 1:5, Volume = 101:105)
  res <- buildLagFeatures(df, lags = c(1))
  expect_true("Close_lag1" %in% names(res))
})
