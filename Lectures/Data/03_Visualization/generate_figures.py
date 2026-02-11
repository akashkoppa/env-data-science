"""
Generate figures for Lecture 3: Data Visualization and Interpretation
Environmental Data Science (ENST431/631)

Run this script to generate all figures used in the lecture slides.
Each figure corresponds to one of the 8 environmental problems discussed in class.

Requires: matplotlib, numpy
Usage: python generate_figures.py
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
# Problem 1: Is Earth Getting Warmer?
# Global Temperature Anomaly (1900-2024) — Bar + Running Mean
# =============================================================================
def problem1_temperature():
    print("Problem 1: Global Temperature Anomaly...")
    np.random.seed(42)
    years = np.arange(1900, 2025)

    # Simulate realistic global temperature anomaly relative to 1951-1980 baseline
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

    # 10-year running mean
    window = 10
    running_mean = np.convolve(anomaly, np.ones(window) / window, mode="valid")
    running_years = years[window // 2 : window // 2 + len(running_mean)]

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))

    # Color bars blue (negative) or red (positive)
    colors = [WARNING_RED if a > 0 else STEEL_BLUE for a in anomaly]
    ax.bar(years, anomaly, width=0.8, color=colors, alpha=0.7, edgecolor="none")

    # Running mean
    ax.plot(
        running_years, running_mean,
        color=SOFT_CHARCOAL, linewidth=2.5, label="10-year running mean",
    )

    ax.axhline(y=0, color=SOFT_CHARCOAL, linewidth=0.8)
    ax.set_xlabel("Year", fontsize=14)
    ax.set_ylabel("Temperature Anomaly (\u00b0C)", fontsize=14)
    ax.set_title(
        "Global Surface Temperature Anomaly Relative to 1951\u20131980 Baseline",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.legend(fontsize=11, loc="upper left")
    ax.set_xlim(1898, 2026)

    fig.tight_layout()
    save_fig(fig, "03_prob1_temperature.png")


# =============================================================================
# Problem 2: Which Sectors Drive Climate Change?
# GHG Emissions by Sector — Horizontal Bar Chart
# =============================================================================
def problem2_emissions():
    print("Problem 2: Emissions by Sector...")

    sectors = [
        "Electricity & Heat",
        "Agriculture & Land Use",
        "Industry",
        "Transport",
        "Manufacturing",
        "Buildings",
        "Other Energy",
    ]
    emissions = [25.0, 18.4, 21.0, 16.2, 12.4, 5.6, 1.4]

    # Sort ascending for horizontal bar
    sorted_idx = np.argsort(emissions)
    sectors_sorted = [sectors[i] for i in sorted_idx]
    emissions_sorted = [emissions[i] for i in sorted_idx]

    colors = []
    for e in emissions_sorted:
        if e >= 20:
            colors.append(SAGE_GREEN)
        elif e >= 10:
            colors.append(STEEL_BLUE)
        else:
            colors.append(ORANGE)

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))
    bars = ax.barh(
        sectors_sorted, emissions_sorted,
        color=colors, edgecolor="white", height=0.55,
    )

    for bar, val in zip(bars, emissions_sorted):
        ax.text(
            bar.get_width() + 0.5, bar.get_y() + bar.get_height() / 2,
            f"{val}%", va="center", fontsize=12, color=SOFT_CHARCOAL, fontweight="bold",
        )

    ax.set_xlabel("Share of Global Greenhouse Gas Emissions (%)", fontsize=14)
    ax.set_title(
        "Global Greenhouse Gas Emissions by Sector",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.set_xlim(0, 30)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    fig.tight_layout()
    save_fig(fig, "03_prob2_emissions.png")


# =============================================================================
# Problem 3: Is the Air Safe to Breathe?
# PM2.5 Across Cities — Boxplots
# =============================================================================
def problem3_air_quality():
    print("Problem 3: Air Quality Boxplots...")
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
    data = [cities_data[c] for c in city_names]

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))

    bp = ax.boxplot(
        data, labels=city_names, patch_artist=True, widths=0.5,
        medianprops=dict(color=SOFT_CHARCOAL, linewidth=2),
        whiskerprops=dict(color=SOFT_CHARCOAL),
        capprops=dict(color=SOFT_CHARCOAL),
        flierprops=dict(
            marker="o", markerfacecolor="gray", markersize=3, alpha=0.4,
        ),
    )

    box_colors = [SAGE_GREEN, STEEL_BLUE, ORANGE, PURPLE, WARNING_RED, "#8b0000"]
    for patch, color in zip(bp["boxes"], box_colors):
        patch.set_facecolor(mcolors.to_rgba(color, alpha=0.55))
        patch.set_edgecolor(color)
        patch.set_linewidth(1.5)

    # WHO annual guideline
    ax.axhline(
        y=15, color=WARNING_RED, linewidth=2, linestyle="--",
        label="WHO Annual Guideline (15 \u03bcg/m\u00b3)",
    )

    ax.set_ylabel("PM$_{2.5}$ Concentration (\u03bcg/m\u00b3)", fontsize=14)
    ax.set_title(
        "Daily PM$_{2.5}$ Concentrations Across Major Cities (1 Year)",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.legend(fontsize=11, loc="upper left")
    ax.set_ylim(0, 220)

    fig.tight_layout()
    save_fig(fig, "03_prob3_air_quality.png")


# =============================================================================
# Problem 4: Does Warmer Water Kill Coral?
# SST Anomaly vs Coral Bleaching — Scatter Plot
# =============================================================================
def problem4_coral_bleaching():
    print("Problem 4: Coral Bleaching Scatter...")
    np.random.seed(456)
    n = 80

    sst_anomaly = np.random.uniform(0.2, 3.2, n)
    # Non-linear with threshold near 1.0 C
    bleaching = np.clip(
        -5 + 20 * sst_anomaly + 8 * sst_anomaly**2 + np.random.normal(0, 8, n),
        0, 100,
    )

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))

    scatter = ax.scatter(
        sst_anomaly, bleaching, c=bleaching, cmap="YlOrRd",
        s=65, alpha=0.8, edgecolor="white", linewidth=0.5, vmin=0, vmax=100,
    )

    # Polynomial fit
    z = np.polyfit(sst_anomaly, bleaching, 2)
    p = np.poly1d(z)
    x_fit = np.linspace(0.2, 3.2, 100)
    ax.plot(
        x_fit, np.clip(p(x_fit), 0, 100),
        color=SAGE_GREEN, linewidth=2.5, label="Quadratic fit",
    )

    ax.axvline(
        x=1.0, color=WARNING_RED, linewidth=1.5, linestyle=":",
        label="Bleaching threshold (~1\u00b0C)", alpha=0.8,
    )

    plt.colorbar(scatter, ax=ax, label="Bleaching (%)", shrink=0.8)
    ax.set_xlabel("Sea Surface Temperature Anomaly (\u00b0C)", fontsize=14)
    ax.set_ylabel("Coral Bleaching (%)", fontsize=14)
    ax.set_title(
        "Coral Bleaching vs. Sea Surface Temperature Anomaly",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.legend(fontsize=11, loc="upper left")

    fig.tight_layout()
    save_fig(fig, "03_prob4_coral_bleaching.png")


# =============================================================================
# Problem 5: How Fast Are We Losing the Amazon?
# Annual Deforestation Rates — Bar Chart
# =============================================================================
def problem5_deforestation():
    print("Problem 5: Amazon Deforestation...")
    years = np.arange(1990, 2025)

    # Approximate real deforestation rates (km^2/year)
    rates = np.array([
        13730, 11030, 13786, 14896, 14896, 29059, 18161, 13227, 17383, 17259,
        18226, 18165, 21651, 25396, 27772, 19014, 14286, 11651, 12911, 7464,
        7000, 6418, 4571, 5891, 5012, 6207, 7893, 6947, 7536, 10129,
        11088, 13235, 11568, 9001, 8590,
    ])

    # Color by policy era
    colors = []
    for y in years:
        if y < 2004:
            colors.append(WARNING_RED)
        elif y < 2012:
            colors.append(SAGE_GREEN)
        elif y < 2019:
            colors.append(STEEL_BLUE)
        else:
            colors.append(ORANGE)

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))
    ax.bar(years, rates / 1000, color=colors, width=0.8, edgecolor="white", alpha=0.85)

    ax.set_xlabel("Year", fontsize=14)
    ax.set_ylabel("Deforestation (thousands km\u00b2/year)", fontsize=14)
    ax.set_title(
        "Annual Deforestation in the Brazilian Amazon (1990\u20132024)",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )

    # Era annotations
    ax.annotate(
        "Pre-policy", xy=(1997, 28), fontsize=10,
        color=WARNING_RED, ha="center", style="italic",
    )
    ax.annotate(
        "PPCDAm\nAction Plan", xy=(2008, 4), fontsize=10,
        color=SAGE_GREEN, ha="center", style="italic",
    )
    ax.annotate(
        "Policy\nweakening", xy=(2021.5, 14.5), fontsize=10,
        color=ORANGE, ha="center", style="italic",
    )

    ax.set_xlim(1989, 2025.5)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    fig.tight_layout()
    save_fig(fig, "03_prob5_deforestation.png")


# =============================================================================
# Problem 6: Can We Compare Climate Indicators That Use Different Units?
# Z-Score Standardized Overlay of 4 Climate Indicators
# =============================================================================
def problem6_climate_indicators():
    print("Problem 6: Standardized Climate Indicators...")
    np.random.seed(101)
    years = np.arange(1960, 2025)
    n = len(years)

    # Same data as the raw figure
    temp = np.zeros(n, dtype=float)
    for i, y in enumerate(years):
        if y < 1980:
            temp[i] = -0.1 + 0.005 * (y - 1960)
        else:
            temp[i] = 0.0 + 0.025 * (y - 1980)
    temp += np.random.normal(0, 0.05, n)

    co2 = 315 + 1.5 * (years - 1960) + 0.02 * (years - 1960) ** 2
    co2 += np.random.normal(0, 0.3, n)

    sea_level = 0.5 * (years - 1960) + 0.015 * (years - 1960) ** 2
    sea_level += np.random.normal(0, 1.5, n)

    ice = 7.5 - 0.03 * (years - 1960) - 0.0005 * (years - 1960) ** 2
    ice += np.random.normal(0, 0.15, n)

    indicators = {
        "Temperature Anomaly": temp,
        "CO\u2082 Concentration": co2,
        "Sea Level Rise": sea_level,
        "Arctic Sea Ice": ice,
    }
    colors = [SAGE_GREEN, STEEL_BLUE, ORANGE, PURPLE]

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))

    for (name, data), color in zip(indicators.items(), colors):
        # Z-score standardize: subtract mean, divide by std
        z = (data - np.mean(data)) / np.std(data)
        ax.plot(years, z, color=color, linewidth=2, label=name)

    ax.axhline(y=0, color=SOFT_CHARCOAL, linewidth=1, linestyle="--", alpha=0.5)
    ax.set_xlabel("Year", fontsize=14)
    ax.set_ylabel("Standardized Value (z-score)", fontsize=14)
    ax.set_title(
        "Climate Indicators \u2014 Z-Score Standardized (1960\u20132024)",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.legend(fontsize=10, loc="upper left")
    ax.set_xlim(1959, 2025)

    fig.tight_layout()
    save_fig(fig, "03_prob6_climate_indicators.png")


# =============================================================================
# Problem 7: Does Agriculture Pollute Our Waterways?
# Nitrogen vs Agricultural Land — Multi-Variable Scatter
# =============================================================================
def problem7_agriculture_water():
    print("Problem 7: Agriculture & Water Quality...")
    np.random.seed(202)
    n = 60

    ag_pct = np.random.uniform(5, 90, n)
    urban_pct = np.random.uniform(2, 45, n)
    watershed_area = np.random.uniform(50, 500, n)

    # Nitrogen depends on agriculture and urban cover
    nitrogen = (
        0.5
        + 0.07 * ag_pct
        + 0.001 * ag_pct**2
        + 0.03 * urban_pct
        + np.random.normal(0, 1.0, n)
    )
    nitrogen = np.clip(nitrogen, 0.1, None)

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))

    scatter = ax.scatter(
        ag_pct, nitrogen, c=urban_pct, s=watershed_area / 4,
        cmap="YlGnBu", alpha=0.75, edgecolor="white", linewidth=0.5,
    )

    # Trend
    z = np.polyfit(ag_pct, nitrogen, 2)
    p = np.poly1d(z)
    x_fit = np.linspace(5, 90, 100)
    ax.plot(
        x_fit, p(x_fit), color=WARNING_RED, linewidth=2,
        linestyle="--", label="Trend (quadratic)",
    )

    # EPA drinking water limit
    ax.axhline(
        y=10, color=WARNING_RED, linewidth=1.5, linestyle=":",
        alpha=0.7, label="EPA limit (10 mg/L)",
    )

    plt.colorbar(scatter, ax=ax, label="Urban Land Cover (%)", shrink=0.8)
    ax.set_xlabel("Agricultural Land Cover (%)", fontsize=14)
    ax.set_ylabel("Nitrate-N Concentration (mg/L)", fontsize=14)
    ax.set_title(
        "Agricultural Land Use vs. Stream Nitrate Concentration",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )
    ax.legend(fontsize=11, loc="upper left")
    ax.text(
        0.98, 0.02, "Point size = watershed area",
        transform=ax.transAxes, fontsize=9, ha="right", va="bottom",
        color="gray", style="italic",
    )

    fig.tight_layout()
    save_fig(fig, "03_prob7_agriculture_water.png")


# =============================================================================
# Problem 8: Are Droughts Getting Worse?
# Palmer Drought Severity Index — Heatmap
# =============================================================================
def problem8_drought():
    print("Problem 8: Drought Heatmap...")
    np.random.seed(303)

    regions = [
        "Southwest US", "Great Plains", "Southeast US",
        "Mediterranean", "East Africa", "Central Asia",
    ]
    years = np.arange(1990, 2025)
    n_regions = len(regions)
    n_years = len(years)

    # Base random field
    data = np.random.normal(0, 1.0, (n_regions, n_years))

    # Add drying trends to specific regions
    data[0, :] -= np.linspace(0, 2.2, n_years)  # Southwest US
    data[3, :] -= np.linspace(0, 1.8, n_years)  # Mediterranean
    data[4, :] -= np.linspace(0, 1.5, n_years)  # East Africa

    # Great Plains: cyclical pattern
    data[1, :] += np.sin(np.linspace(0, 4 * np.pi, n_years)) * 1.3

    data = np.clip(data, -4, 4)

    fig, ax = plt.subplots(figsize=(FIG_WIDTH, FIG_HEIGHT))

    cmap = plt.cm.BrBG  # Brown (drought) to green (wet)
    im = ax.imshow(data, aspect="auto", cmap=cmap, vmin=-4, vmax=4, interpolation="nearest")

    ax.set_yticks(range(n_regions))
    ax.set_yticklabels(regions, fontsize=11)

    tick_positions = np.arange(0, n_years, 5)
    ax.set_xticks(tick_positions)
    ax.set_xticklabels(years[tick_positions], fontsize=10)
    ax.set_xlabel("Year", fontsize=14)

    ax.set_title(
        "Palmer Drought Severity Index by Region (1990\u20132024)",
        fontsize=15, fontweight="bold", color=SAGE_GREEN,
    )

    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label("PDSI  (\u2190 Drought  |  Wet \u2192)", fontsize=12)

    fig.tight_layout()
    save_fig(fig, "03_prob8_drought.png")


# =============================================================================
# Run all problems
# =============================================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Generating figures for Lecture 3:")
    print("Data Visualization and Interpretation")
    print("=" * 60)
    problem1_temperature()
    problem2_emissions()
    problem3_air_quality()
    problem4_coral_bleaching()
    problem5_deforestation()
    problem6_climate_indicators()
    problem7_agriculture_water()
    problem8_drought()
    print("=" * 60)
    print("All 8 figures generated successfully!")
