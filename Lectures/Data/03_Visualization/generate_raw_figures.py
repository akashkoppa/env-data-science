"""
Generate "raw/uninformative" figures for Lecture 3: Data Visualization and Interpretation.

Each figure shows the same underlying data as the corresponding "good" figure,
but presented in a naive way that fails to answer the posed scientific question.
The pedagogical goal: students see the raw plot first, discuss what transformation
would help, then see the better visualization.

Requires: matplotlib, numpy
Usage: python generate_raw_figures.py
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from pathlib import Path

# --- Configuration ---
OUTPUT_DIR = Path(__file__).parent

# Lecture color scheme
SAGE_GREEN = "#2d5a27"
STEEL_BLUE = "#457b9d"
SOFT_CHARCOAL = "#2f2f2f"
WARNING_RED = "#c44536"
BG_COLOR = "#fdfdfc"
ORANGE = "#e07a3a"
PURPLE = "#8e44ad"
TEAL = "#16a085"

# Set global matplotlib style
plt.rcParams.update({
    "figure.facecolor": BG_COLOR,
    "axes.facecolor": "white",
    "axes.edgecolor": SOFT_CHARCOAL,
    "axes.labelcolor": SOFT_CHARCOAL,
    "text.color": SOFT_CHARCOAL,
    "xtick.color": SOFT_CHARCOAL,
    "ytick.color": SOFT_CHARCOAL,
    "font.family": "serif",
    "font.size": 12,
    "axes.grid": True,
    "grid.alpha": 0.3,
    "grid.color": "#cccccc",
})

DPI = 300
FIG_WIDTH = 10
FIG_HEIGHT = 5.5


def save_fig(fig, name):
    """Save figure to output directory."""
    filepath = OUTPUT_DIR / name
    fig.savefig(filepath, dpi=DPI, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close(fig)
    print(f"  Saved: {filepath.name}")


# =============================================================================
# Problem 1: Raw — Absolute global mean surface temperature (not anomalies)
# The ~14°C baseline with small variations makes warming nearly invisible.
# =============================================================================
def problem1_raw():
    print("Problem 1 Raw: Absolute Temperature Time Series...")
    np.random.seed(42)
    years = np.arange(1900, 2025)

    # Same trend as the "good" figure, but add back the ~14°C baseline
    trend = np.zeros_like(years, dtype=float)
    for i, y in enumerate(years):
        if y < 1940:
            trend[i] = -0.20 + 0.004 * (y - 1900)
        elif y < 1970:
            trend[i] = -0.04 + 0.003 * (y - 1940)
        else:
            trend[i] = 0.05 + 0.019 * (y - 1970)

    noise = np.random.normal(0, 0.07, len(years))
    anomaly = trend + noise

    # Convert anomaly to absolute temperature (baseline ~14.0°C)
    absolute_temp = 14.0 + anomaly

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))
    ax.plot(years, absolute_temp, color=STEEL_BLUE, linewidth=1.2, alpha=0.8)
    ax.scatter(years, absolute_temp, color=STEEL_BLUE, s=8, alpha=0.5, zorder=3)

    ax.set_xlabel("Year", fontsize=14)
    ax.set_ylabel("Global Mean Surface Temperature (°C)", fontsize=14)
    ax.set_title(
        "Global Mean Surface Temperature (1900–2024)",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.set_xlim(1898, 2026)
    # Full y-axis range makes the warming trend look tiny
    ax.set_ylim(12, 16)

    fig.tight_layout()
    save_fig(fig, "03_prob1_temperature_raw.png")


# =============================================================================
# Problem 2: Raw — Pie chart of emissions by sector
# Similar-sized slices are nearly impossible to compare accurately.
# =============================================================================
def problem2_raw():
    print("Problem 2 Raw: Emissions Pie Chart...")

    sectors = [
        "Electricity & Heat",
        "Industry",
        "Agriculture &\nLand Use",
        "Transport",
        "Manufacturing",
        "Buildings",
        "Other Energy",
    ]
    emissions = [25.0, 21.0, 18.4, 16.2, 12.4, 5.6, 1.4]

    colors = [SAGE_GREEN, STEEL_BLUE, ORANGE, WARNING_RED, PURPLE, TEAL, "#aaaaaa"]

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))
    wedges, texts, autotexts = ax.pie(
        emissions,
        labels=sectors,
        autopct="%1.1f%%",
        colors=colors,
        startangle=90,
        textprops={"fontsize": 9},
        pctdistance=0.75,
        labeldistance=1.12,
    )
    for t in autotexts:
        t.set_fontsize(8)
        t.set_color("white")
        t.set_fontweight("bold")

    ax.set_title(
        "Global Greenhouse Gas Emissions by Sector",
        fontsize=14, fontweight="bold", color=SAGE_GREEN, pad=10,
    )

    fig.tight_layout()
    save_fig(fig, "03_prob2_emissions_raw.png")


# =============================================================================
# Problem 3: Raw — Bar chart of mean PM2.5 per city (hides variability)
# A single bar per city hides the distribution, outliers, and daily variation.
# =============================================================================
def problem3_raw():
    print("Problem 3 Raw: Mean PM2.5 Bar Chart...")
    np.random.seed(123)
    n = 365

    cities_data = {
        "Stockholm": np.random.lognormal(1.8, 0.5, n),
        "London": np.random.lognormal(2.3, 0.4, n),
        "Los Angeles": np.random.lognormal(2.5, 0.5, n),
        "Nairobi": np.random.lognormal(2.8, 0.55, n),
        "Beijing": np.random.lognormal(3.3, 0.65, n),
        "Delhi": np.random.lognormal(3.8, 0.55, n),
    }

    city_names = list(cities_data.keys())
    means = [np.mean(cities_data[c]) for c in city_names]

    colors = [SAGE_GREEN, STEEL_BLUE, ORANGE, PURPLE, WARNING_RED, "#8b0000"]

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))
    bars = ax.bar(city_names, means, color=colors, width=0.6, edgecolor="white", alpha=0.85)

    for bar, val in zip(bars, means):
        ax.text(
            bar.get_x() + bar.get_width() / 2, bar.get_height() + 1,
            f"{val:.1f}", ha="center", va="bottom", fontsize=11,
            fontweight="bold", color=SOFT_CHARCOAL,
        )

    ax.set_ylabel("Mean PM$_{2.5}$ Concentration (μg/m³)", fontsize=14)
    ax.set_title(
        "Annual Mean PM$_{2.5}$ Across Major Cities",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    fig.tight_layout()
    save_fig(fig, "03_prob3_air_quality_raw.png")


# =============================================================================
# Problem 4: Raw — Two separate bar charts (SST and bleaching side by side)
# Showing the two variables separately makes the relationship invisible.
# =============================================================================
def problem4_raw():
    print("Problem 4 Raw: Separate SST and Bleaching Bars...")
    np.random.seed(456)
    n = 80

    sst_anomaly = np.random.uniform(0.2, 3.2, n)
    bleaching = np.clip(
        -5 + 20 * sst_anomaly + 8 * sst_anomaly**2 + np.random.normal(0, 8, n),
        0, 100,
    )

    # Sort by site number for the "raw" view
    sites = np.arange(1, n + 1)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(FIG_WIDTH, FIG_HEIGHT - 1))

    # Left: SST anomaly per site
    ax1.bar(sites, sst_anomaly, color=STEEL_BLUE, width=0.8, alpha=0.7, edgecolor="none")
    ax1.set_xlabel("Reef Site", fontsize=11)
    ax1.set_ylabel("SST Anomaly (°C)", fontsize=11)
    ax1.set_title("SST Anomaly by Site", fontsize=12, fontweight="bold", color=SAGE_GREEN)
    ax1.set_xlim(0, n + 1)

    # Right: Bleaching per site
    ax2.bar(sites, bleaching, color=ORANGE, width=0.8, alpha=0.7, edgecolor="none")
    ax2.set_xlabel("Reef Site", fontsize=11)
    ax2.set_ylabel("Bleaching (%)", fontsize=11)
    ax2.set_title("Bleaching by Site", fontsize=12, fontweight="bold", color=SAGE_GREEN)
    ax2.set_xlim(0, n + 1)

    fig.suptitle(
        "Coral Reef Data — Shown Separately",
        fontsize=14, fontweight="bold", color=SAGE_GREEN, y=1.01,
    )
    fig.tight_layout()
    save_fig(fig, "03_prob4_coral_bleaching_raw.png")


# =============================================================================
# Problem 5: Raw — Total remaining forest area (cumulative)
# A slow, gradual decline in a huge number masks the dramatic rate changes.
# =============================================================================
def problem5_raw():
    print("Problem 5 Raw: Remaining Forest Area...")
    years = np.arange(1990, 2025)

    # Same rates as the "good" figure
    rates = np.array([
        13730, 11030, 13786, 14896, 14896, 29059, 18161, 13227, 17383, 17259,
        18226, 18165, 21651, 25396, 27772, 19014, 14286, 11651, 12911, 7464,
        7000, 6418, 4571, 5891, 5012, 6207, 7893, 6947, 7536, 10129,
        11088, 13235, 11568, 9001, 8590,
    ])

    # Total Amazon forest ~5.5 million km², subtract cumulative deforestation
    initial_forest = 5_500_000
    cumulative_loss = np.cumsum(rates)
    remaining = initial_forest - cumulative_loss

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))
    ax.plot(years, remaining / 1e6, color=SAGE_GREEN, linewidth=2.5, marker="o", markersize=3)
    ax.fill_between(years, remaining / 1e6, color=SAGE_GREEN, alpha=0.1)

    ax.set_xlabel("Year", fontsize=14)
    ax.set_ylabel("Remaining Forest Area (million km²)", fontsize=14)
    ax.set_title(
        "Total Remaining Amazon Forest Area (1990–2024)",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    # Y-axis starts at 0 to emphasize how "small" the change looks
    ax.set_ylim(0, 6)
    ax.set_xlim(1989, 2025.5)

    fig.tight_layout()
    save_fig(fig, "03_prob5_deforestation_raw.png")


# =============================================================================
# Problem 6: Raw — Four climate indicators on a shared y-axis
# CO2 (~315–420 ppm) dominates; temperature (~−0.2 to 1.2°C) is invisible.
# =============================================================================
def problem6_raw():
    print("Problem 6 Raw: Climate Indicators on Shared Y-Axis...")
    np.random.seed(101)
    years = np.arange(1960, 2025)
    n = len(years)

    # Temperature anomaly (°C): ~−0.1 to ~1.1, accelerating after 1980
    temp = np.zeros(n, dtype=float)
    for i, y in enumerate(years):
        if y < 1980:
            temp[i] = -0.1 + 0.005 * (y - 1960)
        else:
            temp[i] = 0.0 + 0.025 * (y - 1980)
    temp += np.random.normal(0, 0.05, n)

    # CO2 concentration (ppm): ~315 to ~420, steady Keeling-curve rise
    co2 = 315 + 1.5 * (years - 1960) + 0.02 * (years - 1960) ** 2
    co2 += np.random.normal(0, 0.3, n)

    # Sea level rise (mm): ~0 to ~100, accelerating
    sea_level = 0.5 * (years - 1960) + 0.015 * (years - 1960) ** 2
    sea_level += np.random.normal(0, 1.5, n)

    # Arctic sea ice extent (million km²): ~7.5 declining to ~4.5
    ice = 7.5 - 0.03 * (years - 1960) - 0.0005 * (years - 1960) ** 2
    ice += np.random.normal(0, 0.15, n)

    indicators = {
        "Temperature Anomaly (°C)": temp,
        "CO₂ Concentration (ppm)": co2,
        "Sea Level Rise (mm)": sea_level,
        "Arctic Sea Ice (million km²)": ice,
    }
    colors = [SAGE_GREEN, STEEL_BLUE, ORANGE, PURPLE]

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))

    for (name, data), color in zip(indicators.items(), colors):
        ax.plot(years, data, color=color, linewidth=2, label=name)

    ax.set_xlabel("Year", fontsize=14)
    ax.set_ylabel("Value", fontsize=14)
    ax.set_title(
        "Four Climate Indicators on a Shared Y-Axis (1960–2024)",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.legend(fontsize=9, loc="upper left")
    ax.set_xlim(1959, 2025)

    fig.tight_layout()
    save_fig(fig, "03_prob6_climate_indicators_raw.png")


# =============================================================================
# Problem 7: Raw — Bar chart of nitrate by watershed (no explanatory variables)
# Just shows nitrate values without revealing what drives the differences.
# =============================================================================
def problem7_raw():
    print("Problem 7 Raw: Nitrate by Watershed Bar Chart...")
    np.random.seed(202)
    n = 60

    ag_pct = np.random.uniform(5, 90, n)
    urban_pct = np.random.uniform(2, 45, n)

    nitrogen = (
        0.5
        + 0.07 * ag_pct
        + 0.001 * ag_pct**2
        + 0.03 * urban_pct
        + np.random.normal(0, 1.0, n)
    )
    nitrogen = np.clip(nitrogen, 0.1, None)

    # Sort by watershed number (arbitrary order)
    watersheds = [f"W{i:02d}" for i in range(1, n + 1)]

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))
    ax.bar(
        range(n), nitrogen, color=STEEL_BLUE, width=0.8, alpha=0.7, edgecolor="none",
    )

    ax.set_xlabel("Watershed", fontsize=14)
    ax.set_ylabel("Nitrate-N Concentration (mg/L)", fontsize=14)
    ax.set_title(
        "Nitrate Concentration Across 60 Watersheds",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    # Show only every 10th label to avoid clutter
    ax.set_xticks(range(0, n, 10))
    ax.set_xticklabels([watersheds[i] for i in range(0, n, 10)], fontsize=9)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    fig.tight_layout()
    save_fig(fig, "03_prob7_agriculture_water_raw.png")


# =============================================================================
# Problem 8: Raw — Individual line plots for all 6 regions on one panel
# Overlapping lines make trends and comparisons hard to parse.
# =============================================================================
def problem8_raw():
    print("Problem 8 Raw: PDSI Line Plots (All Regions)...")
    np.random.seed(303)

    regions = [
        "Southwest US", "Great Plains", "Southeast US",
        "Mediterranean", "East Africa", "Central Asia",
    ]
    years = np.arange(1990, 2025)
    n_regions = len(regions)
    n_years = len(years)

    # Same data generation as the heatmap
    data = np.random.normal(0, 1.0, (n_regions, n_years))
    data[0, :] -= np.linspace(0, 2.2, n_years)   # Southwest US
    data[3, :] -= np.linspace(0, 1.8, n_years)   # Mediterranean
    data[4, :] -= np.linspace(0, 1.5, n_years)   # East Africa
    data[1, :] += np.sin(np.linspace(0, 4 * np.pi, n_years)) * 1.3
    data = np.clip(data, -4, 4)

    colors = [SAGE_GREEN, STEEL_BLUE, ORANGE, WARNING_RED, PURPLE, TEAL]

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))

    for i, (region, color) in enumerate(zip(regions, colors)):
        ax.plot(years, data[i, :], color=color, linewidth=1.3, alpha=0.7, label=region)

    ax.axhline(y=0, color=SOFT_CHARCOAL, linewidth=0.8, linestyle="--", alpha=0.5)
    ax.set_xlabel("Year", fontsize=14)
    ax.set_ylabel("Palmer Drought Severity Index (PDSI)", fontsize=14)
    ax.set_title(
        "PDSI Across World Regions (1990–2024)",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.legend(fontsize=9, loc="lower left", ncol=2)
    ax.set_xlim(1989, 2025)

    fig.tight_layout()
    save_fig(fig, "03_prob8_drought_raw.png")


# =============================================================================
# Run all raw figures
# =============================================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Generating RAW/UNINFORMATIVE figures for Lecture 3")
    print("=" * 60)
    problem1_raw()
    problem2_raw()
    problem3_raw()
    problem4_raw()
    problem5_raw()
    problem6_raw()
    problem7_raw()
    problem8_raw()
    print("=" * 60)
    print("All 8 raw figures generated successfully!")
