ema <- function(x, n) {
  k   <- 2 / (n + 1)
  out <- numeric(length(x))
  out[n] <- mean(x[1:n])
  for (i in (n + 1):length(x)) out[i] <- x[i] * k + out[i - 1] * (1 - k)
  out[length(x)]
}

calculateGoldIndices <- function(df) {
  tryCatch({
    cl  <- df$Close
    hi  <- df$High
    lo  <- df$Low
    vol <- df$Volume
    n   <- length(cl)

    sma20  <- mean(tail(cl, 20),  na.rm = TRUE)
    sma50  <- mean(tail(cl, 50),  na.rm = TRUE)
    sma200 <- mean(tail(cl, 200), na.rm = TRUE)
    ema12  <- ema(cl, 12)
    ema26  <- ema(cl, 26)

    deltas <- diff(cl)
    gains  <- ifelse(deltas > 0, deltas, 0)
    losses <- ifelse(deltas < 0, -deltas, 0)
    avg_g  <- mean(tail(gains,  14), na.rm = TRUE)
    avg_l  <- mean(tail(losses, 14), na.rm = TRUE)
    rs     <- avg_g / (avg_l + 1e-9)
    rsi    <- 100 - (100 / (1 + rs))

    std20       <- sd(tail(cl, 20), na.rm = TRUE)
    boll_upper  <- sma20 + 2 * std20
    boll_lower  <- sma20 - 2 * std20
    macd_line   <- ema12 - ema26
    signal_line <- ema(cl, 9)          # 9-day EMA of close as signal proxy

    avg_vol  <- mean(vol, na.rm = TRUE)
    cur_vol  <- tail(vol, 1)
    momentum <- tail(cl, 1) - cl[max(1, n - 10)]

    list(
      SMA_20         = sma20,
      SMA_50         = sma50,
      SMA_200        = sma200,
      EMA_12         = ema12,
      RSI_14         = rsi,
      MACD           = macd_line,
      Signal_Line    = signal_line,
      Bollinger_Upper = boll_upper,
      Bollinger_Middle = sma20,
      Bollinger_Lower = boll_lower,
      Volatility_USD = sd(cl, na.rm = TRUE),
      Volatility_pct = (sd(cl, na.rm = TRUE) / mean(cl, na.rm = TRUE)) * 100,
      Daily_Range    = tail(hi, 1) - tail(lo, 1),
      Yearly_High    = max(hi, na.rm = TRUE),
      Yearly_Low     = min(lo, na.rm = TRUE),
      Support_20d    = min(tail(lo, 20), na.rm = TRUE),
      Resistance_20d = max(tail(hi, 20), na.rm = TRUE),
      Avg_Volume     = avg_vol,
      Current_Volume = cur_vol,
      Volume_Ratio   = cur_vol / avg_vol,
      Momentum_10d   = momentum,
      Momentum_pct   = (momentum / cl[max(1, n - 10)]) * 100
    )
  }, error = function(e) NULL)
}
