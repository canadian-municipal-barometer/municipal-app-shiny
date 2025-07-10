library(shiny)
library(DT)

issues_ui <- function(id) {
  tagList(
    DTOutput(NS(id, "issues_table"))
  )
}

issues_server <- function(id, issue) {
  moduleServer(id, function(input, output, session) {
    issues_data <- read.csv("data/issues-data.csv")

    output$issues_table <- renderDT({
      issues_data |>
        datatable(
          options = list(
            dom = 'rt',
            paging = FALSE,
            lengthChange = FALSE,
            headerCallback = JS(
              "function(thead, data, start, end, display) {",
              "  var tooltips = ['Agreement score for the statement.', 'Standard deviation of agreement.', 'Opinion score related to the statement.', 'The full statement text.'];",
              "  $(thead).find('th').each(function(i) {",
              "    $(this).attr('title', tooltips[i]);",
              "  });",
              "}"
            )
          ),
          filter = "top"
        )
    })
  })
}
