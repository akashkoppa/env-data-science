# =============================================================================
# Lecture 5: Spatial Data and Mapping — Exercise Solutions (R)
# ENST431/631: Environmental Data Science
# Author: Akash Koppa
# =============================================================================
# Working directory assumed to be the folder containing all data files.

library(sf)
library(terra)
library(tmap)
library(tidyverse)
library(exactextractr)
library(lubridate)
library(units)

# Use tmap in plot mode for file output
tmap_mode("plot")


# =============================================================================
# EXERCISE 1: Loading Point Data from a CSV File
# =============================================================================

# --- Load and inspect the CSV ---
stations <- read.csv("/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/06_Spatial/stations.csv")

cat("=== Exercise 1: Station CSV Inspection ===\n")
cat("Number of rows:", nrow(stations), "\n")
cat("Column names:", paste(names(stations), collapse = ", "), "\n")
cat("Missing lat/lon values:", sum(is.na(stations$lat) | is.na(stations$lon)), "\n")
str(stations)

# --- Convert to sf spatial object ---
# coords = c("lon", "lat") — order matters: X (longitude) first, Y (latitude) second
stations_sf <- st_as_sf(stations, coords = c("lon", "lat"), crs = 4326)

# --- Verify CRS and spatial extent ---
cat("\nCRS:\n")
print(st_crs(stations_sf))

cat("\nBounding box (xmin=W, ymin=S, xmax=E, ymax=N):\n")
print(st_bbox(stations_sf))

# --- Identify the three stations with the lowest mean DO ---
low_do_idx    <- order(stations_sf$mean_do_mgl)[1:3]
low_do_stns   <- stations_sf[low_do_idx, ]

cat("\nThree stations with lowest mean dissolved oxygen:\n")
print(low_do_stns[, c("station_id", "description", "watershed", "mean_do_mgl")])

# --- Map: stations colored by mean DO, lowest three labeled ---
map_ex01 <- tm_shape(stations_sf) +
  tm_dots(
    col       = "mean_do_mgl",
    palette   = "viridis",
    title     = "Mean DO (mg/L)",
    size      = 0.4,
    border.col = "white",
    border.lwd = 0.5
  ) +
  tm_shape(low_do_stns) +
  tm_text(
    "station_id",
    size   = 0.65,
    col    = "red",
    ymod   = 0.5,
    fontface = "bold"
  ) +
  tm_layout(
    title          = "CBP Water Quality Monitoring Stations\n(Red labels = lowest mean DO)",
    title.size     = 0.85,
    legend.outside = TRUE,
    frame          = TRUE
  ) +
  tm_compass(position = c("right", "top"), size = 1.5) +
  tm_scale_bar(position = c("left", "bottom"))

tmap_save(map_ex01, "/Users/akashkoppa/Documents/ex01_stations.png", width = 7, height = 5, dpi = 150)
cat("\nSaved: ex01_stations.png\n")

# --- Part B: Station Time Series ---
# Find the station with lowest mean DO
low_do_id <- stations_sf$station_id[order(stations_sf$mean_do_mgl)[1]]
cat("Lowest mean DO station:", low_do_id, "\n")

# Load its time series (filenames use hyphens for slashes in station IDs)
ts_fname <- paste0(gsub("/", "-", low_do_id), ".csv")
ts_data  <- read.csv(file.path("station_data", ts_fname))
ts_data$date <- as.Date(ts_data$date)

cat("Date range:", as.character(min(ts_data$date)), "to", as.character(max(ts_data$date)), "\n")
cat("Mean DO:", round(mean(ts_data$do_mgl, na.rm=TRUE), 2), "mg/L\n")
cat("Mean Temp:", round(mean(ts_data$wtemp_c, na.rm=TRUE), 1), "°C\n")

# Dual y-axis time series plot
png("ex01b_timeseries.png", width=1100, height=400, res=120)
par(mar = c(4, 4.5, 3, 4.5))
plot(ts_data$date, ts_data$do_mgl, type = "l", col = "steelblue", lwd = 2,
     xlab = "Date", ylab = "Dissolved Oxygen (mg/L)",
     main = paste("Station", low_do_id, ": DO and Water Temperature (2015-2022)"),
     col.lab = "steelblue")
par(new = TRUE)
plot(ts_data$date, ts_data$wtemp_c, type = "l", col = "tomato", lwd = 2,
     axes = FALSE, xlab = "", ylab = "")
axis(side = 4, col.axis = "tomato")
mtext("Water Temperature (°C)", side = 4, line = 3, col = "tomato")
legend("topright", legend = c("DO (mg/L)", "Temperature (°C)"),
       col = c("steelblue", "tomato"), lty = 1, lwd = 2, bg = "white")
dev.off()
cat("Saved: ex01b_timeseries.png\n")
# DO is highest in winter (cold water dissolves more oxygen) and lowest in late summer.
# The inverse relationship with temperature is the primary driver of summer hypoxia risk.


# =============================================================================
# EXERCISE 2: Loading Polygon Data — Watershed Boundaries
# =============================================================================

# --- Load the GeoPackage ---
ws <- st_read("chesapeake_watersheds.gpkg", quiet = TRUE)

cat("=== Exercise 2: Watershed GeoPackage Inspection ===\n")
cat("Number of features (watersheds):", nrow(ws), "\n")
cat("Column names:", paste(names(ws), collapse = ", "), "\n")
cat("Geometry type:", as.character(unique(st_geometry_type(ws))), "\n")
cat("CRS (original):\n")
print(st_crs(ws))

# --- Reproject to UTM Zone 18N (meters) for accurate area calculation ---
ws_proj <- st_transform(ws, crs = 32618)

cat("\nCRS after reprojection to UTM 18N:\n")
print(st_crs(ws_proj))

# --- Calculate area in km² ---
# st_area() returns values in CRS units (m²); divide by 1e6 for km²
ws_proj$area_km2 <- as.numeric(st_area(ws_proj)) / 1e6

cat("\nArea summary (km2):\n")
print(summary(ws_proj$area_km2))

largest  <- ws_proj[which.max(ws_proj$area_km2), ]
smallest <- ws_proj[which.min(ws_proj$area_km2), ]
cat("\nLargest watershed :", largest$Name,
    sprintf("(%.1f km2)\n", largest$area_km2))
cat("Smallest watershed:", smallest$Name,
    sprintf("(%.1f km2)\n", smallest$area_km2))

# --- Choropleth map: area with watershed name labels ---
map_ex02 <- tm_shape(ws_proj) +
  tm_polygons(
    col     = "area_km2",
    palette = "YlOrRd",
    title   = "Area (km\u00B2)",
    border.col = "white",
    border.lwd = 0.4
  ) +
  tm_text("Name", size = 0.38, col = "gray20", remove.overlap = TRUE) +
  tm_layout(
    title          = "Chesapeake Bay HUC8 Watersheds\nby Area (UTM Zone 18N)",
    title.size     = 0.85,
    legend.outside = TRUE,
    frame          = TRUE
  ) +
  tm_scale_bar(position = c("left", "bottom"))

tmap_save(map_ex02, "ex02_watersheds.png", width = 7, height = 6, dpi = 150)
cat("Saved: ex02_watersheds.png\n")


# =============================================================================
# EXERCISE 3: Spatial Joins with GeoJSON Data
# =============================================================================

# --- Load county boundaries ---
counties <- st_read("counties_chesapeake.geojson", quiet = TRUE)

cat("=== Exercise 3: County GeoJSON Inspection ===\n")
cat("Number of counties:", nrow(counties), "\n")
cat("Column names:", paste(names(counties), collapse = ", "), "\n")
cat("CRS:", st_crs(counties)$input, "\n")

# --- Ensure both layers share the same CRS before joining ---
cat("\nCRS match (stations vs counties):", st_crs(stations_sf) == st_crs(counties), "\n")
# If FALSE, reproject counties to match stations (both should be EPSG:4326)
if (!isTRUE(st_crs(stations_sf) == st_crs(counties))) {
  counties <- st_transform(counties, st_crs(stations_sf))
  cat("Counties reprojected to match stations CRS.\n")
}

# --- Spatial join: each station inherits the county it falls within ---
stations_joined <- st_join(
  stations_sf,
  counties[c("county_name", "state")],
  join = st_within
)

cat("\nStations per state:\n")
print(table(stations_joined$state))

cat("\nCounties containing at least one monitoring station:\n")
print(unique(stations_joined$county_name[!is.na(stations_joined$county_name)]))

cat("\nStations with no county match (NA):",
    sum(is.na(stations_joined$county_name)), "\n")

# --- Map: county borders, stations colored by DO, state label context ---
map_ex03 <- tm_shape(counties) +
  tm_borders(col = "gray70", lwd = 0.4) +
  tm_shape(stations_joined) +
  tm_dots(
    col    = "mean_do_mgl",
    palette = "viridis",
    title  = "Mean DO (mg/L)",
    size   = 0.35,
    border.col = "white",
    border.lwd = 0.5
  ) +
  tm_layout(
    title          = "Monitoring Stations Overlaid on County Boundaries\n(Colored by Mean DO)",
    title.size     = 0.8,
    legend.outside = TRUE,
    frame          = TRUE
  ) +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_compass(position = c("right", "top"), size = 1.5)

tmap_save(map_ex03, "ex03_spatial_join.png", width = 8, height = 6, dpi = 150)
cat("Saved: ex03_spatial_join.png\n")


# =============================================================================
# EXERCISE 4: Digital Elevation Models — Loading and Classifying GeoTIFF Rasters
# =============================================================================

# --- Load the DEM ---
dem <- terra::rast("chesapeake_dem.tif")

cat("=== Exercise 4: DEM Raster Inspection ===\n")
cat("Dimensions (rows x cols x layers):", paste(dim(dem), collapse = " x "), "\n")
cat("Resolution (CRS units):", paste(round(res(dem), 6), collapse = " x "), "\n")
cat("CRS:\n")
print(crs(dem, describe = TRUE))

mm <- minmax(dem)
cat("\nElevation range: min =", mm[1], "m, max =", mm[2], "m\n")

total_cells <- ncell(dem)
valid_cells <- as.numeric(global(dem, "notNA"))
cat("Total cells:", total_cells, "\n")
cat("Valid (non-NA) cells:", valid_cells, "\n")
cat("Fraction with valid data:", round(valid_cells / total_cells, 3), "\n")
cat("Fraction NoData (water/edge):", round(1 - valid_cells / total_cells, 3), "\n")

# --- Reclassify into three elevation zones ---
# Matrix: from, to, new_value (rows are inclusive intervals)
rcl_matrix <- matrix(c(
  0,   100, 1,
  100, 300, 2,
  300, Inf, 3
), ncol = 3, byrow = TRUE)

dem_class <- classify(dem, rcl_matrix, include.lowest = TRUE)
levels(dem_class) <- data.frame(
  value = 1:3,
  label = c("Low (0-100 m)", "Mid (100-300 m)", "High (>300 m)")
)

# --- Percentage of watershed in each elevation class ---
freq_tbl      <- freq(dem_class)
freq_tbl$pct  <- freq_tbl$count / sum(freq_tbl$count) * 100

cat("\nElevation class distribution:\n")
print(freq_tbl[, c("value", "label", "count", "pct")])

# --- Reproject watershed boundaries to DEM CRS for overlay ---
ws_dem_crs <- st_transform(ws, crs(dem))

# --- Map: classified raster with watershed boundaries overlaid ---
class_palette <- c("#a8d5a2", "#4a7c59", "#1a3a1f")

map_ex04 <- tm_shape(dem_class) +
  tm_raster(
    col        = "label",
    palette    = class_palette,
    title      = "Elevation Zone",
    style      = "cat"
  ) +
  tm_shape(ws_dem_crs) +
  tm_borders(col = "gray20", lwd = 0.6) +
  tm_layout(
    title          = "Chesapeake Bay Watershed — Elevation Zones\n(DEM reclassified at 100 m and 300 m breaks)",
    title.size     = 0.8,
    legend.outside = TRUE,
    frame          = TRUE
  ) +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_compass(position = c("right", "top"), size = 1.5)

tmap_save(map_ex04, "ex04_dem_classified.png", width = 7, height = 6, dpi = 150)
cat("Saved: ex04_dem_classified.png\n")


# =============================================================================
# EXERCISE 5: Loading Precipitation Data from NetCDF
# =============================================================================

# --- Load the MSWEP NetCDF ---
# terra::rast() automatically reads the 'precipitation' variable
prec <- terra::rast("mswep_monthly.nc")

cat("=== Exercise 5: MSWEP NetCDF Inspection ===\n")
cat("Number of layers (months):", nlyr(prec), "\n")
cat("Variable name:", names(prec)[1], "\n")

# Inspect time dimension
prec_dates <- time(prec)
cat("Time range:", format(min(prec_dates), "%Y-%m"),
    "to", format(max(prec_dates), "%Y-%m"), "\n")
cat("Units: mm/day (to be converted to mm/month)\n")

# --- Convert mm/day -> mm/month by multiplying by days in each month ---
days_per_month  <- days_in_month(prec_dates)      # lubridate: e.g. Jan=31, Feb=28
prec_mm         <- prec * days_per_month           # terra broadcasts scalar per layer

cat("\nDays per month (first 12):", days_per_month[1:12], "\n")

# --- Annual totals: sum the 12 monthly layers for each calendar year ---
year_labels <- format(prec_dates, "%Y")
annual      <- tapp(prec_mm, year_labels, fun = sum)   # one layer per year

cat("\nYears in dataset:", names(annual), "\n")

# --- Long-term mean annual precipitation ---
mean_annual <- mean(annual)
names(mean_annual) <- "mean_annual_precip_mm"

cat("\nSpatial mean annual precipitation:\n")
cat("  Min cell:", round(as.numeric(global(mean_annual, "min")), 1), "mm/yr\n")
cat("  Max cell:", round(as.numeric(global(mean_annual, "max")), 1), "mm/yr\n")
cat("  Mean cell:", round(as.numeric(global(mean_annual, "mean")), 1), "mm/yr\n")

# --- Wettest and driest year (basin-averaged) ---
basin_annual <- as.numeric(global(annual, "mean"))
names(basin_annual) <- names(annual)
cat("\nBasin-mean annual precipitation by year:\n")
print(round(basin_annual, 1))
cat("Wettest year:", names(which.max(basin_annual)),
    sprintf("(%.1f mm)\n", max(basin_annual)))
cat("Driest year :", names(which.min(basin_annual)),
    sprintf("(%.1f mm)\n", min(basin_annual)))

# --- Reproject watershed boundaries to match MSWEP CRS (WGS84) for overlay ---
ws_prec_crs <- st_transform(ws, crs(mean_annual))

# --- Map: mean annual precipitation with watershed overlay ---
map_ex05 <- tm_shape(mean_annual) +
  tm_raster(
    col     = "mean_annual_precip_mm",
    palette = "Blues",
    title   = "Mean Annual\nPrecip (mm)",
    style   = "cont"
  ) +
  tm_shape(ws_prec_crs) +
  tm_borders(col = "gray20", lwd = 0.5) +
  tm_layout(
    title          = "MSWEP Long-Term Mean Annual Precipitation\n2015-2019 (Chesapeake Bay Watershed)",
    title.size     = 0.8,
    legend.outside = TRUE,
    frame          = TRUE
  ) +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_compass(position = c("right", "top"), size = 1.5)

tmap_save(map_ex05, "ex05_precipitation.png", width = 7, height = 6, dpi = 150)
cat("Saved: ex05_precipitation.png\n")


# =============================================================================
# EXERCISE 6: Riparian Buffer Analysis
# =============================================================================

# --- Load and inspect stream network ---
streams <- st_read("chesapeake_streams.gpkg", quiet = TRUE)

cat("=== Exercise 6: Stream Network Inspection ===\n")
cat("Number of stream features:", nrow(streams), "\n")
cat("Column names:", paste(names(streams), collapse = ", "), "\n")
cat("CRS (original):", st_crs(streams)$input, "\n")

# --- Reproject to UTM 18N — required for meter-based buffers ---
streams_proj <- st_transform(streams, crs = 32618)
cat("Reprojected to EPSG:32618 (UTM Zone 18N, meters)\n")

# --- Create buffers at 100, 300, and 500 m ---
cat("\nCreating buffers (this may take a moment for 7126 features)...\n")
buf_100 <- st_buffer(streams_proj, dist = 100)
buf_300 <- st_buffer(streams_proj, dist = 300)
buf_500 <- st_buffer(streams_proj, dist = 500)

# --- Dissolve overlapping polygons and compute total buffered area ---
cat("Dissolving overlapping buffer polygons...\n")
buf_100_union <- st_union(buf_100)
buf_300_union <- st_union(buf_300)
buf_500_union <- st_union(buf_500)

area_100_km2 <- as.numeric(st_area(buf_100_union)) / 1e6
area_300_km2 <- as.numeric(st_area(buf_300_union)) / 1e6
area_500_km2 <- as.numeric(st_area(buf_500_union)) / 1e6

cat("\nTotal dissolved buffer areas:\n")
cat(sprintf("  100 m buffer: %.1f km2\n", area_100_km2))
cat(sprintf("  300 m buffer: %.1f km2\n", area_300_km2))
cat(sprintf("  500 m buffer: %.1f km2\n", area_500_km2))
cat("\nArea ratios relative to 100 m buffer:\n")
cat(sprintf("  300 m / 100 m = %.2f  (not 3x because buffers overlap)\n",
            area_300_km2 / area_100_km2))
cat(sprintf("  500 m / 100 m = %.2f  (not 5x — overlapping geometry removed by union)\n",
            area_500_km2 / area_100_km2))

# --- Identify monitoring stations within the 500 m riparian buffer ---
stations_proj <- st_transform(stations_sf, 32618)
in_buf        <- st_within(stations_proj, buf_500_union, sparse = FALSE)[, 1]
stations_proj$in_buffer <- in_buf

cat("\nMonitoring stations within 500 m riparian buffer:",
    sum(in_buf), "of", nrow(stations_proj), "\n")
cat("Stations inside buffer:\n")
print(stations_proj$station_id[in_buf])

# --- Map: 500 m buffer, stream lines, stations colored by buffer membership ---
map_ex06 <- tm_shape(st_sf(geometry = buf_500_union)) +
  tm_fill(col = "lightblue", alpha = 0.45) +
  tm_borders(col = "steelblue", lwd = 0.3) +
  tm_shape(streams_proj) +
  tm_lines(col = "steelblue3", lwd = 0.4) +
  tm_shape(stations_proj) +
  tm_dots(
    col    = "in_buffer",
    palette = c("FALSE" = "#d62828", "TRUE" = "#2a9d8f"),
    title  = "In 500 m Buffer",
    size   = 0.4,
    border.col = "white",
    border.lwd = 0.5,
    labels = c("Outside", "Inside")
  ) +
  tm_layout(
    title          = "Riparian Buffer Analysis — 500 m Zone\n(Station membership shown by color)",
    title.size     = 0.8,
    legend.outside = TRUE,
    frame          = TRUE
  ) +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_compass(position = c("right", "top"), size = 1.5)

tmap_save(map_ex06, "ex06_riparian_buffer.png", width = 8, height = 6, dpi = 150)
cat("Saved: ex06_riparian_buffer.png\n")


# =============================================================================
# EXERCISE 7: Zonal Statistics — Raster Summaries by Watershed
# =============================================================================
# Uses mean_annual from Exercise 5 and ws_proj from Exercise 2

cat("=== Exercise 7: Zonal Statistics — Precipitation by Watershed ===\n")

# --- Align CRS: reproject watershed boundaries to match the MSWEP raster (WGS84) ---
ws_reproj <- st_transform(ws_proj, crs(mean_annual))
cat("Watershed CRS aligned to MSWEP raster CRS\n")
cat("CRS match:", st_crs(ws_reproj)$epsg == st_crs(mean_annual)$epsg, "\n")

# --- Zonal statistics with exactextractr (fractional cell weighting) ---
# exact_extract supports SpatRaster directly; append_cols adds the Name column to output
zonal_stats <- exact_extract(
  mean_annual,
  ws_reproj,
  fun         = c("mean", "min", "max", "stdev"),
  append_cols = "Name"
)
names(zonal_stats) <- c("Name", "precip_mean", "precip_min", "precip_max", "precip_sd")

cat("\nPrecipitation zonal statistics (first 6 watersheds):\n")
print(head(zonal_stats))

cat("\nTop 5 wettest watersheds (mean annual precip):\n")
print(zonal_stats[order(zonal_stats$precip_mean, decreasing = TRUE)[1:5], ])

cat("\nTop 5 driest watersheds:\n")
print(zonal_stats[order(zonal_stats$precip_mean)[1:5], ])

# --- Join zonal statistics back to the spatial watershed data frame ---
ws_with_precip <- merge(ws_proj, zonal_stats, by = "Name")

cat("\nColumns in merged watershed dataset:\n")
print(names(ws_with_precip))

# --- Scatter plot: watershed area vs mean annual precipitation ---
png("ex07_area_vs_precip.png", width = 600, height = 500, res = 120)
plot(ws_with_precip$area_km2, ws_with_precip$precip_mean,
     pch  = 19, col  = adjustcolor("#457b9d", alpha.f = 0.7),
     xlab = "Watershed Area (km\u00B2)",
     ylab = "Mean Annual Precipitation (mm)",
     main = "Watershed Area vs Mean Annual Precipitation\nChesapeake Bay HUC8 Sub-basins")
abline(lm(precip_mean ~ area_km2, data = ws_with_precip),
       col = "#d62828", lty = 2, lwd = 1.5)
text(ws_with_precip$area_km2, ws_with_precip$precip_mean,
     labels = ws_with_precip$Name, cex = 0.35, col = "gray40", pos = 3)
dev.off()
cat("Saved: ex07_area_vs_precip.png\n")

# --- Choropleth map: mean annual precipitation per watershed ---
map_ex07 <- tm_shape(ws_with_precip) +
  tm_polygons(
    col    = "precip_mean",
    palette = "Blues",
    title  = "Mean Annual\nPrecip (mm)",
    border.col = "white",
    border.lwd = 0.4
  ) +
  tm_text("Name", size = 0.35, col = "gray20", remove.overlap = TRUE) +
  tm_layout(
    title          = "Mean Annual Precipitation by Watershed\n(Exact_extract zonal statistics)",
    title.size     = 0.8,
    legend.outside = TRUE,
    frame          = TRUE
  ) +
  tm_scale_bar(position = c("left", "bottom"))

tmap_save(map_ex07, "ex07_precip_by_watershed.png", width = 7, height = 6, dpi = 150)
cat("Saved: ex07_precip_by_watershed.png\n")


# =============================================================================
# EXERCISE 8: Categorical Raster Analysis — National Land Cover Data
# =============================================================================

cat("=== Exercise 8: NLCD Categorical Raster Analysis ===\n")

# --- Load NLCD (EPSG:5070, Albers Equal Area) ---
nlcd <- terra::rast("nlcd_chesapeake.tif")

cat("NLCD CRS (Albers Equal Area EPSG:5070):\n")
print(crs(nlcd, describe = TRUE))
cat("Resolution:", res(nlcd), "m\n")

# Inspect unique class values
unique_vals <- sort(as.integer(unique(nlcd)[[1]]))
cat("\nUnique NLCD class codes in dataset:\n")
print(unique_vals)

# --- Reclassify detailed NLCD codes into 4 aggregated categories ---
# Matrix: from, to, new_value (ranges are inclusive)
rcl_nlcd <- matrix(c(
  11, 11,  4,   # Open Water     -> Other
  21, 24,  3,   # Developed      -> Urban
  31, 31,  4,   # Barren         -> Other
  41, 43,  1,   # Forest         -> Forest
  52, 52,  4,   # Shrub          -> Other
  71, 71,  4,   # Herbaceous     -> Other
  81, 82,  2,   # Agriculture    -> Agriculture
  90, 95,  4    # Wetlands       -> Other
), ncol = 3, byrow = TRUE)

nlcd_reclass <- classify(nlcd, rcl_nlcd, include.lowest = TRUE)
levels(nlcd_reclass) <- data.frame(
  value = 1:4,
  label = c("Forest", "Agriculture", "Urban", "Other")
)

cat("\nReclassified NLCD — overall cell counts:\n")
nlcd_freq       <- freq(nlcd_reclass)
nlcd_freq$pct   <- round(nlcd_freq$count / sum(nlcd_freq$count) * 100, 2)
print(nlcd_freq[, c("value", "label", "count", "pct")])

# --- Reproject watershed boundaries to NLCD CRS (EPSG:5070) before zonal stats ---
ws_5070 <- st_transform(ws_proj, crs(nlcd_reclass))

# --- Zonal statistics for categorical raster: proportion per class per watershed ---
# Use a custom function to compute proportion of each class
lc_pct <- exact_extract(
  nlcd_reclass,
  ws_5070,
  function(values, coverage_fraction) {
    # Filter out NA cells
    valid  <- !is.na(values)
    v      <- values[valid]
    cf     <- coverage_fraction[valid]
    total  <- sum(cf)
    if (total == 0) return(c(pct_for = NA, pct_agr = NA, pct_urb = NA, pct_oth = NA))
    c(
      pct_for = sum(cf[v == 1]) / total * 100,
      pct_agr = sum(cf[v == 2]) / total * 100,
      pct_urb = sum(cf[v == 3]) / total * 100,
      pct_oth = sum(cf[v == 4]) / total * 100
    )
  }
)

# Convert list output to data frame and bind watershed names
lc_pct_df      <- as.data.frame(do.call(rbind, lc_pct))
lc_pct_df$Name <- ws_5070$Name

cat("\nLand cover percentages by watershed (first 6 rows):\n")
print(head(lc_pct_df))

cat("\nTop 5 most agricultural watersheds (% cropland/pasture):\n")
print(lc_pct_df[order(lc_pct_df$pct_agr, decreasing = TRUE)[1:5], ])

cat("\nTop 5 most forested watersheds:\n")
print(lc_pct_df[order(lc_pct_df$pct_for, decreasing = TRUE)[1:5], ])

# --- Join back to spatial watershed data frame ---
ws_with_lc <- merge(ws_proj, lc_pct_df, by = "Name")

# --- Two-panel map: % Agriculture and % Forest side by side ---
m_agr <- tm_shape(ws_with_lc) +
  tm_polygons(
    col    = "pct_agr",
    palette = "YlOrBr",
    title  = "% Agriculture",
    border.col = "white",
    border.lwd = 0.4
  ) +
  tm_layout(
    title      = "A: Agricultural Cover",
    title.size = 0.85,
    frame      = TRUE
  )

m_for <- tm_shape(ws_with_lc) +
  tm_polygons(
    col    = "pct_for",
    palette = "Greens",
    title  = "% Forest",
    border.col = "white",
    border.lwd = 0.4
  ) +
  tm_layout(
    title      = "B: Forest Cover",
    title.size = 0.85,
    frame      = TRUE
  )

map_ex08 <- tmap_arrange(m_agr, m_for, ncol = 2)
tmap_save(map_ex08, "ex08_land_cover.png", width = 12, height = 6, dpi = 150)
cat("Saved: ex08_land_cover.png\n")

# --- Scatter: % Agriculture vs mean DO per watershed ---
# Compute mean DO per watershed from joined stations (Exercise 3)
do_by_ws <- aggregate(mean_do_mgl ~ watershed, data = stations_joined,
                       FUN = mean, na.rm = TRUE)
names(do_by_ws) <- c("Name", "mean_do")

ws_lc_do <- merge(as.data.frame(ws_with_lc)[, c("Name", "pct_agr")],
                   do_by_ws, by = "Name")

if (nrow(ws_lc_do) > 0) {
  png("ex08_agr_vs_do.png", width = 600, height = 500, res = 120)
  plot(ws_lc_do$pct_agr, ws_lc_do$mean_do,
       pch  = 19, col = adjustcolor("#c44536", alpha.f = 0.75),
       xlab = "% Agricultural Cover",
       ylab = "Mean Dissolved Oxygen (mg/L)",
       main = "Agriculture vs Dissolved Oxygen per Watershed\n(Eutrophication hypothesis: more ag -> lower DO)")
  if (nrow(ws_lc_do) > 2) {
    abline(lm(mean_do ~ pct_agr, data = ws_lc_do),
           col = "gray30", lty = 2, lwd = 1.5)
  }
  text(ws_lc_do$pct_agr, ws_lc_do$mean_do,
       labels = ws_lc_do$Name, cex = 0.55, pos = 4, col = "gray40")
  dev.off()
  cat("Saved: ex08_agr_vs_do.png\n")
}


# =============================================================================
# EXERCISE 9: Coordinate Reference Systems and Reprojection
# =============================================================================

cat("=== Exercise 9: CRS and Reprojection Consequences ===\n")

# --- Select two stations for distance comparison ---
stn_a <- stations_sf[1, ]
stn_b <- stations_sf[6, ]

cat("Station A:", stn_a$station_id, "\n")
cat("Station B:", stn_b$station_id, "\n")

# --- Distance in geographic coordinates (INCORRECT for ground distance) ---
# st_distance() on EPSG:4326 uses the spherical/ellipsoidal model by default in sf.
# To show the naive Euclidean error, strip the CRS temporarily.
pair_geo  <- rbind(stn_a, stn_b)
pair_nocrs <- st_set_crs(pair_geo, NA)   # remove CRS to force planar Euclidean

dist_deg <- as.numeric(st_distance(pair_nocrs)[1, 2])
cat(sprintf("\nNaive Euclidean distance in GEOGRAPHIC degrees: %.4f degrees\n", dist_deg))
cat("(This is meaningless as a ground distance!)\n")

# --- Correct ellipsoidal distance via sf default (uses s2 or lwgeom) ---
dist_ellips_m <- as.numeric(st_distance(pair_geo)[1, 2])   # meters on ellipsoid
dist_ellips_km <- dist_ellips_m / 1000
cat(sprintf("Ellipsoidal distance (sf default, EPSG:4326): %.2f km\n", dist_ellips_km))

# --- Projected distance via UTM 18N ---
pair_utm    <- st_transform(pair_geo, 32618)
dist_utm_m  <- as.numeric(st_distance(pair_utm)[1, 2])
dist_utm_km <- dist_utm_m / 1000
cat(sprintf("UTM 18N projected distance             : %.2f km\n", dist_utm_km))

# --- Percentage error of naive degree-based estimate ---
# Convert degrees to km using rough approximation for comparison purposes
deg_km_approx <- sqrt(
  (dist_deg * cos(mean(c(stn_a$geometry[[1]][2], stn_b$geometry[[1]][2])) * pi / 180) * 111.32)^2 +
  (dist_deg * 110.57)^2  # this is a rough proxy; just illustrates the issue
)
cat(sprintf("Naive degree value converted by simple scaling: %.2f km\n", deg_km_approx))
pct_error <- (deg_km_approx - dist_utm_km) / dist_utm_km * 100
cat(sprintf("Approximate error vs UTM: %.1f%%\n", pct_error))

# --- Area comparison for one watershed ---
ws_one_geo  <- ws[1, ]
ws_one_utm  <- st_transform(ws_one_geo, 32618)

# st_area() in geographic CRS uses ellipsoidal model (accurate)
area_ellipsoidal_km2 <- as.numeric(st_area(ws_one_geo)) / 1e6
area_utm_km2         <- as.numeric(st_area(ws_one_utm)) / 1e6

cat(sprintf("\nArea of '%s':\n", ws_one_geo$Name))
cat(sprintf("  Ellipsoidal (EPSG:4326, sf::st_area): %.2f km2\n", area_ellipsoidal_km2))
cat(sprintf("  UTM 18N projected (EPSG:32618)      : %.2f km2\n", area_utm_km2))
cat(sprintf("  Difference: %.2f km2 (%.2f%%)\n",
            abs(area_ellipsoidal_km2 - area_utm_km2),
            abs(area_ellipsoidal_km2 - area_utm_km2) / area_utm_km2 * 100))

# --- CRS mismatch demonstration: NLCD (EPSG:5070) vs watershed (EPSG:4326) ---
cat("\n--- CRS Mismatch Demonstration ---\n")
cat("NLCD CRS (EPSG):", st_crs(nlcd)$epsg, "— Albers Equal Area\n")
cat("Watershed CRS (EPSG):", st_crs(ws)$epsg, "— WGS84 geographic\n")
cat("CRS match?", st_crs(ws) == st_crs(nlcd), "\n")
cat("=> Layers cannot be combined without reprojection.\n")
cat("Fix: ws_albers <- st_transform(ws, crs(nlcd))  [reproject vector to match raster]\n")
cat("  OR nlcd_wgs  <- project(nlcd, 'EPSG:4326')    [reproject raster — more expensive]\n")

# Apply the fix and confirm
ws_albers <- st_transform(ws, crs(nlcd_reclass))
cat("\nAfter fix — CRS match:", st_crs(ws_albers) == st_crs(nlcd_reclass), "\n")

# --- Summary table ---
cat("\n--- Summary Table: CRS Effects ---\n")
summary_tbl <- data.frame(
  Operation           = c("Distance (naive degrees)", "Distance (ellipsoidal sf)", "Distance (UTM 18N)",
                          "Area (ellipsoidal sf)", "Area (UTM 18N)"),
  CRS_Used            = c("EPSG:4326 (planar)", "EPSG:4326 (ellipsoid)", "EPSG:32618 (UTM)",
                          "EPSG:4326 (ellipsoid)", "EPSG:32618 (UTM)"),
  Value               = c(sprintf("%.4f deg", dist_deg),
                          sprintf("%.2f km", dist_ellips_km),
                          sprintf("%.2f km", dist_utm_km),
                          sprintf("%.2f km2", area_ellipsoidal_km2),
                          sprintf("%.2f km2", area_utm_km2)),
  Correct             = c("No — meaningless units", "Yes", "Yes (reference)",
                          "Yes", "Yes (reference)")
)
print(summary_tbl, row.names = FALSE)


# =============================================================================
# EXERCISE 10: Integrated Spatial Analysis — Watershed Risk Assessment
# =============================================================================

cat("=== Exercise 10: Composite Watershed Risk Assessment ===\n")

# =============================================================================
# STEP 1: Assemble watershed-level data
# =============================================================================

# (a) Start with the precipitation zonal stats joined to watersheds (Exercise 7)
ws_risk <- ws_with_precip   # has: Name, HUC8, States, AreaSqKm, area_km2, precip_mean, ...

# (b) Join land cover percentages from Exercise 8
ws_risk <- merge(ws_risk, lc_pct_df[, c("Name", "pct_agr", "pct_for", "pct_urb", "pct_oth")],
                 by = "Name", all.x = TRUE)

# (c) Join mean DO per watershed from station data (Exercise 3)
# Aggregate monitoring stations by watershed using the 'watershed' column in stations_joined
station_do_by_ws <- aggregate(mean_do_mgl ~ watershed,
                               data = as.data.frame(stations_joined),
                               FUN  = mean, na.rm = TRUE)
names(station_do_by_ws) <- c("Name", "mean_do")

ws_risk <- merge(ws_risk, station_do_by_ws, by = "Name", all.x = TRUE)

cat("Assembled dataset — columns:\n")
print(names(ws_risk))
cat("Watersheds with DO data:", sum(!is.na(ws_risk$mean_do)),
    "of", nrow(ws_risk), "\n")

# =============================================================================
# STEP 2: Normalize indicators and compute composite risk score
# =============================================================================

normalize <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (rng[1] == rng[2]) return(rep(0, length(x)))
  (x - rng[1]) / (rng[2] - rng[1])
}

ws_risk$norm_agr  <- normalize(ws_risk$pct_agr)
ws_risk$norm_prec <- normalize(ws_risk$precip_mean)
ws_risk$norm_do   <- normalize(ws_risk$mean_do)

# Risk score: agriculture and precipitation increase risk; high DO reduces risk
# Watersheds with no stations get NA for norm_do; weight only the other two in that case
ws_risk$risk_score <- ifelse(
  is.na(ws_risk$norm_do),
  0.5 * ws_risk$norm_agr + 0.5 * ws_risk$norm_prec,   # fallback without DO
  0.4 * ws_risk$norm_agr + 0.4 * ws_risk$norm_prec + 0.2 * (1 - ws_risk$norm_do)
)

# Classify into three risk tiers
ws_risk$risk_class <- cut(
  ws_risk$risk_score,
  breaks = c(-Inf, 0.3, 0.6, Inf),
  labels = c("Low Risk", "Moderate Risk", "High Risk"),
  right  = TRUE
)

cat("\nRisk classification distribution:\n")
print(table(ws_risk$risk_class, useNA = "always"))

cat("\nHighest-risk watersheds:\n")
top_risk <- ws_risk[order(ws_risk$risk_score, decreasing = TRUE, na.last = TRUE)[1:5], ]
print(as.data.frame(top_risk)[, c("Name", "pct_agr", "precip_mean", "mean_do", "risk_score", "risk_class")])

# =============================================================================
# STEP 3: Four-panel publication-quality map
# =============================================================================

# Panel A: % Agricultural Cover
pA <- tm_shape(ws_risk) +
  tm_polygons(
    col    = "pct_agr",
    palette = "YlOrBr",
    title  = "% Agriculture",
    border.col = "white",
    border.lwd = 0.3,
    textNA = "No data"
  ) +
  tm_layout(
    title      = "A: Agricultural Cover",
    title.size = 0.82,
    frame      = TRUE,
    legend.position = c("right", "bottom"),
    legend.text.size = 0.55,
    legend.title.size = 0.65
  )

# Panel B: Mean Annual Precipitation
pB <- tm_shape(ws_risk) +
  tm_polygons(
    col    = "precip_mean",
    palette = "Blues",
    title  = "Precip (mm/yr)",
    border.col = "white",
    border.lwd = 0.3
  ) +
  tm_layout(
    title      = "B: Mean Annual Precipitation",
    title.size = 0.82,
    frame      = TRUE,
    legend.position = c("right", "bottom"),
    legend.text.size = 0.55,
    legend.title.size = 0.65
  )

# Panel C: Mean Station DO with station points overlaid
pC <- tm_shape(ws_risk) +
  tm_polygons(
    col    = "mean_do",
    palette = "RdYlGn",
    title  = "Mean DO (mg/L)",
    border.col = "white",
    border.lwd = 0.3,
    textNA = "No stations"
  ) +
  tm_shape(stations_sf) +
  tm_dots(col = "black", size = 0.18, border.col = "white", border.lwd = 0.5) +
  tm_layout(
    title      = "C: Mean Dissolved Oxygen",
    title.size = 0.82,
    frame      = TRUE,
    legend.position = c("right", "bottom"),
    legend.text.size = 0.55,
    legend.title.size = 0.65
  )

# Panel D: Composite Risk Classification with scale bar and north arrow
pD <- tm_shape(ws_risk) +
  tm_polygons(
    col    = "risk_class",
    palette = c("Low Risk"      = "#1a9641",
                "Moderate Risk" = "#fdae61",
                "High Risk"     = "#d7191c"),
    title  = "Risk Level",
    border.col = "white",
    border.lwd = 0.3,
    textNA = "Insufficient data"
  ) +
  tm_scale_bar(position = c("left", "bottom"), text.size = 0.45) +
  tm_compass(position = c("right", "top"), size = 1.5) +
  tm_layout(
    title      = "D: Composite Risk Classification",
    title.size = 0.82,
    frame      = TRUE,
    legend.position = c("right", "bottom"),
    legend.text.size = 0.55,
    legend.title.size = 0.65
  )

map_ex10 <- tmap_arrange(pA, pB, pC, pD, ncol = 2)

tmap_save(map_ex10, "ex10_risk_assessment.png", width = 12, height = 10, dpi = 150)
cat("Saved: ex10_risk_assessment.png\n")

cat("\n--- Interpretive Caption ---\n")
cat(
  "Watersheds in the upper Potomac and Shenandoah tributaries show the highest composite",
  "risk scores, driven by a combination of high agricultural land cover (>40%) and above-average",
  "precipitation, which together promote nutrient export and transport to the main stem Bay.",
  "Forest-dominated sub-basins in the upper Susquehanna and Delaware headwaters score consistently",
  "low, reflecting both lower nutrient inputs and higher dissolved oxygen measured at in-watershed",
  "monitoring stations.",
  "Watersheds lacking monitoring stations (white polygons in panel C) were scored using only",
  "agriculture and precipitation weights, highlighting a key monitoring gap for future CBP",
  "station placement.\n"
)

cat("\n=== All exercises complete. Output files saved to Lectures/ ===\n")
