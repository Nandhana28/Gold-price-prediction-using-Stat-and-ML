library(shiny)
library(ggplot2)
library(forecast)
library(dplyr)
library(quantmod)
library(tseries)
library(rpart)
library(randomForest)
library(bslib)

set.seed(42)

# Source all pure utility functions into global environment
for (f in list.files("utils", pattern = "\\.R$", full.names = TRUE)) {
  source(f, local = FALSE)
}

# Source all shiny modules into global environment
for (f in list.files("modules", pattern = "\\.R$", full.names = TRUE)) {
  source(f, local = FALSE)
}
