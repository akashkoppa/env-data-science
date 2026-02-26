"""Figure 3: Spatial Descriptive Statistics — Mean Center, Standard Distance, Std. Deviational Ellipse.
Regenerated WITHOUT colorbar in panel (c).
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse

np.random.seed(42)

# Generate point data with spatial trend
n = 50
x = np.random.uniform(1, 11, n)
y = np.random.uniform(1, 11, n)
# Concentration with spatial trend (higher in lower-left)
concentration = 10 - 0.15 * x + 0.05 * y + np.random.normal(0, 0.5, n)

# Compute spatial statistics
mean_x = np.mean(x)
mean_y = np.mean(y)
std_dist = np.sqrt(np.mean((x - mean_x) ** 2 + (y - mean_y) ** 2))

# Covariance for ellipse
cov = np.cov(x, y)
eigenvalues, eigenvectors = np.linalg.eigh(cov)
angle = np.degrees(np.arctan2(eigenvectors[1, 1], eigenvectors[0, 1]))
ellipse_width = 2 * np.sqrt(eigenvalues[1])
ellipse_height = 2 * np.sqrt(eigenvalues[0])

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
cmap = "YlOrRd"
vmin, vmax = concentration.min(), concentration.max()
scatter_kw = dict(c=concentration, cmap=cmap, vmin=vmin, vmax=vmax,
                  s=50, edgecolors="gray", linewidth=0.5, alpha=0.8)

# --- Panel (a): Mean Center ---
ax = axes[0]
ax.scatter(x, y, **scatter_kw)
ax.plot(mean_x, mean_y, "k+", markersize=15, mew=3)
ax.annotate(
    f"Mean Center\n({mean_x:.1f}, {mean_y:.1f})",
    xy=(mean_x, mean_y),
    xytext=(mean_x - 2.5, mean_y - 2),
    fontsize=10,
    arrowprops=dict(arrowstyle="->", color="black"),
    bbox=dict(boxstyle="round,pad=0.3", facecolor="white", alpha=0.9),
)
ax.set_xlabel("Easting (km)")
ax.set_ylabel("Northing (km)")
ax.set_title("(a) Mean Center", fontweight="bold")
ax.set_xlim(0, 12)
ax.set_ylim(0, 11)

# --- Panel (b): Standard Distance ---
ax = axes[1]
ax.scatter(x, y, **scatter_kw)
ax.plot(mean_x, mean_y, "k+", markersize=15, mew=3)
circle = plt.Circle(
    (mean_x, mean_y), std_dist,
    fill=False, color="#457b9d", linestyle="--", linewidth=2,
)
ax.add_patch(circle)
ax.annotate(
    f"Std Distance\nr = {std_dist:.1f} km",
    xy=(mean_x + std_dist * 0.6, mean_y - std_dist * 0.6),
    fontsize=10, color="#457b9d",
    bbox=dict(boxstyle="round,pad=0.3", facecolor="white", alpha=0.9),
)
ax.set_xlabel("Easting (km)")
ax.set_ylabel("Northing (km)")
ax.set_title("(b) Standard Distance", fontweight="bold")
ax.set_xlim(0, 12)
ax.set_ylim(0, 11)

# --- Panel (c): Std. Deviational Ellipse (NO colorbar) ---
ax = axes[2]
ax.scatter(x, y, **scatter_kw)
ax.plot(mean_x, mean_y, "k+", markersize=15, mew=3)
ellipse = Ellipse(
    (mean_x, mean_y), ellipse_width * 2, ellipse_height * 2, angle=angle,
    fill=False, color="#6a4c93", linestyle="--", linewidth=2,
)
ax.add_patch(ellipse)
ax.annotate(
    "Shows directional\ntrend in data",
    xy=(mean_x + 2, mean_y + 2),
    fontsize=10, color="#6a4c93", fontstyle="italic",
    bbox=dict(boxstyle="round,pad=0.3", facecolor="white", alpha=0.9),
)
ax.set_xlabel("Easting (km)")
ax.set_ylabel("Northing (km)")
ax.set_title("(c) Std. Deviational Ellipse", fontweight="bold")
ax.set_xlim(0, 12)
ax.set_ylim(0, 11)

plt.tight_layout()
plt.savefig(
    "/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/07_Spatial_Analysis/07_descriptive_stats.png",
    dpi=200, bbox_inches="tight",
)
plt.close()
print("Done: 07_descriptive_stats.png")
