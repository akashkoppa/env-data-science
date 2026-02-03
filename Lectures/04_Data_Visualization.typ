#import "@preview/polylux:0.4.0": *
#import "@preview/fletcher:0.5.8": diagram, node, edge


// --- CONFIGURATION & COLORS ---
#let primary-color = rgb("#2d5a27") // Sage Green
#let accent-color = rgb("#457b9d")  // Muted Steel Blue
#let bg-color = rgb("#fdfdfc")      // Soft Cream (easy on the eyes)
#let text-color = rgb("#2f2f2f")    // Soft Charcoal
#let warning-color = rgb("#c44536") // Warning Red

#let setup-theme(title: "", author: "", date: none, body) = {
  set page(
    paper: "presentation-16-9",
    fill: bg-color,
    margin: 2.5em,
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

// Custom Wrapper for Slides
#let lecture-slide(title: none, body) = {
  slide({
    if title != none {
      set align(top)
      // Header styling
      grid(
        columns: (1fr, auto),
        align(left + bottom, text(1.3em, weight: "semibold", fill: primary-color, title)),
        align(right + bottom, text(0.6em, fill: text-color.lighten(50%), [ENST431: Environmental Data Science]))
      )
      line(length: 100%, stroke: 0.5pt + primary-color.lighten(50%))
      v(1em)
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

// Callout boxes
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

// Code block helper
#let code-block(code) = {
  rect(
    fill: luma(245),
    stroke: 0.5pt + luma(200),
    width: 100%,
    inset: 0.8em,
    radius: 4pt,
    text(size: 0.8em, font: "Courier New", code)
  )
}


// --- DOCUMENT START ---

#show: body => setup-theme(
  title: "Data Visualization",
  author: "Instructor: Akash Koppa",
  date: "Lecture 4 of Spring Semester 2026",
  body
)

// =============================================================================
// AGENDA
// =============================================================================

#lecture-slide(title: "Today's Agenda")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    focus-block(title: "Part 1: Foundations", color: primary-color)[
      - Why Visualize Data?
      - The Grammar of Graphics
      - ggplot2 Fundamentals
      - Choosing the Right Plot Type
      - Single Variable Distributions
      - Two Variable Relationships
    ],
    focus-block(title: "Part 2: Advanced Techniques", color: accent-color)[
      - Color, Shape, and Symbology
      - Faceting and Multi-Panel Plots
      - Time Series Visualization
      - Spatial Data Visualization
      - Specialized Environmental Plots
      - Designing Publication-Quality Figures
    ]
  )
]

// =============================================================================
// PART 1: FOUNDATIONS
// =============================================================================

#lecture-slide(title: "Why Visualize Data?")[
  #focus-block(title: "Anscombe's Quartet", color: primary-color)[
    Four datasets with *identical* summary statistics (mean, variance, correlation, regression line) but *vastly different* distributions. Visualization reveals what statistics alone cannot.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #table(
        columns: (auto, auto, auto, auto, auto),
        stroke: 0.5pt + luma(200),
        inset: 0.5em,
        [*Dataset*], [*x̄*], [*ȳ*], [*r*], [*Regression*],
        [I], [9.0], [7.5], [0.82], [y = 0.5x + 3],
        [II], [9.0], [7.5], [0.82], [y = 0.5x + 3],
        [III], [9.0], [7.5], [0.82], [y = 0.5x + 3],
        [IV], [9.0], [7.5], [0.82], [y = 0.5x + 3],
      )
    ],
    focus-block(title: "The Message", color: accent-color)[
      *Always visualize your data!*

      - Outliers and anomalies
      - Non-linear relationships
      - Clusters and patterns
      - Data quality issues

      Statistics summarize; visualization reveals.
    ]
  )
]


#lecture-slide(title: "The Grammar of Graphics")[
  #focus-block(title: "Core Philosophy", color: primary-color)[
    A plot is built from *layers*, each defined by *data*, *aesthetic mappings*, and *geometric objects*. This modular approach allows unlimited customization.
  ]

  #v(0.5em)

  #diagram(
    node-stroke: 1pt,
    spacing: 2.5em,
    node((0, 0), [*Data*], fill: primary-color.lighten(90%), stroke: primary-color, corner-radius: 4pt, width: 5em),
    node((1, 0), [*Aesthetics*], fill: primary-color.lighten(85%), stroke: primary-color, corner-radius: 4pt, width: 6em),
    node((2, 0), [*Geometries*], fill: accent-color.lighten(85%), stroke: accent-color, corner-radius: 4pt, width: 6em),
    node((3, 0), [*Scales*], fill: accent-color.lighten(80%), stroke: accent-color, corner-radius: 4pt, width: 5em),
    node((4, 0), [*Facets*], fill: accent-color.lighten(75%), stroke: accent-color, corner-radius: 4pt, width: 5em),
    node((5, 0), [*Theme*], fill: accent-color.lighten(70%), stroke: accent-color, corner-radius: 4pt, width: 5em),

    edge((0, 0), (1, 0), "-|>"),
    edge((1, 0), (2, 0), "-|>"),
    edge((2, 0), (3, 0), "-|>"),
    edge((3, 0), (4, 0), "-|>"),
    edge((4, 0), (5, 0), "-|>"),
  )

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.8em,
    focus-block(title: "Data", color: primary-color)[
      The tidy data frame (variables as columns, observations as rows)
    ],
    focus-block(title: "Aesthetics", color: primary-color)[
      Map variables to visual properties: x, y, color, size, shape
    ],
    focus-block(title: "Geometries", color: accent-color)[
      Visual marks: points, lines, bars, polygons, text
    ]
  )
]


#lecture-slide(title: "ggplot2 Fundamentals")[
  #focus-block(title: "The Basic Template", color: primary-color)[
    #code-block[
      `ggplot(data = <DATA>, aes(x = <X>, y = <Y>)) +` \
      `  geom_<TYPE>()`
    ]
    Every ggplot starts with `ggplot()`, maps variables with `aes()`, and adds layers with `+`.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Example: Scatter Plot", color: accent-color)[
        #code-block[
          `ggplot(water_data,` \
          `  aes(x = temp_c,` \
          `      y = do_mg_l)) +` \
          `  geom_point()`
        ]
      ]
      #v(0.3em)
      #focus-block(title: "Adding Layers", color: accent-color)[
        #code-block[
          `... +` \
          `  geom_smooth(method = "lm") +` \
          `  labs(title = "DO vs Temp",` \
          `       x = "Temperature (°C)",` \
          `       y = "DO (mg/L)")`
        ]
      ]
    ],
    focus-block(title: "Key Concepts", color: primary-color)[
      - *Layers stack*: Each `+` adds a new layer
      - *Inheritance*: Aesthetics in `ggplot()` apply to all layers
      - *Overriding*: Aesthetics in `geom_*()` apply only to that layer
      - *Flexibility*: Mix multiple geoms freely

      #v(0.3em)

      Common layer types:
      - `geom_*()` — geometric objects
      - `stat_*()` — statistical transformations
      - `scale_*()` — axis and color scales
      - `facet_*()` — multi-panel layouts
      - `theme()` — visual styling
    ]
  )
]


#lecture-slide(title: "Choosing the Right Plot Type")[
  #focus-block(title: "Match Plot Type to Data Type", color: primary-color)[
    The most important decision in visualization is choosing the appropriate plot for your data and question.
  ]

  #v(0.3em)

  #table(
    columns: (2fr, 2fr, 3fr),
    stroke: 0.5pt + luma(200),
    inset: 0.6em,
    fill: (x, y) => if y == 0 { primary-color.lighten(85%) } else { none },
    [*Data Type*], [*Question*], [*Plot Type*],
    [1 Continuous], [Distribution?], [Histogram, Density, Boxplot],
    [1 Categorical], [Counts?], [Bar chart],
    [2 Continuous], [Relationship?], [Scatter plot, Hex bins],
    [Cont. × Categ.], [Comparison?], [Boxplot, Violin, Bar+error],
    [Time series], [Trend?], [Line plot, Area chart],
    [Spatial], [Pattern?], [Map, Heatmap],
    [3+ Variables], [Multivariate?], [Facets, Color/Size mapping],
  )

  #v(0.3em)

  #focus-block(title: "Environmental Examples", color: accent-color)[
    Streamflow trends → Line plot | Species abundance → Bar/Boxplot | Temperature-Salinity → Scatter | Pollutant levels → Heatmap/Map
  ]
]


#lecture-slide(title: "Single Variable: Histograms")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Concept", color: primary-color)[
        Histograms show the *distribution* of a continuous variable by dividing data into bins and counting observations in each bin.
      ]

      #v(0.3em)

      #code-block[
        `ggplot(data, aes(x = temp_c)) +` \
        `  geom_histogram(` \
        `    binwidth = 2,` \
        `    fill = "#2d5a27",` \
        `    color = "white"` \
        `  )`
      ]

      #v(0.3em)

      #focus-block(title: "Binwidth Matters", color: accent-color)[
        - Too narrow → noisy, hard to interpret
        - Too wide → hides important structure
        - Rule of thumb: try multiple values
        - `bins = 30` vs. `binwidth = 2`
      ]
    ],
    [
      #focus-block(title: "Variants", color: primary-color)[
        *Frequency polygon:* Line connecting bin tops
        #code-block[
          `geom_freqpoly(binwidth = 2)`
        ]

        *Cumulative histogram:*
        #code-block[
          `stat_ecdf()`
        ]
        Shows percentiles and median (50th).
      ]

      #v(0.3em)

      #focus-block(title: "Environmental Use", color: accent-color)[
        - Precipitation distributions (often right-skewed)
        - Temperature frequency
        - Pollutant concentrations
        - Species size distributions
      ]
    ]
  )
]


#lecture-slide(title: "Single Variable: Density Plots")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Concept", color: primary-color)[
        Density plots show a *smoothed* estimate of the distribution. The area under the curve equals 1, making it a probability density.
      ]

      #v(0.3em)

      #code-block[
        `ggplot(data, aes(x = temp_c)) +` \
        `  geom_density(` \
        `    fill = "#457b9d",` \
        `    alpha = 0.5` \
        `  )`
      ]

      #v(0.3em)

      #focus-block(title: "Bandwidth", color: accent-color)[
        Like binwidth, bandwidth controls smoothness:
        #code-block[
          `geom_density(bw = 0.5)`
        ]
        Smaller = more detail, more noise
      ]
    ],
    [
      #focus-block(title: "Comparing Groups", color: primary-color)[
        Density plots excel at overlaying distributions:
        #code-block[
          `ggplot(data,` \
          `  aes(x = temp_c,` \
          `      fill = season)) +` \
          `  geom_density(alpha = 0.4)`
        ]

        *Key:* Use `alpha` for transparency when overlapping!
      ]

      #v(0.3em)

      #focus-block(title: "Ridgeline Plots", color: accent-color)[
        For many groups, use `ggridges`:
        #code-block[
          `library(ggridges)` \
          `geom_density_ridges()`
        ]
        Shows distributions stacked by factor.
      ]
    ]
  )
]


#lecture-slide(title: "Single Variable: Boxplots")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Anatomy of a Boxplot", color: primary-color)[
        - *Box*: Q1 to Q3 (Interquartile Range)
        - *Line*: Median (50th percentile)
        - *Whiskers*: 1.5 × IQR from box
        - *Points*: Outliers beyond whiskers
      ]

      #v(0.3em)

      #code-block[
        `ggplot(data,` \
        `  aes(x = station,` \
        `      y = do_mg_l)) +` \
        `  geom_boxplot(` \
        `    fill = "#2d5a27",` \
        `    alpha = 0.7` \
        `  )`
      ]
    ],
    [
      #focus-block(title: "Enhancements", color: accent-color)[
        *Add individual points:*
        #code-block[
          `geom_boxplot() +` \
          `geom_jitter(width = 0.2,` \
          `            alpha = 0.3)`
        ]

        *Notched boxplots:*
        #code-block[
          `geom_boxplot(notch = TRUE)`
        ]
        Notches show 95% CI for median — non-overlapping notches suggest significant difference.
      ]

      #v(0.3em)

      #focus-block(title: "Violin Plots", color: primary-color)[
        Show full distribution shape:
        #code-block[
          `geom_violin() +` \
          `geom_boxplot(width = 0.1)`
        ]
      ]
    ]
  )
]


#lecture-slide(title: "Two Variables: Scatter Plots")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Basic Scatter Plot", color: primary-color)[
        The fundamental plot for two continuous variables:
        #code-block[
          `ggplot(data,` \
          `  aes(x = precip_mm,` \
          `      y = runoff_mm)) +` \
          `  geom_point()`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "Adding Trend Lines", color: accent-color)[
        #code-block[
          `... + geom_smooth()  # loess` \
          `... + geom_smooth(method = "lm")` \
          `... + geom_smooth(` \
          `  method = "lm",` \
          `  se = FALSE  # no CI band` \
          `)`
        ]
      ]
    ],
    [
      #focus-block(title: "Handling Overplotting", color: primary-color)[
        When many points overlap:

        *Transparency:*
        #code-block[
          `geom_point(alpha = 0.3)`
        ]

        *Jittering:*
        #code-block[
          `geom_jitter(width = 0.5)`
        ]

        *2D binning:*
        #code-block[
          `geom_hex() + scale_fill_viridis_c()` \
          `geom_bin2d()`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "Log Scales", color: accent-color)[
        For data spanning orders of magnitude:
        #code-block[
          `... + scale_x_log10() +` \
          `      scale_y_log10()`
        ]
      ]
    ]
  )
]


#lecture-slide(title: "Two Variables: Bar Charts")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "geom_bar() vs geom_col()", color: primary-color)[
        *geom_bar()*: Counts observations
        #code-block[
          `ggplot(data, aes(x = site)) +` \
          `  geom_bar()`
        ]

        *geom_col()*: Uses provided heights
        #code-block[
          `ggplot(summary_data,` \
          `  aes(x = site,` \
          `      y = mean_runoff)) +` \
          `  geom_col()`
        ]

        *Rule:* Count categories → `geom_bar()` \
        Pre-computed values → `geom_col()`
      ]
    ],
    [
      #focus-block(title: "Grouped & Stacked Bars", color: accent-color)[
        *Grouped (dodged):*
        #code-block[
          `aes(fill = treatment) +` \
          `geom_col(position = "dodge")`
        ]

        *Stacked:*
        #code-block[
          `aes(fill = treatment) +` \
          `geom_col()  // default stacked`
        ]

        *Proportional:*
        #code-block[
          `geom_col(position = "fill")`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "Error Bars", color: primary-color)[
        #code-block[
          `geom_col() +` \
          `geom_errorbar(` \
          `  aes(ymin = mean - se,` \
          `      ymax = mean + se),` \
          `  width = 0.2)`
        ]
      ]
    ]
  )
]


// =============================================================================
// PART 2: ADVANCED TECHNIQUES
// =============================================================================

#lecture-slide(title: "Color, Shape, and Size")[
  #focus-block(title: "Mapping Variables to Visual Channels", color: primary-color)[
    Aesthetic mappings (`aes()`) connect data to visual properties. The key distinction: *inside* vs. *outside* `aes()`.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Mapped (varies by data)", color: accent-color)[
        #code-block[
          `aes(color = station,` \
          `    shape = treatment,` \
          `    size = sample_size)`
        ]
        ggplot creates legends automatically.
      ]

      #v(0.3em)

      #focus-block(title: "Fixed (same for all)", color: accent-color)[
        #code-block[
          `geom_point(color = "red",` \
          `           size = 3,` \
          `           shape = 17)`
        ]
        No legend created.
      ]
    ],
    [
      #focus-block(title: "Color Scales", color: primary-color)[
        *Categorical:*
        #code-block[
          `scale_color_brewer(palette = "Set2")` \
          `scale_color_viridis_d()`
        ]

        *Continuous:*
        #code-block[
          `scale_color_viridis_c()` \
          `scale_color_gradient(` \
          `  low = "blue", high = "red")` \
          `scale_color_gradient2(` \
          `  low = "blue", mid = "white",` \
          `  high = "red", midpoint = 0)`
        ]
      ]
    ]
  )
]


#lecture-slide(title: "Faceting: Multi-Panel Plots")[
  #focus-block(title: "Split Your Data Into Panels", color: primary-color)[
    Faceting creates separate panels for subsets of data — essential for comparing patterns across groups without overplotting.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "facet_wrap()", color: accent-color)[
        Wraps panels into a grid:
        #code-block[
          `... + facet_wrap(~station)` \
          `` \
          `# Control layout:` \
          `facet_wrap(~station,` \
          `           ncol = 3,` \
          `           scales = "free_y")`
        ]

        *scales options:*
        - `"fixed"` — same axes (default)
        - `"free_x"` — independent x-axes
        - `"free_y"` — independent y-axes
        - `"free"` — both independent
      ]
    ],
    [
      #focus-block(title: "facet_grid()", color: accent-color)[
        Creates a matrix of panels:
        #code-block[
          `# rows ~ columns` \
          `facet_grid(season ~ site)` \
          `` \
          `# Only rows:` \
          `facet_grid(season ~ .)` \
          `` \
          `# Only columns:` \
          `facet_grid(. ~ site)`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "When to Facet", color: primary-color)[
        - Comparing time series across stations
        - Distribution by treatment × site
        - Avoiding cluttered legends
      ]
    ]
  )
]


#lecture-slide(title: "Time Series Visualization")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Line Plots", color: primary-color)[
        The workhorse of time series:
        #code-block[
          `ggplot(data,` \
          `  aes(x = date,` \
          `      y = discharge,` \
          `      color = station)) +` \
          `  geom_line()`
        ]

        *With points:*
        #code-block[
          `geom_line() +` \
          `geom_point(size = 1)`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "Reference Lines", color: accent-color)[
        Add thresholds and annotations:
        #code-block[
          `geom_hline(yintercept = 5,` \
          `  linetype = "dashed",` \
          `  color = "red")` \
          `geom_vline(xintercept =` \
          `  as.Date("2025-07-01"))`
        ]
      ]
    ],
    [
      #focus-block(title: "Area Charts", color: primary-color)[
        Show cumulative or stacked quantities:
        #code-block[
          `geom_area(alpha = 0.5)` \
          `` \
          `# Stacked by group:` \
          `geom_area(aes(fill = source),` \
          `  position = "stack")`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "Ribbons for Uncertainty", color: accent-color)[
        Show confidence intervals:
        #code-block[
          `geom_ribbon(` \
          `  aes(ymin = lower,` \
          `      ymax = upper),` \
          `  alpha = 0.3) +` \
          `geom_line()`
        ]

        Useful for model predictions, ensemble ranges, and measurement error.
      ]
    ]
  )
]


#lecture-slide(title: "Seasonal Patterns: Multi-Year Comparisons")[
  #focus-block(title: "Overlaying Annual Cycles", color: primary-color)[
    To compare seasonal patterns across years, use day-of-year on x-axis and color by year:
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #code-block[
        `library(lubridate)` \
        `` \
        `data |>` \
        `  mutate(` \
        `    year = year(date),` \
        `    doy = yday(date)` \
        `  ) |>` \
        `  ggplot(aes(x = doy,` \
        `             y = temperature,` \
        `             color = factor(year))) +` \
        `  geom_line(alpha = 0.7) +` \
        `  labs(x = "Day of Year",` \
        `       color = "Year")`
      ]
    ],
    [
      #focus-block(title: "Applications", color: accent-color)[
        - Phenological shifts (earlier spring, later fall)
        - Comparing wet/dry years
        - Identifying anomalous years
        - Climate change detection
      ]

      #v(0.3em)

      #focus-block(title: "Climatological Mean", color: primary-color)[
        Add long-term average:
        #code-block[
          `geom_smooth(aes(group = 1),` \
          `  method = "loess",` \
          `  color = "black",` \
          `  linewidth = 1.5)`
        ]
      ]
    ]
  )
]


#lecture-slide(title: "Heatmaps")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Tile-Based Heatmaps", color: primary-color)[
        Show values across two categorical dimensions:
        #code-block[
          `ggplot(data,` \
          `  aes(x = month,` \
          `      y = station,` \
          `      fill = mean_temp)) +` \
          `  geom_tile() +` \
          `  scale_fill_viridis_c()`
        ]

        Works for:
        - Station × Month matrices
        - Correlation matrices
        - Species × Site presence
      ]
    ],
    [
      #focus-block(title: "Continuous Heatmaps", color: accent-color)[
        For gridded data (rasters):
        #code-block[
          `geom_raster(aes(fill = value))` \
          `` \
          `# Interpolated:` \
          `geom_contour_filled()`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "Color Scale Choice", color: primary-color)[
        - *Sequential:* Low to high values
        - *Diverging:* Deviations from center
        - *Viridis:* Colorblind-safe, perceptually uniform

        #code-block[
          `scale_fill_distiller(` \
          `  palette = "RdBu",` \
          `  direction = -1)`
        ]
      ]
    ]
  )
]


#lecture-slide(title: "Hovmöller Diagrams")[
  #focus-block(title: "Space-Time Visualization", color: primary-color)[
    Hovmöller diagrams show how a variable changes over both space and time simultaneously. Common in atmospheric and oceanographic science.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Construction", color: accent-color)[
        - X-axis: Time (date or hour)
        - Y-axis: Spatial coordinate (latitude, station, depth)
        - Fill: Variable of interest

        #code-block[
          `ggplot(data,` \
          `  aes(x = date,` \
          `      y = latitude,` \
          `      fill = temperature)) +` \
          `  geom_tile() +` \
          `  scale_fill_viridis_c() +` \
          `  labs(x = "Date",` \
          `       y = "Latitude",` \
          `       fill = "Temp (°C)")`
        ]
      ]
    ],
    [
      #focus-block(title: "Environmental Applications", color: primary-color)[
        - Sea surface temperature evolution along coast
        - Dissolved oxygen changes with depth over time
        - Chlorophyll blooms along transects
        - Soil moisture at different depths
        - Air quality across monitoring stations
      ]

      #v(0.3em)

      #focus-block(title: "Interpretation", color: accent-color)[
        - Diagonal patterns: propagating features
        - Horizontal bands: spatial patterns
        - Vertical bands: temporal events
        - Identify seasonal cycles and anomalies
      ]
    ]
  )
]


#lecture-slide(title: "Pairs Plots: Correlation Exploration")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "GGally::ggpairs()", color: primary-color)[
        Visualize all pairwise relationships:
        #code-block[
          `library(GGally)` \
          `` \
          `ggpairs(data,` \
          `  columns = c("temp",` \
          `    "precip", "runoff",` \
          `    "turbidity"),` \
          `  aes(color = site,` \
          `      alpha = 0.5))`
        ]

        Creates a matrix showing:
        - Scatter plots (below diagonal)
        - Correlations (above diagonal)
        - Distributions (diagonal)
      ]
    ],
    [
      #focus-block(title: "Customization", color: accent-color)[
        #code-block[
          `ggpairs(data,` \
          `  lower = list(` \
          `    continuous = wrap("points",` \
          `      alpha = 0.3)),` \
          `  upper = list(` \
          `    continuous = wrap("cor",` \
          `      size = 5)),` \
          `  diag = list(` \
          `    continuous = wrap("densityDiag",` \
          `      fill = "lightblue")))`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "When to Use", color: primary-color)[
        - Exploratory data analysis
        - Variable selection for modeling
        - Identifying multicollinearity
        - Understanding data structure
      ]
    ]
  )
]


#lecture-slide(title: "Spatial Visualization with ggplot2")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Point Data Maps", color: primary-color)[
        Plot station locations with sf:
        #code-block[
          `library(sf)` \
          `` \
          `ggplot(stations_sf) +` \
          `  geom_sf(aes(color = value,` \
          `              size = sample_n)) +` \
          `  scale_color_viridis_c() +` \
          `  theme_minimal()`
        ]

        `geom_sf()` handles coordinate systems automatically.
      ]
    ],
    [
      #focus-block(title: "Adding Basemaps", color: accent-color)[
        With `ggspatial`:
        #code-block[
          `library(ggspatial)` \
          `` \
          `ggplot() +` \
          `  annotation_map_tile() +` \
          `  geom_sf(data = points,` \
          `    aes(color = value))`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "Raster Data", color: primary-color)[
        With `tidyterra`:
        #code-block[
          `library(tidyterra)` \
          `` \
          `ggplot() +` \
          `  geom_spatraster(data = rast)`
        ]
      ]
    ]
  )
]


#lecture-slide(title: "Customizing Themes")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Built-in Themes", color: primary-color)[
        #code-block[
          `+ theme_minimal()   # clean` \
          `+ theme_bw()        # black/white` \
          `+ theme_classic()   # no grid` \
          `+ theme_void()      # nothing` \
          `+ theme_dark()      # dark mode`
        ]

        Extended themes:
        #code-block[
          `library(ggthemes)` \
          `+ theme_economist()` \
          `+ theme_tufte()`
        ]
      ]
    ],
    [
      #focus-block(title: "Custom Modifications", color: accent-color)[
        #code-block[
          `+ theme(` \
          `  legend.position = "bottom",` \
          `  axis.text = element_text(` \
          `    size = 12),` \
          `  axis.title = element_text(` \
          `    face = "bold"),` \
          `  panel.grid.minor =` \
          `    element_blank(),` \
          `  plot.title = element_text(` \
          `    hjust = 0.5)` \
          `)`
        ]
      ]

      #v(0.3em)

      #focus-block(title: "Legend Control", color: primary-color)[
        #code-block[
          `legend.position = c(0.9, 0.9)` \
          `# x, y as proportions`
        ]
      ]
    ]
  )
]


#lecture-slide(title: "Publication-Quality Figures")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Labels and Annotations", color: primary-color)[
        #code-block[
          `+ labs(` \
          `  title = "Main Title",` \
          `  subtitle = "Subtitle",` \
          `  caption = "Data: USGS",` \
          `  x = "Temperature (°C)",` \
          `  y = "Discharge (m³/s)",` \
          `  color = "Station"` \
          `)` \
          `` \
          `+ annotate("text",` \
          `  x = 25, y = 100,` \
          `  label = "Flood event",` \
          `  fontface = "italic")`
        ]
      ]
    ],
    [
      #focus-block(title: "Saving Figures", color: accent-color)[
        #code-block[
          `ggsave("figure.png",` \
          `  width = 8,` \
          `  height = 6,` \
          `  dpi = 300)` \
          `` \
          `# Vector format for publications:` \
          `ggsave("figure.pdf",` \
          `  width = 8, height = 6)`
        ]

        *Tips:*
        - Journals often require 300+ dpi
        - Use PDF/EPS for scalable figures
        - Check required dimensions
      ]

      #v(0.3em)

      #focus-block(title: "Combining Plots", color: primary-color)[
        #code-block[
          `library(patchwork)` \
          `(p1 + p2) / p3`
        ]
      ]
    ]
  )
]


#lecture-slide(title: "Figure Design: Best Practices")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Do", color: primary-color)[
        - Label axes with units: "Temperature (°C)"
        - Use colorblind-friendly palettes
        - Start bar chart y-axes at zero
        - Include figure captions
        - Keep it simple and focused
        - Use consistent styling across figures
        - Include alt-text for accessibility
        - Choose appropriate aspect ratios
      ]
    ],
    [
      #focus-block(title: "Don't", color: warning-color)[
        - Use 3D effects (distorts perception)
        - Use pie charts for precise comparisons
        - Truncate axes to exaggerate effects
        - Use rainbow color scales
        - Use red/green only for categories
        - Overload with too many variables
        - Forget legends when color matters
        - Use tiny fonts
      ]
    ]
  )

  #v(0.3em)

  #focus-block(title: "The Data-Ink Ratio", color: accent-color)[
    Maximize the proportion of ink devoted to data. Remove chartjunk: unnecessary gridlines, backgrounds, decorations, and redundant elements. Every mark should convey information.
  ]
]


#lecture-slide(title: "Summary: The Visualization Workflow")[
  #v(0.5em)

  #diagram(
    node-stroke: 1pt,
    spacing: 2em,
    node((0, 0), [*Question*], fill: luma(240), stroke: luma(200), corner-radius: 4pt, width: 6em),
    node((1.5, 0), [*Data Type*], fill: primary-color.lighten(90%), stroke: primary-color, corner-radius: 4pt, width: 6em),
    node((3, 0), [*Plot Type*], fill: primary-color.lighten(80%), stroke: primary-color, corner-radius: 4pt, width: 6em),
    node((4.5, 0), [*Aesthetics*], fill: accent-color.lighten(85%), stroke: accent-color, corner-radius: 4pt, width: 6em),
    node((6, 0), [*Refinement*], fill: accent-color.lighten(70%), stroke: accent-color, corner-radius: 4pt, width: 6em),

    edge((0, 0), (1.5, 0), "-|>"),
    edge((1.5, 0), (3, 0), "-|>"),
    edge((3, 0), (4.5, 0), "-|>"),
    edge((4.5, 0), (6, 0), "-|>"),
  )

  #v(1em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    focus-block(title: "Key Takeaway 1", color: primary-color)[
      *Always visualize first.* Statistics summarize; visualization reveals patterns, outliers, and relationships that numbers alone miss.
    ],
    focus-block(title: "Key Takeaway 2", color: primary-color)[
      *Match plot to data.* The right visualization depends on your data types (continuous, categorical, temporal, spatial) and your question.
    ],
    focus-block(title: "Key Takeaway 3", color: primary-color)[
      *Design for your audience.* Publication figures need polish; exploratory plots need speed. Balance aesthetics with clarity.
    ]
  )
]


#lecture-slide(title: "What's Next?")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Today We Covered", color: primary-color)[
        - Why visualization matters (Anscombe)
        - Grammar of Graphics philosophy
        - ggplot2 fundamentals
        - Distribution plots (histogram, density, boxplot)
        - Relationship plots (scatter, bar)
        - Time series and seasonal patterns
        - Heatmaps and Hovmöller diagrams
        - Faceting and multi-panel layouts
        - Color, themes, and publication quality
      ]
    ],
    [
      #focus-block(title: "Coming Up", color: accent-color)[
        - Hands-on visualization exercises
        - Interactive plots with `plotly`
        - Spatial visualization with `sf` and `tmap`
        - Animated visualizations with `gganimate`
        - Dashboard creation with Shiny
      ]

      #v(0.5em)

      #focus-block(title: "Resources", color: accent-color)[
        - #link("https://r4ds.hadley.nz/data-visualize")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[R4DS: Visualization]]]
        - #link("https://ggplot2-book.org/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[ggplot2 Book]]]
        - #link("https://www.data-to-viz.com/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[From Data to Viz]]]
        - #link("https://bookdown.org/igisc/EnvDataSci/visualization.html")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[EnvDataSci: Visualization]]]
      ]
    ]
  )
]


#lecture-slide[
  #set align(center + horizon)
  #text(2em, fill: primary-color, [Questions?])
]
