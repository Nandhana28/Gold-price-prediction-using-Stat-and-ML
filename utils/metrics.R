directionalAccuracy <- function(actual, predicted) {
  # % of times predicted direction (up/down) matches actual direction
  if (length(actual) < 2) return(NA)
  act_dir  <- sign(diff(actual))
  pred_dir <- sign(diff(predicted))
  mean(act_dir == pred_dir, na.rm = TRUE) * 100
}
