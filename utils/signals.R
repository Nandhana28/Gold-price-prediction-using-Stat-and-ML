interpretSignals <- function(indices) {
  if (is.null(indices)) return(NULL)

  signals <- list()

  # RSI
  signals$RSI <- if (indices$RSI_14 > 70) {
    list(value = round(indices$RSI_14, 1), signal = "OVERBOUGHT", color = "danger",
         note = "RSI > 70: price may be extended, watch for reversal")
  } else if (indices$RSI_14 < 30) {
    list(value = round(indices$RSI_14, 1), signal = "OVERSOLD", color = "success",
         note = "RSI < 30: potential buying opportunity")
  } else {
    list(value = round(indices$RSI_14, 1), signal = "NEUTRAL", color = "secondary",
         note = "RSI 30–70: no extreme signal")
  }

  # MACD
  signals$MACD <- if (indices$MACD > 0) {
    list(value = round(indices$MACD, 2), signal = "BULLISH", color = "success",
         note = "MACD > 0: short-term momentum above long-term")
  } else {
    list(value = round(indices$MACD, 2), signal = "BEARISH", color = "danger",
         note = "MACD < 0: short-term momentum below long-term")
  }

  # Bollinger
  cur <- indices$SMA_20  # proxy for current price relative to bands
  signals$Bollinger <- if (cur > indices$Bollinger_Upper) {
    list(signal = "ABOVE UPPER BAND", color = "danger",
         note = "Price near upper band: potential resistance / overbought")
  } else if (cur < indices$Bollinger_Lower) {
    list(signal = "BELOW LOWER BAND", color = "success",
         note = "Price near lower band: potential support / oversold")
  } else {
    list(signal = "WITHIN BANDS", color = "secondary",
         note = "Price within Bollinger Bands: no extreme volatility signal")
  }

  # Trend (SMA cross)
  signals$Trend <- if (indices$SMA_20 > indices$SMA_200) {
    list(signal = "BULLISH TREND", color = "success",
         note = "SMA20 > SMA200: price above long-term average (golden zone)")
  } else {
    list(signal = "BEARISH TREND", color = "danger",
         note = "SMA20 < SMA200: price below long-term average (death zone)")
  }

  # Volume
  signals$Volume <- if (indices$Volume_Ratio > 1.5) {
    list(value = round(indices$Volume_Ratio, 2), signal = "HIGH VOLUME", color = "warning",
         note = "Volume ratio > 1.5×: strong conviction behind recent move")
  } else if (indices$Volume_Ratio < 0.5) {
    list(value = round(indices$Volume_Ratio, 2), signal = "LOW VOLUME", color = "secondary",
         note = "Volume ratio < 0.5×: weak conviction, treat moves cautiously")
  } else {
    list(value = round(indices$Volume_Ratio, 2), signal = "NORMAL VOLUME", color = "secondary",
         note = "Volume near average")
  }

  signals
}
