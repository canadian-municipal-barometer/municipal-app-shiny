library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(DT)
library(DBI)
library(duckdb)
library(readr)

muni_data <- read_csv("data/municipal-data_raw.csv")

details_ui <- function(id) {
  tagList(
    "muni_menu" = selectInput(
      inputId = NS(id, "muni_menu"),
      label = "",
      choices = muni_list,
      selectize = TRUE,
      width = "100%",
    ),
    "corr_menu" = selectInput(
      inputId = NS(id, "corr_menu"),
      label = "Correlate with...",
      choices = colnames(muni_data)[
        colnames(muni_data) %in%
          c(
            "Pct. renters",
            "Average age",
            "Median after-tax income",
            "Pop. / sq. km (log.)",
            "Population (log.)"
          )
      ],
      selectize = TRUE,
      width = "100%",
    ),
    "histogram" = plotOutput(NS(id, "histogram")),
    "corr_plot" = plotOutput(NS(id, "corr_plot")),
    "pred_plot" = plotOutput(NS(id, "pred_plot"))
  )
}

details_server <- function(id, selected_issue) {
  moduleServer(id, function(input, output, session) {
    # --------------------
    # Prediction Histogram
    output$histogram <- renderPlot({
      hist_data <- muni_data |>
        filter(
          issue == selected_issue(),
          # filter out the empty row used for the muni_menu placeholder
          Name != ""
        )

      ggplot(hist_data, aes(x = as.numeric(agree))) +
        xlab("Pct. Agreement") +
        ylab("Count") +
        geom_histogram(fill = "#0091AC") +
        theme_minimal(base_size = 16) +
        theme(
          legend.position = "none",
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
        )
    })

    # --------------------
    # Correlation Plot
    output$corr_plot <- renderPlot({
      req(input$corr_menu)

      corr_data <- muni_data |>
        filter(
          issue == selected_issue(),
        )

      ggplot(
        corr_data,
        aes(
          x = .data[[input$corr_menu]],
          y = as.numeric(agree)
        )
      ) +
        geom_point(alpha = 0.5) +
        geom_smooth(method = "lm", se = FALSE, color = "#0091AC") +
        xlab(input$corr_menu) +
        ylab("Pct. Agreement") +
        theme_minimal(base_size = 16)
    })

    return(reactive(input$muni_menu))
  })
}
