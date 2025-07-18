library(shiny)
library(htmltools)

map_ui <- function(id) {
  tagList(
    "map" = uiOutput(NS(id, "map"))
  )
}

map_server <- function(id, selected_issue) {
  moduleServer(id, function(input, output, session) {
    output$map <- renderUI({
      tags$div(
        style = "height: 100%;",
        tags$iframe(
          src = paste0(selected_issue(), ".html"), # relative to www/
          style = "width: 100%; height: 100%; border: none;"
        )
      )
    })
  })
}
