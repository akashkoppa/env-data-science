# ==============================================================================
# 02_Solutions_to_Exercises.py
# Solutions to "Algorithms and Syntax" - Programming Exercises (Python)
# Environmental Data Science (ENST431)
# ==============================================================================

import numpy as np
import pandas as pd
import random

# ==============================================================================
# EXERCISE 1: Variables and Vectors
# ==============================================================================
print("\n--- Exercise 1 ---")

# 1. Create variables for station metadata
station_id = "CB-5.1"
latitude = 38.9784
longitude = -76.3811
sampling_depth = 2
is_active = True

# 2. Create arrays/lists for readings
do_readings = np.array([8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5])

# Monthly temperatures with names (dictionary)
monthly_temps = {
    "Jan": 4.2, "Feb": 4.5, "Mar": 8.1, "Apr": 12.5, "May": 17.3, "Jun": 22.1,
    "Jul": 26.8, "Aug": 26.5, "Sep": 22.4, "Oct": 16.3, "Nov": 10.7, "Dec": 6.1
}

# 3. Calculate statistics for dissolved oxygen — first without built-in functions
# Mean: sum of all values divided by the number of values
#   mean = (x_1 + x_2 + ... + x_n) / n
do_mean_manual = sum(do_readings) / len(do_readings)

# Standard deviation: square root of the average squared deviation from the mean
#   sd = sqrt( sum((x_i - mean)^2) / (n - 1) )
do_sd_manual = (sum((do_readings - do_mean_manual) ** 2) / (len(do_readings) - 1)) ** 0.5

print(f"Manual: Mean={do_mean_manual:.2f}, SD={do_sd_manual:.2f}")

# Now using built-in functions (same result)
do_mean = np.mean(do_readings)
do_sd = np.std(do_readings, ddof=1)  # ddof=1 for sample std dev (same as R)
do_cv = (do_sd / do_mean) * 100

print(f"DO Stats: Mean={do_mean:.2f}, SD={do_sd:.2f}, CV={do_cv:.2f}%")

# 4. Logical array for hypoxic conditions (DO < 5.0 mg/L)
is_hypoxic = do_readings < 5.0
print("Hypoxic readings check:")
print(is_hypoxic)

# 5. Extract and count hypoxic values
hypoxic_values = do_readings[is_hypoxic]
count_hypoxic = len(hypoxic_values)  # or np.sum(is_hypoxic)
print(f"Number of hypoxic readings: {count_hypoxic}")

# 6. Find depth position with lowest oxygen
lowest_do_pos = np.argmin(do_readings)
print(f"Lowest oxygen found at index: {lowest_do_pos} (Value: {do_readings[lowest_do_pos]})")

# 7. Compare July temp to annual mean
temps_array = np.array(list(monthly_temps.values()))
annual_mean_temp = np.mean(temps_array)
jul_diff = monthly_temps["Jul"] - annual_mean_temp
print(f"July is {jul_diff:.2f} degrees warmer than the annual average.")


# ==============================================================================
# EXERCISE 2: Importing Data
# ==============================================================================
print("\n--- Exercise 2 ---")

# Import with explicit handling of NAs
water_data = pd.read_csv(
    "/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/water_quality.csv",
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
print(f"Missing DO values: {na_do}")
print(f"Missing Temp values: {na_temp}")


# ==============================================================================
# EXERCISE 3: Data Inspection and Validation
# ==============================================================================
print("\n--- Exercise 3 ---")

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
if len(invalid_data) > 0:
    print(f"Found {len(invalid_data)} rows with potentially invalid data:")
    print(invalid_data)
else:
    print("No data validation issues found based on ranges.")


# ==============================================================================
# EXERCISE 4: Filtering and Selecting
# ==============================================================================
print("\n--- Exercise 4 ---")

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

print("Fisheries Data:")
print(fisheries_req.head())

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

print("Researcher Data:")
print(researcher_req.head())


# ==============================================================================
# EXERCISE 5: Transforming Data
# ==============================================================================
print("\n--- Exercise 5 ---")

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
water_enhanced["days_since_start"] = (
    water_enhanced["date"] - water_enhanced["date"].min()
).dt.days

# 7. Temperature Z-score
temp_mean = water_enhanced["temp_c"].mean()
temp_sd = water_enhanced["temp_c"].std()
water_enhanced["temp_zscore"] = (water_enhanced["temp_c"] - temp_mean) / temp_sd

print(water_enhanced.dtypes)
print(water_enhanced.head())


# ==============================================================================
# EXERCISE 6: Grouping and Summarizing
# ==============================================================================
print("\n--- Exercise 6 ---")

# Part 1: Station summary report
station_summary = water_enhanced.groupby("station", observed=True).agg(
    mean_temp=("temp_c", "mean"),
    mean_do=("do_mg_l", "mean"),
    max_turbidity=("turbidity_ntu", "max"),
    n_obs=("temp_c", "count"),
).reset_index()

# Proportion of stressed readings (DO < 6)
prop_stressed = (
    water_enhanced.groupby("station", observed=True)["do_mg_l"]
    .apply(lambda x: (x < 6).mean())
    .reset_index(name="prop_stressed")
)

station_summary = station_summary.merge(prop_stressed, on="station")

print("Station Summary:")
print(station_summary)

# Part 2: Station-relative analysis using transform
water_enhanced["station_mean_temp"] = water_enhanced.groupby(
    "station", observed=True
)["temp_c"].transform("mean")

water_enhanced["temp_vs_station"] = (
    water_enhanced["temp_c"] - water_enhanced["station_mean_temp"]
)

water_enhanced["station_do_rank"] = water_enhanced.groupby(
    "station", observed=True
)["do_mg_l"].rank(ascending=False)

print("Station Relative Data:")
print(
    water_enhanced[["station", "temp_c", "temp_vs_station", "station_do_rank"]]
    .head()
)


# ==============================================================================
# EXERCISE 7: Tidying Data
# ==============================================================================
print("\n--- Exercise 7 ---")

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

print("Long Format:")
print(temps_long)

# Part 2: Pivot back to wide (stations as columns)
temps_wide_again = temps_long.pivot(
    index="month", columns="station", values="temperature"
).reset_index()

print("Wide Format (Stations as columns):")
print(temps_wide_again)

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
).reset_index()

# Flatten column names
water_tidy.columns.name = None

print("Tidied Multi-variable Data:")
print(water_tidy)


# ==============================================================================
# EXERCISE 8: Combining Monitoring Databases
# ==============================================================================
print("\n--- Exercise 8 ---")

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
print(f"Stations in metadata but not in water quality: {missing_from_wq}")
print(f"Stations in water quality but not in metadata: {missing_from_meta}")

# Part 2: Nutrient data merge
nutrient_data = pd.DataFrame({
    "station": ["CB-5.1", "CB-5.2", "CB-6.1"],
    "date": pd.to_datetime(["2025-06-15", "2025-06-15", "2025-06-15"]),
    "nitrogen_mg_l": [1.2, 1.5, 0.9],
    "phosphorus_mg_l": [0.08, 0.12, 0.06],
})

# Merge by both station and date
combined = pd.merge(water_data, nutrient_data, on=["station", "date"], how="left")
print(f"Combined rows: {len(combined)}")
print(f"Rows with nutrient data: {combined['nitrogen_mg_l'].notna().sum()}")

# Part 3: Stacking datasets
# Simulate a second batch with same columns
batch2 = water_data.head(5).copy()
stacked = pd.concat([water_data, batch2], ignore_index=True)
print(f"Original rows: {len(water_data)}")
print(f"Batch 2 rows: {len(batch2)}")
print(f"Stacked rows: {len(stacked)}")
print(f"Verified: {len(stacked) == len(water_data) + len(batch2)}")


# ==============================================================================
# EXERCISE 9: Writing Functions
# ==============================================================================
print("\n--- Exercise 9 ---")

# 1. Temperature Conversion
def celsius_to_fahrenheit(temp_c):
    return temp_c * 9/5 + 32

def fahrenheit_to_celsius(temp_f):
    return (temp_f - 32) * 5/9

# Test: round-trip conversion
print(f"25C to F: {celsius_to_fahrenheit(25)}")
print(f"77F to C: {fahrenheit_to_celsius(77)}")
print(f"Round-trip: {fahrenheit_to_celsius(celsius_to_fahrenheit(25))}")

# 2. Saturation Deficit
def calc_saturation_deficit(do_measured, temperature):
    do_saturated = 14.62 - (0.3898 * temperature)
    deficit = do_saturated - do_measured
    return deficit

# Test
print(f"Deficit at 6.5mg/L, 25C: {calc_saturation_deficit(6.5, 25)}")

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

# Test
print(classify_water_quality(1.5, 20))   # Critical
print(classify_water_quality(3.0, 22))   # Stressed
print(classify_water_quality(7.0, 30))   # Heat Stress
print(classify_water_quality(8.0, 22))   # Good

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

# Test (assuming water_enhanced exists)
result = summarize_station(water_enhanced, "CB-5.1")
if result:
    print(result)


# ==============================================================================
# EXERCISE 10: Loops and Iteration
# ==============================================================================
print("\n--- Exercise 10 ---")

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
print("Accumulated Summaries:")
print(all_summaries)

# Part 3: While loop simulation
print("Running Hypoxia Simulation...")

def run_simulation():
    do_level = 8.0
    days = 0
    while do_level >= 2.0:
        do_level -= random.uniform(0.1, 0.5)
        days += 1
    return days

# Run 5 times
sim_results = [run_simulation() for _ in range(5)]
print(f"Days to hypoxia in 5 simulations: {sim_results}")

# Part 4: Two ways to iterate — for loop vs list comprehension
# Both approaches produce the exact same result.

# Approach A: For loop (explicit, step-by-step — the algorithmic way)
results_loop = []
for st in stations:
    st_data = water_enhanced[water_enhanced["station"] == st]
    results_loop.append({
        "station": st,
        "mean_do": st_data["do_mg_l"].mean(),
        "n": len(st_data),
    })
final_loop = pd.DataFrame(results_loop)

# Approach B: List comprehension (compact syntax — same logic, one expression)
results_comp = [
    {
        "station": st,
        "mean_do": water_enhanced[water_enhanced["station"] == st]["do_mg_l"].mean(),
        "n": len(water_enhanced[water_enhanced["station"] == st]),
    }
    for st in stations
]
final_comp = pd.DataFrame(results_comp)

# Verify both give the same result
print("For loop result:")
print(final_loop)
print("List comprehension result:")
print(final_comp)
