dashboardUI <- function(id) {
  ns <- NS(id)
  tabPanel("Dashboard",
    br(),
    uiOutput(ns("summaryCards")),
    br(),
    h4("Data Quality Report"),
    tableOutput(ns("dataQualityTable")),
    br(),
    plotOutput(ns("priceTimeSeries"), height = "400px")
  )
}

dashboardServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$summaryCards <- renderUI({
      req(rv$gold_df)
      df <- rv$gold_df
      cur  <- round(tail(df$Close, 1), 2)
      hi   <- round(max(df$High),  2)
      lo   <- round(min(df$Low),   2)
      ret  <- round(((tail(df$Close,1) - df$Close[1]) / df$Close[1]) * 100, 2)
      ret_col <- if (ret >= 0) "success" else "danger"

      fluidRow(
        column(3, div(class = paste0("card border-primary mb-3"),
          div(class = "card-body",
            h6(class = "card-subtitle text-muted", "Current Price"),
            h4(class = "card-title text-primary", paste0("$", cur, " / oz"))))),
        column(3, div(class = "card border-success mb-3",
          div(class = "card-body",
            h6(class = "card-subtitle text-muted", "Period High"),
            h4(class = "card-title text-success", paste0("$", hi))))),
        column(3, div(class = "card border-danger mb-3",
          div(class = "card-body",
            h6(class = "card-subtitle text-muted", "Period Low"),
            h4(class = "card-title text-danger", paste0("$", lo))))),
        column(3, div(class = paste0("card border-", ret_col, " mb-3"),
          div(class = "card-body",
            h6(class = "card-subtitle text-muted", "Period Return"),
            h4(class = paste0("card-title text-", ret_col),
               paste0(ifelse(ret >= 0, "+", ""), ret, "%")))))
      )
    })

    output$dataQualityTable <- renderTable({ rv$results$quality })

    output$priceTimeSeries <- renderPlot({
      req(rv$gold_df)
      df <- rv$gold_df
      ggplot(df, aes(x = Date, y = Close)) +
        geom_line(color = "#2c7fb8", linewidth = 0.7) +
        labs(title = "Gold Close Price", x = NULL, y = "USD / oz") +
        theme_minimal(base_size = 13)
    })
  })
}
