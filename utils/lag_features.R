library(rpart)
library(randomForest)

buildLagFeatures <- function(df, lags = c(1, 2, 5, 10, 21)) {
  out <- df[, c("Date", "Close", "Volume")]
  cl  <- df$Close
  for (lag in lags) {
    out[[paste0("Close_lag", lag)]] <- c(rep(NA, lag), head(cl, -lag))
  }
  # Rolling 5-day return
  out$Return5 <- c(rep(NA, 5), diff(cl, lag = 5) / head(cl, -5))
  out <- out[complete.cases(out), ]
  out
}

buildLagLinearModel <- function(lag_df) {
  tryCatch({
    lag_cols <- grep("Close_lag|Return5|Volume", names(lag_df), value = TRUE)
    formula  <- as.formula(paste("Close ~", paste(lag_cols, collapse = " + ")))
    lm(formula, data = lag_df)
  }, error = function(e) NULL)
}

buildLagDecisionTree <- function(lag_df) {
  tryCatch({
    lag_cols <- grep("Close_lag|Return5|Volume", names(lag_df), value = TRUE)
    formula  <- as.formula(paste("Close ~", paste(lag_cols, collapse = " + ")))
    model    <- rpart(formula, data = lag_df, method = "anova",
                      control = rpart.control(cp = 0.01))
    list(model = model, predicted = predict(model, lag_df))
  }, error = function(e) NULL)
}

buildLagRandomForest <- function(lag_df) {
  set.seed(42)
  tryCatch({
    lag_cols <- grep("Close_lag|Return5|Volume", names(lag_df), value = TRUE)
    formula  <- as.formula(paste("Close ~", paste(lag_cols, collapse = " + ")))
    model    <- randomForest(formula, data = lag_df, ntree = 100, maxnodes = 20)
    list(model = model, predicted = predict(model, lag_df))
  }, error = function(e) NULL)
}
