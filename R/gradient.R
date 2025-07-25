library(shiny)
library(htmltools)

gradientUI <- function(id) {
  ns <- NS(id)
  tagList(
    tagList(
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "gradient.css")
      ),
      div(
        id = "grad-container",
        div(class = "gradient"),
        div(
          class = "labels",
          span("0.00"),
          span("0.25"),
          span("0.50"),
          span("0.75"),
          span("1.00")
        )
      )
    )
  )
}

gradientServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # No server-side logic needed for a static gradient
  })
}
