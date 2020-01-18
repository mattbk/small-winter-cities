
# This project is to try to figure out similarity among
# Grand Forks/East Grand Forks and US cities of similar size
# in similar climate. The results will then be used to reseearch
# what those cities are doing for bike infra and how it is
# working out for them.

# TODO make this Rmd file

library(tidycensus)
library(tidyverse)
library(ggplot2)
library(tigris)
library(viridis)
library(ini)
library(sf)
# Load the census API key, the ini file should be of format
# [keys]
# key = your_key_here
census_api_key(read.ini('census_api_key.ini')$keys$key)

# Get a list of variables
vars <- load_variables("2018", "acs5")

# This includes a broader area
# us_metro <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
#                      variables = "B01001_001",
#                     geometry = T)
# This is just urban
# Code is for total population, all ages
# https://www.census.gov/data/developers/data-sets/acs-1year/notes-on-acs-api-variable-formats.html
us_urban <- get_acs(geography = "urban area",
                    variables = "B01001_001")

# Geometry is not in tidycensus yet, so we have to get it this way
# Download it once and save locally
#urban_areas_geom <- urban_areas(class = "sf")
#save(urban_areas_geom, file = "data/urban_areas_tigris.RData")
# Load saved variable
load("data/urban_areas_tigris.RData")

us_urban_joined <- left_join(urban_areas_geom,
                    us_urban,
                    by = c("GEOID10" = "GEOID"))

# Prove you can plot the largest cities
ggplot(us_urban_joined %>% filter(estimate > 5000000)) +
    geom_sf(aes(fill = estimate),
            color = NA) +
    theme_minimal() +
    scale_fill_viridis()

# Define range of populations to include
gfk_pop <- us_urban_clean %>%
                filter(NAME == "Grand Forks, ND--MN Urbanized Area (2010)") %>%
                mutate(high = estimate + (estimate * 0.1),
                       low = estimate - (estimate * 0.1))

# Clean data
us_urban_clean <- us_urban_joined %>%
                    select(NAME, variable, estimate, moe) %>%
                    st_centroid() %>%
                    filter(estimate < gfk_pop[['high']],
                           estimate > gfk_pop[['low']])

# TODO bring in climate data







