mlModelsUI <- function(id) {
  ns <- NS(id)
  tabPanel("ML Models",
    br(),
    h4("Lag-Feature Machine Learning Models"),
    p("These models use lagged Close prices (t-1, t-2, t-5, t-10, t-21),",
      "5-day return, and volume as features — enabling genuine out-of-sample forecasting."),
    br(),
    h5("Linear Regression"),
    verbatimTextOutput(ns("linearSummary")),
    br(),
    h5("Decision Tree"),
    plotOutput(ns("dtPlot"), height = "400px"),
    verbatimTextOutput(ns("dtMetrics")),
    br(),
    h5("Random Forest"),
    plotOutput(ns("rfImportancePlot"), height = "350px"),
    verbatimTextOutput(ns("rfMetrics")),
    br(),
    plotOutput(ns("mlPredictionsPlot"), height = "450px")
  )
}

mlModelsServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$linearSummary <- renderPrint({
      req(rv$results$lin_mod)
      summary(rv$results$lin_mod)
    })

    output$dtPlot <- renderPlot({
      req(rv$results$dt_mod)
      plot(rv$results$dt_mod$model, main = "Decision Tree Structure")
      text(rv$results$dt_mod$model, cex = 0.8)
    })

    output$dtMetrics <- renderPrint({
      req(rv$results$dt_mod, rv$results$lag_df)
      dt  <- rv$results$dt_mod
      act <- rv$results$lag_df$Close
      pred <- dt$predicted
      cat("Decision Tree — in-sample metrics (lag features)\n")
      cat("MAE: ",  round(mean(abs(pred - act)), 4), "\n")
      cat("RMSE:", round(sqrt(mean((pred - act)^2)), 4), "\n")
      cat("Directional Accuracy:", round(directionalAccuracy(act, pred), 1), "%\n")
    })

    output$rfImportancePlot <- renderPlot({
      req(rv$results$rf_mod)
      imp <- importance(rv$results$rf_mod$model)
      imp_df <- data.frame(Feature = rownames(imp),
                           IncMSE  = imp[, "%IncMSE"])
      ggplot(imp_df, aes(x = reorder(Feature, IncMSE), y = IncMSE)) +
        geom_col(fill = "#2c7fb8", alpha = 0.8) +
        coord_flip() +
        labs(title = "Random Forest — Feature Importance (%IncMSE)",
             x = NULL, y = "% Increase in MSE if removed") +
        theme_minimal(base_size = 12)
    })

    output$rfMetrics <- renderPrint({
      req(rv$results$rf_mod, rv$results$lag_df)
      rf   <- rv$results$rf_mod
      act  <- rv$results$lag_df$Close
      pred <- rf$predicted
      cat("Random Forest — in-sample metrics (lag features)\n")
      cat("MAE: ",  round(mean(abs(pred - act)), 4), "\n")
      cat("RMSE:", round(sqrt(mean((pred - act)^2)), 4), "\n")
      cat("Directional Accuracy:", round(directionalAccuracy(act, pred), 1), "%\n")
    })

    output$mlPredictionsPlot <- renderPlot({
      req(rv$results$lag_df, rv$results$lin_mod,
          rv$results$dt_mod,  rv$results$rf_mod)
      lag_df <- rv$results$lag_df
      n      <- nrow(lag_df)
      plot_df <- tail(lag_df, min(n, 120))

      fitted_lin <- tail(fitted(rv$results$lin_mod), min(n, 120))
      fitted_dt  <- tail(rv$results$dt_mod$predicted, min(n, 120))
      fitted_rf  <- tail(rv$results$rf_mod$predicted, min(n, 120))

      ggplot(plot_df, aes(x = Date)) +
        geom_line(aes(y = Close),      color = "black",   linewidth = 0.8, alpha = 0.9) +
        geom_line(aes(y = fitted_lin), color = "#e6550d", linewidth = 0.7, linetype = "dashed") +
        geom_line(aes(y = fitted_dt),  color = "#31a354", linewidth = 0.7, linetype = "dashed") +
        geom_line(aes(y = fitted_rf),  color = "#3182bd", linewidth = 0.7, linetype = "dashed") +
        labs(title = "ML Model Fitted Values vs Actual (last 120 days)",
             subtitle = "Black = Actual | Orange = Linear | Green = DTree | Blue = RF",
             x = NULL, y = "USD / oz") +
        theme_minimal(base_size = 13)
    })
  })
}
