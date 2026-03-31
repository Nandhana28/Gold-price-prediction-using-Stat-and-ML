usdCorrelationUI <- function(id) {
  ns <- NS(id)
  tabPanel("USD Correlation",
    br(),
    h4("Gold vs USD Index (DX-Y.NYB)"),
    p("Gold typically has an inverse relationship with the US Dollar.",
      "This panel shows the empirical correlation over your selected date range."),
    uiOutput(ns("correlationBadge")),
    br(),
    plotOutput(ns("correlationPlot"), height = "500px")
  )
}

usdCorrelationServer <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$correlationBadge <- renderUI({
      req(rv$results$corr_data)
      cr <- rv$results$corr_data$correlation
      if (is.null(cr)) {
        return(div(class = "alert alert-warning", "USD index data unavailable."))
      }
      strength <- if (abs(cr) > 0.7) "Strong" else if (abs(cr) > 0.4) "Moderate" else "Weak"
      direction <- if (cr < 0) "negative" else "positive"
      cls <- if (cr < -0.4) "alert-success" else if (cr > 0.4) "alert-warning" else "alert-secondary"
      div(class = paste("alert", cls),
          strong(paste0("Pearson r = ", cr, "  |  ", strength, " ", direction, " correlation")),
          br(),
          if (cr < 0) "Gold and USD are moving in opposite directions (expected inverse relationship)."
          else "Gold and USD are moving together — unusual, may reflect market stress or data anomaly.")
    })

    output$correlationPlot <- renderPlot({
      req(rv$results$corr_data)
      cd <- rv$results$corr_data
      if (is.null(cd)) return(NULL)

      # Normalise both series to 100 at start for visual comparison
      df_norm <- cd$data %>%
        mutate(Gold_norm = Gold_Close / first(Gold_Close) * 100,
               USD_norm  = USD_Close  / first(USD_Close)  * 100)

      ggplot(df_norm, aes(x = Date)) +
        geom_line(aes(y = Gold_norm, color = "Gold (GC=F)"),  linewidth = 0.8) +
        geom_line(aes(y = USD_norm,  color = "USD Index"),    linewidth = 0.8) +
        scale_color_manual(values = c("Gold (GC=F)" = "#e6a817", "USD Index" = "#3182bd")) +
        labs(title = "Gold vs USD Index (rebased to 100)",
             subtitle = paste0("Pearson r = ", cd$correlation),
             x = NULL, y = "Rebased price (start = 100)", color = NULL) +
        theme_minimal(base_size = 13)
    })
  })
}
