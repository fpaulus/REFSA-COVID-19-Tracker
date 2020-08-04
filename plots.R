# Script for various Covid-19 statistics
# Mostly experiments so far

# Load libraries
library(tidyverse)
library(ggplot2)
library(scales)
library(lubridate)

# Load REFSA logo
refsa_logo <- png::readPNG("Logo.png")

# Load data

# Apple Mobility Trends: https://www.apple.com/covid19/mobility
mobi <- read.csv("https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev48/v2/en-us/applemobilitytrends-2020-05-04.csv", na.strings = "", fileEncoding = "UTF-8-BOM")

# ECDC Covid-19 cases: https://www.ecdc.europa.eu/en/publications-data/download-todays-data-geographic-distribution-covid-19-cases-worldwide
covid_data <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", na.strings = "", fileEncoding = "UTF-8-BOM")

# Convert table in usable format
# Convert date columns to a "requests" key, freq is the value
mobi_t <- gather(data = mobi, key = date, value = requests, 5:ncol(mobi))

# Filter table for Malaysia and Singapore only
regions <- c("Malaysia", "Singapore")
mobi_t_m <- filter(mobi_t,region %in% regions & transportation_type == "driving")

# Plot data upfront
mobi_plot <- ggplot(data = mobi_t_m) + 
  geom_line(aes(x = ymd(date), y = requests, group = region)) + 
  scale_x_date(NULL, breaks = "2 weeks", date_labels = "%d-%b") +
  geom_hline(yintercept = 100) +
  facet_wrap(~ region, nrow = 1) + 
  theme(axis.text.x=element_text(angle = 45, hjust = 1, vjust = 1)) +
  labs(title = "Change in Apple Maps routing requests during MCO", subtitle = "(13-Jan-2020 = 100)", caption = "Source: Apple Mobility Trends") + 
  annotation_custom(grid::rasterGrob(refsa_logo, x = unit(1, "npc"), y = unit(0.92, "npc"), 
                                     width = unit(30, "points"), hjust = 1.1, vjust = 0))

# Save the plots to PNG
# ggsave("RoutingRequestsMCO.png", plot = mobi_plot, device = "png")

# Filter COVID-19 data for Malaysia, Belgium & Singapore
geo_ids <- c("MY", "SG", "UK", "BE", "US")
covid_data_m <- filter(covid_data, geoId %in% geo_ids)

# Convert string date to Date
covid_data_MYd <- covid_data_m %>% mutate(date = dmy(dateRep))

# Sort rows in ascending order (by Date)
covid_data_MYd <- arrange(covid_data_MYd, date)

# Calculate cumulative number of cases and deaths
covid_data_MYd <- covid_data_MYd %>% group_by(geoId) %>% mutate(cumCases = cumsum(cases))
covid_data_MYd <- covid_data_MYd %>% group_by(geoId) %>% mutate(cumDeaths = cumsum(deaths))

# Plot MY COVID-19 cases
covid_my_plot <- ggplot(data = covid_data_MYd) + 
  geom_line(aes(x = date, y = cumCases, color = geoId), linetype = "dashed") +
  geom_line(aes(x = date, y = cumDeaths, color = geoId))
covid_my_plot

# Filter days where number of cases exceeds 5 for the first time
min_date_my <- filter(covid_data_MYd, cumCases > 5 & geoId == "MY") %>% filter(date == min(date)) %>% select(date)
min_date_sg <- filter(covid_data_MYd, cumCases > 5 & geoId == "SG") %>% filter(date == min(date)) %>% select(date)
min_date_uk <- filter(covid_data_MYd, cumCases > 5 & geoId == "UK") %>% filter(date == min(date)) %>% select(date)
min_date_be <- filter(covid_data_MYd, cumCases > 5 & geoId == "BE") %>% filter(date == min(date)) %>% select(date)
min_date_us <- filter(covid_data_MYd, cumCases > 5 & geoId == "US") %>% filter(date == min(date)) %>% select(date)

# Add a column to the original data frame counting the number of days from the earliest date
covid_data_my_baseline <- filter(covid_data_MYd, geoId == "MY" & cumCases > 5) %>% mutate(days_since = date - min_date_my$date)
covid_data_sg_baseline <- filter(covid_data_MYd, geoId == "SG" & cumCases > 5) %>% mutate(days_since = date - min_date_sg$date)
covid_data_uk_baseline <- filter(covid_data_MYd, geoId == "UK" & cumCases > 5) %>% mutate(days_since = date - min_date_uk$date)
covid_data_be_baseline <- filter(covid_data_MYd, geoId == "BE" & cumCases > 5) %>% mutate(days_since = date - min_date_be$date)
covid_data_us_baseline <- filter(covid_data_MYd, geoId == "US" & cumCases > 5) %>% mutate(days_since = date - min_date_be$date)

# Should have left a note here explaining what this does... 
covid_cases_norm <- covid_data_my_baseline
covid_cases_norm <- rbind(covid_cases_norm, covid_data_sg_baseline)
covid_cases_norm <- rbind(covid_cases_norm, covid_data_uk_baseline)
covid_cases_norm <- rbind(covid_cases_norm, covid_data_be_baseline)
covid_cases_norm <- rbind(covid_cases_norm, covid_data_us_baseline)

# test plot
covid_cases_norm_plot <- ggplot(data = covid_cases_norm) +
  geom_line(aes(x = days_since, y = cumCases, color = geoId)) +
  scale_y_log10(name = "Cumulative cases", labels = trans_format("identity", math_format(.x))) +
  scale_x_continuous(name = "Days since cases > 5")

covid_cases_norm_plot

