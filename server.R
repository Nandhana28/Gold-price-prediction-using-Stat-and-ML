server <- function(input, output, session) {

  rv <- reactiveValues(
    gold_df    = NULL,
    usd_xts    = NULL,
    data_source = NULL,
    results    = NULL
  )

  # ── Load data ──────────────────────────────
  observeEvent(input$loadData, {
    withProgress(message = "Fetching gold data...", value = 0.3, {
      loaded <- loadGoldData(input$dateRange[1], input$dateRange[2])
      incProgress(0.4, detail = "Converting...")
      rv$gold_df     <- convertToDataFrame(loaded$data)
      rv$data_source <- loaded$source
      incProgress(0.2, detail = "Loading USD index...")
      rv$usd_xts <- loadUsdIndex(input$dateRange[1], input$dateRange[2])
    })

    if (!is.null(rv$gold_df)) {
      showNotification(
        paste0("Data loaded (", rv$data_source, ") — ",
               nrow(rv$gold_df), " trading days"),
        type = "message")
    } else {
      showNotification("Failed to load data. Check internet connection.",
                       type = "error")
    }
  })

  output$dataSourceBadge <- renderUI({
    req(rv$data_source)
    cls <- switch(rv$data_source,
                  "live"        = "badge bg-success",
                  "cache"       = "badge bg-info",
                  "stale_cache" = "badge bg-warning",
                  "failed"      = "badge bg-danger",
                  "badge bg-secondary")
    tags$span(class = cls, rv$data_source)
  })

  # ── Run analysis ────────────────────────────
  observeEvent(input$runAnalysis, {
    req(rv$gold_df)
    df <- rv$gold_df
    h  <- input$forecastHorizon

    withProgress(message = "Running analysis...", value = 0, {

      incProgress(0.05, detail = "Statistics & indicators...")
      stats   <- calculateStatistics(df)
      indices <- calculateGoldIndices(df)
      signals <- interpretSignals(indices)
      quality <- assessDataQuality(df)

      incProgress(0.10, detail = "Stationarity tests...")
      stat_res <- checkStationarity(df)
      price_ts <- prepareSeriesForArima(df, stat_res)

      incProgress(0.15, detail = "Building lag features...")
      lag_df  <- buildLagFeatures(df)
      lin_mod <- buildLagLinearModel(lag_df)
      dt_mod  <- buildLagDecisionTree(lag_df)
      rf_mod  <- buildLagRandomForest(lag_df)

      incProgress(0.25, detail = "Fitting ARIMA...")
      arima_res  <- buildArimaModel(price_ts, h)

      incProgress(0.35, detail = "Fitting SARIMA...")
      sarima_res <- buildSarimaModel(price_ts, h)

      incProgress(0.45, detail = "Fitting ETS...")
      es_res     <- buildExponentialSmoothing(price_ts, h)

      incProgress(0.55, detail = "Walk-forward CV (this takes a moment)...")
      # Only run if enough data
      wf_cv <- if (length(price_ts) > 300) {
        walkForwardCV(price_ts, h = min(h, 30), initial = 200)
      } else NULL

      incProgress(0.70, detail = "Building ensemble...")
      ensemble <- buildEnsemble(arima_res, sarima_res, es_res, wf_cv)

      incProgress(0.80, detail = "Checking coverage...")
      coverage <- checkCoverage(df, arima_res, input$holdoutDays)

      incProgress(0.90, detail = "USD correlation...")
      corr_data <- buildCorrelationData(df, rv$usd_xts)

      rv$results <- list(
        stats      = stats,
        indices    = indices,
        signals    = signals,
        quality    = quality,
        stat_res   = stat_res,
        price_ts   = price_ts,
        lag_df     = lag_df,
        lin_mod    = lin_mod,
        dt_mod     = dt_mod,
        rf_mod     = rf_mod,
        arima_res  = arima_res,
        sarima_res = sarima_res,
        es_res     = es_res,
        wf_cv      = wf_cv,
        ensemble   = ensemble,
        coverage   = coverage,
        corr_data  = corr_data
      )
      incProgress(1.0, detail = "Done.")
    })
    showNotification("Analysis complete!", type = "message")
  })

  # ── Call Modules ──────────────────────────────
  dashboardServer("dashboard_mod", rv)
  statisticsServer("statistics_mod", rv)
  indicesServer("indices_mod", rv)
  signalsServer("signals_mod", rv)
  stationarityServer("stationarity_mod", rv)
  mlModelsServer("ml_models_mod", rv)
  arimaServer("arima_mod", rv)
  sarimaServer("sarima_mod", rv)
  etsServer("ets_mod", rv)
  ensembleServer("ensemble_mod", rv)
  walkforwardServer("walkforward_mod", rv)
  comparisonServer("comparison_mod", rv)
  usdCorrelationServer("usd_correlation_mod", rv)
}
