# `global.R` is automatically sourced by Shiny when running via RStudio "Run App"
# For explicit execution of app.R, we source it manually.
source("global.R")
source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)
