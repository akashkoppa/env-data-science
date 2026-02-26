"""Figure 7: IDW — Effect of the Power Parameter.
Regenerated with colorbar on the RIGHT SIDE of the figure (outside the panels).
"""
import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

# Station locations and temperatures
stations_x = np.array([2, 5, 8, 3, 7, 1, 9, 4, 6, 8])
stations_y = np.array([8, 5, 7, 2, 2, 5, 9, 7, 4, 1])
temperatures = np.array([22.1, 18.5, 20.3, 24.8, 23.0, 19.5, 17.2, 21.0, 22.5, 25.5])

# Grid for interpolation
grid_x = np.linspace(0, 10, 200)
grid_y = np.linspace(0, 10, 200)
GX, GY = np.meshgrid(grid_x, grid_y)


def idw(x, y, values, xi, yi, power):
    """Inverse Distance Weighting interpolation."""
    result = np.zeros_like(xi)
    for i in range(xi.shape[0]):
        for j in range(xi.shape[1]):
            dist = np.sqrt((x - xi[i, j]) ** 2 + (y - yi[i, j]) ** 2)
            dist = np.maximum(dist, 1e-10)
            weights = 1.0 / dist ** power
            result[i, j] = np.sum(weights * values) / np.sum(weights)
    return result


powers = [1, 2, 5]
labels = ["(a) Power = 1 (smooth)", "(b) Power = 2 (standard)", "(c) Power = 5 (local)"]

# Compute all interpolations first to get consistent color limits
all_Z = [idw(stations_x, stations_y, temperatures, GX, GY, p) for p in powers]
vmin = min(Z.min() for Z in all_Z)
vmax = max(Z.max() for Z in all_Z)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, (Z, label) in enumerate(zip(all_Z, labels)):
    ax = axes[idx]
    c = ax.contourf(GX, GY, Z, levels=20, cmap="RdYlBu_r", vmin=vmin, vmax=vmax)
    ax.scatter(stations_x, stations_y, c="black", s=40, zorder=5)
    ax.set_xlabel("Easting (km)")
    if idx == 0:
        ax.set_ylabel("Northing (km)")
    ax.set_title(label, fontweight="bold")
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)

# Add colorbar on the right side, outside the panels
fig.subplots_adjust(right=0.88)
cbar_ax = fig.add_axes([0.90, 0.15, 0.02, 0.7])
fig.colorbar(c, cax=cbar_ax, label="Temperature (°C)")

plt.savefig(
    "/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/07_Spatial_Analysis/07_idw.png",
    dpi=200, bbox_inches="tight",
)
plt.close()
print("Done: 07_idw.png")
