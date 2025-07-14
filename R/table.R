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
    municipal_data <- read.csv(
      "data/municipal-data-final.csv",
      check.names = FALSE
    )

    filtered_data <- reactive({
      df <- municipal_data[municipal_data$issue == issue(), ]
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
        formatRound(c('Agreement'), 3) |>
        formatStyle(
          'Agreement',
          background = styleColorBar(
            range(municipal_data$prediction),
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
