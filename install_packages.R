packages <- c("shiny", "ggplot2", "forecast", "dplyr", "quantmod", "tseries", "rpart", "randomForest", "bslib")

for (pkg in packages) {
  if (!require(pkg, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, repos = "http://cran.r-project.org")
  } else {
    cat(pkg, "already installed\n")
  }
}

cat("\nAll packages installed successfully!\n")
