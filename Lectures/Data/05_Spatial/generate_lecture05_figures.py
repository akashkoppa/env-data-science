#!/usr/bin/env python3
"""
Generate all 10 figures for Lecture 05 (Spatial Data and Mapping) revisions.
"""

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.gridspec as gridspec
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from shapely.geometry import LineString
import warnings
warnings.filterwarnings("ignore")

# -- Style constants -----------------------------------------------------------
SAGE      = "#2d5a27"
STEEL     = "#457b9d"
CREAM     = "#fdfdfc"
CHARCOAL  = "#2f2f2f"
RED       = "#c44536"
DPI       = 200

OUTDIR = "/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/05_Spatial/"

plt.rcParams.update({
    "font.family": "sans-serif",
    "font.size": 10,
    "axes.facecolor": CREAM,
    "figure.facecolor": CREAM,
    "text.color": CHARCOAL,
    "axes.labelcolor": CHARCOAL,
    "xtick.color": CHARCOAL,
    "ytick.color": CHARCOAL,
})


# ==============================================================================
# 1. 05_proximity.png  (~800x400 landscape)
# ==============================================================================
def fig_proximity():
    fig, ax = plt.subplots(figsize=(8, 4))
    x = np.linspace(0, 6000, 500)
    pm25 = 12 + 48 * np.exp(-x / 400)
    ax.fill_between(x, pm25, alpha=0.18, color=RED)
    ax.plot(x, pm25, color=RED, lw=2.5, zorder=3)
    ax.axvline(0, color=CHARCOAL, lw=6, zorder=4)
    ax.text(60, 57, "Highway", fontsize=9, fontweight="bold", color=CHARCOAL,
            rotation=90, va="top", ha="left")
    sensors = {"50 m": 50, "500 m": 500, "5 km": 5000}
    for label, dist in sensors.items():
        y_val = 12 + 48 * np.exp(-dist / 400)
        ax.plot(dist, y_val, "o", color=STEEL, ms=10, zorder=5,
                markeredgecolor="white", markeredgewidth=1.5)
        ax.annotate(f"{label}\n({y_val:.0f} \u00b5g/m\u00b3)", xy=(dist, y_val),
                    xytext=(0, 18), textcoords="offset points",
                    fontsize=8.5, ha="center", fontweight="bold", color=STEEL,
                    arrowprops=dict(arrowstyle="-", color=STEEL, lw=0.8))
    ax.axhline(12, color=SAGE, ls="--", lw=1, alpha=0.7)
    ax.text(5800, 13.5, "Background\n(12 \u00b5g/m\u00b3)", fontsize=7.5,
            ha="right", color=SAGE)
    ax.set_xlim(-200, 6200)
    ax.set_ylim(0, 65)
    ax.set_xlabel("Distance from Highway (m)", fontsize=10)
    ax.set_ylabel("PM\u2082.\u2085 Concentration (\u00b5g/m\u00b3)", fontsize=10)
    ax.set_title("Proximity: Distance from Source Matters",
                 fontsize=13, fontweight="bold", color=CHARCOAL, pad=12)
    ax.spines[["top", "right"]].set_visible(False)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_proximity.png", dpi=DPI, bbox_inches="tight",
                facecolor=CREAM)
    plt.close(fig)
    print("  [1/10] 05_proximity.png")


# ==============================================================================
# 2. 05_spatial_patterns.png  (~800x400 landscape)
# ==============================================================================
def fig_spatial_patterns():
    rng = np.random.default_rng(42)
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.set_facecolor("#e8f0e4")
    road_x = np.array([0, 10])
    road_y = np.array([1, 9])
    ax.plot(road_x, road_y, color="#888888", lw=4, solid_capstyle="round",
            zorder=2, label="Road")
    river_x = np.linspace(0, 10, 200)
    river_y = 5 + 1.8 * np.sin(river_x * 0.9)
    ax.plot(river_x, river_y, color=STEEL, lw=3, solid_capstyle="round",
            zorder=2, label="River")
    n_road = 90
    t_road = rng.uniform(0.1, 0.95, n_road)
    rx = road_x[0] + t_road * (road_x[1] - road_x[0])
    ry = road_y[0] + t_road * (road_y[1] - road_y[0])
    rx += rng.normal(0, 0.45, n_road)
    ry += rng.normal(0, 0.45, n_road)
    n_river = 70
    t_river = rng.uniform(0.05, 0.95, n_river)
    idx = (t_river * (len(river_x) - 1)).astype(int)
    rvx = river_x[idx] + rng.normal(0, 0.4, n_river)
    rvy = river_y[idx] + rng.normal(0, 0.4, n_river)
    n_far = 10
    fx = rng.uniform(0.5, 9.5, n_far)
    fy = rng.uniform(0.5, 9.5, n_far)
    all_x = np.concatenate([rx, rvx, fx])
    all_y = np.concatenate([ry, rvy, fy])
    ax.scatter(all_x, all_y, c=RED, s=18, alpha=0.55, edgecolors="none",
               zorder=3, label="Deforestation")
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 10.5)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_title("Spatial Patterns: Deforestation Clusters Along Roads",
                 fontsize=13, fontweight="bold", color=CHARCOAL, pad=12)
    ax.legend(loc="lower right", fontsize=9, framealpha=0.9,
              edgecolor=CHARCOAL, fancybox=False)
    for spine in ax.spines.values():
        spine.set_color(CHARCOAL)
        spine.set_linewidth(0.5)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_spatial_patterns.png", dpi=DPI,
                bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [2/10] 05_spatial_patterns.png")


# ==============================================================================
# 3. 05_scale.png  (~800x400 landscape)
# ==============================================================================
def fig_scale():
    fig = plt.figure(figsize=(8, 4))
    gs = gridspec.GridSpec(1, 2, width_ratios=[1, 1.15], wspace=0.30)
    ax1 = fig.add_subplot(gs[0])
    rng = np.random.default_rng(7)
    months = np.arange(1, 13)
    precip = np.array([85, 78, 72, 55, 30, 12, 8, 10, 25, 52, 70, 82])
    precip = precip + rng.normal(0, 4, 12)
    ax1.bar(months, precip, color=STEEL, width=0.65, edgecolor="white",
            linewidth=0.5, zorder=3)
    for m in [6, 7, 8]:
        ax1.bar(m, precip[m - 1], color=RED, width=0.65, edgecolor="white",
                linewidth=0.5, zorder=4)
    ax1.axhline(30, color=RED, ls="--", lw=1, alpha=0.6)
    ax1.text(9.5, 32, "Drought\nthreshold", fontsize=7, color=RED, ha="left")
    ax1.set_xticks(months)
    ax1.set_xticklabels(["J","F","M","A","M","J","J","A","S","O","N","D"], fontsize=8)
    ax1.set_ylabel("Precipitation (mm)", fontsize=9)
    ax1.set_title("Station Scale", fontsize=12, fontweight="bold", color=CHARCOAL, pad=8)
    ax1.spines[["top", "right"]].set_visible(False)

    ax2 = fig.add_subplot(gs[1], projection=ccrs.PlateCarree())
    ax2.set_extent([-82, -34, -56, 13], crs=ccrs.PlateCarree())
    ax2.add_feature(cfeature.LAND, facecolor="#e8e8e0", edgecolor="none")
    ax2.add_feature(cfeature.OCEAN, facecolor="#d4e6f1")
    ax2.add_feature(cfeature.BORDERS, linewidth=0.4, edgecolor=CHARCOAL)
    ax2.add_feature(cfeature.COASTLINE, linewidth=0.5, edgecolor=CHARCOAL)
    from matplotlib.patches import Ellipse
    drought_ellipse = Ellipse((-46, -14), 16, 12, angle=-15,
                               facecolor=RED, alpha=0.30, edgecolor=RED,
                               linewidth=1.5, transform=ccrs.PlateCarree(), zorder=5)
    ax2.add_patch(drought_ellipse)
    ax2.text(-46, -14, "Drought\nRegion", fontsize=8, fontweight="bold",
             color=RED, ha="center", va="center", transform=ccrs.PlateCarree(), zorder=6)
    ax2.plot(-46, -14, "v", color=CHARCOAL, ms=7, zorder=7, transform=ccrs.PlateCarree())
    ax2.set_title("Continental Scale", fontsize=12, fontweight="bold", color=CHARCOAL, pad=8)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_scale.png", dpi=DPI, bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [3/10] 05_scale.png")


# ==============================================================================
# 4. 05_spatial_op_buffer.png  (~600x500)
# ==============================================================================
def fig_buffer():
    fig, ax = plt.subplots(figsize=(6, 5))
    x = np.linspace(0.5, 9.5, 300)
    y = 5 + 2.2 * np.sin(x * 0.7 + 0.5)
    river = LineString(np.column_stack([x, y]))
    buf = river.buffer(1.0)
    bx, by = buf.exterior.xy
    ax.fill(bx, by, color=STEEL, alpha=0.18, zorder=1)
    ax.plot(bx, by, color=STEEL, lw=1, ls="--", alpha=0.6, zorder=2)
    ax.plot(x, y, color=STEEL, lw=3, solid_capstyle="round", zorder=3)
    ax.annotate("500 m buffer zone", xy=(7.2, 7.8), fontsize=11,
                fontweight="bold", color=STEEL, ha="center",
                bbox=dict(boxstyle="round,pad=0.3", fc=CREAM, ec=STEEL, alpha=0.9))
    ax.text(2.5, 4.3, "River", fontsize=10, fontweight="bold", color="white",
            ha="center", va="center",
            bbox=dict(boxstyle="round,pad=0.2", fc=STEEL, ec="none"))
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(0, 10)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_title("Buffer", fontsize=15, fontweight="bold", color=CHARCOAL, pad=10)
    for spine in ax.spines.values():
        spine.set_color(CHARCOAL)
        spine.set_linewidth(0.5)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_spatial_op_buffer.png", dpi=DPI, bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [4/10] 05_spatial_op_buffer.png")


# ==============================================================================
# 5. 05_spatial_op_intersection.png  (~600x500)
# ==============================================================================
def fig_intersection():
    fig, ax = plt.subplots(figsize=(6, 5))
    ax.add_patch(mpatches.FancyBboxPatch((1, 2), 4.5, 4, boxstyle="round,pad=0.1",
                 facecolor=STEEL, alpha=0.25, edgecolor=STEEL, linewidth=2))
    ax.add_patch(mpatches.FancyBboxPatch((3.5, 3), 4.5, 4, boxstyle="round,pad=0.1",
                 facecolor=RED, alpha=0.25, edgecolor=RED, linewidth=2))
    inter = mpatches.FancyBboxPatch((3.5, 3), 2, 3, boxstyle="round,pad=0.05",
            facecolor=SAGE, alpha=0.50, edgecolor=CHARCOAL, linewidth=2.5)
    ax.add_patch(inter)
    ax.text(2.2, 4.8, "Layer A", fontsize=12, fontweight="bold", color=STEEL, ha="center")
    ax.text(6.8, 5.8, "Layer B", fontsize=12, fontweight="bold", color=RED, ha="center")
    ax.text(4.5, 4.5, "A \u2229 B", fontsize=14, fontweight="bold", color="white",
            ha="center", va="center",
            bbox=dict(boxstyle="round,pad=0.3", fc=SAGE, ec="none", alpha=0.85))
    ax.set_xlim(0, 9)
    ax.set_ylim(1, 8.5)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_title("Intersection", fontsize=15, fontweight="bold", color=CHARCOAL, pad=10)
    ax.set_aspect("equal")
    for spine in ax.spines.values():
        spine.set_color(CHARCOAL)
        spine.set_linewidth(0.5)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_spatial_op_intersection.png", dpi=DPI, bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [5/10] 05_spatial_op_intersection.png")


# ==============================================================================
# 6. 05_spatial_op_spatial_join.png  (~600x500)
# ==============================================================================
def fig_spatial_join():
    fig = plt.figure(figsize=(6, 5))
    gs = gridspec.GridSpec(1, 3, width_ratios=[1, 0.25, 1], wspace=0.05)
    zone_colors = [STEEL, SAGE, "#e6a817"]
    zone_labels = ["Zone A", "Zone B", "Zone C"]
    ax1 = fig.add_subplot(gs[0])
    zones = [
        ([0, 4, 4, 0, 0], [0, 0, 3, 3, 0]),
        ([4, 8, 8, 4, 4], [0, 0, 3, 3, 0]),
        ([0, 8, 8, 0, 0], [3, 3, 6, 6, 3]),
    ]
    rng = np.random.default_rng(11)
    all_pts = []
    all_zone_idx = []
    for i, (zx, zy) in enumerate(zones):
        ax1.fill(zx, zy, color=zone_colors[i], alpha=0.15, edgecolor=zone_colors[i], linewidth=1.5)
        ax1.text(np.mean(zx[:4]), np.mean(zy[:4]) + 0.8, zone_labels[i],
                 fontsize=8, ha="center", color=zone_colors[i], fontweight="bold")
        n_pts = 4
        px = rng.uniform(min(zx) + 0.4, max(zx) - 0.4, n_pts)
        py = rng.uniform(min(zy) + 0.4, max(zy) - 0.4, n_pts)
        ax1.scatter(px, py, color=CHARCOAL, s=40, zorder=5, edgecolors="white", linewidths=0.8)
        for p in zip(px, py):
            all_pts.append(p)
            all_zone_idx.append(i)
    ax1.set_xlim(-0.5, 8.5)
    ax1.set_ylim(-0.5, 6.5)
    ax1.set_xticks([])
    ax1.set_yticks([])
    ax1.set_title("Points + Zones", fontsize=10, fontweight="bold", color=CHARCOAL)
    for spine in ax1.spines.values():
        spine.set_color(CHARCOAL)
        spine.set_linewidth(0.5)

    ax_arrow = fig.add_subplot(gs[1])
    ax_arrow.set_xlim(0, 1)
    ax_arrow.set_ylim(0, 1)
    ax_arrow.annotate("", xy=(0.9, 0.5), xytext=(0.1, 0.5),
                      arrowprops=dict(arrowstyle="->", lw=2.5, color=CHARCOAL))
    ax_arrow.axis("off")

    ax2 = fig.add_subplot(gs[2])
    for i, (zx, zy) in enumerate(zones):
        ax2.fill(zx, zy, color=zone_colors[i], alpha=0.08, edgecolor=zone_colors[i], linewidth=1, ls="--")
    for (px, py), zi in zip(all_pts, all_zone_idx):
        ax2.scatter(px, py, color=zone_colors[zi], s=55, zorder=5, edgecolors="white", linewidths=0.8)
    ax2.set_xlim(-0.5, 8.5)
    ax2.set_ylim(-0.5, 6.5)
    ax2.set_xticks([])
    ax2.set_yticks([])
    ax2.set_title("Joined Result", fontsize=10, fontweight="bold", color=CHARCOAL)
    for spine in ax2.spines.values():
        spine.set_color(CHARCOAL)
        spine.set_linewidth(0.5)
    fig.suptitle("Spatial Join", fontsize=15, fontweight="bold", color=CHARCOAL, y=1.01)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_spatial_op_spatial_join.png", dpi=DPI, bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [6/10] 05_spatial_op_spatial_join.png")


# ==============================================================================
# 7. 05_spatial_op_dissolve.png  (~600x500)
# ==============================================================================
def fig_dissolve():
    fig = plt.figure(figsize=(6, 5))
    gs = gridspec.GridSpec(1, 3, width_ratios=[1, 0.25, 1], wspace=0.05)
    state_a_color = STEEL
    state_b_color = SAGE
    counties = [
        ([0, 2, 2, 0], [0, 0, 2, 2], "County 1", "A"),
        ([2, 4, 4, 2], [0, 0, 2, 2], "County 2", "A"),
        ([4, 6, 6, 4], [0, 0, 2, 2], "County 3", "A"),
        ([0, 2, 2, 0], [2, 2, 4, 4], "County 4", "B"),
        ([2, 4, 4, 2], [2, 2, 4, 4], "County 5", "B"),
        ([4, 6, 6, 4], [2, 2, 4, 4], "County 6", "B"),
    ]
    ax1 = fig.add_subplot(gs[0])
    for cx, cy, label, state in counties:
        c = state_a_color if state == "A" else state_b_color
        ax1.fill(cx, cy, color=c, alpha=0.25, edgecolor=CHARCOAL, linewidth=1.5)
        ax1.text(np.mean(cx), np.mean(cy), label, fontsize=7.5, ha="center",
                 va="center", color=CHARCOAL, fontweight="bold")
    ax1.set_xlim(-0.5, 6.5)
    ax1.set_ylim(-0.7, 4.7)
    ax1.set_xticks([])
    ax1.set_yticks([])
    ax1.set_title("Before (Counties)", fontsize=10, fontweight="bold", color=CHARCOAL)
    for spine in ax1.spines.values():
        spine.set_color(CHARCOAL)
        spine.set_linewidth(0.5)

    ax_arrow = fig.add_subplot(gs[1])
    ax_arrow.set_xlim(0, 1)
    ax_arrow.set_ylim(0, 1)
    ax_arrow.annotate("", xy=(0.9, 0.5), xytext=(0.1, 0.5),
                      arrowprops=dict(arrowstyle="->", lw=2.5, color=CHARCOAL))
    ax_arrow.axis("off")

    ax2 = fig.add_subplot(gs[2])
    ax2.fill([0, 6, 6, 0], [0, 0, 2, 2], color=state_a_color, alpha=0.30,
             edgecolor=CHARCOAL, linewidth=2)
    ax2.text(3, 1, "State A", fontsize=12, ha="center", va="center",
             fontweight="bold", color=state_a_color)
    ax2.fill([0, 6, 6, 0], [2, 2, 4, 4], color=state_b_color, alpha=0.30,
             edgecolor=CHARCOAL, linewidth=2)
    ax2.text(3, 3, "State B", fontsize=12, ha="center", va="center",
             fontweight="bold", color=state_b_color)
    ax2.set_xlim(-0.5, 6.5)
    ax2.set_ylim(-0.7, 4.7)
    ax2.set_xticks([])
    ax2.set_yticks([])
    ax2.set_title("After (States)", fontsize=10, fontweight="bold", color=CHARCOAL)
    for spine in ax2.spines.values():
        spine.set_color(CHARCOAL)
        spine.set_linewidth(0.5)
    fig.suptitle("Dissolve", fontsize=15, fontweight="bold", color=CHARCOAL, y=1.01)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_spatial_op_dissolve.png", dpi=DPI, bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [7/10] 05_spatial_op_dissolve.png")


# ==============================================================================
# 8. 05_spatial_op_zonal_stats.png  (~600x500)
# ==============================================================================
def fig_zonal_stats():
    fig, ax = plt.subplots(figsize=(6, 5))
    rng = np.random.default_rng(99)
    nx, ny = 60, 50
    x = np.linspace(0, 6, nx)
    y = np.linspace(0, 5, ny)
    X, Y = np.meshgrid(x, y)
    Z = (2.5 * np.sin(X * 0.8) * np.cos(Y * 0.6)
         + 1.5 * np.sin(X * 0.3 + Y * 0.5)
         + rng.normal(0, 0.3, (ny, nx)))
    cmap = LinearSegmentedColormap.from_list("custom",
           ["#2d5a27", "#a8d08d", "#f5e6a8", "#c44536"], N=256)
    ax.pcolormesh(X, Y, Z, cmap=cmap, shading="auto", zorder=1)
    zones = [
        ([0, 3, 3, 0, 0], [0, 0, 2.5, 2.5, 0]),
        ([3, 6, 6, 3, 3], [0, 0, 2.5, 2.5, 0]),
        ([0, 3, 3, 0, 0], [2.5, 2.5, 5, 5, 2.5]),
        ([3, 6, 6, 3, 3], [2.5, 2.5, 5, 5, 2.5]),
    ]
    zone_names = ["Zone 1", "Zone 2", "Zone 3", "Zone 4"]
    for (zx, zy), zname in zip(zones, zone_names):
        ax.plot(zx, zy, color=CHARCOAL, lw=2.5, zorder=3)
        x_min, x_max = min(zx), max(zx)
        y_min, y_max = min(zy), max(zy)
        mask = (X >= x_min) & (X <= x_max) & (Y >= y_min) & (Y <= y_max)
        mean_val = Z[mask].mean()
        ax.text(np.mean(zx[:4]), np.mean(zy[:4]),
                f"{zname}\n\u03bc = {mean_val:.1f}",
                fontsize=10, ha="center", va="center", fontweight="bold",
                color="white", zorder=4,
                bbox=dict(boxstyle="round,pad=0.3", fc=CHARCOAL, alpha=0.7, ec="none"))
    ax.set_xlim(0, 6)
    ax.set_ylim(0, 5)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_title("Zonal Statistics", fontsize=15, fontweight="bold", color=CHARCOAL, pad=10)
    for spine in ax.spines.values():
        spine.set_color(CHARCOAL)
        spine.set_linewidth(0.5)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_spatial_op_zonal_stats.png", dpi=DPI, bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [8/10] 05_spatial_op_zonal_stats.png")


# ==============================================================================
# 9. 05_spatial_op_map_algebra.png  (~600x500)
# ==============================================================================
def fig_map_algebra():
    fig = plt.figure(figsize=(6, 5))
    gs = gridspec.GridSpec(2, 3, width_ratios=[1, 0.3, 1], hspace=0.55, wspace=0.20)
    rng = np.random.default_rng(5)
    nir = rng.uniform(0.20, 0.55, (4, 4))
    red = rng.uniform(0.05, 0.25, (4, 4))
    ndvi = (nir - red) / (nir + red)

    def draw_grid(ax, data, title, fmt=".2f", cmap_name="YlGn", vmin=None, vmax=None):
        cmap = plt.get_cmap(cmap_name)
        if vmin is None:
            vmin = data.min()
        if vmax is None:
            vmax = data.max()
        for i in range(4):
            for j in range(4):
                val = data[i, j]
                norm = (val - vmin) / (vmax - vmin + 1e-9)
                color = cmap(norm)
                ax.add_patch(plt.Rectangle((j, 3 - i), 1, 1, facecolor=color,
                             edgecolor=CHARCOAL, linewidth=1))
                ax.text(j + 0.5, 3 - i + 0.5, f"{val:{fmt}}", ha="center",
                        va="center", fontsize=7, fontweight="bold",
                        color="white" if norm > 0.55 else CHARCOAL)
        ax.set_xlim(0, 4)
        ax.set_ylim(0, 4)
        ax.set_aspect("equal")
        ax.set_xticks([])
        ax.set_yticks([])
        ax.set_title(title, fontsize=10, fontweight="bold", color=CHARCOAL, pad=5)
        for spine in ax.spines.values():
            spine.set_visible(False)

    ax_nir = fig.add_subplot(gs[0, 0])
    draw_grid(ax_nir, nir, "NIR Band", cmap_name="Greens")
    ax_red = fig.add_subplot(gs[1, 0])
    draw_grid(ax_red, red, "Red Band", cmap_name="Reds")

    ax_arrow = fig.add_subplot(gs[:, 1])
    ax_arrow.set_xlim(0, 1)
    ax_arrow.set_ylim(0, 1)
    ax_arrow.annotate("", xy=(0.9, 0.5), xytext=(0.1, 0.5),
                      arrowprops=dict(arrowstyle="->", lw=2.5, color=CHARCOAL))
    ax_arrow.text(0.5, 0.62, r"$\frac{NIR - Red}{NIR + Red}$", fontsize=12,
                  ha="center", va="center", color=CHARCOAL, fontweight="bold")
    ax_arrow.axis("off")

    ax_ndvi = fig.add_subplot(gs[:, 2])
    draw_grid(ax_ndvi, ndvi, "NDVI Result", cmap_name="RdYlGn", vmin=-0.1, vmax=0.8)

    fig.suptitle("Map Algebra", fontsize=15, fontweight="bold", color=CHARCOAL, y=1.01)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_spatial_op_map_algebra.png", dpi=DPI, bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [9/10] 05_spatial_op_map_algebra.png")


# ==============================================================================
# 10. 05_mercator_vs_equalarea_vertical.png  (~800x800 portrait/square)
# ==============================================================================
def fig_mercator_vs_equalarea_vertical():
    fig = plt.figure(figsize=(8, 8))
    gs = gridspec.GridSpec(2, 1, hspace=0.12)
    highlight_countries = {
        "Brazil":    (-52, -10),
        "Greenland": (-42, 72),
        "India":     (79, 22),
        "DR Congo":  (24, -2),
        "Australia": (134, -25),
    }
    highlight_color = {
        "Brazil": SAGE,
        "Greenland": STEEL,
        "India": "#e6a817",
        "DR Congo": RED,
        "Australia": "#9b59b6",
    }
    projections = [
        ("Mercator Projection", ccrs.Mercator()),
        ("Equal-Area Projection (Mollweide)", ccrs.Mollweide()),
    ]
    import cartopy.io.shapereader as shpreader
    shpname = shpreader.natural_earth(resolution="110m", category="cultural",
                                       name="admin_0_countries")
    name_map = {
        "Brazil": "Brazil",
        "Greenland": "Greenland",
        "India": "India",
        "DR Congo": "Dem. Rep. Congo",
        "Australia": "Australia",
    }
    for panel_idx, (title, proj) in enumerate(projections):
        ax = fig.add_subplot(gs[panel_idx], projection=proj)
        ax.set_global()
        ax.add_feature(cfeature.OCEAN, facecolor="#d4e6f1", zorder=0)
        ax.add_feature(cfeature.LAND, facecolor="#e8e8e0", edgecolor="none", zorder=1)
        ax.add_feature(cfeature.BORDERS, linewidth=0.3, edgecolor="#999999", zorder=2)
        ax.add_feature(cfeature.COASTLINE, linewidth=0.4, edgecolor=CHARCOAL, zorder=2)
        reader = shpreader.Reader(shpname)
        for country in reader.records():
            name = country.attributes["NAME"]
            for our_name, shp_name in name_map.items():
                if name == shp_name:
                    geom = country.geometry
                    ax.add_geometries([geom], ccrs.PlateCarree(),
                                      facecolor=highlight_color[our_name],
                                      alpha=0.55, edgecolor=CHARCOAL,
                                      linewidth=0.6, zorder=3)
                    lon, lat = highlight_countries[our_name]
                    ax.text(lon, lat, our_name, fontsize=7, fontweight="bold",
                            ha="center", va="center", color=CHARCOAL,
                            transform=ccrs.PlateCarree(), zorder=5,
                            bbox=dict(boxstyle="round,pad=0.15", fc="white",
                                      alpha=0.75, ec="none"))
        ax.set_title(title, fontsize=13, fontweight="bold", color=CHARCOAL, pad=10)
    fig.tight_layout()
    fig.savefig(OUTDIR + "05_mercator_vs_equalarea_vertical.png", dpi=DPI,
                bbox_inches="tight", facecolor=CREAM)
    plt.close(fig)
    print("  [10/10] 05_mercator_vs_equalarea_vertical.png")


# ==============================================================================
# Run all
# ==============================================================================
if __name__ == "__main__":
    print("Generating Lecture 05 revision figures ...\\n")
    fig_proximity()
    fig_spatial_patterns()
    fig_scale()
    fig_buffer()
    fig_intersection()
    fig_spatial_join()
    fig_dissolve()
    fig_zonal_stats()
    fig_map_algebra()
    fig_mercator_vs_equalarea_vertical()
    print("\\nAll 10 figures generated successfully.")
