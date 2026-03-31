arimaUI <- function(id) {
  ns <- NS(id)
  tabPanel("ARIMA",
    br(),
    uiOutput(ns("arimaDiffNote")),
    plotOutput(ns("arimaPlot"), height = "500px"),
    verbatimTextOutput(ns("arimaSummary")),
    h4("Forecast Table (30 days)"),
    tableOutput(ns("arimaTable"))
  )
}

arimaServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$arimaDiffNote <- renderUI({
      req(rv$results$stat_res)
      sr <- rv$results$stat_res
      if (!sr$is_stationary) {
        div(class = "alert alert-info",
            "Series was non-stationary — first-order differencing was applied automatically before fitting.")
      }
    })

    output$arimaPlot <- renderPlot({
      req(rv$results$arima_res)
      plot(rv$results$arima_res$forecast, main = "ARIMA Forecast")
    })

    output$arimaSummary <- renderPrint({
      req(rv$results$arima_res)
      summary(rv$results$arima_res$model)
    })

    output$arimaTable <- renderTable({
      req(rv$results$arima_res)
      fc <- rv$results$arima_res$forecast
      h  <- min(30, length(fc$mean))
      data.frame(
        Day      = 1:h,
        Forecast = round(as.numeric(fc$mean)[1:h],         2),
        Lo80     = round(as.numeric(fc$lower[1:h, 1]),     2),
        Hi80     = round(as.numeric(fc$upper[1:h, 1]),     2),
        Lo95     = round(as.numeric(fc$lower[1:h, 2]),     2),
        Hi95     = round(as.numeric(fc$upper[1:h, 2]),     2)
      )
    })
  })
}
