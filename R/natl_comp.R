library(shiny)
library(duckdb)
library(DBI)

natl_comp_ui <- function(id) {
  tagList(
    "plot" = plotOutput(NS(id, "plot"))
  )
}

natl_comp_server <- function(id, selected_issue, selected_muni) {
  moduleServer(id, function(input, output, session) {
    # Data for pred plot
    pred_data <- reactive({
      req(selected_muni(), selected_issue())

      con <- dbConnect(
        duckdb::duckdb(),
        dbdir = "data/natl_comp_plot_data.duckdb",
        read_only = TRUE
      )
      on.exit(dbDisconnect(con, shutdown = TRUE))

      dbGetQuery(
        con,
        "SELECT * FROM plot_data WHERE muni = ? AND issue = ?",
        params = list(selected_muni(), selected_issue())
      )
    })

    # pred bar plot
    output$plot <- renderPlot({
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
