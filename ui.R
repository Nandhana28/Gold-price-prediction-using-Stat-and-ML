ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),

  titlePanel("ChrysaNova — Gold Price Analysis & Forecasting"),

  sidebarLayout(
    sidebarPanel(
      h4("Data Configuration"),
      dateRangeInput("dateRange", "Select Date Range:",
                     start = Sys.Date() - 730,
                     end   = Sys.Date(),
                     max   = Sys.Date()),
      actionButton("loadData",    "Load Gold Data",     class = "btn-info btn-block"),
      br(), br(),

      h4("Forecast Settings"),
      sliderInput("forecastHorizon", "Forecast Horizon (days):",
                  min = 5, max = 90, value = 30, step = 5),
      sliderInput("holdoutDays", "Holdout days (coverage test):",
                  min = 30, max = 120, value = 60, step = 10),

      hr(),
      h4("Run Analysis"),
      actionButton("runAnalysis", "Run Full Analysis",
                   class = "btn-primary btn-lg btn-block"),
      br(),
      uiOutput("dataSourceBadge"),
      width = 3
    ),

    mainPanel(
      tabsetPanel(
        dashboardUI("dashboard_mod"),
        statisticsUI("statistics_mod"),
        indicesUI("indices_mod"),
        signalsUI("signals_mod"),
        stationarityUI("stationarity_mod"),
        mlModelsUI("ml_models_mod"),
        arimaUI("arima_mod"),
        sarimaUI("sarima_mod"),
        etsUI("ets_mod"),
        ensembleUI("ensemble_mod"),
        walkforwardUI("walkforward_mod"),
        comparisonUI("comparison_mod"),
        usdCorrelationUI("usd_correlation_mod")
      ),
      width = 9
    )
  )
)
