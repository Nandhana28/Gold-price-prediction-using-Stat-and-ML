library(forecast)

buildArimaModel <- function(price_ts, h = 30) {
  tryCatch({
    model  <- auto.arima(price_ts, stepwise = TRUE, trace = FALSE)
    fc     <- forecast(model, h = h, level = c(80, 95))
    list(model = model, forecast = fc)
  }, error = function(e) NULL)
}

buildSarimaModel <- function(price_ts, h = 30) {
  tryCatch({
    model  <- auto.arima(price_ts, seasonal = TRUE, stepwise = TRUE, trace = FALSE)
    fc     <- forecast(model, h = h, level = c(80, 95))
    list(model = model, forecast = fc)
  }, error = function(e) NULL)
}

buildExponentialSmoothing <- function(price_ts, h = 30) {
  tryCatch({
    model  <- ets(price_ts)
    fc     <- forecast(model, h = h, level = c(80, 95))
    list(model = model, forecast = fc)
  }, error = function(e) NULL)
}
