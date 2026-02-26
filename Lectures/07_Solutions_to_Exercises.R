# =============================================================================
# Lecture 7: Spatial Data Analysis — Exercise Solutions (R)
# ENST431/631: Environmental Data Science
# Instructor: Akash Koppa
# =============================================================================
# Working directory assumed to be the folder containing all data files.
# Required packages: sf, ggplot2, tidyverse, spdep, spatstat

library(sf)
library(ggplot2)
library(tidyverse)
library(spdep)
library(spatstat)

# Set paths — works in both RStudio and command-line R
DATA_DIR <- tryCatch(
  dirname(rstudioapi::getActiveDocumentContext()$path),
  error = function(e) {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("--file=", args, value = TRUE)
    if (length(file_arg) > 0) {
      dirname(normalizePath(sub("--file=", "", file_arg)))
    } else {
      getwd()
    }
  }
)
SPATIAL_06 <- file.path(DATA_DIR, "Data", "06_Spatial")
SPATIAL_07 <- file.path(DATA_DIR, "Data", "07_Spatial_Analysis")


# =============================================================================
# EXERCISE 1: Spatial Descriptive Statistics
# =============================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXERCISE 1: Spatial Descriptive Statistics\n")
cat(strrep("=", 70), "\n")

# --- Load station data ---
stations <- read.csv(file.path(SPATIAL_06, "stations.csv"))
stations_sf <- st_as_sf(stations, coords = c("lon", "lat"), crs = 4326)
cat("Loaded", nrow(stations_sf), "monitoring stations\n")

# --- Mean center ---
coords <- st_coordinates(stations_sf)
mc_lon <- mean(coords[, "X"])
mc_lat <- mean(coords[, "Y"])
cat(sprintf("Mean center: (%.4f, %.4f)\n", mc_lon, mc_lat))

# --- Weighted mean center (weight = mean DO) ---
w <- stations_sf$mean_do_mgl
wmc_lon <- sum(w * coords[, "X"]) / sum(w)
wmc_lat <- sum(w * coords[, "Y"]) / sum(w)
cat(sprintf("Weighted mean center (weight=DO): (%.4f, %.4f)\n", wmc_lon, wmc_lat))

# --- Standard distance ---
dists_deg <- sqrt((coords[, "X"] - mc_lon)^2 + (coords[, "Y"] - mc_lat)^2)
std_dist <- sqrt(mean(dists_deg^2))
cat(sprintf("Standard distance: %.4f degrees\n", std_dist))

# --- Interpretation ---
shift_lon <- wmc_lon - mc_lon
shift_lat <- wmc_lat - mc_lat
cat(sprintf("\nShift from unweighted to weighted center:\n"))
cat(sprintf("  Longitude: %+.4f degrees (%s)\n", shift_lon,
            ifelse(shift_lon > 0, "east", "west")))
cat(sprintf("  Latitude:  %+.4f degrees (%s)\n", shift_lat,
            ifelse(shift_lat > 0, "north", "south")))
cat("Interpretation: The weighted center shifts northward because headwater\n")
cat("stations (Susquehanna, Potomac) have higher dissolved oxygen.\n")

# --- Map with ggplot2 ---
# Create circle points for standard distance
theta <- seq(0, 2 * pi, length.out = 100)
circle_df <- data.frame(
  x = mc_lon + std_dist * cos(theta),
  y = mc_lat + std_dist * sin(theta)
)

centers_df <- data.frame(
  x = c(mc_lon, wmc_lon),
  y = c(mc_lat, wmc_lat),
  label = c("Mean Center", "Weighted Center (DO)")
)

stations_plot <- cbind(as.data.frame(stations_sf), coords)

p1 <- ggplot() +
  geom_path(data = circle_df, aes(x = x, y = y),
            linetype = "dashed", color = "gray50", linewidth = 0.8) +
  geom_point(data = stations_plot,
             aes(x = X, y = Y, color = mean_do_mgl),
             size = 3, stroke = 0.3) +
  scale_color_viridis_c(name = "Mean DO\n(mg/L)") +
  geom_point(data = centers_df, aes(x = x, y = y, fill = label),
             shape = 24, size = 4, stroke = 1) +
  scale_fill_manual(name = "Center",
                    values = c("Mean Center" = "red",
                               "Weighted Center (DO)" = "dodgerblue")) +
  geom_segment(aes(x = mc_lon, y = mc_lat, xend = wmc_lon, yend = wmc_lat),
               arrow = arrow(length = unit(0.2, "cm")), linewidth = 0.8) +
  coord_sf(crs = 4326) +
  labs(title = "CBP Monitoring Stations — Spatial Descriptive Statistics",
       x = "Longitude", y = "Latitude") +
  theme_minimal(base_size = 11)

ggsave(file.path(DATA_DIR, "ex01_descriptive_stats.png"), p1,
       width = 8, height = 8, dpi = 150)
cat("Saved: ex01_descriptive_stats.png\n")


# =============================================================================
# EXERCISE 2: Nearest Neighbor Analysis
# =============================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXERCISE 2: Nearest Neighbor Analysis\n")
cat(strrep("=", 70), "\n")

# --- Reproject to UTM 18N ---
stations_utm <- st_transform(stations_sf, 32618)
coords_utm   <- st_coordinates(stations_utm)

# --- Pairwise distance matrix ---
dmat <- as.matrix(st_distance(stations_utm))  # in meters
diag(dmat) <- NA
n <- nrow(stations_utm)
cat(sprintf("Distance matrix: %d x %d\n", n, n))

# --- Nearest neighbor distances ---
nn_dists   <- apply(dmat, 1, min, na.rm = TRUE)
nn_indices <- apply(dmat, 1, which.min)
d_obs      <- mean(nn_dists)

cat("\nNearest-neighbor distances:\n")
for (i in seq_len(n)) {
  cat(sprintf("  %12s -> %12s  d = %.1f km\n",
              stations_utm$station_id[i],
              stations_utm$station_id[nn_indices[i]],
              nn_dists[i] / 1000))
}
cat(sprintf("\nMean observed NN distance: %.2f km\n", d_obs / 1000))

# --- Convex hull area ---
hull <- st_convex_hull(st_union(stations_utm))
A    <- as.numeric(st_area(hull))  # m^2
cat(sprintf("Convex hull area: %.1f km\u00b2\n", A / 1e6))

# --- Expected NN distance under CSR ---
d_exp <- 1 / (2 * sqrt(n / A))
cat(sprintf("Expected NN distance (CSR): %.2f km\n", d_exp / 1000))

# --- NNI ---
NNI <- d_obs / d_exp
cat(sprintf("Nearest Neighbor Index (NNI): %.4f\n", NNI))

# --- Z-score and p-value ---
se <- 0.26136 / sqrt(n^2 / A)
z  <- (d_obs - d_exp) / se
p_value <- 2 * (1 - pnorm(abs(z)))
cat(sprintf("z-score: %.4f\n", z))
cat(sprintf("p-value: %.4f\n", p_value))

pattern <- ifelse(NNI < 1, "CLUSTERED", ifelse(NNI > 1, "DISPERSED", "RANDOM"))
sig_str <- ifelse(p_value < 0.05, "significant", "not significant")
cat(sprintf("\nConclusion: The monitoring network is %s (NNI=%.2f, z=%.2f, p=%.4f, %s)\n",
            pattern, NNI, z, p_value, sig_str))

# --- Most isolated station ---
most_isolated <- which.max(nn_dists)
cat(sprintf("\nMost isolated station: %s (%s)\n",
            stations_utm$station_id[most_isolated],
            stations_utm$description[most_isolated]))
cat(sprintf("  NN distance: %.1f km\n", nn_dists[most_isolated] / 1000))

# --- Map: stations with NN lines ---
nn_lines <- vector("list", n)
for (i in seq_len(n)) {
  j <- nn_indices[i]
  nn_lines[[i]] <- st_linestring(matrix(
    c(coords_utm[i, 1], coords_utm[j, 1],
      coords_utm[i, 2], coords_utm[j, 2]),
    ncol = 2
  ))
}
nn_sf <- st_sf(
  from     = stations_utm$station_id,
  to       = stations_utm$station_id[nn_indices],
  dist_km  = nn_dists / 1000,
  geometry = st_sfc(nn_lines, crs = 32618)
)

hull_sf <- st_sf(geometry = st_sfc(hull, crs = 32618))

p2 <- ggplot() +
  geom_sf(data = hull_sf, fill = NA, linetype = "dashed", color = "gray70") +
  geom_sf(data = nn_sf, aes(color = dist_km), linewidth = 1) +
  scale_color_distiller(name = "NN Distance\n(km)", palette = "RdYlGn") +
  geom_sf(data = stations_utm, color = "black", size = 2.5) +
  geom_sf_text(data = stations_utm, aes(label = station_id),
               size = 2, nudge_y = 5000) +
  labs(title = sprintf("Nearest Neighbor Analysis (NNI = %.2f, p = %.4f)",
                       NNI, p_value),
       x = "Easting (m)", y = "Northing (m)") +
  theme_minimal(base_size = 11)

ggsave(file.path(DATA_DIR, "ex02_nearest_neighbor.png"), p2,
       width = 8, height = 7, dpi = 150)
cat("Saved: ex02_nearest_neighbor.png\n")


# =============================================================================
# EXERCISE 3: Kernel Density Estimation
# =============================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXERCISE 3: Kernel Density Estimation\n")
cat(strrep("=", 70), "\n")

# --- Load algal bloom data ---
blooms <- read.csv(file.path(SPATIAL_07, "algal_blooms.csv"))
blooms_sf <- st_as_sf(blooms, coords = c("lon", "lat"), crs = 4326)
blooms_utm <- st_transform(blooms_sf, 32618)
cat(sprintf("Loaded %d algal bloom sightings\n", nrow(blooms_utm)))

# --- Create spatstat point pattern ---
coords_blooms <- st_coordinates(blooms_utm)
bb <- st_bbox(blooms_utm)
pad <- 10000

win <- owin(
  xrange = c(bb["xmin"] - pad, bb["xmax"] + pad),
  yrange = c(bb["ymin"] - pad, bb["ymax"] + pad)
)
pp <- ppp(coords_blooms[, 1], coords_blooms[, 2], window = win)

# --- KDE with bandwidth = 5 km ---
kde_5k <- density(pp, sigma = 5000)
cat(sprintf("KDE (5 km): max density = %.2e\n", max(kde_5k$v, na.rm = TRUE)))

# --- KDE with bandwidth = 20 km ---
kde_20k <- density(pp, sigma = 20000)
cat(sprintf("KDE (20 km): max density = %.2e\n", max(kde_20k$v, na.rm = TRUE)))

# --- Three-panel figure ---
png(file.path(DATA_DIR, "ex03_kde.png"), width = 1800, height = 600, res = 150)
par(mfrow = c(1, 3), mar = c(4, 4, 3, 2))

# Panel 1: Raw points colored by severity
sev_cols <- colorRampPalette(c("yellow", "red"))(10)
sev_idx <- pmin(pmax(round(blooms$severity), 1), 10)
plot(coords_blooms, pch = 19, cex = 0.8,
     col = sev_cols[sev_idx],
     xlab = "Easting (m)", ylab = "Northing (m)",
     main = "A: Raw Bloom Locations",
     asp = 1)
legend("bottomright",
       legend = c("Low (1)", "High (10)"),
       pch = 19, col = c("yellow", "red"),
       cex = 0.7, title = "Severity")

# Panel 2: KDE, bw = 5 km
plot(kde_5k, main = "B: KDE (bandwidth = 5 km)")
points(pp, pch = ".", col = rgb(0, 0, 0, 0.3))

# Panel 3: KDE, bw = 20 km
plot(kde_20k, main = "C: KDE (bandwidth = 20 km)")
points(pp, pch = ".", col = rgb(0, 0, 0, 0.3))

dev.off()
cat("Saved: ex03_kde.png\n")

cat("\nInterpretation:\n")
cat("  - 5 km bandwidth reveals 3 distinct hotspots: mid-Bay, upper Bay,\n")
cat("    and Potomac tidal area. Useful for targeted bloom response.\n")
cat("  - 20 km bandwidth merges these into a single elongated region.\n")
cat("  Recommendation: Use 5 km bandwidth to preserve hotspot distinction.\n")


# =============================================================================
# EXERCISE 4: Global Moran's I — Spatial Autocorrelation
# =============================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXERCISE 4: Global Moran's I — Spatial Autocorrelation\n")
cat(strrep("=", 70), "\n")

# --- Load and join data ---
ws <- st_read(file.path(SPATIAL_06, "chesapeake_watersheds.gpkg"), quiet = TRUE)
ws_quality <- read.csv(file.path(SPATIAL_07, "watershed_quality.csv"),
                       colClasses = c(HUC8 = "character"))

# Ensure HUC8 is character (zero-padded) in both
ws$HUC8 <- as.character(ws$HUC8)
ws_quality$HUC8 <- sprintf("%08s", ws_quality$HUC8)

ws <- merge(ws, ws_quality, by = "HUC8", all.x = TRUE, suffixes = c("", "_csv"))
if ("Name_csv" %in% names(ws)) ws$Name_csv <- NULL

cat(sprintf("Loaded %d watersheds with nitrogen data\n", nrow(ws)))
cat(sprintf("Nitrogen range: %.1f - %.1f kg/ha/yr\n",
            min(ws$nitrogen_kg_ha), max(ws$nitrogen_kg_ha)))
cat(sprintf("Mean: %.2f, Std: %.2f\n",
            mean(ws$nitrogen_kg_ha), sd(ws$nitrogen_kg_ha)))

# --- Choropleth map ---
p4_choro <- ggplot() +
  geom_sf(data = ws, aes(fill = nitrogen_kg_ha),
          color = "white", linewidth = 0.3) +
  scale_fill_distiller(name = "Nitrogen\n(kg/ha/yr)",
                       palette = "YlOrRd", direction = 1) +
  labs(title = "Nitrogen Loading by HUC8 Watershed",
       x = "Longitude", y = "Latitude") +
  theme_minimal(base_size = 11)

ggsave(file.path(DATA_DIR, "ex04_nitrogen_choropleth.png"), p4_choro,
       width = 7, height = 7, dpi = 150)
cat("Saved: ex04_nitrogen_choropleth.png\n")

# --- Build Queen contiguity spatial weights ---
nb <- poly2nb(ws, queen = TRUE)
lw <- nb2listw(nb, style = "W")  # row-standardized

cat(sprintf("\nSpatial weights summary:\n"))
cat(sprintf("  Number of features: %d\n", length(nb)))
cat(sprintf("  Mean neighbors: %.1f\n", mean(card(nb))))
cat(sprintf("  Min neighbors: %d\n", min(card(nb))))
cat(sprintf("  Max neighbors: %d\n", max(card(nb))))

# --- Global Moran's I ---
moran_result <- moran.test(ws$nitrogen_kg_ha, lw)
mi_val <- moran_result$estimate["Moran I statistic"]
mi_exp <- moran_result$estimate["Expectation"]
mi_p   <- moran_result$p.value

cat(sprintf("\nGlobal Moran's I Results:\n"))
cat(sprintf("  Moran's I:     %.4f\n", mi_val))
cat(sprintf("  Expected I:    %.4f\n", mi_exp))
cat(sprintf("  p-value:       %.6f\n", mi_p))

if (mi_p < 0.05) {
  if (mi_val > 0) {
    cat("  Conclusion: SIGNIFICANT POSITIVE spatial autocorrelation.\n")
  } else {
    cat("  Conclusion: SIGNIFICANT NEGATIVE spatial autocorrelation.\n")
  }
} else {
  cat("  Conclusion: No significant spatial autocorrelation.\n")
}

# --- Moran's I with permutation test ---
moran_mc <- moran.mc(ws$nitrogen_kg_ha, lw, nsim = 999)
cat(sprintf("\nPermutation test (999 simulations):\n"))
cat(sprintf("  Moran's I: %.4f\n", moran_mc$statistic))
cat(sprintf("  p-value:   %.4f\n", moran_mc$p.value))

# --- Moran scatter plot ---
png(file.path(DATA_DIR, "ex04_moran_scatter.png"),
    width = 700, height = 700, res = 150)
moran.plot(ws$nitrogen_kg_ha, lw,
           xlab = "Nitrogen (standardized)",
           ylab = "Spatial Lag of Nitrogen",
           main = sprintf("Moran Scatter Plot (I = %.4f, p = %.4f)",
                          mi_val, mi_p),
           pch = 19, col = adjustcolor("#457b9d", alpha.f = 0.7))
dev.off()
cat("Saved: ex04_moran_scatter.png\n")

cat("\nInterpretation:\n")
cat("  Moran's I is strongly positive and highly significant.\n")
cat("  Nitrogen loading is spatially clustered: high-N watersheds neighbor\n")
cat("  other high-N watersheds. The Bay Program can target contiguous regions.\n")


# =============================================================================
# EXERCISE 5: Local Moran's I (LISA)
# =============================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXERCISE 5: Local Moran's I (LISA)\n")
cat(strrep("=", 70), "\n")

# --- Compute Local Moran's I ---
lisa <- localmoran(ws$nitrogen_kg_ha, lw)

ws$Ii      <- lisa[, "Ii"]
ws$p_value <- lisa[, "Pr(z != E(Ii))"]

# --- Classify into quadrants ---
z_val <- scale(ws$nitrogen_kg_ha)[, 1]   # standardized values
lag_z <- lag.listw(lw, z_val)            # spatial lag

ws$cluster <- "Not Significant"
sig <- ws$p_value < 0.05
ws$cluster[sig & z_val > 0 & lag_z > 0] <- "HH (Hot Spot)"
ws$cluster[sig & z_val < 0 & lag_z < 0] <- "LL (Cold Spot)"
ws$cluster[sig & z_val > 0 & lag_z < 0] <- "HL (High Outlier)"
ws$cluster[sig & z_val < 0 & lag_z > 0] <- "LH (Low Outlier)"

cat("LISA cluster classification:\n")
print(table(ws$cluster))

# --- Report significant clusters ---
sig_ws <- ws[ws$cluster != "Not Significant", ]
sig_ws <- sig_ws[order(sig_ws$cluster), ]
cat(sprintf("\nSignificant clusters (p < 0.05):\n"))
for (i in seq_len(nrow(sig_ws))) {
  cat(sprintf("  %40s: %20s (N = %.1f kg/ha, Ii = %.3f, p = %.4f)\n",
              sig_ws$Name[i], sig_ws$cluster[i],
              sig_ws$nitrogen_kg_ha[i], sig_ws$Ii[i], sig_ws$p_value[i]))
}

# --- Make cluster a factor with defined levels and colors ---
ws$cluster <- factor(ws$cluster, levels = c(
  "HH (Hot Spot)", "HL (High Outlier)", "LH (Low Outlier)",
  "LL (Cold Spot)", "Not Significant"
))

cluster_colors <- c(
  "HH (Hot Spot)"     = "#d7191c",
  "HL (High Outlier)" = "#fdae61",
  "LH (Low Outlier)"  = "#abd9e9",
  "LL (Cold Spot)"    = "#2c7bb6",
  "Not Significant"   = "#e0e0e0"
)

# --- Two-panel figure ---
# Panel A: Nitrogen choropleth
pA <- ggplot() +
  geom_sf(data = ws, aes(fill = nitrogen_kg_ha),
          color = "white", linewidth = 0.3) +
  scale_fill_distiller(name = "Nitrogen\n(kg/ha/yr)",
                       palette = "YlOrRd", direction = 1) +
  labs(title = "A: Nitrogen Loading (kg/ha/yr)") +
  theme_minimal(base_size = 10) +
  theme(axis.title = element_blank())

# Panel B: LISA cluster map
pB <- ggplot() +
  geom_sf(data = ws, aes(fill = cluster),
          color = "white", linewidth = 0.3) +
  scale_fill_manual(name = "LISA Cluster", values = cluster_colors,
                    drop = FALSE) +
  labs(title = sprintf("B: LISA Clusters (Global I = %.3f)", mi_val)) +
  theme_minimal(base_size = 10) +
  theme(axis.title = element_blank())

# Combine panels side by side
library(patchwork)
p5_combined <- pA + pB +
  plot_annotation(
    title = "Nitrogen Loading — Spatial Autocorrelation Analysis",
    theme = theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5))
  )

ggsave(file.path(DATA_DIR, "ex05_lisa.png"), p5_combined,
       width = 14, height = 7, dpi = 150)
cat("Saved: ex05_lisa.png\n")

# --- Labeled LISA cluster map ---
sig_ws_labels <- ws[ws$cluster != "Not Significant", ]
sig_centroids <- st_centroid(sig_ws_labels)

p5_labeled <- ggplot() +
  geom_sf(data = ws, aes(fill = cluster),
          color = "white", linewidth = 0.4) +
  scale_fill_manual(name = "LISA Cluster", values = cluster_colors,
                    drop = FALSE) +
  geom_sf_text(data = sig_centroids, aes(label = Name),
               size = 2.2, fontface = "bold", check_overlap = TRUE) +
  labs(title = "LISA Cluster Map with Labeled Significant Watersheds",
       x = "Longitude", y = "Latitude") +
  theme_minimal(base_size = 11)

suppressWarnings(
  ggsave(file.path(DATA_DIR, "ex05_lisa_labeled.png"), p5_labeled,
         width = 9, height = 8, dpi = 150)
)
cat("Saved: ex05_lisa_labeled.png\n")

cat("\nInterpretation:\n")
cat("  Hot Spots (HH): Southern Bay tributaries (James, York, Rappahannock,\n")
cat("  Hampton Roads) — high nitrogen from agriculture and urbanization.\n\n")
cat("  Cold Spots (LL): Northern headwaters (upper Susquehanna, Chemung,\n")
cat("  Tioga) — forested, low-development watersheds.\n\n")
cat("  The LISA map pinpoints specific watersheds for targeted nutrient\n")
cat("  management, showing southern tributaries as priority areas.\n")

cat("\n=== All exercises complete. Output files saved. ===\n")
