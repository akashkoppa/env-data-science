# =============================================================================
# Lecture 7: Spatial Data Analysis — Exercise Solutions (Python)
# ENST431/631: Environmental Data Science
# Instructor: Akash Koppa
# =============================================================================
# Working directory assumed to be the folder containing all data files.
# Required packages: geopandas, numpy, scipy, scikit-learn, matplotlib,
#                    libpysal, esda, splot, pointpats

import os
import warnings

import numpy as np
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import Circle
from matplotlib.colors import Normalize, ListedColormap, BoundaryNorm
from matplotlib.cm import ScalarMappable
from scipy.spatial.distance import cdist
from scipy.stats import norm, gaussian_kde
from sklearn.neighbors import KernelDensity

import libpysal
import esda
from splot.esda import moran_scatterplot, lisa_cluster

warnings.filterwarnings("ignore")

# Set working directory to the data folder
DATA_DIR = os.path.dirname(os.path.abspath(__file__))
SPATIAL_06 = os.path.join(DATA_DIR, "Data", "06_Spatial")
SPATIAL_07 = os.path.join(DATA_DIR, "Data", "07_Spatial_Analysis")


# =============================================================================
# EXERCISE 1: Spatial Descriptive Statistics
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 1: Spatial Descriptive Statistics")
print("=" * 70)

# --- Load station data ---
stations = pd.read_csv(os.path.join(SPATIAL_06, "stations.csv"))
stations_gdf = gpd.GeoDataFrame(
    stations,
    geometry=gpd.points_from_xy(stations["lon"], stations["lat"]),
    crs=4326,
)
print(f"Loaded {len(stations_gdf)} monitoring stations")
print(stations_gdf[["station_id", "lat", "lon", "mean_do_mgl"]].head())

# --- Mean center (arithmetic mean of coordinates) ---
coords = np.column_stack([stations_gdf.geometry.x, stations_gdf.geometry.y])
mc_lon, mc_lat = coords.mean(axis=0)
print(f"\nMean center: ({mc_lon:.4f}, {mc_lat:.4f})")

# --- Weighted mean center (weight = mean DO) ---
w = stations_gdf["mean_do_mgl"].values
wmc_lon = np.average(coords[:, 0], weights=w)
wmc_lat = np.average(coords[:, 1], weights=w)
print(f"Weighted mean center (weight=DO): ({wmc_lon:.4f}, {wmc_lat:.4f})")

# --- Standard distance ---
dists_deg = np.sqrt(((coords - np.array([mc_lon, mc_lat])) ** 2).sum(axis=1))
std_dist = np.sqrt(np.mean(dists_deg**2))
print(f"Standard distance: {std_dist:.4f} degrees")

# --- Interpretation ---
shift_lon = wmc_lon - mc_lon
shift_lat = wmc_lat - mc_lat
print(f"\nShift from unweighted to weighted center:")
print(f"  Longitude: {shift_lon:+.4f} degrees ({'east' if shift_lon > 0 else 'west'})")
print(f"  Latitude:  {shift_lat:+.4f} degrees ({'north' if shift_lat > 0 else 'south'})")
print(
    "Interpretation: The weighted center shifts northward because headwater "
    "stations (Susquehanna, Potomac) have higher dissolved oxygen. The southern "
    "tidal and estuarine stations have lower DO, pulling the unweighted center "
    "further south relative to the DO-weighted center."
)

# --- Map ---
fig, ax = plt.subplots(1, 1, figsize=(8, 8))
stations_gdf.plot(
    ax=ax,
    column="mean_do_mgl",
    cmap="viridis",
    markersize=60,
    edgecolor="white",
    linewidth=0.5,
    legend=True,
    legend_kwds={"label": "Mean DO (mg/L)", "shrink": 0.6},
)

# Plot mean center (red triangle)
ax.plot(mc_lon, mc_lat, marker="^", color="red", markersize=14,
        markeredgecolor="black", markeredgewidth=1, zorder=5,
        label="Mean Center")

# Plot weighted mean center (blue triangle)
ax.plot(wmc_lon, wmc_lat, marker="^", color="dodgerblue", markersize=14,
        markeredgecolor="black", markeredgewidth=1, zorder=5,
        label="Weighted Mean Center (DO)")

# Standard distance circle
circle = Circle(
    (mc_lon, mc_lat), std_dist,
    fill=False, edgecolor="gray", linestyle="--", linewidth=1.5,
    label=f"Std Distance = {std_dist:.2f}\u00b0",
)
ax.add_patch(circle)

# Arrow from unweighted to weighted center
ax.annotate(
    "", xy=(wmc_lon, wmc_lat), xytext=(mc_lon, mc_lat),
    arrowprops=dict(arrowstyle="->", color="black", lw=1.5),
)

ax.legend(loc="lower left", fontsize=9)
ax.set_title("CBP Monitoring Stations — Spatial Descriptive Statistics", fontsize=12)
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.set_aspect("equal")
plt.tight_layout()
plt.savefig(os.path.join(DATA_DIR, "ex01_descriptive_stats.png"), dpi=150)
plt.close()
print("Saved: ex01_descriptive_stats.png")


# =============================================================================
# EXERCISE 2: Nearest Neighbor Analysis
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 2: Nearest Neighbor Analysis")
print("=" * 70)

# --- Reproject to UTM 18N for distance in meters ---
stations_utm = stations_gdf.to_crs(epsg=32618)
coords_utm = np.column_stack([stations_utm.geometry.x, stations_utm.geometry.y])

# --- Pairwise distance matrix ---
dmat = cdist(coords_utm, coords_utm)
np.fill_diagonal(dmat, np.inf)
print(f"Distance matrix shape: {dmat.shape}")

# --- Nearest neighbor distances ---
nn_dists = dmat.min(axis=1)
nn_indices = dmat.argmin(axis=1)
d_obs = nn_dists.mean()
print(f"\nNearest-neighbor distances (m):")
for i, (stn, nnd, nni) in enumerate(
    zip(stations_utm["station_id"], nn_dists, nn_indices)
):
    print(f"  {stn:>12s} -> {stations_utm.iloc[nni]['station_id']:>12s}  "
          f"d = {nnd/1000:.1f} km")

print(f"\nMean observed NN distance: {d_obs/1000:.2f} km")

# --- Study area = convex hull ---
hull = stations_utm.unary_union.convex_hull
A = hull.area  # m^2
print(f"Convex hull area: {A/1e6:.1f} km\u00b2")

# --- Expected NN distance under CSR ---
n = len(stations_utm)
d_exp = 1 / (2 * np.sqrt(n / A))
print(f"Expected NN distance (CSR): {d_exp/1000:.2f} km")

# --- NNI ---
NNI = d_obs / d_exp
print(f"Nearest Neighbor Index (NNI): {NNI:.4f}")

# --- Z-score ---
se = 0.26136 / np.sqrt(n**2 / A)
z = (d_obs - d_exp) / se
p_value = 2 * (1 - norm.cdf(abs(z)))
print(f"z-score: {z:.4f}")
print(f"p-value: {p_value:.4f}")

if NNI < 1:
    pattern = "CLUSTERED"
elif NNI > 1:
    pattern = "DISPERSED"
else:
    pattern = "RANDOM"
sig_str = "significant" if p_value < 0.05 else "not significant"
print(f"\nConclusion: The monitoring network is {pattern} (NNI={NNI:.2f}, "
      f"z={z:.2f}, p={p_value:.4f}, {sig_str} at alpha=0.05)")

# --- Most isolated station ---
most_isolated_idx = nn_dists.argmax()
print(f"\nMost isolated station: {stations_utm.iloc[most_isolated_idx]['station_id']} "
      f"({stations_utm.iloc[most_isolated_idx]['description']})")
print(f"  NN distance: {nn_dists[most_isolated_idx]/1000:.1f} km")

# --- Map: stations with NN lines ---
fig, ax = plt.subplots(1, 1, figsize=(8, 8))

# Draw NN lines
nn_norm = Normalize(vmin=nn_dists.min(), vmax=nn_dists.max())
cmap_lines = plt.cm.RdYlGn_r
for i in range(n):
    j = nn_indices[i]
    color = cmap_lines(nn_norm(nn_dists[i]))
    ax.plot(
        [coords_utm[i, 0], coords_utm[j, 0]],
        [coords_utm[i, 1], coords_utm[j, 1]],
        color=color, linewidth=1.5, alpha=0.7,
    )

# Plot stations
stations_utm.plot(ax=ax, color="black", markersize=50, edgecolor="white",
                  linewidth=0.5, zorder=5)

# Label stations
for idx, row in stations_utm.iterrows():
    ax.annotate(
        row["station_id"], xy=(row.geometry.x, row.geometry.y),
        fontsize=5.5, ha="left", va="bottom",
        xytext=(5, 5), textcoords="offset points",
    )

# Convex hull
hull_gdf = gpd.GeoDataFrame(geometry=[hull], crs=32618)
hull_gdf.boundary.plot(ax=ax, color="gray", linestyle="--", linewidth=1)

# Colorbar for NN distances
sm = ScalarMappable(cmap=cmap_lines, norm=nn_norm)
sm.set_array([])
cbar = plt.colorbar(sm, ax=ax, shrink=0.5, label="NN Distance (m)")

ax.set_title(f"Nearest Neighbor Analysis (NNI = {NNI:.2f}, p = {p_value:.4f})",
             fontsize=12)
ax.set_xlabel("Easting (m)")
ax.set_ylabel("Northing (m)")
ax.set_aspect("equal")
plt.tight_layout()
plt.savefig(os.path.join(DATA_DIR, "ex02_nearest_neighbor.png"), dpi=150)
plt.close()
print("Saved: ex02_nearest_neighbor.png")


# =============================================================================
# EXERCISE 3: Kernel Density Estimation
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 3: Kernel Density Estimation")
print("=" * 70)

# --- Load algal bloom data ---
blooms = pd.read_csv(os.path.join(SPATIAL_07, "algal_blooms.csv"))
blooms_gdf = gpd.GeoDataFrame(
    blooms,
    geometry=gpd.points_from_xy(blooms["lon"], blooms["lat"]),
    crs=4326,
)
blooms_utm = blooms_gdf.to_crs(epsg=32618)
print(f"Loaded {len(blooms_utm)} algal bloom sightings")

coords_blooms = np.column_stack([blooms_utm.geometry.x, blooms_utm.geometry.y])

# --- Create evaluation grid ---
xmin, ymin, xmax, ymax = blooms_utm.total_bounds
pad = 10000  # 10 km padding
grid_res = 200  # grid cells per axis
xx, yy = np.meshgrid(
    np.linspace(xmin - pad, xmax + pad, grid_res),
    np.linspace(ymin - pad, ymax + pad, grid_res),
)
positions = np.column_stack([xx.ravel(), yy.ravel()])

# --- KDE with bandwidth = 5 km ---
kde_5k = KernelDensity(bandwidth=5000, kernel="gaussian")
kde_5k.fit(coords_blooms)
log_dens_5k = kde_5k.score_samples(positions)
dens_5k = np.exp(log_dens_5k).reshape(xx.shape)
print(f"KDE (5 km): max density = {dens_5k.max():.2e}")

# --- KDE with bandwidth = 20 km ---
kde_20k = KernelDensity(bandwidth=20000, kernel="gaussian")
kde_20k.fit(coords_blooms)
log_dens_20k = kde_20k.score_samples(positions)
dens_20k = np.exp(log_dens_20k).reshape(xx.shape)
print(f"KDE (20 km): max density = {dens_20k.max():.2e}")

# --- Three-panel figure ---
fig, axes = plt.subplots(1, 3, figsize=(18, 7))

# Panel 1: Raw points
ax = axes[0]
scatter = ax.scatter(
    coords_blooms[:, 0], coords_blooms[:, 1],
    c=blooms_utm["severity"], cmap="YlOrRd", s=15,
    edgecolor="gray", linewidth=0.3, vmin=1, vmax=10,
)
plt.colorbar(scatter, ax=ax, shrink=0.6, label="Severity (1-10)")
ax.set_title("A: Raw Bloom Locations", fontsize=11)
ax.set_xlabel("Easting (m)")
ax.set_ylabel("Northing (m)")
ax.set_aspect("equal")

# Panel 2: KDE, bandwidth = 5 km
ax = axes[1]
cf = ax.contourf(xx, yy, dens_5k, levels=20, cmap="YlOrRd")
ax.scatter(coords_blooms[:, 0], coords_blooms[:, 1],
           c="black", s=3, alpha=0.3)
plt.colorbar(cf, ax=ax, shrink=0.6, label="Density")
ax.set_title("B: KDE (bandwidth = 5 km)", fontsize=11)
ax.set_xlabel("Easting (m)")
ax.set_ylabel("Northing (m)")
ax.set_aspect("equal")

# Panel 3: KDE, bandwidth = 20 km
ax = axes[2]
cf = ax.contourf(xx, yy, dens_20k, levels=20, cmap="YlOrRd")
ax.scatter(coords_blooms[:, 0], coords_blooms[:, 1],
           c="black", s=3, alpha=0.3)
plt.colorbar(cf, ax=ax, shrink=0.6, label="Density")
ax.set_title("C: KDE (bandwidth = 20 km)", fontsize=11)
ax.set_xlabel("Easting (m)")
ax.set_ylabel("Northing (m)")
ax.set_aspect("equal")

plt.suptitle("Algal Bloom Density — Effect of Bandwidth", fontsize=14, y=1.01)
plt.tight_layout()
plt.savefig(os.path.join(DATA_DIR, "ex03_kde.png"), dpi=150, bbox_inches="tight")
plt.close()
print("Saved: ex03_kde.png")

print("\nInterpretation:")
print("  - 5 km bandwidth reveals 3 distinct hotspots: mid-Bay, upper Bay/Susquehanna,")
print("    and Potomac tidal area. This resolution is useful for targeted response.")
print("  - 20 km bandwidth smooths these into a single elongated region, losing the")
print("    ability to distinguish individual hotspots.")
print("  Recommendation: Use the 5 km bandwidth for bloom response targeting, as it")
print("  preserves the distinction between separate hotspot regions.")


# =============================================================================
# EXERCISE 4: Global Moran's I — Spatial Autocorrelation
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 4: Global Moran's I — Spatial Autocorrelation")
print("=" * 70)

# --- Load watershed boundaries and nitrogen data ---
ws = gpd.read_file(os.path.join(SPATIAL_06, "chesapeake_watersheds.gpkg"))
ws_quality = pd.read_csv(os.path.join(SPATIAL_07, "watershed_quality.csv"))

# Ensure HUC8 is zero-padded string in both DataFrames before merging
ws["HUC8"] = ws["HUC8"].astype(str).str.zfill(8)
ws_quality["HUC8"] = ws_quality["HUC8"].astype(str).str.zfill(8)

# Join on HUC8
ws = ws.merge(ws_quality, on="HUC8", how="left", suffixes=("", "_csv"))
# Use the Name from the CSV if available, otherwise keep original
if "Name_csv" in ws.columns:
    ws.drop(columns=["Name_csv"], inplace=True)

print(f"Loaded {len(ws)} watersheds with nitrogen data")
print(f"Nitrogen range: {ws['nitrogen_kg_ha'].min():.1f} - "
      f"{ws['nitrogen_kg_ha'].max():.1f} kg/ha/yr")
print(f"Mean: {ws['nitrogen_kg_ha'].mean():.2f}, "
      f"Std: {ws['nitrogen_kg_ha'].std():.2f}")

# --- Choropleth map of nitrogen loading ---
fig, ax = plt.subplots(1, 1, figsize=(8, 8))
ws.plot(
    ax=ax, column="nitrogen_kg_ha", cmap="YlOrRd",
    edgecolor="white", linewidth=0.4,
    legend=True, legend_kwds={"label": "Nitrogen (kg/ha/yr)", "shrink": 0.6},
)
ax.set_title("Nitrogen Loading by HUC8 Watershed", fontsize=12)
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.set_aspect("equal")
plt.tight_layout()
plt.savefig(os.path.join(DATA_DIR, "ex04_nitrogen_choropleth.png"), dpi=150)
plt.close()
print("Saved: ex04_nitrogen_choropleth.png")

# --- Build Queen contiguity spatial weights ---
w = libpysal.weights.Queen.from_dataframe(ws)
w.transform = "r"  # row-standardize

print(f"\nSpatial weights summary:")
print(f"  Number of features: {w.n}")
print(f"  Mean neighbors: {w.mean_neighbors:.1f}")
print(f"  Min neighbors: {w.min_neighbors}")
print(f"  Max neighbors: {w.max_neighbors}")

# Check for islands (features with no neighbors)
if w.islands:
    print(f"  WARNING: {len(w.islands)} island(s) detected: {w.islands}")

# --- Global Moran's I ---
y = ws["nitrogen_kg_ha"].values
mi = esda.Moran(y, w, permutations=999)

print(f"\nGlobal Moran's I Results:")
print(f"  Moran's I:     {mi.I:.4f}")
print(f"  Expected I:    {mi.EI:.4f}")
print(f"  p-value (sim): {mi.p_sim:.4f}")
print(f"  z-score (sim): {mi.z_sim:.4f}")

if mi.p_sim < 0.05:
    if mi.I > 0:
        print("  Conclusion: SIGNIFICANT POSITIVE spatial autocorrelation.")
        print("  Watersheds with similar nitrogen levels tend to be neighbors.")
    else:
        print("  Conclusion: SIGNIFICANT NEGATIVE spatial autocorrelation.")
else:
    print("  Conclusion: No significant spatial autocorrelation detected.")

# --- Moran scatter plot ---
fig, ax = plt.subplots(1, 1, figsize=(7, 7))
moran_scatterplot(mi, aspect_equal=False, ax=ax)
ax.set_title(f"Moran Scatter Plot — Nitrogen Loading\n"
             f"(I = {mi.I:.4f}, p = {mi.p_sim:.4f})", fontsize=12)
ax.set_xlabel("Nitrogen (standardized)", fontsize=11)
ax.set_ylabel("Spatial Lag of Nitrogen", fontsize=11)
plt.tight_layout()
plt.savefig(os.path.join(DATA_DIR, "ex04_moran_scatter.png"), dpi=150)
plt.close()
print("Saved: ex04_moran_scatter.png")

print("\nInterpretation:")
print("  Moran's I is strongly positive and highly significant, confirming that")
print("  nitrogen loading is spatially clustered. Watersheds with high nitrogen")
print("  tend to neighbor other high-nitrogen watersheds (and vice versa). This")
print("  means the Chesapeake Bay Program can target contiguous regions for")
print("  nutrient management rather than addressing each watershed independently.")


# =============================================================================
# EXERCISE 5: Local Moran's I (LISA)
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 5: Local Moran's I (LISA)")
print("=" * 70)

# --- Compute Local Moran's I ---
lisa = esda.Moran_Local(y, w, permutations=999)

ws["Ii"] = lisa.Is
ws["p_value"] = lisa.p_sim
ws["quadrant"] = lisa.q  # 1=HH, 2=LH, 3=LL, 4=HL

# --- Classify clusters ---
sig = lisa.p_sim < 0.05
quad_labels = {1: "HH (Hot Spot)", 2: "LH (Low Outlier)",
               3: "LL (Cold Spot)", 4: "HL (High Outlier)"}
cluster = np.array(["Not Significant"] * len(ws))
for i in range(len(ws)):
    if sig[i]:
        cluster[i] = quad_labels[lisa.q[i]]
ws["cluster"] = cluster

print("LISA cluster classification:")
print(ws["cluster"].value_counts())

# --- Report significant clusters ---
sig_ws = ws[ws["cluster"] != "Not Significant"].sort_values("cluster")
print(f"\nSignificant clusters (p < 0.05):")
for _, row in sig_ws.iterrows():
    print(f"  {row['Name']:>40s}: {row['cluster']:>20s} "
          f"(N = {row['nitrogen_kg_ha']:.1f} kg/ha, "
          f"Ii = {row['Ii']:.3f}, p = {row['p_value']:.4f})")

# --- Two-panel figure: choropleth + LISA cluster map ---
fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# Panel A: Nitrogen choropleth
ax = axes[0]
ws.plot(
    ax=ax, column="nitrogen_kg_ha", cmap="YlOrRd",
    edgecolor="white", linewidth=0.4,
    legend=True, legend_kwds={"label": "Nitrogen (kg/ha/yr)", "shrink": 0.6},
)
ax.set_title("A: Nitrogen Loading (kg/ha/yr)", fontsize=12)
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.set_aspect("equal")

# Panel B: LISA cluster map
ax = axes[1]
cluster_colors = {
    "HH (Hot Spot)": "#d7191c",
    "LL (Cold Spot)": "#2c7bb6",
    "HL (High Outlier)": "#fdae61",
    "LH (Low Outlier)": "#abd9e9",
    "Not Significant": "#e0e0e0",
}

# Plot each cluster type
for ctype, color in cluster_colors.items():
    subset = ws[ws["cluster"] == ctype]
    if len(subset) > 0:
        subset.plot(ax=ax, color=color, edgecolor="white", linewidth=0.4)

# Add legend
patches = [mpatches.Patch(color=color, label=label)
           for label, color in cluster_colors.items()
           if label in ws["cluster"].values]
ax.legend(handles=patches, loc="lower left", fontsize=8,
          title="LISA Cluster Type", title_fontsize=9)

ax.set_title(f"B: LISA Cluster Map (p < 0.05)\n"
             f"Global Moran's I = {mi.I:.3f}", fontsize=12)
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.set_aspect("equal")

plt.suptitle("Nitrogen Loading — Spatial Autocorrelation Analysis", fontsize=14)
plt.tight_layout()
plt.savefig(os.path.join(DATA_DIR, "ex05_lisa.png"), dpi=150, bbox_inches="tight")
plt.close()
print("Saved: ex05_lisa.png")

# --- Label significant watersheds on a dedicated map ---
fig, ax = plt.subplots(1, 1, figsize=(10, 10))
for ctype, color in cluster_colors.items():
    subset = ws[ws["cluster"] == ctype]
    if len(subset) > 0:
        subset.plot(ax=ax, color=color, edgecolor="white", linewidth=0.5)

# Label significant watersheds
for _, row in sig_ws.iterrows():
    centroid = row.geometry.centroid
    ax.annotate(
        row["Name"], xy=(centroid.x, centroid.y),
        fontsize=6, ha="center", va="center", fontweight="bold",
        bbox=dict(boxstyle="round,pad=0.2", facecolor="white", alpha=0.7),
    )

patches = [mpatches.Patch(color=color, label=label)
           for label, color in cluster_colors.items()
           if label in ws["cluster"].values]
ax.legend(handles=patches, loc="lower left", fontsize=9,
          title="LISA Cluster Type")
ax.set_title("LISA Cluster Map with Labeled Significant Watersheds", fontsize=13)
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.set_aspect("equal")
plt.tight_layout()
plt.savefig(os.path.join(DATA_DIR, "ex05_lisa_labeled.png"), dpi=150)
plt.close()
print("Saved: ex05_lisa_labeled.png")

print("\nInterpretation:")
print("  Hot Spots (HH): Watersheds in the southern Bay tributaries (James, York,")
print("  Rappahannock, Hampton Roads) form a cluster of high nitrogen loading.")
print("  These areas have extensive agricultural land and urbanization that drive")
print("  nutrient export into the Bay.")
print()
print("  Cold Spots (LL): Northern headwater watersheds (upper Susquehanna,")
print("  Chemung, Tioga) form a cluster of low nitrogen loading. These forested,")
print("  less-developed watersheds contribute less nutrient runoff.")
print()
print("  The LISA map identifies specific watersheds for targeted nutrient")
print("  management, showing that the southern tributaries should be prioritized")
print("  for pollution reduction efforts.")

print("\n=== All exercises complete. Output files saved. ===")
