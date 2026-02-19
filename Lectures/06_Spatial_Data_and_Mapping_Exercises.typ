// =============================================================================
// Lecture 5: Spatial Data and Mapping - Exercises
// Environmental Data Science (ENST431/631)
// Author: Akash Koppa
// =============================================================================

// --- CONFIGURATION & COLORS ---
#let primary-color = rgb("#2d5a27")
#let accent-color = rgb("#457b9d")
#let bg-color = rgb("#fdfdfc")
#let text-color = rgb("#2f2f2f")
#let warning-color = rgb("#c44536")
#let map-color = rgb("#1a6b72")

// --- PAGE SETUP ---
#set page(
  paper: "us-letter",
  fill: bg-color,
  margin: (x: 1in, y: 0.85in),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 9pt, fill: text-color.lighten(40%))
      #grid(
        columns: (1fr, 1fr),
        align(left)[ENST431: Environmental Data Science],
        align(right)[Lecture 5: Spatial Data and Mapping]
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.5pt + text-color.lighten(70%))
    ]
  },
  footer: context {
    set text(size: 9pt, fill: text-color.lighten(40%))
    align(center)[Page #counter(page).display() of #counter(page).final().first()]
  }
)

#set text(size: 10.5pt, fill: text-color, font: "New Computer Modern")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: none)

// --- CUSTOM COMPONENTS ---
#let title-block(title: "", subtitle: "", author: "", date: "") = {
  set align(center)
  v(1em)
  block(width: 100%, inset: 1.5em, stroke: (bottom: 3pt + primary-color), [
    #text(2em, weight: "bold", fill: primary-color, title)
    #v(0.3em)
    #text(1.1em, fill: text-color.lighten(20%), subtitle)
    #v(0.8em)
    #text(1em, author)
    #v(0.2em)
    #text(0.9em, fill: text-color.lighten(30%), date)
  ])
  v(1.5em)
}

#let focus-box(title: "Note", color: accent-color, body) = {
  v(0.4em)
  rect(fill: color.lighten(92%), stroke: (left: 4pt + color), width: 100%, inset: 1em, radius: 4pt, [
    #text(weight: "bold", fill: color, size: 10pt, title)
    #v(0.3em)
    #set text(size: 10pt)
    #body
  ])
  v(0.4em)
}

#let exercise-header(number: 1, title: "", difficulty: "Beginner") = {
  let diff-color = if difficulty == "Beginner" { primary-color.lighten(20%) } else if difficulty == "Intermediate" { accent-color } else { warning-color }

  v(1em)
  block(width: 100%, stroke: 1.5pt + primary-color.lighten(40%), radius: 6pt, clip: true, [
    #block(width: 100%, fill: primary-color.lighten(85%), inset: (x: 1em, y: 0.7em), [
      #grid(columns: (auto, 1fr, auto), align: (left, left, right), gutter: 0.8em,
        [#text(weight: "bold", fill: primary-color, size: 12pt)[Exercise #number]],
        [#text(weight: "semibold", fill: text-color, size: 11pt)[#title]],
        [#box(fill: diff-color.lighten(70%), stroke: 0.5pt + diff-color, inset: (x: 0.5em, y: 0.2em), radius: 3pt, text(size: 8pt, fill: diff-color.darken(20%), weight: "medium", difficulty))]
      )
    ])
  ])
  v(0.5em)
}

#let context-box(body)       = { focus-box(title: "The Problem", color: rgb("#5a8f7b"), body) }
#let spatial-think-box(body) = { focus-box(title: "Think Before You Code", color: accent-color, body) }
#let hint-box(body)          = { focus-box(title: "R Syntax Hints", color: primary-color.lighten(10%), body) }
#let python-hint-box(body)   = { focus-box(title: "Python Syntax Hints", color: rgb("#306998"), body) }

#let code-block(code) = {
  v(0.3em)
  rect(fill: luma(248), stroke: 0.5pt + luma(200), width: 100%, inset: 0.7em, radius: 4pt, [
    #set text(size: 9pt, font: "DejaVu Sans Mono")
    #code
  ])
  v(0.3em)
}

// =============================================================================
// TITLE PAGE
// =============================================================================

#title-block(
  title: "Spatial Data and Mapping",
  subtitle: "Programming Exercises for Environmental Data Science",
  author: "Instructor: Akash Koppa",
  date: "Lecture 5, Spring Semester 2026"
)

// --- INTRODUCTION ---
#text(weight: "semibold", size: 12pt, fill: primary-color)[Introduction]
#v(0.3em)

Each exercise introduces a different spatial data format and a core spatial operation, building toward a watershed-scale analysis of the Chesapeake Bay drainage basin. By the end, you will have loaded seven distinct file types (CSV, Shapefile, GeoPackage, GeoJSON, GeoTIFF, NetCDF, and categorical raster), performed the spatial operations covered in lecture, and produced maps suitable for an environmental management report.

#focus-box(title: "Thematic Setting", color: map-color)[
  All exercises are set in the *Chesapeake Bay watershed*, which drains approximately 166,000 km² across six states and Washington D.C. The Bay receives runoff carrying nitrogen, phosphorus, and sediment from agricultural and urban lands. The workflows in these exercises mirror those used by the Chesapeake Bay Program, USGS, and state environmental agencies.
]

#v(0.5em)
#text(weight: "semibold", size: 11pt, fill: accent-color)[Data Files]

The following files are used across the exercises. Place all files in a single folder and set that as your working directory.

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(200),
  fill: (col, row) => if row == 0 { primary-color.lighten(85%) } else { white },
  inset: (x: 0.7em, y: 0.5em),
  [*File*], [*Used in*],
  [`stations.csv`], [Exercises 1, 3, 6, 9, 10],
  [`station_data/{station\_id}.csv`], [Exercise 1 (Part B)],
  [`chesapeake_watersheds.gpkg`], [Exercises 2, 4, 5, 7, 8, 9, 10],
  [`counties_chesapeake.geojson`], [Exercise 3],
  [`chesapeake_dem.tif`], [Exercises 4, 9],
  [`mswep_monthly.nc`], [Exercises 5, 7, 10],
  [`chesapeake_streams.gpkg`], [Exercise 6],
  [`nlcd_chesapeake.tif`], [Exercises 8, 9, 10],
)

#v(0.5em)
#text(weight: "semibold", size: 11pt, fill: accent-color)[How to Use This Document]

For each exercise, follow this workflow:

+ *Read the problem*: identify the environmental question and the required output.
+ *Identify the data*: determine which file(s) are needed and what format they use.
+ *Think spatially*: answer the questions in the "Think Before You Code" box before writing any code.
+ *Load and explore*: always inspect a spatial dataset before performing analysis.
+ *Solve and map*: produce the required output with a clear, labeled map.

#v(0.5em)

#focus-box(title: "Setup Required", color: warning-color)[
  *R packages*: `sf` (vector data), `terra` (raster data), `tmap` (mapping), `tidyverse`, and `exactextractr` (zonal statistics). *Python packages*: `geopandas`, `rasterio`, `xarray`, `rasterstats`, `matplotlib`, and `cartopy`. All data files should be placed in a single folder. Set your working directory to that folder before running any code.
]

#pagebreak()

// =============================================================================
// EXERCISE 1
// =============================================================================

#exercise-header(number: 1, title: "Loading Point Data from a CSV File", difficulty: "Beginner")

#context-box[
  The Chesapeake Bay Program (CBP) maintains a long-term water quality monitoring network across the Bay and its tributaries. The file `stations.csv` contains the location and summary water quality attributes for 20 stations. The columns are: `station_id`, `description`, `watershed`, `lat` (decimal degrees), `lon` (decimal degrees), `mean_do_mgl` (mean dissolved oxygen, mg/L), `mean_temp_c` (mean water temperature, degrees C), and `years_active`.

  A CSV with coordinate columns is not a spatial dataset: you cannot compute distances, perform spatial joins, or overlay it with other layers until you explicitly assign geometry and a coordinate reference system (CRS). This exercise covers that conversion and the basic spatial inspection that should precede any analysis.
]

*Your Primary Tasks*

- Read `stations.csv` using the standard CSV reader
- Inspect the data: how many rows? What does `str()` / `df.info()` show?
- Convert to a spatial object using the `lat` and `lon` columns, assigning CRS EPSG:4326 (WGS84)
- Verify the CRS is correctly set by printing it
- Check the spatial extent (bounding box)
- Create a map of all station locations, colored by `mean_do_mgl`
- Add a title, legend, and label the three stations with the lowest mean dissolved oxygen

*Part B: Exploring a Station Time Series*

The folder `station_data/` contains one CSV file per station with daily to monthly dissolved oxygen and water temperature measurements for the period 2015-2022. Each file is named by station ID (e.g., `station_data/TF5.0J.csv`) and has three columns: `date` (YYYY-MM-DD), `do_mgl`, and `wtemp_c`.

- Select the station with the lowest mean DO from Part A
- Load its time series CSV
- Convert the `date` column to a proper date/datetime type
- Plot DO and water temperature on the same figure with dual y-axes, over the full 2015-2022 period
- Describe the seasonal pattern: when is DO highest? When is it lowest? What drives this cycle?

#spatial-think-box[
  - What is the difference between a CSV with lat/lon columns and a spatial file format such as a shapefile or GeoPackage? Why can spatial operations not be performed directly on the CSV?
  - EPSG:4326 stores coordinates in decimal degrees. Why does this create problems for distance calculations? (Consider: what is the ground distance covered by 1 degree of longitude at the equator versus at 40 degrees N?)
  - The `lon` column contains negative values (e.g., -76.38). What does the negative sign indicate? What would happen if lat and lon were accidentally swapped?
  - Coloring points by `mean_do_mgl` encodes a continuous variable. Which palette type is appropriate: sequential, diverging, or qualitative?
  - Should you check for missing lat/lon values before converting to a spatial object? What would happen to the conversion if some rows had NA coordinates?
]

#hint-box[
  *Read CSV:* `stations <- read.csv("stations.csv")`

  *Convert to sf object:*
  ```r
  library(sf)
  stations_sf <- st_as_sf(stations, coords = c("lon", "lat"), crs = 4326)
  ```

  *Check CRS:* `st_crs(stations_sf)` -- look for "WGS 84" and "EPSG:4326"

  *Bounding box:* `st_bbox(stations_sf)` -- returns xmin, ymin, xmax, ymax

  *Basic plot:* `plot(stations_sf["mean_do_mgl"], pch = 19, main = "Mean DO at CBP Stations")`

  *Map with tmap:*
  ```r
  library(tmap)
  tm_shape(stations_sf) +
    tm_dots(col = "mean_do_mgl", palette = "viridis",
            title = "Mean DO (mg/L)", size = 0.3)
  ```

  *Find lowest DO stations:* `stations_sf[order(stations_sf$mean_do_mgl)[1:3], ]`

  *Part B -- Load time series for the lowest-DO station:*
  ```r
  low_do_id <- stations_sf$station_id[order(stations_sf$mean_do_mgl)[1]]
  ts_file <- file.path("station_data", paste0(low_do_id, ".csv"))
  ts_data <- read.csv(ts_file)
  ts_data$date <- as.Date(ts_data$date)

  # Dual y-axis plot
  par(mar = c(5, 4, 4, 4))
  plot(ts_data$date, ts_data$do_mgl, type = "l", col = "steelblue",
       xlab = "Date", ylab = "DO (mg/L)", main = paste("Station:", low_do_id))
  par(new = TRUE)
  plot(ts_data$date, ts_data$wtemp_c, type = "l", col = "tomato",
       axes = FALSE, xlab = "", ylab = "")
  axis(side = 4)
  mtext("Water Temperature (°C)", side = 4, line = 3)
  legend("topright", legend = c("DO (mg/L)", "Temperature (°C)"),
         col = c("steelblue", "tomato"), lty = 1)
  ```
]

#python-hint-box[
  *Read CSV and convert to GeoDataFrame:*
  ```python
  import pandas as pd
  import geopandas as gpd

  stations = pd.read_csv("stations.csv")
  stations_gdf = gpd.GeoDataFrame(
      stations,
      geometry=gpd.points_from_xy(stations['lon'], stations['lat']),
      crs=4326
  )
  ```

  *Check CRS:* `stations_gdf.crs` -- should show EPSG:4326

  *Bounding box:* `stations_gdf.total_bounds` -- [xmin, ymin, xmax, ymax]

  *Plot:* `stations_gdf.plot(column='mean_do_mgl', cmap='viridis', legend=True, markersize=30)`

  *Part B -- Load time series for the lowest-DO station:*
  ```python
  low_do_id = stations_gdf.loc[stations_gdf['mean_do_mgl'].idxmin(), 'station_id']
  ts_data = pd.read_csv(f"station_data/{low_do_id}.csv", parse_dates=['date'])

  # Dual y-axis plot
  fig, ax1 = plt.subplots(figsize=(10, 4))
  ax1.plot(ts_data['date'], ts_data['do_mgl'], color='steelblue', label='DO (mg/L)')
  ax1.set_ylabel('DO (mg/L)', color='steelblue')
  ax2 = ax1.twinx()
  ax2.plot(ts_data['date'], ts_data['wtemp_c'], color='tomato', label='Temperature (°C)')
  ax2.set_ylabel('Water Temperature (°C)', color='tomato')
  ax1.set_title(f'Station {low_do_id}: DO and Temperature 2015-2022')
  fig.legend(loc='upper right', bbox_to_anchor=(0.88, 0.88))
  plt.tight_layout()
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 2
// =============================================================================

#exercise-header(number: 2, title: "Loading Polygon Data: Watershed Boundaries", difficulty: "Beginner")

#context-box[
  The USGS organizes the Chesapeake Bay drainage into HUC8 sub-basins (Hydrologic Unit Code, 8-digit), each representing a major tributary watershed such as the Potomac, Patuxent, or Upper Susquehanna. The file `chesapeake_watersheds.gpkg` is a GeoPackage containing 54 HUC8 sub-watershed boundaries for the Chesapeake Bay drainage area.

  This exercise introduces the GeoPackage format and the fundamental polygon operations: loading, structure inspection, area calculation in a projected CRS, and choropleth mapping.
]

*Your Primary Tasks*

- Read `chesapeake_watersheds.gpkg` using `st_read()` / `gpd.read_file()`
- Inspect the dataset: how many features (rows), how many attribute columns, what geometry type?
- Print the CRS. Is it geographic (degrees) or projected (meters)?
- Reproject to UTM Zone 18N (EPSG:32618) and calculate the area of each watershed in km²
- Add the calculated area as a new column
- Create a choropleth map: polygons colored by area, with watershed names labeled
- Which watershed is the largest? Which is the smallest?

#spatial-think-box[
  - What is a GeoPackage (`.gpkg`)? How does it differ from a Shapefile (`.shp`)? What are the practical advantages of GeoPackage?
  - If the data are stored in WGS84 (EPSG:4326, units = degrees), why can area not be calculated directly in km²? What does "one square degree" represent at different latitudes?
  - When you reproject to UTM 18N (EPSG:32618), what are the units of the coordinates? Does the geographic shape of the watershed change, or only its numerical representation?
  - For a choropleth of watershed areas, which palette type is appropriate: sequential, diverging, or qualitative?
  - Choropleth maps can visually overrepresent large polygons even when their values are not the most extreme. How should this be acknowledged when interpreting the map?
]

#hint-box[
  *Read a GeoPackage:* `ws <- st_read("chesapeake_watersheds.gpkg")`

  *Inspect structure:* `nrow(ws)`, `names(ws)`, `st_geometry_type(ws)`, `st_crs(ws)`

  *Reproject:* `ws_proj <- st_transform(ws, crs = 32618)`

  *Calculate area:*
  ```r
  ws_proj$area_km2 <- as.numeric(st_area(ws_proj)) / 1e6
  ```
  `st_area()` returns values in CRS units (m²); divide by 1,000,000 to convert to km².

  *Summary:* `summary(ws_proj$area_km2)`, `ws_proj[which.max(ws_proj$area_km2), "Name"]`

  *Choropleth map:*
  ```r
  tm_shape(ws_proj) +
    tm_polygons("area_km2", palette = "YlOrRd", title = "Area (km2)") +
    tm_text("Name", size = 0.5)
  ```
]

#python-hint-box[
  *Read a GeoPackage:* `ws = gpd.read_file("chesapeake_watersheds.gpkg")`

  *Inspect structure:* `ws.shape`, `ws.columns`, `ws.geom_type.unique()`, `ws.crs`

  *Reproject:* `ws_proj = ws.to_crs("EPSG:32618")`

  *Calculate area:*
  ```python
  ws_proj['area_km2'] = ws_proj.geometry.area / 1e6
  ```
  After projecting to UTM (meters), `.area` returns m²; divide by 1,000,000 for km².

  *Find largest/smallest:* `ws_proj.loc[ws_proj['area_km2'].idxmax(), 'Name']`

  *Plot choropleth:*
  ```python
  ws_proj.plot(column='area_km2', cmap='YlOrRd', legend=True,
               legend_kwds={'label': 'Area (km2)'})
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 3
// =============================================================================

#exercise-header(number: 3, title: "Spatial Joins with GeoJSON Data", difficulty: "Beginner")

#context-box[
  Water quality data collected at CBP stations is often aggregated and reported by county. This requires knowing which county each station falls within. That information is not stored in the station table; it must be derived by overlaying station points with county boundary polygons in a *spatial join*.

  The file `counties_chesapeake.geojson` contains county boundaries for Maryland, Virginia, Pennsylvania, Delaware, West Virginia, and New York -- the states that drain to the Chesapeake Bay. Each county polygon has attributes for county name, state abbreviation, and geographic identifiers. Available columns include: `county_name`, `state`, `geoid`, and `land_area_m2`. The goal is to transfer county attributes to each monitoring station record based on geographic containment.
]

*Your Primary Tasks*

- Read `counties_chesapeake.geojson`
- Inspect the GeoJSON: how many counties? What attributes are available? What is the CRS?
- Ensure the stations (Exercise 1) and counties are in the same CRS before joining
- Perform a spatial join: for each station point, identify the county polygon that contains it
- After the join, each station row should have new columns: `county_name` and `state`
- Count how many stations fall within each state
- Identify which counties contain at least one monitoring station
- Produce a map showing county boundaries in light gray, stations colored by `mean_do_mgl`, and state abbreviation labels

#spatial-think-box[
  - GeoJSON is a text-based format. Open `counties_chesapeake.geojson` in a text editor. How are geometries and attributes structured? How does this differ from a shapefile?
  - In a point-to-polygon spatial join, which dataset is the "left" (base) and which is the "right" (joined)? Does the ordering matter for the output?
  - What happens to a station that falls exactly on a county boundary? How does the software typically resolve this ambiguity?
  - Some stations may return NA for `county_name` after the join. When does this occur?
  - If you want to compare water quality across counties, what is the minimum number of stations per county needed to make a meaningful comparison?
]

#hint-box[
  *Read GeoJSON:* `counties <- st_read("counties_chesapeake.geojson")`

  *Check and align CRS:*
  ```r
  st_crs(stations_sf) == st_crs(counties)  # should be TRUE
  # If FALSE: counties <- st_transform(counties, st_crs(stations_sf))
  ```

  *Spatial join (point inherits attributes of the containing polygon):*
  ```r
  stations_joined <- st_join(stations_sf, counties[c("county_name", "state")],
                             join = st_within)
  ```

  *Count stations per state:* `table(stations_joined$state)`

  *Counties containing at least one station:*
  ```r
  unique(stations_joined$county_name[!is.na(stations_joined$county_name)])
  ```

  *Layered map:*
  ```r
  tm_shape(counties) + tm_borders(col = "gray70") +
    tm_shape(stations_joined) +
    tm_dots(col = "mean_do_mgl", palette = "viridis", size = 0.3)
  ```
]

#python-hint-box[
  *Read GeoJSON:* `counties = gpd.read_file("counties_chesapeake.geojson")`

  *Align CRS before joining:*
  ```python
  counties = counties.to_crs(stations_gdf.crs)
  ```

  *Spatial join:*
  ```python
  stations_joined = gpd.sjoin(
      stations_gdf,
      counties[['county_name', 'state', 'geometry']],
      how='left', predicate='within'
  )
  ```

  *Count per state:* `stations_joined['state'].value_counts()`

  *Counties with stations:* `stations_joined['county_name'].dropna().unique()`

  *Layered plot:*
  ```python
  fig, ax = plt.subplots()
  counties.plot(ax=ax, color='none', edgecolor='gray', linewidth=0.5)
  stations_joined.plot(ax=ax, column='mean_do_mgl', cmap='viridis', legend=True, markersize=25)
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 4
// =============================================================================

#exercise-header(number: 4, title: "Digital Elevation Models: Loading and Classifying GeoTIFF Rasters", difficulty: "Intermediate")

#context-box[
  Terrain determines where water flows, where it accumulates, and how fast it moves. Watershed topography controls stream gradients, flood-prone areas, and the transport pathways of sediment and nutrients from upland sources to waterways. The USGS 3DEP (3D Elevation Program) dataset provides a national DEM at 300 m resolution, where each raster cell contains the surface elevation in meters.

  The file `chesapeake_dem.tif` is a GeoTIFF DEM clipped to the Chesapeake Bay watershed extent. The tasks below cover the basic raster inspection and classification workflow: loading, examining metadata, reclassifying continuous values into discrete zones, computing class statistics, and producing an elevation map with vector overlay.
]

*Your Primary Tasks*

- Load `chesapeake_dem.tif` using `terra::rast()` / `rasterio.open()`
- Print the key raster properties: number of rows and columns, cell resolution (in CRS units), CRS, and value range (min/max elevation in meters)
- How many total cells are there? What fraction have NoData values?
- Reclassify the raster into three elevation zones: Low (0 to 100 m), Mid (100 to 300 m), High (greater than 300 m)
- Calculate the percentage of the watershed in each elevation class
- Plot the continuous DEM with a terrain color ramp
- Plot the classified raster with a three-color palette and a labeled legend
- Overlay the watershed boundaries from Exercise 2 on the elevation map; ensure CRS alignment before overlaying

#spatial-think-box[
  - What three pieces of metadata transform an ordinary image grid into a spatial raster? (Extent, resolution, and CRS)
  - Why is a projected CRS such as UTM Zone 18N preferable to WGS84 for terrain analysis?
  - When reclassifying a continuous DEM into discrete elevation zones, what information is lost? When is this trade-off appropriate?
  - NoData cells in a DEM typically represent water bodies. How should they appear in the map, and how should they be treated in cell-count statistics?
  - When overlaying watershed polygon boundaries on a 300 m raster, what happens if the two layers are in different CRSs?
]

#hint-box[
  *Load raster:* `dem <- terra::rast("chesapeake_dem.tif")`

  *Inspect properties:*
  ```r
  dim(dem)         # rows, columns, layers
  res(dem)         # cell size in CRS units (meters if projected)
  crs(dem)         # coordinate reference system
  minmax(dem)      # min and max values
  global(dem, "notNA") / ncell(dem)  # fraction with valid data
  ```

  *Reclassify into zones:*
  ```r
  m <- matrix(c(0, 100, 1, 100, 300, 2, 300, Inf, 3), ncol = 3, byrow = TRUE)
  dem_class <- classify(dem, m)
  levels(dem_class) <- data.frame(value = 1:3,
                                  label = c("Low (0-100 m)", "Mid (100-300 m)", "High (>300 m)"))
  ```

  *Area percentage:*
  ```r
  freq_table <- freq(dem_class)
  freq_table$pct <- freq_table$count / sum(freq_table$count) * 100
  ```

  *Plot:* `plot(dem, col = terrain.colors(50), main = "Chesapeake Bay Watershed Elevation")`

  *Overlay watershed boundaries:*
  ```r
  ws_reproj <- st_transform(ws, crs(dem))
  plot(vect(ws_reproj), add = TRUE, border = "black", lwd = 1.5)
  ```
]

#python-hint-box[
  *Load raster:*
  ```python
  import rasterio
  import numpy as np

  with rasterio.open("chesapeake_dem.tif") as src:
      dem = src.read(1).astype(float)
      dem[dem == src.nodata] = np.nan
      meta    = src.meta
      transform = src.transform
      crs     = src.crs
      print(f"Resolution: {src.res}")
      print(f"CRS: {src.crs}")
      print(f"Shape: {src.height} rows x {src.width} cols")
      print(f"Value range: {np.nanmin(dem):.1f} to {np.nanmax(dem):.1f} m")
  ```

  *Reclassify:*
  ```python
  dem_class = np.full_like(dem, np.nan)
  dem_class[(dem >= 0)   & (dem < 100)] = 1
  dem_class[(dem >= 100) & (dem < 300)] = 2
  dem_class[dem >= 300]                 = 3
  ```

  *Area percentage:*
  ```python
  for zone, label in zip([1, 2, 3], ["Low", "Mid", "High"]):
      pct = np.nansum(dem_class == zone) / np.sum(~np.isnan(dem_class)) * 100
      print(f"{label}: {pct:.1f}%")
  ```

  *Plot:* `plt.imshow(dem, cmap='terrain')` with `plt.colorbar(label='Elevation (m)')`
]

#pagebreak()

// =============================================================================
// EXERCISE 5
// =============================================================================

#exercise-header(number: 5, title: "Loading Precipitation Data from NetCDF", difficulty: "Intermediate")

#context-box[
  NetCDF (Network Common Data Form) is the standard format for multi-dimensional environmental data: a single file holds multiple variables across multiple time steps. The MSWEP (Multi-Source Weighted-Ensemble Precipitation) dataset provides global monthly precipitation estimates at 0.1 degree resolution, combining rain gauge observations, satellite retrievals, and reanalysis output.

  The file `mswep_monthly.nc` contains MSWEP monthly precipitation clipped to the Chesapeake Bay watershed extent for 2015 to 2019. Values are in mm/day (variable name: `precipitation`). The tasks below cover the full workflow: loading and inspecting a NetCDF, unit conversion, temporal aggregation, and spatial mapping.
]

*Your Primary Tasks*

- Load `mswep_monthly.nc` and inspect its structure: variables, dimensions (lat, lon, time), and time range
- Extract the precipitation variable and verify its units (mm/day)
- Convert each monthly layer from mm/day to mm/month by multiplying by the number of days in that month
- Compute: (a) the mean monthly precipitation map averaged across all months, (b) total annual precipitation for each year, and (c) the wettest and driest year in the record
- Map the long-term mean annual precipitation as a raster with the watershed boundaries overlaid
- Identify the spatial pattern: which part of the watershed receives the most precipitation?

#spatial-think-box[
  - A NetCDF has named dimensions (lat, lon, time) and named variables stored over those dimensions. How is this structurally different from a GeoTIFF?
  - If precipitation is in mm/day, why must the number of days per month be known before converting to monthly totals? (Compare February and August.)
  - To compute mean annual precipitation, should you sum the 12 monthly values or average them? What does each operation give you?
  - Based on the elevation pattern from Exercise 4, where would you expect precipitation to be highest in the watershed? Why?
  - The MSWEP grid is in WGS84 at 0.1 degree resolution. Is reprojection needed to overlay the watershed boundaries? What challenges arise when combining a coarse raster with detailed polygon boundaries?
]

#hint-box[
  *Load NetCDF with terra:*
  ```r
  library(terra)
  prec <- rast("mswep_monthly.nc")
  ```

  *Inspect:* print `prec` to see all layers and time stamps; use `time(prec)` for dates

  *Convert mm/day to mm/month:*
  ```r
  library(lubridate)
  days <- days_in_month(time(prec))
  prec_mm <- prec * days
  ```

  *Annual total grouped by year:*
  ```r
  years  <- format(time(prec_mm), "%Y")
  annual <- tapp(prec_mm, years, sum)
  ```

  *Long-term mean annual:* `mean_annual <- mean(annual)`

  *Plot with watershed overlay:*
  ```r
  plot(mean_annual, main = "Mean Annual Precipitation (mm)")
  plot(vect(st_transform(ws, crs(mean_annual))), add = TRUE, border = "black")
  ```
]

#python-hint-box[
  *Load NetCDF with xarray:*
  ```python
  import xarray as xr
  prec = xr.open_dataset("mswep_monthly.nc")
  prec_var = prec['precipitation']
  ```

  *Inspect dimensions:* `prec_var.dims`, `prec_var.coords['time'].values`

  *Convert mm/day to mm/month:*
  ```python
  import pandas as pd
  times = pd.DatetimeIndex(prec_var.coords['time'].values)
  days  = times.days_in_month
  prec_mm = prec_var * xr.DataArray(days, coords=[prec_var.coords['time']], dims=['time'])
  ```

  *Annual total:* `annual = prec_mm.resample(time='YE').sum()`

  *Long-term mean annual:* `mean_annual = annual.mean(dim='time')`

  *Wettest year:*
  ```python
  basin_annual = annual.mean(dim=['lat', 'lon'])
  wettest_year = basin_annual.idxmax().item()
  ```

  *Plot:* `mean_annual.plot(cmap='Blues', robust=True)`
]

#pagebreak()

// =============================================================================
// EXERCISE 6
// =============================================================================

#exercise-header(number: 6, title: "Riparian Buffer Analysis", difficulty: "Intermediate")

#context-box[
  Riparian buffers are strips of vegetation maintained along stream banks to intercept nutrient and sediment runoff before it reaches the waterway. Maryland law requires a minimum 100-foot (approximately 30 m) buffer along streams draining more than one-third of a square mile. Management guidelines from the Chesapeake Bay Program recommend wider buffers of 35 to 300 m depending on adjacent land use and slope.

  The file `chesapeake_streams.gpkg` contains the major stream and river network of the Chesapeake Bay watershed as line features (from the National Hydrography Dataset). The dataset includes approximately 7,100 major stream features (NHD stream order level >= 6). Key columns include `NAME` (stream name), `FTYPE`, `FCODE_DESC`, `STRM_LEVEL` (stream order level), and `METERS` (feature length). This exercise covers the buffer operation, dissolving overlapping geometries, area calculation, and a point-in-polygon spatial filter.
]

*Your Primary Tasks*

- Load `chesapeake_streams.gpkg`; inspect the number of line features and available attributes
- Check the CRS. If geographic (degrees), reproject to UTM Zone 18N (EPSG:32618) before buffering
- Create buffers at three distances: 100 m, 300 m, and 500 m around all stream lines
- Dissolve (union) the overlapping buffer polygons for each distance, then calculate the total buffered area in km²
- Does total buffered area scale linearly with buffer distance? Why or why not?
- Identify which monitoring stations from Exercise 1 fall within the 500 m buffer
- Produce a map showing stream lines, the 500 m buffer zone (semi-transparent), and stations colored by whether they are inside or outside the buffer

#spatial-think-box[
  - Buffer operations require projected coordinates. Why does buffering in geographic degrees produce geometrically incorrect results, particularly at higher latitudes?
  - Adjacent streams produce overlapping buffer polygons. Why must these be dissolved before computing total area? What error would result from summing the areas of individual, overlapping polygons?
  - The three buffers are nested: the 300 m buffer fully contains the 100 m buffer. If you want the area of only the 100-300 m annular ring, what geometric operation gives that?
  - Identifying stations within the buffer is a point-in-polygon test. Which spatial predicate function performs this test?
  - Would a station inside the 500 m riparian buffer be expected to show better or worse water quality than stations outside? What factors could produce either result?
]

#hint-box[
  *Load and reproject:*
  ```r
  streams <- st_read("chesapeake_streams.gpkg")
  streams_proj <- st_transform(streams, 32618)
  ```

  *Inspect stream attributes:* `names(streams)` -- key columns include `NAME`, `STRM_LEVEL`, `METERS`

  *Create buffers:*
  ```r
  buf_100 <- st_buffer(streams_proj, dist = 100)
  buf_300 <- st_buffer(streams_proj, dist = 300)
  buf_500 <- st_buffer(streams_proj, dist = 500)
  ```

  *Dissolve overlapping buffers and compute area:*
  ```r
  buf_100_union <- st_union(buf_100)
  area_100_km2  <- as.numeric(st_area(buf_100_union)) / 1e6
  ```

  *Stations within 500 m buffer:*
  ```r
  stations_proj <- st_transform(stations_sf, 32618)
  in_buffer <- st_within(stations_proj, buf_500_union, sparse = FALSE)[, 1]
  stations_proj$in_buffer <- in_buffer
  ```

  *Map:*
  ```r
  tm_shape(buf_500_union) + tm_fill(col = "lightblue", alpha = 0.4) +
    tm_shape(streams_proj) + tm_lines(col = "steelblue", lwd = 0.5) +
    tm_shape(stations_proj) + tm_dots(col = "in_buffer",
                                      palette = c("red", "green"), size = 0.3)
  ```
]

#python-hint-box[
  *Load and reproject:*
  ```python
  streams = gpd.read_file("chesapeake_streams.gpkg")
  streams_proj = streams.to_crs("EPSG:32618")
  ```

  *Inspect stream attributes:* `streams.columns` -- key columns include `NAME`, `STRM_LEVEL`, `METERS`

  *Create buffers:*
  ```python
  buf_100 = streams_proj.buffer(100)
  buf_300 = streams_proj.buffer(300)
  buf_500 = streams_proj.buffer(500)
  ```

  *Union overlapping buffers and compute area:*
  ```python
  buf_100_union = buf_100.unary_union
  area_100_km2  = buf_100_union.area / 1e6
  ```

  *Stations within 500 m buffer:*
  ```python
  stations_proj = stations_gdf.to_crs("EPSG:32618")
  stations_proj['in_buffer'] = stations_proj.geometry.within(buf_500.unary_union)
  ```

  *Map:*
  ```python
  fig, ax = plt.subplots()
  gpd.GeoSeries([buf_500.unary_union]).plot(ax=ax, color='lightblue', alpha=0.4)
  streams_proj.plot(ax=ax, color='steelblue', linewidth=0.3)
  stations_proj.plot(ax=ax, column='in_buffer', cmap='RdYlGn', markersize=25, legend=True)
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 7
// =============================================================================

#exercise-header(number: 7, title: "Zonal Statistics: Raster Summaries by Watershed", difficulty: "Intermediate")

#context-box[
  Zonal statistics summarize the values of a raster within each polygon of a vector layer. This is one of the most common operations in environmental spatial analysis: for example, computing mean annual precipitation per watershed, mean NDVI per land management unit, or total forest loss per protected area.

  Using the watershed boundaries from Exercise 2 and the mean annual precipitation raster derived in Exercise 5, compute precipitation statistics for each of the 54 Chesapeake Bay sub-watersheds and explore the relationship between precipitation and water quality.
]

*Your Primary Tasks*

- Load the watershed boundaries and the mean annual precipitation raster from Exercise 5
- Confirm that the raster and polygon layers are in the same CRS; reproject if needed
- Use `exactextractr::exact_extract()` / `rasterstats.zonal_stats()` to compute, for each watershed: mean, minimum, maximum, and standard deviation of annual precipitation
- Join the zonal statistics results back to the watershed polygon data frame
- Map mean annual precipitation per watershed as a choropleth
- Plot a scatter plot of watershed area vs. mean precipitation
- Advanced: join mean station DO per watershed (from Exercise 3) and plot DO vs. mean precipitation. Is there a statistically interpretable pattern?

#spatial-think-box[
  - When a raster cell straddles a polygon boundary, how should its value be allocated? Compare two approaches: (a) assign the cell to the zone that covers its center point, or (b) weight the cell's contribution by the fraction of its area within each zone. Which is more accurate for irregular polygons?
  - The `exactextractr` package uses fractional area weighting. When does this correction matter most: when raster cells are large relative to the polygons, or when they are small?
  - After computing zonal statistics, the result is a plain data frame with no geometry. What step is needed before you can map it as a choropleth?
  - High precipitation standard deviation within a watershed indicates spatially variable rainfall. What landscape factors could produce this pattern?
  - If a positive correlation is found between precipitation and DO, what mechanisms could explain it? What confounders might produce a spurious correlation?
]

#hint-box[
  *Key package:* `exactextractr` (more accurate than `terra::extract` for polygons)
  ```r
  library(exactextractr)
  ```

  *Align CRS:* `ws_reproj <- st_transform(ws, crs(mean_annual))`

  *Zonal statistics:*
  ```r
  zonal_stats <- exact_extract(mean_annual, ws_reproj,
                               fun = c("mean", "min", "max", "stdev"),
                               append_cols = "Name")
  ```

  *Join back to spatial data:*
  ```r
  ws_with_precip <- merge(ws_reproj, zonal_stats, by = "Name")
  ```

  *Choropleth:*
  ```r
  tm_shape(ws_with_precip) +
    tm_polygons("mean", palette = "Blues", title = "Mean Annual Precip (mm)")
  ```

  *Scatter plot:*
  ```r
  plot(ws_with_precip$area_km2, ws_with_precip$mean,
       xlab = "Area (km2)", ylab = "Mean Annual Precip (mm)")
  ```
]

#python-hint-box[
  *Key package:* `rasterstats`
  ```python
  from rasterstats import zonal_stats
  ```

  *Align CRS:* `ws_reproj = ws.to_crs(mean_annual_crs_string)`

  *Zonal statistics (provide raster filepath or array + affine transform):*
  ```python
  stats    = zonal_stats(ws_reproj, "mean_annual_precip.tif",
                         stats=["mean", "min", "max", "std"])
  zonal_df = pd.DataFrame(stats)
  zonal_df.columns = ['precip_' + c for c in zonal_df.columns]
  ```

  *Join back to GeoDataFrame:*
  ```python
  ws_with_precip = pd.concat(
      [ws_reproj.reset_index(drop=True), zonal_df], axis=1
  )
  ```

  *Choropleth:*
  ```python
  ws_with_precip.plot(column='precip_mean', cmap='Blues', legend=True,
                      legend_kwds={'label': 'Mean Annual Precip (mm)'})
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 8
// =============================================================================

#exercise-header(number: 8, title: "Categorical Raster Analysis: National Land Cover Data", difficulty: "Intermediate")

#context-box[
  Land use composition is a primary predictor of nutrient loading in Chesapeake Bay tributaries. Agricultural land (cropland and pasture) is the dominant source of nitrogen and phosphorus; urban impervious surfaces export sediment and metals; forest buffers nutrient export through uptake and interception. The National Land Cover Database (NLCD) provides a 300 m categorical raster of land cover for the contiguous United States, updated approximately every three years.

  The file `nlcd_chesapeake.tif` contains NLCD 2021 land cover clipped to the watershed (Albers Equal Area, EPSG:5070). Cell values are integer class codes: 11 = Open Water, 21-24 = Developed (low to high intensity), 31 = Barren, 41-43 = Forest, 52 = Shrub, 71 = Herbaceous, 81-82 = Agriculture (hay/pasture and cropland), 90-95 = Wetlands.

  The tasks below cover loading and inspecting a categorical raster, reclassification into aggregated classes, and zonal summarization by watershed.
]

*Your Primary Tasks*

- Load `nlcd_chesapeake.tif`; print the unique cell values and confirm they match NLCD class codes
- Reclassify the detailed NLCD codes into four aggregated categories: Forest (classes 41-43), Agriculture (classes 81-82), Urban (classes 21-24), and Other (all remaining classes)
- Using zonal statistics (as in Exercise 7), calculate the percentage of each watershed covered by Forest and Agriculture
- Join the land cover percentages to the watershed polygon data frame
- Produce a two-panel map: (a) % Agriculture and (b) % Forest, displayed side by side
- Plot % Agriculture vs. mean station DO per watershed (from Exercise 3). Does the pattern support the eutrophication hypothesis?

#spatial-think-box[
  - Categorical rasters store class codes (integers), not continuous measurements. Why is computing the mean of a categorical raster meaningless? What summary statistic is appropriate?
  - To calculate the percentage of a watershed covered by agriculture, you need to count cells in classes 81 and 82 and divide by the total cell count. How does `exact_extract` need to be configured differently for a categorical raster compared to a continuous one?
  - After reclassifying, the raster still holds integers (1, 2, 3, 4). How do you assign human-readable labels to these integer codes in R and Python?
  - The NLCD is at 300 m resolution; watersheds contain many cells. At what relative scale does fractional cell weighting (Exercise 7) become less important?
  - When relating % Agriculture (a watershed-level variable) to mean station DO (computed from multiple point observations per watershed), how do you handle watersheds with different numbers of stations?
]

#hint-box[
  *Load categorical raster:*
  ```r
  nlcd <- rast("nlcd_chesapeake.tif")
  unique_vals <- unique(nlcd)
  ```

  *Reclassify to 4 categories:*
  ```r
  rcl <- matrix(c(
    11, 11, 4,   # Water    -> Other
    21, 24, 3,   # Urban
    31, 31, 4,   # Barren   -> Other
    41, 43, 1,   # Forest
    52, 52, 4,
    71, 71, 4,
    81, 82, 2,   # Agriculture
    90, 95, 4    # Wetlands -> Other
  ), ncol = 3, byrow = TRUE)
  nlcd_reclass <- classify(nlcd, rcl)
  levels(nlcd_reclass) <- data.frame(value = 1:4,
                                     label = c("Forest", "Agriculture", "Urban", "Other"))
  ```

  *Zonal stats for categorical raster (proportion per class):*
  ```r
  pct <- exact_extract(nlcd_reclass, ws_reproj, function(values, coverage_fraction) {
    tab <- table(values[!is.na(values)])
    prop.table(tab)
  })
  ```

  *Two-panel map:*
  ```r
  m1 <- tm_shape(ws) + tm_polygons("pct_agr", palette = "YlOrBr", title = "% Agriculture")
  m2 <- tm_shape(ws) + tm_polygons("pct_for", palette = "Greens",  title = "% Forest")
  tmap_arrange(m1, m2)
  ```
]

#python-hint-box[
  *Load categorical raster:*
  ```python
  with rasterio.open("nlcd_chesapeake.tif") as src:
      nlcd = src.read(1)
  ```

  *Reclassify:*
  ```python
  nlcd_reclass = np.full_like(nlcd, 4, dtype=np.int16)  # default: Other
  nlcd_reclass[np.isin(nlcd, [41, 42, 43])]        = 1  # Forest
  nlcd_reclass[np.isin(nlcd, [81, 82])]            = 2  # Agriculture
  nlcd_reclass[np.isin(nlcd, [21, 22, 23, 24])]    = 3  # Urban
  ```

  *Zonal stats for categorical raster:*
  ```python
  from rasterstats import zonal_stats
  agr_stats = zonal_stats(ws_reproj, nlcd_reclass_filepath,
                           categorical=True,
                           category_map={1: "forest", 2: "agr", 3: "urban", 4: "other"})
  ```

  *Calculate percentages from category counts:*
  ```python
  zonal_df     = pd.DataFrame(agr_stats)
  totals       = zonal_df.sum(axis=1)
  zonal_df_pct = zonal_df.div(totals, axis=0) * 100
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 9
// =============================================================================

#exercise-header(number: 9, title: "Coordinate Reference Systems and Reprojection", difficulty: "Intermediate")

#context-box[
  CRS errors are the most common source of mistakes in spatial analysis, and they are frequently silent. Data loads without error, plots without warnings, and produces numerically plausible results. Errors become apparent only when values are cross-checked against external references: distances may be off by tens of percent, areas wrong by a factor of two, or two layers that appear to overlap may actually be thousands of kilometers apart in their native coordinates.

  This exercise demonstrates the consequences of using an inappropriate or mismatched CRS, and shows the correct workflow: verifying CRS, reprojecting to a suitable coordinate system before analysis, and using the appropriate projection type (geographic vs. projected vs. equal-area) for each operation.
]

*Your Primary Tasks*

- Load the monitoring stations from Exercise 1 (WGS84, EPSG:4326)
- Compute the Euclidean distance between two stations *in geographic coordinates* (degrees). Record the result.
- Reproject both stations to UTM Zone 18N (EPSG:32618) and recalculate the same distance in meters, then convert to km
- Compute the percentage error: `(degrees_value - km_value) / km_value * 100`. Note whether this is a negligible or significant error.
- Select one large watershed polygon. Calculate its area in: (a) WGS84 using naive planar geometry (square degrees), (b) UTM 18N (km²), and (c) WGS84 using ellipsoidal calculations via `st_area()` / `pyproj.Geod`. Compare all three results.
- Load the NLCD raster (stored in Albers Equal Area, EPSG:5070) and the watershed polygons (WGS84). Attempt to overlay them without reprojecting. Describe what happens. Then fix it.
- Summarize results in a table: operation, CRS used, computed value, correct value.

#spatial-think-box[
  - A degree of longitude at 39 degrees N (central Maryland) spans approximately 86 km, while a degree of latitude spans approximately 111 km. How does this non-uniform scaling affect Euclidean distance calculations in geographic coordinates?
  - The NLCD uses Albers Equal Area (EPSG:5070), which is designed to preserve areas. The watershed polygons may be in WGS84. What practical advantages does each CRS offer, and what are the trade-offs?
  - When `st_transform()` is called, the coordinate values change but the geographic locations on Earth do not. What is happening geometrically?
  - If two layers appear to overlap on a map but have different EPSG codes, what does this indicate?
  - `st_area()` in the `sf` package can compute accurate areas from geographic coordinates using the ellipsoidal model. How does this differ from squaring coordinate differences? When is reprojecting to a projected CRS preferable?
]

#hint-box[
  *Euclidean distance in geographic coordinates (incorrect for ground distance):*
  ```r
  # Force planar Euclidean computation by stripping CRS
  dist_euclid <- st_distance(st_set_crs(stations_sf, NA))
  ```

  *Ellipsoidal distance via sf (correct):*
  ```r
  dist_sf <- st_distance(stations_sf)  # sf uses ellipsoidal model by default
  ```

  *Projected distance (UTM):*
  ```r
  stations_utm <- st_transform(stations_sf, 32618)
  dist_utm <- st_distance(stations_utm)   # returns meters
  dist_km  <- units::set_units(dist_utm, "km")
  ```

  *Area comparison:*
  ```r
  ws_geo  <- ws[1, ]
  ws_utm  <- st_transform(ws_geo, 32618)
  area_ellipsoidal <- as.numeric(st_area(ws_geo)) / 1e6    # m2 to km2
  area_utm         <- as.numeric(st_area(ws_utm)) / 1e6
  cat("Ellipsoidal:", area_ellipsoidal, "km2\n")
  cat("UTM:", area_utm, "km2\n")
  ```

  *Check for CRS mismatch:* `st_crs(layer1) == st_crs(layer2)` returns TRUE or FALSE

  *Reproject NLCD raster to match watershed CRS (or vice versa):*
  ```r
  nlcd_wgs84 <- project(nlcd, "EPSG:4326")
  # Or reproject the vector to match the raster:
  ws_albers <- st_transform(ws, "EPSG:5070")
  ```
]

#python-hint-box[
  *Euclidean distance in geographic coordinates (incorrect):*
  ```python
  p1 = stations_gdf.geometry.iloc[0]
  p2 = stations_gdf.geometry.iloc[5]
  dist_deg = p1.distance(p2)  # in degrees -- meaningless as a ground distance
  ```

  *Projected distance (UTM):*
  ```python
  stations_utm = stations_gdf.to_crs("EPSG:32618")
  p1_utm = stations_utm.geometry.iloc[0]
  p2_utm = stations_utm.geometry.iloc[5]
  dist_m  = p1_utm.distance(p2_utm)
  dist_km = dist_m / 1000
  ```

  *Ellipsoidal area using pyproj:*
  ```python
  from pyproj import Geod
  geod    = Geod(ellps="WGS84")
  poly    = ws.geometry.values[0]
  area_m2, _ = geod.geometry_area_perimeter(poly)
  area_km2   = abs(area_m2) / 1e6
  ```

  *Projected area (UTM):*
  ```python
  ws_utm = ws.to_crs("EPSG:32618")
  area_utm_km2 = ws_utm.geometry.area.values[0] / 1e6
  ```

  *Check CRS match:* `layer1.crs == layer2.crs`
]

#pagebreak()

// =============================================================================
// EXERCISE 10
// =============================================================================

#exercise-header(number: 10, title: "Integrated Spatial Analysis: Watershed Risk Assessment", difficulty: "Advanced")

#context-box[
  This exercise integrates all datasets and operations from the previous exercises into a single analysis pipeline. The objective is to identify which Chesapeake Bay sub-watersheds present the highest risk of contributing to hypoxic conditions in the main stem Bay. The working hypothesis is that risk is proportional to three factors: (1) agricultural land cover fraction (nutrient source), (2) mean annual precipitation (nutrient transport), and (3) low dissolved oxygen measured at in-watershed monitoring stations (observed impact).

  The output is a composite risk score for each watershed and a four-panel publication-quality map summarizing each indicator and the combined classification.
]

*Your Primary Tasks*

*Step 1: Assemble the watershed-level data table*

- Join the watershed polygons with: (a) mean annual precipitation (Exercise 7), (b) percent agricultural cover (Exercise 8), and (c) mean dissolved oxygen averaged across all stations in each watershed (Exercise 3)
- The result should be one row per watershed with all three indicators as columns

*Step 2: Normalize and compute a composite risk score*

- Normalize each indicator to [0, 1]: `(x - min(x)) / (max(x) - min(x))`
- Risk score = 0.4 x norm_agr + 0.4 x norm_prec + 0.2 x (1 - norm_do)
- High agriculture and high precipitation increase risk; high DO decreases risk (hence the inversion)
- Classify watersheds as High Risk (score > 0.6), Moderate Risk (0.3 to 0.6), or Low Risk (score < 0.3)

*Step 3: Produce the four-panel map*

- Panel A: % Agricultural Cover (choropleth)
- Panel B: Mean Annual Precipitation (choropleth)
- Panel C: Mean Station DO (choropleth with station points overlaid)
- Panel D: Composite Risk Classification (three-class, colorblind-friendly palette)

Add a scale bar and north arrow to at least one panel. Write a three-sentence interpretive caption.

#spatial-think-box[
  - The weighting scheme assigns 0.4 to agriculture, 0.4 to precipitation, and 0.2 to observed DO. What assumptions does equal weighting between agriculture and precipitation imply? How would you adjust weights if one predictor had stronger empirical support?
  - Some watersheds may have no monitoring stations, resulting in NA for mean DO. How will you handle NA values in the normalization step and the risk score calculation?
  - To allow valid visual comparison across all four panels, what must be consistent across panels in the map layout?
  - Walk through the DO inversion: if watershed A has the highest mean DO in the dataset and watershed B has the lowest, what normalized and inverted values do they receive? What risk contribution does each make?
  - What environmental stressors or processes does this three-variable risk score fail to capture? What additional data layers would improve it?
]

#hint-box[
  *Assemble and normalize:*
  ```r
  ws_risk <- ws_with_precip                                    # from Ex 7
  ws_risk <- merge(ws_risk, land_cover_pct,   by = "Name")    # from Ex 8
  ws_risk <- merge(ws_risk, station_do_by_ws, by = "Name")    # from Ex 3

  normalize <- function(x) (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
  ws_risk$norm_agr  <- normalize(ws_risk$pct_agr)
  ws_risk$norm_prec <- normalize(ws_risk$precip_mean)
  ws_risk$norm_do   <- normalize(ws_risk$mean_do)

  ws_risk$risk_score <- 0.4 * ws_risk$norm_agr + 0.4 * ws_risk$norm_prec +
                        0.2 * (1 - ws_risk$norm_do)

  ws_risk$risk_class <- cut(ws_risk$risk_score,
    breaks = c(-Inf, 0.3, 0.6, Inf),
    labels = c("Low Risk", "Moderate Risk", "High Risk"))
  ```

  *Four-panel map with tmap:*
  ```r
  pA <- tm_shape(ws_risk) + tm_polygons("pct_agr",     palette = "YlOrBr", title = "% Agriculture")
  pB <- tm_shape(ws_risk) + tm_polygons("precip_mean", palette = "Blues",  title = "Precip (mm/yr)")
  pC <- tm_shape(ws_risk) + tm_polygons("mean_do",     palette = "RdYlGn", title = "Mean DO (mg/L)") +
        tm_shape(stations_sf) + tm_dots(size = 0.15)
  pD <- tm_shape(ws_risk) + tm_polygons("risk_class",
                                         palette = c("#1a9641", "#fdae61", "#d7191c"),
                                         title = "Risk Level") +
        tm_scale_bar(position = c("left", "bottom")) + tm_compass()
  tmap_arrange(pA, pB, pC, pD, ncol = 2)
  ```
]

#python-hint-box[
  *Assemble and normalize:*
  ```python
  ws_risk = ws_with_precip.copy()
  ws_risk = ws_risk.merge(land_cover_pct,   on='Name')
  ws_risk = ws_risk.merge(station_do_by_ws, on='Name')

  def normalize(s):
      return (s - s.min()) / (s.max() - s.min())

  ws_risk['norm_agr']  = normalize(ws_risk['pct_agr'])
  ws_risk['norm_prec'] = normalize(ws_risk['precip_mean'])
  ws_risk['norm_do']   = normalize(ws_risk['mean_do'])

  ws_risk['risk_score'] = (0.4 * ws_risk['norm_agr'] +
                            0.4 * ws_risk['norm_prec'] +
                            0.2 * (1 - ws_risk['norm_do']))

  ws_risk['risk_class'] = pd.cut(ws_risk['risk_score'],
                                  bins=[-np.inf, 0.3, 0.6, np.inf],
                                  labels=["Low Risk", "Moderate Risk", "High Risk"])
  ```

  *Four-panel map:*
  ```python
  fig, axes = plt.subplots(2, 2, figsize=(14, 10))

  ws_risk.plot(column='pct_agr',     cmap='YlOrBr', legend=True, ax=axes[0, 0])
  ws_risk.plot(column='precip_mean', cmap='Blues',  legend=True, ax=axes[0, 1])
  ws_risk.plot(column='mean_do',     cmap='RdYlGn', legend=True, ax=axes[1, 0])
  stations_gdf.plot(ax=axes[1, 0], color='black', markersize=5)
  ws_risk.plot(column='risk_class', categorical=True,
               color=['#1a9641', '#fdae61', '#d7191c'], legend=True, ax=axes[1, 1])

  titles = ['A: % Agriculture', 'B: Mean Precipitation',
            'C: Mean DO', 'D: Risk Classification']
  for ax, title in zip(axes.flat, titles):
      ax.set_title(title, fontsize=11, fontweight='bold')
      ax.set_axis_off()

  plt.tight_layout()
  ```
]

#v(2em)
#align(center)[
  #text(size: 10pt, fill: text-color.lighten(40%))[
    End of Exercise Document
  ]
]
