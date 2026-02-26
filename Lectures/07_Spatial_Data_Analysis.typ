#import "@preview/polylux:0.4.0": *
#import "@preview/fletcher:0.5.8": diagram, node, edge


// --- CONFIGURATION & COLORS ---
#let primary-color = rgb("#2d5a27") // Sage Green
#let accent-color = rgb("#457b9d")  // Muted Steel Blue
#let bg-color = rgb("#fdfdfc")      // Soft Cream (easy on the eyes)
#let text-color = rgb("#2f2f2f")    // Soft Charcoal
#let warning-color = rgb("#c44536") // Warning Red
#let discuss-color = rgb("#6a4c93") // Discussion Purple

#let setup-theme(title: "", author: "", date: none, body) = {
  set page(
    paper: "presentation-16-9",
    fill: bg-color,
    margin: 2em,
  )
  set text(size: 14pt, fill: text-color)

  // Title Slide
  slide({
    set align(center + horizon)
    block(
      stroke: (bottom: 2pt + primary-color),
      inset: 1em,
      text(2em, weight: "bold", fill: primary-color, title)
    )
    v(1em)
    text(1.2em, author)
    v(0.5em)
    text(0.8em, fill: text-color.lighten(30%), date)
  })

  body
}

// --- CUSTOM COMPONENTS ---

#let lecture-slide(title: none, body) = {
  slide({
    if title != none {
      set align(top)
      grid(
        columns: (1fr, auto),
        align(left + bottom, text(1.3em, weight: "semibold", fill: primary-color, title)),
        align(right + bottom, text(0.6em, fill: text-color.lighten(50%), [ENST431: Environmental Data Science]))
      )
      line(length: 100%, stroke: 0.5pt + primary-color.lighten(50%))
      v(0.5em)
    }
    body

    place(bottom + center, context {
      let total = counter(page).final().last()
      text(0.6em, fill: text-color.lighten(50%))[
        Page #counter(page).display() of #total
      ]
    })
  })
}

// Callout box --- use sparingly
#let focus-block(title: "Note", color: accent-color, body) = {
  rect(
    fill: color.lighten(90%),
    stroke: (left: 4pt + color),
    width: 100%,
    inset: 1em,
    radius: 4pt,
    [
      #text(weight: "bold", fill: color, title) \
      #set text(size: 0.9em)
      #body
    ]
  )
}

// Discussion prompt --- use for interactive moments
#let discuss-block(title: "Class Discussion", body) = {
  rect(
    fill: discuss-color.lighten(92%),
    stroke: (left: 4pt + discuss-color),
    width: 100%,
    inset: 1em,
    radius: 4pt,
    [
      #text(weight: "bold", fill: discuss-color, title) \
      #set text(size: 0.9em)
      #body
    ]
  )
}

// Figure placeholder --- gray box with caption for future images
#let figure-placeholder(caption: "Figure", width: 100%, height: 12em) = {
  rect(
    fill: luma(230),
    stroke: 1pt + luma(180),
    width: width,
    height: height,
    radius: 4pt,
    inset: 0.8em,
    align(center + horizon,
      text(0.85em, fill: luma(100), style: "italic", caption)
    )
  )
}


// --- DOCUMENT START ---

#show: body => setup-theme(
  title: "Spatial Data Analysis",
  author: "Instructor: Akash Koppa",
  date: "Lecture 7 of Spring Semester 2026",
  body
)


// =============================================================================
// PART 1: FROM SPATIAL DATA TO SPATIAL ANALYSIS
// =============================================================================

#lecture-slide(title: "Recap: Where We Are")[
  In Lectures 5 and 6, we learned to *store*, *manipulate*, and *map* spatial data. Now we ask a different question:

  #v(0.5em)

  #align(center)[
    #text(1.3em, weight: "bold", fill: primary-color)[What spatial _patterns_ exist in the data, and can we _predict_ values at unmeasured locations?]
  ]

  #v(0.5em)

  #align(center)[#image("Data/07_Spatial_Analysis/07_analysis_pipeline.png", height: 14em)]

  #v(0.3em)

  Today we move from *spatial data management* to *spatial data analysis*---the techniques that extract knowledge from geography.
]


#lecture-slide(title: "Tobler's First Law of Geography")[
  #grid(
    columns: (2fr, 3fr),
    gutter: 1.5em,
    [
      #v(1em)

      #focus-block(title: "The Foundation", color: primary-color)[
        "Everything is related to everything else, but *near things are more related* than distant things."

        --- Waldo Tobler, 1970
      ]

      #v(0.5em)

      This single idea underpins nearly every spatial analysis method we will cover today:

      - *Spatial autocorrelation*: nearby values are correlated
      - *Interpolation*: estimate unknowns from nearby knowns
      - *Geostatistics*: model the decay of correlation with distance

      #v(0.3em)

      _If this law didn't hold, spatial analysis would be pointless._
    ],
    image("Data/07_Spatial_Analysis/07_tobler_law.png", width: 100%),
  )
]


// =============================================================================
// PART 2: SPATIAL DESCRIPTIVE STATISTICS
// =============================================================================

#lecture-slide(title: "Spatial Descriptive Statistics")[
  Just as we compute the *mean* and *standard deviation* for a column of numbers, we can compute spatial summary statistics for a set of point locations.

  #v(0.3em)

  #align(center)[#image("Data/07_Spatial_Analysis/07_descriptive_stats.png", height: 14em)]

  #v(0.2em)

  #set text(size: 0.85em)
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    [
      *Mean Center:* $overline(x) = 1/n sum x_i$ , $overline(y) = 1/n sum y_i$

      The geographic "center of gravity."
    ],
    [
      *Standard Distance:* $"SD" = sqrt(1/n sum d_i^2)$

      How spread out are points around the mean center?
    ],
    [
      *Std. Deviational Ellipse:* uses the *covariance matrix* of coordinates to show directional trends. Elongated = directional bias.
    ],
  )
]


#lecture-slide(title: "Example: Where Is the Center of Pollution?")[
  #discuss-block(title: "Interactive Exercise")[
    Twelve monitoring stations in the Chesapeake Bay measure nutrient concentrations. Consider these questions:
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #set text(size: 0.85em, font: "DejaVu Sans Mono")
      #table(
        columns: (auto, auto, auto, auto),
        inset: 0.4em,
        stroke: 0.5pt + luma(200),
        fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
        [*Station*], [*Lon*], [*Lat*], [*N (mg/L)*],
        [CB3.3], [-76.38], [38.55], [1.8],
        [CB4.1], [-76.32], [38.08], [3.2],
        [CB5.2], [-76.17], [37.41], [4.5],
        [EE3.3], [-76.08], [38.63], [2.1],
        [ET5.2], [-76.15], [38.82], [1.4],
        [TF5.5], [-76.01], [37.18], [5.1],
      )

      _(showing 6 of 12 stations)_
    ],
    [
      + Compute the *mean center* of all stations. Does it fall in the Bay?

      + Now compute the *weighted mean center* using nitrogen concentration as the weight. How does it shift?

      + What does the shift tell you about where nutrient loading is concentrated?

      + If you drew the standard deviational ellipse, which direction would it stretch? Why?

      #v(0.3em)

      _Hint: The Bay runs NNW--SSE. Higher nutrients cluster in the southern tributaries._
    ],
  )
]


// =============================================================================
// PART 3: POINT PATTERN ANALYSIS
// =============================================================================

#lecture-slide(title: "Point Pattern Analysis: Is It Random?")[
  The first question in spatial analysis: *is the pattern random, clustered, or dispersed?*

  #v(0.3em)

  #align(center)[#image("Data/07_Spatial_Analysis/07_point_patterns.png", height: 16em)]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    [
      *Complete Spatial Randomness (CSR)*: each location is equally likely. The null hypothesis.
    ],
    [
      *Clustered*: points aggregate. Disease outbreaks, pollution sources, species habitats.
    ],
    [
      *Regular / Dispersed*: points repel each other. Territorial species, planted trees.
    ],
  )
]


#lecture-slide(title: "Nearest Neighbor Analysis")[
  #grid(
    columns: (2fr, 3fr),
    gutter: 1em,
    [
      The *Nearest Neighbor Index (NNI)* compares the average distance to the nearest neighbor against the expected distance under CSR:

      #v(0.3em)

      $ "NNI" = overline(d)_"observed" / overline(d)_"expected" $

      #v(0.3em)

      where:

      $ overline(d)_"expected" = 1 / (2 sqrt(n "/" A)) $

      #v(0.3em)

      - *NNI < 1*: clustered (neighbors closer than expected)
      - *NNI = 1*: random (CSR)
      - *NNI > 1*: dispersed (neighbors farther than expected)

      #v(0.3em)

      A z-test determines statistical significance.
    ],
    image("Data/07_Spatial_Analysis/07_nearest_neighbor.png", width: 100%),
  )
]


#lecture-slide(title: "Example: Are Hypoxia Events Clustered?")[
  #discuss-block(title: "Interactive Exercise")[
    The map below shows 30 locations where dissolved oxygen dropped below 2 mg/L (hypoxia) during summer 2023 in the Chesapeake Bay.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      Suppose the study area is 11,500 km² and the mean nearest-neighbor distance among the 30 hypoxia locations is 8.2 km.

      #v(0.3em)

      + Compute $overline(d)_"expected"$:
        $ 1 / (2 sqrt(30 "/" 11500)) = ? $

      + Compute the NNI. Is it above or below 1?

      + What does this tell you about the spatial pattern of hypoxia?

      + *Why* would hypoxia events cluster? Think about bathymetry, circulation, and nutrient input.
    ],
    [
      #focus-block(title: "Answer Key", color: accent-color)[
        $ overline(d)_"expected" = 1 / (2 sqrt(0.0026)) approx 9.8 "km" $

        $ "NNI" = 8.2 / 9.8 approx 0.84 $

        NNI < 1 #sym.arrow *clustered*.

        Hypoxia clusters in the deep central channel where stratification traps low-oxygen bottom water.
      ]
    ],
  )
]


// =============================================================================
// PART 4: KERNEL DENSITY ESTIMATION (KDE)
// =============================================================================

#lecture-slide(title: "Kernel Density Estimation: From Points to Surfaces")[
  Points are hard to interpret visually when they overlap. *KDE* converts discrete points into a continuous density surface.

  #v(0.3em)

  #align(center)[#image("Data/07_Spatial_Analysis/07_kde.png", height: 16em)]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *How it works:*
      + Place a smooth "kernel" (bump) over each point
      + Sum all kernels across a regular grid
      + Result: estimated intensity (events per unit area)
    ],
    [
      *The bandwidth (h) controls smoothness:*
      - *Small h*: captures local detail, noisy
      - *Large h*: smooth, may blur real clusters
      - Choose h using cross-validation or domain knowledge
    ],
  )
]


#lecture-slide(title: "Example: Mapping Wildlife Sighting Density")[
  #discuss-block(title: "Interactive Exercise")[
    A field team recorded 200 GPS sightings of a threatened bird species across a 50 km² nature reserve. The reserve manager wants a *density map* to prioritize habitat protection. You are the data scientist.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      + Why is a KDE map more useful than plotting raw points for a reserve manager?

      + The reserve spans a range of elevations: 50 m to 800 m. You suspect the species prefers mid-elevation zones. How could KDE reveal this?

      + Your first KDE uses a 500 m bandwidth and shows two distinct hotspots. A 2 km bandwidth shows a single blob. Which do you present to the manager, and why?

      + What happens to KDE at the reserve *boundary*? Can the density "leak" outside the reserve?
    ],
    [
      #focus-block(title: "Key Insight", color: primary-color)[
        KDE does not explain *why* density is high---it only shows *where*. To understand the drivers, overlay the density map with environmental layers (elevation, vegetation, water sources).
      ]

      #v(0.3em)

      #focus-block(title: "Software", color: accent-color)[
        *R:* `spatstat::density.ppp()` \
        *Python:* `sklearn.neighbors.KernelDensity` or `scipy.stats.gaussian_kde`
      ]
    ],
  )
]


// =============================================================================
// PART 5: SPATIAL AUTOCORRELATION
// =============================================================================

#lecture-slide(title: "Spatial Autocorrelation: Quantifying Spatial Patterns")[
  *Spatial autocorrelation* measures the degree to which nearby locations have similar values. It formalizes Tobler's Law into a testable statistic.

  #v(0.3em)

  #align(center)[#image("Data/07_Spatial_Analysis/07_spatial_autocorrelation.png", height: 16em)]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    [
      *Positive*: similar values cluster (temperature, income, vegetation).
    ],
    [
      *Zero*: values are spatially random (no pattern).
    ],
    [
      *Negative*: dissimilar values are neighbors (rare; checkerboard).
    ],
  )
]


#lecture-slide(title: "Global Moran's I")[
  The most common test for spatial autocorrelation. Moran's I is essentially a *spatial correlation coefficient*.

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      $ I = n / (sum_(i) sum_(j) w_(i j)) dot (sum_(i) sum_(j) w_(i j) (x_i - overline(x))(x_j - overline(x))) / (sum_(i) (x_i - overline(x))^2) $

      #v(0.3em)

      where:
      - $n$ = number of spatial units
      - $x_i$ = value at location $i$
      - $w_(i j)$ = spatial weight (1 if neighbors, 0 otherwise)

      #v(0.3em)

      *Interpretation:*
      - $I approx +1$: strong positive autocorrelation
      - $I approx 0$: no spatial pattern
      - $I approx -1$: strong negative autocorrelation
    ],
    [
      #focus-block(title: "Spatial Weights Matrix (W)", color: accent-color)[
        *W* defines what "neighbor" means:
        - *Contiguity*: share a border (Queen = edges + corners; Rook = edges only)
        - *Distance*: within a threshold distance
        - *k-Nearest*: the k closest features

        The choice of W affects the result. Always justify your choice.
      ]

      #v(0.3em)

      #focus-block(title: "Hypothesis Test", color: primary-color)[
        $H_0$: values are randomly distributed in space \
        $H_a$: values exhibit spatial clustering \
        Use a *z-test* or *permutation test* (shuffle values across locations 999+ times)
      ]
    ],
  )
]


#lecture-slide(title: "Moran's I Scatter Plot")[
  #grid(
    columns: (2.5fr, 2fr),
    gutter: 1em,
    image("Data/07_Spatial_Analysis/07_moran_scatter.png", height: 23em),
    [
      The scatter plot shows each location's value (x-axis) against the *spatial lag*---the weighted average of its neighbors (y-axis).

      #v(0.3em)

      *Four quadrants:*

      - *HH (upper right)*: high value surrounded by high values #sym.arrow *hot spot*
      - *LL (lower left)*: low value surrounded by low values #sym.arrow *cold spot*
      - *HL / LH*: spatial outliers (unlike their neighbors)

      #v(0.3em)

      The slope of the regression line *is* Moran's I.

      #v(0.3em)

      _Most points in HH and LL = positive autocorrelation. Scattered across all four = no spatial pattern._
    ],
  )
]


#lecture-slide(title: "Local Moran's I (LISA)")[
  Global Moran's I gives *one number* for the entire study area. But spatial patterns are often *local*. LISA decomposes the global statistic into contributions from each location.

  #v(0.3em)

  #grid(
    columns: (2fr, 3fr),
    gutter: 1em,
    [
      $ I_i = (x_i - overline(x)) / (s^2) sum_(j) w_(i j)(x_j - overline(x)) $

      #v(0.3em)

      Each location gets its own $I_i$ value and a significance test. This produces a *LISA cluster map* showing:

      - #text(fill: warning-color)[*HH*]: hot spots (high-high)
      - #text(fill: accent-color)[*LL*]: cold spots (low-low)
      - #text(fill: rgb("#fdbf6f"))[*HL*]: high outlier
      - #text(fill: rgb("#a6cee3"))[*LH*]: low outlier
      - Not significant (no local pattern)
    ],
    image("Data/07_Spatial_Analysis/07_lisa_clusters.png", height: 20em),
  )
]


#lecture-slide(title: "Example: Is Water Quality Spatially Clustered?")[
  #discuss-block(title: "Interactive Exercise")[
    You have dissolved oxygen data for 54 Chesapeake Bay sub-watersheds and want to test whether DO is spatially autocorrelated.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      + You compute Moran's I = 0.62 (p < 0.001). What does this mean in plain language?

      + On the Moran scatter plot, most points fall in the *LL* quadrant (lower left). What does this tell you about the Bay?

      + The LISA map shows a cluster of *LL* (cold spots) in the mid-Bay region. What environmental process explains this?

      + A single watershed in the upper Bay appears as an *LH* outlier (low DO surrounded by high-DO neighbors). What could cause this?
    ],
    [
      #focus-block(title: "Interpreting the Results", color: primary-color)[
        Moran's I = 0.62 means *strong positive spatial autocorrelation*: watersheds near each other have similar DO levels.

        The LL cluster in the mid-Bay marks the *hypoxic zone*, where nutrient-driven oxygen depletion affects a contiguous region.

        The LH outlier could be a heavily urbanized watershed with local nutrient inputs that degrade DO despite its location among healthy watersheds.
      ]

      #v(0.3em)

      *R:* `spdep::moran.test()`, `spdep::localmoran()` \
      *Python:* `esda.Moran()`, `esda.Moran_Local()`
    ],
  )
]


// =============================================================================
// PART 6: SPATIAL INTERPOLATION --- IDW
// =============================================================================

#lecture-slide(title: "Spatial Interpolation: Predicting the Unknown")[
  We have measurements at *some* locations but need values *everywhere*. Spatial interpolation fills the gaps using spatial structure.

  #v(0.3em)

  #align(center)[#image("Data/07_Spatial_Analysis/07_chesapeake_interp.png", height: 18em)]

  #v(0.3em)

  #align(center)[_Left: sparse monitoring stations. Right: interpolated DO surface reveals the hypoxic zone._]
]


#lecture-slide(title: "Inverse Distance Weighting (IDW)")[
  The simplest interpolation method. Predicted value at an unsampled location is a *weighted average* of nearby observations, with weights inversely proportional to distance.

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      $ hat(z)(s_0) = (sum_(i=1)^n w_i dot z(s_i)) / (sum_(i=1)^n w_i) $

      where:

      $ w_i = 1 / d(s_0, s_i)^p $

      #v(0.3em)

      - $hat(z)(s_0)$ = predicted value at location $s_0$
      - $z(s_i)$ = observed value at station $s_i$
      - $d$ = distance between locations
      - $p$ = power parameter (controls locality)
    ],
    [
      #focus-block(title: "The Power Parameter (p)", color: accent-color)[
        - *p = 1*: gentle decay #sym.arrow smooth surface, distant stations have influence
        - *p = 2*: standard choice, moderate locality
        - *p = 5+*: sharp decay #sym.arrow very local, "bull's-eye" around each station
      ]

      #v(0.3em)

      *Strengths:* Simple, fast, exact interpolator (passes through data points)

      *Weaknesses:* No uncertainty estimate, creates artifacts around stations, does not account for spatial structure
    ],
  )
]


#lecture-slide(title: "IDW: Effect of the Power Parameter")[
  #align(center)[#image("Data/07_Spatial_Analysis/07_idw.png", height: 18em)]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    [
      #text(size: 0.85em)[*p = 1*: Very smooth. Distant stations still influence the prediction. Good for broad trends.]
    ],
    [
      #text(size: 0.85em)[*p = 2*: Balanced. The most common default. Moderate spatial locality.]
    ],
    [
      #text(size: 0.85em)[*p = 5*: Sharp "bull's-eye" effect. Each station dominates its immediate neighborhood.]
    ],
  )
]


#lecture-slide(title: "Example: Interpolating Temperature from Weather Stations")[
  #discuss-block(title: "Interactive Exercise")[
    Five weather stations record daily mean temperature. You need a continuous temperature map for the region.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #set text(size: 0.85em, font: "DejaVu Sans Mono")
      #table(
        columns: (auto, auto, auto, auto),
        inset: 0.4em,
        stroke: 0.5pt + luma(200),
        fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
        [*Station*], [*X (km)*], [*Y (km)*], [*Temp (°C)*],
        [A], [2], [8], [22.1],
        [B], [5], [5], [18.5],
        [C], [8], [7], [20.3],
        [D], [3], [2], [24.8],
        [E], [7], [2], [23.0],
      )

      #v(0.3em)

      Predict the temperature at location *P = (5, 3)* using IDW with *p = 2*.
    ],
    [
      + Compute the distance from P to each station
      + Compute the weight $w_i = 1"/"d_i^2$ for each
      + Compute $hat(z)(P) = (sum w_i z_i) "/" (sum w_i)$

      #v(0.3em)

      #focus-block(title: "Worked Solution", color: accent-color)[
        Station D is closest (d = 2.24 km) #sym.arrow highest weight. \
        Station A is farthest (d = 5.83 km) #sym.arrow lowest weight. \
        The prediction will be pulled toward Station D's value (24.8°C).

        $hat(z)(P) approx 22.4 degree$C
      ]

      #v(0.3em)

      _What if Station D's thermometer was broken and read 40°C? IDW has no way to know---it trusts all data equally._
    ],
  )
]


// =============================================================================
// PART 7: GEOSTATISTICS --- VARIOGRAMS AND KRIGING
// =============================================================================

#lecture-slide(title: "Geostatistics: The Science of Spatial Prediction")[
  IDW is intuitive but has a critical limitation: *it provides no uncertainty estimate*. We don't know how reliable the prediction is.

  #v(0.3em)

  *Geostatistics* (Kriging) solves this by:

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1.2em,
    [
      #focus-block(title: "1. Model the Structure", color: primary-color)[
        Use a *variogram* to quantify how dissimilarity changes with distance.
      ]
    ],
    [
      #focus-block(title: "2. Optimal Prediction", color: accent-color)[
        Use the variogram to compute weights that minimize prediction error.
      ]
    ],
    [
      #focus-block(title: "3. Quantify Uncertainty", color: discuss-color)[
        Produce a *variance map* that shows where predictions are reliable and where they are not.
      ]
    ],
  )

  #v(0.5em)

  #align(center)[
    #text(1.1em, weight: "semibold", fill: primary-color)[Kriging is the _Best Linear Unbiased Predictor_ (BLUP) for spatial data.]
  ]
]


#lecture-slide(title: "The Variogram: Fingerprint of Spatial Structure")[
  #grid(
    columns: (2fr, 3fr),
    gutter: 1em,
    [
      The *empirical variogram* measures average squared difference between pairs of observations as a function of distance:

      #v(0.3em)

      $ hat(gamma)(h) = 1 / (2 N(h)) sum_(i=1)^(N(h)) [z(s_i) - z(s_i + h)]^2 $

      #v(0.3em)

      where:
      - $h$ = lag distance (separation)
      - $N(h)$ = number of pairs at distance $h$
      - $z(s_i)$ = observed value at location $s_i$

      #v(0.3em)

      A *model* is then fitted to the empirical variogram (spherical, exponential, Gaussian, etc.)
    ],
    image("Data/07_Spatial_Analysis/07_variogram.png", height: 22em),
  )
]


#lecture-slide(title: "Reading the Variogram")[
  The three parameters of the variogram tell a complete story about spatial structure:

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "Nugget (C₀)", color: warning-color)[
        Semivariance at distance 0. Represents *measurement error* and *micro-scale variability* below the sampling resolution.

        #v(0.3em)

        Large nugget = noisy data or important variation at scales smaller than station spacing.
      ]
    ],
    [
      #focus-block(title: "Range (a)", color: accent-color)[
        Distance at which semivariance levels off. Beyond this, observations are *spatially independent*.

        #v(0.3em)

        Tells you the *spatial reach* of correlation. Determines how far Kriging can "look" for information.
      ]
    ],
    [
      #focus-block(title: "Sill (C₀ + C₁)", color: primary-color)[
        The plateau: total variance of the data. At distances > range, $gamma(h) approx "Sill"$.

        #v(0.3em)

        The *partial sill* (C₁ = Sill − Nugget) is the spatially structured variance.
      ]
    ],
  )

  #v(0.5em)

  #align(center)[_A variogram with a high nugget relative to sill means most variation is random, not spatial. Kriging won't help much._]
]


#lecture-slide(title: "Example: Reading Real Variograms")[
  #discuss-block(title: "Interactive Exercise")[
    For each scenario below, sketch or describe what the variogram would look like. Think about the nugget, range, and sill.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *Scenario A: Soil pH across a farm field*

      Soil pH changes gradually across the field due to underlying geology. Samples 10 m apart are very similar; samples 500 m apart are very different.

      - Nugget: _small_ (precise lab measurements)
      - Range: _~500 m_ (spatial correlation extent)
      - Sill: _moderate_ (total pH variability)

      #v(0.3em)

      *Scenario B: Rainfall across a mountain range*

      Rain gauges on the same slope give similar readings, but gauges on opposite sides of a ridge differ dramatically. Gauge error is small.
    ],
    [
      *Scenario C: Air quality in a city (PM#sub[2.5])*

      Sensors near busy roads read very differently from those just 200 m away in parks. Measurements fluctuate minute-to-minute.

      - Nugget: _large_ (high micro-scale variability)
      - Range: _short_ (local pollution sources)
      - Sill: _high_ (huge variation across the city)

      #v(0.3em)

      *Scenario D: Sea surface temperature (SST)*

      SST varies smoothly over hundreds of kilometers. Satellite measurements have low noise.

      - Nugget: _very small_
      - Range: _very long_ (hundreds of km)
      - What does this tell you about how far Kriging can interpolate reliably?
    ],
  )
]


#lecture-slide(title: "Ordinary Kriging")[
  Kriging uses the variogram to compute *optimal weights* for spatial prediction.

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *The prediction:*

      $ hat(z)(s_0) = sum_(i=1)^n lambda_i dot z(s_i) $

      The weights $lambda_i$ are found by solving a system of equations that:

      + *Minimizes prediction variance* (best prediction)
      + *Ensures unbiasedness*: $sum lambda_i = 1$
      + Uses the *variogram model* to compute inter-point semivariances

      #v(0.3em)

      Unlike IDW, the weights depend on the *spatial configuration* of all stations---not just their distances to the prediction point.
    ],
    [
      *The uncertainty:*

      $ sigma^2_K (s_0) = sum_(i=1)^n lambda_i gamma(s_i, s_0) + mu $

      where $mu$ is a Lagrange multiplier.

      #v(0.3em)

      This *Kriging variance* is:
      - *Low* near observation points
      - *High* far from observation points
      - *High* when the nugget is large
      - Independent of the actual data values!

      #v(0.3em)

      _This is the key advantage over IDW: Kriging tells you *where it doesn't know*._
    ],
  )
]


#lecture-slide(title: "Kriging: Prediction and Uncertainty")[
  #align(center)[#image("Data/07_Spatial_Analysis/07_kriging.png", height: 18em)]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #text(size: 0.85em)[*Left:* Predicted surface. Smooth transitions between stations. The prediction is a weighted average informed by the variogram.]
    ],
    [
      #text(size: 0.85em)[*Right:* Kriging variance. Low (yellow) near stations, high (red) far away. This map tells managers exactly *where more data is needed*.]
    ],
  )
]


#lecture-slide(title: "IDW vs. Kriging: A Direct Comparison")[
  #align(center)[#image("Data/07_Spatial_Analysis/07_idw_vs_kriging.png", height: 13em)]

  #v(0.2em)

  #set text(size: 0.85em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "IDW", color: accent-color)[
        - Simple, fast, no model fitting
        - Weights based only on distance
        - No uncertainty estimate
        - Bull's-eye artifacts at high power
        - Use when: quick exploration, dense data
      ]
    ],
    [
      #focus-block(title: "Kriging", color: primary-color)[
        - Requires variogram modeling
        - Weights account for spatial structure and data configuration
        - Provides prediction variance
        - Statistically optimal (BLUP)
        - Use when: sparse data, need uncertainty, formal analysis
      ]
    ],
  )
]


#lecture-slide(title: "Example: Designing a Monitoring Network")[
  #discuss-block(title: "Interactive Exercise")[
    A state agency has 15 soil monitoring stations and wants to add 5 more to reduce prediction uncertainty. They have a Kriging variance map.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      + The Kriging variance map shows a large red zone (high uncertainty) in the northwest corner of the study area. Why is uncertainty high there?

      + Should the 5 new stations be placed in a tight cluster within the red zone or spread across the entire red region? Why?

      + After adding the stations, the agency re-runs Kriging. What happens to: (a) the prediction surface, and (b) the variance map?

      + The agency wants to guarantee that prediction error is below 0.5 mg/kg everywhere. How does the variance map help answer whether 5 stations are enough?
    ],
    [
      #focus-block(title: "Key Insight", color: primary-color)[
        Kriging variance depends only on *station locations and the variogram*---not on measured values. This means you can design optimal monitoring networks *before collecting any data*.

        This is called *variance-guided sampling design*.
      ]

      #v(0.3em)

      #focus-block(title: "Software", color: accent-color)[
        *R:* `gstat::krige()`, `automap::autoKrige()` \
        *Python:* `pykrige.OrdinaryKriging`, `scikit-gstat`
      ]
    ],
  )
]


// =============================================================================
// PART 8: CHOOSING THE RIGHT TECHNIQUE
// =============================================================================

#lecture-slide(title: "Choosing the Right Spatial Analysis Technique")[
  #align(center)[#image("Data/07_Spatial_Analysis/07_decision_framework.png", height: 20em)]

  #v(0.3em)

  #align(center)[_Match the technique to your question. Complexity is only justified when the simpler method cannot answer it._]
]


// =============================================================================
// TAKEAWAYS
// =============================================================================

#lecture-slide(title: "Key Takeaways")[
  #set text(size: 0.8em)
  #table(
    columns: (2fr, 2fr, 3fr),
    inset: 0.4em,
    stroke: 0.5pt + luma(200),
    fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
    [*Technique*], [*What It Does*], [*When to Use It*],
    [Mean Center / Std Distance], [Summarizes location and spread], [Describe the spatial distribution of events],
    [Nearest Neighbor (NNI)], [Tests clustering vs. dispersion], [Determine if a point pattern is non-random],
    [Kernel Density (KDE)], [Converts points to intensity surface], [Visualize hotspots; communicate density to non-experts],
    [Global Moran's I], [Tests overall spatial autocorrelation], [Is the variable spatially structured?],
    [Local Moran's I (LISA)], [Identifies local clusters/outliers], [Where are the hot spots and cold spots?],
    [IDW], [Weighted average interpolation], [Quick prediction; dense networks; no uncertainty needed],
    [Variogram], [Models spatial dependence vs. distance], [Understand the range and structure of spatial correlation],
    [Kriging], [Optimal interpolation + uncertainty], [Sparse data; need prediction variance; formal spatial modeling],
  )

  #v(0.3em)

  *Resources:*
  #link("https://r-spatial.org/book/")[#text(fill: accent-color.darken(20%))[Spatial Data Science with R]] #sym.dot.c
  #link("https://mgimond.github.io/Spatial/")[#text(fill: accent-color.darken(20%))[Intro to GIS and Spatial Analysis]] #sym.dot.c
  #link("https://pysal.org/")[#text(fill: accent-color.darken(20%))[PySAL (Python Spatial Analysis Library)]]
]


#lecture-slide[
  #set align(center + horizon)
  #text(2em, fill: primary-color, [Questions?])
]
