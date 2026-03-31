etsUI <- function(id) {
  ns <- NS(id)
  tabPanel("ETS",
    br(),
    plotOutput(ns("esPlot"), height = "500px"),
    verbatimTextOutput(ns("esSummary")),
    h4("Forecast Table (30 days)"),
    tableOutput(ns("esTable"))
  )
}

etsServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$esPlot <- renderPlot({
      req(rv$results$es_res)
      plot(rv$results$es_res$forecast, main = "ETS Forecast")
    })

    output$esSummary <- renderPrint({
      req(rv$results$es_res)
      summary(rv$results$es_res$model)
    })

    output$esTable <- renderTable({
      req(rv$results$es_res)
      fc <- rv$results$es_res$forecast
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
