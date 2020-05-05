# Script for various Covid-19 statistics
# Mostly experiments so far

# Load libraries
library(tidyverse)
library(ggplot2)
library(scales)

# Load data from CSV file
# URL for downloads: https://www.apple.com/covid19/mobility
mobi <- read_csv("applemobilitytrends-2020-05-02.csv")
mobi

# Convert table in usable format
# Convert date columns to a "requests" key, freq is the value
mobi_t <- gather(data = mobi, key = date, value = requests, `2020-01-13`:`2020-05-02`)

# Filter table for Malaysia and Singapore only
regions <- c("Malaysia", "Singapore", "UK")
mobi_t_m <- filter(mobi_t,region %in% regions & transportation_type == "driving")

# Plot data upfront
ggplot(data = mobi_t_m) + 
  geom_line(aes(x = as.Date(date, tryformats = c("%Y-%m-%d")), y = requests, group = region)) + 
  scale_x_date(NULL, breaks = "2 weeks") +
  geom_hline(yintercept = 100) +
  facet_wrap(~ region, nrow = 1)
  




