#######################################
# UI of Air Pollutant shiny dashboard
# This application produces three tabs
#  - The dashboard tab (main panel)
#  - The documentation tab
#  - The dataset tab
#######################################

library(shiny)
library(DT)

# As widgets are configured dynamically from the emissions dataset
# it must be also loaded in this sript
source("LoadData.R")

# The basic layout is based on navigation over different tabs (panels)
shinyUI(navbarPage("US Air Pollutant Emissions",

    # Principal panel with the dashboard
    tabPanel("Dashboard",
        sidebarLayout(sidebarPanel(
            
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
            
            # Type of diagrams supported
            radioButtons("diag_option", label = "Type of diagram:",
                         choices = list("Total pollutant emissions" = 1,
                                        "Pollutant splitted by source" = 2,
                                        "Pollutant across States" = 3),
                         selected = 1),
            
            # Basic instructions
            helpText( "Please, select a pollutant, a State (by default, all of them),", 
                      "and a period of years (by default, the total period).",
                      "Optionally, you can compare emissions with another State."),
            
            helpText("You can choose between three type of diagrams:", br(),
                      "1. Total emission of pollutant (default).", br(),
                      "2. Pollutant emissions splitted by source.", br(),
                      "3. Pollutant emissions across all States."),
            
            helpText("Note: be patient when you start the dashboard for the first",
                     "time, while dataset is being loaded."),
            helpText(strong("Please, see the 'Documentation' tab for details."))
        ),
        
        mainPanel(
            plotOutput('plot1')
        )
    )),
    
    # Panel with de documentation
    tabPanel("Documentation",
        fluidRow(
            column(2, helpText(strong("Purpose:"))),
            column(7, 
                 helpText(
                "This dashboard summarizes US air emissions trends of seven",
                "key pollutants since 1996. It shows how each pollutant", 
                "has evolved over a period of years depending on the State",
                "and the source of the emissions."),
                 helpText(
                "The pollutants are: 1. Carbon monoxide (CO); 2. Ammonia (NH3);",
                "3. Oxides of nitrogen (NOX); 4. Particulate matter less than",
                "10 microns in diameter (PM10); 5. Particulate matter less than",
                "2.5 microns in diameter (PM25); 6. Sulfur dioxide (SO2);",
                "7. Volatile organic compounds.")
            )
        ),
        fluidRow(
            column(2, helpText(strong("Raw data source:"))),
            column(7, 
                 helpText(
                 "The raw data are available in the file",
                 strong("State Average Annual Emissions Trend"),
                 "(xls format), published by the US Environmental Protection",
                 "Agency (EPA). It can be downloaded at",
                 a("here.",
                   href ="https://www.epa.gov/air-emissions-inventories/air-pollutant-emissions-trends-data"))
            )
        ),
        fluidRow(
            column(2, helpText(strong("Final dataset:"))),
            column(7, 
                   helpText(
                   "The xls file above mentioned cannot be considered", 
                   "a tidy dataset as long as it exhibits several usual problems:",
                   "measurements for every year are in columns; pollutants are",
                   "in rows; from year 1991 to 1995 does not include any",
                   "figures leaving year 1990 alone.; etc."),
                   helpText(
                   "From the original xsl file, a new tidy dataset has been",
                   "produced making extensive use",
                   "of 'tidyr', 'dplyr', and 'stringr' R packages.",
                   "Moreover, State abbreviations have been changed by ",
                   "full names, and pollutant sources have been simplified",
                   "(see next paragraph).",
                   "All measurements are in thousands of tons.",
                   "The final dataset is shown in",
                   " the tab", strong("'Dataset'"),".")
            )
        ),
        fluidRow(
            column(2, helpText(strong("A note on pollutant sources:"))),
            column(7, 
                   helpText(
                   "In the raw file, emissions are classified according the",
                   "15 Tier 1 categories defined by the EPA. However, so many", 
                   "categories make any splitted diagram unclear and unhelpful."),
                   helpText(
                   "In the final dataset all these categories have been grouped",
                   " in 6 different types of sources:", 
                        strong("1. Vehicles, "), "grouping ",
                   "'HIGHWAY VEHICLES' and 'OFF-HIGHWAY'",
                   ";", strong("2. Fuel comb., "), "grouping",
                   "'FUEL COMB. ELEC. UTIL.',",
                   "'FUEL COMB. INDUSTRIAL', and", "'FUEL COMB. OTHER'",
                   ";", strong("3. Industry, "), "grouping", 
                   "'CHEMICAL & ALLIED PRODUCT MFG',",
                   "'METALS PROCESSING', 'OTHER INDUSTRIAL PROCESSES',",
                   "'PETROLEUM & RELATED INDUSTRIES', and 'SOLVENT UTILIZATION'",
                   ";", strong("4. Materials,"), "groping",
                   "'WASTE DISPOSAL & RECYCLING' and 'STORAGE & TRANSPORT'",
                   ";", strong("5. Fires,"), "grouping",
                   "'PRESCRIBED FIRES' and 'WILDFIRES'",
                   ";", strong("6. Others,"), "which correspond to the original",
                   "category 'MISCELLANEOUS'."),
                   helpText(
                       ) 
            )
        ),
        fluidRow(
            column(2, helpText(strong("R code:"))),
            column(7, 
                   helpText(
                   "All R files of this application, including the script for",
                   "transforming the original raw file in the final dataset,",
                   "are available -properly documented- in a github repository",
                       a("here.", 
                         href = "https://github.com/e-bertrand/Shiny_Dashboard")    
                   ) 
            )
        )
    ),
    
    # Panel with the Emissions dataset
    tabPanel('Dataset',       
             DT::dataTableOutput('emissions'))
))
