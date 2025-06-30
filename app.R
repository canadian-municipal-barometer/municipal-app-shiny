# Note that a single entry point in the app's root directory is a requirement of
# deployment on Posit Connect Cloud.

library(shiny)

issues <- readRDS("data/issues.RDS")

municipal_policy_app <- function() {
  ui <- fluidPage(
    map_ui("map", issues)
  )
  server <- function(input, output, session) {
    map_server("map")
  }
  shinyApp(ui, server) # nolint
  # profvis::profvis(runApp(shinyApp(ui, server))) #nolint
}

municipal_policy_app()
