library(shiny)
library(DT)

table_ui <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(ns("municipal_table"))
  )
}

table_server <- function(id, selected_issue) {
  moduleServer(id, function(input, output, session) {
    muni_data <- read.csv(
      "data/municipal-data_table.csv",
      check.names = FALSE
    )

    filtered_data <- reactive({
      df <- muni_data[muni_data$issue == selected_issue(), ]
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
      return(df)
    })

    output$municipal_table <- renderDT({
      datatable(
        rownames = FALSE,
        filtered_data(),
        options = list(
          dom = 'rt',
          paging = FALSE,
          lengthChange = FALSE,
          columnDefs = list(
            list(targets = c(1, 2, 3, 4, 5, 6), className = "dt-right")
          )
        ),
        filter = "top"
      ) |>
        formatRound(c('Agreement'), 1) |>
        formatStyle(
          'Agreement',
          background = styleColorBar(
            range(muni_data$agree),
            'lightblue'
          ),
          backgroundSize = '100% 90%',
          backgroundRepeat = 'no-repeat',
          backgroundPosition = 'center'
        ) |>
        formatStyle(
          columns = c(
            "Population",
            "Province",
            "% Renters",
            "Avg. Age",
            "Median After-tax Income"
          ),
          textAlign = 'right'
        )
    })
  })
}
