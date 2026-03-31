stationarityUI <- function(id) {
  ns <- NS(id)
  tabPanel("Stationarity",
    br(),
    uiOutput(ns("stationarityBadge")),
    br(),
    h4("ADF Test"),
    verbatimTextOutput(ns("adfOut")),
    h4("KPSS Test"),
    verbatimTextOutput(ns("kpssOut")),
    br(),
    p("Both tests must agree for a conclusive stationarity verdict.",
      "If ADF p < 0.05 and KPSS p > 0.05, the series is treated as stationary.",
      "Otherwise, first-order differencing is applied automatically before ARIMA fitting.")
  )
}

stationarityServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$stationarityBadge <- renderUI({
      req(rv$results$stat_res)
      sr  <- rv$results$stat_res
      lbl <- if (sr$is_stationary) "STATIONARY — no differencing needed" else
               "NON-STATIONARY — first-order differencing applied before ARIMA"
      cls <- if (sr$is_stationary) "alert alert-success" else "alert alert-warning"
      div(class = cls, strong(lbl))
    })

    output$adfOut  <- renderPrint({ req(rv$results$stat_res); rv$results$stat_res$adf  })
    output$kpssOut <- renderPrint({ req(rv$results$stat_res); rv$results$stat_res$kpss })
  })
}
