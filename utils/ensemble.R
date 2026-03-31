buildEnsemble <- function(arima_res, sarima_res, es_res, wf_cv) {
  tryCatch({
    if (is.null(arima_res) || is.null(sarima_res) || is.null(es_res)) return(NULL)

    # Weights from walk-forward RMSE if available; else equal weights
    if (!is.null(wf_cv)) {
      w_arima  <- 1 / (wf_cv$arima_rmse  + 1e-9)
      w_ets    <- 1 / (wf_cv$ets_rmse    + 1e-9)
      w_sarima <- 1 / (wf_cv$arima_rmse  + 1e-9)  # sarima shares arima wf estimate
    } else {
      w_arima <- w_sarima <- w_ets <- 1
    }
    w_total <- w_arima + w_sarima + w_ets

    ensemble_mean <- (arima_res$forecast$mean  * w_arima  +
                      sarima_res$forecast$mean * w_sarima +
                      es_res$forecast$mean     * w_ets) / w_total

    list(
      mean    = ensemble_mean,
      weights = c(ARIMA = w_arima / w_total,
                  SARIMA = w_sarima / w_total,
                  ETS    = w_ets   / w_total)
    )
  }, error = function(e) NULL)
}
