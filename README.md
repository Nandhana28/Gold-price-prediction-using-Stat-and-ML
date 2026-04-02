# ChrysaNova
### Gold Price Analysis & Forecasting Dashboard

ChrysaNova is an interactive R Shiny dashboard that combines **statistical time-series models** and **machine learning** to forecast Gold prices and compare model performance — all in one place, with no code required to operate.

---

## What It Does

Most forecasting tools give you one model's prediction and ask you to trust it. ChrysaNova runs **6 models simultaneously**, evaluates them honestly using walk-forward cross-validation, and combines the best ones into an ensemble forecast — giving you a result you can actually rely on.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | R |
| Framework | Shiny |
| Data Source | Yahoo Finance via `quantmod` |
| Time-Series Models | `forecast` (ARIMA, SARIMA, ETS) |
| ML Models | `rpart` (Decision Tree), `randomForest` |
| UI Components | `bslib`, `ggplot2` |
| Validation | Walk-Forward CV via `tsCV` |

---

## Quick Start

```r
# 1. Clone the repository
git clone https://github.com/your-username/Gold-price-prediction-using-Stat-and-ML.git
cd Gold-price-prediction-using-Stat-and-ML

# 2. Install dependencies
source("install_packages.R")

# 3. Launch the app
shiny::runApp()
```

> **Requires R 4.0+** and an internet connection for live data fetch.  
> If offline, the app automatically falls back to cached data.

---

## Project Structure

```
├── app.R                   # Entry point
├── ui.R                    # Main UI layout (13 tabs)
├── server.R                # Core server logic & analysis orchestration
├── global.R                # Library loading & module sourcing
├── install_packages.R      # One-time dependency installer
│
├── modules/                # One Shiny module per dashboard tab
│   ├── mod_dashboard.R     # Overview tab
│   ├── mod_statistics.R    # Descriptive statistics
│   ├── mod_indices.R       # Gold-specific indicators (RSI etc.)
│   ├── mod_signals.R       # Buy / Sell / Hold signals
│   ├── mod_stationarity.R  # ADF test results
│   ├── mod_ml_models.R     # Linear, Decision Tree, Random Forest
│   ├── mod_arima.R         # ARIMA forecast & table
│   ├── mod_sarima.R        # SARIMA forecast
│   ├── mod_ets.R           # Exponential Smoothing forecast
│   ├── mod_ensemble.R      # Weighted ensemble forecast
│   ├── mod_walkforward.R   # Walk-forward CV results
│   ├── mod_comparison.R    # All models side-by-side
│   └── mod_usd_correlation.R  # USD Index correlation
│
├── utils/                  # Pure, testable R functions (no Shiny dependency)
│   ├── data_loader.R       # Live fetch + cache fallback logic
│   ├── statistics.R        # Descriptive stats calculations
│   ├── indicators.R        # RSI, momentum, bias ratio
│   ├── signals.R           # Signal interpretation logic
│   ├── stationarity.R      # ADF test wrapper
│   ├── lag_features.R      # Feature engineering for ML models
│   ├── ts_models.R         # ARIMA, SARIMA, ETS model builders
│   ├── ensemble.R          # Inverse-RMSE weighted ensemble
│   ├── validation.R        # Walk-forward CV & coverage check
│   ├── metrics.R           # MAE, RMSE, directional accuracy
│   ├── correlation.R       # USD-Gold correlation analysis
│   └── data_quality.R      # Data cleaning & quality assessment
│
├── tests/                  # Unit tests for utility functions
│   ├── test_indicators.R
│   ├── test_lag_features.R
│   ├── test_metrics.R
│   └── test_statistics.R
│
├── data/
│   └── gold_cache.rds      # Auto-generated cache file
│
└── www/
    └── custom.css          # Dashboard styling
```

---

## Models & Approach

### Statistical Time-Series Models
| Model | What it does | Best for |
|---|---|---|
| **ARIMA** | Learns from past prices + past errors | Stable trending periods |
| **SARIMA** | ARIMA + seasonal patterns | Recurring yearly/quarterly cycles |
| **ETS** | Exponential smoothing — weights recent data more | Markets changing direction |

### Machine Learning Models (Lag Features)
All three ML models use the same 7 input features:

```
Close_lag1   →  Price 1 day ago
Close_lag2   →  Price 2 days ago
Close_lag5   →  Price 5 days ago
Close_lag10  →  Price 10 days ago
Close_lag21  →  Price 21 days ago
Return5      →  % change over last 5 days
Volume       →  Contracts traded that day
```

| Model | Strength |
|---|---|
| **Linear Regression** | Interpretable baseline |
| **Decision Tree** | Captures price thresholds & non-linear patterns |
| **Random Forest** | 100 trees averaged — highest directional accuracy |

### Ensemble
Combines ARIMA + SARIMA + ETS using **inverse-RMSE weighting** — models that performed better during walk-forward validation automatically receive a higher weight in the final forecast.

```
Weight = (1 / model_RMSE) / sum(1 / all_RMSEs)
```

---

## Data & Caching

Live Gold price data is fetched using the `GC=F` ticker from Yahoo Finance via `quantmod`.

```
Cache lifetime:  4 hours
Cache location:  data/gold_cache.rds
```

| Badge | Meaning |
|---|---|
| 🟢 Live | Fresh data from Yahoo Finance |
| 🔵 Cache | Data under 4 hours old served from disk |
| 🟡 Stale Cache | Over 4 hours old — live fetch failed, using last known data |
| 🔴 Failed | No data available |

---

## Validation — Why Walk-Forward CV

Standard in-sample accuracy is misleading — a model can memorize training data and look perfect while failing on new data. Walk-Forward Cross Validation simulates real-world forecasting:

```
Train on days 1–200  → Predict day 201
Train on days 1–201  → Predict day 202
Train on days 1–202  → Predict day 203
... and so on
```

The MAE and RMSE shown in the Walk-Forward tab are **true out-of-sample scores** — honest measures of how each model would actually perform going forward.

---

## Key Terms

| Term | Simple explanation |
|---|---|
| **ADF Test** | Checks if price data is stable enough for ARIMA. Gold prices trend upward so they fail — differencing is applied automatically |
| **Differencing** | Subtracting each day's price from the previous to flatten the trend |
| **VaR** | Worst expected loss on a bad day (95% confidence) |
| **Sharpe Ratio** | Return per unit of risk — higher is better |
| **RSI** | Momentum indicator — above 70 = overbought, below 30 = oversold |
| **%IncMSE** | Random Forest feature importance — how much error increases if that feature is removed |
| **Directional Accuracy** | % of days the model correctly predicted up or down movement |

---

## Running Tests

```r
source("tests/test_indicators.R")
source("tests/test_lag_features.R")
source("tests/test_metrics.R")
source("tests/test_statistics.R")
```

All utility functions in `utils/` are pure R functions with no Shiny dependency — making them fully unit-testable in isolation.

---

## Customisation

In `server.R`, adjust before running:

```r
forecastHorizon  # Number of days to forecast ahead (default: 30)
holdoutDays      # Days held out for coverage check (default: 60)
```

In `utils/data_loader.R`:
```r
CACHE_MAX_AGE <- 4   # Hours before re-fetching live data
```

In `utils/validation.R`:
```r
initial = 200        # Minimum days before walk-forward CV begins
```

---

## Groundbreaking Insight

> No single model is reliably best across all market conditions.  
> Random Forest consistently leads on **directional accuracy** — getting the up/down movement right more often.  
> The **Ensemble forecast** consistently produces the lowest error overall.  
> The gap between them proves that combining models is always safer than betting on one.

---

## Author

Built as part of an academic project exploring the intersection of statistical forecasting and machine learning in commodity markets.

---

*"Gold is the money of kings. Data is the intelligence of decisions."*