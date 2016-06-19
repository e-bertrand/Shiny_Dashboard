####################################################
# Load and tidying up the annual emissions file
# The result is an emissions dataset ready to be
# analyzed in the shiny dashboard
####################################################

library(tidyr)
library(dplyr)
library(stringr)
library(readxl)

data(state)

# Add DC to the table of State names/abbr. It will be used later
# for change abbreviations by full names
state.abb <- c(state.abb, "DC")
state.name <- c(state.name, "Dist. Columbia")

# Create a simpler table of sources from EPA Tier 1 categories. It will
# be used later to simplify the number of different sources
tier1 <- c("CHEMICAL & ALLIED PRODUCT MFG", "FUEL COMB. ELEC. UTIL.",
           "FUEL COMB. INDUSTRIAL", "FUEL COMB. OTHER", 
           "HIGHWAY VEHICLES", "METALS PROCESSING",             
           "MISCELLANEOUS", "OFF-HIGHWAY",
           "OTHER INDUSTRIAL PROCESSES", "PETROLEUM & RELATED INDUSTRIES",
           "PRESCRIBED FIRES", "SOLVENT UTILIZATION",          
           "STORAGE & TRANSPORT", "WASTE DISPOSAL & RECYCLING", 
           "WILDFIRES")
categ <- c("1. Vehicles", "2. Fuel comb.", "3. Industry",   
           "4. Materials", "5. Fires", "6. Others")
source_categ <- c(categ[3], categ[2], categ[2], categ[2], categ[1], categ[3],
                  categ[6], categ[1], categ[3], categ[3], categ[5], categ[3],
                  categ[4], categ[4], categ[5])
tier1_categ <- data.frame(tier1, category = source_categ)

# Loading the excel file downloaded from
# https://www.epa.gov/air-emissions-inventories/air-pollutant-emissions-trends-data
# Data are in a specific sheet, the first row of which is a comment line
emissions <- as.data.frame(read_excel("data/annual_emissions_trend.xls",
                                      sheet = "state_trends", skip = 1,
                                      col_names = TRUE))

# Dataset must be fully reorganized as it is untidy, with abbrevitions and
# codes instead of full names, with too many type of sources
emissions <- emissions %>%
                
                # Transforming year columns in rows
                gather(year, weight, emissions90:emissions14) %>%
    
                # Suppresing year 1990 (isolated year) and rows with NA
                filter(year != "emissions90") %>%
                filter(!is.na(weight)) %>%
            
                # Tranforming row pollutants in columns
                spread(pollutant_code, weight) %>%
    
                # Recoding the year column
                mutate(year = year %>% str_replace("emissions","")) %>%
                mutate(year = as.numeric(ifelse(year >= "96" & year <= "99",
                                                paste0(19, year),
                                                paste0(20, year)))) %>%
                
                # Change state abbreviations for state names
                mutate(state = state.name[match(STATE_ABBR, state.abb)]) %>%
    
                # Assign source types from tier 1 categories
                mutate(source = tier1_categ$category[match(tier1_description, 
                                                           tier1_categ$tier1)]) %>%
                
                # Suppresing code columns and grouping and summarizing by basic
                # criterias
                select(state, year, source, CO:VOC) %>%
                group_by(state, year, source) %>%
                summarise_each(funs(sum(., na.rm = TRUE)))

# Converting states and source columns in factors
emissions$state <- as.factor(emissions$state)
emissions$source <- as.factor(emissions$source)
