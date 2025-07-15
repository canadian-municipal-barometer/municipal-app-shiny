library(shiny)
library(dplyr)
library(ggplot2)
library(DT)

muni_data <- read.csv("data/municipal-data_raw.csv", check.names = FALSE)

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
    "muni_menu" = uiOutput(NS(id, "muni_menu")),
    "corr_menu" = selectInput(
      NS(id, "corr_menu"),
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
    "nat_comp" = plotOutput(NS(id, "nat_comp"))
  )
}

details_server <- function(id, issue) {
  moduleServer(id, function(input, output, session) {
    # --------------------
    # municipality menu

    output$muni_menu <- renderUI(
      selectInput(
        inputId = "muni_menu",
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
        inputId = "corr_var",
        label = "Correlate with...",
        choices = colnames(muni_data)[
          !(colnames(muni_data) %in%
            c("prediction", "Name", "Province", "issue", "csd"))
        ],
        selectize = TRUE,
        width = "100%",
      )
    )

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
        geom_smooth(method = "lm", se = FALSE, color = "red") +
        xlab(input$corr_menu) +
        ylab("Pct. Agreement") +
        theme_minimal(base_size = 16)
    })
  })
}
