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
  "table" = div(
    style = "padding-top: 250px;",
    table_ui("table")
  ),
  "issue-menu" = absolutePanel(
    top = "0rem",
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
  ),
  "ui-toggle-container" = absolutePanel(
    bottom = "1rem",
    left = "50%",
    style = "transform: translateX(-50%); z-index: 10;",
    div(
      style = "
        display: flex;
        background-color: white;
      ",
      actionButton("map_btn", "Map", icon = icon("map")),
      actionButton("tbl_btn", "Table", icon = icon("table"))
    ),
  )
)

ui <- page_fillable(
  padding = 0,
  uiOutput("main_content")
)

server <- function(input, output, session) {
  output$main_content <- renderUI({
    if (curr_view() == "table") {
      return(
        tagList(
          elements["table"],
          elements["logo"],
          elements["issue-menu"],
          elements["ui-toggle-container"]
        )
      )
    }
    if (curr_view() == "map") {
      return(
        tagList(
          elements["map"],
          elements["logo"],
          elements["issue-menu"],
          elements["legend"],
          elements["ui-toggle-container"]
        )
      )
    }
  })

  # reactive to track if it is the table or the map being displayed
  curr_view <- reactiveVal("map")

  observeEvent(input$map_btn, {
    if (curr_view() == "table") {
      curr_view("map")
    }
  })

  observeEvent(input$tbl_btn, {
    if (curr_view() == "map") {
      curr_view("table")
    }
  })

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
