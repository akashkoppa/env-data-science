# =============================================================================
# Lecture 5: Spatial Data and Mapping — Exercise Solutions (Python)
# ENST431/631: Environmental Data Science
# Instructor: Akash Koppa
# =============================================================================
# Working directory assumed to be the folder containing all data files.

import os
import warnings
import tempfile

import numpy as np
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.colors as mcolors
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize, BoundaryNorm, ListedColormap

import rasterio
from rasterio.transform import from_bounds
import rasterio.features

import xarray as xr
from pyproj import Geod

from rasterstats import zonal_stats

warnings.filterwarnings("ignore")


# =============================================================================
# EXERCISE 1: Loading Point Data from a CSV File
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 1: Loading Point Data from a CSV File")
print("=" * 70)

# --- Load the CSV with pandas ---
stations = pd.read_csv("stations.csv")
print(f"\nShape: {stations.shape[0]} rows, {stations.shape[1]} columns")
print("\nColumn names and dtypes:")
print(stations.dtypes)
print("\nFirst 5 rows:")
print(stations.head())

# --- Check for missing coordinates ---
missing_coords = stations[["lat", "lon"]].isna().sum()
print(f"\nMissing lat/lon values: {missing_coords.to_dict()}")

# --- Convert to GeoDataFrame ---
# A plain CSV with lat/lon columns cannot participate in spatial operations:
# no geometry, no CRS.  gpd.points_from_xy() creates Point geometry objects.
# We assign EPSG:4326 (WGS84 geographic, units = decimal degrees).
stations_gdf = gpd.GeoDataFrame(
    stations,
    geometry=gpd.points_from_xy(stations["lon"], stations["lat"]),
    crs="EPSG:4326"
)

print(f"\nCRS: {stations_gdf.crs}")
print(f"Bounding box (xmin, ymin, xmax, ymax): {stations_gdf.total_bounds.round(4)}")

# --- Identify the 3 stations with lowest mean DO ---
lowest_do = stations_gdf.nsmallest(3, "mean_do_mgl")[["station_id", "description", "mean_do_mgl"]]
print("\n3 stations with lowest mean dissolved oxygen:")
print(lowest_do.to_string(index=False))

# --- Map: all stations colored by mean_do_mgl, label the 3 lowest DO ---
fig, ax = plt.subplots(figsize=(9, 7))

# All stations: colored by mean_do_mgl using a sequential palette
sc = stations_gdf.plot(
    column="mean_do_mgl",
    cmap="viridis",
    markersize=60,
    legend=False,
    ax=ax,
    zorder=3
)

# Colorbar
sm = ScalarMappable(cmap="viridis", norm=Normalize(
    vmin=stations_gdf["mean_do_mgl"].min(),
    vmax=stations_gdf["mean_do_mgl"].max()
))
sm.set_array([])
cbar = fig.colorbar(sm, ax=ax, fraction=0.03, pad=0.02)
cbar.set_label("Mean DO (mg/L)", fontsize=10)

# Label the 3 lowest-DO stations
for _, row in lowest_do.iterrows():
    x = row.geometry.x if hasattr(row, "geometry") else None
    # Retrieve geometry from gdf
for _, row in stations_gdf.nsmallest(3, "mean_do_mgl").iterrows():
    ax.annotate(
        f"{row['station_id']}\n({row['mean_do_mgl']:.2f} mg/L)",
        xy=(row.geometry.x, row.geometry.y),
        xytext=(8, 8),
        textcoords="offset points",
        fontsize=7,
        color="darkred",
        arrowprops=dict(arrowstyle="-", color="darkred", lw=0.8),
    )

ax.set_title("CBP Water Quality Monitoring Stations\nColored by Mean Dissolved Oxygen (mg/L)",
             fontsize=12, fontweight="bold")
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.grid(True, linestyle="--", linewidth=0.4, alpha=0.6)
plt.tight_layout()
plt.savefig("ex01_stations.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex01_stations.png")

# --- Part B: Station Time Series ---
# Find the station with the lowest mean DO
low_do_id = stations_gdf.loc[stations_gdf['mean_do_mgl'].idxmin(), 'station_id']
print(f"\nLowest mean DO station: {low_do_id}")

# Load its time series (filename uses hyphens for slashes in station IDs)
ts_fname = low_do_id.replace('/', '-') + '.csv'
ts_data = pd.read_csv(f"station_data/{ts_fname}", parse_dates=['date'])
print(ts_data.head())
print(f"Date range: {ts_data['date'].min()} to {ts_data['date'].max()}")
print(f"Mean DO: {ts_data['do_mgl'].mean():.2f} mg/L  |  Mean Temp: {ts_data['wtemp_c'].mean():.1f} °C")

# Dual y-axis time series plot
fig, ax1 = plt.subplots(figsize=(11, 4))
ax1.plot(ts_data['date'], ts_data['do_mgl'], color='steelblue', linewidth=1.5, label='DO (mg/L)')
ax1.set_ylabel('Dissolved Oxygen (mg/L)', color='steelblue', fontsize=11)
ax1.tick_params(axis='y', labelcolor='steelblue')
ax1.set_xlabel('Date')

ax2 = ax1.twinx()
ax2.plot(ts_data['date'], ts_data['wtemp_c'], color='tomato', linewidth=1.5, label='Temperature (°C)')
ax2.set_ylabel('Water Temperature (°C)', color='tomato', fontsize=11)
ax2.tick_params(axis='y', labelcolor='tomato')

ax1.set_title(f'Station {low_do_id}: Dissolved Oxygen and Water Temperature (2015-2022)', fontsize=12)
lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, loc='upper right')
plt.tight_layout()
plt.savefig('ex01b_timeseries.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: ex01b_timeseries.png")
# Note: DO is highest in winter (cold water holds more oxygen) and lowest in summer.
# The inverse relationship with temperature drives summer hypoxia risk in the Bay.


# =============================================================================
# EXERCISE 2: Loading Polygon Data — Watershed Boundaries
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 2: Loading Polygon Data — Watershed Boundaries")
print("=" * 70)

# --- Load the GeoPackage ---
# A GeoPackage (.gpkg) is a single-file, SQLite-based container.
# Advantages over Shapefile: no 4 GB size limit, no attribute-name truncation,
# stores multiple layers in one file.
ws = gpd.read_file("chesapeake_watersheds.gpkg",
                   layer="chesapeake_watersheds")

print(f"\nShape: {ws.shape[0]} features, {ws.shape[1]} columns")
print(f"Columns: {list(ws.columns)}")
print(f"Geometry type(s): {ws.geom_type.unique()}")
print(f"CRS (original): {ws.crs}")

# --- Reproject to UTM Zone 18N (EPSG:32618, units = meters) ---
# Area calculations in geographic degrees are meaningless because the size
# of a degree varies with latitude; 1° longitude ≈ 86 km at 39°N vs 111 km at equator.
ws_proj = ws.to_crs("EPSG:32618")
print(f"CRS after reprojection: {ws_proj.crs}")

# --- Compute area in km² ---
# .area returns values in the CRS native units (here: m²)
ws_proj["area_km2"] = ws_proj.geometry.area / 1e6

print(f"\nArea statistics (km²):")
print(ws_proj["area_km2"].describe().round(1))

largest  = ws_proj.loc[ws_proj["area_km2"].idxmax(), "Name"]
smallest = ws_proj.loc[ws_proj["area_km2"].idxmin(), "Name"]
print(f"\nLargest watershed : {largest} ({ws_proj['area_km2'].max():.0f} km²)")
print(f"Smallest watershed: {smallest} ({ws_proj['area_km2'].min():.0f} km²)")

# --- Choropleth map: watersheds colored by area ---
fig, ax = plt.subplots(figsize=(9, 7))
ws_proj.plot(
    column="area_km2",
    cmap="YlOrRd",
    legend=True,
    legend_kwds={"label": "Area (km²)", "shrink": 0.6},
    edgecolor="gray",
    linewidth=0.5,
    ax=ax
)

# Label watershed names for the largest few to keep the map readable
label_df = ws_proj.nlargest(8, "area_km2")
for _, row in label_df.iterrows():
    cx, cy = row.geometry.centroid.x, row.geometry.centroid.y
    ax.annotate(row["Name"], xy=(cx, cy), ha="center", va="center",
                fontsize=5, color="black", clip_on=True)

ax.set_title("Chesapeake Bay HUC8 Sub-Watersheds\nArea (km²) — UTM Zone 18N",
             fontsize=12, fontweight="bold")
ax.set_xlabel("Easting (m)")
ax.set_ylabel("Northing (m)")
ax.grid(True, linestyle="--", linewidth=0.3, alpha=0.5)
plt.tight_layout()
plt.savefig("ex02_watersheds.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex02_watersheds.png")


# =============================================================================
# EXERCISE 3: Spatial Joins with GeoJSON Data
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 3: Spatial Joins with GeoJSON Data")
print("=" * 70)

# --- Load county boundaries (GeoJSON is a text-based, human-readable format) ---
counties = gpd.read_file("counties_chesapeake.geojson")
print(f"\nCounties shape: {counties.shape[0]} features, {counties.shape[1]} columns")
print(f"Columns: {list(counties.columns)}")
print(f"CRS: {counties.crs}")

# --- Align CRS before joining (both must be identical) ---
# stations_gdf is already EPSG:4326; ensure counties match
counties = counties.to_crs(stations_gdf.crs)
print(f"CRS match: {stations_gdf.crs == counties.crs}")

# --- Spatial join: for each station, find which county contains it ---
# 'how="left"' keeps all stations; 'predicate="within"' tests point-in-polygon.
stations_joined = gpd.sjoin(
    stations_gdf,
    counties[["county_name", "state", "geometry"]],
    how="left",
    predicate="within"
)

print(f"\nJoined table shape: {stations_joined.shape}")
print("\nStation–county assignments:")
print(stations_joined[["station_id", "description", "mean_do_mgl",
                         "county_name", "state"]].to_string(index=False))

# --- Count stations per state ---
print("\nStations per state:")
print(stations_joined["state"].value_counts().to_string())

# --- Counties containing at least one station ---
counties_with_stations = stations_joined["county_name"].dropna().unique()
print(f"\nCounties containing at least one monitoring station ({len(counties_with_stations)}):")
for c in sorted(counties_with_stations):
    print(f"  {c}")

# --- Map: county boundaries + stations colored by mean DO ---
fig, ax = plt.subplots(figsize=(9, 8))
counties.plot(ax=ax, color="none", edgecolor="gray", linewidth=0.5, zorder=1)
stations_joined.plot(
    ax=ax,
    column="mean_do_mgl",
    cmap="viridis",
    markersize=50,
    legend=True,
    legend_kwds={"label": "Mean DO (mg/L)", "shrink": 0.6},
    zorder=3
)

# Label state abbreviations at approximate centroids of state extent
for state, grp in counties.groupby("state"):
    merged_geom = grp.geometry.unary_union
    cx, cy = merged_geom.centroid.x, merged_geom.centroid.y
    ax.annotate(state, xy=(cx, cy), ha="center", va="center",
                fontsize=9, color="black", fontweight="bold",
                bbox=dict(boxstyle="round,pad=0.2", fc="white", alpha=0.6))

ax.set_title("CBP Monitoring Stations by County\nColored by Mean Dissolved Oxygen (mg/L)",
             fontsize=12, fontweight="bold")
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.grid(True, linestyle="--", linewidth=0.3, alpha=0.5)
plt.tight_layout()
plt.savefig("ex03_spatial_join.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex03_spatial_join.png")


# =============================================================================
# EXERCISE 4: Digital Elevation Models — Loading and Classifying GeoTIFF Rasters
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 4: Digital Elevation Models")
print("=" * 70)

dem_path = "chesapeake_dem.tif"

# --- Load the DEM with rasterio ---
with rasterio.open(dem_path) as src:
    dem = src.read(1).astype(float)
    dem_transform = src.transform
    dem_crs       = src.crs
    dem_nodata    = src.nodata
    dem_height    = src.height
    dem_width     = src.width
    dem_res       = src.res
    dem_bounds    = src.bounds

# Replace NoData with NaN
if dem_nodata is not None:
    dem[dem == dem_nodata] = np.nan

total_cells  = dem_height * dem_width
valid_cells  = int(np.sum(~np.isnan(dem)))
nodata_cells = total_cells - valid_cells

print(f"\nDEM metadata:")
print(f"  Rows x Columns  : {dem_height} x {dem_width}")
print(f"  Resolution       : {dem_res[0]:.4f} x {dem_res[1]:.4f} (CRS units)")
print(f"  CRS              : {dem_crs}")
print(f"  Value range      : {np.nanmin(dem):.1f} to {np.nanmax(dem):.1f} m")
print(f"  Total cells      : {total_cells:,}")
print(f"  Valid (non-NaN)  : {valid_cells:,} ({100*valid_cells/total_cells:.1f}%)")
print(f"  NoData cells     : {nodata_cells:,} ({100*nodata_cells/total_cells:.1f}%)")

# --- Reclassify into 3 elevation zones ---
# Low  :   0 – 100 m  (class 1)
# Mid  : 100 – 300 m  (class 2)
# High : > 300 m      (class 3)
dem_class = np.full_like(dem, np.nan)
dem_class[(dem >= 0)   & (dem < 100)] = 1
dem_class[(dem >= 100) & (dem < 300)] = 2
dem_class[dem >= 300]                  = 3

zone_labels = {1: "Low (0–100 m)", 2: "Mid (100–300 m)", 3: "High (>300 m)"}
print("\nElevation zone coverage:")
for zone, label in zone_labels.items():
    n = int(np.nansum(dem_class == zone))
    pct = n / valid_cells * 100
    print(f"  {label}: {n:,} cells ({pct:.1f}%)")

# --- Build a lat/lon extent tuple for imshow ---
extent_deg = [dem_bounds.left, dem_bounds.right, dem_bounds.bottom, dem_bounds.top]

# --- Reproject watershed polygons to match DEM CRS for overlay ---
ws_dem = ws.to_crs(str(dem_crs))

# --- Plot 1: continuous DEM with terrain colormap ---
fig, axes = plt.subplots(1, 2, figsize=(13, 6))

ax = axes[0]
im = ax.imshow(dem, cmap="terrain", extent=extent_deg, origin="upper", aspect="auto")
cbar = fig.colorbar(im, ax=ax, fraction=0.03, pad=0.03)
cbar.set_label("Elevation (m)")
# Overlay watershed boundaries
for geom in ws_dem.geometry:
    if geom is None:
        continue
    if geom.geom_type == "Polygon":
        geoms = [geom]
    else:
        geoms = list(geom.geoms)
    for g in geoms:
        xs, ys = g.exterior.xy
        ax.plot(xs, ys, color="black", linewidth=0.4, alpha=0.6)
ax.set_title("Continuous DEM\n(with watershed boundaries)", fontweight="bold")
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")

# --- Plot 2: classified DEM ---
ax = axes[1]
cmap_class = ListedColormap(["#a8ddb5", "#fdae61", "#d7191c"])  # Low/Mid/High
bounds_class = [0.5, 1.5, 2.5, 3.5]
norm_class = BoundaryNorm(bounds_class, cmap_class.N)
ax.imshow(dem_class, cmap=cmap_class, norm=norm_class,
          extent=extent_deg, origin="upper", aspect="auto")
patches = [mpatches.Patch(color=c, label=l) for c, l in
           zip(["#a8ddb5", "#fdae61", "#d7191c"],
               ["Low (0–100 m)", "Mid (100–300 m)", "High (>300 m)"])]
ax.legend(handles=patches, loc="upper right", fontsize=8,
          title="Elevation Zone", title_fontsize=9)
for geom in ws_dem.geometry:
    if geom is None:
        continue
    if geom.geom_type == "Polygon":
        geoms = [geom]
    else:
        geoms = list(geom.geoms)
    for g in geoms:
        xs, ys = g.exterior.xy
        ax.plot(xs, ys, color="black", linewidth=0.4, alpha=0.7)
ax.set_title("Classified Elevation Zones\n(Low / Mid / High)", fontweight="bold")
ax.set_xlabel("Longitude")

fig.suptitle("Chesapeake Bay Watershed — Digital Elevation Model (300 m)",
             fontsize=13, fontweight="bold", y=1.01)
plt.tight_layout()
plt.savefig("ex04_dem.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex04_dem.png")


# =============================================================================
# EXERCISE 5: Loading Precipitation Data from NetCDF
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 5: Loading Precipitation Data from NetCDF")
print("=" * 70)

nc_path = "mswep_monthly.nc"

# --- Load with xarray ---
# xarray is the standard library for labeled multi-dimensional arrays.
# It preserves dimension names (lat, lon, time) and coordinate metadata.
ds = xr.open_dataset(nc_path)
print(f"\nDataset variables: {list(ds.data_vars)}")
print(f"Dimensions: {dict(ds.dims)}")

prec_var = ds["precipitation"]
print(f"\nPrecipitation shape  : {prec_var.shape}  (time, lat, lon)")
print(f"Time range           : {str(prec_var.time.values[0])[:10]} "
      f"to {str(prec_var.time.values[-1])[:10]}")
print(f"Spatial extent       : lat {float(prec_var.lat.min()):.2f}°–"
      f"{float(prec_var.lat.max()):.2f}°, "
      f"lon {float(prec_var.lon.min()):.2f}°–{float(prec_var.lon.max()):.2f}°")
print(f"Units: mm/day (multiply by days_in_month to convert to mm/month)")

# --- Convert mm/day → mm/month ---
# February has 28 days, August has 31; missing this step creates systematic error.
times    = pd.DatetimeIndex(prec_var.coords["time"].values)
days_arr = xr.DataArray(times.days_in_month,
                         coords=[prec_var.coords["time"]], dims=["time"])
prec_mm = prec_var * days_arr   # now in mm/month

# --- Temporal aggregation ---
# Annual total: sum the 12 monthly values within each calendar year
annual = prec_mm.resample(time="YE").sum()

# Long-term mean annual precipitation (average of 2015–2019 annual totals)
mean_annual = annual.mean(dim="time")

print(f"\nMean annual precipitation range: "
      f"{float(mean_annual.min()):.0f} – {float(mean_annual.max()):.0f} mm/yr")

# Wettest and driest year (spatially-averaged basin total)
basin_annual = annual.mean(dim=["lat", "lon"])
years_str    = [str(t)[:4] for t in annual.time.values]

wettest_idx  = int(basin_annual.argmax())
driest_idx   = int(basin_annual.argmin())
print(f"\nWettest year: {years_str[wettest_idx]} "
      f"({float(basin_annual[wettest_idx]):.0f} mm/yr basin avg)")
print(f"Driest year : {years_str[driest_idx]} "
      f"({float(basin_annual[driest_idx]):.0f} mm/yr basin avg)")

# Annual totals by year for quick reference
print("\nBasin-average annual precipitation by year:")
for yr, val in zip(years_str, basin_annual.values):
    print(f"  {yr}: {val:.0f} mm/yr")

# --- Save mean annual precipitation as a GeoTIFF for use in Exercise 7 ---
mean_annual_np = mean_annual.values                   # 2-D numpy array
lats  = mean_annual.lat.values
lons  = mean_annual.lon.values
res_x = float(lons[1] - lons[0])
res_y = float(lats[1] - lats[0])   # may be negative (decreasing lat)

mean_annual_tif = "mean_annual_precip.tif"
transform_prec  = from_bounds(
    west=float(lons.min()) - abs(res_x) / 2,
    east=float(lons.max()) + abs(res_x) / 2,
    south=float(lats.min()) - abs(res_y) / 2,
    north=float(lats.max()) + abs(res_y) / 2,
    width=len(lons),
    height=len(lats)
)

# Flip array so that row 0 = north (required for correct georeferencing)
if lats[0] < lats[-1]:
    mean_annual_np = np.flipud(mean_annual_np)

with rasterio.open(
    mean_annual_tif, "w",
    driver="GTiff", height=len(lats), width=len(lons),
    count=1, dtype=np.float32,
    crs="EPSG:4326", transform=transform_prec, nodata=-9999.0
) as dst:
    out_arr = mean_annual_np.astype(np.float32)
    out_arr[np.isnan(out_arr)] = -9999.0
    dst.write(out_arr, 1)
print(f"\nMean annual precipitation GeoTIFF saved: {mean_annual_tif}")

# --- Map: long-term mean annual precipitation with watershed overlay ---
fig, ax = plt.subplots(figsize=(9, 6))
mean_annual.plot(
    ax=ax, cmap="Blues", robust=True,
    cbar_kwargs={"label": "Mean Annual Precipitation (mm/yr)", "shrink": 0.7}
)

# Overlay watershed boundaries (both already in EPSG:4326)
ws.plot(ax=ax, color="none", edgecolor="black", linewidth=0.6)

ax.set_title("MSWEP Mean Annual Precipitation 2015–2019\n(Chesapeake Bay Watershed)",
             fontsize=12, fontweight="bold")
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
plt.tight_layout()
plt.savefig("ex05_precipitation.png", dpi=150, bbox_inches="tight")
plt.close()
print("Figure saved: ex05_precipitation.png")

ds.close()


# =============================================================================
# EXERCISE 6: Riparian Buffer Analysis
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 6: Riparian Buffer Analysis")
print("=" * 70)

# --- Load stream network ---
streams = gpd.read_file("chesapeake_streams.gpkg",
                        layer="chesapeake_streams")
print(f"\nStreams shape: {streams.shape[0]} features, {streams.shape[1]} columns")
print(f"Columns: {list(streams.columns)}")
print(f"CRS (original): {streams.crs}")
print(f"Geometry type: {streams.geom_type.unique()}")

# --- Reproject to UTM Zone 18N (meters required for buffering) ---
# Buffering in geographic degrees produces ellipses, not circles, and the
# "distance" varies with latitude — incorrect for any ground-distance analysis.
streams_proj    = streams.to_crs("EPSG:32618")
stations_proj   = stations_gdf.to_crs("EPSG:32618")
print(f"CRS after reprojection: {streams_proj.crs}")

# --- Create buffers at 100 m, 300 m, 500 m ---
print("\nCreating buffers (this may take a moment for 7,000+ features)...")
buf_100 = streams_proj.buffer(100)
buf_300 = streams_proj.buffer(300)
buf_500 = streams_proj.buffer(500)

# --- Dissolve (union) overlapping polygons for each distance ---
# Summing individual buffer areas double-counts where buffers overlap;
# unary_union merges all overlapping polygons into a single geometry first.
print("Dissolving buffer geometries...")
buf_100_union = buf_100.unary_union
buf_300_union = buf_300.unary_union
buf_500_union = buf_500.unary_union

area_100 = buf_100_union.area / 1e6
area_300 = buf_300_union.area / 1e6
area_500 = buf_500_union.area / 1e6

print(f"\nTotal dissolved buffer areas:")
print(f"  100 m buffer: {area_100:,.0f} km²")
print(f"  300 m buffer: {area_300:,.0f} km²")
print(f"  500 m buffer: {area_500:,.0f} km²")
print(f"\nArea ratios (relative to 100 m):")
print(f"  300 m / 100 m: {area_300/area_100:.2f}x  (linear scaling would give 3.0x)")
print(f"  500 m / 100 m: {area_500/area_100:.2f}x  (linear scaling would give 5.0x)")
print("  (Sub-linear because buffers merge — more overlap at larger distances)")

# --- Identify stations within the 500 m buffer ---
stations_proj["in_buffer_500m"] = stations_proj.geometry.within(buf_500_union)
in_buf = stations_proj[stations_proj["in_buffer_500m"]]
out_buf = stations_proj[~stations_proj["in_buffer_500m"]]

print(f"\nStations within 500 m buffer : {len(in_buf)}")
print(f"Stations outside 500 m buffer: {len(out_buf)}")
print("\nStations inside the 500 m riparian buffer:")
print(in_buf[["station_id", "description"]].to_string(index=False))

# --- Map: streams + 500 m buffer + stations (inside vs outside) ---
fig, ax = plt.subplots(figsize=(10, 8))

# 500 m buffer zone (semi-transparent fill)
gpd.GeoSeries([buf_500_union], crs="EPSG:32618").plot(
    ax=ax, color="lightblue", alpha=0.4, zorder=1
)
# Stream lines
streams_proj.plot(ax=ax, color="steelblue", linewidth=0.3, zorder=2)

# Stations inside buffer (green) and outside (red)
if len(in_buf) > 0:
    in_buf.plot(ax=ax, color="forestgreen", markersize=55,
                zorder=4, label="Inside 500 m buffer")
if len(out_buf) > 0:
    out_buf.plot(ax=ax, color="firebrick", markersize=55,
                 zorder=4, label="Outside 500 m buffer")

ax.legend(fontsize=9, loc="upper right")
ax.set_title("Riparian Buffer Analysis — 500 m Buffer Zone\n"
             "Chesapeake Bay Stream Network (NHD Major Streams)",
             fontsize=12, fontweight="bold")
ax.set_xlabel("Easting (m, UTM Zone 18N)")
ax.set_ylabel("Northing (m, UTM Zone 18N)")
ax.grid(True, linestyle="--", linewidth=0.3, alpha=0.5)
plt.tight_layout()
plt.savefig("ex06_buffers.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex06_buffers.png")


# =============================================================================
# EXERCISE 7: Zonal Statistics — Raster Summaries by Watershed
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 7: Zonal Statistics — Precipitation per Watershed")
print("=" * 70)

# --- Align watersheds to the precipitation raster CRS (EPSG:4326) ---
# Both layers must share the same CRS before rasterstats can intersect them.
ws_geo = ws.to_crs("EPSG:4326")
print(f"Watershed CRS: {ws_geo.crs}")
print(f"Precipitation raster: {mean_annual_tif} (EPSG:4326)")

# --- Zonal statistics: mean, min, max, std of annual precipitation per watershed ---
# rasterstats.zonal_stats accepts a file path for the raster.
# It samples raster pixels within each polygon and applies summary functions.
print("\nComputing zonal statistics...")
stats = zonal_stats(
    ws_geo,
    mean_annual_tif,
    stats=["mean", "min", "max", "std"],
    nodata=-9999.0
)

zonal_df = pd.DataFrame(stats)
zonal_df.columns = ["precip_mean", "precip_min", "precip_max", "precip_std"]

# --- Join results back to the watershed GeoDataFrame ---
# zonal_stats returns a list in the same row order as the input GeoDataFrame
ws_with_precip = ws_proj.reset_index(drop=True).copy()
ws_with_precip = pd.concat([ws_with_precip, zonal_df], axis=1)

print("\nPrecipitation statistics per watershed (mm/yr) — first 8 rows:")
print(ws_with_precip[["Name", "area_km2", "precip_mean", "precip_std"]].head(8).to_string(index=False))

print(f"\nWettest watershed : "
      f"{ws_with_precip.loc[ws_with_precip['precip_mean'].idxmax(), 'Name']} "
      f"({ws_with_precip['precip_mean'].max():.0f} mm/yr)")
print(f"Driest watershed  : "
      f"{ws_with_precip.loc[ws_with_precip['precip_mean'].idxmin(), 'Name']} "
      f"({ws_with_precip['precip_mean'].min():.0f} mm/yr)")

# --- Two-panel map: choropleth + scatter ---
fig, axes = plt.subplots(1, 2, figsize=(13, 6))

# Left: choropleth of mean annual precipitation
ws_with_precip.plot(
    column="precip_mean",
    cmap="Blues",
    legend=True,
    legend_kwds={"label": "Mean Annual Precip (mm/yr)", "shrink": 0.6},
    edgecolor="gray", linewidth=0.4,
    ax=axes[0]
)
axes[0].set_title("Mean Annual Precipitation\nper HUC8 Watershed", fontweight="bold")
axes[0].set_xlabel("Easting (m)")
axes[0].set_ylabel("Northing (m)")

# Right: scatter — watershed area vs mean precipitation
axes[1].scatter(
    ws_with_precip["area_km2"],
    ws_with_precip["precip_mean"],
    color="steelblue", edgecolors="black", linewidth=0.5, s=50, alpha=0.8
)
axes[1].set_xlabel("Watershed Area (km²)")
axes[1].set_ylabel("Mean Annual Precipitation (mm/yr)")
axes[1].set_title("Watershed Area vs.\nMean Annual Precipitation", fontweight="bold")
axes[1].grid(True, linestyle="--", linewidth=0.4, alpha=0.6)

plt.tight_layout()
plt.savefig("ex07_zonal_stats.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex07_zonal_stats.png")

# --- Advanced: DO vs precipitation by watershed ---
# Aggregate station DO to watershed level using the 'watershed' column in stations
station_do_by_ws = (
    stations_gdf.groupby("watershed")["mean_do_mgl"]
    .mean()
    .reset_index()
    .rename(columns={"watershed": "Name", "mean_do_mgl": "mean_do"})
)
ws_do = ws_with_precip.merge(station_do_by_ws, on="Name", how="left")

fig, ax = plt.subplots(figsize=(7, 5))
mask = ws_do["mean_do"].notna()
sc = ax.scatter(
    ws_do.loc[mask, "precip_mean"],
    ws_do.loc[mask, "mean_do"],
    c=ws_do.loc[mask, "precip_mean"],
    cmap="Blues", edgecolors="black", linewidth=0.5, s=70, alpha=0.85
)
for _, row in ws_do[mask].iterrows():
    ax.annotate(row["Name"], xy=(row["precip_mean"], row["mean_do"]),
                fontsize=5.5, alpha=0.75, xytext=(2, 2),
                textcoords="offset points")
ax.set_xlabel("Mean Annual Precipitation (mm/yr)")
ax.set_ylabel("Mean Dissolved Oxygen (mg/L)")
ax.set_title("DO vs. Mean Annual Precipitation by Watershed\n"
             "(watersheds with monitoring stations only)", fontweight="bold")
ax.grid(True, linestyle="--", linewidth=0.4, alpha=0.5)
plt.tight_layout()
plt.savefig("ex07_do_vs_precip.png", dpi=150, bbox_inches="tight")
plt.close()
print("Figure saved: ex07_do_vs_precip.png")


# =============================================================================
# EXERCISE 8: Categorical Raster Analysis — National Land Cover Data (NLCD)
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 8: Categorical Raster Analysis — NLCD Land Cover")
print("=" * 70)

nlcd_path = "nlcd_chesapeake.tif"

# --- Load NLCD (EPSG:5070 Albers Equal Area) ---
with rasterio.open(nlcd_path) as src:
    nlcd         = src.read(1)
    nlcd_nodata  = src.nodata
    nlcd_crs     = src.crs
    nlcd_transform = src.transform
    nlcd_height  = src.height
    nlcd_width   = src.width

print(f"\nNLCD CRS          : {nlcd_crs}")
print(f"NLCD shape        : {nlcd_height} rows x {nlcd_width} cols")
print(f"NLCD nodata value : {nlcd_nodata}")

unique_vals = np.unique(nlcd[nlcd != nlcd_nodata]) if nlcd_nodata is not None else np.unique(nlcd)
print(f"Unique NLCD class codes: {unique_vals}")

# NLCD class definitions used in Chesapeake dataset
nlcd_class_names = {
    11: "Open Water", 21: "Developed-Low", 22: "Developed-Med",
    23: "Developed-High", 24: "Developed-VHigh", 31: "Barren",
    41: "Deciduous Forest", 42: "Evergreen Forest", 43: "Mixed Forest",
    52: "Shrub/Scrub", 71: "Herbaceous", 81: "Hay/Pasture",
    82: "Cultivated Crops", 90: "Woody Wetlands", 95: "Emergent Herbaceous Wetlands"
}
print("\nNLCD classes present in dataset:")
for v in unique_vals:
    if int(v) in nlcd_class_names:
        print(f"  {v:3d}: {nlcd_class_names[int(v)]}")

# --- Reclassify to 4 aggregated categories ---
# 1 = Forest (41–43), 2 = Agriculture (81–82), 3 = Urban (21–24), 4 = Other
nlcd_reclass = np.full_like(nlcd, 4, dtype=np.int16)   # default: Other
nlcd_reclass[np.isin(nlcd, [41, 42, 43])]       = 1   # Forest
nlcd_reclass[np.isin(nlcd, [81, 82])]            = 2   # Agriculture
nlcd_reclass[np.isin(nlcd, [21, 22, 23, 24])]   = 3   # Urban

# Mask nodata pixels
nodata_mask = (nlcd == nlcd_nodata) if nlcd_nodata is not None else np.zeros_like(nlcd, dtype=bool)
nlcd_reclass[nodata_mask] = 0   # 0 = NoData in reclassified raster

total_valid_nlcd = int(np.sum(nlcd_reclass > 0))
print(f"\nReclassified land cover distribution:")
for code, label in [(1, "Forest"), (2, "Agriculture"), (3, "Urban"), (4, "Other")]:
    n = int(np.sum(nlcd_reclass == code))
    pct = n / total_valid_nlcd * 100 if total_valid_nlcd > 0 else 0
    print(f"  {label}: {n:,} cells ({pct:.1f}%)")

# --- Save reclassified raster as a temporary GeoTIFF for zonal_stats ---
nlcd_reclass_tif = "nlcd_reclass.tif"
with rasterio.open(
    nlcd_reclass_tif, "w",
    driver="GTiff", height=nlcd_height, width=nlcd_width,
    count=1, dtype=np.int16,
    crs=nlcd_crs, transform=nlcd_transform, nodata=0
) as dst:
    dst.write(nlcd_reclass.astype(np.int16), 1)
print(f"\nReclassified NLCD saved: {nlcd_reclass_tif}")

# --- Reproject watersheds to EPSG:5070 for zonal stats (must match raster CRS) ---
ws_albers = ws.to_crs(str(nlcd_crs))
print(f"Watershed CRS for NLCD zonal stats: {ws_albers.crs}")

# --- Zonal statistics: count cells per NLCD category per watershed ---
# categorical=True tells rasterstats to count how many cells of each integer
# value fall within each polygon — appropriate for class-coded rasters.
print("\nComputing categorical zonal statistics...")
lc_stats = zonal_stats(
    ws_albers,
    nlcd_reclass_tif,
    categorical=True,
    category_map={1: "forest", 2: "agr", 3: "urban", 4: "other"},
    nodata=0
)

lc_df = pd.DataFrame(lc_stats).fillna(0)

# Ensure all four categories are present even if a watershed has none
for col in ["forest", "agr", "urban", "other"]:
    if col not in lc_df.columns:
        lc_df[col] = 0.0

# Convert counts to percentages
lc_totals = lc_df[["forest", "agr", "urban", "other"]].sum(axis=1)
lc_pct = lc_df[["forest", "agr", "urban", "other"]].div(lc_totals, axis=0) * 100
lc_pct.columns = ["pct_forest", "pct_agr", "pct_urban", "pct_other"]

# Join back to the watershed GeoDataFrame (already has area_km2 and precip)
ws_lc = ws_with_precip.reset_index(drop=True).copy()
ws_lc = pd.concat([ws_lc, lc_pct], axis=1)

print("\nLand cover statistics (% of watershed) — first 8 rows:")
print(ws_lc[["Name", "pct_forest", "pct_agr", "pct_urban"]].head(8).to_string(index=False))

highest_agr = ws_lc.loc[ws_lc["pct_agr"].idxmax(), "Name"]
highest_for = ws_lc.loc[ws_lc["pct_forest"].idxmax(), "Name"]
print(f"\nMost agricultural watershed : {highest_agr} "
      f"({ws_lc['pct_agr'].max():.1f}% agriculture)")
print(f"Most forested watershed     : {highest_for} "
      f"({ws_lc['pct_forest'].max():.1f}% forest)")

# --- Two-panel map: % Agriculture and % Forest ---
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

ws_lc.plot(
    column="pct_agr",
    cmap="YlOrBr",
    legend=True,
    legend_kwds={"label": "% Agriculture", "shrink": 0.6},
    edgecolor="gray", linewidth=0.4,
    ax=axes[0]
)
axes[0].set_title("A — Agricultural Cover (%)\nper HUC8 Watershed", fontweight="bold")
axes[0].set_xlabel("Easting (m)")
axes[0].set_ylabel("Northing (m)")

ws_lc.plot(
    column="pct_forest",
    cmap="Greens",
    legend=True,
    legend_kwds={"label": "% Forest", "shrink": 0.6},
    edgecolor="gray", linewidth=0.4,
    ax=axes[1]
)
axes[1].set_title("B — Forest Cover (%)\nper HUC8 Watershed", fontweight="bold")
axes[1].set_xlabel("Easting (m)")

fig.suptitle("NLCD 2021 Land Cover — Chesapeake Bay HUC8 Watersheds",
             fontsize=13, fontweight="bold", y=1.01)
plt.tight_layout()
plt.savefig("ex08_land_cover.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex08_land_cover.png")

# --- Scatter: % Agriculture vs mean station DO ---
ws_lc_do = ws_lc.merge(station_do_by_ws, on="Name", how="left")
mask = ws_lc_do["mean_do"].notna()

fig, ax = plt.subplots(figsize=(7, 5))
ax.scatter(
    ws_lc_do.loc[mask, "pct_agr"],
    ws_lc_do.loc[mask, "mean_do"],
    color="sienna", edgecolors="black", linewidth=0.5, s=65, alpha=0.85
)
for _, row in ws_lc_do[mask].iterrows():
    ax.annotate(row["Name"], xy=(row["pct_agr"], row["mean_do"]),
                fontsize=5.5, alpha=0.75, xytext=(2, 2),
                textcoords="offset points")
ax.set_xlabel("% Agricultural Cover")
ax.set_ylabel("Mean Dissolved Oxygen (mg/L)")
ax.set_title("% Agriculture vs. Mean DO by Watershed\n"
             "(supports eutrophication hypothesis: more agriculture → lower DO)",
             fontweight="bold")
ax.grid(True, linestyle="--", linewidth=0.4, alpha=0.5)
plt.tight_layout()
plt.savefig("ex08_agr_vs_do.png", dpi=150, bbox_inches="tight")
plt.close()
print("Figure saved: ex08_agr_vs_do.png")


# =============================================================================
# EXERCISE 9: Coordinate Reference Systems and Reprojection
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 9: CRS Effects — Distance and Area Calculations")
print("=" * 70)

# Use two stations that are geographically spread apart
p1_geo = stations_gdf.geometry.iloc[0]   # northernmost: Susquehanna at Conklin NY
p2_geo = stations_gdf.geometry.iloc[-1]  # southernmost: James River lower tidal
s1_name = stations_gdf["station_id"].iloc[0]
s2_name = stations_gdf["station_id"].iloc[-1]

print(f"\nStation 1: {s1_name}  ({p1_geo.y:.4f}°N, {p1_geo.x:.4f}°E)")
print(f"Station 2: {s2_name}  ({p2_geo.y:.4f}°N, {p2_geo.x:.4f}°E)")

# --- Distance in geographic coordinates (degrees) — incorrect as a ground distance ---
# Shapely's .distance() computes Euclidean (planar) distance in coordinate units.
# When coordinates are in degrees, the result is in "degrees" — not meaningful ground distance.
dist_deg = p1_geo.distance(p2_geo)
print(f"\n1. Euclidean distance in geographic coordinates (EPSG:4326): {dist_deg:.4f} °")
print("   (This is in DEGREES — not a ground distance. Mixing longitude and latitude")
print("    degrees is geometrically incorrect because they have different ground lengths.)")

# --- Distance in UTM Zone 18N (meters) — correct planar approximation ---
stations_utm = stations_gdf.to_crs("EPSG:32618")
p1_utm = stations_utm.geometry.iloc[0]
p2_utm = stations_utm.geometry.iloc[-1]
dist_m  = p1_utm.distance(p2_utm)
dist_km = dist_m / 1000
print(f"\n2. Euclidean distance in UTM Zone 18N (EPSG:32618): {dist_km:.2f} km")

# --- Geodetic distance using pyproj.Geod (most accurate — follows Earth's ellipsoid) ---
geod = Geod(ellps="WGS84")
_az1, _az2, dist_geod_m = geod.inv(p1_geo.x, p1_geo.y, p2_geo.x, p2_geo.y)
dist_geod_km = dist_geod_m / 1000
print(f"\n3. Geodetic (ellipsoidal) distance (pyproj.Geod): {dist_geod_km:.2f} km")

pct_err_deg = (dist_deg - dist_km) / dist_km * 100
pct_err_utm = (dist_km - dist_geod_km) / dist_geod_km * 100
print(f"\nPercentage error — degree distance vs geodetic: {pct_err_deg:.1f}% (meaningless units)")
print(f"Percentage error — UTM vs geodetic            : {pct_err_utm:.2f}%")

# --- Area comparison for one watershed ---
ws_sel = ws.iloc[[0]]   # first watershed polygon
ws_name = ws_sel["Name"].values[0]
print(f"\n--- Area comparison for watershed: {ws_name} ---")

# (a) Naive planar area in WGS84 (square degrees — meaningless)
area_deg2 = float(ws_sel.geometry.area.values[0])
print(f"\n(a) Naive planar area in WGS84 (sq. degrees): {area_deg2:.6f} °²")
print("    (Unit is 'square degrees' — not convertible to km² without latitude correction)")

# (b) UTM Zone 18N: accurate planar area
ws_sel_utm = ws_sel.to_crs("EPSG:32618")
area_utm_km2 = float(ws_sel_utm.geometry.area.values[0]) / 1e6
print(f"\n(b) UTM Zone 18N (EPSG:32618) projected area: {area_utm_km2:.2f} km²")

# (c) Ellipsoidal area via pyproj.Geod (reference value, accounts for Earth's curvature)
poly_geom = ws_sel.geometry.values[0]
if poly_geom.geom_type == "MultiPolygon":
    poly_geom = max(poly_geom.geoms, key=lambda g: g.area)
area_m2_geod, _ = geod.geometry_area_perimeter(poly_geom)
area_geod_km2    = abs(area_m2_geod) / 1e6
print(f"\n(c) Ellipsoidal area via pyproj.Geod (WGS84): {area_geod_km2:.2f} km²")

pct_err_area = (area_utm_km2 - area_geod_km2) / area_geod_km2 * 100
print(f"\nUTM vs. ellipsoidal area error: {pct_err_area:.2f}%")

# --- CRS mismatch demonstration: NLCD (EPSG:5070) vs watersheds (EPSG:4326) ---
print("\n--- CRS mismatch: NLCD raster (EPSG:5070) vs watershed polygons (EPSG:4326) ---")
print(f"Watershed CRS         : {ws.crs}")
print(f"NLCD CRS              : {nlcd_crs}")
print(f"CRS match             : {str(ws.crs) == str(nlcd_crs)}")
print("If you overlay without reprojecting, geometries will be in incompatible")
print("coordinate spaces — the layers will not align spatially.")
print("Fix: reproject watersheds to match the raster CRS before analysis.")
ws_fixed = ws.to_crs(str(nlcd_crs))
print(f"After ws.to_crs(nlcd_crs): {ws_fixed.crs}  (CRS now matches NLCD)")

# --- Summary table ---
print("\n--- Summary Table: CRS and Measurement Method Comparison ---")
summary = pd.DataFrame({
    "Operation": [
        "Distance (2 stations)",
        "Distance (2 stations)",
        "Distance (2 stations)",
        f"Area ({ws_name})",
        f"Area ({ws_name})",
    ],
    "CRS / Method": [
        "WGS84 EPSG:4326 (degree distance, INCORRECT)",
        "UTM Zone 18N EPSG:32618 (planar)",
        "pyproj.Geod WGS84 (geodetic, REFERENCE)",
        "WGS84 EPSG:4326 (square degrees, INCORRECT)",
        "UTM Zone 18N EPSG:32618 (planar)",
    ],
    "Result": [
        f"{dist_deg:.4f} °",
        f"{dist_km:.2f} km",
        f"{dist_geod_km:.2f} km",
        f"{area_deg2:.4f} °²",
        f"{area_utm_km2:.2f} km²",
    ],
    "Notes": [
        "Meaningless units; not a ground distance",
        f"{pct_err_utm:.2f}% error vs geodetic",
        "Reference value (ellipsoidal model)",
        "Cannot convert to km² without correction",
        f"{pct_err_area:.2f}% error vs geodetic",
    ]
})
print(summary.to_string(index=False))

# --- Figure: visual summary of the distance pair ---
fig, ax = plt.subplots(figsize=(9, 7))
stations_gdf.plot(ax=ax, color="steelblue", markersize=30, zorder=3, alpha=0.7)
ws.plot(ax=ax, color="none", edgecolor="gray", linewidth=0.4, zorder=1)

# Highlight the two selected stations
pair_gdf = stations_gdf.iloc[[0, -1]]
pair_gdf.plot(ax=ax, color="firebrick", markersize=80, zorder=4)

ax.plot([p1_geo.x, p2_geo.x], [p1_geo.y, p2_geo.y],
        "r--", linewidth=1.5, zorder=5, label=f"Distance ≈ {dist_geod_km:.0f} km (geodetic)")

for _, row in pair_gdf.iterrows():
    ax.annotate(
        row["station_id"],
        xy=(row.geometry.x, row.geometry.y),
        xytext=(6, 6), textcoords="offset points", fontsize=8,
        color="darkred", fontweight="bold"
    )

ax.legend(fontsize=9)
ax.set_title("CRS Demonstration: Distance Between Two Stations\n"
             f"Geodetic distance: {dist_geod_km:.1f} km | UTM planar: {dist_km:.1f} km",
             fontsize=11, fontweight="bold")
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
ax.grid(True, linestyle="--", linewidth=0.3, alpha=0.5)
plt.tight_layout()
plt.savefig("ex09_crs_effects.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex09_crs_effects.png")


# =============================================================================
# EXERCISE 10: Integrated Spatial Analysis — Watershed Risk Assessment
# =============================================================================
print("\n" + "=" * 70)
print("EXERCISE 10: Integrated Spatial Analysis — Watershed Risk Assessment")
print("=" * 70)

# =============================================================================
# STEP 1: Assemble the watershed-level data table
# =============================================================================
# Start from ws_with_precip (from Ex 7) which has: geometry, area_km2, precip_*
# Join land cover percentages from ws_lc (Ex 8)
# Join mean DO per watershed from station_do_by_ws (Ex 3)

# ws_lc already contains both precip and land cover columns; use it as the base
ws_risk = ws_lc.copy()

# Join station DO (aggregated to watershed by the 'watershed' column in stations.csv)
ws_risk = ws_risk.merge(station_do_by_ws, on="Name", how="left")

print(f"\nWatershed risk table shape: {ws_risk.shape}")
print(f"Columns: {list(ws_risk.columns)}")

# Report how many watersheds have DO observations
n_with_do = ws_risk["mean_do"].notna().sum()
print(f"\nWatersheds with DO data   : {n_with_do} / {len(ws_risk)}")
print(f"Watersheds without DO data: {ws_risk['mean_do'].isna().sum()} (will be excluded from risk score)")

# Quick overview of the three risk indicators
print("\nIndicator summary (watersheds with complete data):")
complete = ws_risk.dropna(subset=["mean_do"])
print(complete[["pct_agr", "precip_mean", "mean_do"]].describe().round(2))

# =============================================================================
# STEP 2: Normalize and compute composite risk score
# =============================================================================
def normalize(series):
    """Min-max normalization to [0, 1]. Returns NaN where input is NaN."""
    mn = series.min(skipna=True)
    mx = series.max(skipna=True)
    if mx == mn:
        return series * 0.0   # all same value -> all 0
    return (series - mn) / (mx - mn)


ws_risk["norm_agr"]  = normalize(ws_risk["pct_agr"])
ws_risk["norm_prec"] = normalize(ws_risk["precip_mean"])
ws_risk["norm_do"]   = normalize(ws_risk["mean_do"])

# Composite risk score:
#   High agriculture (+)  -> more nutrient loading
#   High precipitation (+) -> more transport to the Bay
#   High DO (-)          -> invert: high DO means low risk
# Watersheds with missing DO receive NaN risk score
ws_risk["risk_score"] = (
    0.4 * ws_risk["norm_agr"] +
    0.4 * ws_risk["norm_prec"] +
    0.2 * (1.0 - ws_risk["norm_do"])
)

ws_risk["risk_class"] = pd.cut(
    ws_risk["risk_score"],
    bins=[-np.inf, 0.3, 0.6, np.inf],
    labels=["Low Risk", "Moderate Risk", "High Risk"]
)

# Print risk results
risk_scored = ws_risk.dropna(subset=["risk_score"])
print("\nWatershed risk scores (descending):")
print(risk_scored[["Name", "pct_agr", "precip_mean", "mean_do", "risk_score", "risk_class"]]
      .sort_values("risk_score", ascending=False)
      .to_string(index=False))

print(f"\nRisk classification counts (watersheds with data):")
print(ws_risk["risk_class"].value_counts().to_string())

# =============================================================================
# STEP 3: Four-panel publication-quality map
# =============================================================================
# All four panels use the projected CRS (UTM 18N) so the geometry column
# from ws_lc (which carries geometry from ws_proj) is used directly.
# (ws_risk inherits the geometry through ws_lc which was derived from ws_proj)

risk_colors = {
    "Low Risk"      : "#1a9641",   # green
    "Moderate Risk" : "#fdae61",   # orange
    "High Risk"     : "#d7191c",   # red
}

fig, axes = plt.subplots(2, 2, figsize=(15, 11))
fig.suptitle(
    "Chesapeake Bay Watershed — Hypoxia Risk Assessment\n"
    "Indicators: % Agriculture | Mean Precipitation | Mean DO | Composite Risk",
    fontsize=13, fontweight="bold", y=1.01
)

# ---- Panel A: % Agricultural Cover ----
ax = axes[0, 0]
ws_risk.plot(
    column="pct_agr",
    cmap="YlOrBr",
    legend=True,
    legend_kwds={"label": "% Agriculture", "shrink": 0.7, "pad": 0.02},
    edgecolor="white", linewidth=0.4,
    missing_kwds={"color": "lightgray", "label": "No data"},
    ax=ax
)
ax.set_title("A — Agricultural Cover (%)", fontweight="bold", fontsize=11)
ax.set_xlabel("Easting (m)", fontsize=8)
ax.set_ylabel("Northing (m)", fontsize=8)
ax.tick_params(labelsize=7)
ax.grid(True, linestyle="--", linewidth=0.25, alpha=0.4)

# ---- Panel B: Mean Annual Precipitation ----
ax = axes[0, 1]
ws_risk.plot(
    column="precip_mean",
    cmap="Blues",
    legend=True,
    legend_kwds={"label": "Mean Annual Precip (mm/yr)", "shrink": 0.7, "pad": 0.02},
    edgecolor="white", linewidth=0.4,
    missing_kwds={"color": "lightgray", "label": "No data"},
    ax=ax
)
ax.set_title("B — Mean Annual Precipitation (mm/yr)", fontweight="bold", fontsize=11)
ax.set_xlabel("Easting (m)", fontsize=8)
ax.tick_params(labelsize=7)
ax.grid(True, linestyle="--", linewidth=0.25, alpha=0.4)

# ---- Panel C: Mean Station DO with station points overlaid ----
ax = axes[1, 0]
ws_risk.plot(
    column="mean_do",
    cmap="RdYlGn",
    legend=True,
    legend_kwds={"label": "Mean DO (mg/L)", "shrink": 0.7, "pad": 0.02},
    edgecolor="white", linewidth=0.4,
    missing_kwds={"color": "lightgray", "label": "No station data"},
    ax=ax
)
# Overlay monitoring station points
stations_proj.plot(ax=ax, color="black", markersize=20, zorder=5, alpha=0.8)
ax.set_title("C — Mean Dissolved Oxygen (mg/L)\n(black dots = monitoring stations)",
             fontweight="bold", fontsize=11)
ax.set_xlabel("Easting (m)", fontsize=8)
ax.set_ylabel("Northing (m)", fontsize=8)
ax.tick_params(labelsize=7)
ax.grid(True, linestyle="--", linewidth=0.25, alpha=0.4)

# ---- Panel D: Composite Risk Classification ----
ax = axes[1, 1]

# Separate patches by risk class so colors are explicit and colorblind-friendly
for risk_val, color in risk_colors.items():
    subset = ws_risk[ws_risk["risk_class"] == risk_val]
    if len(subset) > 0:
        subset.plot(ax=ax, color=color, edgecolor="white", linewidth=0.4, zorder=2)

# Watersheds with no risk score (missing DO)
no_score = ws_risk[ws_risk["risk_score"].isna()]
if len(no_score) > 0:
    no_score.plot(ax=ax, color="lightgray", edgecolor="white", linewidth=0.4, zorder=1)

# Legend patches
legend_patches = [
    mpatches.Patch(color="#1a9641", label="Low Risk (score < 0.3)"),
    mpatches.Patch(color="#fdae61", label="Moderate Risk (0.3 – 0.6)"),
    mpatches.Patch(color="#d7191c", label="High Risk (score > 0.6)"),
    mpatches.Patch(color="lightgray", label="No DO data"),
]
ax.legend(handles=legend_patches, loc="lower left", fontsize=7,
          title="Risk Level", title_fontsize=8)

# Simple scale bar (approximate: 1° longitude ≈ 86 km at 39°N in UTM context)
# In UTM units, add a 100 km scale bar at lower right of the axis
xlim = ax.get_xlim()
ylim = ax.get_ylim()
bar_x_start = xlim[0] + (xlim[1] - xlim[0]) * 0.60
bar_y = ylim[0] + (ylim[1] - ylim[0]) * 0.06
bar_length = 100_000   # 100 km in meters
ax.plot([bar_x_start, bar_x_start + bar_length], [bar_y, bar_y],
        "k-", linewidth=3, solid_capstyle="butt", zorder=10)
ax.text(bar_x_start + bar_length / 2, bar_y + (ylim[1] - ylim[0]) * 0.012,
        "100 km", ha="center", va="bottom", fontsize=7, zorder=10)

# North arrow
ax.annotate("N", xy=(xlim[1] - (xlim[1]-xlim[0])*0.05,
                      ylim[1] - (ylim[1]-ylim[0])*0.07),
            fontsize=12, fontweight="bold", ha="center", va="center")
ax.annotate("", xy=(xlim[1] - (xlim[1]-xlim[0])*0.05,
                     ylim[1] - (ylim[1]-ylim[0])*0.04),
            xytext=(xlim[1] - (xlim[1]-xlim[0])*0.05,
                    ylim[1] - (ylim[1]-ylim[0])*0.12),
            arrowprops=dict(arrowstyle="->", color="black", lw=1.5))

ax.set_title("D — Composite Hypoxia Risk Classification\n"
             "(0.4×Agriculture + 0.4×Precipitation + 0.2×(1−DO))",
             fontweight="bold", fontsize=11)
ax.set_xlabel("Easting (m)", fontsize=8)
ax.tick_params(labelsize=7)
ax.grid(True, linestyle="--", linewidth=0.25, alpha=0.4)

plt.tight_layout()
plt.savefig("ex10_risk_assessment.png", dpi=150, bbox_inches="tight")
plt.close()
print("\nFigure saved: ex10_risk_assessment.png")

# --- Interpretive caption ---
print("""
INTERPRETIVE CAPTION:
  Panel A shows that the Coastal Plain and lower Susquehanna sub-watersheds
  carry the highest agricultural cover, the primary source of nitrogen and
  phosphorus loading to the Chesapeake Bay. Panel B shows a broadly uniform
  precipitation pattern (approximately 1,000–1,200 mm/yr) across the watershed,
  with slightly elevated totals in the western Appalachian highlands, reflecting
  orographic enhancement. Panel C confirms that dissolved oxygen is lowest at
  stations in the tidally influenced, nutrient-rich zones of the main stem and
  lower tributaries, consistent with eutrophic conditions. Panel D integrates
  all three indicators: several lower-Susquehanna and Eastern Shore sub-watersheds
  receive High Risk classifications, identifying them as priority targets for
  agricultural best-management practices and riparian buffer programs.
""")

print("\n" + "=" * 70)
print("All 10 exercises complete.")
print("Output figures: ex01_stations.png through ex10_risk_assessment.png")
print("=" * 70)
