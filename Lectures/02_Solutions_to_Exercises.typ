// =============================================================================
// Lecture 2: Algorithms and Syntax — Programming Exercises
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
  #text(size: 18pt, weight: "bold", fill: primary-color)[Solutions: Algorithms and Syntax Exercises]
  #v(0.5em)
  #text(size: 12pt)[ENST431: Environmental Data Science]
]

// =============================================================================
// EXERCISE 1
// =============================================================================

#solution-header("Exercise 1: Variables and Vectors")

#section-title("(a) Algorithm in Plain English")
1. Define variables for the station metadata (ID, coordinates, depth, active status).
2. Create a numeric vector containing the 10 dissolved oxygen (DO) readings.
3. Create a named numeric vector for the monthly temperatures.
4. Calculate the mean and standard deviation of the DO readings.
5. Calculate the Coefficient of Variation (CV) using the formula: $("SD" / "Mean") times 100$.
6. Create a logical vector that checks if each DO reading is less than 5.0 mg/L.
7. Use this logical vector to subset the original readings and count the number of hypoxic values.
8. Find the index (position) of the minimum value in the DO vector.
9. Calculate the annual mean temperature and subtract it from the July temperature.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
SET station_id = "CB-5.1"
SET do_readings = [8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5]
CALCULATE mean_do = MEAN(do_readings)
CALCULATE sd_do = SD(do_readings)
CALCULATE cv_do = (sd_do / mean_do) * 100

SET is_hypoxic = do_readings < 5.0
COUNT TRUE values in is_hypoxic

FIND index of MIN(do_readings)
CALCULATE temp_diff = temp_july - MEAN(all_temps)
```)

#section-title("(c) R Code Solution")
#code-box(```r
# 1. Variables
station_id <- "CB-5.1"
latitude <- 38.9784
longitude <- -76.3811
sampling_depth <- 2L
is_active <- TRUE

# 2. Vectors
do_readings <- c(8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5)
monthly_temps <- c(
  Jan = 4.2, Feb = 4.5, Mar = 8.1, Apr = 12.5, May = 17.3, Jun = 22.1,
  Jul = 26.8, Aug = 26.5, Sep = 22.4, Oct = 16.3, Nov = 10.7, Dec = 6.1
)

# 3. Statistics — first without built-in functions
# Mean: sum of all values divided by the number of values
#   mean = (x_1 + x_2 + ... + x_n) / n
do_mean_manual <- sum(do_readings) / length(do_readings)

# Standard deviation: square root of the average squared deviation from the mean
#   sd = sqrt( sum((x_i - mean)^2) / (n - 1) )
do_sd_manual <- sqrt(sum((do_readings - do_mean_manual)^2) / (length(do_readings) - 1))

# Now using built-in functions (same result)
do_mean <- mean(do_readings)
do_sd <- sd(do_readings)
do_cv <- (do_sd / do_mean) * 100

# 4. Logical operations
is_hypoxic <- do_readings < 5.0
hypoxic_count <- sum(is_hypoxic)

# 5. Position finding
lowest_do_pos <- which.min(do_readings)

# 6. Temperature comparison
jul_diff <- monthly_temps["Jul"] - mean(monthly_temps)
```)

#section-title("(d) Python Code Solution")
#code-box(```python
import numpy as np

# 1. Variables
station_id = "CB-5.1"
latitude = 38.9784
longitude = -76.3811
sampling_depth = 2
is_active = True

# 2. Arrays/lists for readings
do_readings = np.array([8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5])

# Monthly temperatures with names (dictionary)
monthly_temps = {
    "Jan": 4.2, "Feb": 4.5, "Mar": 8.1, "Apr": 12.5, "May": 17.3, "Jun": 22.1,
    "Jul": 26.8, "Aug": 26.5, "Sep": 22.4, "Oct": 16.3, "Nov": 10.7, "Dec": 6.1
}

# 3. Statistics — first without built-in functions
# Mean: sum of all values divided by the number of values
do_mean_manual = sum(do_readings) / len(do_readings)

# Standard deviation: square root of the average squared deviation from the mean
do_sd_manual = (sum((do_readings - do_mean_manual) ** 2) / (len(do_readings) - 1)) ** 0.5

# Now using built-in functions (same result)
do_mean = np.mean(do_readings)
do_sd = np.std(do_readings, ddof=1)  # ddof=1 for sample std dev (same as R)
do_cv = (do_sd / do_mean) * 100

# 4. Logical operations
is_hypoxic = do_readings < 5.0
hypoxic_count = np.sum(is_hypoxic)

# 5. Position finding
lowest_do_pos = np.argmin(do_readings)

# 6. Temperature comparison
temps_array = np.array(list(monthly_temps.values()))
annual_mean_temp = np.mean(temps_array)
jul_diff = monthly_temps["Jul"] - annual_mean_temp
```)

#pagebreak()

// =============================================================================
// EXERCISE 2
// =============================================================================

#solution-header("Exercise 2: Importing Data")

#section-title("(a) Algorithm in Plain English")
1. Define a list of strings that represent missing values (e.g., "NA", "-999", "-9999").
2. Read the CSV file using base R's `read.csv()`, passing the missing value list via `na.strings`.
3. Convert column types manually: Station to factor, Date to Date object.
4. Inspect the resulting data frame for structure and any issues.
5. Count the number of missing values (NA) in the dissolved oxygen and temperature columns.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
DEFINE na_codes = ["", "NA", "N/A", "-999", "-9999"]

data = READ.CSV("water_quality.csv", na.strings = na_codes)

# Convert types manually
data$station = AS_FACTOR(data$station)
data$date = AS_DATE(data$date, format = "%Y-%m-%d")

DISPLAY structure(data)
DISPLAY summary(data)

COUNT NA in data$do_mg_l
COUNT NA in data$temp_c
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Import with explicit handling of NAs
water_data <- read.csv(
  "water_quality.csv",
  na.strings = c("", "NA", "N/A", "-999", "-9999"),
  stringsAsFactors = FALSE
)

# Convert column types manually
water_data$station <- as.factor(water_data$station)
water_data$date <- as.Date(water_data$date, format = "%Y-%m-%d")

# Inspect structure
str(water_data)
summary(water_data)

# Count NAs
sum(is.na(water_data$do_mg_l))
sum(is.na(water_data$temp_c))
```)

#section-title("(d) Python Code Solution")
#code-box(```python
import pandas as pd

# Import with explicit handling of NAs
water_data = pd.read_csv(
    "water_quality.csv",
    na_values=["", "NA", "N/A", "-999", "-9999"]
)

# Convert column types
water_data["station"] = water_data["station"].astype("category")
water_data["date"] = pd.to_datetime(water_data["date"])

# Inspect structure
print(water_data.dtypes)
print(water_data.info())

# Count NAs
na_do = water_data["do_mg_l"].isna().sum()
na_temp = water_data["temp_c"].isna().sum()
```)

#pagebreak()

// =============================================================================
// EXERCISE 3
// =============================================================================

#solution-header("Exercise 3: Data Inspection and Validation")

#section-title("(a) Algorithm in Plain English")
1. Inspect the data frame structure (dimensions, column names, types) using summary functions.
2. Calculate the count and percentage of missing values for every column using `sapply()`.
3. Define logical conditions for physically impossible values (e.g., Temp < 0 or > 35).
4. Use logical indexing to extract only rows that satisfy these "impossible" conditions.
5. Print the invalid rows for inspection.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
DISPLAY str(data)
DISPLAY summary(data)

FOR each column in data:
    CALCULATE count of NAs using sapply
    CALCULATE percent of NAs

DEFINE condition = (temp < 0 OR temp > 35) OR
                   (do < 0 OR do > 15) OR
                   (ph < 6 OR ph > 9)

invalid_rows = data[condition, ]
DISPLAY invalid_rows
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Structure
str(water_data)
summary(water_data)

# Missing data summary
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

# APPROACH B: Using sapply (compact, same result)
# sapply applies a function to each column and returns a vector
na_counts_v2 <- sapply(water_data, function(x) sum(is.na(x)))
na_percent_v2 <- sapply(water_data, function(x) mean(is.na(x)) * 100)

# Validation check using logical indexing
invalid_condition <- (water_data$temp_c < 0 | water_data$temp_c > 35) |
                     (water_data$do_mg_l < 0 | water_data$do_mg_l > 15) |
                     (water_data$ph < 6 | water_data$ph > 9)

# Handle NAs in conditions (replace NA with FALSE)
invalid_condition[is.na(invalid_condition)] <- FALSE

invalid_rows <- water_data[invalid_condition, ]
print(invalid_rows)
```)

#section-title("(d) Python Code Solution")
#code-box(```python
# 1. Inspect structure
print(water_data.describe())
print(f"Shape: {water_data.shape}")
print(f"Columns: {list(water_data.columns)}")

# 2. Missing data summary
na_counts = water_data.isna().sum()
na_percent = water_data.isna().mean() * 100
missing_summary = pd.DataFrame({
    "na_count": na_counts,
    "na_percent": na_percent.round(2)
})
print(missing_summary)

# 3 & 4. Validation checks (Plausible ranges)
# Temp: 0-35, DO: 0-15, pH: 6-9
invalid_condition = (
    (water_data["temp_c"] < 0) | (water_data["temp_c"] > 35) |
    (water_data["do_mg_l"] < 0) | (water_data["do_mg_l"] > 15) |
    (water_data["ph"] < 6) | (water_data["ph"] > 9)
)

# Replace NaN in condition with False
invalid_condition = invalid_condition.fillna(False)

invalid_data = water_data[invalid_condition]
print(invalid_data)
```)

#pagebreak()

// =============================================================================
// EXERCISE 4
// =============================================================================

#solution-header("Exercise 4: Filtering and Selecting")

#section-title("(a) Algorithm in Plain English")
1. *Fisheries Request:*
   - Filter rows where Date is "2025-07-23" using logical indexing.
   - Keep rows where DO < 6.0 OR Turbidity > 15.
   - Select only station, date, DO, and turbidity columns by name.
   - Sort rows by DO in ascending order using `order()`.
2. *Researcher Request:*
   - Filter rows where Station is "CB-5.1" OR "CB-5.2" using `%in%`.
   - Keep rows where Temp is between 24 and 26 (inclusive).
   - Keep rows where DO is NOT missing.
   - Rename `do_mg_l` to `dissolved_oxygen` using `names()`.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// Fisheries
fisheries = data[date == "2025-07-23", ]
fisheries = fisheries[(do < 6.0) OR (turbidity > 15), ]
fisheries = fisheries[, c("station", "date", "do", "turbidity")]
fisheries = fisheries[order(fisheries$do), ]

// Researcher
researcher = data[station %in% c("CB-5.1", "CB-5.2"), ]
researcher = researcher[temp >= 24 AND temp <= 26, ]
researcher = researcher[NOT is.na(do), ]
RENAME do_mg_l -> dissolved_oxygen
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Fisheries Biologist
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

# Researcher
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
```)

#section-title("(d) Python Code Solution")
#code-box(```python
# Request 1: Fisheries Biologist
# July 23rd, DO < 6.0 OR Turbidity > 15

# Step 1: Filter by date
fisheries_req = water_data[water_data["date"] == "2025-07-23"]

# Step 2: Filter by DO or turbidity condition
condition = (fisheries_req["do_mg_l"] < 6.0) | (fisheries_req["turbidity_ntu"] > 15)
condition = condition.fillna(False)
fisheries_req = fisheries_req[condition]

# Step 3: Select columns
fisheries_req = fisheries_req[["station", "date", "do_mg_l", "turbidity_ntu"]]

# Step 4: Sort by DO ascending
fisheries_req = fisheries_req.sort_values("do_mg_l")

# Request 2: Researcher
# Stations CB-5.1 OR CB-5.2, Temp 24-26, DO not missing

# Step 1: Filter by station
researcher_req = water_data[water_data["station"].isin(["CB-5.1", "CB-5.2"])]

# Step 2: Filter by temperature range
researcher_req = researcher_req[
    (researcher_req["temp_c"] >= 24) & (researcher_req["temp_c"] <= 26)
]

# Step 3: Remove rows with missing DO
researcher_req = researcher_req[researcher_req["do_mg_l"].notna()]

# Step 4: Select and rename columns
researcher_req = researcher_req[["station", "date", "temp_c", "do_mg_l"]]
researcher_req = researcher_req.rename(columns={"do_mg_l": "dissolved_oxygen"})
```)

#pagebreak()

// =============================================================================
// EXERCISE 5
// =============================================================================

#solution-header("Exercise 5: Transforming Data")

#section-title("(a) Algorithm in Plain English")
1. Add new columns using direct assignment (`data$new_col <- ...`).
2. Calculate Fahrenheit from Celsius using standard formula.
3. Calculate Percent Saturation using the given simplified formula.
4. Calculate Log Turbidity using natural log.
5. Create a categorical status column using nested `ifelse()`: if DO is missing return "Unknown", else if < 2 "Hypoxic", else if < 5 "Stressed", etc. (Order matters).
6. Extract Month and Day of Year from the Date object using `format()`.
7. Calculate "Days Since Start" by subtracting the minimum date from the current row's date.
8. Calculate Temperature Z-score: $("Value" - "Mean") / "SD"$.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
data$temp_f = temp_c * 1.8 + 32
data$do_sat = (do / 8.0) * 100
data$log_turb = LOG(turbidity)
data$status = IFELSE(is_na(do), "Unknown",
               IFELSE(do < 2, "Hypoxic",
                IFELSE(do < 5, "Stressed",
                 IFELSE(do < 8, "Adequate", "Healthy"))))
data$month = FORMAT(date, "%m")
data$day_of_year = FORMAT(date, "%j")
data$days_elapsed = date - MIN(date)
data$temp_z = (temp - MEAN(temp)) / SD(temp)
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Make a copy to avoid modifying original
water_enhanced <- water_data

# Temperature conversion
water_enhanced$temp_f <- water_enhanced$temp_c * 9/5 + 32

# DO percent saturation
water_enhanced$do_percent_sat <- (water_enhanced$do_mg_l / 8.0) * 100

# Log turbidity
water_enhanced$log_turbidity <- log(water_enhanced$turbidity_ntu)

# DO status classification using nested ifelse
water_enhanced$do_status <- ifelse(is.na(water_enhanced$do_mg_l), "Unknown",
  ifelse(water_enhanced$do_mg_l < 2.0, "Hypoxic",
    ifelse(water_enhanced$do_mg_l < 5.0, "Stressed",
      ifelse(water_enhanced$do_mg_l < 8.0, "Adequate", "Healthy"))))

# Extract month and day of year using format()
water_enhanced$month <- format(water_enhanced$date, "%B")  # Full month name
water_enhanced$day_of_year <- as.integer(format(water_enhanced$date, "%j"))

# Days since start of monitoring (broken into steps)
# Step 1: Find the earliest date in the dataset
start_date <- min(water_enhanced$date, na.rm = TRUE)

# Step 2: Calculate the difference between each date and the start date
date_difference <- difftime(water_enhanced$date, start_date, units = "days")

# Step 3: Convert to numeric (removes the "days" label)
water_enhanced$days_since_start <- as.numeric(date_difference)

# Temperature z-score
temp_mean <- mean(water_enhanced$temp_c, na.rm = TRUE)
temp_sd <- sd(water_enhanced$temp_c, na.rm = TRUE)
water_enhanced$temp_zscore <- (water_enhanced$temp_c - temp_mean) / temp_sd
```)

#section-title("(d) Python Code Solution")
#code-box(```python
import numpy as np

# Make a copy to avoid modifying original
water_enhanced = water_data.copy()

# 1. Temperature in Fahrenheit
water_enhanced["temp_f"] = water_enhanced["temp_c"] * 9/5 + 32

# 2. DO Percent Saturation (simplified)
water_enhanced["do_percent_sat"] = (water_enhanced["do_mg_l"] / 8.0) * 100

# 3. Log Turbidity
water_enhanced["log_turbidity"] = np.log(water_enhanced["turbidity_ntu"])

# 4. Water Quality Status using np.select
conditions = [
    water_enhanced["do_mg_l"].isna(),
    water_enhanced["do_mg_l"] < 2.0,
    water_enhanced["do_mg_l"] < 5.0,
    water_enhanced["do_mg_l"] < 8.0,
]
choices = ["Unknown", "Hypoxic", "Stressed", "Adequate"]
water_enhanced["do_status"] = np.select(conditions, choices, default="Healthy")

# 5. Time variables
water_enhanced["month"] = water_enhanced["date"].dt.month_name()
water_enhanced["day_of_year"] = water_enhanced["date"].dt.day_of_year

# 6. Days since start of monitoring
# Step 1: Find the earliest date in the dataset
start_date = water_enhanced["date"].min()

# Step 2: Calculate the difference between each date and the start date
date_difference = water_enhanced["date"] - start_date

# Step 3: Extract just the number of days from the difference
water_enhanced["days_since_start"] = date_difference.dt.days

# 7. Temperature Z-score
temp_mean = water_enhanced["temp_c"].mean()
temp_sd = water_enhanced["temp_c"].std()
water_enhanced["temp_zscore"] = (water_enhanced["temp_c"] - temp_mean) / temp_sd
```)

#pagebreak()

// =============================================================================
// EXERCISE 6
// =============================================================================

#solution-header("Exercise 6: Grouping and Summarizing")

#section-title("(a) Algorithm in Plain English")
1. *Station Summary:*
   - Split the dataset by Station using `split()` or use `aggregate()`.
   - Calculate summary statistics for each group: mean temp, mean DO (ignoring NAs), max turbidity, and count of observations.
   - Calculate proportion of stressed readings by taking the mean of the logical condition (DO < 6).
2. *Relative Analysis:*
   - Use `ave()` to calculate group-level statistics without collapsing rows:
     - Station Mean Temp (mean of temp for that group).
     - Deviation (current temp - station mean).
     - Rank (rank of DO within that station, descending).

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// Summary using aggregate
station_summary = AGGREGATE(
  cbind(temp, do, turbidity) BY station,
  FUN = function to calculate mean/max/count
)

// Relative Analysis using ave
data$station_mean = AVE(temp, station, FUN = MEAN)
data$anomaly = temp - station_mean
data$rank = AVE(do, station, FUN = function(x) RANK(-x))
```)

#section-title("(c) R Code Solution")
#code-box(```r
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

# Part 1: Summary Report using aggregate
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

# Part 2: Relative Analysis using ave()
# ave() applies a function to groups but returns a vector the same length as input
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
```)

#section-title("(d) Python Code Solution")
#code-box(```python
# Part 1: Station summary report

# Step 1: Group the data by station
grouped = water_enhanced.groupby("station", observed=True)

# Step 2: Calculate summary statistics for each group
station_summary = grouped.agg(
    mean_temp=("temp_c", "mean"),
    mean_do=("do_mg_l", "mean"),
    max_turbidity=("turbidity_ntu", "max"),
    n_obs=("temp_c", "count"),
)

# Step 3: Convert the index (station) back to a regular column
station_summary = station_summary.reset_index()

# Proportion of stressed readings (DO < 6)

# Step 1: Create a boolean column marking stressed readings
water_enhanced["is_stressed"] = water_enhanced["do_mg_l"] < 6

# Step 2: Group the data by station
grouped = water_enhanced.groupby("station", observed=True)

# Step 3: Select the is_stressed column from each group
stressed_by_station = grouped["is_stressed"]

# Step 4: Calculate the mean of each group
#         The mean of a boolean column = proportion of True values
#         (since True=1 and False=0, mean gives us count_true / total)
prop_stressed = stressed_by_station.mean()

# Step 5: Convert the result from a Series to a DataFrame
prop_stressed = prop_stressed.reset_index()

# Step 6: Rename the column to something descriptive
prop_stressed.columns = ["station", "prop_stressed"]

# Step 7: Merge the proportion back into station_summary
station_summary = station_summary.merge(prop_stressed, on="station")

# Part 2: Station-relative analysis using transform
# transform() applies a function to each group and returns a Series
# with the same index as the original DataFrame

# Step 1: Group by station
grouped_by_station = water_enhanced.groupby("station", observed=True)

# Step 2: Get the temperature column from each group
temp_by_station = grouped_by_station["temp_c"]

# Step 3: Calculate the mean for each group (result has same length as original)
water_enhanced["station_mean_temp"] = temp_by_station.transform("mean")

# Step 4: Calculate how each reading differs from its station's mean
water_enhanced["temp_vs_station"] = water_enhanced["temp_c"] - water_enhanced["station_mean_temp"]

# Step 5: Rank DO values within each station (highest = rank 1)
do_by_station = grouped_by_station["do_mg_l"]
water_enhanced["station_do_rank"] = do_by_station.rank(ascending=False)
```)

#pagebreak()

// =============================================================================
// EXERCISE 7
// =============================================================================

#solution-header("Exercise 7: Tidying Data")

#section-title("(a) Algorithm in Plain English")
1. *Wide to Long:* Use `reshape()` or `stack()` to take columns 'jan' through 'oct', move their names to a "month" column and their values to a "temperature" column.
2. *Long to Wide:* Use `reshape()` with direction="wide" to spread values back into columns.
3. *Complex Tidy:*
   - Convert all columns except 'station' to long format using `stack()`.
   - Split the column names (e.g., "do_jun") into two parts ("variable", "month") using `strsplit()`.
   - Reshape wider using `reshape()` so 'do' and 'temp' become separate columns.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// Part 1: Using stack()
stacked = STACK(wide_data[, c("jan", "apr", "jul", "oct")])
long_data = DATA.FRAME(
  station = REPEAT(wide_data$station, 4),
  month = stacked$ind,
  temperature = stacked$values
)

// Part 3
stacked = STACK(dirty_data[, columns != "station"])
parts = STRSPLIT(stacked$ind, "_")
variable = EXTRACT first element of each split
month = EXTRACT second element of each split
RESHAPE to wide format
```)

#section-title("(c) R Code Solution")
#code-box(```r
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

# Alternative using reshape()
temps_long_v2 <- reshape(temps_wide,
  direction = "long",
  varying = list(c("jan", "apr", "jul", "oct")),
  v.names = "temperature",
  timevar = "month",
  times = c("jan", "apr", "jul", "oct"),
  idvar = "station"
)

# Part 2: Long to Wide (stations as columns)
temps_wide_again <- reshape(temps_long,
  direction = "wide",
  idvar = "month",
  timevar = "station",
  v.names = "temperature"
)

# Part 3: Complex Tidy
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
```)

#section-title("(d) Python Code Solution")
#code-box(```python
# Part 1: Wide to Long using melt
temps_wide = pd.DataFrame({
    "station": ["CB-5.1", "CB-5.2"],
    "jan": [4.2, 3.8],
    "apr": [12.5, 11.9],
    "jul": [26.8, 27.1],
    "oct": [16.3, 15.8],
})

temps_long = pd.melt(
    temps_wide,
    id_vars="station",
    var_name="month",
    value_name="temperature",
)

# Part 2: Pivot back to wide (stations as columns)

# Step 1: Pivot the data (month becomes index, stations become columns)
temps_wide_again = temps_long.pivot(
    index="month",
    columns="station",
    values="temperature"
)

# Step 2: Convert the index (month) back to a regular column
temps_wide_again = temps_wide_again.reset_index()

# Part 3: Multi-variable Tidying
water_wide = pd.DataFrame({
    "station": ["CB-5.1"],
    "do_jun": [6.8],
    "do_jul": [5.2],
    "temp_jun": [24.5],
    "temp_jul": [26.8],
})

# Step 1: Melt to long format
long_df = pd.melt(water_wide, id_vars="station", var_name="name", value_name="value")

# Step 2: Split the name column into variable and month
long_df[["variable", "month"]] = long_df["name"].str.split("_", expand=True)

# Step 3: Pivot so variable becomes separate columns
water_tidy = long_df.pivot_table(
    index=["station", "month"],
    columns="variable",
    values="value",
)

# Step 4: Convert the index back to regular columns
water_tidy = water_tidy.reset_index()

# Step 5: Remove the "variable" label from the column names
water_tidy.columns.name = None
```)

#pagebreak()

// =============================================================================
// EXERCISE 8
// =============================================================================

#solution-header("Exercise 8: Combining Monitoring Databases")

#section-title("(a) Algorithm in Plain English")
1. *Create metadata:* Build a data frame containing station metadata (region, type, coordinates).
2. *Inner join:* Use `merge()` with default settings to join metadata with water quality data—only matching stations are kept.
3. *Left join:* Use `merge()` with `all.x = TRUE` to keep all water quality rows, filling in NA where metadata is missing.
4. *Compare:* Check which stations are in one dataset but not the other using `setdiff()`.
5. *Nutrient merge:* Create the nutrient data frame and merge by both station AND date.
6. *Stack:* Use `rbind()` to combine two data frames with identical columns.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// Part 1: Merge metadata
metadata = CREATE data frame with station info
merged_inner = MERGE(water_data, metadata, by = "station")  // inner
merged_left = MERGE(water_data, metadata, by = "station", all.x = TRUE)  // left

// Compare row counts
PRINT nrow(merged_inner) vs nrow(merged_left)

// Find mismatches
missing_from_wq = SETDIFF(metadata$station, water_data$station)
missing_from_meta = SETDIFF(water_data$station, metadata$station)

// Part 2: Nutrient merge
nutrients = CREATE data frame with nutrient readings
combined = MERGE(water_data, nutrients, by = c("station", "date"), all.x = TRUE)

// Part 3: Stack
batch2 = CREATE second batch of water quality data
stacked = RBIND(water_data, batch2)
VERIFY nrow(stacked) == nrow(water_data) + nrow(batch2)
```)

#section-title("(c) R Code Solution")
#code-box(```r
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
# Create a small second batch with same columns as water_data
batch2 <- water_data[1:5, ]  # simulate a second batch
stacked <- rbind(water_data, batch2)
cat("Original rows:", nrow(water_data), "\n")
cat("Batch 2 rows:", nrow(batch2), "\n")
cat("Stacked rows:", nrow(stacked), "\n")
cat("Verified:", nrow(stacked) == nrow(water_data) + nrow(batch2), "\n")
```)

#section-title("(d) Python Code Solution")
#code-box(```python
# Part 1: Create station metadata
station_meta = pd.DataFrame({
    "station": ["CB-5.1", "CB-5.2", "CB-5.3", "CB-6.1"],
    "region": ["Main Stem", "Main Stem", "Main Stem", "Lower Bay"],
    "type": ["Fixed", "Fixed", "Fixed", "Rotating"],
    "lat": [38.978, 38.856, 38.742, 37.587],
    "lon": [-76.381, -76.372, -76.321, -76.138],
})

# Inner join: only stations present in BOTH datasets
merged_inner = pd.merge(water_data, station_meta, on="station")
print(f"Inner join rows: {len(merged_inner)}")

# Left join: keep all water quality rows
merged_left = pd.merge(water_data, station_meta, on="station", how="left")
print(f"Left join rows: {len(merged_left)}")

# Which stations are in metadata but not in water quality data?
wq_stations = set(water_data["station"].unique())
meta_stations = set(station_meta["station"])
missing_from_wq = meta_stations - wq_stations
missing_from_meta = wq_stations - meta_stations

# Part 2: Nutrient data merge
nutrient_data = pd.DataFrame({
    "station": ["CB-5.1", "CB-5.2", "CB-6.1"],
    "date": pd.to_datetime(["2025-06-15", "2025-06-15", "2025-06-15"]),
    "nitrogen_mg_l": [1.2, 1.5, 0.9],
    "phosphorus_mg_l": [0.08, 0.12, 0.06],
})

# Merge by both station and date
combined = pd.merge(water_data, nutrient_data, on=["station", "date"], how="left")

# Count how many rows have nutrient data (not missing)
has_nutrient_data = combined["nitrogen_mg_l"].notna()
rows_with_nutrients = has_nutrient_data.sum()

# Part 3: Stacking datasets
batch2 = water_data.head(5).copy()
stacked = pd.concat([water_data, batch2], ignore_index=True)
print(f"Verified: {len(stacked) == len(water_data) + len(batch2)}")
```)

#pagebreak()

// =============================================================================
// EXERCISE 9
// =============================================================================

#solution-header("Exercise 9: Writing Functions")

#section-title("(a) Algorithm in Plain English")
1. *Conversion:* Function takes `temp_c`, multiplies by 1.8 and adds 32. Return result.
2. *Classifier:* Function takes `do`, `temp`, and thresholds.
   - If DO or Temp is NA, return "Unknown".
   - If DO < hypoxic_threshold, return "Critical".
   - Else if DO < stress_threshold, return "Stressed".
   - Else if Temp > 28, return "Heat Stress".
   - Else return "Good".
3. *Summarizer:* Function takes `data` and `station_id`.
   - Filter data for that station using logical indexing.
   - If rows == 0, return warning.
   - Return list containing calculated mean temp, mean DO, count, etc.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
FUNCTION classify(do, temp, limits):
  IF is_na(do) OR is_na(temp) RETURN "Unknown"
  IF do < limits.hypoxic RETURN "Critical"
  IF do < limits.stress RETURN "Stressed"
  IF temp > 28 RETURN "Heat Stress"
  RETURN "Good"

FUNCTION summarize_station(data, id):
  subset = data[data$station == id, ]
  IF nrow(subset) == 0 RETURN NULL
  RETURN LIST(
    mean_t = MEAN(subset$temp),
    mean_do = MEAN(subset$do)
  )
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Temperature conversion functions
celsius_to_fahrenheit <- function(temp_c) {
  temp_f <- temp_c * 9/5 + 32
  return(temp_f)
}

fahrenheit_to_celsius <- function(temp_f) {
  temp_c <- (temp_f - 32) * 5/9
  return(temp_c)
}

# Test: round-trip conversion
fahrenheit_to_celsius(celsius_to_fahrenheit(25))  # Should return 25

# Saturation deficit calculator
calc_saturation_deficit <- function(do_measured, temperature) {
  do_saturated <- 14.62 - (0.3898 * temperature)
  deficit <- do_saturated - do_measured
  return(deficit)
}

# Test with DO = 6.5, temp = 25
calc_saturation_deficit(6.5, 25)

# Water quality classifier
classify_water_quality <- function(do, temp,
                                   hypoxic_threshold = 2.0,
                                   stress_threshold = 5.0) {
  if (is.na(do) || is.na(temp)) {
    return("Unknown")
  }
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

# Station Summarizer using base R
summarize_station <- function(data, station_id) {
  # Filter using logical indexing
  st_data <- data[data$station == station_id, ]

  if (nrow(st_data) == 0) {
    warning(paste("Station", station_id, "not found in data"))
    return(NULL)
  }

  # Return named list with statistics
  list(
    station = station_id,
    mean_temp = mean(st_data$temp_c, na.rm = TRUE),
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    n_observations = nrow(st_data),
    hypoxic_count = sum(st_data$do_mg_l < 2.0, na.rm = TRUE)
  )
}
```)

#section-title("(d) Python Code Solution")
#code-box(```python
import pandas as pd

# 1. Temperature Conversion
def celsius_to_fahrenheit(temp_c):
    return temp_c * 9/5 + 32

def fahrenheit_to_celsius(temp_f):
    return (temp_f - 32) * 5/9

# Test: round-trip conversion
print(f"Round-trip: {fahrenheit_to_celsius(celsius_to_fahrenheit(25))}")

# 2. Saturation Deficit
def calc_saturation_deficit(do_measured, temperature):
    do_saturated = 14.62 - (0.3898 * temperature)
    deficit = do_saturated - do_measured
    return deficit

# 3. Water Quality Classifier
def classify_water_quality(do, temp, hypoxic_threshold=2.0, stress_threshold=5.0):
    if pd.isna(do) or pd.isna(temp):
        return "Unknown"
    if do < hypoxic_threshold:
        return "Critical"
    elif do < stress_threshold:
        return "Stressed"
    elif temp > 28:
        return "Heat Stress"
    else:
        return "Good"

# 4. Station Summarizer
def summarize_station(data, station_id):
    st_data = data[data["station"] == station_id]

    if len(st_data) == 0:
        print(f"Warning: Station {station_id} not found in data")
        return None

    return {
        "station": station_id,
        "mean_temp": st_data["temp_c"].mean(),
        "mean_do": st_data["do_mg_l"].mean(),
        "n_observations": len(st_data),
        "hypoxic_count": (st_data["do_mg_l"] < 2.0).sum(),
    }
```)

#pagebreak()

// =============================================================================
// EXERCISE 10
// =============================================================================

#solution-header("Exercise 10: Loops and Iteration")

#section-title("(a) Algorithm in Plain English")
1. *For Loop:* Iterate through each unique station name. Inside loop, filter data for that station using logical indexing and print its mean temperature.
2. *Accumulation:* Create empty list. Loop through stations. In each iteration, create a 1-row data frame of stats. Store in list. After loop, combine all list elements into one data frame using `do.call(rbind, ...)`.
3. *While Loop:* Set DO = 8.0. While DO >= 2.0, subtract random number (0.1-0.5) from DO and increment day counter.
4. *Apply Family:* Use `lapply()` to iterate over stations. Pass a function that filters and summarizes. Combine results with `do.call(rbind, ...)`.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// For Loop with printing
FOR st IN unique(data$station):
   subset = data[data$station == st, ]
   PRINT("Station", st, ": Mean temp =", MEAN(subset$temp))

// Accumulation
results = LIST()
FOR i IN 1:length(stations):
   subset = data[data$station == stations[i], ]
   results[[i]] = DATA.FRAME(station, mean_temp, count)
final_table = DO.CALL(rbind, results)

// While Loop
do_level = 8.0
days = 0
WHILE do_level >= 2.0:
   do_level = do_level - RUNIF(1, 0.1, 0.5)
   days = days + 1
```)

#section-title("(c) R Code Solution")

#text(weight: "semibold", size: 9pt)[Parts 1 & 2: For loops]
#code-box(```r
# Part 1: For loop with printing
stations <- unique(water_enhanced$station)

for (st in stations) {
  st_data <- water_enhanced[water_enhanced$station == st, ]
  mean_temp <- mean(st_data$temp_c, na.rm = TRUE)
  print(paste("Station", st, ": Mean temperature =",
              round(mean_temp, 2), "C"))
}

# Part 2: Accumulating results in a list
station_summaries <- list()

for (i in seq_along(stations)) {
  st_data <- water_enhanced[water_enhanced$station == stations[i], ]

  station_summaries[[i]] <- data.frame(
    station = stations[i],
    mean_temp = mean(st_data$temp_c, na.rm = TRUE),
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    count = nrow(st_data)
  )
}

# Combine list into single data frame
all_summaries <- do.call(rbind, station_summaries)
print(all_summaries)
```)

#pagebreak()

#text(weight: "semibold", size: 9pt)[Part 3: While loop simulation]
#code-box(```r
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
```)

#text(weight: "semibold", size: 9pt)[Part 4: Two ways to iterate — for loop vs lapply]
#code-box(```r
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
results_lapply <- lapply(stations, function(st) {
  st_data <- water_enhanced[water_enhanced$station == st, ]
  data.frame(
    station = st,
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    n = nrow(st_data)
  )
})
final_lapply <- do.call(rbind, results_lapply)

# Both produce the same result
print(final_loop)
print(final_lapply)
```)

#section-title("(d) Python Code Solution")

#text(weight: "semibold", size: 9pt)[Parts 1 & 2: For loops]
#code-box(```python
import pandas as pd
import random

# Part 1: For loop with printing
stations = water_enhanced["station"].unique()

for st in stations:
    st_data = water_enhanced[water_enhanced["station"] == st]
    mean_temp = st_data["temp_c"].mean()
    print(f"Station {st}: Mean temperature = {mean_temp:.2f} C")

# Part 2: Accumulating results in a list
station_summaries = []

for st in stations:
    st_data = water_enhanced[water_enhanced["station"] == st]

    station_summaries.append({
        "station": st,
        "mean_temp": st_data["temp_c"].mean(),
        "mean_do": st_data["do_mg_l"].mean(),
        "count": len(st_data),
    })

# Convert list of dicts to DataFrame
all_summaries = pd.DataFrame(station_summaries)
print(all_summaries)
```)

#text(weight: "semibold", size: 9pt)[Part 3: While loop simulation]
#code-box(```python
def run_simulation():
    do_level = 8.0
    days = 0
    while do_level >= 2.0:
        do_level -= random.uniform(0.1, 0.5)
        days += 1
    return days

# Run the simulation 5 times using a for loop
sim_results = []
for i in range(5):
    days = run_simulation()
    sim_results.append(days)
    print(f"  Run {i + 1}: {days} days")

print(f"Days to hypoxia in 5 simulations: {sim_results}")
```)

#text(weight: "semibold", size: 9pt)[Part 4: Building a summary table with a for loop]
#code-box(```python
# This is the same pattern as Part 2, showing how to accumulate results

results = []

for st in stations:
    # Filter data for this station
    st_data = water_enhanced[water_enhanced["station"] == st]

    # Calculate statistics
    mean_do = st_data["do_mg_l"].mean()
    n_obs = len(st_data)

    # Create a dictionary with the results
    station_result = {
        "station": st,
        "mean_do": mean_do,
        "n": n_obs,
    }

    # Add to our list
    results.append(station_result)

# Convert list of dictionaries to a DataFrame
final_results = pd.DataFrame(results)

print("Station DO Summary:")
print(final_results)
```)
