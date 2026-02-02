# ==============================================================================
# 02_Solutions_to_R_Exercises.R
# Solutions to "Algorithms vs. Syntax" - R Programming Exercises
# Environmental Data Science (ENST431)
# ==============================================================================

# ------------------------------------------------------------------------------
# SETUP
# ------------------------------------------------------------------------------
# Install tidyverse if not already installed
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)

# ==============================================================================
# EXERCISE 1: Variables and Vectors
# ==============================================================================
cat("\n--- Exercise 1 ---\n")

# 1. Create variables for station metadata
station_id <- "CB-5.1"
latitude <- 38.9784
longitude <- -76.3811
sampling_depth <- 2L
is_active <- TRUE

# 2. Create vectors for readings
do_readings <- c(8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5)

# Monthly temperatures with names
monthly_temps <- c(
  Jan = 4.2, Feb = 4.5, Mar = 8.1, Apr = 12.5, May = 17.3, Jun = 22.1,
  Jul = 26.8, Aug = 26.5, Sep = 22.4, Oct = 16.3, Nov = 10.7, Dec = 6.1
)

# 3. Calculate statistics for dissolved oxygen
do_mean <- mean(do_readings)
do_sd <- sd(do_readings)
do_cv <- (do_sd / do_mean) * 100

cat(sprintf("DO Stats: Mean=%.2f, SD=%.2f, CV=%.2f%%\n", do_mean, do_sd, do_cv))

# 4. Logical vector for hypoxic conditions (DO < 5.0 mg/L)
is_hypoxic <- do_readings < 5.0
print("Hypoxic readings check:")
print(is_hypoxic)

# 5. Extract and count hypoxic values
hypoxic_values <- do_readings[is_hypoxic]
count_hypoxic <- length(hypoxic_values) # or sum(is_hypoxic)
cat("Number of hypoxic readings:", count_hypoxic, "\n")

# 6. Find depth position with lowest oxygen
# Assuming readings are at indices 1 to 10 (representing depths, though depth isn't explicitly mapped to index in problem,
# usually 1st reading is surface or specific depth. The prompt says "at 10 depths")
lowest_do_pos <- which.min(do_readings)
cat("Lowest oxygen found at index:", lowest_do_pos, "(Value:", do_readings[lowest_do_pos], ")\n")

# 7. Compare July temp to annual mean
annual_mean_temp <- mean(monthly_temps)
jul_diff <- monthly_temps["Jul"] - annual_mean_temp
cat("July is", round(jul_diff, 2), "degrees warmer than the annual average.\n")


# ==============================================================================
# EXERCISE 2: Importing Data
# ==============================================================================
cat("\n--- Exercise 2 ---\n")

# NOTE: This assumes 'water_quality.csv' exists in the working directory.
# If you need to generate a dummy file for testing:
# write_csv(tibble(
#   station = c("CB-5.1", "CB-5.1", "CB-5.2", "CB-5.2"),
#   date = as.Date(c("2025-06-01", "2025-06-02", "2025-06-01", "2025-06-02")),
#   temp_c = c(22.5, 23.1, 21.8, -999),
#   do_mg_l = c(7.5, 6.8, NA, 5.5),
#   ph = c(7.8, 7.7, 7.9, 7.6),
#   turbidity_ntu = c(12, 15, 8, 10)
# ), "water_quality.csv")

# 1. Read CSV with default settings (to see types)
# water_raw <- read_csv("water_quality.csv")
# spec(water_raw)

# 2 & 3. Re-import with explicit NA handling and column types
water_data <- read_csv(
  "water_quality.csv",
  na = c("", "NA", "N/A", "-999", "-9999"),
  col_types = cols(
    station = col_factor(),
    date = col_date(),
    # inferring other column names based on typical structure
    temp_c = col_double(),
    do_mg_l = col_double(),
    ph = col_double(),
    turbidity_ntu = col_double()
  )
)

# 4. Check for parsing problems
print(problems(water_data))

# 5. Count missing values in DO and Temp
na_do <- sum(is.na(water_data$do_mg_l))
na_temp <- sum(is.na(water_data$temp_c))
cat("Missing DO values:", na_do, "\n")
cat("Missing Temp values:", na_temp, "\n")


# ==============================================================================
# EXERCISE 3: Data Inspection and Validation
# ==============================================================================
cat("\n--- Exercise 3 ---\n")

# 1. Inspect structure
glimpse(water_data)
# summary(water_data)

# 2. Missing data summary
missing_summary <- water_data |>
  summarize(across(everything(), ~sum(is.na(.)))) |>
  pivot_longer(everything(), names_to = "variable", values_to = "na_count") |>
  mutate(pct_missing = (na_count / nrow(water_data)) * 100)

print(missing_summary)

# 3 & 4. Validation checks (Plausible ranges)
# Temp: 0-35, DO: 0-15, pH: 6-9
invalid_rows <- water_data |>
  filter(
    (temp_c < 0 | temp_c > 35) |
    (do_mg_l < 0 | do_mg_l > 15) |
    (ph < 6 | ph > 9)
  )

if (nrow(invalid_rows) > 0) {
  cat("Found", nrow(invalid_rows), "rows with potentially invalid data:\n")
  print(invalid_rows)
} else {
  cat("No data validation issues found based on ranges.\n")
}


# ==============================================================================
# EXERCISE 4: Filtering and Selecting
# ==============================================================================
cat("\n--- Exercise 4 ---\n")

# Request 1: Fisheries Biologist
# July 23rd, DO < 6.0 OR Turbidity > 15
fisheries_data <- water_data |>
  filter(
    date == as.Date("2025-07-23"),
    (do_mg_l < 6.0 | turbidity_ntu > 15)
  ) |>
  select(station, date, do_mg_l, turbidity_ntu) |>
  arrange(do_mg_l) # Ascending: lowest/worst first

print("Fisheries Data:")
print(head(fisheries_data))

# Request 2: Researcher
# Stations CB-5.1 OR CB-5.2, Temp 24-26, DO not missing
researcher_data <- water_data |>
  filter(
    station %in% c("CB-5.1", "CB-5.2"),
    between(temp_c, 24, 26),
    !is.na(do_mg_l)
  ) |>
  select(everything(), dissolved_oxygen = do_mg_l) # Rename

print("Researcher Data:")
print(head(researcher_data))


# ==============================================================================
# EXERCISE 5: Transforming Data
# ==============================================================================
cat("\n--- Exercise 5 ---\n")

water_enhanced <- water_data |>
  mutate(
    # 1. Temperature in Fahrenheit
    temp_f = temp_c * 9/5 + 32,

    # 2. DO Percent Saturation (simplified)
    do_percent_sat = (do_mg_l / 8.0) * 100,

    # 3. Log Turbidity
    log_turbidity = log(turbidity_ntu),

    # 4. Water Quality Status
    do_status = case_when(
      is.na(do_mg_l) ~ "Unknown",
      do_mg_l < 2.0 ~ "Hypoxic",
      do_mg_l < 5.0 ~ "Stressed",
      do_mg_l < 8.0 ~ "Adequate",
      TRUE ~ "Healthy"
    ),

    # 5. Time variables
    month = month(date, label = TRUE),
    day_of_year = yday(date),
    days_since_start = as.numeric(date - min(date, na.rm = TRUE)),

    # 6. Temperature Z-score
    temp_zscore = (temp_c - mean(temp_c, na.rm = TRUE)) / sd(temp_c, na.rm = TRUE)
  )

glimpse(water_enhanced)


# ==============================================================================
# EXERCISE 6: Grouping and Summarizing
# ==============================================================================
cat("\n--- Exercise 6 ---\n")

# Part 1: Station summary report
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

# Part 2: Station-relative analysis
station_relative <- water_enhanced |>
  group_by(station) |>
  mutate(
    station_mean_temp = mean(temp_c, na.rm = TRUE),
    temp_vs_station = temp_c - station_mean_temp,
    station_do_rank = min_rank(desc(do_mg_l)) # Rank 1 is highest DO
  ) |>
  ungroup()

print("Station Relative Data (first few cols):")
print(station_relative |> select(station, temp_c, temp_vs_station, station_do_rank) |> head())


# ==============================================================================
# EXERCISE 7: Tidying Data
# ==============================================================================
cat("\n--- Exercise 7 ---\n")

# Part 1: Pivot Longer
temps_wide <- tibble(
  station = c("CB-5.1", "CB-5.2"),
  jan = c(4.2, 3.8), apr = c(12.5, 11.9),
  jul = c(26.8, 27.1), oct = c(16.3, 15.8)
)

temps_long <- temps_wide |>
  pivot_longer(
    cols = c(jan, apr, jul, oct),
    names_to = "month",
    values_to = "temperature"
  )

print("Long Format:")
print(temps_long)

# Part 2: Pivot Wider (Back)
temps_wide_again <- temps_long |>
  pivot_wider(
    names_from = station,
    values_from = temperature
  )

print("Wide Format (Stations as columns):")
print(temps_wide_again)

# Part 3: Multi-variable Tidying
water_wide <- tibble(
  station = "CB-5.1",
  do_jun = 6.8, do_jul = 5.2,
  temp_jun = 24.5, temp_jul = 26.8
)

water_tidy <- water_wide |>
  pivot_longer(
    cols = -station,
    names_to = "name",
    values_to = "value"
  ) |>
  separate(name, into = c("variable", "month"), sep = "_") |>
  pivot_wider(
    names_from = variable,
    values_from = value
  )

print("Tidied Multi-variable Data:")
print(water_tidy)


# ==============================================================================
# EXERCISE 8: Data Visualization
# ==============================================================================
cat("\n--- Exercise 8 ---\n")
# Note: These commands generate plots. In a script, you might want to save them
# or just print them to the active graphics device.

# Plot 1: Temperature vs DO scatter
p1 <- ggplot(water_enhanced, aes(x = temp_c, y = do_mg_l)) +
  geom_point(aes(color = station)) +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Dissolved Oxygen vs Temperature",
    x = "Temperature (°C)",
    y = "Dissolved Oxygen (mg/L)",
    color = "Station"
  ) +
  theme_minimal()

# Plot 2: Turbidity distributions
# Using boxplot as it often allows good comparison across groups
p2 <- ggplot(water_enhanced, aes(x = station, y = turbidity_ntu, fill = station)) +
  geom_boxplot() +
  labs(title = "Turbidity Distribution by Station", y = "Turbidity (NTU)") +
  theme_minimal()

# Plot 3: DO Time Series with threshold
p3 <- ggplot(water_enhanced, aes(x = date, y = do_mg_l, color = station, group = station)) +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = 5.0, linetype = "dashed", color = "red") +
  labs(title = "DO Time Series", y = "DO (mg/L)") +
  theme_minimal()

# Plot 4: Faceted Comparison
p4 <- ggplot(water_enhanced, aes(x = temp_c, y = do_mg_l)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~station) +
  labs(title = "Temp vs DO by Station") +
  theme_minimal()

# Print plots if running interactively
# print(p1)
# print(p2)
# print(p3)
# print(p4)


# ==============================================================================
# EXERCISE 9: Writing Functions
# ==============================================================================
cat("\n--- Exercise 9 ---\n")

# 1. Temperature Conversion
celsius_to_fahrenheit <- function(temp_c) {
  return(temp_c * 9/5 + 32)
}

fahrenheit_to_celsius <- function(temp_f) {
  return((temp_f - 32) * 5/9)
}

# Test
print(paste("25C to F:", celsius_to_fahrenheit(25)))
print(paste("77F to C:", fahrenheit_to_celsius(77)))

# 2. Saturation Deficit
calc_saturation_deficit <- function(do_measured, temperature) {
  do_saturated <- 14.62 - (0.3898 * temperature)
  deficit <- do_saturated - do_measured
  return(deficit)
}

# Test
print(paste("Deficit at 6.5mg/L, 25C:", calc_saturation_deficit(6.5, 25)))

# 3. Water Quality Classifier
classify_water_quality <- function(do, temp, hypoxic_threshold = 2.0, stress_threshold = 5.0) {
  if (is.na(do) || is.na(temp)) return("Unknown")

  if (do < hypoxic_threshold) {
    return("Critical")
  } else if (do < stress_threshold) {
    return("Stressed")
  } else if (temp > 28) {
    return("Heat Stress")
  } else {
    return("Good")
  }
}

# Vectorized version for use in mutate (wrapper around simple function using sapply or case_when logic inside)
classify_water_quality_v <- Vectorize(classify_water_quality)

# Test
print(classify_water_quality(1.5, 20)) # Critical

# 4. Station Summarizer
summarize_station <- function(data, station_id) {
  station_data <- data |> filter(station == station_id)

  if (nrow(station_data) == 0) {
    warning("Station ID not found.")
    return(NULL)
  }

  result <- list(
    station = station_id,
    mean_temp = mean(station_data$temp_c, na.rm = TRUE),
    mean_do = mean(station_data$do_mg_l, na.rm = TRUE),
    n_observations = nrow(station_data),
    hypoxic_count = sum(station_data$do_mg_l < 2.0, na.rm = TRUE)
  )

  return(result)
}

# Test (assuming water_enhanced exists)
# print(summarize_station(water_enhanced, "CB-5.1"))


# ==============================================================================
# EXERCISE 10: Loops and Iteration
# ==============================================================================
cat("\n--- Exercise 10 ---\n")

# Part 1: For Loop
stations <- unique(water_enhanced$station)
for (st in stations) {
  st_data <- filter(water_enhanced, station == st)
  mean_t <- mean(st_data$temp_c, na.rm = TRUE)
  cat(paste("Station", st, ": Mean temperature =", round(mean_t, 2), "°C\n"))
}

# Part 2: Accumulating results
station_summaries <- list()
for (i in seq_along(stations)) {
  st <- stations[i]
  st_data <- filter(water_enhanced, station == st)

  # Create a 1-row data frame
  df <- tibble(
    station = st,
    mean_temp = mean(st_data$temp_c, na.rm = TRUE),
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    count = n()
  )

  station_summaries[[i]] <- df
}

all_summaries <- bind_rows(station_summaries)
print("Accumulated Summaries:")
print(all_summaries)

# Part 3: Simulation with While Loop
# Simulate hypoxia development
cat("Running Hypoxia Simulation...\n")
run_simulation <- function() {
  do_level <- 8.0
  days <- 0
  while (do_level >= 2.0) {
    do_level <- do_level - runif(1, 0.1, 0.5)
    days <- days + 1
  }
  return(days)
}

# Run 5 times
sim_results <- replicate(5, run_simulation())
cat("Days to hypoxia in 5 simulations:", paste(sim_results, collapse=", "), "\n")

# Part 4: Functional Iteration (purrr)
purrr_summary <- map_dfr(stations, function(st) {
  water_enhanced |>
    filter(station == st) |>
    summarize(
      station = st, # Add station name to output
      mean_temp = mean(temp_c, na.rm = TRUE),
      mean_do = mean(do_mg_l, na.rm = TRUE),
      count = n()
    )
})

print("Purrr Summaries:")
print(purrr_summary)
