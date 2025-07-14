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
          rownames = FALSE,
          options = list(
            dom = 'rt',
            paging = FALSE,
            lengthChange = FALSE,
            headerCallback = JS(
              "function(thead, data, start, end, display) {",
              "  var tooltips = ['Full statement text', 'Proportion that agree', 'Proportion that have an opinion', 'Standard deviation of municipal agreement proportions'];",
              "  $(thead).find('th').each(function(i) {",
              "    if (tooltips[i] && $(this).find('.tooltip-icon').length === 0) {",
              "      var icon = $('<span class=\"tooltip-icon\"> &#9432;</span>');",
              "      $(this).append(icon);",
              "      $(this).find('span.tooltip-icon').attr('title', tooltips[i]);",
              "    }",
              "  });",
              "}"
            )
          ),
          filter = "top"
        ) |>
        formatStyle(
          columns = c("Agreement", "Opinion", "Polarization"),
          "text-align" = "right"
        )
    })
  })
}
