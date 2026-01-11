library(shiny)
library(ggplot2)
library(forecast)
library(dplyr)
library(quantmod)
library(tseries)

# Load live gold data from Yahoo Finance
loadGoldData <- function(startDate = Sys.Date() - 365, endDate = Sys.Date()) {
  tryCatch({
    suppressWarnings({
      data <- getSymbols("GC=F", src = "yahoo", from = startDate, to = endDate, auto.assign = FALSE)
      return(data)
    })
  }, error = function(e) {
    return(NULL)
  })
}

# Convert xts to dataframe
convertToDataFrame <- function(xtsData) {
  if (is.null(xtsData)) return(NULL)
  
  tryCatch({
    df <- data.frame(
      Date = index(xtsData),
      Open = as.numeric(xtsData[, 1]),
      High = as.numeric(xtsData[, 2]),
      Low = as.numeric(xtsData[, 3]),
      Close = as.numeric(xtsData[, 4]),
      Volume = as.numeric(xtsData[, 5]),
      Adjusted = as.numeric(xtsData[, 6])
    )
    
    df <- df[complete.cases(df), ]
    rownames(df) <- NULL
    return(df)
  }, error = function(e) {
    return(NULL)
  })
}

# Calculate Gold Market Indices
calculateGoldIndices <- function(data) {
  tryCatch({
    indices <- list()
    
    # 1. Simple Moving Averages
    indices$SMA20 <- mean(tail(data$Close, 20), na.rm = TRUE)
    indices$SMA50 <- mean(tail(data$Close, 50), na.rm = TRUE)
    indices$SMA200 <- mean(tail(data$Close, 200), na.rm = TRUE)
    
    # 2. Exponential Moving Average
    indices$EMA12 <- tail(data$Close, 1) * 0.15 + indices$SMA20 * 0.85
    
    # 3. Relative Strength Index (RSI)
    deltas <- diff(data$Close)
    gains <- mean(deltas[deltas > 0], na.rm = TRUE)
    losses <- abs(mean(deltas[deltas < 0], na.rm = TRUE))
    rs <- gains / (losses + 0.0001)
    indices$RSI <- 100 - (100 / (1 + rs))
    
    # 4. Bollinger Bands
    sma <- mean(tail(data$Close, 20), na.rm = TRUE)
    std <- sd(tail(data$Close, 20), na.rm = TRUE)
    indices$BollingerUpper <- sma + (2 * std)
    indices$BollingerLower <- sma - (2 * std)
    indices$BollingerMiddle <- sma
    
    # 5. MACD (Moving Average Convergence Divergence)
    ema12 <- mean(tail(data$Close, 12), na.rm = TRUE)
    ema26 <- mean(tail(data$Close, 26), na.rm = TRUE)
    indices$MACD <- ema12 - ema26
    indices$Signal <- mean(c(ema12, ema26), na.rm = TRUE)
    
    # 6. Volatility (Standard Deviation)
    indices$Volatility <- sd(data$Close, na.rm = TRUE)
    indices$VolatilityPercent <- (indices$Volatility / mean(data$Close, na.rm = TRUE)) * 100
    
    # 7. Price Range
    indices$DailyRange <- tail(data$High, 1) - tail(data$Low, 1)
    indices$YearlyHigh <- max(data$High, na.rm = TRUE)
    indices$YearlyLow <- min(data$Low, na.rm = TRUE)
    
    # 8. Volume Analysis
    indices$AvgVolume <- mean(data$Volume, na.rm = TRUE)
    indices$CurrentVolume <- tail(data$Volume, 1)
    indices$VolumeRatio <- indices$CurrentVolume / indices$AvgVolume
    
    # 9. Price Momentum
    indices$Momentum <- tail(data$Close, 1) - data$Close[max(1, nrow(data) - 10)]
    indices$MomentumPercent <- (indices$Momentum / data$Close[max(1, nrow(data) - 10)]) * 100
    
    # 10. Support & Resistance
    indices$Support <- min(tail(data$Low, 20), na.rm = TRUE)
    indices$Resistance <- max(tail(data$High, 20), na.rm = TRUE)
    
    return(indices)
  }, error = function(e) {
    return(NULL)
  })
}

# Linear regression model
buildLinearModel <- function(data) {
  tryCatch({
    model <- lm(Close ~ Open + High + Low, data = data)
    return(model)
  }, error = function(e) {
    return(NULL)
  })
}

# Decision Tree Model (lightweight ML)
buildDecisionTreeModel <- function(data, forecastHorizon = 30) {
  tryCatch({
    if (!require("rpart", quietly = TRUE)) {
      install.packages("rpart", repos = "http://cran.r-project.org")
      library(rpart)
    }
    
    model <- rpart(Close ~ Open + High + Low + Volume, data = data, method = "anova")
    predicted <- predict(model, data)
    
    return(list(model = model, predicted = predicted))
  }, error = function(e) {
    return(NULL)
  })
}

# Random Forest Model (lightweight ML)
buildRandomForestModel <- function(data, forecastHorizon = 30) {
  tryCatch({
    if (!require("randomForest", quietly = TRUE)) {
      install.packages("randomForest", repos = "http://cran.r-project.org")
      library(randomForest)
    }
    
    model <- randomForest(Close ~ Open + High + Low + Volume, data = data, ntree = 50, maxnodes = 10)
    predicted <- predict(model, data)
    
    return(list(model = model, predicted = predicted))
  }, error = function(e) {
    return(NULL)
  })
}

# ARIMA model
buildArimaModel <- function(data, forecastHorizon = 30) {
  tryCatch({
    priceTs <- ts(data$Close, frequency = 12)
    arimaModel <- auto.arima(priceTs, stepwise = TRUE, trace = FALSE)
    forecastResult <- forecast(arimaModel, h = forecastHorizon)
    return(list(model = arimaModel, forecast = forecastResult))
  }, error = function(e) {
    return(NULL)
  })
}

# SARIMA model
buildSarimaModel <- function(data, forecastHorizon = 30) {
  tryCatch({
    priceTs <- ts(data$Close, frequency = 12)
    sarimaModel <- auto.arima(priceTs, seasonal = TRUE, stepwise = TRUE, trace = FALSE)
    forecastResult <- forecast(sarimaModel, h = forecastHorizon)
    return(list(model = sarimaModel, forecast = forecastResult))
  }, error = function(e) {
    return(NULL)
  })
}

# Exponential Smoothing
buildExponentialSmoothing <- function(data, forecastHorizon = 30) {
  tryCatch({
    priceTs <- ts(data$Close, frequency = 12)
    esModel <- ets(priceTs)
    forecastResult <- forecast(esModel, h = forecastHorizon)
    return(list(model = esModel, forecast = forecastResult))
  }, error = function(e) {
    return(NULL)
  })
}

# Stationarity test (ADF test)
performAdfTest <- function(data) {
  tryCatch({
    suppressWarnings({
      adfTest <- adf.test(data$Close)
      return(adfTest)
    })
  }, error = function(e) {
    return(NULL)
  })
}

# KPSS test
performKpssTest <- function(data) {
  tryCatch({
    suppressWarnings({
      kpssTest <- kpss.test(data$Close)
      return(kpssTest)
    })
  }, error = function(e) {
    return(NULL)
  })
}

# Calculate comprehensive statistics
calculateStatistics <- function(data) {
  tryCatch({
    stats <- list(
      Mean = mean(data$Close, na.rm = TRUE),
      Median = median(data$Close, na.rm = TRUE),
      StdDev = sd(data$Close, na.rm = TRUE),
      Min = min(data$Close, na.rm = TRUE),
      Max = max(data$Close, na.rm = TRUE),
      Range = max(data$Close, na.rm = TRUE) - min(data$Close, na.rm = TRUE),
      Q1 = quantile(data$Close, 0.25, na.rm = TRUE),
      Q3 = quantile(data$Close, 0.75, na.rm = TRUE),
      IQR = IQR(data$Close, na.rm = TRUE),
      Skewness = (mean(data$Close, na.rm = TRUE) - median(data$Close, na.rm = TRUE)) / sd(data$Close, na.rm = TRUE),
      CV = (sd(data$Close, na.rm = TRUE) / mean(data$Close, na.rm = TRUE)) * 100,
      DailyReturn = ((tail(data$Close, 1) - data$Close[1]) / data$Close[1]) * 100,
      AvgDailyChange = mean(diff(data$Close), na.rm = TRUE),
      AvgDailyChangePercent = mean((diff(data$Close) / head(data$Close, -1)) * 100, na.rm = TRUE)
    )
    return(stats)
  }, error = function(e) {
    return(NULL)
  })
}

# UI
ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  
  titlePanel("Gold Price Prediction & Analysis Dashboard - Advanced"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Data Configuration"),
      
      dateRangeInput("dateRange",
                     "Select Date Range:",
                     start = Sys.Date() - 365,
                     end = Sys.Date(),
                     max = Sys.Date()),
      
      actionButton("loadData", "Load Live Gold Data", class = "btn-info"),
      
      hr(),
      
      h4("Forecast Settings"),
      
      sliderInput("forecastHorizon", 
                  "Forecast Horizon (days):", 
                  min = 5, max = 90, value = 30, step = 5),
      
      hr(),
      
      h4("Analysis Sections"),
      
      checkboxInput("showStats", "Statistics", value = TRUE),
      checkboxInput("showIndices", "Market Indices", value = TRUE),
      checkboxInput("showStationarity", "Stationarity Tests", value = TRUE),
      checkboxInput("showLinear", "Linear Regression", value = TRUE),
      checkboxInput("showML", "ML Models (Tree & Forest)", value = TRUE),
      checkboxInput("showForecasts", "Time Series Forecasts", value = TRUE),
      checkboxInput("showComparison", "Model Comparison", value = TRUE),
      
      hr(),
      
      actionButton("runAnalysis", "Run Full Analysis", class = "btn-primary btn-lg"),
      
      width = 3
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Dashboard",
                 h3("Gold Price Analysis Dashboard"),
                 p("Real-time gold price data with advanced ML models and market indices."),
                 br(),
                 div(class = "alert alert-info",
                     h5("Features:"),
                     tags$ul(
                       tags$li("Live gold price data (GC=F)"),
                       tags$li("Comprehensive statistics & market indices"),
                       tags$li("ML Models: Linear, Decision Tree, Random Forest"),
                       tags$li("Time Series: ARIMA, SARIMA, Exponential Smoothing"),
                       tags$li("Stationarity testing (ADF, KPSS)"),
                       tags$li("Model comparison with all predictions")
                     )
                 ),
                 br(),
                 h4("Data Summary"),
                 tableOutput("dataSummary")
        ),
        
        tabPanel("Statistics",
                 h3("Comprehensive Price Statistics"),
                 tableOutput("statisticsTable"),
                 br(),
                 h4("Distribution Analysis"),
                 plotOutput("distributionPlot", height = "500px")
        ),
        
        tabPanel("Market Indices",
                 h3("Gold Market Indices"),
                 tableOutput("indicesTable"),
                 br(),
                 h4("Technical Indicators"),
                 plotOutput("indicesPlot", height = "600px")
        ),
        
        tabPanel("Data Overview",
                 h3("Gold Price Data"),
                 plotOutput("priceTimeSeries", height = "500px"),
                 br(),
                 h4("Detailed Price Data (Last 20 Records)"),
                 tableOutput("detailedDataTable")
        ),
        
        tabPanel("Stationarity",
                 h3("Stationarity Tests"),
                 h4("Augmented Dickey-Fuller (ADF) Test"),
                 verbatimTextOutput("adfTestOutput"),
                 br(),
                 h4("KPSS Test"),
                 verbatimTextOutput("kpssTestOutput"),
                 br(),
                 p("These tests determine if the time series is stationary (required for ARIMA).")
        ),
        
        tabPanel("Linear Model",
                 h3("Linear Regression Analysis"),
                 verbatimTextOutput("linearSummary"),
                 br(),
                 plotOutput("linearPlot", height = "600px"),
                 br(),
                 verbatimTextOutput("linearMetrics")
        ),
        
        tabPanel("ML Models",
                 h3("Machine Learning Models"),
                 h4("Decision Tree Model"),
                 plotOutput("dtreePlot", height = "500px"),
                 br(),
                 verbatimTextOutput("dtreeMetrics"),
                 br(),
                 h4("Random Forest Model"),
                 verbatimTextOutput("rfMetrics")
        ),
        
        tabPanel("ARIMA",
                 h3("ARIMA Model Forecast"),
                 plotOutput("arimaPlot", height = "600px"),
                 br(),
                 verbatimTextOutput("arimaSummary"),
                 br(),
                 h4("Forecast Table (First 15 Days)"),
                 tableOutput("arimaForecastTable")
        ),
        
        tabPanel("SARIMA",
                 h3("SARIMA Model Forecast"),
                 plotOutput("sarimaPlot", height = "600px"),
                 br(),
                 verbatimTextOutput("sarimaSummary"),
                 br(),
                 h4("Forecast Table (First 15 Days)"),
                 tableOutput("sarimaForecastTable")
        ),
        
        tabPanel("Exponential Smoothing",
                 h3("Exponential Smoothing Forecast"),
                 plotOutput("esPlot", height = "600px"),
                 br(),
                 verbatimTextOutput("esSummary"),
                 br(),
                 h4("Forecast Table (First 15 Days)"),
                 tableOutput("esForecastTable")
        ),
        
        tabPanel("Model Comparison",
                 h3("All Models Comparison"),
                 plotOutput("comparisonPlot", height = "700px"),
                 br(),
                 h4("Model Performance Metrics"),
                 tableOutput("modelMetricsTable"),
                 br(),
                 h4("All Model Predictions (Last 20 Days)"),
                 tableOutput("allPredictionsTable")
        )
      ),
      
      width = 9
    )
  )
)
