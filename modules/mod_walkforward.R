walkforwardUI <- function(id) {
  ns <- NS(id)
  tabPanel("Walk-Forward CV",
    br(),
    h4("Out-of-Sample Walk-Forward Validation"),
    p("Model errors measured on data the model never saw during training.",
      "These are more reliable than in-sample metrics."),
    tableOutput(ns("wfTable")),
    br(),
    h4("Confidence Interval Coverage"),
    p("A well-calibrated 80% interval should contain the actual price 80% of the time.",
      "Coverage far from the stated level means the intervals are misleading."),
    tableOutput(ns("coverageTable"))
  )
}

walkforwardServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$wfTable <- renderTable({
      req(rv$results$wf_cv)
      wf <- rv$results$wf_cv
      if (is.null(wf)) {
        data.frame(Note = "Insufficient data for walk-forward CV (need > 300 observations)")
      } else {
        data.frame(
          Model = c("ARIMA", "ETS"),
          WF_MAE  = round(c(wf$arima_mae,  wf$ets_mae),  2),
          WF_RMSE = round(c(wf$arima_rmse, wf$ets_rmse), 2),
          Type    = "Out-of-sample (walk-forward)"
        )
      }
    })

    output$coverageTable <- renderTable({
      if (is.null(rv$results$coverage)) {
        data.frame(Note = "Not enough data for coverage check (need > 110 observations)")
      } else {
        rv$results$coverage
      }
    })
  })
}
