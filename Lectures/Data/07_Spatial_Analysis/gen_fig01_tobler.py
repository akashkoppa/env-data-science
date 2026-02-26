"""Figure 1: Tobler's First Law — nearby things are more related."""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

np.random.seed(42)
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Left panel: temperature field with two pairs of points
x = np.linspace(0, 10, 100)
y = np.linspace(0, 10, 100)
X, Y = np.meshgrid(x, y)
Z = 20 + 5 * np.sin(X * 0.5) + 3 * np.cos(Y * 0.4) + np.random.normal(0, 0.3, X.shape)

ax = axes[0]
c = ax.contourf(X, Y, Z, levels=20, cmap='RdYlBu_r', alpha=0.8)
plt.colorbar(c, ax=ax, label='Temperature (°C)', shrink=0.8)

# Near pair
ax.plot([3, 4], [5, 5.5], 'ko', markersize=10, zorder=5)
ax.annotate('', xy=(4, 5.5), xytext=(3, 5),
            arrowprops=dict(arrowstyle='<->', color='black', lw=2))
ax.text(3.5, 4.3, 'Near\n(similar values)', ha='center', fontsize=11, fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.9))

# Far pair
ax.plot([1, 8.5], [2, 8], 'ks', markersize=10, zorder=5)
ax.annotate('', xy=(8.5, 8), xytext=(1, 2),
            arrowprops=dict(arrowstyle='<->', color='#c44536', lw=2, linestyle='--'))
ax.text(5.5, 3.5, 'Far\n(different values)', ha='center', fontsize=11, fontweight='bold',
        color='#c44536', bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.9))

ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.set_xlabel('Easting (km)')
ax.set_ylabel('Northing (km)')
ax.set_title("Spatial Field: Temperature", fontsize=13, fontweight='bold')

# Right panel: correlation vs distance
distances = np.linspace(0.1, 10, 50)
correlation = np.exp(-0.4 * distances) + np.random.normal(0, 0.03, 50)
correlation = np.clip(correlation, 0, 1)

ax2 = axes[1]
ax2.scatter(distances, correlation, c='#2d5a27', s=40, alpha=0.7, edgecolors='white', linewidth=0.5)
d_smooth = np.linspace(0.1, 10, 200)
ax2.plot(d_smooth, np.exp(-0.4 * d_smooth), color='#c44536', lw=2.5, label='Exponential decay')
ax2.set_xlabel('Distance Between Locations (km)', fontsize=12)
ax2.set_ylabel('Correlation', fontsize=12)
ax2.set_title("Tobler's First Law", fontsize=13, fontweight='bold')
ax2.set_ylim(-0.05, 1.05)
ax2.legend(fontsize=11)
ax2.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax2.text(5, 0.85, '"Near things are\nmore related than\ndistant things"',
         fontsize=12, fontstyle='italic', ha='center',
         bbox=dict(boxstyle='round,pad=0.4', facecolor='#2d5a27', alpha=0.15))

plt.tight_layout()
plt.savefig('/Users/akashkoppa/Documents/teaching/env-data-science/Lectures/Data/07_Spatial_Analysis/07_tobler_law.png', dpi=200, bbox_inches='tight')
plt.close()
print("Done: 07_tobler_law.png")
