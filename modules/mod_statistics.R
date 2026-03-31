statisticsUI <- function(id) {
  ns <- NS(id)
  tabPanel("Statistics",
    br(),
    h4("Descriptive Statistics"),
    tableOutput(ns("statisticsTable")),
    br(),
    h4("Price Distribution"),
    plotOutput(ns("distributionPlot"), height = "450px")
  )
}

statisticsServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$statisticsTable <- renderTable({
      req(rv$results$stats)
      s <- rv$results$stats
      data.frame(Statistic = names(s), Value = round(unlist(s), 4))
    })

    output$distributionPlot <- renderPlot({
      req(rv$gold_df)
      df <- rv$gold_df
      ggplot(df, aes(x = Close)) +
        geom_histogram(bins = 35, fill = "#2c7fb8", alpha = 0.75, color = "white") +
        geom_vline(aes(xintercept = mean(Close)), color = "red",
                   linetype = "dashed", linewidth = 1) +
        geom_vline(aes(xintercept = median(Close)), color = "#31a354",
                   linetype = "dashed", linewidth = 1) +
        annotate("text", x = mean(df$Close), y = Inf, vjust = 2,
                 label = "Mean", color = "red", size = 4) +
        annotate("text", x = median(df$Close), y = Inf, vjust = 4,
                 label = "Median", color = "#31a354", size = 4) +
        labs(title = "Gold Price Distribution", x = "Price (USD/oz)", y = "Count") +
        theme_minimal(base_size = 13)
    })
  })
}
