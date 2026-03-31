CACHE_FILE    <- "data/gold_cache.rds"
CACHE_MAX_AGE <- 4  # hours before re-fetch

loadGoldData <- function(startDate = Sys.Date() - 365, endDate = Sys.Date()) {
  # Return cached data if fresh enough
  if (file.exists(CACHE_FILE)) {
    cached <- readRDS(CACHE_FILE)
    age_hours <- as.numeric(difftime(Sys.time(), cached$timestamp, units = "hours"))
    if (age_hours < CACHE_MAX_AGE &&
        as.Date(cached$startDate) == as.Date(startDate) &&
        as.Date(cached$endDate)   == as.Date(endDate)) {
      return(list(data = cached$data, source = "cache"))
    }
  }

  tryCatch({
    suppressWarnings({
      raw <- getSymbols("GC=F", src = "yahoo",
                        from = startDate, to = endDate,
                        auto.assign = FALSE)
      # Create data folder if it doesn't exist
      if (!dir.exists("data")) dir.create("data")
      saveRDS(list(data = raw, timestamp = Sys.time(),
                   startDate = startDate, endDate = endDate),
              CACHE_FILE)
      return(list(data = raw, source = "live"))
    })
  }, error = function(e) {
    # Fall back to cache even if stale
    if (file.exists(CACHE_FILE)) {
      cached <- readRDS(CACHE_FILE)
      return(list(data = cached$data, source = "stale_cache"))
    }
    return(list(data = NULL, source = "failed"))
  })
}

loadUsdIndex <- function(startDate, endDate) {
  tryCatch({
    suppressWarnings({
      raw <- getSymbols("DX-Y.NYB", src = "yahoo",
                        from = startDate, to = endDate,
                        auto.assign = FALSE)
      return(raw)
    })
  }, error = function(e) NULL)
}

convertToDataFrame <- function(xtsData) {
  if (is.null(xtsData)) return(NULL)
  tryCatch({
    df <- data.frame(
      Date     = index(xtsData),
      Open     = as.numeric(xtsData[, 1]),
      High     = as.numeric(xtsData[, 2]),
      Low      = as.numeric(xtsData[, 3]),
      Close    = as.numeric(xtsData[, 4]),
      Volume   = as.numeric(xtsData[, 5]),
      Adjusted = as.numeric(xtsData[, 6])
    )
    df <- df[complete.cases(df), ]
    rownames(df) <- NULL
    df
  }, error = function(e) NULL)
}
