# Note that a single entry point in the app's root directory is a requirement of
# deployment on Posit Connect Cloud.

library(shiny)
library(bslib)
library(DT)

issues <- jsonlite::fromJSON("data/statements_en.json")

elements <- tagList(
  "logo" = absolutePanel(
    top = "1rem",
    right = "1rem",
    width = "100px",
    style = "z-index: 10;",
    a(
      img(
        src = "main-logo-no-text.png",
        style = "width: 100%; height: auto;"
      ),
      href = "https://www.cmb-bmc.ca/"
    )
  ),
  "map" = div(
    style = "height: 100vh;",
    map_ui("map")["map"]
  ),
  "issue-menu" = absolutePanel(
    top = "1rem",
    left = "50%",
    width = "600px",
    style = "transform: translateX(-50%); z-index: 10;",
    div(
      style = "
          display: flex;
          flex-direction: column;
          align-items: center;
        ",
      p(
        style = "
            position: relative;
            bottom: -37px;
            width: fit-content;
            border-radius: 7px;
            padding: 5px 10px;
            text-align: center;
            background-color: white;
          ",
        "Select an issue:"
      ),
    ),
    selectInput(
      "selected_issue",
      label = "",
      choices = issues,
      width = "100%"
    )
  ),
  "legend" = absolutePanel(
    bottom = "1rem",
    left = "1rem",
    card(
      gradientUI("grad")
    )
  )
)

ui <- page_fillable(
  padding = 0,
  elements["map"],
  elements["logo"],
  elements["issue-menu"],
  elements["legend"]
)
server <- function(input, output, session) {
  map_server(
    "map",
    selected_issue = reactive({
      input$selected_issue
    })
  )
  issues_server("issues")
  table_server(
    "table",
    selected_issue = reactive({
      input$selected_issue
    })
  )
  selected_muni <- details_server(
    "details",
    selected_issue = reactive({
      input$selected_issue
    })
  )
  natl_comp_server(
    "natl_comp",
    selected_issue = reactive({
      input$selected_issue
    }),
    selected_muni = selected_muni
  )
  gradientServer("grad")
}
shinyApp(ui, server) # nolint
