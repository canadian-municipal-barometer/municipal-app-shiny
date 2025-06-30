library(ggplot2)
library(dplyr)
library(leaflet)
library(shiny)
library(sf)
library(plotly)

map_ui <- function(id, issues) {
  tagList(
    selectInput(
      NS(id, "issue"),
      label = "Select and issue:",
      choices = issues
    ),
    plotlyOutput(NS(id, "map"))
  )
}

map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    geo_data <- sf::read_sf("data/geo_simple/geo_simple.shp")

    mrp_data <- reactive({
      data <- readRDS("data/cmb25mrp_estimates.RDS")
      data <- data |>
        dplyr::filter(issue == input$issue) |>
        mutate(csd = as.character(csd))
      return(data)
    })
    output$map <- renderPlotly({
      geo_data <- geo_data |>
        dplyr::left_join(mrp_data(), by = c("CSDUID" = "csd"))
      p <- ggplot(geo_data) +
        geom_sf(aes(fill = prediction)) +
        theme_void()
      ggplotly(p)
    })
  })
}
