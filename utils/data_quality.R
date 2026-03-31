assessDataQuality <- function(df) {
  if (is.null(df)) return(NULL)
  total      <- nrow(df)
  missing    <- sum(!complete.cases(df))
  # Outliers: Close beyond 3*IQR from Q1/Q3
  q1  <- quantile(df$Close, 0.25)
  q3  <- quantile(df$Close, 0.75)
  iqr <- q3 - q1
  outliers <- sum(df$Close < (q1 - 3 * iqr) | df$Close > (q3 + 3 * iqr))
  # Zero-volume days (data gaps)
  zero_vol <- sum(df$Volume == 0, na.rm = TRUE)

  data.frame(
    Check   = c("Total records", "Missing rows removed",
                "Price outliers (3×IQR)", "Zero-volume days"),
    Value   = c(total, missing, outliers, zero_vol),
    Status  = c("OK",
                ifelse(missing  == 0, "OK", "WARNING"),
                ifelse(outliers == 0, "OK", "WARNING"),
                ifelse(zero_vol == 0, "OK", "WARNING"))
  )
}
