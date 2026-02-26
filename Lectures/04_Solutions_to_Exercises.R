# =============================================================================
# Lecture 4: Data Visualization and Interpretation — Solutions (R)
# Environmental Data Science (ENST431/631)
# Author: Akash Koppa
# =============================================================================

# Each exercise below is fully self-contained: it includes all data loading,
# preparation, and transformation code needed to run independently.

# =============================================================================
# EXERCISE 1: Visualizing the Oxygen Profile
# =============================================================================

# --- Data Setup (self-contained) ---
do_readings <- c(8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5)
depths <- 1:10
monthly_temps <- c(Jan = 4.2, Feb = 4.5, Mar = 8.1, Apr = 12.5, May = 17.3,
                   Jun = 22.1, Jul = 26.8, Aug = 26.5, Sep = 22.4,
                   Oct = 16.3, Nov = 10.7, Dec = 6.1)

# --- Figure A: DO Depth Profile ---
# Convention: depth on y-axis, increasing downward (mimics the water column)
plot(do_readings, depths,
     type = "b", pch = 19, col = "steelblue", lwd = 2, cex = 1.2,
     xlim = c(0, 10), ylim = c(10, 1),
     xlab = "Dissolved Oxygen (mg/L)",
     ylab = "Depth Position (surface = 1, bottom = 10)",
     main = "Dissolved Oxygen Declines Sharply Below Position 6\nat Station CB-5.1")

# EPA hypoxia threshold
abline(v = 5.0, col = "red", lty = 2, lwd = 2)
text(5.3, 1.5, "EPA Hypoxia\nThreshold (5.0 mg/L)", col = "red", cex = 0.75, adj = 0)

# Shade hypoxic zone
rect(xleft = 0, xright = 5.0, ybottom = 10, ytop = 1,
     col = rgb(1, 0, 0, 0.05), border = NA)

# --- Figure B: Seasonal Temperature Cycle ---
# Bar chart with conditional coloring to highlight warm months
temp_colors <- ifelse(monthly_temps > 20, "#d62828", "#457b9d")
bp <- barplot(monthly_temps, names.arg = names(monthly_temps),
              col = temp_colors, border = "white",
              xlab = "Month",
              ylab = "Water Temperature (\u00B0C)",
              main = "Four Months Exceed 20\u00B0C at Station CB-5.1\n(Jun\u2013Sep: Elevated Risk of Oxygen Depletion)",
              ylim = c(0, 30))

# 20 degree threshold
abline(h = 20, col = "red", lty = 2, lwd = 1.5)
text(bp[1], 21, "20\u00B0C threshold", col = "red", cex = 0.7, adj = 0)

# Legend
legend("topright",
       legend = c("Above 20\u00B0C", "Below 20\u00B0C"),
       fill = c("#d62828", "#457b9d"), border = "white", cex = 0.8)


# =============================================================================
# EXERCISE 2: Mapping the Data Gaps
# =============================================================================

# --- Data Setup (self-contained) ---
data <- read.csv("water_quality.csv", na.strings = c("NA", "-999", "-9999"))
data$date <- as.Date(data$date)
names(data)[names(data) == "turbidity_ntu"] <- "turbidity"

# --- Figure: Missing Data Pattern ---
# Two-panel figure: (1) NA counts by variable, (2) NA counts by station

par(mfrow = c(1, 2), mar = c(5, 6, 3, 1))

# Panel 1: NA counts by variable
na_counts <- sapply(data, function(x) sum(is.na(x)))
na_counts_sorted <- sort(na_counts[na_counts > 0], decreasing = TRUE)
barplot(na_counts_sorted, horiz = TRUE, las = 1,
        col = "steelblue", border = "white",
        xlab = "Number of Missing Values",
        main = "Missing Values by Variable")

# Panel 2: NA counts by station for DO
na_by_station <- tapply(is.na(data$do_mg_l), data$station, sum)
barplot(na_by_station, horiz = TRUE, las = 1,
        col = "#d62828", border = "white",
        xlab = "Number of Missing DO Values",
        main = "Missing DO by Station")

par(mfrow = c(1, 1))


# =============================================================================
# EXERCISE 3: Diagnosing Data Quality Visually
# =============================================================================

# --- Data Setup (self-contained) ---
data <- read.csv("water_quality.csv", na.strings = c("NA", "-999", "-9999"))
data$date <- as.Date(data$date)
names(data)[names(data) == "turbidity_ntu"] <- "turbidity"

# --- Figure: Four-panel distribution check ---
par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))

# Temperature
hist(data$temp_c, breaks = 25, col = "#457b9d", border = "white",
     main = "Temperature Distribution",
     xlab = "Temperature (\u00B0C)", ylab = "Frequency")
abline(v = c(0, 35), col = "red", lty = 2, lwd = 2)
legend("topright", legend = "Plausible range", lty = 2, col = "red", cex = 0.7)

# Dissolved Oxygen
hist(data$do_mg_l, breaks = 25, col = "#2a9d8f", border = "white",
     main = "Dissolved Oxygen Distribution",
     xlab = "Dissolved Oxygen (mg/L)", ylab = "Frequency")
abline(v = c(0, 15), col = "red", lty = 2, lwd = 2)

# pH
hist(data$ph, breaks = 25, col = "#e9c46a", border = "white",
     main = "pH Distribution",
     xlab = "pH", ylab = "Frequency")
abline(v = c(6, 9), col = "red", lty = 2, lwd = 2)

# Turbidity
hist(data$turbidity, breaks = 25, col = "#f4a261", border = "white",
     main = "Turbidity Distribution",
     xlab = "Turbidity (NTU)", ylab = "Frequency")
abline(v = 0, col = "red", lty = 2, lwd = 2)

par(mfrow = c(1, 1))


# =============================================================================
# EXERCISE 4: Visualizing the Hypoxia Event
# =============================================================================

# --- Data Setup (self-contained) ---
data <- read.csv("water_quality.csv", na.strings = c("NA", "-999", "-9999"))
data$date <- as.Date(data$date)
names(data)[names(data) == "turbidity_ntu"] <- "turbidity"

# --- Filter to July 23rd event data ---
event <- data[data$date == as.Date("2025-07-23") &
              (data$do_mg_l < 6.0 | data$turbidity > 15), ]

# --- Figure: DO vs Turbidity Scatter with Quadrant Annotations ---
station_factor <- factor(event$station)
okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
               "#0072B2", "#D55E00", "#CC79A7", "#999999")
point_colors <- okabe_ito[as.numeric(station_factor)]

plot(event$turbidity, event$do_mg_l,
     pch = 19, cex = 1.5, col = point_colors,
     xlab = "Turbidity (NTU)",
     ylab = "Dissolved Oxygen (mg/L)",
     main = "July 23 Hypoxia Event: Low DO and High Turbidity\nCo-Occur at Multiple Stations",
     xlim = c(min(event$turbidity, na.rm = TRUE) - 2,
              max(event$turbidity, na.rm = TRUE) + 5),
     ylim = c(min(event$do_mg_l, na.rm = TRUE) - 0.5,
              max(event$do_mg_l, na.rm = TRUE) + 0.5))

# Reference lines
abline(h = 6.0, col = "red", lty = 2, lwd = 1.5)
abline(v = 15, col = "darkorange", lty = 2, lwd = 1.5)

# Label the critical quadrant
text(max(event$turbidity, na.rm = TRUE) * 0.85,
     min(event$do_mg_l, na.rm = TRUE) + 0.3,
     "Critical Zone:\nLow DO + High Turbidity",
     col = "red", cex = 0.75, font = 2)

# Label points with station IDs
text(event$turbidity, event$do_mg_l,
     labels = event$station, pos = 4, cex = 0.65, col = "gray30")

# Legend
legend("topright",
       legend = levels(station_factor),
       col = okabe_ito[1:nlevels(station_factor)],
       pch = 19, cex = 0.8, title = "Station")


# =============================================================================
# EXERCISE 5: The Annual Report Timeline
# =============================================================================

# --- Data Setup (self-contained) ---
data <- read.csv("water_quality.csv", na.strings = c("NA", "-999", "-9999"))
data$date <- as.Date(data$date)
names(data)[names(data) == "turbidity_ntu"] <- "turbidity"

# --- Derived columns from Lecture 2 Exercise 5 ---
data$do_percent_sat <- (data$do_mg_l / 8.0) * 100
data$do_status <- ifelse(is.na(data$do_mg_l), "Unknown",
                  ifelse(data$do_mg_l < 2, "Hypoxic",
                  ifelse(data$do_mg_l < 5, "Stressed",
                  ifelse(data$do_mg_l < 8, "Adequate", "Healthy"))))

# --- Figure: Two-panel timeline ---
par(mfrow = c(2, 1), mar = c(4, 4, 3, 1))

# Panel 1: DO percent saturation over time, colored by status
status_colors <- c(Hypoxic = "#d62828", Stressed = "#f77f00",
                   Adequate = "#457b9d", Healthy = "#2a9d8f",
                   Unknown = "gray70")
plot(data$date, data$do_percent_sat,
     pch = 19, cex = 0.7,
     col = status_colors[data$do_status],
     xlab = "Date",
     ylab = "DO Percent Saturation (%)",
     main = "Water Quality Status Across the 2025 Monitoring Season")
abline(h = 100, col = "gray40", lty = 2)
text(min(data$date), 102, "100% Saturation", col = "gray40", cex = 0.7, adj = 0)
legend("bottomleft",
       legend = names(status_colors),
       col = status_colors, pch = 19, cex = 0.7,
       ncol = 3, title = "Water Quality Status")

# Panel 2: Temperature over time
plot(data$date, data$temp_c,
     pch = 19, cex = 0.5, col = adjustcolor("#d62828", alpha.f = 0.5),
     xlab = "Date",
     ylab = "Water Temperature (\u00B0C)",
     main = "Temperature Drives Seasonal Oxygen Depletion")
abline(h = 20, col = "red", lty = 2)
text(min(data$date), 21, "20\u00B0C", col = "red", cex = 0.7, adj = 0)

par(mfrow = c(1, 1))


# =============================================================================
# EXERCISE 6: The Station Scorecard
# =============================================================================

# --- Data Setup (self-contained) ---
data <- read.csv("water_quality.csv", na.strings = c("NA", "-999", "-9999"))
data$date <- as.Date(data$date)
names(data)[names(data) == "turbidity_ntu"] <- "turbidity"

# --- Station summary from Lecture 2 Exercise 6 ---
station_summary <- do.call(rbind, lapply(unique(data$station), function(st) {
  sub <- data[data$station == st, ]
  data.frame(
    station = st,
    mean_temp = mean(sub$temp_c, na.rm = TRUE),
    mean_do = mean(sub$do_mg_l, na.rm = TRUE),
    max_turbidity = max(sub$turbidity, na.rm = TRUE),
    n_obs = nrow(sub),
    prop_stressed = mean(sub$do_mg_l < 6, na.rm = TRUE)
  )
}))

# --- Figure: Cleveland dot plot of mean DO, sorted ---
ord <- order(station_summary$mean_do)
dotchart(station_summary$mean_do[ord],
         labels = station_summary$station[ord],
         pch = 19, col = "#457b9d", cex = 1.2,
         xlab = "Mean Dissolved Oxygen (mg/L)",
         main = "Station Performance Ranked by Mean DO\nLowest Stations Need Priority Intervention")

# Reference lines
abline(v = 5.0, col = "#d62828", lty = 2, lwd = 2)
text(5.2, 1, "Stress threshold\n(5.0 mg/L)", col = "#d62828", cex = 0.7)

abline(v = 2.0, col = "#d62828", lty = 3, lwd = 1.5)
text(2.2, 1, "Hypoxia\n(2.0 mg/L)", col = "#d62828", cex = 0.7)

# Point size encodes proportion stressed
point_sizes <- 1 + station_summary$prop_stressed[ord] * 4
points(station_summary$mean_do[ord],
       1:nrow(station_summary),
       pch = 1, cex = point_sizes, col = "#d62828")


# =============================================================================
# EXERCISE 7: Revealing Seasonal Patterns in Legacy Data
# =============================================================================

# --- Data Setup (self-contained) ---
temps_wide <- data.frame(
  station = c("CB-5.1", "CB-5.2"),
  jan = c(4.2, 3.8), apr = c(12.5, 11.9),
  jul = c(26.8, 27.1), oct = c(16.3, 15.8)
)

long_data <- reshape(temps_wide, direction = "long",
                     varying = list(c("jan", "apr", "jul", "oct")),
                     v.names = "temperature", timevar = "month",
                     times = c("Jan", "Apr", "Jul", "Oct"))

# --- Figure: Overlaid line plot ---
stations <- unique(long_data$station)
colors <- c("#457b9d", "#d62828")
month_nums <- c(Jan = 1, Apr = 4, Jul = 7, Oct = 10)

plot(NULL,
     xlim = c(1, 12), ylim = range(long_data$temperature),
     xlab = "Month", ylab = "Temperature (\u00B0C)",
     main = "Seasonal Temperature Cycle Consistent Across Stations\n(Legacy Data: CB-5.1 vs CB-5.2)",
     xaxt = "n")
axis(1, at = c(1, 4, 7, 10), labels = c("Jan", "Apr", "Jul", "Oct"))

for (i in seq_along(stations)) {
  sub <- long_data[long_data$station == stations[i], ]
  x_positions <- month_nums[sub$month]
  lines(x_positions, sub$temperature,
        col = colors[i], type = "b", pch = 19, lwd = 2, cex = 1.3)
}

legend("topleft", legend = stations,
       col = colors, lty = 1, pch = 19, lwd = 2, cex = 0.9)

# Seasonal range annotation
for (i in seq_along(stations)) {
  sub <- long_data[long_data$station == stations[i], ]
  range_val <- max(sub$temperature) - min(sub$temperature)
  text(11, min(sub$temperature) + range_val / 2 + (i - 1) * 1.5,
       paste0(stations[i], "\nRange: ", round(range_val, 1), "\u00B0C"),
       cex = 0.7, col = colors[i])
}


# =============================================================================
# EXERCISE 8: Exploring Nutrient-Oxygen Connections
# =============================================================================

# --- Data Setup (self-contained) ---
data <- read.csv("water_quality.csv", na.strings = c("NA", "-999", "-9999"))
data$date <- as.Date(data$date)
names(data)[names(data) == "turbidity_ntu"] <- "turbidity"

# --- Station metadata from Lecture 2 Exercise 8 ---
station_meta <- data.frame(
  station = c("CB-5.1", "CB-5.2", "CB-5.3", "CB-6.1"),
  region = c("Main Stem", "Main Stem", "Main Stem", "Lower Bay"),
  type = c("Fixed", "Fixed", "Fixed", "Rotating"),
  lat = c(38.978, 38.856, 38.742, 37.587),
  lon = c(-76.381, -76.372, -76.321, -76.138)
)

# --- Nutrient data from Lecture 2 Exercise 8 ---
nutrient_data <- data.frame(
  station = c("CB-5.1", "CB-5.2", "CB-6.1"),
  date = as.Date(c("2025-06-15", "2025-06-15", "2025-06-15")),
  nitrogen_mg_l = c(1.2, 1.5, 0.9),
  phosphorus_mg_l = c(0.08, 0.12, 0.06)
)

# --- Merge all three datasets ---
merged <- merge(data, station_meta, by = "station", all.x = TRUE)
merged <- merge(merged, nutrient_data, by = c("station", "date"), all.x = TRUE)
# Keep only rows with nutrient data for plotting
merged <- merged[!is.na(merged$nitrogen_mg_l), ]

# --- Figure: Scatter with region color and phosphorus size ---
region_colors <- ifelse(merged$region == "Main Stem", "#457b9d", "#d62828")
phos_sizes <- merged$phosphorus_mg_l * 40 + 1  # scale for visibility

plot(merged$nitrogen_mg_l, merged$do_mg_l,
     pch = 19,
     col = adjustcolor(region_colors, alpha.f = 0.6),
     cex = phos_sizes / 5,
     xlab = "Nitrogen Concentration (mg/L)",
     ylab = "Dissolved Oxygen (mg/L)",
     main = "Higher Nitrogen Associated with Lower Dissolved Oxygen\nin Main Stem Stations")

# Trend line
fit <- lm(do_mg_l ~ nitrogen_mg_l, data = merged)
abline(fit, col = "gray40", lty = 2, lwd = 1.5)

# Legend for regions
legend("topright",
       legend = c("Main Stem", "Lower Bay"),
       col = c("#457b9d", "#d62828"),
       pch = 19, cex = 0.9, title = "Region")

# Legend for phosphorus (approximate)
legend("bottomleft",
       legend = c("Low P", "High P"),
       pt.cex = c(1, 2.5), pch = 1, cex = 0.8,
       title = "Phosphorus (mg/L)")


# =============================================================================
# EXERCISE 9: Diagnosing Oxygen Stress with Your Toolkit
# =============================================================================

# --- Data Setup (self-contained) ---
data <- read.csv("water_quality.csv", na.strings = c("NA", "-999", "-9999"))
data$date <- as.Date(data$date)
names(data)[names(data) == "turbidity_ntu"] <- "turbidity"

# --- Functions from Lecture 2 Exercise 9 ---
calc_saturation_deficit <- function(do_measured, temperature) {
  do_saturated <- 14.62 - (0.3898 * temperature)
  return(do_saturated - do_measured)
}

classify_water_quality <- function(do_val, temp,
                                   hypoxic_threshold = 2.0,
                                   stress_threshold = 5.0) {
  if (is.na(do_val) | is.na(temp)) return("Unknown")
  if (do_val < hypoxic_threshold) return("Critical")
  if (do_val < stress_threshold) return("Stressed")
  if (temp > 28) return("Heat Stress")
  return("Good")
}

# --- Apply functions to dataset ---
data$sat_deficit <- calc_saturation_deficit(data$do_mg_l, data$temp_c)
data$wq_class <- mapply(classify_water_quality, data$do_mg_l, data$temp_c)

# --- Figure: Saturation deficit vs temperature ---
class_colors <- c(Critical = "#d62828", Stressed = "#f77f00",
                  "Heat Stress" = "#7b2d8b", Good = "#2a9d8f",
                  Unknown = "gray70")
point_cols <- class_colors[data$wq_class]

plot(data$temp_c, data$sat_deficit,
     pch = 19, cex = 0.8,
     col = adjustcolor(point_cols, alpha.f = 0.5),
     xlab = "Water Temperature (\u00B0C)",
     ylab = "Saturation Deficit (mg/L)",
     main = "Oxygen Deficit Peaks at High Temperatures\n(Warm Water Holds Less Oxygen and Actual DO Drops)")

# Theoretical saturation curve
temp_seq <- seq(min(data$temp_c, na.rm = TRUE),
                max(data$temp_c, na.rm = TRUE), by = 0.5)
do_sat <- 14.62 - 0.3898 * temp_seq
lines(temp_seq, do_sat, col = "gray30", lwd = 2, lty = 2)
text(max(temp_seq) - 2, max(do_sat) - 0.5,
     "Theoretical\nMax DO", col = "gray30", cex = 0.7)

# Zero deficit line
abline(h = 0, col = "gray60", lty = 3)

legend("topleft",
       legend = names(class_colors[class_colors != "gray70"]),
       col = class_colors[class_colors != "gray70"],
       pch = 19, cex = 0.8, title = "Classification")


# =============================================================================
# EXERCISE 10: Visualizing Uncertainty in Simulations
# =============================================================================

# --- Data Setup (self-contained) ---
simulate_hypoxia <- function() {
  do_level <- 8.0
  trajectory <- do_level
  while (do_level >= 2.0) {
    do_level <- do_level - runif(1, 0.1, 0.5)
    trajectory <- c(trajectory, do_level)
  }
  return(trajectory)
}

# Run 100 simulations
set.seed(42)
sims <- lapply(1:100, function(i) simulate_hypoxia())
days_to_hypoxia <- sapply(sims, length) - 1

# --- Figure A: Simulation Trajectories ---
max_days <- max(sapply(sims, length))

plot(NULL,
     xlim = c(0, max_days), ylim = c(0, 9),
     xlab = "Day",
     ylab = "Dissolved Oxygen (mg/L)",
     main = "100 Simulated Hypoxia Events: Envelope of Possible Trajectories")

# Draw all trajectories with transparency
for (traj in sims) {
  lines(0:(length(traj) - 1), traj,
        col = adjustcolor("#457b9d", alpha.f = 0.12), lwd = 0.8)
}

# Highlight the median trajectory (closest to median days)
median_days <- median(days_to_hypoxia)
median_idx <- which.min(abs(days_to_hypoxia - median_days))[1]
lines(0:(length(sims[[median_idx]]) - 1), sims[[median_idx]],
      col = "#d62828", lwd = 2.5)

# Reference lines for DO thresholds
abline(h = 8.0, col = "#2a9d8f", lty = 2, lwd = 1.5)
abline(h = 5.0, col = "#f77f00", lty = 2, lwd = 1.5)
abline(h = 2.0, col = "#d62828", lty = 2, lwd = 1.5)

# Labels
text(max_days * 0.9, 8.3, "Healthy (8.0)", col = "#2a9d8f", cex = 0.7)
text(max_days * 0.9, 5.3, "Stressed (5.0)", col = "#f77f00", cex = 0.7)
text(max_days * 0.9, 2.3, "Critical (2.0)", col = "#d62828", cex = 0.7)

legend("topright",
       legend = c("Individual simulation", "Median trajectory"),
       col = c(adjustcolor("#457b9d", alpha.f = 0.4), "#d62828"),
       lwd = c(1, 2.5), cex = 0.8)


# --- Figure B: Distribution of Days to Hypoxia ---
hist(days_to_hypoxia, breaks = 15,
     col = "#457b9d", border = "white",
     main = "Distribution of Days to Critical Hypoxia (DO < 2.0 mg/L)\nBased on 100 Stochastic Simulations",
     xlab = "Days Until Critical Hypoxia",
     ylab = "Number of Simulations")

# Median line
abline(v = median(days_to_hypoxia), col = "#d62828", lwd = 2.5)
text(median(days_to_hypoxia) + 0.5, par("usr")[4] * 0.9,
     paste0("Median: ", median(days_to_hypoxia), " days"),
     col = "#d62828", cex = 0.85, adj = 0, font = 2)

# IQR shading
q25 <- quantile(days_to_hypoxia, 0.25)
q75 <- quantile(days_to_hypoxia, 0.75)
rect(xleft = q25, xright = q75,
     ybottom = par("usr")[3], ytop = par("usr")[4],
     col = rgb(0.85, 0.17, 0.16, 0.1), border = NA)
text(q75 + 0.3, par("usr")[4] * 0.75,
     paste0("IQR: ", q25, "\u2013", q75, " days"),
     col = "#d62828", cex = 0.75, adj = 0)

# Risk statement
cat("\n--- Risk Statement ---\n")
cat(sprintf("Based on 100 simulations, critical hypoxia is expected within %d-%d days,\n",
            min(days_to_hypoxia), max(days_to_hypoxia)))
cat(sprintf("with a median of %d days.\n", median(days_to_hypoxia)))
pct_fast <- mean(days_to_hypoxia <= quantile(days_to_hypoxia, 0.1)) * 100
cat(sprintf("In %.0f%% of simulations, critical conditions developed within %d days.\n",
            pct_fast, quantile(days_to_hypoxia, 0.1)))
cat(sprintf("Summary quantiles: %s\n",
            paste(names(quantile(days_to_hypoxia, c(0.05, 0.25, 0.5, 0.75, 0.95))),
                  quantile(days_to_hypoxia, c(0.05, 0.25, 0.5, 0.75, 0.95)),
                  sep = "=", collapse = ", ")))
