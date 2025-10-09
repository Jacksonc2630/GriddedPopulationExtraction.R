# Load libraries 

library(terra)
library(sf)
library(dplyr)
library(stringr)

# Define File Paths

raw_data_dir <- "Data/Raw"
processed_data_dir <- "Data/Processed"
native_shp_file <- file.path(raw_data_dir, "native_boundaries", "tl_2020_us_aitsn.shp")
population_dir <- file.path(raw_data_dir, "population_data")

# Create output folder if it doesn’t exist
if (!dir.exists(processed_data_dir)) {
  dir.create(processed_data_dir, recursive = TRUE)
  message("Created 'Data/Processed' directory for output files")
}

# Load Native Boundaries

native_shp <- st_read(native_shp_file)
native_shp <- st_transform(native_shp, crs = "EPSG:4326")

# Reading Raster Files

raster_files <- list.files(population_dir, pattern = "\\.tif$", full.names = TRUE)

if (length(raster_files) == 0) {
  stop("No raster (.tif) files found in the population_data directory")
}

# Process Population Rasters

for (raster_file in raster_files) {
  
  # Extract year from filename (e.g., "worldpop_2000.tif")
  year <- str_extract(basename(raster_file), "\\d{4}") %>% as.integer()
  message(paste0("\n--- Processing raster for year ", year, " ---"))
  
  pop_raster <- rast(raster_file)

  raster_crs <- crs(pop_raster)
  shapefile_crs <- crs(vect(native_shp))
  
  if (raster_crs != shapefile_crs) {
    message("CRS mismatch detected")
    pop_raster <- project(pop_raster, shapefile_crs)
  }
  
  # Extract total population within each Native boundary
  pop_extract <- terra::extract(pop_raster, vect(native_shp), fun = sum, na.rm = TRUE)
  native_pop <- cbind(native_shp, pop_extract)
  pop_col <- setdiff(names(native_pop), c(names(native_shp), "ID", "geometry"))[1]
  
  # Create CSV
  native_pop_df <- native_pop %>%
    st_drop_geometry() %>%
    mutate(
      year = year,
      GEOID = as.character(GEOID),
      population = .data[[pop_col]]
    ) %>%
    select(GEOID, year, population)
  
  # Save CSV
  output_file <- file.path(processed_data_dir, paste0("NativeBoundaries_Pop_", year, ".csv"))
  write.csv(native_pop_df, output_file, row.names = FALSE)
  
  message(paste0("Saved: ", output_file))
}

message("\nAll population rasters processed successfully!")
