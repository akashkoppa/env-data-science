// =============================================================================
// Lecture 4: Data Visualization and Interpretation — Exercises
// Environmental Data Science (ENST431/631)
// Author: Akash Koppa
// =============================================================================

// --- CONFIGURATION & COLORS ---
#let primary-color = rgb("#2d5a27")
#let accent-color = rgb("#457b9d")
#let bg-color = rgb("#fdfdfc")
#let text-color = rgb("#2f2f2f")
#let warning-color = rgb("#c44536")
#let viz-color = rgb("#7b2d8b")

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
        align(right)[Lecture 4: Data Visualization and Interpretation]
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

#let context-box(body) = { focus-box(title: "🌍 The Problem", color: rgb("#5a8f7b"), body) }
#let viz-task-box(body) = { focus-box(title: "📊 Visualization Task", color: viz-color, body) }
#let think-box(body) = { focus-box(title: "🧠 Think Before You Plot", color: accent-color, body) }

// =============================================================================
// TITLE PAGE
// =============================================================================

#title-block(
  title: "Data Visualization and Interpretation",
  subtitle: "Exercises for Environmental Data Science",
  author: "Instructor: Akash Koppa",
  date: "Lecture 4 — Spring Semester 2026"
)

// --- INTRODUCTION ---
#text(weight: "semibold", size: 12pt, fill: primary-color)[Introduction]
#v(0.3em)

Data analysis without visualization is like field work without observation — you may collect data, but you miss the story it tells. These exercises build directly on the programming skills you developed in the Lecture 2 exercises. Where those exercises asked you to _manipulate_ data, these exercises ask you to _see_ and _interpret_ it. For each of the ten problems from the previous exercise set, you will now create a figure that reveals a pattern, answers a question, or communicates a finding. You must choose the appropriate figure type, justify that choice, and interpret what the figure reveals.

#v(0.5em)
#text(weight: "semibold", size: 11pt, fill: accent-color)[How to Use This Document]

For each exercise, follow this workflow:

+ *Review your work*: from the corresponding Lecture 2 exercise. You will use the data and results you already produced.
+ *Read the visualization task*: understand what question your figure must answer.
+ *Choose a figure type*: decide which type of plot best addresses the question. There is often more than one valid choice.
+ *Create the figure*: following the Visualization Guidelines below.
+ *Interpret the figure*: answer the specific question posed. Write 2--3 sentences explaining what the figure reveals.
+ *Justify your choice*: explain _why_ you chose this figure type over alternatives. What would be lost if you used a different type?

#v(0.5em)

#focus-box(title: "Setup Required", color: warning-color)[
  These exercises assume you have completed (or are working alongside) the Lecture 2 exercises. You will need the data objects, functions, and derived variables created there. For plotting in R, we use *base R graphics* (`plot()`, `barplot()`, `hist()`, `boxplot()`). For Python, use *matplotlib* (`import matplotlib.pyplot as plt`) and optionally *seaborn* (`import seaborn as sns`). Later lectures will introduce `ggplot2` (R) and advanced seaborn patterns.
]

#pagebreak()

// =============================================================================
// VISUALIZATION GUIDELINES
// =============================================================================

#v(0.5em)
#text(weight: "semibold", size: 14pt, fill: primary-color)[Visualization Guidelines]
#v(0.3em)

Every figure you produce in this course should follow the guidelines below. In science, a figure is often the first (and sometimes only) thing a reader examines. A well-constructed figure stands on its own and communicates clearly without requiring the reader to hunt through surrounding text for context.

#v(0.3em)

#block(width: 100%, stroke: 1.5pt + primary-color.lighten(30%), radius: 6pt, inset: 1.2em, fill: primary-color.lighten(95%), [

  #text(weight: "bold", fill: primary-color, size: 11pt)[Guidelines for Effective Figures]
  #v(0.5em)

  *1. Label every axis with a descriptive name and units.*
  #v(0.15em)
  Write "Dissolved Oxygen (mg/L)", not "DO" or "do_mg_l". The reader should never have to guess what is being plotted. If an axis represents a dimensionless quantity (e.g., a z-score or proportion), state that explicitly.
  #v(0.4em)

  *2. Give every figure an informative title.*
  #v(0.15em)
  The title should state _what the figure shows_, not just name the variables. "Dissolved Oxygen Declines Below 5 m Depth at Station CB-5.1" is informative. "DO vs. Depth" is not.
  #v(0.4em)

  *3. Use colorblind-friendly palettes.*
  #v(0.15em)
  Approximately 8% of men and 0.5% of women have color vision deficiency. Never rely solely on red vs. green to distinguish categories. Use palettes designed for accessibility: `viridis`, `cividis`, or ColorBrewer qualitative palettes (e.g., `Set2`, `Dark2`). In R, use `palette.colors(palette = "Okabe-Ito")` or the `viridis` package. In Python, use `plt.cm.viridis` or seaborn's colorblind palette. When using color to encode a continuous variable (e.g., temperature), use a sequential palette (e.g., `viridis`). When encoding a diverging variable (e.g., anomalies from a mean), use a diverging palette (e.g., `RdBu`).
  #v(0.4em)

  *4. Include a legend whenever color, shape, or size encodes information.*
  #v(0.15em)
  If you use color to distinguish stations, the legend must map each color to its station name. If you use point size to encode a variable, the legend must show the scale. A figure without a legend forces the reader to guess.
  #v(0.4em)

  *5. Add reference lines, thresholds, or annotations where meaningful.*
  #v(0.15em)
  Environmental data often has regulatory or scientific thresholds (e.g., EPA hypoxia threshold at 2 mg/L, WHO PM#sub[2.5] guideline at 15 µg/m³). If your figure relates to such a threshold, show it as a horizontal or vertical line with a text label. This transforms a figure from "here is data" to "here is data _in context_."
  #v(0.4em)

  *6. Remove visual clutter.*
  #v(0.15em)
  No 3D effects, no unnecessary gridlines, no decorative elements that do not encode data. Every element in the figure should serve a purpose. If you cannot explain why a visual element is there, remove it. Prefer clean, minimal designs that direct the reader's attention to the data.
  #v(0.4em)

  *7. Make the figure self-contained.*
  #v(0.15em)
  A reader should be able to understand the key message of the figure _without reading the surrounding text_. This means the title, labels, legend, and annotations must together tell a complete story. Ask yourself: "If I emailed this figure with no explanation, would the recipient understand it?"
])

#pagebreak()

// =============================================================================
// EXERCISE 1
// =============================================================================

#exercise-header(number: 1, title: "Visualizing the Oxygen Profile", difficulty: "Beginner")

#context-box[
  In Lecture 2 Exercise 1, you cataloged station CB-5.1: you stored dissolved oxygen (DO) readings at 10 depths, calculated summary statistics (mean, SD, CV), and identified which depths are hypoxic (DO < 5.0 mg/L). You also stored 12 monthly temperature values.

  The station's annual report for the Maryland Department of the Environment requires a figure showing where in the water column hypoxia begins. Summary statistics alone do not convey the spatial structure of oxygen depletion — a visual representation is needed.
]

#viz-task-box[
  *Create two figures using the data from Exercise 1:*

  *Figure A — Depth Profile:* Visualize how dissolved oxygen changes with depth at station CB-5.1. Your figure must answer this question:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"Does dissolved oxygen decline gradually with depth, or is there a sharp boundary where conditions suddenly become hostile to aquatic life?"_]
    ]
  ]
  #v(0.2em)

  Your figure should include the EPA hypoxia threshold (5.0 mg/L) as a reference. After creating the figure, write 2--3 sentences interpreting what you see.

  *Figure B — Seasonal Temperature Cycle:* Visualize the monthly temperature pattern. Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"During which months is the water warm enough to exacerbate oxygen depletion (above 20°C), and how long does this warm period last?"_]
    ]
  ]
  #v(0.2em)

  Explain why you chose the figure type you did, and what would be lost if you used a different type.
]

#think-box[
  Before plotting, consider:

  - Depth profiles in oceanography are conventionally plotted with depth on the y-axis (increasing downward). Why does this convention exist, and should you follow it?
  - For the DO profile, would connecting the points with a line be appropriate, or should you show only the points? What does each choice imply about the data between measurement depths?
  - For monthly temperatures, what type of figure best shows a cyclical seasonal pattern? Would a bar chart, line chart, or something else work best?
  - Where should you place the EPA threshold line, and how can you draw the reader's eye to the transition zone?
]

#pagebreak()

// =============================================================================
// EXERCISE 2
// =============================================================================

#exercise-header(number: 2, title: "Mapping the Data Gaps", difficulty: "Beginner")

#context-box[
  In Lecture 2 Exercise 2, you imported `water_quality.csv`, handled missing value codes (`-999`, `-9999`), converted data types, and counted missing values in the dissolved oxygen and temperature columns.

  Evaluating the success of a monitoring campaign requires understanding not just _how many_ values are missing, but _where_ the gaps are. A count of "15 missing DO values" is far less informative than knowing those 15 values all came from one station during one week due to a sensor malfunction. A figure can reveal whether missingness is random or structured.
]

#viz-task-box[
  *Create a figure that reveals the pattern of missing data in the water quality dataset.* Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"Are the missing values in this dataset randomly scattered, or are they concentrated in specific variables, stations, or time periods? Does the pattern of missingness suggest sensor failure, sampling gaps, or data entry errors?"_]
    ]
  ]
  #v(0.2em)

  After creating the figure, write 2--3 sentences interpreting the pattern. Specifically address: should the data management team be _worried_ about these gaps, or are they minor and unlikely to bias analysis?

  Explain why you chose this figure type and what alternative you considered.
]

#think-box[
  Before plotting, consider:

  - A single number ("15 NAs in DO") hides structure. What visual representation reveals _where_ the gaps are — across variables, stations, and time?
  - Would a bar chart of NA counts per column be sufficient, or do you need something that shows the joint pattern (e.g., which _rows_ have which _columns_ missing)?
  - If the gaps are clustered in time, a time-oriented view might work best. If they are clustered by variable, a variable-oriented view might be better. Can you show both?
  - How would you handle the case where multiple variables are missing for the same observation?
]

#pagebreak()

// =============================================================================
// EXERCISE 3
// =============================================================================

#exercise-header(number: 3, title: "Diagnosing Data Quality Visually", difficulty: "Beginner")

#context-box[
  In Lecture 2 Exercise 3, you performed a quality control audit: you examined data structure, counted missing values, defined plausible ranges (temperature 0--35°C, dissolved oxygen 0--15 mg/L, pH 6--9), wrote validation checks, and flagged out-of-range values.

  A table of flagged values identifies individual problems, but does not reveal whether those problems are isolated glitches or part of a systematic pattern. Visualizing the full distribution of each parameter shows the shape of the data — skewness, bimodality, clusters of outliers — in a way that summary statistics cannot.
]

#viz-task-box[
  *Create a figure that shows the distribution of each water quality parameter and highlights the plausible range boundaries.* Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"What do the distributions of temperature, dissolved oxygen, pH, and turbidity look like? Are the out-of-range values isolated outliers at the tails, or is there evidence of systematic measurement problems (bimodal distributions, heavy skew, clusters of impossible values)?"_]
    ]
  ]
  #v(0.2em)

  For each parameter, include the plausible range boundaries as reference lines. After creating the figure, summarize which parameter you are _most concerned_ about and why. Would you recommend excluding any observations from further analysis?

  Explain why you chose this figure type. Consider: what information does your chosen type convey that a summary statistics table does not?
]

#think-box[
  Before plotting, consider:

  - What figure type best shows the _shape_ of a distribution? Think about histograms, density plots, boxplots, and violin plots. Each reveals different aspects.
  - If you need to compare four distributions side-by-side, should you use four separate panels (facets) or overlay them? What are the trade-offs?
  - How do you visually mark the "plausible range" boundaries? Consider shaded regions vs. vertical lines.
  - Boxplots show median, quartiles, and outliers — but hide the shape (e.g., bimodality). Histograms show shape but make comparisons harder. Is there a way to get the best of both?
  - Should you remove missing values before plotting, or do they affect the visualization?
]

#pagebreak()

// =============================================================================
// EXERCISE 4
// =============================================================================

#exercise-header(number: 4, title: "Visualizing the Hypoxia Event", difficulty: "Intermediate")

#context-box[
  In Lecture 2 Exercise 4, you filtered data for two requests: July 23rd records with DO < 6.0 or turbidity > 15 for a fisheries assessment, and data from specific stations with temperature between 24--26°C for a research query. You sorted, selected columns, and renamed variables.

  Filtered tables are useful for extracting subsets, but they do not reveal relationships between variables. To understand whether the July 23rd fish kill was driven by low oxygen, high turbidity, or both acting together, a figure showing the joint distribution of these stressors is needed.
]

#viz-task-box[
  *Create a figure that reveals the relationship between dissolved oxygen and turbidity during the July 23rd hypoxia event.* Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"On July 23rd, did low dissolved oxygen and high turbidity occur together at the same stations, or were they independent problems? Is there visual evidence that turbidity is associated with oxygen depletion?"_]
    ]
  ]
  #v(0.2em)

  Include reference lines for the DO concern threshold (6.0 mg/L) and the turbidity concern threshold (15 NTU). These lines divide the plot into four quadrants — label or annotate at least the "worst" quadrant (low DO AND high turbidity).

  After creating the figure, interpret: if you were advising the regional director, what would you say about the nature of this event?
]

#think-box[
  Before plotting, consider:

  - You are investigating a _relationship_ between two continuous variables. What figure type is designed for this?
  - If each point represents a station, should you label the points with station IDs so the director knows which locations are worst?
  - The two reference lines (DO = 6, turbidity = 15) create four quadrants. What does each quadrant mean ecologically?
    - High DO, Low turbidity = healthy
    - Low DO, Low turbidity = oxygen depletion without turbidity (nutrient-driven?)
    - High DO, High turbidity = turbid but oxygenated (sediment resuspension?)
    - Low DO, High turbidity = worst case (compounding stressors)
  - Would color or size encoding add useful information (e.g., color by station, size by temperature)?
]

#pagebreak()

// =============================================================================
// EXERCISE 5
// =============================================================================

#exercise-header(number: 5, title: "The Annual Report Timeline", difficulty: "Intermediate")

#context-box[
  In Lecture 2 Exercise 5, you created several derived variables for the annual report: temperature in Fahrenheit, DO percent saturation, a water quality status classification ("Hypoxic", "Stressed", "Adequate", "Healthy"), log-transformed turbidity, month, day of year, days since start, and temperature z-scores.

  The annual report requires a figure for its executive summary showing how Bay health changed over the monitoring season. The figure should communicate when conditions deteriorated, how severe the worst period was, and whether recovery occurred — conveying the temporal narrative that individual derived variables alone do not capture.
]

#viz-task-box[
  *Create a figure that shows how water quality status evolved over the monitoring period.* Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"Is there a clear 'danger period' during the summer when water quality deteriorates? When does the deterioration begin, when is it worst, and is there evidence of recovery? Could temperature be driving the pattern?"_]
    ]
  ]
  #v(0.2em)

  You may use the `do_status` classification, the `do_percent_sat` values, the `day_of_year` or date variable, or any combination. Consider whether showing the proportion of each status category over time (e.g., by week) tells a more compelling story than showing raw DO values.

  After creating the figure, write a 2--3 sentence caption suitable for the executive summary.
]

#think-box[
  Before plotting, consider:

  - You have a categorical variable (`do_status`) that changes over time. What figure type shows how the _composition_ of categories shifts across time?
  - Alternatively, you could plot a continuous variable (`do_percent_sat`) over time. Which approach — categorical or continuous — is more appropriate for the Secretary of the Environment?
  - If you group by day or week, should you show counts (number of observations in each status) or proportions (percentage in each status)? When would each be misleading?
  - Could you overlay temperature on the same figure (perhaps as a secondary axis or a separate panel) to show the temperature--DO connection?
  - Think about the color mapping: "Hypoxic" should probably be red, "Healthy" should be green/blue. Does this conflict with the colorblind-friendly guideline? How can you reconcile?
]

#pagebreak()

// =============================================================================
// EXERCISE 6
// =============================================================================

#exercise-header(number: 6, title: "The Station Scorecard", difficulty: "Intermediate")

#context-box[
  In Lecture 2 Exercise 6, you calculated station-level summaries: mean temperature, mean DO, maximum turbidity, number of observations, and proportion of readings with DO < 6. You also computed station-relative deviations and within-station rankings.

  Summary tables are precise but require cognitive effort to compare across rows. A figure that ranks and visually compares stations makes it immediately clear which locations are underperforming and whether the problems are consistent across metrics or station-specific.
]

#viz-task-box[
  *Create a figure that ranks and compares station performance across multiple water quality metrics.* Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"Which monitoring stations have the worst water quality, and is there a single dominant problem (e.g., always low DO) or do different stations fail on different metrics? Can the board see at a glance which stations need intervention?"_]
    ]
  ]
  #v(0.2em)

  Your figure should encode at least two summary metrics (e.g., mean DO and proportion of stressed readings). Consider whether a single multi-variable figure is more effective than multiple simple panels.

  After creating the figure, recommend which station(s) should receive priority attention and explain what the figure reveals that the table did not.
]

#think-box[
  Before plotting, consider:

  - You are comparing a small number of discrete groups (stations) across multiple metrics. What figure types are designed for this? Think about grouped bar charts, dot plots (Cleveland dot plots), radar/spider charts, and heatmaps.
  - If stations are on the y-axis and metrics on the x-axis, would a sorted order (worst to best) make the figure more informative?
  - How do you show two metrics with different scales (e.g., temperature in °C and proportion from 0-1) on the same figure? Consider normalizing, using dual axes, or separate panels.
  - Cleveland dot plots (points on horizontal lines) are often more effective than bar charts for comparisons — why?
  - For a 30-second attention span, should the figure have _more_ information or _less_ information?
]

#pagebreak()

// =============================================================================
// EXERCISE 7
// =============================================================================

#exercise-header(number: 7, title: "Revealing Seasonal Patterns in Legacy Data", difficulty: "Intermediate")

#context-box[
  In Lecture 2 Exercise 7, you reshaped legacy temperature data between wide and long formats. You practiced pivoting a dataset with stations as rows and months as columns into tidy format, and back again. You also tidied a multi-variable wide dataset (with combined column names like `do_jun`, `temp_jul`).

  Now that the legacy data is in tidy format, it can be visualized to check whether the seasonal temperature cycle is consistent across stations. Anomalous patterns — a station that does not warm in summer, or one with an unusually narrow seasonal range — could indicate errors in the historical record that went undetected while the data sat in spreadsheets.
]

#viz-task-box[
  *Create a figure from the reshaped legacy data that compares the seasonal temperature cycle across stations.* Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"Do all monitoring stations follow the same seasonal temperature pattern (warm in summer, cool in winter), or do any stations show anomalous behavior that might indicate errors in the historical record? Which station has the widest seasonal range?"_]
    ]
  ]
  #v(0.2em)

  Use your long-format (tidy) data for this figure. Consider how to distinguish between stations visually. After creating the figure, identify any stations that appear anomalous and explain whether you think the anomaly is real or a data issue.

  Explain why the long (tidy) data format was necessary for creating this figure, and why the wide format would have made it harder.
]

#think-box[
  Before plotting, consider:

  - You want to compare multiple stations across a shared time dimension (months). What figure type allows you to see both the overall seasonal pattern AND deviations from it?
  - If you plot all stations as separate lines on the same axes, how do you ensure each is distinguishable? Color? Line type? Direct labels?
  - Would a heatmap (stations as rows, months as columns, temperature as color) be more effective than a line chart for this comparison? What information does each emphasize?
  - With only 2 stations and 4 months in the legacy dataset, you have very few data points. Does this change your choice of figure type?
  - Why is long format essential for plotting with standard tools? Think about what the `x`, `y`, and `group` aesthetics map to.
]

#pagebreak()

// =============================================================================
// EXERCISE 8
// =============================================================================

#exercise-header(number: 8, title: "Exploring Nutrient-Oxygen Connections", difficulty: "Intermediate")

#context-box[
  In Lecture 2 Exercise 8, you combined three databases: water quality measurements, station metadata (with geographic coordinates and region), and nutrient data (nitrogen and phosphorus). You practiced inner joins, left joins, multi-column merges, and vertical stacking.

  The combined dataset now links nutrient concentrations to water quality measurements and regional metadata. High nutrient loading is hypothesized to fuel algal blooms that deplete oxygen (eutrophication). Visualizing the nutrient--DO relationship across regions tests whether this pattern is visible in the data and whether it varies spatially.
]

#viz-task-box[
  *Create a figure that explores the relationship between nutrient concentrations and dissolved oxygen, incorporating regional information from the station metadata.* Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"Is there visual evidence that higher nitrogen or phosphorus concentrations are associated with lower dissolved oxygen levels? Does this relationship look different in the Main Stem versus the Lower Bay region?"_]
    ]
  ]
  #v(0.2em)

  Your figure should encode at least three variables: a nutrient (x-axis), dissolved oxygen (y-axis), and region (color or shape). If possible, encode a fourth variable (e.g., the other nutrient as point size).

  After creating the figure, discuss whether the pattern you observe is consistent with the eutrophication hypothesis. What caveats would you raise about drawing causal conclusions from this visualization?
]

#think-box[
  Before plotting, consider:

  - You are exploring a _relationship_ between two continuous variables, split by a categorical variable (region). This is a classic use case — what figure type handles this?
  - Your merged dataset may have fewer rows than the original water quality data (if the join was an inner join). Does this affect how you interpret the figure?
  - Encoding four variables (nitrogen, DO, region, phosphorus) in a single scatter plot risks visual overload. What is the maximum number of variables you can encode before the figure becomes unreadable?
  - Recall from Lecture 3, Problem 7 (agriculture and nitrate): a scatter plot with color and size encoding worked well for 4 variables. Could you follow a similar approach?
  - Correlation does not imply causation. What confounding variables might explain a nutrient-DO relationship that is not causal?
]

#pagebreak()

// =============================================================================
// EXERCISE 9
// =============================================================================

#exercise-header(number: 9, title: "Diagnosing Oxygen Stress with Your Toolkit", difficulty: "Intermediate")

#context-box[
  In Lecture 2 Exercise 9, you built a water quality toolkit with reusable functions: `celsius_to_fahrenheit()`, `calc_saturation_deficit()`, `classify_water_quality()`, and `summarize_station()`. You tested these functions with individual values.

  Testing functions on individual values confirms they work correctly, but does not reveal dataset-wide patterns. Applying the saturation deficit calculation to every observation and visualizing the results shows how the gap between measured and saturated oxygen varies with temperature — information that directly informs when to increase monitoring frequency.
]

#viz-task-box[
  *Apply your `calc_saturation_deficit()` function to the full dataset and create a figure that reveals how saturation deficit relates to temperature.* Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"How does the gap between measured and saturated dissolved oxygen change with water temperature? At what temperature range is the oxygen deficit largest, and what does this imply for summer monitoring strategy?"_]
    ]
  ]
  #v(0.2em)

  Use color to encode the water quality classification from `classify_water_quality()`. This way, the figure shows three things at once: the temperature-deficit relationship, the theoretical saturation curve, and the classification status.

  After creating the figure, answer: if you could only afford to send monitoring crews during 3 months of the year, which months would you choose and why?
]

#think-box[
  Before plotting, consider:

  - The saturation deficit depends on both temperature (which determines the theoretical maximum DO) and the actual measured DO. As temperature rises, the theoretical maximum _decreases_ (warm water holds less oxygen). Does this mean the deficit should increase or decrease with temperature?
  - Would it be useful to also plot the theoretical saturation curve (`DO_saturated = 14.62 - 0.3898 × temp`) as a reference line, so the reader can see the "ceiling" for oxygen?
  - Points colored by classification ("Critical", "Stressed", "Heat Stress", "Good") will create a natural visual separation. What colorblind-friendly palette maps intuitively to these categories?
  - With many overlapping points, consider transparency (`alpha`), jittering, or a 2D density representation.
  - This figure connects the _function-building_ exercise to _scientific interpretation_. The functions are tools; the figure is the insight.
]

#pagebreak()

// =============================================================================
// EXERCISE 10
// =============================================================================

#exercise-header(number: 10, title: "Visualizing Uncertainty in Simulations", difficulty: "Advanced")

#context-box[
  In Lecture 2 Exercise 10, you automated monthly processing using loops, accumulated station summaries in a list, simulated hypoxia development with a while loop (DO starting at 8.0, decreasing randomly by 0.1--0.5 each day until dropping below 2.0), and rewrote the iteration using `lapply()`.

  A single simulation run produces one possible outcome, but oxygen depletion is stochastic — running the simulation many times reveals the range of possible trajectories and the uncertainty in the timeline. A risk assessment requires visualizing both the trajectory envelope and the distribution of outcomes to communicate how confident predictions are.
]

#viz-task-box[
  *Create two figures from your hypoxia simulations:*

  *Figure A — Simulation Trajectories:* Run your hypoxia simulation 100 times, recording the full DO trajectory (not just the final day count) for each run. Plot all 100 trajectories on a single figure. Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"What does the 'envelope of possibility' look like for hypoxia development? Do all simulations follow a similar path, or is there wide divergence? At what day do the fastest and slowest simulations reach critical hypoxia?"_]
    ]
  ]
  #v(0.2em)

  *Figure B — Distribution of Outcomes:* From the 100 simulations, extract the number of days to reach critical hypoxia (DO < 2.0). Your figure must answer:

  #v(0.2em)
  #align(center)[
    #block(inset: 0.5em, fill: viz-color.lighten(90%), radius: 4pt, width: 90%)[
      #text(weight: "semibold", fill: viz-color)[_"What is the most likely timeline for a hypoxia event, and how much uncertainty surrounds this estimate? If a manager asked 'how many days do we have before conditions become critical?', what would you answer, and how confident would you be?"_]
    ]
  ]
  #v(0.2em)

  After creating both figures, write a brief risk statement: "Based on 100 simulations, critical hypoxia is expected within [range] days, with a median of [X] days. In [Y]% of simulations, critical conditions developed within [Z] days."
]

#think-box[
  Before plotting, consider:

  - For Figure A (trajectories), you need to store the _entire path_ of each simulation, not just the endpoint. How do you modify the while loop to record DO at every step?
  - With 100 overlapping lines, the figure will be cluttered. How can transparency help? Should you highlight specific trajectories (e.g., fastest, slowest, median)?
  - Adding horizontal reference lines for key DO thresholds (hypoxic at 2.0, stressed at 5.0, adequate at 8.0) helps the reader anchor the trajectories.
  - For Figure B (distribution), what figure type best shows the distribution of a single continuous variable (days to hypoxia)? Consider histograms, density plots, boxplots, or a combination.
  - Would adding a vertical line at the median and shading the interquartile range (25th--75th percentile) make the risk message clearer?
  - The simulation uses `runif(1, 0.1, 0.5)` — the mean daily decrease is 0.3 mg/L. With a total decline of 6 mg/L (8.0 → 2.0), the expected number of days is 6/0.3 = 20. Does your simulation match this expectation?
]

#v(2em)
#align(center)[
  #text(size: 10pt, fill: text-color.lighten(40%))[
    — End of Exercise Document —
  ]
]
