library(shiny)
library(htmltools)

map_ui <- function(id) {
  tagList(
    uiOutput(NS(id, "map"))
  )
}

map_server <- function(id, issue) {
  moduleServer(id, function(input, output, session) {
    output$map <- renderUI({
      tags$div(
        style = "flex-grow: 1; display: flex;",
        tags$iframe(
          src = paste0(issue(), ".html"), # relative to www/
          style = "width: 100%; height: 600px;"
        )
      )
    })
  })
}
