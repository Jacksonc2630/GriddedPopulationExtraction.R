# Purpose: Extract gridded population data from WorldPop raster files using Native Lands and US state shapefiles. Outputs a CSV in standardized format for analysis and data exploration.
# Jackson Chen, October 2025

# Load required libraries

library(terra)
library(sf)   
library(dplyr)

# File paths

raw_data_dir <- "Data/Raw"
processed_data_dir <- "Data/Processed"

if (!dir.exists(processed_data_dir)) dir.create(processed_data_dir, recursive = TRUE)

pop_raster_file <- file.path(Raw_Data_dir,"usa_level0_100m_2000_2020.tif")
native_shp_file <- file.path(Raw_Data_dir,"native_boundaries","tl_2020_us_aitsn.shp")
states_shp_file <- file.path(Raw_Data_dir,"states","states.shp")

# Read population raster and shapefiles

pop_raster <- rast(pop_raster_file)
native_shp <- st_read(native_shp_file)
states_shp <- st_read(states_shp_file)

#