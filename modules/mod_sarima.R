sarimaUI <- function(id) {
  ns <- NS(id)
  tabPanel("SARIMA",
    br(),
    plotOutput(ns("sarimaPlot"), height = "500px"),
    verbatimTextOutput(ns("sarimaSummary")),
    h4("Forecast Table (30 days)"),
    tableOutput(ns("sarimaTable"))
  )
}

sarimaServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$sarimaPlot <- renderPlot({
      req(rv$results$sarima_res)
      plot(rv$results$sarima_res$forecast, main = "SARIMA Forecast")
    })

    output$sarimaSummary <- renderPrint({
      req(rv$results$sarima_res)
      summary(rv$results$sarima_res$model)
    })

    output$sarimaTable <- renderTable({
      req(rv$results$sarima_res)
      fc <- rv$results$sarima_res$forecast
      h  <- min(30, length(fc$mean))
      data.frame(
        Day      = 1:h,
        Forecast = round(as.numeric(fc$mean)[1:h],     2),
        Lo80     = round(as.numeric(fc$lower[1:h, 1]), 2),
        Hi80     = round(as.numeric(fc$upper[1:h, 1]), 2),
        Lo95     = round(as.numeric(fc$lower[1:h, 2]), 2),
        Hi95     = round(as.numeric(fc$upper[1:h, 2]), 2)
      )
    })
  })
}
