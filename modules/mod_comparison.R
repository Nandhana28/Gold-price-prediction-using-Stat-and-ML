comparisonUI <- function(id) {
  ns <- NS(id)
  tabPanel("Model Comparison",
    br(),
    h4("All Models — Performance Metrics"),
    tableOutput(ns("allMetricsTable")),
    br(),
    plotOutput(ns("comparisonPlot"), height = "550px"),
    br(),
    h4("Predictions vs Actual (Last 30 days)"),
    tableOutput(ns("allPredTable"))
  )
}

comparisonServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$allMetricsTable <- renderTable({
      req(rv$results)
      r      <- rv$results
      lag_df <- r$lag_df
      act    <- lag_df$Close

      rows <- list()

      if (!is.null(r$lin_mod)) {
        pred <- fitted(r$lin_mod)
        rows[["Linear (lag)"]] <- c(
          MAE  = round(mean(abs(pred - act)), 2),
          RMSE = round(sqrt(mean((pred - act)^2)), 2),
          DirAcc = round(directionalAccuracy(act, pred), 1),
          Type = "In-sample")
      }
      if (!is.null(r$dt_mod)) {
        pred <- r$dt_mod$predicted
        rows[["DTree (lag)"]] <- c(
          MAE  = round(mean(abs(pred - act)), 2),
          RMSE = round(sqrt(mean((pred - act)^2)), 2),
          DirAcc = round(directionalAccuracy(act, pred), 1),
          Type = "In-sample")
      }
      if (!is.null(r$rf_mod)) {
        pred <- r$rf_mod$predicted
        rows[["RF (lag)"]] <- c(
          MAE  = round(mean(abs(pred - act)), 2),
          RMSE = round(sqrt(mean((pred - act)^2)), 2),
          DirAcc = round(directionalAccuracy(act, pred), 1),
          Type = "In-sample")
      }
      if (!is.null(r$wf_cv)) {
        rows[["ARIMA"]] <- c(
          MAE  = round(r$wf_cv$arima_mae,  2),
          RMSE = round(r$wf_cv$arima_rmse, 2),
          DirAcc = NA,
          Type = "Walk-forward OOS")
        rows[["ETS"]] <- c(
          MAE  = round(r$wf_cv$ets_mae,  2),
          RMSE = round(r$wf_cv$ets_rmse, 2),
          DirAcc = NA,
          Type = "Walk-forward OOS")
      }

      if (length(rows) == 0) return(data.frame(Note = "Run analysis first"))
      out <- do.call(rbind, lapply(names(rows), function(nm) {
        cbind(Model = nm, as.data.frame(t(rows[[nm]]), stringsAsFactors = FALSE))
      }))
      out
    })

    output$comparisonPlot <- renderPlot({
      req(rv$results$arima_res, rv$results$sarima_res, rv$results$es_res,
          rv$results$ensemble)
      ar  <- as.numeric(rv$results$arima_res$forecast$mean)
      sar <- as.numeric(rv$results$sarima_res$forecast$mean)
      es  <- as.numeric(rv$results$es_res$forecast$mean)
      ens <- as.numeric(rv$results$ensemble$mean)
      h   <- length(ar)
      df_plot <- data.frame(
        Day      = 1:h,
        ARIMA    = ar,
        SARIMA   = sar,
        ETS      = es,
        Ensemble = ens
      )
      ggplot(df_plot, aes(x = Day)) +
        geom_line(aes(y = ARIMA,    color = "ARIMA"),    linewidth = 0.8) +
        geom_line(aes(y = SARIMA,   color = "SARIMA"),   linewidth = 0.8) +
        geom_line(aes(y = ETS,      color = "ETS"),      linewidth = 0.8) +
        geom_line(aes(y = Ensemble, color = "Ensemble"), linewidth = 1.3) +
        scale_color_manual(values = c(
          ARIMA    = "#636363",
          SARIMA   = "#e6550d",
          ETS      = "#31a354",
          Ensemble = "#2c7fb8")) +
        labs(title = "All Time-Series Model Forecasts",
             x = "Days ahead", y = "USD / oz", color = NULL) +
        theme_minimal(base_size = 13)
    })

    output$allPredTable <- renderTable({
      req(rv$results$lag_df, rv$results$lin_mod,
          rv$results$dt_mod,  rv$results$rf_mod)
      lag_df <- rv$results$lag_df
      n      <- nrow(lag_df)
      k      <- min(30, n)
      tail_df <- tail(lag_df, k)

      data.frame(
        Date   = as.character(tail_df$Date),
        Actual = round(tail_df$Close, 2),
        Linear = round(tail(fitted(rv$results$lin_mod), k), 2),
        DTree  = round(tail(rv$results$dt_mod$predicted, k), 2),
        RF     = round(tail(rv$results$rf_mod$predicted, k), 2)
      )
    })
  })
}
