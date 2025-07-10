# Note that a single entry point in the app's root directory is a requirement of
# deployment on Posit Connect Cloud.

library(shiny)
library(bslib)

issues <- jsonlite::fromJSON("data/statements_en.json")

municipal_policy_app <- function() {
  ui <- fluidPage(
    includeCSS("www/style.css"),
    div(
      id = "header",
      style = "
          display: flex;
          align-items: center;
          justify-content: space-around;
          height: 150px;
        ",
      titlePanel("Municipal-level Policy Agreement"),
      a(
        img(
          src = "https://www.cmb-bmc.ca/wp-content/uploads/2024/09/logo-bmc-cmb.svg" # nolint
        ),
        href = "https://www.cmb-bmc.ca/"
      ),
    ),
    div(
      style = "
          display: flex;
          justify-content: center;
        ",
      selectInput(
        "issue",
        label = "Select an issue:",
        choices = issues,
        width = "600px"
      ),
    ),
    navset_tab(
      nav_panel(
        "Map",
        map_ui("map")[[1]]
      ),
      nav_panel("Municipalities", "TABLE HERE"),
      nav_panel("Issues", "TABLE HERE")
    ),
  )
  server <- function(input, output, session) {
    map_server(
      "map",
      issue = reactive({
        input$issue
      })
    )
  }
  shinyApp(ui, server) # nolint
  # profvis::profvis(runApp(shinyApp(ui, server))) #nolint
}

municipal_policy_app()
