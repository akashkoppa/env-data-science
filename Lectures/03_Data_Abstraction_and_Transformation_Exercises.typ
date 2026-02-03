// =============================================================================
// Lecture 3: Data Abstraction and Transformation Exercises
// Environmental Data Science (ENST431/631)
// Author: Akash Koppa
// =============================================================================

// --- CONFIGURATION & COLORS ---
#let primary-color = rgb("#2d5a27")
#let accent-color = rgb("#457b9d")
#let bg-color = rgb("#fdfdfc")
#let text-color = rgb("#2f2f2f")
#let warning-color = rgb("#c44536")

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
        align(right)[Lecture 3: Data Abstraction & Transformation]
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
#let algorithm-box(body) = { focus-box(title: "🧠 Think About the Data Flow", color: accent-color, body) }
#let hint-box(body) = { focus-box(title: "💡 Tidyverse Syntax Hints", color: primary-color.lighten(10%), body) }

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
  title: "Data Abstraction and Transformation",
  subtitle: "From Raw Data to Analytical Insights with the Tidyverse",
  author: "Instructor: Akash Koppa",
  date: "Lecture 3 — Spring Semester 2026"
)

// --- INTRODUCTION ---
#text(weight: "semibold", size: 12pt, fill: primary-color)[Introduction]
#v(0.3em)

In the previous lecture, you learned to manipulate data using base R—understanding what happens "under the hood." Now we introduce the *tidyverse*, a collection of R packages that provide a more *concise* and *readable* syntax for the same operations. The tidyverse philosophy centers on *tidy data* (each variable is a column, each observation is a row) and *composable functions* connected by the pipe operator.

This exercise set has two parts:

#focus-box(title: "Part 1: Data Abstraction", color: primary-color)[
  Revisit problems from Lecture 2 and solve them using tidyverse functions (`dplyr`, `readr`, `stringr`, `lubridate`). You'll see how the same algorithms translate into more readable code.
]

#focus-box(title: "Part 2: Data Transformation", color: accent-color)[
  Learn to *reshape*, *join*, and *pivot* datasets—critical skills for combining data from multiple sources and preparing data for visualization.
]

#v(0.5em)

#focus-box(title: "Setup Required", color: warning-color)[
  Install the tidyverse: `install.packages("tidyverse")` (run once). Then load it each session with `library(tidyverse)`. This loads `dplyr`, `tidyr`, `readr`, `stringr`, `ggplot2`, and other essential packages.
]

#pagebreak()

// =============================================================================
// PART 1: DATA ABSTRACTION
// =============================================================================

#align(center)[
  #text(1.5em, weight: "bold", fill: primary-color)[Part 1: Data Abstraction with the Tidyverse]
]
#v(0.5em)

#text(size: 10pt, fill: text-color.lighten(20%))[
  These exercises parallel Lecture 2, but now you'll use tidyverse functions. Compare your solutions to see how the same algorithms become more concise.
]

#v(0.5em)

// =============================================================================
// EXERCISE 1: Importing with readr
// =============================================================================

#exercise-header(number: 1, title: "Importing the Chesapeake Bay Data with readr", difficulty: "Beginner")

#context-box[
  The Chesapeake Bay Program has sent you the same `water_quality.csv` file from Lecture 2. This time, use the tidyverse's `readr` package to import it. The `read_csv()` function provides automatic type detection, better handling of missing values, and returns a *tibble* (an improved data frame).
]

*Your Primary Tasks*

Import the data using `read_csv()` and explore its advantages:
- Read the CSV with automatic type detection and examine the column specification message
- Re-import with explicit handling of missing value codes (`-999`, `-9999`) using the `na` argument
- Specify explicit column types using `col_types = cols(...)`
- Use `problems()` to check for any parsing issues
- Compare the output of `glimpse()` to base R's `str()`

#algorithm-box[
  Think about the data import workflow:
  - What information does `read_csv()` provide that `read.csv()` doesn't?
  - How does specifying `na = c("-999", "-9999")` differ from base R's approach?
  - What's the advantage of getting a tibble instead of a data.frame?
]

#hint-box[
  *Import with readr:* `read_csv("filename.csv")` — note the underscore!

  *Column types specification:*
  ```r
  col_types = cols(
    station = col_factor(),
    date = col_date(format = "%Y-%m-%d"),
    temp_c = col_double()
  )
  ```

  *Missing values:* `na = c("", "NA", "N/A", "-999", "-9999")`

  *Check parsing:* `problems(data)` shows any rows that couldn't be parsed

  *Inspect tibble:* `glimpse(data)` shows all columns compactly
]

#pagebreak()

// =============================================================================
// EXERCISE 2: Filtering and Selecting with dplyr
// =============================================================================

#exercise-header(number: 2, title: "Extracting Hypoxia Events with dplyr", difficulty: "Beginner")

#context-box[
  The same fisheries biologist from Lecture 2 needs data on potential hypoxia events. This time, use `dplyr` verbs to extract the data. Notice how the pipe operator `|>` creates a readable, top-to-bottom workflow.
]

*Your Primary Tasks*

Recreate the Lecture 2 data extractions using dplyr:

*For the fisheries biologist:*
- Use `filter()` to select July 23rd observations with DO < 6.0 OR turbidity > 15
- Use `select()` to keep only station, date, DO, and turbidity columns
- Use `arrange()` to sort by DO ascending

*For the researcher:*
- Chain `filter()` calls using `%in%` for stations CB-5.1 and CB-5.2
- Use `between()` for the temperature range 24-26°C
- Use `select()` with renaming: `select(..., dissolved_oxygen = do_mg_l)`

*Bonus:* Use `count()` to see how many observations remain at each step.

#algorithm-box[
  Compare the dplyr approach to base R:
  - How does `filter(data, condition)` compare to `data[condition, ]`?
  - What's more readable: nested conditions or piped operations?
  - Why might `between(x, 24, 26)` be preferred over `x >= 24 & x <= 26`?
]

#hint-box[
  *Filter:* `filter(data, condition1, condition2)` — conditions combined with AND

  *Logical operators:* `&` (and), `|` (or), `!` (not), `%in%` (membership)

  *Select:* `select(data, col1, col2)` or `select(data, -unwanted)`

  *Select helpers:* `starts_with()`, `ends_with()`, `contains()`, `matches()`

  *Rename while selecting:* `select(data, new_name = old_name)`

  *Sort:* `arrange(data, col)` or `arrange(data, desc(col))`

  *Pipe:* `data |> filter(...) |> select(...) |> arrange(...)`
]

#pagebreak()

// =============================================================================
// EXERCISE 3: Transforming with mutate
// =============================================================================

#exercise-header(number: 3, title: "Calculating Derived Variables with mutate", difficulty: "Intermediate")

#context-box[
  The annual report requires the same derived variables as Lecture 2. Use `mutate()` to create them all in a single, readable chain. The `case_when()` function replaces nested `ifelse()` with a cleaner syntax.
]

*Your Primary Tasks*

Create these columns using `mutate()`:
- `temp_f`: Temperature in Fahrenheit
- `do_percent_sat`: DO as percent saturation (measured DO / 8.0 × 100)
- `log_turbidity`: Natural log of turbidity
- `do_status`: Classification using `case_when()`:
  - "Hypoxic" if DO < 2, "Stressed" if DO < 5, "Adequate" if DO < 8, else "Healthy"
  - Handle NA values first!
- `month`: Month extracted from date using `lubridate::month()`
- `day_of_year`: Day of year using `lubridate::yday()`
- `days_since_start`: Days since the earliest date
- `temp_zscore`: Standardized temperature

#algorithm-box[
  Compare `case_when()` to nested `ifelse()`:
  - How does the order of conditions matter in `case_when()`?
  - What does `TRUE ~ "default"` mean as the final condition?
  - Why put `is.na(do_mg_l) ~ "Unknown"` first?
]

#hint-box[
  *Mutate:* `mutate(data, new_col = expr, another = expr)`

  *case_when syntax:*
  ```r
  case_when(
    is.na(do_mg_l) ~ "Unknown",
    do_mg_l < 2 ~ "Hypoxic",
    do_mg_l < 5 ~ "Stressed",
    TRUE ~ "Healthy"  # default
  )
  ```

  *Lubridate:* `year(date)`, `month(date)`, `day(date)`, `yday(date)`, `wday(date)`

  *Date arithmetic:* `as.numeric(date - min(date))` or `difftime()`
]

#pagebreak()

// =============================================================================
// EXERCISE 4: Grouping and Summarizing
// =============================================================================

#exercise-header(number: 4, title: "Station Summaries with group_by and summarize", difficulty: "Intermediate")

#context-box[
  The regional administrator needs station-level statistics. The `group_by() |> summarize()` pattern is one of the most powerful tools in dplyr—it replaces complex `aggregate()` and `ave()` calls with intuitive syntax.
]

*Your Primary Tasks*

*Part 1: Station Summary Report*
- Group by station using `group_by()`
- Calculate: mean temp, mean DO (with `na.rm = TRUE`), max turbidity, count (`n()`), proportion stressed (`mean(do_mg_l < 6, na.rm = TRUE)`)

*Part 2: Station-Relative Analysis (grouped mutate)*
- Add columns showing each station's mean temperature
- Calculate deviation from station mean
- Rank observations within each station by DO (highest = rank 1)
- Remember to `ungroup()` afterward!

*Bonus:* Use `across()` to apply the same function to multiple columns:
```r
summarize(across(c(temp_c, do_mg_l), mean, na.rm = TRUE))
```

#algorithm-box[
  Understand grouped operations:
  - What's the difference between `summarize()` and `mutate()` after `group_by()`?
  - Why does `mean(do_mg_l < 6)` calculate a proportion?
  - What happens if you forget `ungroup()` before the next operation?
]

#hint-box[
  *Group:* `group_by(data, station)` — affects all subsequent operations

  *Summarize:*
  ```r
  group_by(station) |>
    summarize(mean_temp = mean(temp_c, na.rm = TRUE), n = n())
  ```

  *Grouped mutate:* Adds group stats to each row without collapsing
  ```r
  group_by(station) |> mutate(station_mean = mean(temp_c))
  ```

  *Ranking:* `min_rank(desc(do_mg_l))` — highest gets rank 1

  *Ungroup:* `ungroup()` removes grouping for subsequent operations
]

#pagebreak()

// =============================================================================
// EXERCISE 5: String Manipulation
// =============================================================================

#exercise-header(number: 5, title: "Cleaning Station Names with stringr", difficulty: "Intermediate")

#context-box[
  A collaborator sends you data where station names are inconsistent: some are uppercase, some have extra spaces, and some use different separators. The `stringr` package provides consistent, pipe-friendly string operations.

  Sample data:
  #code-block(```
  station_name
  " CB-5.1 "
  "cb-5.2"
  "CB_5.3"
  "Chesapeake Bay 5.4"
  ```)
]

*Your Primary Tasks*

Clean the station names using stringr functions:
- Remove leading/trailing whitespace with `str_trim()`
- Convert all names to uppercase with `str_to_upper()`
- Replace underscores with hyphens using `str_replace()`
- Extract just the numeric portion (e.g., "5.1") with `str_extract()`
- Detect which names contain "Chesapeake" with `str_detect()`

#hint-box[
  *String cleaning:*
  ```r
  mutate(
    clean_name = station_name |>
      str_trim() |>
      str_to_upper() |>
      str_replace("_", "-")
  )
  ```

  *Detection:* `str_detect(x, "pattern")` returns TRUE/FALSE

  *Extraction:* `str_extract(x, "[0-9]+\\.[0-9]+")` extracts first numeric match

  *Replacement:* `str_replace_all(x, "_", "-")` replaces all occurrences
]

#pagebreak()

// =============================================================================
// PART 2: DATA TRANSFORMATION
// =============================================================================

#align(center)[
  #text(1.5em, weight: "bold", fill: accent-color)[Part 2: Data Transformation]
]
#v(0.5em)

#text(size: 10pt, fill: text-color.lighten(20%))[
  Data transformation involves reshaping, joining, and pivoting datasets. These skills are essential for combining data from multiple sources and preparing data for analysis and visualization.
]

#v(0.5em)

// =============================================================================
// EXERCISE 6: Pivoting Longer
// =============================================================================

#exercise-header(number: 6, title: "Reshaping Climate Normals Data", difficulty: "Intermediate")

#context-box[
  The National Weather Service provides climate normals in "wide" format, with months as columns:

  #code-block(```
  station      | jan_temp | feb_temp | mar_temp | ... | dec_temp
  -------------|----------|----------|----------|-----|----------
  SFO_AIRPORT  | 10.2     | 11.5     | 12.8     | ... | 10.5
  SACRAMENTO   | 7.8      | 10.1     | 12.4     | ... | 8.2
  FRESNO       | 6.5      | 9.8      | 13.2     | ... | 7.1
  ```)

  For time series analysis and ggplot2 visualization, you need "long" format with columns: station, month, temperature.
]

*Your Primary Tasks*

- Create the sample data as a tibble (include at least 4 months)
- Use `pivot_longer()` to reshape to long format
- Verify you have (n_stations × n_months) rows
- Convert the month column to an ordered factor for proper plotting
- Create a line plot showing seasonal temperature patterns by station

#algorithm-box[
  Think about data shape:
  - How many observations exist in the wide format? In the long format?
  - Which columns should remain as "ID" columns vs. being pivoted?
  - Why is long format better for ggplot2?
]

#hint-box[
  *Pivot longer:*
  ```r
  pivot_longer(
    cols = jan_temp:dec_temp,  # columns to pivot
    names_to = "month",         # new column for names
    values_to = "temperature"   # new column for values
  )
  ```

  *Column selection:* `cols = starts_with("temp")`, `cols = -station`, `cols = 2:13`

  *Clean names:* `names_prefix = "temp_"` removes prefix from names
]

#pagebreak()

// =============================================================================
// EXERCISE 7: Pivoting Wider
// =============================================================================

#exercise-header(number: 7, title: "Creating a Species Presence Matrix", difficulty: "Intermediate")

#context-box[
  A wildlife survey records species observations in long format:

  #code-block(```
  site    | date       | species     | count
  --------|------------|-------------|------
  Marsh_A | 2025-06-15 | Great_Egret | 12
  Marsh_A | 2025-06-15 | Mallard     | 45
  Marsh_B | 2025-06-15 | Great_Egret | 8
  Marsh_B | 2025-06-15 | Wood_Duck   | 23
  ```)

  For habitat analysis, you need a "wide" presence/absence matrix with species as columns.
]

*Your Primary Tasks*

- Create the sample data as a tibble (at least 3 sites, 4 species)
- Use `pivot_wider()` to create species columns with counts as values
- Handle missing combinations (species not observed at a site) with `values_fill = 0`
- Convert counts to presence/absence (1/0) using `mutate(across(...))`
- Calculate species richness (number of species present) per site

#algorithm-box[
  Think about the transformation:
  - What value should appear when a species wasn't observed at a site?
  - How would you convert counts > 0 to presence (1)?
  - What's the ecological interpretation of the resulting matrix?
]

#hint-box[
  *Pivot wider:*
  ```r
  pivot_wider(
    names_from = species,
    values_from = count,
    values_fill = 0
  )
  ```

  *Convert to presence/absence:*
  ```r
  mutate(across(Great_Egret:Wood_Duck, ~if_else(. > 0, 1, 0)))
  ```

  *Species richness:* `rowSums(select(data, -site))`
]

#pagebreak()

// =============================================================================
// EXERCISE 8: Joining Datasets
// =============================================================================

#exercise-header(number: 8, title: "Combining Water Quality and Watershed Data", difficulty: "Intermediate")

#context-box[
  You have two datasets that need to be combined:

  *water_quality*: Daily measurements (station, date, DO, turbidity)

  *station_info*: Station metadata (station, watershed, drainage_area_km2, land_use)

  To analyze how land use affects water quality, you need to join these tables.
]

*Your Primary Tasks*

- Create sample data for both tables (4 stations, 10 measurements)
- Use `left_join()` to add station metadata to measurements
- Analyze: Does drainage area correlate with turbidity?
- Use `inner_join()` and compare the result to `left_join()`
- Try `anti_join()` to find measurements without matching station info

#algorithm-box[
  Understand join types:
  - `left_join`: Keep all rows from left table, match from right
  - `inner_join`: Keep only rows that match in both tables
  - `anti_join`: Keep rows from left that DON'T match right
  - What happens to rows with no match?
]

#hint-box[
  *Left join:*
  ```r
  left_join(water_quality, station_info, by = "station")
  ```

  *Multiple keys:* `by = c("station", "date")`

  *Different names:* `by = c("station_id" = "station")`

  *Check for mismatches:* `anti_join(measurements, metadata, by = "station")`
]

#pagebreak()

// =============================================================================
// EXERCISE 9: Multi-Source Environmental Data
// =============================================================================

#exercise-header(number: 9, title: "Combining Precipitation and Streamflow Data", difficulty: "Advanced")

#context-box[
  You're analyzing rainfall-runoff relationships using data from two sources:

  *NOAA Precipitation*: Daily rainfall at 3 rain gauges (wide format with gauge columns)

  *USGS Streamflow*: Daily discharge at 2 stream gauges (long format)

  The gauges are in different watersheds, and you need to match each stream gauge to the appropriate rain gauge.
]

*Your Primary Tasks*

- Create sample precipitation data (30 days, 3 gauges in wide format)
- Create sample streamflow data (30 days, 2 gauges in long format)
- Create a lookup table mapping stream gauges to rain gauges
- Pivot precipitation to long format
- Join all three datasets
- Calculate 3-day cumulative rainfall using `lag()` and `mutate()`
- Plot streamflow vs. cumulative rainfall

#hint-box[
  *Cumulative rainfall with lag:*
  ```r
  mutate(
    precip_3day = precip + lag(precip, 1) + lag(precip, 2)
  )
  ```

  *Multiple joins:*
  ```r
  streamflow |>
    left_join(gauge_lookup, by = "stream_gauge") |>
    left_join(precipitation, by = c("rain_gauge", "date"))
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 10: Air Quality Transformation
// =============================================================================

#exercise-header(number: 10, title: "Reshaping EPA Air Quality Data", difficulty: "Advanced")

#context-box[
  EPA air quality monitoring data arrives with multiple pollutants recorded in separate columns, and you need to create faceted time series plots comparing pollutants across monitoring sites.

  #code-block(```
  site     | date       | PM25  | O3    | NO2   | CO
  ---------|------------|-------|-------|-------|-----
  Urban_1  | 2025-01-01 | 12.5  | 0.035 | 25.3  | 0.8
  Urban_1  | 2025-01-02 | 15.2  | 0.042 | 28.1  | 1.1
  Rural_1  | 2025-01-01 | 8.2   | 0.028 | 12.4  | 0.3
  ```)

  Each pollutant has different units and scales, requiring separate y-axes when faceting.
]

*Your Primary Tasks*

- Create sample data (2 sites, 30 days, 4 pollutants)
- Pivot to long format with columns: site, date, pollutant, value
- Calculate daily summaries: mean, max, and exceedance counts per pollutant
- Create faceted time series using `facet_wrap(~pollutant, scales = "free_y")`
- Join with a pollutant_info table containing units and health thresholds

#hint-box[
  *Pivot with names pattern:*
  ```r
  pivot_longer(
    cols = c(PM25, O3, NO2, CO),
    names_to = "pollutant",
    values_to = "concentration"
  )
  ```

  *Faceted plot with free scales:*
  ```r
  ggplot(aes(x = date, y = concentration)) +
    geom_line() +
    facet_wrap(~pollutant, scales = "free_y")
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 11: Groundwater Contamination Analysis
// =============================================================================

#exercise-header(number: 11, title: "Analyzing PFAS Contamination Trends", difficulty: "Advanced")

#context-box[
  California's Groundwater Ambient Monitoring and Assessment (GAMA) program tracks per- and polyfluoroalkyl substances (PFAS) contamination in drinking water wells. The data includes:
  - Multiple PFAS compounds (PFOS, PFOA, PFHxS) measured at each well
  - Multiple samples over time at some wells
  - Coordinates and well depth information

  You need to identify wells exceeding EPA health advisory levels and track contamination trends.
]

*Your Primary Tasks*

- Create sample data: 20 wells, 3 PFAS compounds, 1-3 samples per well
- Pivot longer to analyze all compounds together
- Calculate total PFAS (sum of all compounds) per sample
- Identify wells exceeding thresholds (PFOS > 4 ppt, PFOA > 4 ppt, Total > 70 ppt)
- Pivot wider to create a summary table: one row per well, columns for each compound's max value
- Join with well metadata to analyze contamination by well depth

#hint-box[
  *Summarize across multiple compounds:*
  ```r
  group_by(well_id, sample_date) |>
    summarize(
      total_pfas = sum(concentration),
      n_compounds = n(),
      max_compound = compound[which.max(concentration)]
    )
  ```

  *Pivot wider with summary:*
  ```r
  pivot_wider(
    names_from = compound,
    values_from = concentration,
    values_fn = max  # handles multiple samples
  )
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 12: Ecological Survey Transformation
// =============================================================================

#exercise-header(number: 12, title: "Vegetation Plot Data Transformation", difficulty: "Advanced")

#context-box[
  A meadow restoration project collects vegetation data in a nested format:
  - Multiple plots per site
  - Multiple quadrats per plot
  - Multiple species per quadrat with percent cover estimates

  You need to calculate species composition metrics and compare pre/post restoration conditions.
]

*Your Primary Tasks*

- Create hierarchical sample data: 2 sites × 3 plots × 4 quadrats × 5-10 species
- Calculate species richness and Shannon diversity per quadrat
- Aggregate to plot level using `group_by()` and `summarize()`
- Create a site × species matrix showing mean cover per species
- Compare native vs. invasive species cover across sites

#hint-box[
  *Shannon diversity:* $H' = -sum(p_i times ln(p_i))$ where $p_i$ is proportion of species $i$

  *Calculate in R:*
  ```r
  group_by(plot_id) |>
    mutate(total_cover = sum(cover)) |>
    mutate(p = cover / total_cover) |>
    summarize(shannon = -sum(p * log(p)))
  ```

  *Nested grouping:*
  ```r
  group_by(site, plot) |>
    summarize(across(native_cover:invasive_cover, mean))
  ```
]

#pagebreak()

// =============================================================================
// EXERCISE 13: Time Series Alignment
// =============================================================================

#exercise-header(number: 13, title: "Aligning Multi-Resolution Sensor Data", difficulty: "Advanced")

#context-box[
  Environmental sensors collect data at different intervals:
  - Temperature logger: every 15 minutes
  - Soil moisture: every hour
  - Precipitation: daily totals

  For regression analysis, you need to align these datasets to a common temporal resolution.
]

*Your Primary Tasks*

- Create sample data at different resolutions (7 days of data)
- Aggregate temperature to hourly means
- Expand precipitation to hourly (divide daily total by 24)
- Join all datasets by timestamp
- Handle timezone issues with `lubridate::with_tz()`
- Calculate rolling statistics using `slider` or `zoo` packages

#hint-box[
  *Floor datetime to hour:*
  ```r
  mutate(hour = floor_date(timestamp, "hour"))
  ```

  *Aggregate to hourly:*
  ```r
  group_by(hour) |>
    summarize(temp_mean = mean(temperature))
  ```

  *Rolling mean (with slider):*
  ```r
  mutate(temp_24h = slide_dbl(temp, mean, .before = 23))
  ```
]

#pagebreak()

// =============================================================================
// REFLECTION
// =============================================================================

#v(1em)
#line(length: 100%, stroke: 0.5pt + text-color.lighten(70%))
#v(0.5em)

#text(weight: "semibold", size: 12pt, fill: primary-color)[Reflection: Base R vs. Tidyverse]

#v(0.3em)

After completing these exercises, consider:

+ How does the pipe operator `|>` change the way you think about data analysis?

+ Compare your Lecture 2 solutions (base R) to your Lecture 3 solutions (tidyverse). Which are more readable? Which are more flexible?

+ When might base R approaches be preferable to tidyverse? (Hint: think about dependencies, package versions, and performance with very large datasets)

+ How do `pivot_longer()` and `pivot_wider()` compare to base R's `reshape()`?

+ What data transformation challenges did you encounter that weren't covered in these exercises?

#v(0.5em)

#focus-box(title: "Key Takeaways", color: primary-color)[
  - The tidyverse provides *consistent syntax* across packages
  - Pipes create *readable, sequential workflows*
  - `pivot_longer()` and `pivot_wider()` handle most reshaping needs
  - Joins combine data from multiple sources
  - Grouped operations (`group_by() |> summarize()`) are incredibly powerful
]

#v(0.5em)

#focus-box(title: "Resources", color: accent-color)[
  - *R for Data Science* (2nd ed.): #link("https://r4ds.hadley.nz")[r4ds.hadley.nz]
  - *Environmental Data Science with R*: #link("https://bookdown.org/igisc/EnvDataSci/")[bookdown.org/igisc/EnvDataSci]
  - *dplyr cheatsheet*: #link("https://posit.co/resources/cheatsheets")[posit.co/resources/cheatsheets]
]

#v(2em)
#align(center)[
  #text(size: 10pt, fill: text-color.lighten(40%))[
    — End of Exercise Document —
  ]
]
