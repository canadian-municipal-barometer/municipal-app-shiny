library(ggplot2)
library(dplyr)
library(leaflet)
library(shiny)
library(sf)

map_ui <- function(id) {
  tagList(
    selectInput(
      NS(id, "issue"),
      label = "Select and issue:",
      choices = unique(mrp_data$issue)
    ),
    plotOutput(NS(id, "map"))
  )
}

map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    geo_data <- sf::read_sf("data/geo_simple/geo_simple.shp")
    mrp_data <- reactive({
      data <- readRDS("data/cmb25mrp_estimates.RDS")
      data <- data |>
        filter(issue == input$issue) |>
        mutate(csd = as.character(csd))
      return(data)
    })
    output$map <- renderPlot({
      geo_data <- geo_data |>
        dplyr::left_join(mrp_data(), by = c("CSDUID" = "csd"))
      ggplot(geo_data) +
        geom_sf(aes(fill = prediction)) +
        theme_void()
    })
  })
}
