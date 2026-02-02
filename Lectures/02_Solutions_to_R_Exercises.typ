// =============================================================================
// Lecture 2: Algorithms vs. Syntax — R Programming Exercises
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
  #text(size: 18pt, weight: "bold", fill: primary-color)[Solutions: R Programming Exercises]
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

# 3. Statistics
do_mean <- mean(do_readings)
do_sd <- sd(do_readings)
do_cv <- (do_sd / do_mean) * 100

# 4. Logical operations
is_hypoxic <- do_readings < 5.0
hypoxic_count <- sum(is_hypoxic)

# 5. Position finding
lowest_pos <- which.min(do_readings)

# 6. Temperature comparison
jul_diff <- monthly_temps["Jul"] - mean(monthly_temps)
```)

#pagebreak()

// =============================================================================
// EXERCISE 2
// =============================================================================

#solution-header("Exercise 2: Importing Data")

#section-title("(a) Algorithm in Plain English")
1. Load the `readr` package (part of tidyverse).
2. Define a list of strings that represent missing values (e.g., "NA", "-999", "-9999").
3. Read the CSV file, explicitly passing the missing value list and defining column types (Station as factor, Date as date, others as double).
4. Inspect the resulting dataframe for parsing errors.
5. Count the number of missing values (NA) in the dissolved oxygen and temperature columns.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
IMPORT library(tidyverse)
DEFINE na_codes = ["", "NA", "N/A", "-999", "-9999"]

data = READ_CSV("water_quality.csv",
    na = na_codes,
    col_types = {station: FACTOR, date: DATE, others: DOUBLE}
)

IF problems(data) EXIST:
    PRINT problems

COUNT NA in data.do_mg_l
COUNT NA in data.temp_c
```)

#section-title("(c) R Code Solution")
#code-box(```r
library(tidyverse)

# Import with explicit handling of NAs and types
water_data <- read_csv(
  "water_quality.csv",
  na = c("", "NA", "N/A", "-999", "-9999"),
  col_types = cols(
    station = col_factor(),
    date = col_date(),
    temp_c = col_double(),
    do_mg_l = col_double(),
    ph = col_double(),
    turbidity_ntu = col_double()
  )
)

# Check for parsing problems
problems(water_data)

# Count NAs
sum(is.na(water_data$do_mg_l))
sum(is.na(water_data$temp_c))
```)

#pagebreak()

// =============================================================================
// EXERCISE 3
// =============================================================================

#solution-header("Exercise 3: Data Inspection and Validation")

#section-title("(a) Algorithm in Plain English")
1. Inspect the dataframe structure (dimensions, column names, types) using summary functions.
2. Calculate the count and percentage of missing values for every column.
3. Define logical conditions for physically impossible values (e.g., Temp < 0 or > 35).
4. Filter the dataframe to extract only rows that satisfy these "impossible" conditions.
5. Print the invalid rows for inspection.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
DISPLAY structure(data)

FOR each column in data:
    CALCULATE count of NAs
    CALCULATE percent of NAs

DEFINE invalid_rows = FILTER data WHERE:
    (temp < 0 OR temp > 35) OR
    (do < 0 OR do > 15) OR
    (ph < 6 OR ph > 9)

DISPLAY invalid_rows
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Structure
glimpse(water_data)

# Missing data summary
water_data |>
  summarize(across(everything(), ~sum(is.na(.)))) |>
  pivot_longer(everything(), names_to = "variable", values_to = "na_count")

# Validation check
invalid_data <- water_data |>
  filter(
    (temp_c < 0 | temp_c > 35) |
    (do_mg_l < 0 | do_mg_l > 15) |
    (ph < 6 | ph > 9)
  )

print(invalid_data)
```)

#pagebreak()

// =============================================================================
// EXERCISE 4
// =============================================================================

#solution-header("Exercise 4: Filtering and Selecting")

#section-title("(a) Algorithm in Plain English")
1. *Fisheries Request:*
   - Filter rows where Date is "2025-07-23".
   - Keep rows where DO < 6.0 OR Turbidity > 15.
   - Select only station, date, DO, and turbidity columns.
   - Sort rows by DO in ascending order.
2. *Researcher Request:*
   - Filter rows where Station is "CB-5.1" OR "CB-5.2".
   - Keep rows where Temp is between 24 and 26 (inclusive).
   - Keep rows where DO is NOT missing.
   - Rename `do_mg_l` to `dissolved_oxygen` during selection.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// Fisheries
fisheries = data
  FILTER date == "2025-07-23"
  FILTER (do < 6.0) OR (turbidity > 15)
  SELECT station, date, do, turbidity
  SORT by do (ascending)

// Researcher
researcher = data
  FILTER station IN ["CB-5.1", "CB-5.2"]
  FILTER temp >= 24 AND temp <= 26
  FILTER do IS NOT NA
  RENAME do_mg_l -> dissolved_oxygen
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Fisheries Biologist
fisheries_req <- water_data |>
  filter(
    date == as.Date("2025-07-23"),
    (do_mg_l < 6.0 | turbidity_ntu > 15)
  ) |>
  select(station, date, do_mg_l, turbidity_ntu) |>
  arrange(do_mg_l)

# Researcher
researcher_req <- water_data |>
  filter(
    station %in% c("CB-5.1", "CB-5.2"),
    between(temp_c, 24, 26),
    !is.na(do_mg_l)
  ) |>
  select(station, date, temp_c, dissolved_oxygen = do_mg_l)
```)

#pagebreak()

// =============================================================================
// EXERCISE 5
// =============================================================================

#solution-header("Exercise 5: Transforming Data")

#section-title("(a) Algorithm in Plain English")
1. Use a mutation function to create new columns.
2. Calculate Fahrenheit from Celsius using standard formula.
3. Calculate Percent Saturation using the given simplified formula.
4. Calculate Log Turbidity using natural log.
5. Create a categorical status column: if DO is missing return "Unknown", else if < 2 "Hypoxic", else if < 5 "Stressed", etc. (Order matters).
6. Extract Month and Day of Year from the Date object.
7. Calculate "Days Since Start" by subtracting the minimum date from the current row's date.
8. Calculate Temperature Z-score: $("Value" - "Mean") / "SD"$.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
data_new = data WITH NEW COLUMNS:
  temp_f = temp_c * 1.8 + 32
  do_sat = (do / 8.0) * 100
  log_turb = LOG(turbidity)
  status = CASE_WHEN(
     is_na(do) -> "Unknown",
     do < 2 -> "Hypoxic",
     do < 5 -> "Stressed",
     TRUE -> "Healthy"
  )
  days_elapsed = date - MIN(date)
  temp_z = (temp - MEAN(temp)) / SD(temp)
```)

#section-title("(c) R Code Solution")
#code-box(```r
water_enhanced <- water_data |>
  mutate(
    temp_f = temp_c * 9/5 + 32,
    do_percent_sat = (do_mg_l / 8.0) * 100,
    log_turbidity = log(turbidity_ntu),
    do_status = case_when(
      is.na(do_mg_l) ~ "Unknown",
      do_mg_l < 2.0 ~ "Hypoxic",
      do_mg_l < 5.0 ~ "Stressed",
      do_mg_l < 8.0 ~ "Adequate",
      TRUE ~ "Healthy"
    ),
    month = month(date, label = TRUE),
    day_of_year = yday(date),
    days_since_start = as.numeric(date - min(date, na.rm = TRUE)),
    temp_zscore = (temp_c - mean(temp_c, na.rm = TRUE)) / sd(temp_c, na.rm = TRUE)
  )
```)

#pagebreak()

// =============================================================================
// EXERCISE 6
// =============================================================================

#solution-header("Exercise 6: Grouping and Summarizing")

#section-title("(a) Algorithm in Plain English")
1. *Station Summary:*
   - Group the dataset by Station.
   - Calculate summary statistics for each group: mean temp, mean DO (ignoring NAs), max turbidity, and count of observations.
   - Calculate proportion of stressed readings by taking the mean of the logical condition (DO < 6).
2. *Relative Analysis:*
   - Group by Station.
   - Instead of collapsing rows, add new columns to existing rows:
     - Station Mean Temp (mean of temp for that group).
     - Deviation (current temp - station mean).
     - Rank (rank of DO within that station, descending).
   - Ungroup the data to prevent issues with future operations.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// Summary
GROUP data BY station
SUMMARIZE:
  mean_temp = MEAN(temp)
  mean_do = MEAN(do, remove_na=TRUE)
  prop_stressed = MEAN(do < 6)

// Relative Analysis
GROUP data BY station
MUTATE:
  station_mean = MEAN(temp)
  anomaly = temp - station_mean
  rank = RANK(DESC(do))
UNGROUP
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Part 1: Summary Report
station_summary <- water_enhanced |>
  group_by(station) |>
  summarize(
    mean_temp = mean(temp_c, na.rm = TRUE),
    mean_do = mean(do_mg_l, na.rm = TRUE),
    max_turb = max(turbidity_ntu, na.rm = TRUE),
    n = n(),
    prop_stressed = mean(do_mg_l < 6.0, na.rm = TRUE)
  )

# Part 2: Relative Analysis
station_relative <- water_enhanced |>
  group_by(station) |>
  mutate(
    station_mean_temp = mean(temp_c, na.rm = TRUE),
    temp_vs_station = temp_c - station_mean_temp,
    station_do_rank = min_rank(desc(do_mg_l))
  ) |>
  ungroup()
```)

#pagebreak()

// =============================================================================
// EXERCISE 7
// =============================================================================

#solution-header("Exercise 7: Tidying Data")

#section-title("(a) Algorithm in Plain English")
1. *Wide to Long:* Take columns 'jan' through 'oct', move their names to a "month" column and their values to a "temperature" column.
2. *Long to Wide:* Take the "month" column for names and "temperature" column for values, and spread them back out.
3. *Complex Tidy:*
   - Convert all columns except 'station' to long format (name, value).
   - Split the 'name' column (e.g., "do_jun") into two columns ("variable", "month") using the underscore separator.
   - Pivot wider, using the "variable" column for new column names and "value" for values, resulting in columns for 'do' and 'temp'.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// Part 1
long_data = PIVOT_LONGER(wide_data, cols=[jan:oct],
    names="month", values="temperature")

// Part 3
tidy_data = dirty_data
  PIVOT_LONGER(cols=-station, names="key", values="val")
  SEPARATE(key, into=["var", "month"], sep="_")
  PIVOT_WIDER(names_from="var", values_from="val")
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Part 1: Wide to Long
temps_long <- temps_wide |>
  pivot_longer(
    cols = c(jan, apr, jul, oct),
    names_to = "month",
    values_to = "temperature"
  )

# Part 3: Complex Tidy
water_tidy <- water_wide |>
  pivot_longer(cols = -station, names_to = "name", values_to = "value") |>
  separate(name, into = c("variable", "month"), sep = "_") |>
  pivot_wider(names_from = variable, values_from = value)
```)

#pagebreak()

// =============================================================================
// EXERCISE 8
// =============================================================================

#solution-header("Exercise 8: Data Visualization")

#section-title("(a) Algorithm in Plain English")
1. *Scatter:* Map Temp (x) and DO (y). Color points by Station. Add a smoothed trend line.
2. *Boxplot:* Map Station (x) and Turbidity (y). Use `geom_boxplot` to show distribution.
3. *Time Series:* Map Date (x) and DO (y). Group/Color by Station. Add line and point geometries. Add horizontal reference line at y=5.
4. *Facets:* Create scatter plot of Temp vs DO. Use `facet_wrap` to create a separate panel for each Station.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
PLOT(data, x=temp, y=do) +
  POINTS(color=station) +
  SMOOTH_LINE()

PLOT(data, x=date, y=do, color=station) +
  LINE() +
  HLINE(y=5)

PLOT(data, x=temp, y=do) +
  POINTS() +
  FACET(by=station)
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Plot 1: Scatter
ggplot(water_enhanced, aes(x = temp_c, y = do_mg_l)) +
  geom_point(aes(color = station)) +
  geom_smooth(method = "loess") +
  labs(title = "DO vs Temp")

# Plot 3: Time Series
ggplot(water_enhanced, aes(x = date, y = do_mg_l, color = station)) +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = 5.0, linetype = "dashed")

# Plot 4: Facets
ggplot(water_enhanced, aes(x = temp_c, y = do_mg_l)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~station) +
  theme_minimal()
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
   - Filter data for that station.
   - If rows == 0, return warning.
   - Return list containing calculated mean temp, mean DO, count, etc.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
FUNCTION classify(do, temp, limits):
  IF is_na(do) RETURN "Unknown"
  IF do < limits.hypoxic RETURN "Critical"
  IF do < limits.stress RETURN "Stressed"
  IF temp > 28 RETURN "Heat Stress"
  RETURN "Good"

FUNCTION summarize_station(data, id):
  subset = FILTER data WHERE station == id
  RETURN LIST(
    mean_t = MEAN(subset.temp),
    mean_do = MEAN(subset.do)
  )
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Classifier
classify_water_quality <- function(do, temp,
                                   hypoxic_threshold = 2.0,
                                   stress_threshold = 5.0) {
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

# Station Summarizer
summarize_station <- function(data, station_id) {
  st_data <- data |> filter(station == station_id)

  if (nrow(st_data) == 0) return(NULL)

  list(
    station = station_id,
    mean_temp = mean(st_data$temp_c, na.rm = TRUE),
    mean_do = mean(st_data$do_mg_l, na.rm = TRUE),
    n = nrow(st_data)
  )
}
```)

#pagebreak()

// =============================================================================
// EXERCISE 10
// =============================================================================

#solution-header("Exercise 10: Loops and Iteration")

#section-title("(a) Algorithm in Plain English")
1. *For Loop:* Iterate through each unique station name. Inside loop, filter data for that station and print its mean temperature.
2. *Accumulation:* Create empty list. Loop through stations. In each iteration, create a 1-row dataframe of stats. Store in list. After loop, bind all list elements into one dataframe.
3. *While Loop:* Set DO = 8.0. While DO >= 2.0, subtract random number (0.1-0.5) from DO and increment day counter.
4. *Purrr:* Use `map_dfr` to iterate over stations. Pass a function that filters and summarizes. It automatically binds results.

#section-title("(b) Algorithm in Pseudocode")
#code-box(```text
// Accumulation
results = LIST()
FOR st IN stations:
   df = CALCULATE stats for st
   results.APPEND(df)
final_table = BIND_ROWS(results)

// While Loop
do_level = 8.0
days = 0
WHILE do_level >= 2.0:
   do_level = do_level - RANDOM(0.1, 0.5)
   days = days + 1
```)

#section-title("(c) R Code Solution")
#code-box(```r
# Accumulating Results
station_summaries <- list()
for (i in seq_along(stations)) {
  st_data <- filter(water_enhanced, station == stations[i])

  station_summaries[[i]] <- tibble(
    station = stations[i],
    mean_temp = mean(st_data$temp_c, na.rm = TRUE),
    count = nrow(st_data)
  )
}
final_results <- bind_rows(station_summaries)

# While Loop
do_level <- 8.0
days <- 0
while (do_level >= 2.0) {
  do_level <- do_level - runif(1, 0.1, 0.5)
  days <- days + 1
}

# Purrr
map_dfr(unique(water_enhanced$station), function(st) {
  water_enhanced |>
    filter(station == st) |>
    summarize(station = st, mean_do = mean(do_mg_l, na.rm = TRUE))
})
```)
