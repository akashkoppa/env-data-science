# ==============================================================================
# 02_Solutions_to_Exercises.R
# Solutions to "Algorithms and Syntax" - Programming Exercises
# Environmental Data Science (ENST431)
# NOTE: All solutions use base R only — no external packages required.
# ==============================================================================

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

# 3. Calculate statistics — first WITHOUT built-in functions
# Mean: sum of all values divided by the number of values
#   mean = (x_1 + x_2 + ... + x_n) / n
do_mean_manual <- sum(do_readings) / length(do_readings)

# Standard deviation: square root of the average squared deviation from the mean
#   sd = sqrt( sum((x_i - mean)^2) / (n - 1) )
do_sd_manual <- sqrt(sum((do_readings - do_mean_manual)^2) / (length(do_readings) - 1))

cat(sprintf("Manual:   Mean=%.2f, SD=%.2f\n", do_mean_manual, do_sd_manual))

# Now using built-in functions (same result)
do_mean <- mean(do_readings)
do_sd <- sd(do_readings)
do_cv <- (do_sd / do_mean) * 100

cat(sprintf("Built-in: Mean=%.2f, SD=%.2f, CV=%.2f%%\n", do_mean, do_sd, do_cv))

# 4. Logical vector for hypoxic conditions (DO < 5.0 mg/L)
is_hypoxic <- do_readings < 5.0
print("Hypoxic readings check:")
print(is_hypoxic)

# 5. Extract and count hypoxic values
hypoxic_values <- do_readings[is_hypoxic]
count_hypoxic <- length(hypoxic_values) # or sum(is_hypoxic)
cat("Number of hypoxic readings:", count_hypoxic, "\n")

# 6. Find depth position with lowest oxygen
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
# write.csv(data.frame(
#   station = c("CB-5.1", "CB-5.1", "CB-5.2", "CB-5.2"),
#   date = c("2025-06-01", "2025-06-02", "2025-06-01", "2025-06-02"),
#   temp_c = c(22.5, 23.1, 21.8, -999),
#   do_mg_l = c(7.5, 6.8, NA, 5.5),
#   ph = c(7.8, 7.7, 7.9, 7.6),
#   turbidity_ntu = c(12, 15, 8, 10)
# ), "water_quality.csv", row.names = FALSE)

# Import with explicit handling of NAs
water_data <- read.csv(
  "/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/02_Algorithms/water_quality.csv",
  na.strings = c("", "NA", "N/A", "-999", "-9999"),
  stringsAsFactors = FALSE
)

# Convert column types manually
water_data$station <- as.factor(water_data$station)
water_data$date <- as.Date(water_data$date, format = "%Y-%m-%d")

# Inspect structure
str(water_data)
summary(water_data)

# Count missing values in DO and Temp
na_do <- sum(is.na(water_data$do_mg_l))
na_temp <- sum(is.na(water_data$temp_c))
cat("Missing DO values:", na_do, "\n")
cat("Missing Temp values:", na_temp, "\n")


# ==============================================================================
# EXERCISE 3: Data Inspection and Validation
# ==============================================================================
cat("\n--- Exercise 3 ---\n")

# 1. Inspect structure
str(water_data)
summary(water_data)

# 2. Missing data summary
# APPROACH A: Using a for loop (explicit, step-by-step)
na_counts <- c()
na_percent <- c()

for (col_name in names(water_data)) {
  col_data <- water_data[[col_name]]
  na_counts[col_name] <- sum(is.na(col_data))
  na_percent[col_name] <- mean(is.na(col_data)) * 100
}

missing_summary <- data.frame(
  variable = names(na_counts),
  na_count = na_counts,
  na_percent = round(na_percent, 2)
)

print(missing_summary)

# APPROACH B: Using sapply (compact, same result)
# sapply applies a function to each column and returns a vector
na_counts_v2 <- sapply(water_data, function(x) sum(is.na(x)))
na_percent_v2 <- sapply(water_data, function(x) mean(is.na(x)) * 100)

# 3 & 4. Validation checks (Plausible ranges)
# Temp: 0-35, DO: 0-15, pH: 6-9
invalid_condition <- (water_data$temp_c < 0 | water_data$temp_c > 35) |
                     (water_data$do_mg_l < 0 | water_data$do_mg_l > 15) |
                     (water_data$ph < 6 | water_data$ph > 9)

# Handle NAs in conditions (replace NA with FALSE)
invalid_condition[is.na(invalid_condition)] <- FALSE

invalid_rows <- water_data[invalid_condition, ]

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

# Step 1: Filter by date
fisheries_req <- water_data[water_data$date == as.Date("2025-07-23"), ]

# Step 2: Filter by DO or turbidity condition
condition <- (fisheries_req$do_mg_l < 6.0 | fisheries_req$turbidity_ntu > 15)
condition[is.na(condition)] <- FALSE
fisheries_req <- fisheries_req[condition, ]

# Step 3: Select columns
fisheries_req <- fisheries_req[, c("station", "date", "do_mg_l", "turbidity_ntu")]

# Step 4: Sort by DO ascending
fisheries_req <- fisheries_req[order(fisheries_req$do_mg_l), ]

print("Fisheries Data:")
print(head(fisheries_req))

# Request 2: Researcher
# Stations CB-5.1 OR CB-5.2, Temp 24-26, DO not missing

# Step 1: Filter by station
researcher_req <- water_data[water_data$station %in% c("CB-5.1", "CB-5.2"), ]

# Step 2: Filter by temperature range
researcher_req <- researcher_req[researcher_req$temp_c >= 24 &
                                  researcher_req$temp_c <= 26, ]

# Step 3: Remove rows with missing DO
researcher_req <- researcher_req[!is.na(researcher_req$do_mg_l), ]

# Step 4: Select and rename columns
researcher_req <- researcher_req[, c("station", "date", "temp_c", "do_mg_l")]
names(researcher_req)[names(researcher_req) == "do_mg_l"] <- "dissolved_oxygen"

print("Researcher Data:")
print(head(researcher_req))


# ==============================================================================
# EXERCISE 5: Transforming Data
# ==============================================================================
cat("\n--- Exercise 5 ---\n")

# Make a copy to avoid modifying original
water_enhanced <- water_data

# 1. Temperature in Fahrenheit
water_enhanced$temp_f <- water_enhanced$temp_c * 9/5 + 32

# 2. DO Percent Saturation (simplified)
water_enhanced$do_percent_sat <- (water_enhanced$do_mg_l / 8.0) * 100

# 3. Log Turbidity
water_enhanced$log_turbidity <- log(water_enhanced$turbidity_ntu)

# 4. Water Quality Status using nested ifelse
water_enhanced$do_status <- ifelse(is.na(water_enhanced$do_mg_l), "Unknown",
  ifelse(water_enhanced$do_mg_l < 2.0, "Hypoxic",
    ifelse(water_enhanced$do_mg_l < 5.0, "Stressed",
      ifelse(water_enhanced$do_mg_l < 8.0, "Adequate", "Healthy"))))

# 5. Time variables
water_enhanced$month <- format(water_enhanced$date, "%B")  # Full month name
water_enhanced$day_of_year <- as.integer(format(water_enhanced$date, "%j"))

# Days since start of monitoring (broken into steps)
# Step 1: Find the earliest date in the dataset
start_date <- min(water_enhanced$date, na.rm = TRUE)

# Step 2: Calculate the difference between each date and the start date
date_difference <- difftime(water_enhanced$date, start_date, units = "days")

# Step 3: Convert to numeric (removes the "days" label)
water_enhanced$days_since_start <- as.numeric(date_difference)

# 6. Temperature Z-score
temp_mean <- mean(water_enhanced$temp_c, na.rm = TRUE)
temp_sd <- sd(water_enhanced$temp_c, na.rm = TRUE)
water_enhanced$temp_zscore <- (water_enhanced$temp_c - temp_mean) / temp_sd

str(water_enhanced)


# ==============================================================================
# EXERCISE 6: Grouping and Summarizing
# ==============================================================================
cat("\n--- Exercise 6 ---\n")

# First, define helper functions for clarity
# These make the aggregate() and ave() calls easier to read
mean_na_rm <- function(x) {
  mean(x, na.rm = TRUE)
}

max_na_rm <- function(x) {
  max(x, na.rm = TRUE)
}

prop_below_6 <- function(x) {
  # Calculate proportion of values below 6.0
  mean(x < 6.0, na.rm = TRUE)
}

rank_descending <- function(x) {
  # Rank values so highest value gets rank 1
  rank(-x, na.last = "keep")
}

# Part 1: Station summary report using aggregate
# aggregate() splits data by group and applies a function to each group
mean_temp <- aggregate(temp_c ~ station, data = water_enhanced, FUN = mean_na_rm)
mean_do <- aggregate(do_mg_l ~ station, data = water_enhanced, FUN = mean_na_rm)
max_turb <- aggregate(turbidity_ntu ~ station, data = water_enhanced, FUN = max_na_rm)
n_obs <- aggregate(temp_c ~ station, data = water_enhanced, FUN = length)
prop_stressed <- aggregate(do_mg_l ~ station, data = water_enhanced, FUN = prop_below_6)

# Combine into one data frame
station_summary <- data.frame(
  station = mean_temp$station,
  mean_temp = mean_temp$temp_c,
  mean_do = mean_do$do_mg_l,
  max_turb = max_turb$turbidity_ntu,
  n = n_obs$temp_c,
  prop_stressed = prop_stressed$do_mg_l
)

print("Station Summary:")
print(station_summary)

# Part 2: Station-relative analysis using ave()
# ave() applies a function to groups but returns a vector the same length as input
# (unlike aggregate which collapses to one row per group)
water_enhanced$station_mean_temp <- ave(
  water_enhanced$temp_c,
  water_enhanced$station,
  FUN = mean_na_rm
)

water_enhanced$temp_vs_station <- water_enhanced$temp_c - water_enhanced$station_mean_temp

water_enhanced$station_do_rank <- ave(
  water_enhanced$do_mg_l,
  water_enhanced$station,
  FUN = rank_descending
)

print("Station Relative Data (first few rows):")
print(head(water_enhanced[, c("station", "temp_c", "temp_vs_station", "station_do_rank")]))


# ==============================================================================
# EXERCISE 7: Tidying Data
# ==============================================================================
cat("\n--- Exercise 7 ---\n")

# Part 1: Wide to Long using stack()
temps_wide <- data.frame(
  station = c("CB-5.1", "CB-5.2"),
  jan = c(4.2, 3.8), apr = c(12.5, 11.9),
  jul = c(26.8, 27.1), oct = c(16.3, 15.8)
)

# Stack the month columns
stacked <- stack(temps_wide[, c("jan", "apr", "jul", "oct")])
temps_long <- data.frame(
  station = rep(temps_wide$station, 4),
  month = stacked$ind,
  temperature = stacked$values
)

print("Long Format:")
print(temps_long)

# Alternative using reshape()
temps_long_v2 <- reshape(temps_wide,
  direction = "long",
  varying = list(c("jan", "apr", "jul", "oct")),
  v.names = "temperature",
  timevar = "month",
  times = c("jan", "apr", "jul", "oct"),
  idvar = "station"
)

# Part 2: Pivot back to wide (stations as columns)
temps_wide_again <- reshape(temps_long,
  direction = "wide",
  idvar = "month",
  timevar = "station",
  v.names = "temperature"
)

print("Wide Format (Stations as columns):")
print(temps_wide_again)

# Part 3: Multi-variable Tidying
water_wide <- data.frame(
  station = "CB-5.1",
  do_jun = 6.8, do_jul = 5.2,
  temp_jun = 24.5, temp_jul = 26.8
)

# Step 1: Stack to long format
stacked <- stack(water_wide[, -1])  # Exclude station column
long_df <- data.frame(
  station = rep(water_wide$station, ncol(water_wide) - 1),
  name = as.character(stacked$ind),
  value = stacked$values
)

# Step 2: Split the name column into variable and month
parts <- strsplit(long_df$name, "_")

# APPROACH A: Using a for loop (explicit, step-by-step)
long_df$variable <- character(nrow(long_df))
long_df$month <- character(nrow(long_df))

for (i in 1:nrow(long_df)) {
  long_df$variable[i] <- parts[[i]][1]  # First part (do, temp)
  long_df$month[i] <- parts[[i]][2]     # Second part (jun, jul)
}

# APPROACH B: Using sapply (compact, same result)
# sapply(parts, "[", 1) extracts the 1st element from each list item
# long_df$variable <- sapply(parts, "[", 1)
# long_df$month <- sapply(parts, "[", 2)

# Step 3: Reshape to wide format
water_tidy <- reshape(long_df[, c("station", "month", "variable", "value")],
  direction = "wide",
  idvar = c("station", "month"),
  timevar = "variable",
  v.names = "value"
)
names(water_tidy) <- gsub("value\\.", "", names(water_tidy))

print("Tidied Multi-variable Data:")
print(water_tidy)


# ==============================================================================
# EXERCISE 8: Combining Monitoring Databases
# ==============================================================================
cat("\n--- Exercise 8 ---\n")

# Part 1: Create station metadata
station_meta <- data.frame(
  station = c("CB-5.1", "CB-5.2", "CB-5.3", "CB-6.1"),
  region = c("Main Stem", "Main Stem", "Main Stem", "Lower Bay"),
  type = c("Fixed", "Fixed", "Fixed", "Rotating"),
  lat = c(38.978, 38.856, 38.742, 37.587),
  lon = c(-76.381, -76.372, -76.321, -76.138)
)

# Inner join: only stations present in BOTH datasets
merged_inner <- merge(water_data, station_meta, by = "station")
cat("Inner join rows:", nrow(merged_inner), "\n")

# Left join: keep all water quality rows
merged_left <- merge(water_data, station_meta, by = "station", all.x = TRUE)
cat("Left join rows:", nrow(merged_left), "\n")

# Which stations are in metadata but not in water quality data?
missing_from_wq <- setdiff(station_meta$station, unique(water_data$station))
cat("Stations in metadata but not in water quality:", missing_from_wq, "\n")

# Which stations are in water quality but not in metadata?
missing_from_meta <- setdiff(unique(water_data$station), station_meta$station)
cat("Stations in water quality but not in metadata:", missing_from_meta, "\n")

# Part 2: Nutrient data merge
nutrient_data <- data.frame(
  station = c("CB-5.1", "CB-5.2", "CB-6.1"),
  date = as.Date(c("2025-06-15", "2025-06-15", "2025-06-15")),
  nitrogen_mg_l = c(1.2, 1.5, 0.9),
  phosphorus_mg_l = c(0.08, 0.12, 0.06)
)

# Merge by both station and date
combined <- merge(water_data, nutrient_data,
                  by = c("station", "date"), all.x = TRUE)
cat("Combined rows:", nrow(combined), "\n")
cat("Rows with nutrient data:", sum(!is.na(combined$nitrogen_mg_l)), "\n")

# Part 3: Stacking datasets
# Simulate a second batch with same columns
batch2 <- water_data[1:5, ]
stacked <- rbind(water_data, batch2)
cat("Original rows:", nrow(water_data), "\n")
cat("Batch 2 rows:", nrow(batch2), "\n")
cat("Stacked rows:", nrow(stacked), "\n")
cat("Verified:", nrow(stacked) == nrow(water_data) + nrow(batch2), "\n")


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

# Vectorized version using Vectorize (base R)
classify_water_quality_v <- Vectorize(classify_water_quality)

# Test
print(classify_water_quality(1.5, 20)) # Critical

# 4. Station Summarizer using base R
summarize_station <- function(data, station_id) {
  # Filter using logical indexing
  st_data <- data[data$station == station_id, ]

  if (nrow(st_data) == 0) {
    warning(paste("Station", station_id, "not found in data"))
    return(NULL)
  }

  list(
    station = station_id,
    mean_temp = mean(st_data$temp_c, na.rm = TRUE),
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    n_observations = nrow(st_data),
    hypoxic_count = sum(st_data$do_mg_l < 2.0, na.rm = TRUE)
  )
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
  st_data <- water_enhanced[water_enhanced$station == st, ]
  mean_temp <- mean(st_data$temp_c, na.rm = TRUE)
  print(paste("Station", st, ": Mean temperature =", round(mean_temp, 2), "C"))
}

# Part 2: Accumulating results
station_summaries <- list()
for (i in seq_along(stations)) {
  st <- stations[i]
  st_data <- water_enhanced[water_enhanced$station == st, ]

  station_summaries[[i]] <- data.frame(
    station = st,
    mean_temp = mean(st_data$temp_c, na.rm = TRUE),
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    count = nrow(st_data)
  )
}

# Combine list into single data frame
all_summaries <- do.call(rbind, station_summaries)
print("Accumulated Summaries:")
print(all_summaries)

# Part 3: Simulation with While Loop
cat("Running Hypoxia Simulation...\n")

do_level <- 8.0
days <- 0

while (do_level >= 2.0) {
  do_level <- do_level - runif(1, 0.1, 0.5)
  days <- days + 1
}

print(paste("Days to critical hypoxia:", days))

# Run simulation 5 times to see variability
set.seed(NULL)  # Reset random seed
for (run in 1:5) {
  do_level <- 8.0
  days <- 0
  while (do_level >= 2.0) {
    do_level <- do_level - runif(1, 0.1, 0.5)
    days <- days + 1
  }
  print(paste("Run", run, ":", days, "days"))
}

# Part 4: Two ways to iterate — for loop vs lapply
# Both approaches produce the exact same result.

# Approach A: For loop (explicit, step-by-step — the algorithmic way)
results_loop <- list()
for (i in seq_along(stations)) {
  st_data <- water_enhanced[water_enhanced$station == stations[i], ]
  results_loop[[i]] <- data.frame(
    station = stations[i],
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    n = nrow(st_data)
  )
}
final_loop <- do.call(rbind, results_loop)

# Approach B: lapply (functional style — same logic, more compact)
# lapply applies a function to each element of a vector/list and returns a list
results_lapply <- lapply(stations, function(st) {
  st_data <- water_enhanced[water_enhanced$station == st, ]
  data.frame(
    station = st,
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    n = nrow(st_data)
  )
})
final_lapply <- do.call(rbind, results_lapply)

# Verify both give the same result
print("For loop result:")
print(final_loop)
print("lapply result:")
print(final_lapply)
