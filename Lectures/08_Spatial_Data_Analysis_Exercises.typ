// =============================================================================
// Lecture 7: Spatial Data Analysis - Exercises
// Environmental Data Science (ENST431/631)
// Author: Akash Koppa
// =============================================================================

// --- CONFIGURATION & COLORS ---
#let primary-color = rgb("#2d5a27")
#let accent-color = rgb("#457b9d")
#let bg-color = rgb("#fdfdfc")
#let text-color = rgb("#2f2f2f")
#let warning-color = rgb("#c44536")
#let map-color = rgb("#1a6b72")

// --- PAGE SETUP ---
#set page(
  paper: "us-letter",
  fill: bg-color,
  margin: (x: 1in, y: 0.85in),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 9pt, fill: text-color.lighten(40%))
      #grid(
        columns: (1fr, 1fr),
        align(left)[ENST431: Environmental Data Science],
        align(right)[Lecture 7: Spatial Data Analysis]
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.5pt + text-color.lighten(70%))
    ]
  },
  footer: context {
    set text(size: 9pt, fill: text-color.lighten(40%))
    align(center)[Page #counter(page).display() of #counter(page).final().first()]
  }
)

#set text(size: 10.5pt, fill: text-color, font: "New Computer Modern")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: none)

// --- CUSTOM COMPONENTS ---
#let title-block(title: "", subtitle: "", author: "", date: "") = {
  set align(center)
  v(1em)
  block(width: 100%, inset: 1.5em, stroke: (bottom: 3pt + primary-color), [
    #text(2em, weight: "bold", fill: primary-color, title)
    #v(0.3em)
    #text(1.1em, fill: text-color.lighten(20%), subtitle)
    #v(0.8em)
    #text(1em, author)
    #v(0.2em)
    #text(0.9em, fill: text-color.lighten(30%), date)
  ])
  v(1.5em)
}

#let focus-box(title: "Note", color: accent-color, body) = {
  v(0.4em)
  rect(fill: color.lighten(92%), stroke: (left: 4pt + color), width: 100%, inset: 1em, radius: 4pt, [
    #text(weight: "bold", fill: color, size: 10pt, title)
    #v(0.3em)
    #set text(size: 10pt)
    #body
  ])
  v(0.4em)
}

#let exercise-header(number: 1, title: "", difficulty: "Beginner") = {
  let diff-color = if difficulty == "Beginner" { primary-color.lighten(20%) } else if difficulty == "Intermediate" { accent-color } else { warning-color }

  v(1em)
  block(width: 100%, stroke: 1.5pt + primary-color.lighten(40%), radius: 6pt, clip: true, [
    #block(width: 100%, fill: primary-color.lighten(85%), inset: (x: 1em, y: 0.7em), [
      #grid(columns: (auto, 1fr, auto), align: (left, left, right), gutter: 0.8em,
        [#text(weight: "bold", fill: primary-color, size: 12pt)[Exercise #number]],
        [#text(weight: "semibold", fill: text-color, size: 11pt)[#title]],
        [#box(fill: diff-color.lighten(70%), stroke: 0.5pt + diff-color, inset: (x: 0.5em, y: 0.2em), radius: 3pt, text(size: 8pt, fill: diff-color.darken(20%), weight: "medium", difficulty))]
      )
    ])
  ])
  v(0.5em)
}

#let context-box(body)       = { focus-box(title: "The Problem", color: rgb("#5a8f7b"), body) }
#let spatial-think-box(body) = { focus-box(title: "Think Before You Code", color: accent-color, body) }
#let hint-box(body)          = { focus-box(title: "R Syntax Hints", color: primary-color.lighten(10%), body) }
#let python-hint-box(body)   = { focus-box(title: "Python Syntax Hints", color: rgb("#306998"), body) }

#let code-block(code) = {
  v(0.3em)
  rect(fill: luma(248), stroke: 0.5pt + luma(200), width: 100%, inset: 0.7em, radius: 4pt, [
    #set text(size: 9pt, font: "DejaVu Sans Mono")
    #code
  ])
  v(0.3em)
}

// =============================================================================
// TITLE PAGE
// =============================================================================

#title-block(
  title: "Spatial Data Analysis",
  subtitle: "Programming Exercises for Environmental Data Science",
  author: "Instructor: Akash Koppa",
  date: "Lecture 7, Spring Semester 2026"
)

// --- INTRODUCTION ---
#text(weight: "semibold", size: 12pt, fill: primary-color)[Introduction]
#v(0.3em)

These five exercises walk you through the core spatial analysis techniques covered in Lecture 7, from computing spatial descriptive statistics to identifying local clusters with LISA. Each exercise builds on the Chesapeake Bay theme from earlier lectures and uses real watershed boundaries alongside synthetic water quality data. By the end, you will have computed spatial centers, tested for clustering, estimated density surfaces, and produced publication-quality maps of spatial autocorrelation patterns.

#focus-box(title: "Thematic Setting", color: map-color)[
  All exercises use the Chesapeake Bay watershed, drawing on monitoring station data, simulated algal bloom observations, and synthetic nitrogen loading estimates. These workflows mirror the spatial analysis methods used by environmental agencies to detect pollution hotspots, evaluate monitoring network design, and prioritize management actions.
]

#v(0.5em)
#text(weight: "semibold", size: 11pt, fill: accent-color)[Data Files]

#table(
  columns: (auto,),
  stroke: 0.5pt + luma(200),
  fill: (col, row) => if row == 0 { primary-color.lighten(85%) } else { white },
  inset: (x: 0.7em, y: 0.5em),
  [*File*],
  [`stations.csv`],
  [`chesapeake_watersheds.gpkg`],
  [`algal_blooms.csv`],
  [`watershed_quality.csv`],
)

#v(0.5em)
#text(weight: "semibold", size: 11pt, fill: accent-color)[How to Use This Document]

For each exercise, follow this workflow:

+ *Read the problem*: identify the environmental question and the required output.
+ *Think spatially*: answer the questions in the "Think Before You Code" box before writing any code.
+ *Load and explore*: always inspect a spatial dataset before performing analysis.
+ *Solve and map*: produce the required output with a clear, labeled map or plot.
+ *Interpret*: write 2--3 sentences describing what the result tells you about the environmental system.

#v(0.5em)

#focus-box(title: "Setup Required", color: warning-color)[
  *R packages*: `sf`, `tmap`, `tidyverse`, `spdep` (spatial weights and Moran's I), `spatstat` (KDE and point patterns). *Python packages*: `geopandas`, `matplotlib`, `numpy`, `scipy`, `scikit-learn`, `libpysal`, `esda`, `splot`, `pointpats`. All data files should be placed in a single folder. Set your working directory to that folder before running any code.
]

#pagebreak()

// =============================================================================
// EXERCISE 1
// =============================================================================

#exercise-header(number: 1, title: "Spatial Descriptive Statistics", difficulty: "Beginner")

#context-box[
  Spatial descriptive statistics summarize the central tendency and spread of a point pattern, just as the mean and standard deviation summarize a column of numbers. The 20 Chesapeake Bay monitoring stations vary in dissolved oxygen levels across the Bay. Compute the *mean center*, *weighted mean center* (using DO as the weight), and *standard distance* to determine where the geographic center of the network lies and how weighting by dissolved oxygen shifts that center.
]

*Your Primary Tasks*

- Load `stations.csv` and convert to a spatial object with CRS EPSG:4326.
- Compute the *mean center* (arithmetic mean of longitude and latitude).
- Compute the *weighted mean center* using `mean_do_mgl` as the weight. Recall that the weighted mean of a coordinate is:

  $ overline(x)_w = (sum w_i x_i) / (sum w_i) $

  where $w_i$ is the dissolved oxygen value and $x_i$ is the longitude (or latitude) of station $i$.
- Compute the *standard distance*: the average distance of all stations from the mean center.

  $ "SD" = sqrt(1 / n sum_(i=1)^n d_i^2) $

  where $d_i$ is the distance from station $i$ to the mean center. For simplicity, compute this in degrees (or reproject to UTM 18N for meters).
- Create a single map showing: (a) all 20 stations colored by `mean_do_mgl`, (b) the unweighted mean center as a red triangle, (c) the weighted mean center as a blue triangle, and (d) a circle of radius equal to the standard distance centered on the mean center.
- In which direction does the weighted center shift relative to the unweighted center? What does this tell you about where high-DO (healthy) stations are concentrated?

#spatial-think-box[
  - What is the difference between the mean center and a centroid of the convex hull? When would each be appropriate?
  - If all stations had identical DO values, what would happen to the weighted mean center?
  - Why might you want to weight by *inverse* DO (i.e., $w_i = 1 "/" "DO"_i$) instead? What environmental question would that answer?
  - The standard distance is analogous to the standard deviation. If you computed two standard distances---one for stations with DO above the median and one for stations below---what would a difference in their values tell you?
]

#hint-box[
  *Mean center (base R):*
  ```r
  mc_lon <- mean(stations_sf$lon)    # or use st_coordinates()
  mc_lat <- mean(stations_sf$lat)
  ```

  *Weighted mean center:*
  ```r
  coords <- st_coordinates(stations_sf)
  w <- stations_sf$mean_do_mgl
  wmc_lon <- sum(w * coords[, 1]) / sum(w)
  wmc_lat <- sum(w * coords[, 2]) / sum(w)
  ```

  *Standard distance:*
  ```r
  dists <- sqrt((coords[, 1] - mc_lon)^2 + (coords[, 2] - mc_lat)^2)
  std_dist <- sqrt(mean(dists^2))
  ```

  *Plotting centers as sf points:*
  ```r
  mc_pt  <- st_sfc(st_point(c(mc_lon, mc_lat)), crs = 4326)
  wmc_pt <- st_sfc(st_point(c(wmc_lon, wmc_lat)), crs = 4326)
  ```
]

#python-hint-box[
  *Mean center:*
  ```python
  coords = np.column_stack([gdf.geometry.x, gdf.geometry.y])
  mc = coords.mean(axis=0)
  ```

  *Weighted mean center:*
  ```python
  w = gdf['mean_do_mgl'].values
  wmc = np.average(coords, axis=0, weights=w)
  ```

  *Standard distance:*
  ```python
  dists = np.sqrt(((coords - mc) ** 2).sum(axis=1))
  std_dist = np.sqrt(np.mean(dists ** 2))
  ```

  *Circle for standard distance:*
  ```python
  from matplotlib.patches import Circle
  circle = Circle(mc, std_dist, fill=False, edgecolor='gray', linestyle='--')
  ax.add_patch(circle)
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 2
// =============================================================================

#exercise-header(number: 2, title: "Nearest Neighbor Analysis", difficulty: "Intermediate")

#context-box[
  A monitoring network can be *clustered* (stations bunched together, leaving gaps), *dispersed* (stations spread evenly), or *random*. The *Nearest Neighbor Index (NNI)* quantifies this by comparing observed nearest-neighbor distances against the expected distances under Complete Spatial Randomness (CSR). Use the NNI to determine whether the Chesapeake Bay monitoring network is optimally spread out or whether there are gaps and redundancies.
]

*Your Primary Tasks*

- Load `stations.csv` and convert to a spatial object. *Reproject to UTM Zone 18N (EPSG:32618)* so that all distances are in meters.
- Compute the *pairwise distance matrix* between all 20 stations (a 20#sym.times 20 matrix).
- For each station, find the distance to its *nearest neighbor* (the minimum distance in its row, excluding distance to itself).
- Compute the *mean nearest-neighbor distance* ($overline(d)_"obs"$).
- Compute the *expected nearest-neighbor distance* under CSR:

  $ overline(d)_"exp" = 1 / (2 sqrt(n "/" A)) $

  Use the *convex hull* of the station locations as the study area $A$.
- Compute the *Nearest Neighbor Index*: $"NNI" = overline(d)_"obs" "/" overline(d)_"exp"$
- Compute the *z-score* to test significance:

  $ z = (overline(d)_"obs" - overline(d)_"exp") / (0.26136 "/" sqrt(n^2 "/" A)) $

- Create a map showing stations with lines connecting each station to its nearest neighbor. Color the lines by distance.
- Report: Is the monitoring network clustered (NNI < 1), random (NNI $approx$ 1), or dispersed (NNI > 1)? Is the result statistically significant?
- Identify the most *isolated* station (largest nearest-neighbor distance). Where is it, and does the gap suggest a need for additional monitoring?

#spatial-think-box[
  - Why must we reproject to a projected CRS (UTM) before computing distances? What units would we get if we computed distances in EPSG:4326?
  - The convex hull is a simple approximation of the study area. How might using the actual Chesapeake Bay watershed boundary change the results?
  - An NNI > 1 means stations are more evenly spread than random. Is this desirable for a monitoring network? Why?
  - What assumptions does the NNI make about the study area boundary? How could edge effects bias the result?
]

#hint-box[
  *Pairwise distance matrix (R):*
  ```r
  dmat <- st_distance(stations_utm)  # returns a units matrix (m)
  dmat <- as.matrix(dmat)
  diag(dmat) <- NA
  nn_dists <- apply(dmat, 1, min, na.rm = TRUE)
  ```

  *Convex hull area:*
  ```r
  hull <- st_convex_hull(st_union(stations_utm))
  A <- as.numeric(st_area(hull))   # m^2
  ```

  *NNI and z-score:*
  ```r
  d_obs <- mean(nn_dists)
  n <- nrow(stations_utm)
  d_exp <- 1 / (2 * sqrt(n / A))
  NNI <- d_obs / d_exp
  se <- 0.26136 / sqrt(n^2 / A)
  z <- (d_obs - d_exp) / se
  p <- 2 * (1 - pnorm(abs(z)))
  ```
]

#python-hint-box[
  *Pairwise distances (projected coordinates):*
  ```python
  from scipy.spatial.distance import cdist
  coords = np.column_stack([gdf_utm.geometry.x, gdf_utm.geometry.y])
  dmat = cdist(coords, coords)
  np.fill_diagonal(dmat, np.inf)
  nn_dists = dmat.min(axis=1)
  ```

  *Convex hull area:*
  ```python
  hull = gdf_utm.unary_union.convex_hull
  A = hull.area   # m^2
  ```

  *Or use pointpats for a one-liner:*
  ```python
  from pointpats import PointPattern
  pp = PointPattern(coords)
  pp.mean_nnd  # mean nearest neighbor distance
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 3
// =============================================================================

#exercise-header(number: 3, title: "Kernel Density Estimation", difficulty: "Intermediate")

#context-box[
  In summer 2025, citizen scientists and automated sensors reported 150 algal bloom sightings across the Chesapeake Bay region. The file `algal_blooms.csv` contains the location (`lon`, `lat`), `severity` (1--10 scale), and `month` (Jun--Sep) of each sighting.

  Raw point maps are hard to interpret when points overlap. *Kernel Density Estimation (KDE)* converts discrete points into a continuous density surface, revealing hotspots and gradients that would otherwise be hidden. Use KDE to identify where algal bloom activity is most concentrated and explore how sensitive the result is to bandwidth choice.
]

*Your Primary Tasks*

- Load `algal_blooms.csv` and convert to a spatial object (EPSG:4326), then reproject to UTM 18N (EPSG:32618) for analysis in meters.
- Create a simple point map of all 150 bloom locations, colored by severity.
- Compute a KDE surface using a *bandwidth of 5,000 m (5 km)*. Evaluate the density on a regular grid covering the bounding box of the bloom locations.
- Compute a second KDE surface using a *bandwidth of 20,000 m (20 km)*.
- Create a 3-panel figure:
  + Panel 1: raw point map
  + Panel 2: KDE with bandwidth = 5 km
  + Panel 3: KDE with bandwidth = 20 km
- How many distinct hotspots do you see with the 5 km bandwidth? How many with 20 km?
- Which bandwidth would you recommend to the Chesapeake Bay Program for targeting bloom response resources? Justify your choice.
- *Bonus*: Compute a KDE using only the July--August blooms. Does the spatial pattern differ from the full-season map?

#spatial-think-box[
  - KDE spreads each point into a smooth "bump." What does the height of the surface represent? (Hint: it is not a count---it is an *intensity* or *density*, i.e., events per unit area.)
  - A very small bandwidth captures every local fluctuation. A very large bandwidth blurs everything into a single mound. What real-world knowledge could guide bandwidth selection for algal blooms?
  - KDE does not stop at the study area boundary. Density can "leak" into the ocean or over land. How could you address this problem?
  - If you doubled the number of bloom observations but they were in the same locations, what would happen to the KDE surface? Would the hotspot locations change?
]

#hint-box[
  *KDE in R with spatstat:*
  ```r
  library(spatstat)
  # Define observation window from bounding box
  bb <- st_bbox(blooms_utm)
  win <- owin(xrange = c(bb["xmin"], bb["xmax"]),
              yrange = c(bb["ymin"], bb["ymax"]))

  # Create point pattern object
  coords <- st_coordinates(blooms_utm)
  pp <- ppp(coords[, 1], coords[, 2], window = win)

  # KDE with bandwidth in meters
  kde_5k  <- density(pp, sigma = 5000)
  kde_20k <- density(pp, sigma = 20000)
  plot(kde_5k, main = "KDE: bandwidth = 5 km")
  ```

  *Plotting KDE as filled contours:*
  ```r
  plot(kde_5k, main = "Bloom Density (5 km bandwidth)")
  contour(kde_5k, add = TRUE, nlevels = 5)
  ```
]

#python-hint-box[
  *KDE with scipy:*
  ```python
  from scipy.stats import gaussian_kde
  coords = np.column_stack([gdf_utm.geometry.x, gdf_utm.geometry.y])

  # Create evaluation grid
  xmin, ymin, xmax, ymax = gdf_utm.total_bounds
  xx, yy = np.mgrid[xmin:xmax:200j, ymin:ymax:200j]
  positions = np.vstack([xx.ravel(), yy.ravel()])

  # KDE (bw_method in data units)
  kde = gaussian_kde(coords.T, bw_method=5000 / coords.std())
  density = kde(positions).reshape(xx.shape)
  ```

  *Or with scikit-learn (more control over bandwidth):*
  ```python
  from sklearn.neighbors import KernelDensity
  kde = KernelDensity(bandwidth=5000, kernel='gaussian')
  kde.fit(coords)
  log_dens = kde.score_samples(positions.T)
  density = np.exp(log_dens).reshape(xx.shape)
  ```

  *Plotting:*
  ```python
  plt.contourf(xx, yy, density, levels=20, cmap='YlOrRd')
  plt.colorbar(label='Density')
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 4
// =============================================================================

#exercise-header(number: 4, title: "Global Moran's I: Spatial Autocorrelation", difficulty: "Intermediate")

#context-box[
  Spatial autocorrelation is the tendency of nearby locations to have similar values. *Moran's I* is the standard global test: it produces a single number between --1 and +1 summarizing whether the spatial pattern is clustered (+1), random (0), or dispersed (--1).

  The file `watershed_quality.csv` contains estimated total nitrogen loading (`nitrogen_kg_ha`, in kg/ha/yr) for all 54 HUC8 sub-watersheds in the Chesapeake Bay drainage. Use Moran's I to test whether nitrogen loading is spatially clustered---that is, whether high-nitrogen watersheds tend to neighbor other high-nitrogen watersheds.
]

*Your Primary Tasks*

- Load `chesapeake_watersheds.gpkg` and `watershed_quality.csv`. Join them on the `HUC8` column so that each polygon has a `nitrogen_kg_ha` attribute.
- Create a choropleth map of nitrogen loading across the 54 watersheds.
- Build a *Queen contiguity spatial weights matrix* (two watersheds are neighbors if they share any boundary point, including corners).
- Row-standardize the weights matrix (each row sums to 1).
- Compute *Global Moran's I*:

  $ I = n / (sum_(i) sum_(j) w_(i j)) dot (sum_(i) sum_(j) w_(i j) (x_i - overline(x))(x_j - overline(x))) / (sum_(i) (x_i - overline(x))^2) $

- Perform a *permutation test* (999 permutations) to assess significance. Report the I statistic, the pseudo p-value, and the z-score.
- Create a *Moran scatter plot*: x-axis = standardized nitrogen value at each watershed, y-axis = spatial lag (weighted average of neighbors). Draw the regression line whose slope is Moran's I.
- Interpret: Is nitrogen loading spatially autocorrelated? What does this mean for management---can the Bay Program target contiguous regions, or must each watershed be addressed independently?

#spatial-think-box[
  - Why must we define a spatial weights matrix before computing Moran's I? What happens if we use k-nearest-neighbor weights instead of Queen contiguity?
  - Row-standardizing means each neighbor contributes equally to the spatial lag. What is the alternative (binary weights)? When might each be preferred?
  - The Moran scatter plot divides the plane into four quadrants: HH, HL, LH, LL. What does a point in the HL quadrant represent environmentally?
  - Could a Moran's I close to zero occur even if there are strong *local* clusters? When would you need Local Moran's I (Exercise 5)?
]

#hint-box[
  *Spatial weights (R with spdep):*
  ```r
  library(spdep)
  # Queen contiguity
  nb <- poly2nb(ws_sf, queen = TRUE)
  lw <- nb2listw(nb, style = "W")  # row-standardized
  ```

  *Global Moran's I:*
  ```r
  moran_result <- moran.test(ws_sf$nitrogen_kg_ha, lw)
  print(moran_result)  # I, expected I, variance, p-value
  ```

  *Moran scatter plot:*
  ```r
  moran.plot(ws_sf$nitrogen_kg_ha, lw,
             xlab = "Nitrogen (standardized)",
             ylab = "Spatial Lag",
             main = "Moran Scatter Plot — Nitrogen Loading")
  ```
]

#python-hint-box[
  *Spatial weights (Python with libpysal):*
  ```python
  import libpysal
  import esda

  w = libpysal.weights.Queen.from_dataframe(ws_gdf)
  w.transform = 'r'  # row-standardize
  ```

  *Global Moran's I:*
  ```python
  mi = esda.Moran(ws_gdf['nitrogen_kg_ha'], w, permutations=999)
  print(f"Moran's I = {mi.I:.4f}")
  print(f"p-value   = {mi.p_sim:.4f}")
  print(f"z-score   = {mi.z_sim:.4f}")
  ```

  *Moran scatter plot:*
  ```python
  from splot.esda import moran_scatterplot
  fig, ax = moran_scatterplot(mi, aspect_equal=False)
  ax.set_title("Moran Scatter Plot — Nitrogen Loading")
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 5
// =============================================================================

#exercise-header(number: 5, title: "Local Moran's I (LISA): Cluster and Outlier Detection", difficulty: "Advanced")

#context-box[
  Global Moran's I tells us whether the map as a whole exhibits spatial autocorrelation, but it cannot tell us *where* the clusters are. *Local Indicators of Spatial Association (LISA)* decompose the global statistic into a contribution from each location, revealing hot spots (HH), cold spots (LL), and spatial outliers (HL, LH).

  Continuing from Exercise 4, use LISA to identify which specific watersheds form nitrogen hot spots (high N surrounded by high N) and which are cold spots or outliers.
]

*Your Primary Tasks*

- Use the same joined watershed--nitrogen dataset and Queen contiguity weights from Exercise 4.
- Compute *Local Moran's I* ($I_i$) for each of the 54 watersheds:

  $ I_i = (x_i - overline(x)) / s^2 sum_(j) w_(i j) (x_j - overline(x)) $

- For each watershed, determine the quadrant assignment:
  - *HH (Hot Spot)*: high value, neighbors are high
  - *LL (Cold Spot)*: low value, neighbors are low
  - *HL (High Outlier)*: high value, neighbors are low
  - *LH (Low Outlier)*: low value, neighbors are high
  - *Not Significant*: p-value above 0.05 threshold

- Perform a permutation test (999 permutations) for each watershed to identify statistically significant clusters at the $alpha = 0.05$ level.
- Create a *LISA cluster map*: color each watershed by its cluster type (HH = red, LL = blue, HL = orange, LH = light blue, Not Significant = light gray).
- Create a two-panel figure: (a) choropleth of nitrogen loading, (b) LISA cluster map side by side.
- Interpret: Name the watersheds that are nitrogen hot spots. Where are the cold spots? Are there any spatial outliers? What environmental processes might explain these patterns?

#spatial-think-box[
  - How does the LISA cluster map relate to the Moran scatter plot from Exercise 4? Each quadrant of the scatter plot corresponds to a cluster type on the map.
  - Why is a significance test essential for LISA? Without it, every watershed would be classified into a quadrant---even if the local pattern is consistent with random chance.
  - If a watershed shows up as an HL outlier (high nitrogen surrounded by low-nitrogen neighbors), what might explain this? Think about point-source versus diffuse pollution.
  - The choice of significance level ($alpha = 0.05$) and the number of permutations (999) both affect which watersheds are flagged as significant. What happens if you increase the number of permutations to 9999?
  - LISA results can be sensitive to the weights matrix. How might switching from Queen to Rook contiguity change the cluster map?
]

#hint-box[
  *Local Moran's I (R with spdep):*
  ```r
  lisa <- localmoran(ws_sf$nitrogen_kg_ha, lw)
  # lisa returns: Ii, E.Ii, Var.Ii, z.Ii, Pr(z != E(Ii))

  ws_sf$Ii <- lisa[, 1]          # Local Moran's I value
  ws_sf$p_value <- lisa[, 5]     # p-value

  # Classify into quadrants
  z <- scale(ws_sf$nitrogen_kg_ha)[, 1]          # standardized values
  lag_z <- lag.listw(lw, z)                       # spatial lag (standardized)
  ws_sf$cluster <- "Not Significant"
  sig <- ws_sf$p_value < 0.05
  ws_sf$cluster[sig & z > 0 & lag_z > 0] <- "HH"
  ws_sf$cluster[sig & z < 0 & lag_z < 0] <- "LL"
  ws_sf$cluster[sig & z > 0 & lag_z < 0] <- "HL"
  ws_sf$cluster[sig & z < 0 & lag_z > 0] <- "LH"
  ```

  *LISA cluster map:*
  ```r
  tm_shape(ws_sf) +
    tm_polygons(col = "cluster",
      palette = c("HH"="red", "LL"="blue", "HL"="orange",
                  "LH"="lightblue", "Not Significant"="gray90"))
  ```
]

#python-hint-box[
  *Local Moran's I (Python with esda):*
  ```python
  lisa = esda.Moran_Local(ws_gdf['nitrogen_kg_ha'], w, permutations=999)

  ws_gdf['Ii'] = lisa.Is             # Local I values
  ws_gdf['p_value'] = lisa.p_sim     # pseudo p-values
  ws_gdf['quadrant'] = lisa.q        # 1=HH, 2=LH, 3=LL, 4=HL
  ```

  *LISA cluster map with splot:*
  ```python
  from splot.esda import lisa_cluster
  fig, ax = plt.subplots(1, 1, figsize=(8, 8))
  lisa_cluster(lisa, ws_gdf, p=0.05, ax=ax)
  ax.set_title("LISA Cluster Map — Nitrogen Loading")
  ```

  *Manual classification:*
  ```python
  sig = lisa.p_sim < 0.05
  labels = np.array(["Not Significant"] * len(ws_gdf))
  quad_map = {1: "HH", 2: "LH", 3: "LL", 4: "HL"}
  for i, q in enumerate(lisa.q):
      if sig[i]:
          labels[i] = quad_map[q]
  ws_gdf['cluster'] = labels
  ```
]

#pagebreak()

// =============================================================================
// SUMMARY
// =============================================================================

#text(weight: "semibold", size: 12pt, fill: primary-color)[Summary of Techniques]

#v(0.3em)

#table(
  columns: (auto, 1.5fr, 2fr),
  stroke: 0.5pt + luma(200),
  fill: (col, row) => if row == 0 { primary-color.lighten(85%) } else { white },
  inset: (x: 0.7em, y: 0.5em),
  [*Exercise*], [*Technique*], [*Environmental Question*],
  [1], [Mean Center, Weighted Mean Center, Std. Distance], [Where is the center of the monitoring network, and how does weighting by DO shift it?],
  [2], [Nearest Neighbor Index (NNI)], [Is the monitoring network clustered, random, or evenly dispersed?],
  [3], [Kernel Density Estimation (KDE)], [Where is algal bloom activity most concentrated?],
  [4], [Global Moran's I], [Is nitrogen loading spatially autocorrelated across watersheds?],
  [5], [Local Moran's I (LISA)], [Which specific watersheds are nitrogen hot spots or cold spots?],
)

