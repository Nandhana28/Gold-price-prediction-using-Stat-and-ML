library(dplyr)

buildCorrelationData <- function(gold_df, usd_xts) {
  tryCatch({
    if (is.null(usd_xts)) return(NULL)
    usd_df <- data.frame(
      Date     = index(usd_xts),
      USD_Close = as.numeric(usd_xts[, 4])
    )
    merged <- inner_join(gold_df[, c("Date", "Close")], usd_df, by = "Date")
    names(merged)[2] <- "Gold_Close"
    merged <- merged[complete.cases(merged), ]
    cor_val <- cor(merged$Gold_Close, merged$USD_Close)
    list(data = merged, correlation = round(cor_val, 4))
  }, error = function(e) NULL)
}
