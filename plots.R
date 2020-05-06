# Script for various Covid-19 statistics
# Mostly experiments so far

# Load libraries
library(tidyverse)
library(ggplot2)
library(scales)

# Load REFSA logo
refsa_logo <- png::readPNG("Logo.png")

# Load data

# Apple Mobility Trends: https://www.apple.com/covid19/mobility
mobi <- read.csv("https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev48/v2/en-us/applemobilitytrends-2020-05-04.csv", na.strings = "", fileEncoding = "UTF-8-BOM")

# ECDC Covid-19 cases: https://www.ecdc.europa.eu/en/publications-data/download-todays-data-geographic-distribution-covid-19-cases-worldwide
covid_data <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", na.strings = "", fileEncoding = "UTF-8-BOM")

# Convert table in usable format
# Convert date columns to a "requests" key, freq is the value
mobi_t <- gather(data = mobi, key = date, value = requests, `2020-01-13`:`2020-05-02`)

# Filter table for Malaysia and Singapore only
regions <- c("Malaysia", "Singapore")
mobi_t_m <- filter(mobi_t,region %in% regions & transportation_type == "driving")

# Plot data upfront
mobi_plot <- ggplot(data = mobi_t_m) + 
  geom_line(aes(x = as.Date(date, tryformats = c("%Y-%m-%d")), y = requests, group = region)) + 
  scale_x_date(NULL, breaks = "2 weeks", date_labels = "%d-%b") +
  geom_hline(yintercept = 100) +
  facet_wrap(~ region, nrow = 1) + 
  theme(axis.text.x=element_text(angle = 45, hjust = 1, vjust = 1)) +
  labs(title = "Change in Apple Maps routing requests during MCO", subtitle = "(13-Jan-2020 = 100)", caption = "Source: Apple Mobility Trends") + 
  annotation_custom(grid::rasterGrob(refsa_logo, x = unit(1, "npc"), y = unit(0.92, "npc"), 
                                     width = unit(30, "points"), hjust = 1.1, vjust = 0))

# Save the plots to PNG
ggsave("RoutingRequestsMCO.png", plot = mobi_plot, device = "png")




