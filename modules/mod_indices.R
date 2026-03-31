indicesUI <- function(id) {
  ns <- NS(id)
  tabPanel("Market Indices",
    br(),
    h4("Technical Indicators"),
    tableOutput(ns("indicesTable")),
    br(),
    plotOutput(ns("indicesPlot"), height = "500px")
  )
}

indicesServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$indicesTable <- renderTable({
      req(rv$results$indices)
      idx <- rv$results$indices
      data.frame(Indicator = names(idx), Value = round(unlist(idx), 4))
    })

    output$indicesPlot <- renderPlot({
      req(rv$gold_df, rv$results$indices)
      df  <- rv$gold_df
      idx <- rv$results$indices
      n   <- nrow(df)
      plot_df <- tail(df, min(n, 252))

      ggplot(plot_df, aes(x = Date, y = Close)) +
        geom_line(color = "black", linewidth = 0.8) +
        geom_hline(yintercept = idx$SMA_20,  color = "#3182bd", linetype = "dashed") +
        geom_hline(yintercept = idx$SMA_50,  color = "#31a354", linetype = "dashed") +
        geom_hline(yintercept = idx$SMA_200, color = "#e6550d", linetype = "dashed") +
        geom_hline(yintercept = idx$Bollinger_Upper, color = "purple", linetype = "dotted") +
        geom_hline(yintercept = idx$Bollinger_Lower, color = "purple", linetype = "dotted") +
        annotate("text", x = max(plot_df$Date), y = idx$SMA_20,
                 label = "SMA20", hjust = 1, color = "#3182bd", size = 3.5) +
        annotate("text", x = max(plot_df$Date), y = idx$SMA_50,
                 label = "SMA50", hjust = 1, color = "#31a354", size = 3.5) +
        annotate("text", x = max(plot_df$Date), y = idx$SMA_200,
                 label = "SMA200", hjust = 1, color = "#e6550d", size = 3.5) +
        labs(title = "Gold Price with Moving Averages & Bollinger Bands",
             x = NULL, y = "USD / oz") +
        theme_minimal(base_size = 13)
    })
  })
}
