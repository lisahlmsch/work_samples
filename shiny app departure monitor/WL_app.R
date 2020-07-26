## DEPARTURE MONITOR
# This is a shiny web application to check the real-time departures and delays at any public transporation station in Vienna. 
# The API is provided by Wiener Linien
# https://www.data.gv.at/katalog/dataset/add66f20-d033-4eee-b9a0-47019828e698

library(readr)
library(shiny)
library(shinydashboard)
library(DT)
source("global.R")

## DEFINE UI ----------------------------------------

# create header
header <- dashboardHeader(
    dropdownMenu(
        type = "messages",
        messageItem(
            from = "Lisa",
            message = "Check out the Wiener Linien website!",
            href = "https://www.wienerlinien.at/en/",
            icon = icon("info-circle"))),
    title = "Vienna Transport"
)

# create sidebar
sidebar <- dashboardSidebar(
    sidebarMenu(
        # Drop down menu with stations in Vienna
        selectInput(inputId = 'station', 
                    label = 'Please select station', 
                    choices = haltestellen, 
                    selectize=FALSE),
        # Checkboxes for barrier free and transportation type
        checkboxInput(inputId = "barrierfree", 
                      label = "Show if barrier free", 
                      value = FALSE),
        checkboxInput(inputId = "transporttype",
                      label = "Show type of transport",
                      value = TRUE),
        # Sidebar menu DASHBOARD
        menuItem("Dashboard",
                 tabName = "dashboard", 
                 icon = icon("dashboard")),
        # Sidbar menu MAP
        menuItem("Map",
                 tabName = "map",
                 icon = icon("map")),
        # Sidbar menu LICENCE
        menuItem("Licence info",
                 tabName = "licence",
                 icon = icon("info-circle"))
        )
)

# create body
body <- dashboardBody(
    tabItems(
        # content of menu DASHBOARD
        tabItem(tabName = "dashboard",
            # Row 1: Main Box showing the selected station
            fluidRow(
                valueBoxOutput("mainheader",
                               width = 12)
            ),
            # Row 2: Main Box showing the departures at the selected station
            fluidRow(
                box(width = 12,
                    title = "DEPARTURES",
                    dataTableOutput(outputId = "departure_table"),
                    status = "info"))),
        # content of menu MAP
        tabItem(tabName = "map",
                fluidRow(
                    valueBoxOutput("mainheader2", 
                                       width = 12)),
                fluidRow(
                    # Output: interactive world map
                    box(width = 12,
                    leafletOutput(outputId ="plot_map",
                                  height = 500)))),
        # content of menu LICENCE
        tabItem(tabName = "licence",
                h2("Licence"),
                p("Creative Commons Namensnennung 4.0 International"),
                p(strong("Data Source: "),"Stadt Wien – ", a("https://data.wien.gv.at", href = "https://data.wien.gv.at")),
                p(strong("Licence: "), a("https://creativecommons.org/licenses/by/4.0/deed.de", href = "https://creativecommons.org/licenses/by/4.0/deed.de")),
                p(strong("Terms of Use: "), a("https://digitales.wien.gv.at/site/open-data/ogd-nutzungsbedingungen/", href = "https://digitales.wien.gv.at/site/open-data/ogd-nutzungsbedingungen/"))
                )
     )
)

# Create the UI using the header, sidebar, and body
ui <- dashboardPage(skin = "red",
                    header, 
                    sidebar,
                    body)

## DEFINE SERVER ----------------------------------------

server <- function(input, output, session) {
    output$station <- renderText({input$station})
    
    output$mainheader <- renderValueBox({
        valueBox(value = input$station,
            subtitle = "Selected station", icon = icon("subway"),
            color = "red")
    })
    
    output$mainheader2 <- renderValueBox({
        valueBox(value = input$station,
                 subtitle = "Selected station", icon = icon("subway"),
                 color = "red")
    })

    output$barrier <- renderText({ input$barrierfree })
    
    output$type <- renderText({ input$transporttype })

    output$departure_table <- DT::renderDataTable(
        expr = departure_table_fun(input$station, input$barrierfree, input$transporttype)
    )
    
    # Create the interactive city map
    output$plot_map <- renderLeaflet({
        station_map_fun(input$station)
    }) 
}

shinyApp(ui, server)


