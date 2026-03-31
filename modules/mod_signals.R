signalsUI <- function(id) {
  ns <- NS(id)
  tabPanel("Signals",
    br(),
    h4("Trading Signal Interpretation"),
    uiOutput(ns("signalPanel")),
    br(),
    h5("Note: signals are derived from technical indicators only.",
       "They do not constitute financial advice.")
  )
}

signalsServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$signalPanel <- renderUI({
      req(rv$results$signals)
      sigs <- rv$results$signals

      make_card <- function(title, sig) {
        div(class = paste0("card border-", sig$color, " mb-3"),
          div(class = "card-body",
            h5(class = "card-title", title),
            tags$span(class = paste0("badge bg-", sig$color), sig$signal),
            br(), br(),
            p(class = "card-text text-muted small", sig$note)
          )
        )
      }

      fluidRow(
        column(4, make_card("RSI (14)",       sigs$RSI)),
        column(4, make_card("MACD",           sigs$MACD)),
        column(4, make_card("Bollinger Bands",sigs$Bollinger))
      ) %>% tagList(
        fluidRow(
          column(4, make_card("Trend (SMA cross)", sigs$Trend)),
          column(4, make_card("Volume",            sigs$Volume))
        )
      )
    })
  })
}
