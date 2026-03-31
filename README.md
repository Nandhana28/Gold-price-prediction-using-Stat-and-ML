# ChrysaNova

ChrysaNova is a Shiny-based dashboard for Gold Price Analysis & Forecasting.
It has been structured modularly to separate UI components, server logic, and pure mathematical utilities.

## Directory Structure
- `app.R` - Entry point
- `ui.R` - Main UI layout
- `server.R` - Main Server logic
- `modules/` - Shiny modules for each specific tab
- `utils/` - Pure, testable computational R functions
- `tests/` - Unit tests
- `www/` - Static web assets

## Running the App
Open the project in RStudio and source `app.R`, or run:
```R
shiny::runApp()
```
