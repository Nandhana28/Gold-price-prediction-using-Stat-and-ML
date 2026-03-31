library(forecast)

walkForwardCV <- function(price_ts, h = 30, initial = 200) {
  # Requires at least initial + h observations
  n <- length(price_ts)
  if (n < initial + h) return(NULL)

  tryCatch({
    # ARIMA walk-forward errors via tsCV
    arima_errors <- tsCV(price_ts,
                         forecastfunction = function(x, h) {
                           forecast(auto.arima(x, stepwise = TRUE, trace = FALSE), h = h)
                         },
                         h = h, initial = initial)

    # ETS walk-forward errors
    ets_errors <- tsCV(price_ts,
                       forecastfunction = function(x, h) forecast(ets(x), h = h),
                       h = h, initial = initial)

    # 1-step-ahead only for summary
    arima_e1 <- arima_errors[, 1]
    ets_e1   <- ets_errors[, 1]

    list(
      arima_mae  = mean(abs(arima_e1), na.rm = TRUE),
      arima_rmse = sqrt(mean(arima_e1^2, na.rm = TRUE)),
      ets_mae    = mean(abs(ets_e1),   na.rm = TRUE),
      ets_rmse   = sqrt(mean(ets_e1^2, na.rm = TRUE))
    )
  }, error = function(e) NULL)
}

checkCoverage <- function(df, arima_res, holdout_n = 60) {
  tryCatch({
    n     <- nrow(df)
    if (n < holdout_n + 50) return(NULL)

    train_df <- df[1:(n - holdout_n), ]
    actual   <- df$Close[(n - holdout_n + 1):n]

    # Refit ARIMA on training data
    train_ts <- ts(train_df$Close, frequency = 252)
    model    <- auto.arima(train_ts, stepwise = TRUE, trace = FALSE)
    fc       <- forecast(model, h = holdout_n, level = c(80, 95))

    in80 <- mean(actual >= fc$lower[, 1] & actual <= fc$upper[, 1], na.rm = TRUE) * 100
    in95 <- mean(actual >= fc$lower[, 2] & actual <= fc$upper[, 2], na.rm = TRUE) * 100

    data.frame(
      Interval      = c("80%", "95%"),
      Target        = c(80, 95),
      Actual_Coverage_pct = round(c(in80, in95), 1),
      Assessment    = c(
        ifelse(abs(in80 - 80) < 10, "Well calibrated", "Under/over-confident"),
        ifelse(abs(in95 - 95) < 10, "Well calibrated", "Under/over-confident")
      )
    )
  }, error = function(e) NULL)
}
