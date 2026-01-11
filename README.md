# Gold Price Prediction & Analysis Dashboard - Advanced

## Objective
Build a comprehensive, interactive dashboard for real-time gold price analysis and forecasting using advanced time series methods, machine learning algorithms, and market indices. The system provides live data from Yahoo Finance and implements multiple forecasting models with detailed statistical analysis.

## Key Features

### Data Source
- **Live Gold Price Data**: Real-time data from Yahoo Finance (GC=F futures contract)
- **Customizable Date Range**: Select any historical period for analysis
- **Automatic Updates**: Fresh data on each analysis run

### Comprehensive Statistics
- **Descriptive Statistics**: Mean, Median, Std Dev, Min, Max, Range, Quartiles, IQR
- **Distribution Analysis**: Skewness, Coefficient of Variation, Histograms
- **Return Analysis**: Total Return %, Daily Average Change, Daily Change %
- **Visual Distribution**: Histogram with Mean and Median lines

### Gold Market Indices (22 Technical Indicators)
1. **Moving Averages**: SMA 20, SMA 50, SMA 200, EMA 12
2. **Momentum Indicators**: RSI (Relative Strength Index), MACD, Signal Line
3. **Volatility Measures**: Standard Deviation, Volatility %, Bollinger Bands (Upper/Middle/Lower)
4. **Price Levels**: Daily Range, Yearly High, Yearly Low, Support, Resistance
5. **Volume Analysis**: Average Volume, Current Volume, Volume Ratio
6. **Price Momentum**: Momentum, Momentum %
7. **Technical Plots**: Price with Moving Averages and Bollinger Bands

### Statistical Analysis
- **Stationarity Testing**: Augmented Dickey-Fuller (ADF) and KPSS tests
- **Autocorrelation Analysis**: ACF and PACF plots for parameter identification
- **Hypothesis Testing**: Proper statistical conclusions with p-values

### Forecasting Models

#### Time Series Models
1. **ARIMA**: AutoRegressive Integrated Moving Average
2. **SARIMA**: Seasonal ARIMA for capturing seasonal patterns
3. **Exponential Smoothing**: ETS (Error-Trend-Seasonal) models

#### Machine Learning Models (Lightweight)
1. **Linear Regression**: Baseline model using Open, High, Low prices
2. **Decision Tree**: CART algorithm with automatic pruning
3. **Random Forest**: Ensemble of 50 trees with max 10 nodes per tree

### Model Comparison
- Side-by-side forecast visualization
- Performance metrics (MAE, RMSE) for all models
- All model predictions in detailed table format
- Confidence intervals (80% and 95%)
- Residual diagnostics

### Data Presentation
- **Detailed Tables**: Proper date formatting (YYYY-MM-DD)
- **Interactive Tables**: Hover over rows to see full details
- **Last 20 Records**: Shows Open, High, Low, Close, Volume with proper formatting
- **All Predictions**: Compare all model outputs side-by-side

## Technologies & Libraries

### Core Libraries (Optimized)
- **shiny**: Interactive web dashboard framework
- **ggplot2**: Advanced data visualization
- **forecast**: ARIMA, SARIMA, and exponential smoothing models
- **dplyr**: Data manipulation and transformation
- **quantmod**: Live financial data retrieval from Yahoo Finance
- **tseries**: Time series analysis and stationarity tests
- **rpart**: Decision Tree models
- **randomForest**: Random Forest ensemble models

### Language
- R 4.5.2+

### Storage Optimization
- Minimal package footprint
- Only essential packages installed
- Lightweight ML models for fast computation

## Project Structure

```
├── app.R                    # Main Shiny application (UI + Server)
├── README.md               # This file
├── Gold dataset.xlsx       # Historical gold price data
└── .git/                   # Version control
```

## How to Run

### Prerequisites
1. R 4.5.2 or higher installed
2. Required packages (automatically installed on first run)

### Starting the Dashboard
```r
# In R console or RStudio
shiny::runApp('app.R')
```

The dashboard will be available at: `http://127.0.0.1:3838`

## Dashboard Tabs

1. **Dashboard**: Overview and data summary
2. **Statistics**: Comprehensive price statistics and distribution analysis
3. **Market Indices**: 22 technical indicators with visualization
4. **Data Overview**: Time series plot and detailed price data (last 20 records)
5. **Stationarity**: ADF and KPSS test results
6. **Linear Model**: Linear regression analysis with diagnostics
7. **ML Models**: Decision Tree and Random Forest performance
8. **ARIMA**: ARIMA model forecast and summary
9. **SARIMA**: SARIMA model forecast and summary
10. **Exponential Smoothing**: ETS model forecast
11. **Model Comparison**: All models side-by-side with performance metrics and predictions table

## Usage Guide

### Step 1: Load Data
- Set your desired date range in the sidebar
- Click "Load Live Gold Data" button
- Wait for data to load from Yahoo Finance

### Step 2: Configure Analysis
- Adjust forecast horizon (5-90 days)
- Toggle analysis sections on/off
- Select which statistics and indices to display

### Step 3: Run Analysis
- Click "Run Full Analysis" button
- Wait for all calculations to complete
- Explore results in different tabs

### Step 4: Interpret Results
- Check stationarity tests to validate ARIMA assumptions
- Review market indices for technical signals
- Compare model forecasts in the Comparison tab
- Examine detailed predictions table for all models
- Use statistics for investment decision-making

## Statistical Methods Explained

### Stationarity Tests
- **ADF Test**: Tests if series has unit root (non-stationary)
- **KPSS Test**: Tests if series is stationary around a trend
- Both tests help determine differencing requirements for ARIMA

### Market Indices

#### Moving Averages
- **SMA 20/50/200**: Simple moving averages for trend identification
- **EMA 12**: Exponential moving average for recent price emphasis

#### Momentum Indicators
- **RSI**: Measures overbought (>70) and oversold (<30) conditions
- **MACD**: Identifies trend changes and momentum
- **Signal Line**: MACD trigger line for buy/sell signals

#### Volatility
- **Bollinger Bands**: Price volatility and support/resistance levels
- **Standard Deviation**: Measure of price dispersion

#### Volume Analysis
- **Volume Ratio**: Current volume vs average volume
- **Average Volume**: Baseline for volume comparison

### ARIMA(p,d,q)
- **p**: AutoRegressive order (ACF decay)
- **d**: Differencing order (stationarity)
- **q**: Moving Average order (PACF decay)

### SARIMA(p,d,q)(P,D,Q)m
- Extends ARIMA with seasonal components
- Captures both trend and seasonal patterns
- m = seasonal period (12 for monthly data)

### Machine Learning Models
- **Linear Regression**: Simple baseline with interpretable coefficients
- **Decision Tree**: Non-parametric model capturing non-linear relationships
- **Random Forest**: Ensemble method reducing overfitting

## Model Performance Metrics

- **MAE (Mean Absolute Error)**: Average absolute prediction error
- **RMSE (Root Mean Squared Error)**: Penalizes larger errors more heavily
- **R² Value**: Proportion of variance explained by the model
- **Residual Diagnostics**: Checks for autocorrelation and normality

## Key Insights from Analysis

1. **Technical Indicators**: RSI, MACD, and Bollinger Bands provide trading signals
2. **Seasonal Patterns**: Gold prices show seasonal trends
3. **Model Comparison**: Different models excel in different market conditions
4. **Forecast Confidence**: Wider intervals indicate higher uncertainty
5. **Volume Analysis**: Volume ratio indicates market strength

## Data Quality

- **Date Format**: YYYY-MM-DD for consistency
- **Missing Values**: Automatically removed during preprocessing
- **Volume Formatting**: Displayed with thousand separators
- **Price Precision**: 2 decimal places for USD/oz

## Future Enhancements

- Advanced ML models (XGBoost, Neural Networks)
- GARCH models for volatility forecasting
- Multiple commodity comparison
- Portfolio optimization tools
- Real-time alerts and notifications
- Export functionality for reports
- API integration for live trading

## Notes

- Data is fetched from Yahoo Finance in real-time
- Analysis requires at least 30 days of historical data
- Forecasts are probabilistic and should be used with caution
- Past performance does not guarantee future results
- Always validate results with domain expertise
- Market indices are calculated from available data

## Performance

- **Lightweight ML Models**: Fast computation with minimal memory usage
- **Optimized Package Set**: Only essential packages installed
- **Efficient Data Processing**: Handles 1+ year of daily data smoothly
- **Interactive Dashboard**: Real-time updates and responsive UI