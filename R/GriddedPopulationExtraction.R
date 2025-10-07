# Gridded Population Extraction for Native Boundaries (WorldPop Data)

# Author: Jackson Chen
# Description:
#   This script extracts population totals from WorldPop raster data for Native Land boundary shapefiles (2000–2020). It exports the results to CSV.

# Load Libraries 
message("Loading libraries...")

library(terra)   # For raster and spatial operations
library(sf)      # For shapefile handling
library(dplyr)   # For data manipulation
library(stringr) # For handling filenames


# Define File Paths
message("Setting File Paths...")

raw_data_dir <- "Data/Raw"
processed_data_dir <- "Data/Processed"
native_shp_file <- file.path(raw_data_dir, "native_boundaries", "tl_2020_us_aitsn.shp")
population_dir <- file.path(raw_data_dir, "population_data")

# Create output folder if it doesn’t exist
if (!dir.exists(processed_data_dir)) {
  dir.create(processed_data_dir, recursive = TRUE)
  message("Created 'Data/Processed' directory for output files.")
}


# Load Native Boundaries
message("Reading Native Boundaries shapefile...")

native_shp <- st_read(native_shp_file)
native_shp <- st_transform(native_shp, crs = "EPSG:4326")  # Ensure same coordinate system


# Reading Raster Files

raster_files <- list.files(population_dir, pattern = "\\.tif$", full.names = TRUE)

if (length(raster_files) == 0) {
  stop("No raster (.tif) files found in the population_data directory.")
}

# View available raster files
view_raster_files <- function() {
  files <- list.files(population_dir, pattern = "\\.tif$", full.names = FALSE)
  if (length(files) == 0) {
    message("No raster files found in 'population_data'.")
  } else {
    message("Available raster files:")
    print(files)
  }
}

# View shapefile info

view_shapefile_info <- function() {
  message("Native boundaries shapefile info:")
  print(st_geometry_type(native_shp))
  print(st_crs(native_shp))
  print(head(native_shp))
}


# Process Population Rasters

for (raster_file in raster_files) {
  
  # Extract year from filename (e.g., "worldpop_2000.tif")
  year <- str_extract(basename(raster_file), "\\d{4}") %>% as.integer()
  message(paste0("\n--- Processing raster for year ", year, " ---"))
  
  # Read raster
  pop_raster <- rast(raster_file)
  
  # Check for coordinate system mismatch
  raster_crs <- crs(pop_raster)
  shapefile_crs <- crs(vect(native_shp))
  
  if (raster_crs != shapefile_crs) {
    message("CRS mismatch detected. Reprojecting raster to match shapefile...")
    pop_raster <- project(pop_raster, shapefile_crs)
  }
  
  # Extract total population within each Native boundary
  pop_extract <- terra::extract(pop_raster, vect(native_shp), fun = sum, na.rm = TRUE)
  
  # Combine extracted data with shapefile attributes
  native_pop <- cbind(native_shp, pop_extract)
  
  # Identify the population column name automatically
  pop_col <- setdiff(names(native_pop), c(names(native_shp), "ID", "geometry"))[1]
  
  # Create a clean summary dataframe
  native_pop_df <- native_pop %>%
    st_drop_geometry() %>%
    mutate(
      year = year,
      GEOID = as.character(GEOID),
      population = .data[[pop_col]]
    ) %>%
    select(GEOID, year, population)
  
  # Save CSV output
  output_file <- file.path(processed_data_dir, paste0("NativeBoundaries_Pop_", year, ".csv"))
  write.csv(native_pop_df, output_file, row.names = FALSE)
  
  message(paste0("Saved: ", output_file))
}

message("\nAll population rasters processed successfully!")
