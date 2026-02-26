"""
Generate all figures for Lecture 05: Spatial Data and Mapping
Run with: /Users/akashkoppa/miniforge3/envs/geospatial/bin/python generate_figures.py
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.patheffects as pe
from matplotlib.collections import PatchCollection, LineCollection
from matplotlib.colors import Normalize, LinearSegmentedColormap
import matplotlib.gridspec as gridspec
import geopandas as gpd
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import cartopy.io.shapereader as shpreader
from shapely.geometry import Point, LineString, Polygon, MultiPoint, box
from shapely.ops import voronoi_diagram, unary_union
from scipy.spatial import Voronoi
import warnings
warnings.filterwarnings('ignore')

# --- Style constants ---
SAGE = '#2d5a27'
STEEL = '#457b9d'
CHARCOAL = '#2f2f2f'
CREAM = '#fdfdfc'
RED = '#c44536'
PURPLE = '#6a4c93'
BROWN = '#b5651d'
DPI = 200
OUTDIR = '/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/05_Spatial'

plt.rcParams.update({
    'font.family': 'sans-serif',
    'font.size': 11,
    'axes.facecolor': CREAM,
    'figure.facecolor': CREAM,
    'text.color': CHARCOAL,
    'axes.edgecolor': '#cccccc',
    'axes.labelcolor': CHARCOAL,
    'xtick.color': CHARCOAL,
    'ytick.color': CHARCOAL,
})


# =========================================================================
# FIGURE 1: Vector vs. Raster (conceptual side-by-side)
# =========================================================================
def fig01_vector_vs_raster():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5.5))

    # --- Vector side ---
    ax1.set_title('Vector Model', fontsize=16, fontweight='bold', color=SAGE, pad=12)
    ax1.set_xlim(0, 10); ax1.set_ylim(0, 10)
    ax1.set_aspect('equal')

    # Polygon: lake
    lake = mpatches.FancyBboxPatch((1.5, 5.5), 3, 2.5, boxstyle="round,pad=0.3",
                                     facecolor='#a8d5e2', edgecolor=STEEL, linewidth=2)
    ax1.add_patch(lake)
    ax1.text(3, 6.75, 'Lake\n(Polygon)', ha='center', va='center', fontsize=9, color=STEEL, fontweight='bold')

    # Polygon: forest
    forest_coords = np.array([[5.5, 1], [9, 1], [9.5, 4], [8, 5.5], [5, 4]])
    forest = mpatches.Polygon(forest_coords, closed=True, facecolor='#c8e6c9', edgecolor=SAGE, linewidth=2)
    ax1.add_patch(forest)
    ax1.text(7.2, 3, 'Forest\n(Polygon)', ha='center', va='center', fontsize=9, color=SAGE, fontweight='bold')

    # Line: road
    road_x = [0.5, 2.5, 5, 7, 9.5]
    road_y = [8.5, 7, 5.2, 6.5, 9]
    ax1.plot(road_x, road_y, color='#666666', linewidth=3, solid_capstyle='round')
    ax1.text(5.5, 5.8, 'Road (Line)', fontsize=9, color='#444444', fontweight='bold')

    # Line: river
    river_x = [0.5, 1.5, 2, 3, 4.5, 5.5, 6, 7.5]
    river_y = [3.5, 4.2, 5, 5.5, 5.5, 4.5, 3.5, 2.5]
    ax1.plot(river_x, river_y, color=STEEL, linewidth=2.5, linestyle='-', solid_capstyle='round')
    ax1.text(0.7, 3, 'River (Line)', fontsize=9, color=STEEL, fontweight='bold')

    # Points: stations
    pts_x = [1, 4.5, 8, 6, 2.5]
    pts_y = [1.5, 8, 7, 1.5, 3]
    ax1.scatter(pts_x, pts_y, c=RED, s=80, zorder=5, edgecolors='white', linewidths=1.5)
    ax1.text(1, 0.8, 'Stations (Points)', fontsize=9, color=RED, fontweight='bold')

    ax1.set_xticks([]); ax1.set_yticks([])
    for spine in ax1.spines.values(): spine.set_visible(False)

    # --- Raster side ---
    ax2.set_title('Raster Model', fontsize=16, fontweight='bold', color=STEEL, pad=12)

    # Create a grid with values representing land cover
    np.random.seed(42)
    grid = np.ones((20, 20)) * 1  # background = grassland

    # Lake area
    grid[9:14, 3:9] = 3

    # Forest area
    for i in range(20):
        for j in range(20):
            if 2 <= i <= 10 and (j >= 10 + (i-6)*0.5 and j <= 18):
                grid[i, j] = 2
            if 3 <= i <= 9 and (j >= 11 and j <= 19 - abs(i-6)*0.8):
                grid[i, j] = 2

    # Road pixels
    for k, (rx, ry) in enumerate(zip([0,1,3,5,7,9,11,13,15,17,19], [17,16,14,12,11,12,13,14,16,17,18])):
        if rx < 20 and ry < 20:
            grid[20-1-ry, rx] = 4

    cmap = plt.cm.colors.ListedColormap(['#e8dcc8', '#c8e6c9', '#a8d5e2', '#888888'])
    ax2.imshow(grid, cmap=cmap, interpolation='nearest', aspect='equal')

    # Grid lines
    for i in range(21):
        ax2.axhline(i - 0.5, color='white', linewidth=0.5, alpha=0.7)
        ax2.axvline(i - 0.5, color='white', linewidth=0.5, alpha=0.7)

    ax2.set_xticks([]); ax2.set_yticks([])
    for spine in ax2.spines.values(): spine.set_visible(False)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#e8dcc8', edgecolor='gray', label='Grassland'),
        mpatches.Patch(facecolor='#c8e6c9', edgecolor='gray', label='Forest'),
        mpatches.Patch(facecolor='#a8d5e2', edgecolor='gray', label='Water'),
        mpatches.Patch(facecolor='#888888', edgecolor='gray', label='Road'),
    ]
    ax2.legend(handles=legend_elements, loc='lower right', fontsize=9, framealpha=0.9)

    plt.tight_layout(pad=1.5)
    plt.savefig(f'{OUTDIR}/05_vector_vs_raster.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [1/20] vector_vs_raster')


# =========================================================================
# FIGURE 2: Chesapeake Bay monitoring stations (points, colored by DO)
# =========================================================================
def fig02_chesapeake_stations():
    fig, ax = plt.subplots(figsize=(6, 8), subplot_kw={'projection': ccrs.PlateCarree()})

    ax.set_extent([-77.5, -75.5, 36.8, 39.7], crs=ccrs.PlateCarree())
    ax.add_feature(cfeature.LAND, facecolor='#f0ece3', edgecolor='none')
    ax.add_feature(cfeature.OCEAN, facecolor='#dceaf7')
    ax.add_feature(cfeature.COASTLINE, linewidth=0.8, color='#888888')
    ax.add_feature(cfeature.RIVERS, linewidth=0.5, color='#a8d5e2')
    ax.add_feature(cfeature.STATES, linewidth=0.5, edgecolor='#aaaaaa')

    # Synthetic station data along Chesapeake Bay
    np.random.seed(123)
    n = 60
    lons = np.random.uniform(-77.2, -75.8, n)
    lats = np.random.uniform(37.0, 39.5, n)
    # Filter to roughly within the bay area
    mask = (lats > 37 + (lons + 76.5) * 1.5) & (lats < 39.5 + (lons + 76) * 0.5)
    lons, lats = lons[mask], lats[mask]
    # DO inversely related to distance south (hypoxia in deeper parts)
    do_values = 3 + 5 * (lats - 37) / 2.5 + np.random.normal(0, 1, len(lats))
    do_values = np.clip(do_values, 0.5, 12)

    sc = ax.scatter(lons, lats, c=do_values, cmap='RdYlGn', s=50, edgecolors='white',
                    linewidths=0.8, zorder=5, vmin=1, vmax=10, transform=ccrs.PlateCarree())

    cbar = plt.colorbar(sc, ax=ax, shrink=0.6, pad=0.02, aspect=25)
    cbar.set_label('Dissolved Oxygen (mg/L)', fontsize=10)

    ax.set_title('Chesapeake Bay Monitoring Stations', fontsize=14, fontweight='bold', color=SAGE, pad=10)

    gl = ax.gridlines(draw_labels=True, linewidth=0.3, color='gray', alpha=0.5)
    gl.top_labels = False; gl.right_labels = False
    gl.xlabel_style = {'size': 8}; gl.ylabel_style = {'size': 8}

    plt.savefig(f'{OUTDIR}/05_chesapeake_stations.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [2/20] chesapeake_stations')


# =========================================================================
# FIGURE 3: Global earthquake epicenters
# =========================================================================
def fig03_earthquake_map():
    fig, ax = plt.subplots(figsize=(12, 6), subplot_kw={'projection': ccrs.Robinson()})

    ax.set_global()
    ax.add_feature(cfeature.LAND, facecolor='#f0ece3', edgecolor='none')
    ax.add_feature(cfeature.OCEAN, facecolor='#dceaf7')
    ax.add_feature(cfeature.COASTLINE, linewidth=0.4, color='#999999')

    # Synthetic earthquake data along plate boundaries
    np.random.seed(77)
    # Ring of Fire
    ring_lons = np.concatenate([
        np.random.uniform(120, 150, 80),  # Japan/Philippines
        np.random.uniform(150, 180, 40),  # Pacific
        np.random.uniform(-180, -160, 30),  # Aleutians
        np.random.uniform(-80, -65, 60),  # South America west coast
        np.random.uniform(-130, -110, 30),  # Cascadia
    ])
    ring_lats = np.concatenate([
        np.random.uniform(10, 45, 80),
        np.random.uniform(-20, 10, 40),
        np.random.uniform(50, 55, 30),
        np.random.uniform(-40, 10, 60),
        np.random.uniform(35, 50, 30),
    ])
    # Mid-Atlantic Ridge
    mar_lons = np.random.uniform(-40, -10, 50) + np.random.normal(0, 3, 50)
    mar_lats = np.random.uniform(-30, 60, 50)
    # Himalayan belt
    him_lons = np.random.uniform(25, 95, 60)
    him_lats = np.random.uniform(25, 42, 60)
    # East African Rift
    ear_lons = np.random.uniform(28, 42, 25)
    ear_lats = np.random.uniform(-15, 12, 25)

    all_lons = np.concatenate([ring_lons, mar_lons, him_lons, ear_lons])
    all_lats = np.concatenate([ring_lats, mar_lats, him_lats, ear_lats])
    all_lons += np.random.normal(0, 2, len(all_lons))
    all_lats += np.random.normal(0, 1.5, len(all_lats))
    magnitudes = np.random.exponential(1.2, len(all_lons)) + 3
    magnitudes = np.clip(magnitudes, 3, 9)

    sc = ax.scatter(all_lons, all_lats, c=magnitudes, cmap='YlOrRd', s=magnitudes**1.5 * 1.5,
                    alpha=0.6, edgecolors='none', transform=ccrs.PlateCarree(), vmin=3, vmax=8)

    cbar = plt.colorbar(sc, ax=ax, shrink=0.5, pad=0.02, aspect=25, orientation='horizontal')
    cbar.set_label('Magnitude', fontsize=10)

    ax.set_title('Global Earthquake Epicenters', fontsize=14, fontweight='bold', color=SAGE, pad=10)

    plt.savefig(f'{OUTDIR}/05_earthquake_map.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [3/20] earthquake_map')


# =========================================================================
# FIGURE 4: Voronoi tessellation / station coverage gaps
# =========================================================================
def fig04_voronoi_coverage():
    fig, ax = plt.subplots(figsize=(7, 8))

    np.random.seed(42)
    # Stations clustered in some areas, sparse in others
    n = 35
    lons = np.concatenate([
        np.random.uniform(-77, -76.2, 20),  # dense cluster
        np.random.uniform(-76.8, -75.8, 10),  # moderate
        np.array([-76.5, -76.8, -76.2, -75.9, -77.1]),  # sparse outliers
    ])
    lats = np.concatenate([
        np.random.uniform(38.5, 39.5, 20),
        np.random.uniform(37.5, 38.5, 10),
        np.array([37.2, 37.0, 37.5, 37.8, 37.3]),
    ])

    # Voronoi
    points = np.column_stack([lons, lats])
    vor = Voronoi(points)

    # Bay outline (simplified)
    bay = Polygon([(-77.3, 36.8), (-77.3, 39.7), (-75.5, 39.7), (-75.5, 36.8)])

    # Draw Voronoi regions
    from matplotlib.collections import PolyCollection
    regions = []
    for region_idx in vor.regions:
        if not region_idx or -1 in region_idx:
            continue
        polygon = [vor.vertices[i] for i in region_idx]
        regions.append(polygon)

    # Compute areas for coloring
    ax.set_xlim(-77.3, -75.5)
    ax.set_ylim(36.8, 39.7)

    # Draw Voronoi edges
    for simplex in vor.ridge_vertices:
        if -1 not in simplex:
            x = [vor.vertices[simplex[0], 0], vor.vertices[simplex[1], 0]]
            y = [vor.vertices[simplex[0], 1], vor.vertices[simplex[1], 1]]
            ax.plot(x, y, color=STEEL, linewidth=0.8, alpha=0.6)

    # Highlight gap area
    gap_rect = mpatches.FancyBboxPatch((-76.8, 37.0), 0.8, 0.7,
                                        boxstyle="round,pad=0.05",
                                        facecolor=RED, alpha=0.12, edgecolor=RED,
                                        linewidth=2, linestyle='--')
    ax.add_patch(gap_rect)
    ax.text(-76.4, 37.75, 'Coverage\nGap', fontsize=12, color=RED, fontweight='bold',
            ha='center', va='center')

    # Stations
    ax.scatter(lons, lats, c=SAGE, s=60, zorder=5, edgecolors='white', linewidths=1.2)

    # Suggested new station
    ax.scatter([-76.4], [37.35], c='gold', s=150, zorder=6, edgecolors=RED,
               linewidths=2, marker='*')
    ax.text(-76.25, 37.35, 'New station?', fontsize=10, color=RED, fontweight='bold')

    ax.set_xlabel('Longitude', fontsize=10)
    ax.set_ylabel('Latitude', fontsize=10)
    ax.set_title('Station Network with Voronoi Tessellation', fontsize=14,
                 fontweight='bold', color=SAGE, pad=10)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_voronoi_coverage.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [4/20] voronoi_coverage')


# =========================================================================
# FIGURE 5: Stream network (synthetic, colored by stream order)
# =========================================================================
def fig05_stream_network():
    fig, ax = plt.subplots(figsize=(7, 8))

    # Synthetic dendritic stream network
    np.random.seed(99)
    segments = []
    orders = []

    # Main stem (order 4)
    main_x = [5, 5.1, 5.3, 5.2, 5.0, 4.8, 4.9, 5.0]
    main_y = [0.5, 1.5, 3, 4.5, 6, 7.5, 8.5, 9.5]
    segments.append(list(zip(main_x, main_y)))
    orders.append(4)

    # Order 3 tributaries
    tribs3 = [
        [(3, 5), (3.5, 5.5), (4.2, 5.8), (4.8, 6)],
        [(7, 4), (6.5, 4.5), (5.8, 4.8), (5.3, 5.1)],
        [(3.5, 8), (4, 8.2), (4.5, 8.4), (4.9, 8.5)],
        [(6.5, 7), (6, 7.2), (5.5, 7.5), (5.0, 7.5)],
    ]
    for t in tribs3:
        segments.append(t)
        orders.append(3)

    # Order 2 sub-tributaries
    tribs2 = [
        [(1.5, 4), (2, 4.5), (2.8, 4.9), (3, 5)],
        [(2, 6), (2.5, 5.8), (3, 5.5), (3.5, 5.5)],
        [(8, 3), (7.5, 3.5), (7, 3.8), (6.5, 4)],
        [(8.5, 5), (7.8, 4.7), (7.2, 4.3), (6.5, 4)],
        [(2, 8.5), (2.5, 8.3), (3, 8.1), (3.5, 8)],
        [(3, 9.5), (3.3, 9), (3.8, 8.5), (4, 8.2)],
        [(8, 6.5), (7.5, 6.8), (6.8, 7), (6.5, 7)],
        [(7, 8), (6.5, 7.7), (6.2, 7.4), (6, 7.2)],
    ]
    for t in tribs2:
        segments.append(t)
        orders.append(2)

    # Order 1 headwaters (short)
    tribs1 = [
        [(0.5, 3.5), (1, 3.8), (1.5, 4)],
        [(1, 3), (1.3, 3.5), (1.5, 4)],
        [(1, 6.5), (1.5, 6.2), (2, 6)],
        [(1.5, 7), (1.8, 6.5), (2, 6)],
        [(9, 2.5), (8.5, 2.8), (8, 3)],
        [(9.5, 3.5), (9, 3.3), (8.5, 3.2)],
        [(9, 5.5), (8.8, 5.2), (8.5, 5)],
        [(9.5, 4.5), (9, 4.8), (8.5, 5)],
        [(1, 9), (1.5, 8.8), (2, 8.5)],
        [(1.5, 9.5), (2, 9.2), (2.5, 8.9)],
        [(2.5, 10), (2.8, 9.5), (3, 9.5)],
        [(9, 6), (8.5, 6.3), (8, 6.5)],
        [(8.5, 7.5), (8, 7.2), (7.5, 7)],
        [(7.5, 8.5), (7.2, 8.2), (7, 8)],
    ]
    for t in tribs1:
        segments.append(t)
        orders.append(1)

    # Color and width by order
    colors_map = {1: '#a8d5e2', 2: '#5ba3c9', 3: STEEL, 4: '#1a3a5c'}
    widths_map = {1: 1, 2: 1.8, 3: 3, 4: 4.5}

    for seg, order in zip(segments, orders):
        xs, ys = zip(*seg)
        ax.plot(xs, ys, color=colors_map[order], linewidth=widths_map[order],
                solid_capstyle='round', zorder=order)

    # Legend
    for order in [1, 2, 3, 4]:
        ax.plot([], [], color=colors_map[order], linewidth=widths_map[order],
                label=f'Order {order}')

    ax.legend(loc='lower right', fontsize=10, framealpha=0.9, title='Strahler Order',
              title_fontsize=10)
    ax.set_xlim(0, 10); ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.set_xticks([]); ax.set_yticks([])
    for spine in ax.spines.values(): spine.set_linewidth(0.3)
    ax.set_title('Stream Network by Strahler Order', fontsize=14,
                 fontweight='bold', color=SAGE, pad=10)

    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_stream_network.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [5/20] stream_network')


# =========================================================================
# FIGURE 6: Chesapeake Bay watersheds (polygons colored by nitrogen)
# =========================================================================
def fig06_watersheds():
    fig, ax = plt.subplots(figsize=(7, 8))

    # Simplified Chesapeake tributary watershed polygons
    watersheds = {
        'Susquehanna': Polygon([(-77.2, 39.7), (-76.4, 39.7), (-76.2, 39.3), (-76.4, 39.0), (-77.0, 39.2)]),
        'Patuxent': Polygon([(-77.0, 39.2), (-76.4, 39.0), (-76.5, 38.6), (-76.8, 38.5), (-77.0, 38.8)]),
        'Potomac': Polygon([(-77.5, 39.2), (-77.0, 39.2), (-77.0, 38.8), (-76.8, 38.5), (-77.3, 38.3), (-77.5, 38.8)]),
        'Rappahannock': Polygon([(-77.3, 38.3), (-76.8, 38.5), (-76.5, 38.0), (-76.3, 37.8), (-77.0, 37.6), (-77.3, 37.9)]),
        'York': Polygon([(-77.0, 37.6), (-76.3, 37.8), (-76.1, 37.4), (-76.5, 37.2), (-76.9, 37.3)]),
        'James': Polygon([(-77.5, 37.6), (-77.0, 37.6), (-76.9, 37.3), (-76.5, 37.2), (-76.8, 36.8), (-77.5, 36.8)]),
    }

    nitrogen = {
        'Susquehanna': 8.2,
        'Patuxent': 5.1,
        'Potomac': 7.5,
        'Rappahannock': 3.8,
        'York': 2.9,
        'James': 6.3,
    }

    gdf = gpd.GeoDataFrame({
        'name': list(watersheds.keys()),
        'nitrogen': [nitrogen[k] for k in watersheds.keys()],
        'geometry': list(watersheds.values())
    })

    gdf.plot(ax=ax, column='nitrogen', cmap='YlOrRd', edgecolor='white',
             linewidth=2, legend=True, legend_kwds={'label': 'Total Nitrogen Load (mg/L)',
                                                     'shrink': 0.6})

    for _, row in gdf.iterrows():
        centroid = row.geometry.centroid
        ax.text(centroid.x, centroid.y, row['name'], ha='center', va='center',
                fontsize=9, fontweight='bold', color='#333333',
                path_effects=[pe.withStroke(linewidth=2, foreground='white')])

    ax.set_xlim(-77.6, -76.0)
    ax.set_ylim(36.7, 39.8)
    ax.set_xlabel('Longitude', fontsize=10)
    ax.set_ylabel('Latitude', fontsize=10)
    ax.set_title('Chesapeake Bay Tributary Watersheds', fontsize=14,
                 fontweight='bold', color=SAGE, pad=10)

    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_watersheds.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [6/20] watersheds')


# =========================================================================
# FIGURE 7: Flood zone overlay (conceptual)
# =========================================================================
def fig07_flood_overlay():
    fig, ax = plt.subplots(figsize=(10, 6))

    # Census tracts as a grid of rectangles
    for i in range(5):
        for j in range(4):
            rect = mpatches.Rectangle((i*2, j*2), 2, 2, linewidth=1.2,
                                       edgecolor='#888888', facecolor='#f5f5f0')
            ax.add_patch(rect)
            ax.text(i*2+1, j*2+1, f'Tract\n{i*4+j+1}', ha='center', va='center',
                    fontsize=7, color='#666666')

    # Flood zone as an irregular polygon
    flood_x = [0.5, 2, 4, 6, 8, 9.5, 9, 7, 5, 3, 1]
    flood_y = [2, 3.5, 4.5, 5, 4, 3, 1.5, 1, 0.5, 1, 1.5]
    flood = mpatches.Polygon(list(zip(flood_x, flood_y)), closed=True,
                              facecolor=STEEL, alpha=0.25, edgecolor=STEEL,
                              linewidth=2.5, linestyle='-')
    ax.add_patch(flood)

    # Highlight intersection areas
    intersect_patches = [
        mpatches.Rectangle((0.5, 1.5), 1.5, 0.5, facecolor=RED, alpha=0.3),
        mpatches.Rectangle((2, 2), 2, 2, facecolor=RED, alpha=0.3),
        mpatches.Rectangle((4, 2), 2, 2.5, facecolor=RED, alpha=0.3),
        mpatches.Rectangle((6, 2), 2, 2, facecolor=RED, alpha=0.3),
    ]
    for p in intersect_patches:
        ax.add_patch(p)

    ax.set_xlim(-0.3, 10.3); ax.set_ylim(-0.3, 8.3)
    ax.set_aspect('equal')
    ax.set_xticks([]); ax.set_yticks([])
    for spine in ax.spines.values(): spine.set_visible(False)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#f5f5f0', edgecolor='#888888', label='Census Tracts'),
        mpatches.Patch(facecolor=STEEL, alpha=0.3, edgecolor=STEEL, label='Flood Zone'),
        mpatches.Patch(facecolor=RED, alpha=0.3, label='Intersection (at-risk population)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10, framealpha=0.9)
    ax.set_title('Spatial Intersection: Flood Zone and Census Tracts', fontsize=14,
                 fontweight='bold', color=SAGE, pad=10)

    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_flood_overlay.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [7/20] flood_overlay')


# =========================================================================
# FIGURE 8: Raster concept - satellite with pixel zoom
# =========================================================================
def fig08_raster_concept():
    fig = plt.figure(figsize=(12, 6))
    gs = gridspec.GridSpec(1, 2, width_ratios=[3, 2], wspace=0.3)

    # Left: simulated "satellite image"
    ax1 = fig.add_subplot(gs[0])
    np.random.seed(10)
    # Create a landscape
    from scipy.ndimage import gaussian_filter
    base = np.random.rand(100, 120)
    landscape = gaussian_filter(base, sigma=8)
    # Add "water" channel
    landscape[35:45, :] = landscape[35:45, :] * 0.3
    landscape[40:50, 60:] = landscape[40:50, 60:] * 0.3
    # Add "forest" areas
    landscape[:30, :50] += 0.3
    landscape[:30, :50] = np.clip(landscape[:30, :50], 0, 1)

    cmap_land = LinearSegmentedColormap.from_list('land',
        ['#2a5e1e', '#5a8a4f', '#8ab87a', '#c8d6a0', '#e8dcc8', '#d4a76a'])
    ax1.imshow(landscape, cmap=cmap_land, aspect='equal')
    ax1.set_title('Satellite View (Landsat, 30 m)', fontsize=13, fontweight='bold', color=SAGE)
    ax1.set_xticks([]); ax1.set_yticks([])

    # Draw zoom box
    rect = mpatches.Rectangle((65, 25), 25, 25, linewidth=2, edgecolor=RED, facecolor='none')
    ax1.add_patch(rect)
    ax1.annotate('', xy=(91, 37), xytext=(105, 20),
                 arrowprops=dict(arrowstyle='->', color=RED, lw=2))

    # Right: zoomed in showing individual pixels
    ax2 = fig.add_subplot(gs[1])
    zoomed = landscape[25:50, 65:90]
    # Show as discrete pixels
    ax2.imshow(zoomed, cmap=cmap_land, aspect='equal', interpolation='nearest')
    # Grid lines for pixels
    for i in range(26):
        ax2.axhline(i - 0.5, color='white', linewidth=0.5, alpha=0.5)
        ax2.axvline(i - 0.5, color='white', linewidth=0.5, alpha=0.5)
    ax2.set_title('Zoomed: Individual 30 m Pixels', fontsize=13, fontweight='bold', color=SAGE)
    ax2.set_xticks([]); ax2.set_yticks([])

    # Add some pixel value annotations
    for i in range(3):
        for j in range(3):
            val = zoomed[i+10, j+10]
            ax2.text(j+10, i+10, f'{val:.2f}', ha='center', va='center',
                     fontsize=7, color='white' if val < 0.5 else 'black',
                     fontweight='bold')

    plt.savefig(f'{OUTDIR}/05_raster_concept.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [8/20] raster_concept')


# =========================================================================
# FIGURE 9: NDVI map (simulated)
# =========================================================================
def fig09_ndvi_map():
    fig, ax = plt.subplots(figsize=(8, 6))

    np.random.seed(55)
    from scipy.ndimage import gaussian_filter

    # Create NDVI-like surface
    base = np.random.rand(80, 100)
    ndvi = gaussian_filter(base, sigma=6)
    # Scale to NDVI range
    ndvi = ndvi * 0.8 - 0.1
    # Add water body (negative NDVI)
    ndvi[30:40, 40:70] = -0.2
    ndvi[35:45, 55:80] = -0.15
    # Add urban area (low NDVI)
    ndvi[55:70, 20:45] = np.random.uniform(0.05, 0.15, (15, 25))
    # Add dense forest (high NDVI)
    ndvi[:25, :35] = np.clip(ndvi[:25, :35] + 0.25, 0, 0.85)

    ndvi_cmap = LinearSegmentedColormap.from_list('ndvi',
        ['#1a3399', '#4a7bb7', '#abd9e9', '#e8dcc8', '#d4a76a',
         '#c8d6a0', '#8ab87a', '#5a8a4f', '#2a5e1e'])

    im = ax.imshow(ndvi, cmap=ndvi_cmap, vmin=-0.3, vmax=0.85, aspect='equal')
    cbar = plt.colorbar(im, ax=ax, shrink=0.8, pad=0.02)
    cbar.set_label('NDVI', fontsize=11)

    # Annotations
    ax.annotate('Water', xy=(55, 35), fontsize=10, color='white', fontweight='bold',
                ha='center')
    ax.annotate('Dense\nVegetation', xy=(15, 12), fontsize=10, color='white',
                fontweight='bold', ha='center')
    ax.annotate('Urban', xy=(32, 62), fontsize=10, color='#333333',
                fontweight='bold', ha='center')

    ax.set_xticks([]); ax.set_yticks([])
    ax.set_title('NDVI: Normalized Difference Vegetation Index', fontsize=14,
                 fontweight='bold', color=SAGE, pad=10)

    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_ndvi_map.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [9/20] ndvi_map')


# =========================================================================
# FIGURE 10: Resolution comparison (3 panels)
# =========================================================================
def fig10_resolution():
    fig, axes = plt.subplots(1, 3, figsize=(12, 4.5))

    np.random.seed(42)
    from scipy.ndimage import gaussian_filter

    # Base high-resolution image
    hi_res = gaussian_filter(np.random.rand(200, 200), sigma=10)
    # Add features
    hi_res[60:80, 80:120] = 0.1  # water
    hi_res[:50, :60] += 0.3  # forest

    resolutions = [
        ('10 m Resolution', hi_res, 'Individual fields\nand buildings visible'),
        ('500 m Resolution', hi_res.reshape(10, 20, 10, 20).mean(axis=(1,3)), 'Landscape patterns\nvisible'),
        ('25 km Resolution', hi_res.reshape(4, 50, 4, 50).mean(axis=(1,3)), 'Climate-scale\nfeatures only'),
    ]

    cmap_land = LinearSegmentedColormap.from_list('land2',
        ['#2a5e1e', '#5a8a4f', '#8ab87a', '#c8d6a0', '#e8dcc8'])

    for ax, (title, data, desc) in zip(axes, resolutions):
        ax.imshow(data, cmap=cmap_land, interpolation='nearest', aspect='equal')
        if data.shape[0] < 50:
            for i in range(data.shape[0] + 1):
                ax.axhline(i - 0.5, color='white', linewidth=0.3, alpha=0.5)
            for j in range(data.shape[1] + 1):
                ax.axvline(j - 0.5, color='white', linewidth=0.3, alpha=0.5)
        ax.set_title(title, fontsize=12, fontweight='bold', color=SAGE)
        ax.set_xticks([]); ax.set_yticks([])
        ax.text(0.5, -0.08, desc, transform=ax.transAxes, ha='center',
                fontsize=9, style='italic', color='#666666')

    plt.tight_layout(pad=1.5)
    plt.savefig(f'{OUTDIR}/05_resolution.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [10/20] resolution')


# =========================================================================
# FIGURE 11: CRS concept diagram
# =========================================================================
def fig11_crs_diagram():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Geographic CRS (globe-like)
    ax1.set_title('Geographic CRS\n(Degrees: Longitude, Latitude)', fontsize=13,
                  fontweight='bold', color=SAGE, pad=10)
    theta = np.linspace(0, 2*np.pi, 100)
    ax1.plot(np.cos(theta) * 3, np.sin(theta) * 3, color=STEEL, linewidth=2)

    # Grid lines on globe
    for lat in np.linspace(-60, 60, 5):
        r = np.cos(np.radians(lat)) * 3
        y = np.sin(np.radians(lat)) * 3
        ax1.plot(np.linspace(-r, r, 50), [y]*50, color='#cccccc', linewidth=0.5)
    for lon in np.linspace(-90, 90, 7):
        scale = np.cos(np.radians(lon))
        t = np.linspace(-np.pi/2, np.pi/2, 50)
        ax1.plot(np.sin(t) * 3 * scale, np.cos(t) * 3 * np.sin(np.linspace(0, np.pi, 50)),
                 color='#cccccc', linewidth=0.5)

    # Mark a point
    ax1.scatter([1.5], [1.2], c=RED, s=100, zorder=5)
    ax1.annotate('(38.9\u00b0N, 76.5\u00b0W)', xy=(1.5, 1.2), xytext=(1.8, 2.2),
                 fontsize=10, color=RED, fontweight='bold',
                 arrowprops=dict(arrowstyle='->', color=RED))

    ax1.set_xlim(-4, 4); ax1.set_ylim(-4, 4)
    ax1.set_aspect('equal')
    ax1.set_xticks([]); ax1.set_yticks([])
    for spine in ax1.spines.values(): spine.set_visible(False)
    ax1.text(0, -3.5, 'Units: degrees (\u00b0)', ha='center', fontsize=10, color='#666666')

    # Right: Projected CRS (flat grid)
    ax2.set_title('Projected CRS\n(Meters: Easting, Northing)', fontsize=13,
                  fontweight='bold', color=STEEL, pad=10)

    # Grid
    for x in range(0, 11):
        ax2.axvline(x, color='#dddddd', linewidth=0.5)
    for y in range(0, 11):
        ax2.axhline(y, color='#dddddd', linewidth=0.5)

    # Outline
    rect = mpatches.Rectangle((0, 0), 10, 10, linewidth=2,
                               edgecolor=STEEL, facecolor='#f0f7fa')
    ax2.add_patch(rect)

    # Mark same point
    ax2.scatter([6], [7], c=RED, s=100, zorder=5)
    ax2.annotate('(356,000 E, 4,307,000 N)', xy=(6, 7), xytext=(6.5, 8.5),
                 fontsize=10, color=RED, fontweight='bold',
                 arrowprops=dict(arrowstyle='->', color=RED))

    ax2.set_xlim(-0.5, 10.5); ax2.set_ylim(-0.5, 10.5)
    ax2.set_aspect('equal')
    ax2.set_xticks([]); ax2.set_yticks([])
    for spine in ax2.spines.values(): spine.set_visible(False)
    ax2.text(5, -0.3, 'Units: meters (m)', ha='center', fontsize=10, color='#666666')

    # Arrow between
    fig.text(0.5, 0.5, '\u2192', fontsize=40, ha='center', va='center',
             color=SAGE, fontweight='bold', transform=fig.transFigure)
    fig.text(0.5, 0.42, 'Projection', fontsize=11, ha='center', va='center',
             color=SAGE, fontweight='bold', transform=fig.transFigure)

    plt.tight_layout(w_pad=4)
    plt.savefig(f'{OUTDIR}/05_crs_diagram.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [11/20] crs_diagram')


# =========================================================================
# FIGURES 12-14: Three projections
# =========================================================================
def fig12_mercator():
    fig, ax = plt.subplots(figsize=(6, 5), subplot_kw={'projection': ccrs.Mercator()})
    ax.set_global()
    ax.add_feature(cfeature.LAND, facecolor='#e8dcc8', edgecolor='#999999', linewidth=0.5)
    ax.add_feature(cfeature.OCEAN, facecolor='#dceaf7')
    ax.gridlines(linewidth=0.3, color='gray', alpha=0.5)
    ax.set_title('Mercator (Conformal)', fontsize=13, fontweight='bold', color=SAGE, pad=10)
    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_proj_mercator.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [12/20] proj_mercator')


def fig13_mollweide():
    fig, ax = plt.subplots(figsize=(6, 5), subplot_kw={'projection': ccrs.Mollweide()})
    ax.set_global()
    ax.add_feature(cfeature.LAND, facecolor='#e8dcc8', edgecolor='#999999', linewidth=0.5)
    ax.add_feature(cfeature.OCEAN, facecolor='#dceaf7')
    ax.gridlines(linewidth=0.3, color='gray', alpha=0.5)
    ax.set_title('Mollweide (Equal-Area)', fontsize=13, fontweight='bold', color=STEEL, pad=10)
    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_proj_mollweide.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [13/20] proj_mollweide')


def fig14_azimuthal():
    fig, ax = plt.subplots(figsize=(6, 5),
                            subplot_kw={'projection': ccrs.AzimuthalEquidistant(
                                central_longitude=-76.5, central_latitude=39)})
    ax.set_global()
    ax.add_feature(cfeature.LAND, facecolor='#e8dcc8', edgecolor='#999999', linewidth=0.5)
    ax.add_feature(cfeature.OCEAN, facecolor='#dceaf7')
    ax.gridlines(linewidth=0.3, color='gray', alpha=0.5)
    # Mark center
    ax.plot(-76.5, 39, 'o', color=RED, markersize=8, transform=ccrs.PlateCarree(), zorder=5)
    ax.set_title('Azimuthal Equidistant', fontsize=13, fontweight='bold', color=BROWN, pad=10)
    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_proj_azimuthal.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [14/20] proj_azimuthal')


# =========================================================================
# FIGURE 15: Mercator vs Equal-Area (country size comparison)
# =========================================================================
def fig15_mercator_vs_equalarea():
    fig = plt.figure(figsize=(14, 5))
    ax1 = fig.add_subplot(1, 2, 1, projection=ccrs.Mercator())
    ax2 = fig.add_subplot(1, 2, 2, projection=ccrs.Mollweide())

    for ax in [ax1, ax2]:
        ax.set_global()
        ax.add_feature(cfeature.OCEAN, facecolor='#dceaf7')
        ax.add_feature(cfeature.COASTLINE, linewidth=0.4, color='#999999')

    # Get countries
    shpfile = shpreader.natural_earth(resolution='110m', category='cultural',
                                       name='admin_0_countries')

    highlight = {
        'Greenland': '#7eb5d6',
        'Brazil': '#8ab87a',
        'Russia': '#d4a76a',
        'Australia': '#e6b89c',
        'India': '#c8a2c8',
        'United States of America': '#f0c987',
    }

    for ax in [ax1, ax2]:
        reader = shpreader.Reader(shpfile)
        for record in reader.records():
            name = record.attributes['NAME']
            if name in highlight:
                ax.add_geometries([record.geometry], ccrs.PlateCarree(),
                                  facecolor=highlight[name], edgecolor='white', linewidth=0.8)
            else:
                ax.add_geometries([record.geometry], ccrs.PlateCarree(),
                                  facecolor='#e8dcc8', edgecolor='#cccccc', linewidth=0.3)

    ax1.set_title('Mercator Projection', fontsize=13, fontweight='bold', color=SAGE)
    ax2.set_title('Equal-Area Projection (Mollweide)', fontsize=13, fontweight='bold', color=SAGE)

    # Add area facts
    fig.text(0.5, 0.02,
             'Africa (30.4M km\u00b2) is 14\u00d7 larger than Greenland (2.2M km\u00b2), '
             'but Mercator makes them look similar.',
             ha='center', fontsize=10, color='#666666', style='italic')

    plt.tight_layout(rect=[0, 0.06, 1, 1])
    plt.savefig(f'{OUTDIR}/05_mercator_vs_equalarea.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [15/20] mercator_vs_equalarea')


# =========================================================================
# FIGURE 16: Spatial operations visual guide (6 panels)
# =========================================================================
def fig16_spatial_operations():
    fig, axes = plt.subplots(2, 3, figsize=(13, 8))

    for ax in axes.flat:
        ax.set_xlim(0, 10); ax.set_ylim(0, 10)
        ax.set_aspect('equal')
        ax.set_xticks([]); ax.set_yticks([])
        for spine in ax.spines.values(): spine.set_linewidth(0.3)

    # 1. Buffer
    ax = axes[0, 0]
    ax.set_title('Buffer', fontsize=12, fontweight='bold', color=SAGE)
    river_line = LineString([(1, 2), (3, 4), (5, 3), (7, 5), (9, 4)])
    buffered = river_line.buffer(1.2)
    x_buf, y_buf = buffered.exterior.xy
    ax.fill(x_buf, y_buf, alpha=0.25, color=STEEL)
    ax.plot(x_buf, y_buf, color=STEEL, linewidth=1, linestyle='--')
    xs, ys = river_line.xy
    ax.plot(xs, ys, color=STEEL, linewidth=3, solid_capstyle='round')
    ax.text(5, 7.5, '500 m buffer zone', ha='center', fontsize=9, color=STEEL, fontweight='bold')

    # 2. Intersection
    ax = axes[0, 1]
    ax.set_title('Intersection', fontsize=12, fontweight='bold', color=SAGE)
    poly_a = Polygon([(1, 2), (6, 2), (6, 8), (1, 8)])
    poly_b = Polygon([(4, 1), (9, 1), (9, 7), (4, 7)])
    inter = poly_a.intersection(poly_b)
    xa, ya = poly_a.exterior.xy
    xb, yb = poly_b.exterior.xy
    xi, yi = inter.exterior.xy
    ax.fill(xa, ya, alpha=0.15, color=STEEL)
    ax.plot(xa, ya, color=STEEL, linewidth=1.5)
    ax.fill(xb, yb, alpha=0.15, color=BROWN)
    ax.plot(xb, yb, color=BROWN, linewidth=1.5)
    ax.fill(xi, yi, alpha=0.4, color=RED)
    ax.text(3, 9, 'Layer A', fontsize=9, color=STEEL, fontweight='bold')
    ax.text(7, 8, 'Layer B', fontsize=9, color=BROWN, fontweight='bold')
    ax.text(5, 4.5, 'A \u2229 B', fontsize=11, color=RED, fontweight='bold', ha='center')

    # 3. Spatial Join
    ax = axes[0, 2]
    ax.set_title('Spatial Join', fontsize=12, fontweight='bold', color=SAGE)
    poly1 = mpatches.FancyBboxPatch((0.5, 5), 4, 4, boxstyle="round,pad=0.2",
                                     facecolor=SAGE, alpha=0.15, edgecolor=SAGE, linewidth=1.5)
    poly2 = mpatches.FancyBboxPatch((5.5, 5), 4, 4, boxstyle="round,pad=0.2",
                                     facecolor=STEEL, alpha=0.15, edgecolor=STEEL, linewidth=1.5)
    poly3 = mpatches.FancyBboxPatch((2.5, 0.5), 5, 4, boxstyle="round,pad=0.2",
                                     facecolor=BROWN, alpha=0.15, edgecolor=BROWN, linewidth=1.5)
    ax.add_patch(poly1); ax.add_patch(poly2); ax.add_patch(poly3)
    ax.text(2.5, 9.3, 'Zone A', fontsize=8, color=SAGE, fontweight='bold', ha='center')
    ax.text(7.5, 9.3, 'Zone B', fontsize=8, color=STEEL, fontweight='bold', ha='center')
    ax.text(5, 4.8, 'Zone C', fontsize=8, color=BROWN, fontweight='bold', ha='center')
    # Points
    pts = [(2, 7), (3.5, 6.5), (7, 8), (8, 6), (4, 2), (6, 1.5), (5, 3)]
    colors_pts = [SAGE, SAGE, STEEL, STEEL, BROWN, BROWN, BROWN]
    for (px, py), c in zip(pts, colors_pts):
        ax.scatter(px, py, c=c, s=80, zorder=5, edgecolors='white', linewidths=1.2)

    # 4. Dissolve
    ax = axes[1, 0]
    ax.set_title('Dissolve', fontsize=12, fontweight='bold', color=SAGE)
    # Before: 6 counties
    counties = [
        Polygon([(0.5, 5.5), (3, 5.5), (3, 9.5), (0.5, 9.5)]),
        Polygon([(3, 5.5), (5, 5.5), (5, 9.5), (3, 9.5)]),
        Polygon([(5, 5.5), (9.5, 5.5), (9.5, 9.5), (5, 9.5)]),
        Polygon([(0.5, 0.5), (4, 0.5), (4, 5.5), (0.5, 5.5)]),
        Polygon([(4, 0.5), (7, 0.5), (7, 5.5), (4, 5.5)]),
        Polygon([(7, 0.5), (9.5, 0.5), (9.5, 5.5), (7, 5.5)]),
    ]
    state_colors = [SAGE, SAGE, SAGE, STEEL, STEEL, STEEL]
    for poly, c in zip(counties, state_colors):
        x, y = poly.exterior.xy
        ax.fill(x, y, alpha=0.2, color=c)
        ax.plot(x, y, color='#888888', linewidth=1)
    # State boundaries (merged)
    ax.plot([0.5, 9.5], [5.5, 5.5], color='#333333', linewidth=2.5)
    ax.text(5, 7.5, 'State A', ha='center', fontsize=10, color=SAGE, fontweight='bold')
    ax.text(5, 3, 'State B', ha='center', fontsize=10, color=STEEL, fontweight='bold')

    # 5. Zonal Statistics
    ax = axes[1, 1]
    ax.set_title('Zonal Statistics', fontsize=12, fontweight='bold', color=SAGE)
    np.random.seed(77)
    from scipy.ndimage import gaussian_filter
    raster = gaussian_filter(np.random.rand(20, 20), sigma=3)
    ax.imshow(raster, extent=[0, 10, 0, 10], cmap='YlGn', alpha=0.7, aspect='equal')
    # Overlay zone boundaries
    zone1 = Polygon([(1, 1), (5, 1), (5, 5), (1, 5)])
    zone2 = Polygon([(5, 4), (9, 4), (9, 9), (5, 9)])
    for zone, label, color in [(zone1, '\u03bc = 0.42', SAGE), (zone2, '\u03bc = 0.61', STEEL)]:
        x, y = zone.exterior.xy
        ax.plot(x, y, color=color, linewidth=2.5, linestyle='-')
        c = zone.centroid
        ax.text(c.x, c.y, label, ha='center', va='center', fontsize=11,
                fontweight='bold', color=color,
                path_effects=[pe.withStroke(linewidth=3, foreground='white')])

    # 6. Map Algebra
    ax = axes[1, 2]
    ax.set_title('Map Algebra', fontsize=12, fontweight='bold', color=SAGE)
    np.random.seed(22)
    nir = gaussian_filter(np.random.rand(10, 10), sigma=2) * 0.5 + 0.3
    red = gaussian_filter(np.random.rand(10, 10), sigma=2) * 0.3 + 0.1
    ndvi = (nir - red) / (nir + red)
    ax.imshow(ndvi, extent=[0, 10, 0, 10], cmap='RdYlGn', vmin=-0.2, vmax=0.8,
              interpolation='nearest', aspect='equal')
    for i in range(11):
        ax.axhline(i, color='white', linewidth=0.3, alpha=0.5)
        ax.axvline(i, color='white', linewidth=0.3, alpha=0.5)
    ax.text(5, -0.8, 'NDVI = (NIR \u2212 Red) / (NIR + Red)', ha='center',
            fontsize=9, fontweight='bold', color=SAGE)

    plt.tight_layout(pad=1.0)
    plt.savefig(f'{OUTDIR}/05_spatial_operations.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [16/20] spatial_operations')


# =========================================================================
# FIGURE 17: Protected areas + deforestation (Amazon)
# =========================================================================
def fig17_amazon_deforestation():
    fig, ax = plt.subplots(figsize=(10, 7), subplot_kw={'projection': ccrs.PlateCarree()})

    ax.set_extent([-72, -48, -15, 5], crs=ccrs.PlateCarree())
    ax.add_feature(cfeature.LAND, facecolor='#c8e6c9', edgecolor='none')
    ax.add_feature(cfeature.OCEAN, facecolor='#dceaf7')
    ax.add_feature(cfeature.BORDERS, linewidth=0.5, edgecolor='#aaaaaa')
    ax.add_feature(cfeature.COASTLINE, linewidth=0.5, color='#999999')
    ax.add_feature(cfeature.RIVERS, linewidth=0.5, color='#a8d5e2')

    # Simulated protected areas
    np.random.seed(88)
    protected_areas = [
        Polygon([(-65, -3), (-62, -3), (-62, -1), (-65, -1)]),
        Polygon([(-58, -5), (-55, -5), (-55, -2), (-58, -2)]),
        Polygon([(-68, -8), (-65, -8), (-65, -5), (-68, -5)]),
        Polygon([(-55, -10), (-52, -10), (-52, -7), (-55, -7)]),
        Polygon([(-62, 1), (-59, 1), (-59, 3), (-62, 3)]),
    ]

    for pa in protected_areas:
        x, y = pa.exterior.xy
        ax.fill(x, y, facecolor=SAGE, alpha=0.25, edgecolor=SAGE,
                linewidth=2, transform=ccrs.PlateCarree())

    # Simulated deforestation patches (red dots)
    defor_lons = np.random.uniform(-70, -50, 300)
    defor_lats = np.random.uniform(-12, 3, 300)
    # Cluster along roads (diagonal lines)
    road_mask = (np.abs(defor_lats - (-0.3 * defor_lons - 25)) < 2) | \
                (np.abs(defor_lats - (-0.5 * defor_lons - 30)) < 1.5)
    defor_lons_filtered = defor_lons[road_mask]
    defor_lats_filtered = defor_lats[road_mask]

    # Add some random deforestation
    extra_lons = np.random.uniform(-68, -52, 80)
    extra_lats = np.random.uniform(-10, 0, 80)
    all_defor_lons = np.concatenate([defor_lons_filtered, extra_lons])
    all_defor_lats = np.concatenate([defor_lats_filtered, extra_lats])

    ax.scatter(all_defor_lons, all_defor_lats, c=RED, s=8, alpha=0.5,
               transform=ccrs.PlateCarree(), zorder=3, edgecolors='none')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor=SAGE, alpha=0.3, edgecolor=SAGE, label='Protected Areas'),
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor=RED, markersize=8,
                   alpha=0.6, label='Tree Cover Loss'),
    ]
    ax.legend(handles=legend_elements, loc='lower left', fontsize=10, framealpha=0.9)

    gl = ax.gridlines(draw_labels=True, linewidth=0.3, color='gray', alpha=0.5)
    gl.top_labels = False; gl.right_labels = False
    gl.xlabel_style = {'size': 8}; gl.ylabel_style = {'size': 8}

    ax.set_title('Amazon: Protected Areas and Tree Cover Loss', fontsize=14,
                 fontweight='bold', color=SAGE, pad=10)

    plt.tight_layout()
    plt.savefig(f'{OUTDIR}/05_amazon_deforestation.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [17/20] amazon_deforestation')


# =========================================================================
# FIGURES 18-19: Good map vs. Bad map
# =========================================================================
def fig18_bad_map():
    fig, ax = plt.subplots(figsize=(8, 6), subplot_kw={'projection': ccrs.PlateCarree()})

    ax.set_extent([-77.5, -75.5, 36.8, 39.7], crs=ccrs.PlateCarree())
    ax.add_feature(cfeature.LAND, facecolor='#eeeeee', edgecolor='none')
    ax.add_feature(cfeature.OCEAN, facecolor='white')
    ax.add_feature(cfeature.COASTLINE, linewidth=0.3)

    # Bad: rainbow colormap, no legend explanation
    np.random.seed(42)
    lons = np.random.uniform(-77.2, -75.8, 40)
    lats = np.random.uniform(37.0, 39.5, 40)
    vals = np.random.uniform(0, 100, 40)

    ax.scatter(lons, lats, c=vals, cmap='rainbow', s=100, transform=ccrs.PlateCarree(),
               edgecolors='none')

    # No title, no legend, no scale bar, cluttered annotations
    for i in range(len(lons)):
        ax.annotate(f'{vals[i]:.1f}', (lons[i], lats[i]), fontsize=6,
                    transform=ccrs.PlateCarree(), color='black')

    # 3D-like box effect (bad practice)
    ax.set_frame_on(True)
    for spine in ax.spines.values():
        spine.set_linewidth(3)
        spine.set_color('black')

    plt.savefig(f'{OUTDIR}/05_bad_map.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [18/20] bad_map')


def fig19_good_map():
    fig, ax = plt.subplots(figsize=(8, 6), subplot_kw={'projection': ccrs.PlateCarree()})

    ax.set_extent([-77.5, -75.5, 36.8, 39.7], crs=ccrs.PlateCarree())
    ax.add_feature(cfeature.LAND, facecolor='#f0ece3', edgecolor='none')
    ax.add_feature(cfeature.OCEAN, facecolor='#dceaf7')
    ax.add_feature(cfeature.COASTLINE, linewidth=0.8, color='#888888')
    ax.add_feature(cfeature.STATES, linewidth=0.5, edgecolor='#aaaaaa')

    np.random.seed(42)
    lons = np.random.uniform(-77.2, -75.8, 40)
    lats = np.random.uniform(37.0, 39.5, 40)
    vals = np.random.uniform(0, 100, 40)

    sc = ax.scatter(lons, lats, c=vals, cmap='YlOrRd', s=60, transform=ccrs.PlateCarree(),
                    edgecolors='white', linewidths=0.8, vmin=0, vmax=100)

    cbar = plt.colorbar(sc, ax=ax, shrink=0.6, pad=0.02, aspect=25)
    cbar.set_label('Nitrogen Concentration (mg/L)', fontsize=9)

    ax.set_title('Chesapeake Bay: Nitrogen Concentrations at Monitoring Stations',
                 fontsize=12, fontweight='bold', color=SAGE, pad=10)

    gl = ax.gridlines(draw_labels=True, linewidth=0.3, color='gray', alpha=0.5)
    gl.top_labels = False; gl.right_labels = False
    gl.xlabel_style = {'size': 8}; gl.ylabel_style = {'size': 8}

    # Scale bar (simplified)
    ax.plot([-77.3, -76.85], [37.0, 37.0], color='black', linewidth=2,
            transform=ccrs.PlateCarree())
    ax.text(-77.075, 36.92, '~40 km', ha='center', fontsize=8,
            transform=ccrs.PlateCarree())

    # Data source
    ax.text(0.01, 0.01, 'Data: Chesapeake Bay Program | CRS: WGS84 (EPSG:4326)',
            transform=ax.transAxes, fontsize=7, color='#888888')

    plt.savefig(f'{OUTDIR}/05_good_map.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [19/20] good_map')


# =========================================================================
# FIGURE 20: Case study final figure (choropleth + scatter inset)
# =========================================================================
def fig20_case_study():
    fig = plt.figure(figsize=(12, 7))

    # Main map
    ax_map = fig.add_axes([0.05, 0.05, 0.6, 0.85])

    # Watershed polygons with DO values
    watersheds = {
        'Susquehanna': (Polygon([(-77.2, 39.7), (-76.4, 39.7), (-76.2, 39.3), (-76.4, 39.0), (-77.0, 39.2)]), 6.8, 45),
        'Patuxent': (Polygon([(-77.0, 39.2), (-76.4, 39.0), (-76.5, 38.6), (-76.8, 38.5), (-77.0, 38.8)]), 5.1, 38),
        'Potomac': (Polygon([(-77.5, 39.2), (-77.0, 39.2), (-77.0, 38.8), (-76.8, 38.5), (-77.3, 38.3), (-77.5, 38.8)]), 4.5, 52),
        'Rappahannock': (Polygon([(-77.3, 38.3), (-76.8, 38.5), (-76.5, 38.0), (-76.3, 37.8), (-77.0, 37.6), (-77.3, 37.9)]), 6.2, 30),
        'York': (Polygon([(-77.0, 37.6), (-76.3, 37.8), (-76.1, 37.4), (-76.5, 37.2), (-76.9, 37.3)]), 7.5, 20),
        'James': (Polygon([(-77.5, 37.6), (-77.0, 37.6), (-76.9, 37.3), (-76.5, 37.2), (-76.8, 36.8), (-77.5, 36.8)]), 3.8, 62),
    }

    gdf = gpd.GeoDataFrame({
        'name': list(watersheds.keys()),
        'DO': [v[1] for v in watersheds.values()],
        'ag_pct': [v[2] for v in watersheds.values()],
        'geometry': [v[0] for v in watersheds.values()]
    })

    gdf.plot(ax=ax_map, column='DO', cmap='RdYlGn', edgecolor='white', linewidth=2,
             legend=True, legend_kwds={'label': 'Mean DO (mg/L)', 'shrink': 0.5,
                                        'orientation': 'horizontal', 'pad': 0.08})

    # Station points
    np.random.seed(42)
    for _, row in gdf.iterrows():
        bounds = row.geometry.bounds
        n_pts = np.random.randint(3, 8)
        for _ in range(n_pts):
            px = np.random.uniform(bounds[0]+0.1, bounds[2]-0.1)
            py = np.random.uniform(bounds[1]+0.1, bounds[3]-0.1)
            if row.geometry.contains(Point(px, py)):
                ax_map.scatter(px, py, c='black', s=15, zorder=5, edgecolors='white', linewidths=0.5)

    for _, row in gdf.iterrows():
        c = row.geometry.centroid
        ax_map.text(c.x, c.y, row['name'], ha='center', va='center', fontsize=8,
                    fontweight='bold', color='#333333',
                    path_effects=[pe.withStroke(linewidth=2, foreground='white')])

    ax_map.set_xlim(-77.6, -76.0); ax_map.set_ylim(36.7, 39.8)
    ax_map.set_xlabel('Longitude', fontsize=9)
    ax_map.set_ylabel('Latitude', fontsize=9)
    ax_map.set_title('Chesapeake Bay: Mean Dissolved Oxygen by Watershed',
                     fontsize=13, fontweight='bold', color=SAGE)

    # Scatter inset
    ax_scatter = fig.add_axes([0.68, 0.15, 0.3, 0.7])
    colors = [plt.cm.RdYlGn((do - 3) / 5) for do in gdf['DO']]
    ax_scatter.scatter(gdf['ag_pct'], gdf['DO'], c=colors, s=120, edgecolors='white',
                       linewidths=1.5, zorder=5)

    # Fit line
    z = np.polyfit(gdf['ag_pct'], gdf['DO'], 1)
    x_fit = np.linspace(15, 70, 100)
    ax_scatter.plot(x_fit, np.polyval(z, x_fit), color=RED, linewidth=1.5, linestyle='--', alpha=0.7)

    for _, row in gdf.iterrows():
        ax_scatter.annotate(row['name'], (row['ag_pct'], row['DO']),
                           fontsize=7, ha='left', va='bottom',
                           xytext=(5, 3), textcoords='offset points')

    ax_scatter.set_xlabel('Agriculture (%)', fontsize=10)
    ax_scatter.set_ylabel('Mean DO (mg/L)', fontsize=10)
    ax_scatter.set_title('Agriculture vs. DO', fontsize=11, fontweight='bold', color=SAGE)
    ax_scatter.axhline(5, color='#cccccc', linewidth=0.8, linestyle=':')
    ax_scatter.text(65, 5.15, 'Hypoxia\nthreshold', fontsize=7, color='#888888')

    plt.savefig(f'{OUTDIR}/05_case_study.png', dpi=DPI, bbox_inches='tight')
    plt.close()
    print('  [20/20] case_study')


# =========================================================================
# RUN ALL
# =========================================================================
if __name__ == '__main__':
    print('Generating figures for Lecture 05...')
    fig01_vector_vs_raster()
    fig02_chesapeake_stations()
    fig03_earthquake_map()
    fig04_voronoi_coverage()
    fig05_stream_network()
    fig06_watersheds()
    fig07_flood_overlay()
    fig08_raster_concept()
    fig09_ndvi_map()
    fig10_resolution()
    fig11_crs_diagram()
    fig12_mercator()
    fig13_mollweide()
    fig14_azimuthal()
    fig15_mercator_vs_equalarea()
    fig16_spatial_operations()
    fig17_amazon_deforestation()
    fig18_bad_map()
    fig19_good_map()
    fig20_case_study()
    print('Done! All figures saved to:', OUTDIR)
