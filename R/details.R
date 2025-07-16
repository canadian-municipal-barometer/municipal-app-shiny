library(shiny)
library(dplyr)
library(ggplot2)
library(DT)

muni_data <- read.csv("data/municipal-data_raw.csv", check.names = FALSE)
issues_data <- read.csv("data/issues-data.csv")
issues_data <- issues_data |>
  select("issue" = issue_id, "Agreement" = Agreement, Opinion)

# add an empty first row so that the select input's selectize has the empty
# string in its first position to enable placeholder prompt
# These values are set as placeholders. 1 matches numeric columns in the
# main `muni_data` and "" matches character. This enables the correct types
# for the bind_rows operation
muni_row1 <- tidyr::tibble(
  csd = c(1),
  prediction = c(1),
  issue = c(""),
  "Pct. Renters" = c(1),
  Population = c(1),
  "Pop. / sq. km" = c(1),
  "Average Age" = c(1),
  "Median After-tax income" = c(1),
  Name = c(""),
  Province = c("")
)
muni_data <- bind_rows(muni_row1, muni_data)
muni_data$Population <- log(muni_data$Population)
muni_data$"Pop. / sq. km" <- log(muni_data$"Pop. / sq. km")

details_ui <- function(id) {
  tagList(
    "muni_menu" = selectInput(
      inputId = NS(id, "muni_menu"),
      label = "",
      choices = unique(muni_data$Name),
      selectize = TRUE,
      width = "100%",
    ),
    "corr_menu" = selectInput(
      inputId = NS(id, "corr_menu"),
      label = "Correlate with...",
      choices = colnames(muni_data)[
        !(colnames(muni_data) %in%
          c("prediction", "Name", "Province", "issue", "csd"))
      ],
      selectize = TRUE,
      width = "100%",
    ),
    "histogram" = plotOutput(NS(id, "histogram")),
    "corr_plot" = plotOutput(NS(id, "corr_plot")),
    "nat_comp" = plotOutput(NS(id, "nat_comp")),
    "pred_plot" = plotOutput(NS(id, "pred_plot"))
  )
}

details_server <- function(id, issue) {
  moduleServer(id, function(input, output, session) {
    # --------------------
    # Prediction Histogram
    output$histogram <- renderPlot({
      hist_data <- muni_data |>
        filter(
          issue == issue(),
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
          issue == issue(),
          # filter out the empty row used for the muni_menu placeholder
          Name != ""
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
    # prediction/opinion plot
    output$pred_plot <- renderPlot({
      req(input$muni_menu)
      req(issue())

      colnames(issues_data)

      pred_data <- muni_data |>
        filter(
          issue == issue(),
          Name == input$muni_menu,
          # filter out the empty row used for the muni_menu placeholder
          Name != ""
        ) |>
        select("Agreement" = prediction, issue, "Opinion" = opinion) |>
        mutate(group = "Municipality")

      # rename variables and create group IDs
      issues_data <- issues_data |>
        filter(issue == issue()) |>
        mutate(group = "National")

      plot_data <- bind_rows(pred_data, issues_data)

      plot_data <- plot_data |>
        pivot_longer(
          cols = c(Agreement, Opinion),
          names_to = "pred_type",
          values_to = "pred"
        )

      plot_data$pred <- round(plot_data$pred, 2) * 100
      print(plot_data)

      ggplot(plot_data, aes(x = pred_type, y = pred, fill = group)) +
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
