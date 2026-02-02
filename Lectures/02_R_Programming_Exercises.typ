// =============================================================================
// Lecture 2: Introduction to the R for Environmental Data Science
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
        align(right)[Lecture 2: Algorithms vs. Syntax]
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
#let algorithm-box(body) = { focus-box(title: "🧠 Think Before You Code", color: accent-color, body) }
#let hint-box(body) = { focus-box(title: "💡 R Syntax Hints", color: primary-color.lighten(10%), body) }

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
  title: "The R Programming Language",
  subtitle: "An Introduction to R for Environmental Data Science",
  author: "Instructor: Akash Koppa",
  date: "Lecture 2 — Spring Semester 2026"
)

// --- INTRODUCTION ---
#text(weight: "semibold", size: 12pt, fill: primary-color)[Introduction]
#v(0.3em)

Programming is not just a collection of syntax rules and commands to memorize. While syntax is important, it is merely the _language_ we use to express our ideas. What truly matters is *algorithmic thinking*: the ability to break down a problem into logical, sequential steps that a computer can execute.

//Consider this analogy: knowing the grammar of a language does not make you a novelist. Similarly, knowing R syntax does not make you a data scientist. The exercises in this document are designed to help you develop both skills in tandem—first thinking through the _algorithm_ (the logical steps), then expressing it in R _syntax_.

#focus-box(title: "Key Distinction", color: primary-color)[
  *Algorithm*: A step-by-step procedure for solving a problem or accomplishing a task. It exists independently of any programming language. You could describe an algorithm in plain English, a flowchart, or pseudocode.

  *Syntax*: The specific rules and structure of a programming language used to implement an algorithm. R has its own syntax; Python has different syntax; but both can implement the same algorithm.
]

#v(0.5em)
#text(weight: "semibold", size: 11pt, fill: accent-color)[How to Use This Document]

For each exercise, follow this workflow:

+ *Read the problem*: carefully and understand what is being asked.
+ *Design the algorithm*: describe the logical steps without any code. What data do you need? What calculations? What decisions? What is the output?
+ *Translate to R syntax*: convert your algorithm into working R code.
+ *Test and verify*: use a proper Integrated Development Environment (IDE) such as RStudio.

The exercises are structured around realistic environmental data science problems: importing monitoring data, cleaning and validating measurements, transforming variables, summarizing by groups, reshaping datasets, and creating visualizations. Each exercise builds on the previous ones, using simulated Chesapeake Bay watershed data throughout.

#v(0.5em)

#focus-box(title: "Setup Required", color: warning-color)[
  Before starting, install the tidyverse: `install.packages("tidyverse")` (run once). Then load it each session with `library(tidyverse)`. The tidyverse includes `ggplot2`, `dplyr`, `tidyr`, `readr`, and other essential packages for data science.
]

#pagebreak()

// =============================================================================
// EXERCISE 1: Variables and Vectors
// =============================================================================

#exercise-header(number: 1, title: "Cataloging a Monitoring Station", difficulty: "Beginner")

#context-box[
  You've been hired as a data technician for the Chesapeake Bay Program. Your first task is to create a digital catalog entry for monitoring station CB-5.1 in the main stem of the Bay. The station manager hands you a paper form with the following information:

  - Station ID: "CB-5.1"
  - Latitude: 38.9784°N
  - Longitude: 76.3811°W
  - Sampling depth: 2 meters (whole number)
  - Currently active: Yes
  - Recent dissolved oxygen readings (mg/L) at 10 depths: 8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5
  - Monthly average water temperatures (°C): Jan 4.2, Feb 4.5, Mar 8.1, Apr 12.5, May 17.3, Jun 22.1, Jul 26.8, Aug 26.5, Sep 22.4, Oct 16.3, Nov 10.7, Dec 6.1

  Your supervisor wants you to store this information in R, calculate some basic statistics, and identify any hypoxic conditions (dissolved oxygen below 5.0 mg/L is considered hypoxic by EPA standards).
]

*Your Primary Tasks*

Create variables for each piece of station metadata with appropriate names. Create vectors for the DO readings and monthly temperatures (with month names). Then:
- Calculate the mean, standard deviation, and CV of dissolved oxygen
- Create a logical vector showing which readings are hypoxic
- Extract only the hypoxic values and count them
- Find which depth position has the lowest oxygen
- Determine how much warmer July is than the annual mean temperature

#algorithm-box[
  Before writing any code, answer these questions in plain English:

  - What are the different *types* of data on this form? (text, numbers, yes/no, lists of numbers)
  - If you store all the station info in a single container, what happens when you mix text with numbers?
  - To find which DO readings are hypoxic, what comparison do you need to make?
  - How would you describe the process of "extracting only the hypoxic values" to someone who doesn't know programming?
  - How do you calculate mean and standard deviation without using in-built functions?
  - What's the algorithm for calculating coefficient of variation (CV)?
]

#hint-box[
  *Creating variables:* `station_id <- "CB-5.1"` or `depth <- 2L` (L makes it an integer)

  *Vectors:* `do_readings <- c(8.2, 7.8, 7.1, 6.4, 5.8, 5.1, 4.2, 3.6, 3.1, 2.5)` — Named vectors: `c(Jan = 4.2, Feb = 4.5, ...)`

  *Type checking:* `class(x)` tells you the data type; mixing types in a vector coerces everything to the most flexible type

  *Statistics:* `mean()`, `sd()`, `min()`, `max()`, `sum()`, `range()`

  *Logical operations:* `do_readings < 5.0` creates TRUE/FALSE vector; `sum(logical_vec)` counts TRUEs

  *Subsetting:* `do_readings[do_readings < 5.0]` extracts values where condition is TRUE

  *Position finding:* `which.min()`, `which.max()`, `which()` return positions, not values
]

#pagebreak()

// =============================================================================
// EXERCISE 2: Importing Data
// =============================================================================

#exercise-header(number: 2, title: "Loading the Summer Monitoring Data", difficulty: "Beginner")

#context-box[
  The Chesapeake Bay Program has sent you a CSV file (`water_quality.csv`) containing water quality measurements from a summer monitoring campaign. The data includes readings from multiple stations over several days in June and July 2025. Before you can analyze the data, you need to import it into R correctly.

  The file contains: station IDs, sampling dates, water temperature (°C), dissolved oxygen (mg/L), pH, and turbidity (NTU). Your supervisor warns you that the data is "messy": some missing values are recorded as `NA`, while others use placeholder codes like `-999` or `-9999`. Additionally, some sensors may have malfunctioned, producing physically impossible readings.

  Your task is to import this data correctly, ensuring R recognizes the various missing value codes and appropriate data types.

]

*Your Primary Tasks:*

Import the data from `water_quality.csv` and:
- Read the CSV using `read_csv()` and examine the automatic type detection messages
- Re-import the data, explicitly handling the missing value codes (`-999`, `-9999`)
- Re-import with explicit column types: station as factor, date as date, numerics as doubles
- Check for any parsing problems
- Count how many missing values exist in the dissolved oxygen and temperature columns
- Verify the data looks correct using inspection functions

#algorithm-box[
  Think through the import process:

  - What steps would you take to import a CSV file and verify it loaded correctly?
  - Why might it matter whether "station" is stored as text versus as a categorical variable (factor)?
  - If you wanted dates to be recognized as actual dates (not just text), what would you need to specify?
  - How would you check if there are any problems with the import?
  - What's your algorithm for counting missing values in a specific column?
]

#hint-box[
  *Import:* `read_csv("filename.csv")` — note the underscore! Base R's `read.csv()` behaves differently

  *Column types:* `col_types = cols(station = col_factor(), date = col_date(), temp_c = col_double())`

  *Check problems:* `problems(data)` shows any parsing issues

  *Available types:* `col_double()`, `col_integer()`, `col_character()`, `col_factor()`, `col_date()`, `col_logical()`, `col_skip()`

  *Missing value handling:* `na = c("", "NA", "N/A", "-999", "-9999")` specifies what strings represent missing data

  *Count NAs:* `sum(is.na(column))` works because TRUE counts as 1
]

#pagebreak()

// =============================================================================
// EXERCISE 3: Data Inspection and Validation
// =============================================================================

#exercise-header(number: 3, title: "Quality Control Audit", difficulty: "Beginner")

#context-box[
  Before any analysis can proceed, the Chesapeake Bay Program requires a quality control (QC) audit of all incoming data. As the data technician, you need to produce a QC report for your supervisor that answers:

  1. What is the structure of the dataset? (rows, columns, variable types)
  2. What are the basic statistics for each water quality parameter?
  3. Are there any missing values, and if so, where?
  4. Are all values physically plausible? (Temperature should be 0-35°C, DO should be 0-15 mg/L, pH should be 6-9)

]

*Your Primary Tasks:*

Using the water quality data from Exercise 2, perform a complete QC audit:

- Apply `glimpse()`, `summary()`, `dim()`, `names()` to understand the data structure
- Create a missing data summary showing count and percentage of NAs for every column
- Define plausible ranges for each environmental variable
- Write validation checks that flag any values outside these ranges
- Filter the data to show only rows with potential problems (if any exist)
- Create a brief summary of your QC findings

#algorithm-box[
  Design your QC audit algorithm:

  - What sequence of inspection steps would give you a complete picture of the data structure?
  - How would you systematically check every column for missing values?
  - For data validation, what logical conditions define "implausible" for each variable?
  - If you find values outside the plausible range, how would you extract just those problematic rows?
  - How would you summarize your findings in a way that's useful for data analysis?
]

#hint-box[
  *Quick structure:* `glimpse(data)` shows all columns, types, and sample values compactly

  *Full summary:* `summary(data)` gives min, max, mean, median, quartiles, and NA count for numerics

  *Dimensions:* `dim(data)`, `nrow(data)`, `ncol(data)`, `names(data)`

  *Missing data audit:* `sapply(data, function(x) sum(is.na(x)))` applies NA count to every column

  *Tidyverse approach:* `data |> summarize(across(everything(), ~sum(is.na(.))))`

  *Unique values:* `distinct(data, column)` or `unique(data$column)`

  *Logical checks:* `any(temp < 0 | temp > 35, na.rm = TRUE)` — returns TRUE if any value is out of range

  *Filter problems:* `filter(data, temp_c < 0 | temp_c > 35 | do_mg_l < 0 | do_mg_l > 15)`
]

#pagebreak()

// =============================================================================
// EXERCISE 4: Filtering and Selecting
// =============================================================================

#exercise-header(number: 4, title: "Responding to a Hypoxia Alert", difficulty: "Intermediate")

#context-box[
  A fisheries biologist reports fish kills in the CB-5.1 area and needs your help extracting relevant data. The biologist requires all records from July 23rd where dissolved oxygen dropped below 6.0 mg/L or turbidity exceeded 15 NTU. The output should include only station, date, DO, and turbidity columns, sorted by DO with the worst (lowest) conditions first.

  A separate request comes from another researcher who needs all observations from stations CB-5.1 or CB-5.2 where the temperature was between 24-26°C and DO data is complete (no missing values).

]

*Your Primary Tasks:*

Address both requests using dplyr:

*For the fisheries biologist:*
- Filter to July 23rd observations only
- Further filter to DO < 6.0 OR turbidity > 15
- Select only station, date, DO, and turbidity columns
- Sort by DO ascending (lowest/worst first)

*For the researcher:*
- Filter for stations CB-5.1 OR CB-5.2
- AND temperature between 24-26°C (inclusive)
- AND DO is not missing
- Rename `do_mg_l` to `dissolved_oxygen` in your output

*Additional practice:*
- Count how many rows remain after each filter operation
- Try selecting columns using `starts_with("t")` to get all columns starting with "t"

#algorithm-box[
  Think through the data extraction process:

  - What's the difference between filtering (selecting rows) and selecting (choosing columns)?
  - When combining conditions with AND vs OR, how does the logic differ? Draw a Venn diagram if it helps.
  - Why does the fisheries biologist's request use OR (DO < 6 OR turbidity > 15) while the researcher's uses AND?
  - What's your algorithm for handling the "temperature between 24-26" condition?
  - When sorting by DO to see "worst conditions first," should you sort ascending or descending? What about NAs?
]

#hint-box[
  *Filter rows:* `filter(data, condition)` — multiple conditions separated by commas are combined with AND

  *Logical operators:* `&` (and), `|` (or), `!` (not) — `filter(data, temp > 24 & temp < 26)`

  *Between shortcut:* `between(temp_c, 24, 26)` is equivalent to `temp_c >= 24 & temp_c <= 26`

  *Check for NA:* `is.na(x)` returns TRUE if missing; `!is.na(x)` for NOT missing

  *Select columns:* `select(data, col1, col2)` or `select(data, -unwanted_col)` to drop

  *Select helpers:* `starts_with()`, `ends_with()`, `contains()`, `matches()`

  *Rename while selecting:* `select(data, new_name = old_name)`

  *Sort:* `arrange(data, col)` for ascending; `arrange(data, desc(col))` for descending
]

#pagebreak()

// =============================================================================
// EXERCISE 5: Transforming Data
// =============================================================================

#exercise-header(number: 5, title: "Preparing Data for the Annual Report", difficulty: "Intermediate")

#context-box[
  The Chesapeake Bay Program's annual report requires several derived variables that don't exist in the raw data:

  1. *Temperature in Fahrenheit*: Some stakeholders prefer imperial units
  2. *Dissolved oxygen percent saturation*: More meaningful than absolute concentration because saturation depends on temperature. Use the simplified formula: `percent_sat = (measured_DO / 8.0) × 100`
  3. *Water quality status classification*: Categorize each observation as
     - "Hypoxic" if DO < 2 mg/L
     - "Stressed" if DO is 2-5 mg/L
     - "Adequate" if DO is 5-8 mg/L
     - "Healthy" if DO ≥ 8 mg/L
     - "Unknown" if DO is missing
  4. *Days since start of monitoring*: For time series analysis
  5. *Temperature anomaly*: How far each reading is from the dataset mean (z-score)
]

*Your Primary Tasks:*

Using `mutate()`, add these new columns to the water quality data:

- `temp_f`: temperature in Fahrenheit (F = C × 9/5 + 32)
- `do_percent_sat`: dissolved oxygen as percent of saturation
- `log_turbidity`: natural log of turbidity (useful for skewed distributions)
- `do_status`: water quality classification using `case_when()`
- `month`: extracted from the date
- `day_of_year`: day number within the year (1-365)
- `days_since_start`: days elapsed since the earliest date in the dataset
- `temp_zscore`: standardized temperature ((value - mean) / sd)

#algorithm-box[
  Plan your transformations:

  - What's the formula to convert Celsius to Fahrenheit?
  - In the water quality classification, why does the order of conditions matter? What happens if you check "DO < 5" before "DO < 2"?
  - When checking for NA in `case_when()`, does it matter where you put that check? (Hint: yes!)
  - What date functions would you need to extract month, day of year, or day of week?
  - Write out the z-score formula. What R functions give you mean and standard deviation?
]

#hint-box[
  *Add columns:* `mutate(data, new_col = expression, another = expression)`

  *Conditional classification:*
  ```r
  case_when(
    is.na(do_mg_l) ~ "Unknown",
    do_mg_l < 2 ~ "Hypoxic",
    do_mg_l < 5 ~ "Stressed",
    do_mg_l < 8 ~ "Adequate",
    TRUE ~ "Healthy"
  )
  ```
  Note: Put NA check FIRST, and conditions are checked in order (first TRUE wins)

  *Date functions:* `year(date)`, `month(date)`, `day(date)`, `yday(date)` for day of year, `wday(date, label = TRUE)` for weekday

  *Date arithmetic:* `as.numeric(date - min(date))` gives days between dates

  *Math functions:* `log()`, `sqrt()`, `abs()`, `round()`, `mean()`, `sd()`
]

#pagebreak()

// =============================================================================
// EXERCISE 6: Grouping and Summarizing
// =============================================================================

#exercise-header(number: 6, title: "Station Performance Comparison", difficulty: "Intermediate")

#context-box[
  The regional administrator needs a comparison report of water quality across monitoring stations. The report must include, for each station: the average temperature, average dissolved oxygen (handling missing data appropriately), maximum turbidity reading, and number of observations. The administrator also wants to know what proportion of readings at each station showed stressed conditions (DO below 6 mg/L).

  Additionally, the analysis should show how each individual reading compares to its station's average, flagging any readings that are unusually high or low for that particular station.

]

*Your Primary Tasks:*

*Part 1: Station summary report*

Group the data by station and calculate:
- Mean temperature
- Mean DO (handling missing values with `na.rm = TRUE`)
- Maximum turbidity
- Number of observations
- Proportion of observations with DO < 6

*Part 2: Station-relative analysis*

Without collapsing the data, add new columns showing:
- `station_mean_temp`: the average temperature for that observation's station
- `temp_vs_station`: how far each temp is from its station average
- `station_do_rank`: rank of each observation within its station by DO (highest DO = rank 1)

Remember to `ungroup()` after grouped operations!

#algorithm-box[
  Think through the aggregation logic:

  - What's the difference between calculating the mean of ALL observations versus the mean FOR EACH station?
  - If a station has some missing DO values, what happens when you calculate the mean? How do you handle this?
  - How would you calculate "proportion of readings below 6"? (Hint: think about what TRUE/FALSE becomes when averaged)
  - What's the conceptual difference between `summarize()` (collapses to one row per group) and `mutate()` with groups (adds columns to each row)?
  - How would you rank observations within each station?
]

#hint-box[
  *Group data:* `group_by(data, station)` — doesn't change appearance but affects subsequent operations

  *Summarize to one row per group:*
  ```r
  data |> group_by(station) |>
    summarize(mean_temp = mean(temp_c),
              mean_do = mean(do_mg_l, na.rm = TRUE),
              max_turb = max(turbidity_ntu),
              n = n())
  ```

  *Proportion trick:* `mean(do_mg_l < 6, na.rm = TRUE)` — TRUE=1, FALSE=0, so mean gives proportion

  *Grouped mutate:* Adds group-level calculations to each row without collapsing
  ```r
  group_by(station) |> mutate(station_mean = mean(temp_c))
  ```

  *Ranking:* `min_rank(desc(do_mg_l))` — highest DO gets rank 1

  *Remove grouping:* `ungroup()` after you're done with grouped operations
]

#pagebreak()

// =============================================================================
// EXERCISE 7: Tidying Data
// =============================================================================

#exercise-header(number: 7, title: "Reformatting Legacy Data", difficulty: "Intermediate")

#context-box[
  A collaborator sends you historical temperature data in a format exported from an old database. The data is in "wide" format—months are spread across columns:

  #code-block(```
  station  | jan  | apr  | jul  | oct
  ---------|------|------|------|-----
  CB-5.1   | 4.2  | 12.5 | 26.8 | 16.3
  CB-5.2   | 3.8  | 11.9 | 27.1 | 15.8
  ```)

  Your analysis tools expect "tidy" data where each variable is a column and each observation is a row. You need to reshape this so you have columns for station, month, and temperature.

  Later, you encounter an even messier dataset where multiple variables are spread wide:

  #code-block(```
  station  | do_jun | do_jul | temp_jun | temp_jul
  ---------|--------|--------|----------|----------
  CB-5.1   | 6.8    | 5.2    | 24.5     | 26.8
  ```)

  This needs to become tidy data with columns: station, month, do, temp.
]

*Your Primary Tasks:*

*Part 1: Create and reshape the temperature data*
#code-block(```r
temps_wide <- tibble(
  station = c("CB-5.1", "CB-5.2"),
  jan = c(4.2, 3.8), apr = c(12.5, 11.9),
  jul = c(26.8, 27.1), oct = c(16.3, 15.8)
)
```)

- Use `pivot_longer()` to create columns: station, month, temperature
- Verify you have 8 rows (2 stations × 4 months)

*Part 2: Pivot back to wide*
- Take your long data and pivot wider with stations as columns and months as rows
- When might this format be useful?

*Part 3: Tidy the multi-variable dataset*
#code-block(```r
water_wide <- tibble(
  station = "CB-5.1",
  do_jun = 6.8, do_jul = 5.2,
  temp_jun = 24.5, temp_jul = 26.8
)
```)
- Pivot longer to get columns: station, name, value
- Use `separate()` to split name into variable and month
- Pivot wider so do and temp become separate columns

#algorithm-box[
  Think about data shapes:

  - In the wide temperature data, how many "observations" are there really? (Hint: each station-month combination is one observation)
  - What does it mean to "pivot longer"? Which columns become values, and which stay as identifiers?
  - For the reverse operation (pivot wider), when would you want stations as columns instead of rows?
  - For the messier dataset, what two-step process would tidy it? (Hint: first make it long, then separate the combined column names, then make the variables into columns)
]

#hint-box[
  *Pivot to long:*
  ```r
  pivot_longer(data, cols = jan:oct,
               names_to = "month", values_to = "temperature")
  ```

  *Select columns to pivot:* `cols = c(jan, apr)`, `cols = jan:oct`, `cols = -station` (all except)

  *Pivot to wide:*
  ```r
  pivot_wider(data, names_from = station, values_from = temperature)
  ```

  *Separate combined names:*
  ```r
  separate(data, col = name, into = c("variable", "month"), sep = "_")
  ```

  *Tidy data principles:* Each variable = column, each observation = row, each value = cell
]

#pagebreak()

// =============================================================================
// EXERCISE 8: Data Visualization
// =============================================================================

#exercise-header(number: 8, title: "Creating the Quarterly Visualization Report", difficulty: "Intermediate")

#context-box[
  The communications team needs visualizations for the quarterly stakeholder meeting. They have requested four specific plots:

  1. *Temperature-DO relationship plot*: A scatter plot showing how dissolved oxygen relates to temperature, with points colored by station, a trend line, and clearly labeled axes.

  2. *Turbidity distribution comparison*: A comparison of turbidity distributions across stations using histograms, density plots, and boxplots to determine which visualization best tells the story.

  3. *DO time series with threshold*: A time series plot of dissolved oxygen for each station, with a horizontal reference line at 5.0 mg/L (the stress threshold) to identify which stations are struggling.

  4. *Station comparison panels*: A faceted temperature-DO scatter plot with each station in its own panel for pattern comparison.

]

*Your Primary Tasks:*

Build these visualizations using ggplot2:

*Plot 1: Temperature vs DO scatter plot*
- Map temperature to x-axis, DO to y-axis
- Color points by station
- Add a smoothed trend line with `geom_smooth()`
- Add proper labels with `labs()`

*Plot 2: Turbidity distributions*
- Create a histogram with `geom_histogram(bins = 10)`
- Create a density plot with `geom_density()`
- Create boxplots by station with `geom_boxplot()`
- Which visualization is most informative for this data?

*Plot 3: Time series with threshold*
- Plot DO over date as lines, grouped and colored by station
- Add points at each observation
- Add horizontal reference line at DO = 5.0 using `geom_hline()`

*Plot 4: Faceted comparison*
- Scatter plot of temp vs DO
- Use `facet_wrap(~station)` for separate panels
- Apply `theme_minimal()` and adjust transparency

#algorithm-box[
  Think about visualization design:

  - For the temperature-DO relationship, what type of plot best shows the relationship between two continuous variables?
  - What does mapping color to station accomplish? How is this different from faceting?
  - When comparing distributions, what does a boxplot show that a histogram doesn't? What does a density plot show that both miss?
  - In ggplot's "grammar of graphics," what are the roles of: data, aesthetics (aes), and geoms?
  - Why add a reference line at DO = 5.0? How does this context help interpretation?
]

#hint-box[
  *Basic structure:* `ggplot(data, aes(x = temp_c, y = do_mg_l)) + geom_point()`

  *Add aesthetics:* `aes(x = ..., y = ..., color = station, size = ..., alpha = ...)`

  *Common geoms:* `geom_point()`, `geom_line()`, `geom_histogram()`, `geom_density()`, `geom_boxplot()`, `geom_smooth()`

  *Layers stack with +:* `ggplot(...) + geom_point() + geom_smooth() + labs(...)`

  *Labels:* `labs(title = "...", x = "Temperature (°C)", y = "DO (mg/L)", color = "Station")`

  *Reference lines:* `geom_hline(yintercept = 5)`, `geom_vline(xintercept = ...)`

  *Faceting:* `facet_wrap(~station)` or `facet_grid(row_var ~ col_var)`

  *Themes:* `theme_minimal()`, `theme_bw()`, `theme_classic()`
]

#pagebreak()

// =============================================================================
// EXERCISE 9: Writing Functions
// =============================================================================

#exercise-header(number: 9, title: "Building a Water Quality Toolkit", difficulty: "Intermediate")

#context-box[
  You find yourself repeatedly writing the same code: converting temperatures, calculating saturation deficits, classifying water quality. Your supervisor recommends creating a set of reusable functions so that anyone in the office can use your tools, reducing copy-paste errors and improving reproducibility.

  The water quality toolkit should include the following functions:

  1. *Temperature conversion functions*: Convert between Celsius and Fahrenheit
  2. *Saturation deficit calculator*: Given measured DO and temperature, calculate how far the water is from being fully saturated with oxygen. Use: `DO_saturated = 14.62 - (0.3898 × temperature)`
  3. *Water quality classifier*: Given DO and temperature, return a status with customizable thresholds
  4. *Station summarizer*: Given a dataset and station ID, return a complete summary
]

*Your Tasks:*

Create these functions:

*celsius_to_fahrenheit(temp_c)* and *fahrenheit_to_celsius(temp_f)*
- Verify: `fahrenheit_to_celsius(celsius_to_fahrenheit(25))` should return 25

*calc_saturation_deficit(do_measured, temperature)*
- Returns how many mg/L below saturation the water is
- Test with DO = 6.5, temp = 25°C

*classify_water_quality(do, temp, hypoxic_threshold = 2.0, stress_threshold = 5.0)*
- Returns "Critical" if DO < hypoxic threshold
- Returns "Stressed" if DO < stress threshold
- Returns "Heat Stress" if temp > 28°C
- Returns "Good" otherwise
- Test with different threshold values

*summarize_station(data, station_id)*
- Filters to the specified station
- Returns a named list with: mean_temp, mean_do, n_observations, hypoxic_count

#algorithm-box[
  Think about function design:

  - What is the input and output of each function? Write it out explicitly.
  - For temperature conversion, how would you test that your function is correct? (Hint: 0°C = 32°F, 100°C = 212°F)
  - Why use default argument values for thresholds in the classifier? When would someone want to override them?
  - In the station summarizer, what happens if someone passes a station ID that doesn't exist in the data?
  - How do you return multiple values from a function?
]

#hint-box[
  *Function structure:*
  ```r
  my_function <- function(arg1, arg2 = default_value) {
    result <- # calculations using arg1, arg2
    return(result)
  }
  ```

  *Arguments with defaults:* `function(x, threshold = 5)` — threshold is optional, defaults to 5

  *Return statement:* `return(value)` — or just put the value as the last line

  *Multiple return values:* Use a named list
  ```r
  return(list(mean_temp = mt, mean_do = md, n = n))
  ```

  *Access list elements:* `result$mean_temp` or `result[["mean_temp"]]`

  *Call with named arguments:* `my_function(arg2 = 10, arg1 = 5)` — order doesn't matter if named
]

#pagebreak()

// =============================================================================
// EXERCISE 10: Loops and Iteration
// =============================================================================

#exercise-header(number: 10, title: "Automating the Monthly Processing", difficulty: "Advanced")

#context-box[
  Each month, you receive data from multiple monitoring stations that needs the same processing: calculate summary statistics, flag quality issues, and generate a report. You've been doing this manually for each station, copying and pasting code. It's tedious and error-prone.

  Your tasks:
  1. Process each station in a loop and print a status message
  2. Build a summary table for all stations without copying code
  3. Simulate a hypoxia event to understand oxygen dynamics
  4. Learn the modern `purrr` approach that many R programmers prefer

  This is about working smarter: write the code once, apply it many times.
]

*Your Tasks:*

*Part 1: For loop basics*

Write a loop that iterates through each unique station and prints:
"Station [ID]: Mean temperature = [value]°C"

*Part 2: Accumulating results*

- Create an empty list: `station_summaries <- list()`
- Loop through each station
- Calculate summary stats (mean temp, mean DO, count) and store as a data frame in the list
- Combine all results with `bind_rows(station_summaries)`

*Part 3: Simulation with while loop*

Simulate hypoxia development:
- Start with DO = 8.0 mg/L
- Each day, DO decreases by a random amount: `runif(1, 0.1, 0.5)`
- Count days until DO drops below 2.0 (critical hypoxia)
- Run this simulation 5 times—do you get different results? Why?

*Part 4: Functional iteration with purrr*

Rewrite Part 2 using `purrr::map_dfr()`:
```r
map_dfr(unique_stations, ~filter(data, station == .x) |> summarize(...))
```

Compare this approach to the explicit for loop—which do you find more readable?

#algorithm-box[
  Think about iteration patterns:

  - What's the algorithm for "do the same thing for each station"? How would you describe this process to someone?
  - When accumulating results in a loop, why do you need to create an empty container first?
  - What's the difference between a `for` loop (do this N times) and a `while` loop (do this until condition)?
  - In the hypoxia simulation, what could go wrong if you forget to update the DO value inside the loop?
  - How is `map()` different from a for loop? What are the trade-offs?
]

#hint-box[
  *For loop:*
  ```r
  for (station in unique(data$station)) {
    # do something with station
    print(paste("Processing", station))
  }
  ```

  *Accumulating results:*
  ```r
  results <- list()
  for (i in seq_along(stations)) {
    results[[i]] <- # create data frame for station i
  }
  bind_rows(results)
  ```

  *While loop:*
  ```r
  do_level <- 8.0
  days <- 0
  while (do_level >= 2.0) {
    do_level <- do_level - runif(1, 0.1, 0.5)
    days <- days + 1
  }
  ```

  *Map functions:* `map()` returns list, `map_dbl()` returns numeric, `map_dfr()` returns data frame

  *Anonymous functions:* `~.x + 1` is shorthand for `function(x) x + 1`

  *Random numbers:* `runif(n, min, max)` — uniform distribution
]

#pagebreak()

// =============================================================================
// REFLECTION
// =============================================================================

#v(1em)
#line(length: 100%, stroke: 0.5pt + text-color.lighten(70%))
#v(0.5em)

#text(weight: "semibold", size: 12pt, fill: primary-color)[Reflection: Algorithms vs. Syntax]

#v(0.3em)

After completing these exercises, consider the following questions:

+ Which exercises did you find easier to describe algorithmically than to code in R? What does this tell you about where you need more practice?

+ Were there exercises where you knew the R syntax but struggled to articulate the underlying algorithm? What does this reveal about your understanding?

+ How did thinking through the algorithm first change your approach to writing code? Did it reduce errors?

+ In which exercises could you have used multiple different algorithms to solve the same problem? How would you choose between them?

+ When you encountered an error in your code, was the problem usually in your algorithm (logic error) or your syntax (typo, wrong function)? How did you diagnose and fix it?

#v(0.5em)

#focus-box(title: "The Data Science Workflow", color: primary-color)[
  You've now practiced the complete workflow: *import* → *tidy* → *transform* → *visualize*, plus essential programming skills (functions and iteration). These techniques form the foundation of all data analysis in R. In upcoming lectures, we'll apply these skills to real Chesapeake Bay datasets with thousands of observations.
]

#v(0.5em)

#focus-box(title: "Resources for Further Practice", color: accent-color)[
  - *R for Data Science* (2nd ed.): #link("https://r4ds.hadley.nz")[r4ds.hadley.nz] — free online, covers everything in these exercises
  - *RStudio Cheatsheets*: #link("https://posit.co/resources/cheatsheets")[posit.co/resources/cheatsheets] — one-page reference guides
  - *Tidyverse documentation*: #link("https://www.tidyverse.org")[tidyverse.org] — detailed function help
]

#v(2em)
#align(center)[
  #text(size: 10pt, fill: text-color.lighten(40%))[
    — End of Exercise Document —
  ]
]
