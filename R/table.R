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
        "agree",
        "opinion",
        "Population",
        "Pop. / sq. km",
        "Pct. renters",
        "Average age",
        "Median after-tax income"
      )]
      colnames(df) <- c(
        "Municipality",
        "Province",
        "Pct. agreement",
        "Pct. have an opinion",
        "Population",
        "Pop. / sq. km",
        "% Renters",
        "Avg. age",
        "Median after-tax income"
      )
      return(df)
    })

    output$municipal_table <- renderDT({
      datatable(
        rownames = FALSE,
        filtered_data(),
        width = '100%',
        options = list(
          dom = 'rt',
          paging = FALSE,
          lengthChange = FALSE,
          scrollY = "calc(100vh - 450px)",
          scrollCollapse = TRUE,
          columnDefs = list(
            list(targets = c(1, 2, 3, 4, 5, 6), className = "dt-right")
          )
        ),
        filter = "top"
      ) |>
        formatRound(c("Pct. agreement"), 1) |>
        formatStyle(
          "Pct. agreement",
          background = styleColorBar(
            range(muni_data$agree),
            "lightblue"
          ),
          backgroundSize = "100% 90%",
          backgroundRepeat = "no-repeat",
          backgroundPosition = "center"
        ) |>
        formatStyle(
          "Pct. have an opinion",
          background = styleColorBar(
            range(muni_data$opinion),
            "lightblue"
          ),
          backgroundSize = "100% 90%",
          backgroundRepeat = "no-repeat",
          backgroundPosition = "center"
        ) |>
        formatStyle(
          columns = c(
            "Population",
            "Province",
            "% Renters",
            "Avg. age",
            "Median after-tax income"
          ),
          textAlign = "right"
        )
    })
  })
}
