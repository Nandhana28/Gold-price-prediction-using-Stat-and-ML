ensembleUI <- function(id) {
  ns <- NS(id)
  tabPanel("Ensemble",
    br(),
    h4("Ensemble Forecast (Inverse-RMSE Weighted)"),
    p("Combines ARIMA, SARIMA, and ETS forecasts weighted by their",
      "walk-forward validation RMSE. Lower RMSE → higher weight."),
    uiOutput(ns("ensembleWeights")),
    br(),
    plotOutput(ns("ensemblePlot"), height = "500px")
  )
}

ensembleServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$ensembleWeights <- renderUI({
      req(rv$results$ensemble)
      w <- round(rv$results$ensemble$weights * 100, 1)
      fluidRow(
        column(4, div(class = "card border-primary mb-3",
          div(class = "card-body text-center",
            h6("ARIMA weight"), h4(paste0(w["ARIMA"], "%"))))),
        column(4, div(class = "card border-info mb-3",
          div(class = "card-body text-center",
            h6("SARIMA weight"), h4(paste0(w["SARIMA"], "%"))))),
        column(4, div(class = "card border-success mb-3",
          div(class = "card-body text-center",
            h6("ETS weight"), h4(paste0(w["ETS"], "%")))))
      )
    })

    output$ensemblePlot <- renderPlot({
      req(rv$results$ensemble, rv$results$arima_res)
      fc_arima <- rv$results$arima_res$forecast
      ens      <- rv$results$ensemble$mean
      h        <- length(ens)
      df_ens   <- data.frame(
        Day      = 1:h,
        ARIMA    = as.numeric(fc_arima$mean)[1:h],
        Ensemble = as.numeric(ens)
      )
      ggplot(df_ens, aes(x = Day)) +
        geom_line(aes(y = ARIMA,    color = "ARIMA"),    linewidth = 0.8, linetype = "dashed") +
        geom_line(aes(y = Ensemble, color = "Ensemble"), linewidth = 1.2) +
        scale_color_manual(values = c("ARIMA" = "#636363", "Ensemble" = "#2c7fb8")) +
        labs(title = "Ensemble vs ARIMA Forecast", x = "Days ahead",
             y = "USD / oz", color = NULL) +
        theme_minimal(base_size = 13)
    })
  })
}
