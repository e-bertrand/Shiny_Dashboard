########################################
# Server of Air Pollutant shiny dashboard
#######################################

library(ggplot2)
library(shiny)
library(DT)

# Running the load and tidying of raw files
source("LoadData.R")

# Build the main panel based in a ggplot2 step by step depending on
# the selected options
shinyServer(function(input, output) {

    output$plot1 <- renderPlot({
        
        # Processing diagram type 3 (pollutions across the states) as it
        # is different to the rest
        if (input$diag_option == 3){
            
            emiss_data <- subset(emissions, year >= input$year[1] &
                                           year <= input$year[2])
            pollutant <- input$pollutant
            pollutant_data <- emiss_data[[pollutant]]
            
            g <- ggplot(emiss_data, aes(x=state, y=pollutant_data)) +
                    stat_summary(fill = "indianred2", color = "gray", size = 0.5,
                                 fun.y = "sum", geom = "bar", na.rm = TRUE) +
                    scale_y_continuous(name = paste(pollutant, "(1000 tons)")) +
                    scale_x_discrete(name = "State") +
                    ggtitle(paste("Pollutant across States between", 
                                  min(emiss_data$year), "and",
                                  max(emiss_data$year))) +
                    theme(plot.title = element_text(size = 16, face = "bold",
                                                    margin = margin(5,0,15,0)),
                          axis.title.y = element_text(size = 14, face = "bold",
                                                      margin = margin(0,15,0,0)),
                          axis.title.x = element_text(size = 14, face = "bold",
                                                      margin = margin(0,15,0,0)),
                          axis.text.x = element_text(size = 11, angle = 90,
                                                     vjust = 0.4, hjust = 1))
            return(print(g))
        }

        # Depending of the selected states a subset of emissions is created
        if (input$state == "All"){
            state_list <- levels(emissions$state)
            state_title <- "in all states"
        } else {
            state_list <- input$state
            state_title <- paste("in", input$state)
        }
        emiss_data <- subset(emissions, state %in% state_list)
        
        # Depending if the source option was selected, a title and a  
        # list of sources is created. In this way splitting the plot
        # by source is posible
        if (input$diag_option == 2){
            Source <- emiss_data$source
            source_title <- "by source"
        } else {
            source_title <- ""
        }
        
        # Data to be plotted correspond to the column for the pollutant
        # selected
        pollutant <- input$pollutant
        pollutant_data <- emiss_data[[pollutant]]

        # We start to build up the plot with the basic data
        # The way y aestetic dimension is assigned make easier the reactivity
        g <- ggplot(emiss_data, aes(x=year, y=pollutant_data)) +
                scale_x_continuous(name = "Year",
                                   breaks = seq(min(emiss_data$year),
                                                max(emiss_data$year),
                                                2),
                                   limits = c(input$year[1], input$year[2])) +
                scale_y_continuous(name = paste(pollutant, "(1000 tons)"),
                                 limits = c(0, NA))
        
        # Depending on whether splitted by source has been selected we can show
        # different sources or all data
        com_title <- ""
        
        if (input$diag_option == 2){
            
            # Plotting splitting the data by source
            g <- g + stat_summary(aes(color = Source), fun.y = "sum", size = 1,
                             geom = "line", na.rm = TRUE)
        } else {
            
            # Plotting for the whole state (sources summarized)
            g <- g + stat_summary(color = "indianred2", fun.y = "sum", size = 1,
                                  geom = "line", na.rm = TRUE)
            
            # If comparison with other state we create a secondary data set
            if (input$state_com != "None") {
                com_title <- paste("/ compared with", input$state_com, 
                                   "(black dashed line)")
                emiss_data_com <- subset(emissions, state == input$state_com)
                pollutant_data_com <- emiss_data_com[[pollutant]]
                g <- g + stat_summary(data = emiss_data_com,
                                      aes(x=year, y=pollutant_data_com),
                                      color = "black", fun.y = "sum", size = 1,
                                      geom = "line", linetype = "dashed", 
                                      na.rm = TRUE)
            }
        }
        
        # Accross the process diferent part of the title has been set
        # Now create the whole graph title
        Title <- paste("Pollutant emissions", state_title, source_title, com_title)
        
        # Ending the plot with the main title and some configurations
        g <- g + ggtitle(Title) +
                 theme(plot.title = element_text(size = 16, face = "bold",
                                                 margin = margin(5,0,15,0)),
                       axis.title.x = element_text(size = 14, face = "bold",
                                                   margin = margin(15,0,5,0)),
                       axis.title.y = element_text(size = 14, face = "bold",
                                                   margin = margin(0,15,0,0)),
                       legend.text = element_text(size = 12))
        return(print(g))

    # The height of the graph could be a fix value in px.
    }, height = 575)
    
    output$emissions <- DT::renderDataTable(
        DT::datatable(emissions, options = list(searching = TRUE))
    )

})
