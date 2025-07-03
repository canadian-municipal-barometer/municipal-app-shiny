library(shiny)
library(htmltools)

map_ui <- function(id, issues) {
  tagList(
    selectInput(
      NS(id, "issue"),
      label = "Select an issue:",
      choices = issues,
      width = "600px"
    ),
    uiOutput(NS(id, "map"))
  )
}

map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$map <- renderUI({
      selected <- input$issue
      tags$div(
        style = "flex-grow: 1; display: flex;",
        tags$iframe(
          src = paste0(selected, ".html"), # relative to www/
          style = "width: 100%; height: 600px;"
        )
      )
    })
  })
}
