library(shiny)
library(DT)

table_ui <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(ns("municipal_table"))
  )
}

table_server <- function(id, issue) {
  moduleServer(id, function(input, output, session) {
    muni_data <- read.csv(
      "data/municipal-data_table.csv",
      check.names = FALSE
    )

    filtered_data <- reactive({
      df <- muni_data[muni_data$issue == issue(), ]
      df <- df[, c(
        "Name",
        "Province",
        "prediction",
        "Population",
        "Pct. Renters",
        "Average Age",
        "Median After-tax income"
      )]
      colnames(df) <- c(
        "Municipality",
        "Province",
        "Agreement",
        "Population",
        "% Renters",
        "Avg. Age",
        "Median After-tax Income"
      )
      df
    })

    output$municipal_table <- renderDT({
      datatable(
        rownames = FALSE,
        filtered_data(),
        options = list(
          dom = 'rt',
          paging = FALSE,
          lengthChange = FALSE
        ),
        filter = "top"
      ) |>
        formatRound(c('Agreement'), 1) |>
        formatStyle(
          'Agreement',
          background = styleColorBar(
            range(muni_data$prediction),
            'lightblue'
          ),
          backgroundSize = '100% 90%',
          backgroundRepeat = 'no-repeat',
          backgroundPosition = 'center'
        ) |>
        formatStyle(
          columns = c(
            "Population",
            "% Renters",
            "Avg. Age",
            "Median After-tax Income"
          ),
          textAlign = 'right'
        )
    })
  })
}
