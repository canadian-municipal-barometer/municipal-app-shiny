library(shiny)
library(dplyr)
library(ggplot2)
library(DT)

details_ui <- function(id) {
  tagList(
    "muni_menu" = uiOutput(NS(id, "muni_menu")),
    "corr_menu" = uiOutput(NS(id, "corr_menu")),
    "histogram" = plotOutput(NS(id, "histogram")),
    "corr_plot" = plotOutput(NS(id, "corr_plot")),
    "nat_comp" = plotOutput(NS(id, "nat_comp"))
  )
}

details_server <- function(id, issue) {
  moduleServer(id, function(input, output, session) {
    issues_data <- read.csv("data/issues-data.csv")
    muni_data <- read.csv("data/municipal-data-final.csv")

    # --------------------
    # municipality menu

    # add an empty first row so that the select input's selectize has the empty
    # string in its first position to enable placeholder prompt
    muni_row1 <- tidyr::tibble(
      csd = c(""),
      prediction = c(""),
      issue = c(""),
      "Pct. Renters" = c(""),
      Population = c(""),
      "Pop. / sq. km" = c(""),
      "Average Age" = c(""),
      "Median After-tax income" = c(""),
      Name = c(""),
      Province = c("")
    )
    muni_data$csd <- as.character(muni_data$csd)
    muni_data$prediction <- as.character(muni_data$prediction)
    muni_data <- bind_rows(muni_row1, muni_data)

    output$muni_menu <- renderUI(
      selectInput(
        inputId = "menu",
        label = "",
        choices = unique(muni_data$Name),
        selectize = TRUE,
        width = "100%",
      )
    )

    # --------------------
    # correlation variable menu

    output$corr_menu <- renderUI(
      selectInput(
        inputId = "muni_menu",
        label = "",
        choices = c(
          "Pct. Renters",
          Population,
          "Pop. / sq. km",
          "Average Age",
          "Median After-tax income",
        ),
        selectize = TRUE,
        width = "100%",
      )
    )

    # --------------------
    # Prediction Histogram
    output$histogram <- renderPlot({
      hist_data <- muni_data |> filter(issue == issue())
      ggplot(hist_data, aes(x = as.numeric(prediction))) +
        xlab("Pct. Agreement") +
        ylab("Count") +
        geom_histogram() +
        theme_minimal(base_size = 16) +
        theme(
          legend.position = "none",
          panel.grid.major = ggplot2::element_blank(),
          panel.grid.minor = ggplot2::element_blank()
        )
    })

    # --------------------
    # Correlation Plot
  })
}
