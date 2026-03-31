checkStationarity <- function(df) {
  tryCatch({
    suppressWarnings({
      adf  <- adf.test(df$Close)
      kpss <- kpss.test(df$Close)
      # Stationary if ADF p < 0.05 AND KPSS p > 0.05
      is_stat <- (adf$p.value < 0.05) && (kpss$p.value > 0.05)
      list(adf = adf, kpss = kpss, is_stationary = is_stat)
    })
  }, error = function(e) NULL)
}

prepareSeriesForArima <- function(df, stat_result) {
  # Gate: if not stationary, apply first-order differencing
  cl <- df$Close
  if (!is.null(stat_result) && !stat_result$is_stationary) {
    cl <- diff(cl)
    cl <- cl[!is.na(cl)]
    attr(cl, "differenced") <- TRUE
  } else {
    attr(cl, "differenced") <- FALSE
  }
  ts(cl, frequency = 252)   # 252 trading days per year
}
