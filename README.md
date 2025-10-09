# Gridded Population Extraction
This project extracts WorldPop gridded population data (2000–2020) for Native boundaries and outputs yearly population summaries.

# Directory
```


├── R
│   └── GriddedPopulationExtraction.R
├── Data
│   ├── Raw
│   │   ├── native_boundaries
│   │   │   ├── tl_2020_us_aitsn.shp
│   │   │   └── ...
│   │   └── population_data
│   │       ├── worldpop_2000.tif
│   │       ├── worldpop_2001.tif
│   │       └── ...
│   └── Processed
│       ├── NativeBoundaries_Population_2000.csv
│       ├── NativeBoundaries_Population_2001.csv
│       └── ...
├── README.md
├── .gitignore
└── GriddedPopulationExtraction.Rproj
```

# Procedure

1. Clone this repository
2. Download WorldPop rasters (2000–2020) from [WorldPop](https://hub.worldpop.org/geodata/listing?id=29).
3. Place `.tif` files in `Data/Raw/population_data/`
4. Open and run `R/GriddedPopulationExtraction.R`
5. View generated CSVs in `Data/Processed/`
