// =============================================================================
// Lecture 3: Data Abstraction and Transformation Exercises
// Environmental Data Science (ENST431)
// Solutions Document
// =============================================================================

// --- CONFIGURATION & COLORS ---
#let primary-color = rgb("#2d5a27")
#let accent-color = rgb("#457b9d")
#let bg-color = rgb("#fdfdfc")
#let text-color = rgb("#2f2f2f")
#let code-bg = luma(248)

#set page(
  paper: "us-letter",
  fill: bg-color,
  margin: (x: 1in, y: 0.85in),
  numbering: "1",
)

#set text(size: 11pt, fill: text-color, font: "New Computer Modern")
#set heading(numbering: none)

#let solution-header(title) = {
  v(1em)
  block(width: 100%, stroke: (bottom: 2pt + primary-color), inset: (bottom: 0.5em), [
    #text(weight: "bold", size: 14pt, fill: primary-color, title)
  ])
  v(0.5em)
}

#let section-title(title) = {
  text(weight: "semibold", fill: accent-color, title)
}

#let code-box(body) = {
  rect(fill: code-bg, stroke: 0.5pt + luma(200), width: 100%, inset: 0.8em, radius: 4pt, [
    #set text(size: 9pt, font: "DejaVu Sans Mono")
    #body
  ])
}

#align(center)[
  #text(size: 18pt, weight: "bold", fill: primary-color)[Solutions: Data Abstraction and Transformation]
  #v(0.5em)
  #text(size: 12pt)[ENST431: Environmental Data Science]
]

// =============================================================================
// EXERCISE 1
// =============================================================================

#solution-header("Exercise 1: Importing the Chesapeake Bay Data with readr")

#section-title("Key Concepts")

The `readr` package provides improved CSV import with automatic type detection, better NA handling, and tibble output.

#section-title("R Code Solution")
#code-box(```r
library(tidyverse)

# 1. Basic import with automatic type detection
water_data <- read_csv("water_quality.csv")

# View the column specification message
spec(water_data)

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
problems(water_data)

# 5. Compare glimpse() to str()
glimpse(water_data)  # Tidyverse: compact, horizontal view
str(water_data)      # Base R: traditional structure view
```)

#pagebreak()

// =============================================================================
// EXERCISE 2
// =============================================================================

#solution-header("Exercise 2: Extracting Hypoxia Events with dplyr")

#section-title("Key Concepts")

The pipe operator `|>` creates readable, top-to-bottom workflows. `filter()`, `select()`, and `arrange()` are the core dplyr verbs for data extraction.

#section-title("R Code Solution")
#code-box(```r
# Fisheries Biologist Request
fisheries_data <- water_data |>
  filter(
    date == as.Date("2025-07-23"),
    do_mg_l < 6.0 | turbidity_ntu > 15
  ) |>
  select(station, date, do_mg_l, turbidity_ntu) |>
  arrange(do_mg_l)

# Count observations at each step
water_data |>
  filter(date == as.Date("2025-07-23")) |>
  count()  # After date filter

water_data |>
  filter(date == as.Date("2025-07-23"),
         do_mg_l < 6.0 | turbidity_ntu > 15) |>
  count()  # After condition filter

# Researcher Request
researcher_data <- water_data |>
  filter(
    station %in% c("CB-5.1", "CB-5.2"),
    between(temp_c, 24, 26),
    !is.na(do_mg_l)
  ) |>
  select(station, date, temp_c, dissolved_oxygen = do_mg_l)

# Using select helpers
water_data |>
  select(station, date, starts_with("temp"), ends_with("_l"))
```)

#pagebreak()

// =============================================================================
// EXERCISE 3
// =============================================================================

#solution-header("Exercise 3: Calculating Derived Variables with mutate")

#section-title("Key Concepts")

`mutate()` adds new columns. `case_when()` provides clean conditional logic, replacing nested `ifelse()`. Order of conditions matters - first match wins.

#section-title("R Code Solution")
#code-box(```r
library(lubridate)

water_enhanced <- water_data |>
  mutate(
    # Temperature conversion
    temp_f = temp_c * 9/5 + 32,

    # DO percent saturation
    do_percent_sat = (do_mg_l / 8.0) * 100,

    # Log turbidity
    log_turbidity = log(turbidity_ntu),

    # DO status with case_when (order matters!)
    do_status = case_when(
      is.na(do_mg_l) ~ "Unknown",    # Handle NA first
      do_mg_l < 2 ~ "Hypoxic",
      do_mg_l < 5 ~ "Stressed",
      do_mg_l < 8 ~ "Adequate",
      TRUE ~ "Healthy"                # Default case
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
```)

#pagebreak()

// =============================================================================
// EXERCISE 4
// =============================================================================

#solution-header("Exercise 4: Station Summaries with group_by and summarize")

#section-title("Key Concepts")

`group_by() |> summarize()` collapses groups to summary rows. `group_by() |> mutate()` adds group stats to each row without collapsing. Always `ungroup()` when done!

#section-title("R Code Solution")
#code-box(```r
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

# Part 2: Station-Relative Analysis (grouped mutate)
station_relative <- water_enhanced |>
  group_by(station) |>
  mutate(
    station_mean_temp = mean(temp_c, na.rm = TRUE),
    temp_deviation = temp_c - station_mean_temp,
    do_rank = min_rank(desc(do_mg_l))  # Highest DO = rank 1
  ) |>
  ungroup()

# Bonus: Using across() for multiple columns
water_enhanced |>
  group_by(station) |>
  summarize(
    across(c(temp_c, do_mg_l, turbidity_ntu),
           list(mean = ~mean(., na.rm = TRUE),
                sd = ~sd(., na.rm = TRUE)))
  )
```)

#pagebreak()

// =============================================================================
// EXERCISE 5
// =============================================================================

#solution-header("Exercise 5: Cleaning Station Names with stringr")

#section-title("Key Concepts")

`stringr` functions are pipe-friendly and consistent. Common functions: `str_trim()`, `str_to_upper()`, `str_replace()`, `str_extract()`, `str_detect()`.

#section-title("R Code Solution")
#code-box(```r
# Create sample messy data
messy_stations <- tibble(
  station_name = c(" CB-5.1 ", "cb-5.2", "CB_5.3", "Chesapeake Bay 5.4")
)

# Clean station names
cleaned_stations <- messy_stations |>
  mutate(
    # Chain string operations
    clean_name = station_name |>
      str_trim() |>           # Remove whitespace
      str_to_upper() |>       # Uppercase
      str_replace("_", "-"),  # Replace underscore with hyphen

    # Extract numeric portion using regex
    station_number = str_extract(station_name, "[0-9]+\\.[0-9]+"),

    # Detect specific patterns
    is_full_name = str_detect(station_name, "Chesapeake")
  )

print(cleaned_stations)

# Replace all occurrences (not just first)
str_replace_all("a_b_c", "_", "-")  # "a-b-c"
```)

#pagebreak()

// =============================================================================
// EXERCISE 6
// =============================================================================

#solution-header("Exercise 6: Reshaping Climate Normals Data")

#section-title("Key Concepts")

`pivot_longer()` converts wide data to long format. Specify which columns to pivot, name for the names column, and name for the values column.

#section-title("R Code Solution")
#code-box(```r
# Create wide climate data
climate_wide <- tibble(
  station = c("SFO_AIRPORT", "SACRAMENTO", "FRESNO"),
  jan_temp = c(10.2, 7.8, 6.5),
  apr_temp = c(13.5, 14.2, 15.8),
  jul_temp = c(17.8, 24.5, 28.2),
  oct_temp = c(16.2, 18.5, 19.8)
)

# Pivot to long format
climate_long <- climate_wide |>
  pivot_longer(
    cols = jan_temp:oct_temp,     # Columns to pivot
    names_to = "month",            # New column for names
    values_to = "temperature",     # New column for values
    names_prefix = "temp_"         # Remove prefix from names
  )

# Verify: 3 stations x 4 months = 12 rows
nrow(climate_long)

# Convert month to ordered factor
climate_long <- climate_long |>
  mutate(
    month = str_remove(month, "_temp"),
    month = factor(month, levels = c("jan", "apr", "jul", "oct"))
  )

# Create line plot
ggplot(climate_long, aes(x = month, y = temperature,
                         color = station, group = station)) +
  geom_line() +
  geom_point() +
  labs(title = "Seasonal Temperature Patterns",
       y = "Temperature (C)") +
  theme_minimal()
```)

#pagebreak()

// =============================================================================
// EXERCISE 7
// =============================================================================

#solution-header("Exercise 7: Creating a Species Presence Matrix")

#section-title("Key Concepts")

`pivot_wider()` converts long data to wide format. Use `values_fill` to handle missing combinations. Use `across()` to transform multiple columns.

#section-title("R Code Solution")
#code-box(```r
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

# Pivot to wide species matrix
species_matrix <- wildlife_survey |>
  pivot_wider(
    names_from = species,
    values_from = count,
    values_fill = 0  # Fill missing with 0
  )

# Convert to presence/absence
presence_matrix <- species_matrix |>
  mutate(across(-site, ~if_else(. > 0, 1L, 0L)))

# Calculate species richness per site
presence_matrix <- presence_matrix |>
  mutate(
    species_richness = rowSums(across(-site))
  )

print(presence_matrix)
```)

#pagebreak()

// =============================================================================
// EXERCISE 8
// =============================================================================

#solution-header("Exercise 8: Combining Water Quality and Watershed Data")

#section-title("Key Concepts")

Join types: `left_join()` keeps all left rows, `inner_join()` keeps only matches, `anti_join()` finds non-matches.

#section-title("R Code Solution")
#code-box(```r
# Create water quality measurements
water_quality <- tibble(
  station = rep(c("CB-5.1", "CB-5.2", "CB-5.3", "CB-5.4"), each = 3),
  date = rep(as.Date("2025-06-01") + 0:2, 4),
  do_mg_l = runif(12, 4, 9),
  turbidity = runif(12, 5, 25)
)

# Create station metadata
station_info <- tibble(
  station = c("CB-5.1", "CB-5.2", "CB-5.3"),  # Note: CB-5.4 missing!
  watershed = c("Upper", "Upper", "Lower"),
  drainage_area_km2 = c(150, 220, 340),
  land_use = c("Forest", "Agricultural", "Urban")
)

# Left join: keeps all water_quality rows
combined <- water_quality |>
  left_join(station_info, by = "station")

# Inner join: only rows with matches in both
matched_only <- water_quality |>
  inner_join(station_info, by = "station")

# Anti join: find measurements without station info
unmatched <- water_quality |>
  anti_join(station_info, by = "station")

# Correlation analysis
combined |>
  filter(!is.na(drainage_area_km2)) |>
  summarize(
    cor_turb_drainage = cor(turbidity, drainage_area_km2)
  )
```)

#pagebreak()

// =============================================================================
// EXERCISE 9
// =============================================================================

#solution-header("Exercise 9: Combining Precipitation and Streamflow Data")

#section-title("Key Concepts")

Multi-source data integration requires: reshaping to common format, creating lookup tables, and chaining joins. Use `lag()` for cumulative calculations.

#section-title("R Code Solution")
#code-box(```r
# Create precipitation data (wide format)
set.seed(42)
dates <- seq(as.Date("2025-06-01"), by = "day", length.out = 30)

precip_wide <- tibble(
  date = dates,
  gauge_A = rpois(30, 3),
  gauge_B = rpois(30, 5),
  gauge_C = rpois(30, 4)
)

# Create streamflow data (long format)
streamflow <- tibble(
  date = rep(dates, 2),
  stream_gauge = rep(c("stream_1", "stream_2"), each = 30),
  discharge_cms = c(runif(30, 10, 50), runif(30, 20, 80))
)

# Create lookup table
gauge_lookup <- tibble(
  stream_gauge = c("stream_1", "stream_2"),
  rain_gauge = c("gauge_A", "gauge_B")
)

# Pivot precipitation to long
precip_long <- precip_wide |>
  pivot_longer(
    cols = starts_with("gauge"),
    names_to = "rain_gauge",
    values_to = "precip_mm"
  )

# Join all datasets
combined <- streamflow |>
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

# Plot
ggplot(combined, aes(x = precip_3day, y = discharge_cms)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm") +
  facet_wrap(~stream_gauge) +
  labs(title = "Streamflow vs 3-Day Cumulative Rainfall",
       x = "3-Day Precipitation (mm)",
       y = "Discharge (m3/s)") +
  theme_minimal()
```)

#pagebreak()

// =============================================================================
// EXERCISE 10
// =============================================================================

#solution-header("Exercise 10: Reshaping EPA Air Quality Data")

#section-title("Key Concepts")

For multi-pollutant data: pivot to long format for analysis and faceted visualization. Use `scales = "free_y"` when pollutants have different scales.

#section-title("R Code Solution")
#code-box(```r
# Create sample air quality data
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

# Daily summaries
daily_summary <- air_long |>
  group_by(site, pollutant) |>
  summarize(
    mean_conc = mean(concentration),
    max_conc = max(concentration),
    .groups = "drop"
  )

# Create faceted time series
ggplot(air_long, aes(x = date, y = concentration, color = site)) +
  geom_line() +
  facet_wrap(~pollutant, scales = "free_y") +
  labs(title = "Air Quality Time Series by Pollutant") +
  theme_minimal()

# Pollutant info table
pollutant_info <- tibble(
  pollutant = c("PM25", "O3", "NO2", "CO"),
  units = c("ug/m3", "ppm", "ppb", "ppm"),
  threshold = c(35, 0.07, 100, 9)
)

# Join with pollutant info
air_with_info <- air_long |>
  left_join(pollutant_info, by = "pollutant")
```)

#pagebreak()

// =============================================================================
// EXERCISE 11
// =============================================================================

#solution-header("Exercise 11: Analyzing PFAS Contamination Trends")

#section-title("Key Concepts")

For multi-compound contamination data: pivot longer to analyze all compounds, then pivot wider to create summary tables.

#section-title("R Code Solution")
#code-box(```r
# Create PFAS sample data
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

# Pivot longer
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

# Create summary table with max per compound
well_summary <- pfas_long |>
  group_by(well_id, compound) |>
  summarize(max_conc = max(concentration), .groups = "drop") |>
  pivot_wider(
    names_from = compound,
    values_from = max_conc
  )

print(well_summary)
```)

#pagebreak()

// =============================================================================
// EXERCISE 12
// =============================================================================

#solution-header("Exercise 12: Vegetation Plot Data Transformation")

#section-title("Key Concepts")

Hierarchical ecological data requires nested grouping. Shannon diversity: $H' = -sum(p_i times ln(p_i))$

#section-title("R Code Solution")
#code-box(```r
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
    cover = pmax(0, rnorm(n(), 10, 8)),
    is_native = !str_detect(species, "Invasive")
  )

# Calculate Shannon diversity per quadrat
diversity <- veg_data |>
  group_by(site, plot, quadrat) |>
  mutate(
    total_cover = sum(cover),
    p = cover / total_cover
  ) |>
  summarize(
    species_richness = n_distinct(species[cover > 0]),
    shannon = -sum(p * log(p), na.rm = TRUE),
    .groups = "drop"
  )

# Aggregate to plot level
plot_summary <- diversity |>
  group_by(site, plot) |>
  summarize(
    mean_richness = mean(species_richness),
    mean_shannon = mean(shannon),
    .groups = "drop"
  )

# Site x species matrix
site_species <- veg_data |>
  group_by(site, species) |>
  summarize(mean_cover = mean(cover), .groups = "drop") |>
  pivot_wider(names_from = species, values_from = mean_cover)

# Native vs invasive comparison
native_comparison <- veg_data |>
  group_by(site, is_native) |>
  summarize(total_cover = sum(cover), .groups = "drop") |>
  pivot_wider(names_from = is_native, values_from = total_cover,
              names_prefix = "native_")
```)

#pagebreak()

// =============================================================================
// EXERCISE 13
// =============================================================================

#solution-header("Exercise 13: Aligning Multi-Resolution Sensor Data")

#section-title("Key Concepts")

Use `floor_date()` to aggregate to common temporal resolution. Join datasets after aligning timestamps.

#section-title("R Code Solution")
#code-box(```r
library(lubridate)

# Create 15-minute temperature data
temp_15min <- tibble(
  timestamp = seq(ymd_hms("2025-06-01 00:00:00"),
                  ymd_hms("2025-06-07 23:45:00"),
                  by = "15 min"),
  temperature = 20 + 8 * sin(hour(timestamp) * pi / 12) + rnorm(n(), 0, 1)
)

# Create hourly soil moisture data
soil_hourly <- tibble(
  timestamp = seq(ymd_hms("2025-06-01 00:00:00"),
                  ymd_hms("2025-06-07 23:00:00"),
                  by = "hour"),
  soil_moisture = runif(n(), 0.2, 0.4)
)

# Create daily precipitation
precip_daily <- tibble(
  date = seq(ymd("2025-06-01"), ymd("2025-06-07"), by = "day"),
  precip_mm = rpois(7, 5)
)

# Aggregate temperature to hourly
temp_hourly <- temp_15min |>
  mutate(hour = floor_date(timestamp, "hour")) |>
  group_by(hour) |>
  summarize(
    temp_mean = mean(temperature),
    temp_min = min(temperature),
    temp_max = max(temperature)
  )

# Expand precipitation to hourly
precip_hourly <- precip_daily |>
  mutate(date = as.POSIXct(date)) |>
  crossing(hour_offset = 0:23) |>
  mutate(
    hour = date + hours(hour_offset),
    precip_mm_hourly = precip_mm / 24
  ) |>
  select(hour, precip_mm_hourly)

# Join all datasets
aligned_data <- temp_hourly |>
  rename(hour = hour) |>
  left_join(soil_hourly |> rename(hour = timestamp), by = "hour") |>
  left_join(precip_hourly, by = "hour")

glimpse(aligned_data)
```)
