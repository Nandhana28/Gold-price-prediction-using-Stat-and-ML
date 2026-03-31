calculateStatistics <- function(df) {
  tryCatch({
    x <- df$Close
    n <- length(x)
    mu <- mean(x, na.rm = TRUE)
    s  <- sd(x,   na.rm = TRUE)
    # Proper moment-based skewness (not Pearson's approximation)
    skew <- (sum((x - mu)^3, na.rm = TRUE) / n) / s^3

    list(
      Mean                  = mu,
      Median                = median(x, na.rm = TRUE),
      StdDev                = s,
      Min                   = min(x, na.rm = TRUE),
      Max                   = max(x, na.rm = TRUE),
      Range                 = max(x, na.rm = TRUE) - min(x, na.rm = TRUE),
      Q1                    = quantile(x, 0.25, na.rm = TRUE),
      Q3                    = quantile(x, 0.75, na.rm = TRUE),
      IQR                   = IQR(x, na.rm = TRUE),
      Skewness              = skew,
      CV_pct                = (s / mu) * 100,
      TotalReturn_pct       = ((tail(x, 1) - x[1]) / x[1]) * 100,
      AvgDailyChange        = mean(diff(x), na.rm = TRUE),
      AvgDailyChange_pct    = mean((diff(x) / head(x, -1)) * 100, na.rm = TRUE)
    )
  }, error = function(e) NULL)
}
