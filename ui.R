########################################
# UI of Air Pollutant shiny dashboard
#######################################

# As widgets are configured dynamically from the emissions dataset
# it must be also loaded in this sript

source("LoadData.R")

shinyUI(pageWithSidebar(
    
    # Year in the title are dynamicly assigned from dataset
    headerPanel(h3('US Air pollutant emissions trends'),
                windowTitle = "US Air pollutant emissions trends"
    ),
    
    sidebarPanel(
        
        # Area of 2x2 widgets at the top of sidebar panel
        fluidRow(
            column(5,
                    # List of pollutants corresponds to colum names
                    selectInput('pollutant', label = 'Pollutant',
                                names(emissions[, -c(1:3)]))
                ),
            column(7,
                   # List of States are factor levels
                   selectInput('state', label = 'State',
                               c("All", levels(emissions$state)))
            )
        ),
        fluidRow(
            column(5),
            column(7,
                   # List of States are factor levels
                   selectInput('state_com', label = 'Compared with State',
                               c("None", levels(emissions$state)))
            )
        ),
        
        # Range of years from the dataset
        sliderInput("year", label = "Period", ticks = FALSE, sep = NULL,
                    min = min(emissions$year), max = max(emissions$year),
                    value = c(min(emissions$year), max(emissions$year))),
        
        
        radioButtons("diag_option", label = "Type of diagram:",
                     choices = list("Total pollutant emissions" = 1,
                                    "Pollutant splitted by source" = 2,
                                    "Pollutant across States" = 3),
                     selected = 1),
        
        helpText( "Please, select a pollutant, a State (by default, all of them),", 
                  "and a period of years (by default, the total period).",
                  "Optionally, you can compare emissions with another State."),
        helpText("You can choose between three type of diagrams:", br(),
                  "1. Total emission of pollutant (default).", br(),
                  "2. Pollutant emissions splitted by source.", br(),
                  "3. Pollutant emissions across all States."),
        helpText("Note: be patient when you start the dashboard for the first",
                 "time, while dataset is being loaded."),
        helpText(strong("This dashboard is based in a dataset",
                        "that summarizes US air emissions of seven key",
                        "pollutants from 1996. The dataset has been obtained ",
                        " tidying and reorganizing the",
                        " 'State Average Annual Emissions Trend' xls file that",
                        " can be downloaded at",
                        a("here.",
                          href ="https://www.epa.gov/air-emissions-inventories/air-pollutant-emissions-trends-data")))
    ),
    
    mainPanel(
        plotOutput('plot1')
    )
))
