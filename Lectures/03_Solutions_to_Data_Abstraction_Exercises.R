# ==============================================================================
# 03_Solutions_to_Data_Abstraction_Exercises.R
# Solutions to "Data Abstraction and Transformation" Exercises
# Environmental Data Science (ENST431)
# ==============================================================================

# ------------------------------------------------------------------------------
# SETUP
# ------------------------------------------------------------------------------
# Install tidyverse if not already installed
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)
library(lubridate)

# ==============================================================================
# EXERCISE 1: Importing the Chesapeake Bay Data with readr
# ==============================================================================
cat("\n--- Exercise 1: Importing with readr ---\n")

# 1. Basic import with automatic type detection
# water_data <- read_csv("water_quality.csv")
# spec(water_data)  # View column specification

# 2. Re-import with explicit NA handling
water_data <- read_csv(
  "water_quality.csv",
  na = c("", "NA", "N/A", "-999", "-9999")
)

# 3. Import with explicit column types
water_data <- read_csv(
  "water_quality.csv",
  na = c("", "NA", "N/A", "-999", "-9999"),
  col_types = cols(
    station = col_factor(),
    date = col_date(format = "%Y-%m-%d"),
    temp_c = col_double(),
    do_mg_l = col_double(),
    ph = col_double(),
    turbidity_ntu = col_double()
  )
)

# 4. Check for parsing issues
print(problems(water_data))

# 5. Compare glimpse() to str()
glimpse(water_data)  # Tidyverse: compact, horizontal view


# ==============================================================================
# EXERCISE 2: Extracting Hypoxia Events with dplyr
# ==============================================================================
cat("\n--- Exercise 2: Filtering and Selecting with dplyr ---\n")

# Fisheries Biologist Request
# July 23rd observations with DO < 6.0 OR turbidity > 15
fisheries_data <- water_data |>
  filter(
    date == as.Date("2025-07-23"),
    do_mg_l < 6.0 | turbidity_ntu > 15
  ) |>
  select(station, date, do_mg_l, turbidity_ntu) |>
  arrange(do_mg_l)

print("Fisheries Data:")
print(fisheries_data)

# Count observations at each step
cat("\nCounting observations at each step:\n")
water_data |>
  filter(date == as.Date("2025-07-23")) |>
  count() |>
  print()

# Researcher Request
# Stations CB-5.1 OR CB-5.2, Temp 24-26, DO not missing
researcher_data <- water_data |>
  filter(
    station %in% c("CB-5.1", "CB-5.2"),
    between(temp_c, 24, 26),
    !is.na(do_mg_l)
  ) |>
  select(station, date, temp_c, dissolved_oxygen = do_mg_l)

print("Researcher Data:")
print(researcher_data)


# ==============================================================================
# EXERCISE 3: Calculating Derived Variables with mutate
# ==============================================================================
cat("\n--- Exercise 3: Transforming with mutate ---\n")

water_enhanced <- water_data |>
  mutate(
    # Temperature conversion
    temp_f = temp_c * 9/5 + 32,

    # DO percent saturation (simplified)
    do_percent_sat = (do_mg_l / 8.0) * 100,

    # Log turbidity
    log_turbidity = log(turbidity_ntu),

    # DO status with case_when (order matters!)
    do_status = case_when(
      is.na(do_mg_l) ~ "Unknown",    # Handle NA first
      do_mg_l < 2 ~ "Hypoxic",
      do_mg_l < 5 ~ "Stressed",
      do_mg_l < 8 ~ "Adequate",
      TRUE ~ "Healthy"               # Default case
    ),

    # Time variables using lubridate
    month = month(date, label = TRUE),
    day_of_year = yday(date),
    days_since_start = as.numeric(date - min(date, na.rm = TRUE)),

    # Temperature z-score
    temp_zscore = (temp_c - mean(temp_c, na.rm = TRUE)) /
                   sd(temp_c, na.rm = TRUE)
  )

glimpse(water_enhanced)


# ==============================================================================
# EXERCISE 4: Station Summaries with group_by and summarize
# ==============================================================================
cat("\n--- Exercise 4: Grouping and Summarizing ---\n")

# Part 1: Station Summary Report
station_summary <- water_enhanced |>
  group_by(station) |>
  summarize(
    mean_temp = mean(temp_c, na.rm = TRUE),
    mean_do = mean(do_mg_l, na.rm = TRUE),
    max_turbidity = max(turbidity_ntu, na.rm = TRUE),
    n_obs = n(),
    prop_stressed = mean(do_mg_l < 6.0, na.rm = TRUE)
  )

print("Station Summary:")
print(station_summary)

# Part 2: Station-Relative Analysis (grouped mutate)
station_relative <- water_enhanced |>
  group_by(station) |>
  mutate(
    station_mean_temp = mean(temp_c, na.rm = TRUE),
    temp_deviation = temp_c - station_mean_temp,
    do_rank = min_rank(desc(do_mg_l))  # Highest DO = rank 1
  ) |>
  ungroup()

print("Station Relative (sample):")
print(station_relative |> select(station, temp_c, temp_deviation, do_rank) |> head(10))

# Bonus: Using across() for multiple columns
multi_summary <- water_enhanced |>
  group_by(station) |>
  summarize(
    across(c(temp_c, do_mg_l, turbidity_ntu),
           list(mean = ~mean(., na.rm = TRUE),
                sd = ~sd(., na.rm = TRUE)),
           .names = "{.col}_{.fn}")
  )

print("Multi-column summary:")
print(multi_summary)


# ==============================================================================
# EXERCISE 5: Cleaning Station Names with stringr
# ==============================================================================
cat("\n--- Exercise 5: String Manipulation with stringr ---\n")

# Create sample messy data
messy_stations <- tibble(
  station_name = c(" CB-5.1 ", "cb-5.2", "CB_5.3", "Chesapeake Bay 5.4")
)

# Clean station names
cleaned_stations <- messy_stations |>
  mutate(
    # Chain string operations
    clean_name = station_name |>
      str_trim() |>           # Remove leading/trailing whitespace
      str_to_upper() |>       # Convert to uppercase
      str_replace("_", "-"),  # Replace underscore with hyphen

    # Extract numeric portion using regex
    station_number = str_extract(station_name, "[0-9]+\\.[0-9]+"),

    # Detect specific patterns
    is_full_name = str_detect(station_name, "Chesapeake")
  )

print("Cleaned Stations:")
print(cleaned_stations)


# ==============================================================================
# EXERCISE 6: Reshaping Climate Normals Data (Pivot Longer)
# ==============================================================================
cat("\n--- Exercise 6: Pivoting Longer ---\n")

# Create wide climate data
climate_wide <- tibble(
  station = c("SFO_AIRPORT", "SACRAMENTO", "FRESNO"),
  jan_temp = c(10.2, 7.8, 6.5),
  apr_temp = c(13.5, 14.2, 15.8),
  jul_temp = c(17.8, 24.5, 28.2),
  oct_temp = c(16.2, 18.5, 19.8)
)

print("Wide format:")
print(climate_wide)

# Pivot to long format
climate_long <- climate_wide |>
  pivot_longer(
    cols = jan_temp:oct_temp,     # Columns to pivot
    names_to = "month",           # New column for names
    values_to = "temperature"     # New column for values
  ) |>
  mutate(
    month = str_remove(month, "_temp"),
    month = factor(month, levels = c("jan", "apr", "jul", "oct"))
  )

print("Long format:")
print(climate_long)

# Verify: 3 stations x 4 months = 12 rows
cat("Number of rows:", nrow(climate_long), "\n")

# Create line plot
p1 <- ggplot(climate_long, aes(x = month, y = temperature,
                               color = station, group = station)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  labs(title = "Seasonal Temperature Patterns",
       y = "Temperature (C)") +
  theme_minimal()

# print(p1)  # Uncomment to display plot


# ==============================================================================
# EXERCISE 7: Creating a Species Presence Matrix (Pivot Wider)
# ==============================================================================
cat("\n--- Exercise 7: Pivoting Wider ---\n")

# Create survey data (long format)
wildlife_survey <- tibble(
  site = c("Marsh_A", "Marsh_A", "Marsh_A",
           "Marsh_B", "Marsh_B",
           "Marsh_C", "Marsh_C", "Marsh_C"),
  species = c("Great_Egret", "Mallard", "Wood_Duck",
              "Great_Egret", "Heron",
              "Mallard", "Wood_Duck", "Heron"),
  count = c(12, 45, 8, 8, 15, 32, 23, 7)
)

print("Survey data (long):")
print(wildlife_survey)

# Pivot to wide species matrix
species_matrix <- wildlife_survey |>
  pivot_wider(
    names_from = species,
    values_from = count,
    values_fill = 0  # Fill missing with 0
  )

print("Species matrix (wide):")
print(species_matrix)

# Convert to presence/absence
presence_matrix <- species_matrix |>
  mutate(across(-site, ~if_else(. > 0, 1L, 0L)))

# Calculate species richness per site
presence_matrix <- presence_matrix |>
  rowwise() |>
  mutate(species_richness = sum(c_across(-site))) |>
  ungroup()

print("Presence matrix with richness:")
print(presence_matrix)


# ==============================================================================
# EXERCISE 8: Combining Water Quality and Watershed Data (Joins)
# ==============================================================================
cat("\n--- Exercise 8: Joining Datasets ---\n")

# Create water quality measurements
set.seed(42)
water_quality <- tibble(
  station = rep(c("CB-5.1", "CB-5.2", "CB-5.3", "CB-5.4"), each = 3),
  date = rep(as.Date("2025-06-01") + 0:2, 4),
  do_mg_l = runif(12, 4, 9),
  turbidity = runif(12, 5, 25)
)

# Create station metadata (note: CB-5.4 is missing!)
station_info <- tibble(
  station = c("CB-5.1", "CB-5.2", "CB-5.3"),
  watershed = c("Upper", "Upper", "Lower"),
  drainage_area_km2 = c(150, 220, 340),
  land_use = c("Forest", "Agricultural", "Urban")
)

# Left join: keeps all water_quality rows
combined <- water_quality |>
  left_join(station_info, by = "station")

print("Left join result (note NA for CB-5.4):")
print(combined)

# Inner join: only rows with matches in both
matched_only <- water_quality |>
  inner_join(station_info, by = "station")

cat("\nInner join: only", nrow(matched_only), "rows (excluding CB-5.4)\n")

# Anti join: find measurements without station info
unmatched <- water_quality |>
  anti_join(station_info, by = "station")

print("Unmatched rows (anti_join):")
print(unmatched)


# ==============================================================================
# EXERCISE 9: Combining Precipitation and Streamflow Data
# ==============================================================================
cat("\n--- Exercise 9: Multi-Source Environmental Data ---\n")

# Create precipitation data (wide format, 30 days, 3 gauges)
set.seed(42)
dates <- seq(as.Date("2025-06-01"), by = "day", length.out = 30)

precip_wide <- tibble(
  date = dates,
  gauge_A = rpois(30, 3),
  gauge_B = rpois(30, 5),
  gauge_C = rpois(30, 4)
)

# Create streamflow data (long format, 30 days, 2 gauges)
streamflow <- tibble(
  date = rep(dates, 2),
  stream_gauge = rep(c("stream_1", "stream_2"), each = 30),
  discharge_cms = c(runif(30, 10, 50), runif(30, 20, 80))
)

# Create lookup table mapping stream gauges to rain gauges
gauge_lookup <- tibble(
  stream_gauge = c("stream_1", "stream_2"),
  rain_gauge = c("gauge_A", "gauge_B")
)

# Pivot precipitation to long format
precip_long <- precip_wide |>
  pivot_longer(
    cols = starts_with("gauge"),
    names_to = "rain_gauge",
    values_to = "precip_mm"
  )

# Join all datasets
combined_hydro <- streamflow |>
  left_join(gauge_lookup, by = "stream_gauge") |>
  left_join(precip_long, by = c("rain_gauge", "date")) |>
  group_by(stream_gauge) |>
  arrange(date) |>
  mutate(
    precip_3day = precip_mm +
                  lag(precip_mm, 1, default = 0) +
                  lag(precip_mm, 2, default = 0)
  ) |>
  ungroup()

print("Combined hydrology data:")
print(head(combined_hydro, 10))

# Plot streamflow vs cumulative rainfall
p2 <- ggplot(combined_hydro, aes(x = precip_3day, y = discharge_cms)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~stream_gauge) +
  labs(title = "Streamflow vs 3-Day Cumulative Rainfall",
       x = "3-Day Precipitation (mm)",
       y = "Discharge (m3/s)") +
  theme_minimal()

# print(p2)  # Uncomment to display plot


# ==============================================================================
# EXERCISE 10: Reshaping EPA Air Quality Data
# ==============================================================================
cat("\n--- Exercise 10: Air Quality Transformation ---\n")

# Create sample air quality data (2 sites, 30 days, 4 pollutants)
set.seed(123)
dates <- seq(as.Date("2025-01-01"), by = "day", length.out = 30)

air_quality <- tibble(
  site = rep(c("Urban_1", "Rural_1"), each = 30),
  date = rep(dates, 2),
  PM25 = c(rnorm(30, 15, 5), rnorm(30, 8, 3)),
  O3 = c(rnorm(30, 0.04, 0.01), rnorm(30, 0.03, 0.008)),
  NO2 = c(rnorm(30, 30, 10), rnorm(30, 15, 5)),
  CO = c(rnorm(30, 1.0, 0.3), rnorm(30, 0.4, 0.15))
)

# Pivot to long format
air_long <- air_quality |>
  pivot_longer(
    cols = c(PM25, O3, NO2, CO),
    names_to = "pollutant",
    values_to = "concentration"
  )

print("Air quality (long format):")
print(head(air_long, 10))

# Daily summaries per pollutant
daily_summary <- air_long |>
  group_by(site, pollutant) |>
  summarize(
    mean_conc = mean(concentration),
    max_conc = max(concentration),
    .groups = "drop"
  )

print("Daily summaries:")
print(daily_summary)

# Pollutant info table with units and thresholds
pollutant_info <- tibble(
  pollutant = c("PM25", "O3", "NO2", "CO"),
  units = c("ug/m3", "ppm", "ppb", "ppm"),
  threshold = c(35, 0.07, 100, 9)
)

# Join with pollutant info
air_with_info <- air_long |>
  left_join(pollutant_info, by = "pollutant") |>
  mutate(exceeds_threshold = concentration > threshold)

# Count exceedances
exceedance_summary <- air_with_info |>
  group_by(site, pollutant) |>
  summarize(
    n_exceedances = sum(exceeds_threshold),
    pct_exceedances = mean(exceeds_threshold) * 100,
    .groups = "drop"
  )

print("Exceedance summary:")
print(exceedance_summary)

# Create faceted time series
p3 <- ggplot(air_long, aes(x = date, y = concentration, color = site)) +
  geom_line() +
  facet_wrap(~pollutant, scales = "free_y") +
  labs(title = "Air Quality Time Series by Pollutant") +
  theme_minimal()

# print(p3)  # Uncomment to display plot


# ==============================================================================
# EXERCISE 11: Analyzing PFAS Contamination Trends
# ==============================================================================
cat("\n--- Exercise 11: PFAS Contamination Analysis ---\n")

# Create PFAS sample data (20 wells, 3 compounds, 1-3 samples)
set.seed(456)
wells <- paste0("WELL_", sprintf("%02d", 1:20))

pfas_data <- expand_grid(
  well_id = wells,
  sample_date = as.Date(c("2024-06-01", "2024-12-01", "2025-06-01"))
) |>
  mutate(
    PFOS = pmax(0, rnorm(n(), 3, 2)),
    PFOA = pmax(0, rnorm(n(), 2.5, 1.5)),
    PFHxS = pmax(0, rnorm(n(), 1.5, 1))
  )

# Pivot longer to analyze all compounds together
pfas_long <- pfas_data |>
  pivot_longer(
    cols = c(PFOS, PFOA, PFHxS),
    names_to = "compound",
    values_to = "concentration"
  )

# Calculate total PFAS per sample
pfas_totals <- pfas_long |>
  group_by(well_id, sample_date) |>
  summarize(
    total_pfas = sum(concentration),
    n_compounds = n(),
    max_compound = compound[which.max(concentration)],
    .groups = "drop"
  )

print("PFAS totals (sample):")
print(head(pfas_totals, 10))

# Identify wells exceeding thresholds
exceedances <- pfas_long |>
  mutate(
    exceeds = case_when(
      compound == "PFOS" & concentration > 4 ~ TRUE,
      compound == "PFOA" & concentration > 4 ~ TRUE,
      TRUE ~ FALSE
    )
  ) |>
  filter(exceeds)

cat("\nNumber of threshold exceedances:", nrow(exceedances), "\n")

# Create summary table: one row per well, columns for each compound's max
well_summary <- pfas_long |>
  group_by(well_id, compound) |>
  summarize(max_conc = max(concentration), .groups = "drop") |>
  pivot_wider(
    names_from = compound,
    values_from = max_conc
  ) |>
  mutate(total_max = PFOS + PFOA + PFHxS)

print("Well summary (max concentrations):")
print(well_summary)


# ==============================================================================
# EXERCISE 12: Vegetation Plot Data Transformation
# ==============================================================================
cat("\n--- Exercise 12: Ecological Survey Transformation ---\n")

# Create hierarchical vegetation data
set.seed(789)
species_list <- c("Native_Grass_A", "Native_Grass_B", "Native_Forb_A",
                  "Invasive_Grass", "Invasive_Forb")

veg_data <- expand_grid(
  site = c("Pre_Restore", "Post_Restore"),
  plot = paste0("Plot_", 1:3),
  quadrat = paste0("Q", 1:4)
) |>
  crossing(species = species_list) |>
  mutate(
    # Simulate cover percentages (higher native cover in Post_Restore)
    base_cover = ifelse(site == "Post_Restore" & !str_detect(species, "Invasive"),
                        15, 8),
    cover = pmax(0, rnorm(n(), base_cover, 5)),
    is_native = !str_detect(species, "Invasive")
  ) |>
  select(-base_cover)

print("Vegetation data (sample):")
print(head(veg_data, 10))

# Calculate Shannon diversity per quadrat
# Shannon: H' = -sum(p_i * ln(p_i))
diversity <- veg_data |>
  filter(cover > 0) |>
  group_by(site, plot, quadrat) |>
  mutate(
    total_cover = sum(cover),
    p = cover / total_cover
  ) |>
  summarize(
    species_richness = n_distinct(species),
    shannon = -sum(p * log(p)),
    .groups = "drop"
  )

print("Diversity metrics:")
print(diversity)

# Aggregate to plot level
plot_summary <- diversity |>
  group_by(site, plot) |>
  summarize(
    mean_richness = mean(species_richness),
    mean_shannon = mean(shannon),
    .groups = "drop"
  )

print("Plot-level summary:")
print(plot_summary)

# Site x species matrix (mean cover per species)
site_species <- veg_data |>
  group_by(site, species) |>
  summarize(mean_cover = mean(cover), .groups = "drop") |>
  pivot_wider(names_from = species, values_from = mean_cover)

print("Site x Species matrix:")
print(site_species)

# Native vs invasive comparison
native_comparison <- veg_data |>
  group_by(site, is_native) |>
  summarize(total_cover = sum(cover), .groups = "drop") |>
  pivot_wider(names_from = is_native, values_from = total_cover) |>
  rename(invasive_cover = `FALSE`, native_cover = `TRUE`) |>
  mutate(native_ratio = native_cover / (native_cover + invasive_cover))

print("Native vs Invasive comparison:")
print(native_comparison)


# ==============================================================================
# EXERCISE 13: Aligning Multi-Resolution Sensor Data
# ==============================================================================
cat("\n--- Exercise 13: Time Series Alignment ---\n")

# Create 15-minute temperature data (7 days)
temp_15min <- tibble(
  timestamp = seq(ymd_hms("2025-06-01 00:00:00"),
                  ymd_hms("2025-06-07 23:45:00"),
                  by = "15 min")
) |>
  mutate(
    temperature = 20 + 8 * sin(hour(timestamp) * pi / 12) + rnorm(n(), 0, 1)
  )

cat("15-min temperature data:", nrow(temp_15min), "rows\n")

# Create hourly soil moisture data
soil_hourly <- tibble(
  timestamp = seq(ymd_hms("2025-06-01 00:00:00"),
                  ymd_hms("2025-06-07 23:00:00"),
                  by = "hour")
) |>
  mutate(
    soil_moisture = runif(n(), 0.2, 0.4)
  )

cat("Hourly soil moisture data:", nrow(soil_hourly), "rows\n")

# Create daily precipitation
precip_daily <- tibble(
  date = seq(ymd("2025-06-01"), ymd("2025-06-07"), by = "day"),
  precip_mm = rpois(7, 5)
)

cat("Daily precipitation data:", nrow(precip_daily), "rows\n")

# Aggregate temperature to hourly means
temp_hourly <- temp_15min |>
  mutate(hour = floor_date(timestamp, "hour")) |>
  group_by(hour) |>
  summarize(
    temp_mean = mean(temperature),
    temp_min = min(temperature),
    temp_max = max(temperature),
    .groups = "drop"
  )

# Expand precipitation to hourly (divide daily by 24)
precip_hourly <- precip_daily |>
  mutate(date = as.POSIXct(date, tz = "UTC")) |>
  crossing(hour_offset = 0:23) |>
  mutate(
    hour = date + hours(hour_offset),
    precip_mm_hourly = precip_mm / 24
  ) |>
  select(hour, precip_mm_hourly)

# Join all datasets by hour
aligned_data <- temp_hourly |>
  left_join(soil_hourly |> rename(hour = timestamp), by = "hour") |>
  left_join(precip_hourly, by = "hour")

print("Aligned multi-resolution data:")
print(head(aligned_data, 10))

cat("\nFinal aligned dataset:", nrow(aligned_data), "rows\n")

# Summary statistics
cat("\nSummary of aligned data:\n")
print(summary(aligned_data))


# ==============================================================================
# END OF SOLUTIONS
# ==============================================================================
cat("\n--- All exercises completed! ---\n")
