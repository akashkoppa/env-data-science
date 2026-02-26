# =============================================================================
# Lecture 4: Data Visualization and Interpretation — Solutions (Python)
# Environmental Data Science (ENST431/631)
# Author: Akash Koppa
# =============================================================================

# Each exercise below is fully self-contained: it includes all data loading,
# preparation, and transformation code needed to run independently.

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import random

# =============================================================================
# EXERCISE 1: Visualizing the Oxygen Profile
# =============================================================================

# --- Data Setup (self-contained) ---
do_readings = np.array([8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5])
depths = np.arange(1, 11)
months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
monthly_temps = np.array([4.2, 4.5, 8.1, 12.5, 17.3, 22.1,
                          26.8, 26.5, 22.4, 16.3, 10.7, 6.1])

# --- Figure A: DO Depth Profile ---
fig, ax = plt.subplots(figsize=(6, 8))
ax.plot(do_readings, depths, "o-", color="#457b9d", linewidth=2, markersize=8)
ax.invert_yaxis()  # depth increases downward
ax.set_xlabel("Dissolved Oxygen (mg/L)", fontsize=12)
ax.set_ylabel("Depth Position (surface = 1, bottom = 10)", fontsize=12)
ax.set_title("Dissolved Oxygen Declines Sharply Below Position 6\n"
             "at Station CB-5.1", fontsize=13, fontweight="bold")

# EPA threshold
ax.axvline(x=5.0, color="red", linestyle="--", linewidth=2, label="EPA Threshold (5.0 mg/L)")
ax.axvspan(0, 5.0, alpha=0.04, color="red")
ax.legend(fontsize=9)
plt.tight_layout()
plt.savefig("ex01_depth_profile.png", dpi=150)
plt.show()

# --- Figure B: Seasonal Temperature Cycle ---
fig, ax = plt.subplots(figsize=(10, 5))
colors = ["#d62828" if t > 20 else "#457b9d" for t in monthly_temps]
bars = ax.bar(months, monthly_temps, color=colors, edgecolor="white", linewidth=0.5)
ax.axhline(y=20, color="red", linestyle="--", linewidth=1.5, label="20°C threshold")
ax.set_xlabel("Month", fontsize=12)
ax.set_ylabel("Water Temperature (°C)", fontsize=12)
ax.set_title("Four Months Exceed 20°C at Station CB-5.1\n"
             "(Jun–Sep: Elevated Risk of Oxygen Depletion)",
             fontsize=13, fontweight="bold")
ax.legend(fontsize=9)
plt.tight_layout()
plt.savefig("ex01_temperature_cycle.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 2: Mapping the Data Gaps
# =============================================================================

# --- Data Setup (self-contained) ---
df = pd.read_csv("/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/02_Algorithms/water_quality.csv", na_values=["-999", "-9999"])
df["date"] = pd.to_datetime(df["date"])
df = df.rename(columns={"turbidity_ntu": "turbidity"})

# --- Figure: Two-panel missing data pattern ---
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Panel 1: NA counts by variable
na_counts = df.isna().sum().sort_values(ascending=True)
na_counts = na_counts[na_counts > 0]
ax1.barh(na_counts.index, na_counts.values, color="#457b9d", edgecolor="white")
ax1.set_xlabel("Number of Missing Values")
ax1.set_title("Missing Values by Variable", fontweight="bold")

# Panel 2: NA counts by station for DO
na_by_station = df.groupby("station")["do_mg_l"].apply(lambda x: x.isna().sum())
na_by_station = na_by_station.sort_values(ascending=True)
ax2.barh(na_by_station.index, na_by_station.values, color="#d62828", edgecolor="white")
ax2.set_xlabel("Number of Missing DO Values")
ax2.set_title("Missing DO by Station", fontweight="bold")

plt.tight_layout()
plt.savefig("ex02_missing_data.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 3: Diagnosing Data Quality Visually
# =============================================================================

# --- Data Setup (self-contained) ---
df = pd.read_csv("/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/02_Algorithms/water_quality.csv", na_values=["-999", "-9999"])
df["date"] = pd.to_datetime(df["date"])
df = df.rename(columns={"turbidity_ntu": "turbidity"})

# --- Figure: Four-panel distribution check ---
fig, axes = plt.subplots(2, 2, figsize=(10, 8))

params = [
    ("temp_c", "Temperature (°C)", [0, 35], "#457b9d"),
    ("do_mg_l", "Dissolved Oxygen (mg/L)", [0, 15], "#2a9d8f"),
    ("ph", "pH", [6, 9], "#e9c46a"),
    ("turbidity", "Turbidity (NTU)", [0, None], "#f4a261"),
]

for ax, (col, label, plausible, color) in zip(axes.flat, params):
    values = df[col].dropna()
    ax.hist(values, bins=25, color=color, edgecolor="white")
    ax.set_xlabel(label)
    ax.set_ylabel("Frequency")
    ax.set_title(f"{label.split('(')[0].strip()} Distribution", fontweight="bold")

    # Plausible range lines
    for boundary in plausible:
        if boundary is not None:
            ax.axvline(x=boundary, color="red", linestyle="--", linewidth=2)

    ax.legend(["Plausible range boundary"], fontsize=7, loc="upper right")

plt.suptitle("Distribution of Water Quality Parameters\n"
             "with Plausible Range Boundaries",
             fontsize=14, fontweight="bold", y=1.02)
plt.tight_layout()
plt.savefig("ex03_distributions.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 4: Visualizing the Hypoxia Event
# =============================================================================

# --- Data Setup (self-contained) ---
df = pd.read_csv("/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/02_Algorithms/water_quality.csv", na_values=["-999", "-9999"])
df["date"] = pd.to_datetime(df["date"])
df = df.rename(columns={"turbidity_ntu": "turbidity"})

# --- Filter to July 23rd event data ---
event = df[(df["date"] == "2025-07-23") &
           ((df["do_mg_l"] < 6.0) | (df["turbidity"] > 15))].copy()

# --- Figure: Scatter with quadrant annotations ---
fig, ax = plt.subplots(figsize=(9, 7))

# Okabe-Ito colorblind-friendly palette
okabe_ito = ["#E69F00", "#56B4E9", "#009E73", "#F0E442",
             "#0072B2", "#D55E00", "#CC79A7", "#999999"]

stations = event["station"].unique()
for i, station in enumerate(stations):
    sub = event[event["station"] == station]
    ax.scatter(sub["turbidity"], sub["do_mg_l"],
               color=okabe_ito[i % len(okabe_ito)],
               s=100, label=station, zorder=5)
    # Label each point
    for _, row in sub.iterrows():
        ax.annotate(station, (row["turbidity"], row["do_mg_l"]),
                    fontsize=7, color="gray",
                    xytext=(5, 5), textcoords="offset points")

# Reference lines
ax.axhline(y=6.0, color="red", linestyle="--", linewidth=1.5, label="DO Threshold (6.0 mg/L)")
ax.axvline(x=15, color="darkorange", linestyle="--", linewidth=1.5, label="Turbidity Threshold (15 NTU)")

# Annotate critical quadrant
ax.text(0.95, 0.05, "Critical Zone:\nLow DO + High Turbidity",
        transform=ax.transAxes, fontsize=9, fontweight="bold",
        color="red", ha="right", va="bottom",
        bbox=dict(boxstyle="round,pad=0.3", facecolor="mistyrose", alpha=0.8))

ax.set_xlabel("Turbidity (NTU)", fontsize=12)
ax.set_ylabel("Dissolved Oxygen (mg/L)", fontsize=12)
ax.set_title("July 23 Hypoxia Event: Low DO and High Turbidity\n"
             "Co-Occur at Multiple Stations",
             fontsize=13, fontweight="bold")
ax.legend(fontsize=8, loc="upper right")
plt.tight_layout()
plt.savefig("ex04_hypoxia_event.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 5: The Annual Report Timeline
# =============================================================================

# --- Data Setup (self-contained) ---
df = pd.read_csv("/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/02_Algorithms/water_quality.csv", na_values=["-999", "-9999"])
df["date"] = pd.to_datetime(df["date"])
df = df.rename(columns={"turbidity_ntu": "turbidity"})

# --- Derived columns from Lecture 2 Exercise 5 ---
df["do_percent_sat"] = (df["do_mg_l"] / 8.0) * 100
conditions = [df["do_mg_l"].isna(), df["do_mg_l"] < 2, df["do_mg_l"] < 5, df["do_mg_l"] < 8]
choices = ["Unknown", "Hypoxic", "Stressed", "Adequate"]
df["do_status"] = np.select(conditions, choices, default="Healthy")

# --- Figure: Two-panel timeline ---
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), sharex=True)

# Panel 1: DO percent saturation colored by status
status_colors = {
    "Hypoxic": "#d62828", "Stressed": "#f77f00",
    "Adequate": "#457b9d", "Healthy": "#2a9d8f",
    "Unknown": "gray"
}

for status, color in status_colors.items():
    mask = df["do_status"] == status
    if mask.any():
        ax1.scatter(df.loc[mask, "date"], df.loc[mask, "do_percent_sat"],
                    c=color, label=status, s=15, alpha=0.7)

ax1.axhline(y=100, color="black", linestyle="--", linewidth=1)
ax1.set_ylabel("DO Percent Saturation (%)", fontsize=11)
ax1.set_title("Water Quality Status Across the 2025 Monitoring Season",
              fontsize=13, fontweight="bold")
ax1.legend(fontsize=8, ncol=3, title="Status")

# Panel 2: Temperature
ax2.scatter(df["date"], df["temp_c"], c="#d62828", s=10, alpha=0.4)
ax2.axhline(y=20, color="red", linestyle="--", linewidth=1.5)
ax2.set_xlabel("Date", fontsize=11)
ax2.set_ylabel("Water Temperature (°C)", fontsize=11)
ax2.set_title("Temperature Drives Seasonal Oxygen Depletion",
              fontsize=13, fontweight="bold")

plt.tight_layout()
plt.savefig("ex05_annual_timeline.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 6: The Station Scorecard
# =============================================================================

# --- Data Setup (self-contained) ---
df = pd.read_csv("/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/02_Algorithms/water_quality.csv", na_values=["-999", "-9999"])
df["date"] = pd.to_datetime(df["date"])
df = df.rename(columns={"turbidity_ntu": "turbidity"})

# --- Station summary from Lecture 2 Exercise 6 ---
station_summary = df.groupby("station").agg(
    mean_temp=("temp_c", "mean"),
    mean_do=("do_mg_l", "mean"),
    max_turbidity=("turbidity", "max"),
    n_obs=("temp_c", "count"),
).reset_index()
station_summary["prop_stressed"] = df.groupby("station")["do_mg_l"].apply(
    lambda x: (x < 6).mean()
).values

# --- Figure: Cleveland dot plot sorted by mean DO ---
sorted_summary = station_summary.sort_values("mean_do")

fig, ax = plt.subplots(figsize=(8, 6))
y_positions = range(len(sorted_summary))

# Mean DO dots
ax.scatter(sorted_summary["mean_do"], y_positions,
           c="#457b9d", s=120, zorder=5, label="Mean DO")

# Encode proportion stressed as ring size
ring_sizes = 50 + sorted_summary["prop_stressed"].values * 500
ax.scatter(sorted_summary["mean_do"], y_positions,
           facecolors="none", edgecolors="#d62828",
           s=ring_sizes, linewidths=1.5, zorder=4,
           label="Ring = Proportion Stressed")

# Reference lines
ax.axvline(x=5.0, color="#d62828", linestyle="--", linewidth=2, label="Stress Threshold (5.0)")
ax.axvline(x=2.0, color="#d62828", linestyle=":", linewidth=1.5, label="Hypoxia (2.0)")

ax.set_yticks(list(y_positions))
ax.set_yticklabels(sorted_summary["station"])
ax.set_xlabel("Mean Dissolved Oxygen (mg/L)", fontsize=12)
ax.set_title("Station Performance Ranked by Mean DO\n"
             "Lowest Stations Need Priority Intervention",
             fontsize=13, fontweight="bold")
ax.legend(fontsize=8, loc="lower right")
plt.tight_layout()
plt.savefig("ex06_station_scorecard.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 7: Revealing Seasonal Patterns in Legacy Data
# =============================================================================

# --- Data Setup (self-contained) ---
temps_wide = pd.DataFrame({
    "station": ["CB-5.1", "CB-5.2"],
    "jan": [4.2, 3.8], "apr": [12.5, 11.9],
    "jul": [26.8, 27.1], "oct": [16.3, 15.8]
})

long_data = pd.melt(temps_wide, id_vars="station",
                    var_name="month", value_name="temperature")

month_order = {"jan": 1, "apr": 4, "jul": 7, "oct": 10}
long_data["month_num"] = long_data["month"].map(month_order)

# --- Figure: Overlaid line plot ---
fig, ax = plt.subplots(figsize=(8, 5))
colors = {"CB-5.1": "#457b9d", "CB-5.2": "#d62828"}

for station in long_data["station"].unique():
    sub = long_data[long_data["station"] == station].sort_values("month_num")
    ax.plot(sub["month_num"], sub["temperature"],
            "o-", color=colors[station], linewidth=2,
            markersize=10, label=station)

    # Annotate seasonal range
    temp_range = sub["temperature"].max() - sub["temperature"].min()
    ax.annotate(f"Range: {temp_range:.1f}°C",
                xy=(10, sub["temperature"].iloc[-1]),
                fontsize=8, color=colors[station])

ax.set_xticks([1, 4, 7, 10])
ax.set_xticklabels(["Jan", "Apr", "Jul", "Oct"])
ax.set_xlabel("Month", fontsize=12)
ax.set_ylabel("Temperature (°C)", fontsize=12)
ax.set_title("Seasonal Temperature Cycle Consistent Across Stations\n"
             "(Legacy Data: CB-5.1 vs CB-5.2)",
             fontsize=13, fontweight="bold")
ax.legend(fontsize=10)
plt.tight_layout()
plt.savefig("ex07_seasonal_patterns.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 8: Exploring Nutrient-Oxygen Connections
# =============================================================================

# --- Data Setup (self-contained) ---
df = pd.read_csv("/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/02_Algorithms/water_quality.csv", na_values=["-999", "-9999"])
df["date"] = pd.to_datetime(df["date"])
df = df.rename(columns={"turbidity_ntu": "turbidity"})

# --- Station metadata from Lecture 2 Exercise 8 ---
station_meta = pd.DataFrame({
    "station": ["CB-5.1", "CB-5.2", "CB-5.3", "CB-6.1"],
    "region": ["Main Stem", "Main Stem", "Main Stem", "Lower Bay"],
    "type": ["Fixed", "Fixed", "Fixed", "Rotating"],
    "lat": [38.978, 38.856, 38.742, 37.587],
    "lon": [-76.381, -76.372, -76.321, -76.138]
})

# --- Nutrient data from Lecture 2 Exercise 8 ---
nutrient_data = pd.DataFrame({
    "station": ["CB-5.1", "CB-5.2", "CB-6.1"],
    "date": pd.to_datetime(["2025-06-15", "2025-06-15", "2025-06-15"]),
    "nitrogen_mg_l": [1.2, 1.5, 0.9],
    "phosphorus_mg_l": [0.08, 0.12, 0.06]
})

# --- Merge all three datasets ---
merged = pd.merge(df, station_meta, on="station", how="left")
merged = pd.merge(merged, nutrient_data, on=["station", "date"], how="left")
# Keep only rows with nutrient data for plotting
merged = merged.dropna(subset=["nitrogen_mg_l"])

# --- Figure: Scatter with region color and phosphorus size ---
fig, ax = plt.subplots(figsize=(9, 7))

region_colors = {"Main Stem": "#457b9d", "Lower Bay": "#d62828"}

for region, color in region_colors.items():
    sub = merged[merged["region"] == region]
    sizes = sub["phosphorus_mg_l"] * 300 + 20
    ax.scatter(sub["nitrogen_mg_l"], sub["do_mg_l"],
               c=color, s=sizes, alpha=0.6, label=region, edgecolors="white")

# Trend line
z = np.polyfit(merged["nitrogen_mg_l"].dropna(),
               merged.loc[merged["nitrogen_mg_l"].notna(), "do_mg_l"], 1)
p = np.poly1d(z)
x_range = np.linspace(merged["nitrogen_mg_l"].min(),
                      merged["nitrogen_mg_l"].max(), 100)
ax.plot(x_range, p(x_range), "--", color="gray", linewidth=1.5, label="Trend")

ax.set_xlabel("Nitrogen Concentration (mg/L)", fontsize=12)
ax.set_ylabel("Dissolved Oxygen (mg/L)", fontsize=12)
ax.set_title("Higher Nitrogen Associated with Lower Dissolved Oxygen\n"
             "in Main Stem Stations",
             fontsize=13, fontweight="bold")
ax.legend(fontsize=9, title="Region (size = phosphorus)")
plt.tight_layout()
plt.savefig("ex08_nutrient_oxygen.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 9: Diagnosing Oxygen Stress with Your Toolkit
# =============================================================================

# --- Data Setup (self-contained) ---
df = pd.read_csv("/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/02_Algorithms/water_quality.csv", na_values=["-999", "-9999"])
df["date"] = pd.to_datetime(df["date"])
df = df.rename(columns={"turbidity_ntu": "turbidity"})

# --- Functions from Lecture 2 Exercise 9 ---
def calc_saturation_deficit(do_measured, temperature):
    do_saturated = 14.62 - (0.3898 * temperature)
    return do_saturated - do_measured

def classify_water_quality(do_val, temp,
                           hypoxic_threshold=2.0, stress_threshold=5.0):
    if pd.isna(do_val) or pd.isna(temp):
        return "Unknown"
    if do_val < hypoxic_threshold:
        return "Critical"
    if do_val < stress_threshold:
        return "Stressed"
    if temp > 28:
        return "Heat Stress"
    return "Good"

# --- Apply functions to dataset ---
df["sat_deficit"] = calc_saturation_deficit(df["do_mg_l"], df["temp_c"])
df["wq_class"] = df.apply(
    lambda r: classify_water_quality(r["do_mg_l"], r["temp_c"]), axis=1
)

# --- Figure: Saturation deficit vs temperature ---
fig, ax = plt.subplots(figsize=(10, 7))

class_colors = {
    "Critical": "#d62828", "Stressed": "#f77f00",
    "Heat Stress": "#7b2d8b", "Good": "#2a9d8f", "Unknown": "gray"
}

for cls, color in class_colors.items():
    if cls == "Unknown":
        continue
    mask = df["wq_class"] == cls
    if mask.any():
        ax.scatter(df.loc[mask, "temp_c"], df.loc[mask, "sat_deficit"],
                   c=color, label=cls, s=25, alpha=0.5)

# Theoretical saturation curve
temp_range = np.linspace(df["temp_c"].min(), df["temp_c"].max(), 200)
do_sat = 14.62 - 0.3898 * temp_range
ax.plot(temp_range, do_sat, "--", color="gray", linewidth=2,
        label="Theoretical Max DO")

# Zero deficit line
ax.axhline(y=0, color="gray", linestyle=":", linewidth=1)

ax.set_xlabel("Water Temperature (°C)", fontsize=12)
ax.set_ylabel("Saturation Deficit (mg/L)", fontsize=12)
ax.set_title("Oxygen Deficit Peaks at High Temperatures\n"
             "(Warm Water Holds Less Oxygen and Actual DO Drops)",
             fontsize=13, fontweight="bold")
ax.legend(fontsize=9, title="Classification")
plt.tight_layout()
plt.savefig("ex09_saturation_deficit.png", dpi=150)
plt.show()


# =============================================================================
# EXERCISE 10: Visualizing Uncertainty in Simulations
# =============================================================================

# --- Data Setup (self-contained) ---
def simulate_hypoxia():
    do_level = 8.0
    trajectory = [do_level]
    while do_level >= 2.0:
        do_level -= random.uniform(0.1, 0.5)
        trajectory.append(do_level)
    return trajectory

# Run 100 simulations
random.seed(42)
sims = [simulate_hypoxia() for _ in range(100)]
days_to_hypoxia = np.array([len(t) - 1 for t in sims])

# --- Figure A: Simulation Trajectories ---
fig, ax = plt.subplots(figsize=(10, 6))

max_days = max(len(t) for t in sims)

for traj in sims:
    ax.plot(range(len(traj)), traj,
            color="#457b9d", alpha=0.12, linewidth=0.8)

# Highlight median trajectory
median_days = np.median(days_to_hypoxia)
median_idx = np.argmin(np.abs(days_to_hypoxia - median_days))
ax.plot(range(len(sims[median_idx])), sims[median_idx],
        color="#d62828", linewidth=2.5, label="Median trajectory")

# Threshold reference lines
ax.axhline(y=8.0, color="#2a9d8f", linestyle="--", linewidth=1.5)
ax.axhline(y=5.0, color="#f77f00", linestyle="--", linewidth=1.5)
ax.axhline(y=2.0, color="#d62828", linestyle="--", linewidth=1.5)

ax.text(max_days * 0.92, 8.3, "Healthy (8.0)", color="#2a9d8f", fontsize=8)
ax.text(max_days * 0.92, 5.3, "Stressed (5.0)", color="#f77f00", fontsize=8)
ax.text(max_days * 0.92, 2.3, "Critical (2.0)", color="#d62828", fontsize=8)

ax.set_xlabel("Day", fontsize=12)
ax.set_ylabel("Dissolved Oxygen (mg/L)", fontsize=12)
ax.set_title("100 Simulated Hypoxia Events: Envelope of Possible Trajectories",
             fontsize=13, fontweight="bold")
ax.legend(fontsize=9)
plt.tight_layout()
plt.savefig("ex10_trajectories.png", dpi=150)
plt.show()


# --- Figure B: Distribution of Days to Hypoxia ---
fig, ax = plt.subplots(figsize=(9, 5))

ax.hist(days_to_hypoxia, bins=15,
        color="#457b9d", edgecolor="white", linewidth=0.5)

# Median line
med = np.median(days_to_hypoxia)
ax.axvline(x=med, color="#d62828", linewidth=2.5)
ax.text(med + 0.3, ax.get_ylim()[1] * 0.9,
        f"Median: {int(med)} days",
        color="#d62828", fontsize=11, fontweight="bold")

# IQR shading
q25 = np.percentile(days_to_hypoxia, 25)
q75 = np.percentile(days_to_hypoxia, 75)
ax.axvspan(q25, q75, alpha=0.1, color="#d62828")
ax.text(q75 + 0.3, ax.get_ylim()[1] * 0.75,
        f"IQR: {int(q25)}\u2013{int(q75)} days",
        color="#d62828", fontsize=9)

ax.set_xlabel("Days Until Critical Hypoxia (DO < 2.0 mg/L)", fontsize=12)
ax.set_ylabel("Number of Simulations", fontsize=12)
ax.set_title("Distribution of Days to Critical Hypoxia\n"
             "Based on 100 Stochastic Simulations",
             fontsize=13, fontweight="bold")
plt.tight_layout()
plt.savefig("ex10_distribution.png", dpi=150)
plt.show()


# --- Risk Statement ---
quantiles = np.percentile(days_to_hypoxia, [5, 25, 50, 75, 95])
fast_threshold = np.percentile(days_to_hypoxia, 10)
pct_fast = (days_to_hypoxia <= fast_threshold).mean() * 100

print("\n--- Risk Statement ---")
print(f"Based on 100 simulations, critical hypoxia is expected within "
      f"{days_to_hypoxia.min()}-{days_to_hypoxia.max()} days,")
print(f"with a median of {int(np.median(days_to_hypoxia))} days.")
print(f"In {pct_fast:.0f}% of simulations, critical conditions developed "
      f"within {int(fast_threshold)} days.")
print(f"Summary quantiles (5th, 25th, 50th, 75th, 95th): "
      f"{', '.join(f'{int(q)}' for q in quantiles)}")
