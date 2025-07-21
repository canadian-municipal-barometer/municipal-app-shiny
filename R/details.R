library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(DT)
library(DBI)
library(duckdb)
library(readr)

muni_list <- readRDS("data/muni-list.RDS")
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
        !(colnames(muni_data) %in%
          c(
            "prediction",
            "Name",
            "Province",
            "issue",
            "opinion",
            "csd",
            "Pop. / sq. km",
            "Population"
          ))
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

      ggplot(hist_data, aes(x = as.numeric(prediction))) +
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
          y = as.numeric(prediction)
        )
      ) +
        geom_point(alpha = 0.5) +
        geom_smooth(method = "lm", se = FALSE, color = "#0091AC") +
        xlab(input$corr_menu) +
        ylab("Pct. Agreement") +
        theme_minimal(base_size = 16)
    })

    # --------------------
    # Data for pred plot
    pred_data <- reactive({
      req(input$muni_menu, selected_issue())

      con <- dbConnect(
        duckdb::duckdb(),
        dbdir = "data/natl_comp_plot_data.duckdb",
        read_only = TRUE
      )
      on.exit(dbDisconnect(con, shutdown = TRUE))

      dbGetQuery(
        con,
        "SELECT * FROM plot_data WHERE muni = ? AND issue = ?",
        params = list(input$muni_menu, selected_issue())
      )
    })

    # --------------------
    # pred bar plot
    output$pred_plot <- renderPlot({
      req(pred_data())

      ggplot(pred_data(), aes(x = pred_type, y = pred, fill = group)) +
        geom_col(
          position = "dodge"
        ) +
        geom_text(
          aes(label = paste0(round(pred, 2), "%")),
          position = position_dodge(width = 0.9),
          vjust = -0.5,
          size = 5
        ) +
        labs(title = "Pct. Agreement and Pct. Have an opinion") +
        ylab("Pct.") +
        scale_fill_manual(
          values = c("Municipality" = "#0091AC", "National" = "#6C6E74")
        ) +
        theme_minimal(base_size = 16) +
        theme(
          legend.position = "right",
          legend.title = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.x = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
        )
    })
  })
}
