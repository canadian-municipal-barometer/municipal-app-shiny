# Note that a single entry point in the app's root directory is a requirement of
# deployment on Posit Connect Cloud.

library(shiny)

issues <- jsonlite::fromJSON("data/statements_en.json")

municipal_policy_app <- function() {
  ui <- fluidPage(
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
      map_ui("map", issues)[[1]],
    ),
    map_ui("map", issues)[[2]]
  )
  server <- function(input, output, session) {
    map_server("map")
  }
  shinyApp(ui, server) # nolint
  # profvis::profvis(runApp(shinyApp(ui, server))) #nolint
}

municipal_policy_app()
