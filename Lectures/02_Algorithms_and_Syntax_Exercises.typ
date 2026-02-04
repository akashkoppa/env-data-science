// =============================================================================
// Lecture 2: Algorithms and Syntax — Programming Exercises
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
#let python-hint-box(body) = { focus-box(title: "🐍 Python Syntax Hints", color: rgb("#306998"), body) }

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
  title: "Algorithms and Syntax",
  subtitle: "Programming Exercises for Environmental Data Science",
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
+ *Translate to code*: convert your algorithm into working R or Python code.
+ *Test and verify*: use a proper Integrated Development Environment (IDE) such as RStudio, VS Code, or Spyder.

//The exercises are structured around realistic environmental data science problems: importing monitoring data, cleaning and validating measurements, transforming variables, summarizing by groups, reshaping datasets, and combining data from multiple sources. Each exercise builds on the previous ones, using simulated Chesapeake Bay watershed data throughout. Both R and Python syntax hints are provided for each exercise.

#v(0.5em)

#focus-box(title: "Setup Required", color: warning-color)[
  Before starting, ensure you have R and RStudio (or VS Code / Spyder) installed. If you wish to follow along in Python, install Python 3 with the `pandas` and `numpy` packages. These exercises intentionally use *base R* (and equivalent base Python / pandas) to help you understand algorithms. Later lectures will techniques for more concise data manipulation."
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

#python-hint-box[
  *Creating variables:* `station_id = "CB-5.1"` or `depth = 2` — Python infers types automatically

  *Lists and arrays:* `do_readings = [8.2, 7.8, 7.1, ...]` — or use NumPy: `import numpy as np; do_readings = np.array([8.2, 7.8, ...])`

  *Dictionaries for named data:* `monthly_temps = {"Jan": 4.2, "Feb": 4.5, ...}` — access with `monthly_temps["Jul"]`

  *Statistics (NumPy):* `np.mean()`, `np.std()`, `np.min()`, `np.max()`, `sum()`

  *Boolean indexing (NumPy):* `do_readings[do_readings < 5.0]` — works the same as R

  *Position finding:* `np.argmin()`, `np.argmax()` return index positions
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
- Read the CSV using `read.csv()` and examine the resulting data frame structure
- Re-import the data, explicitly handling the missing value codes (`-999`, `-9999`) using the `na.strings` argument
- Convert column types manually: station as factor, date as Date object, numerics as doubles
- Check for any rows with missing or problematic values
- Count how many missing values exist in the dissolved oxygen and temperature columns
- Verify the data looks correct using inspection functions like `str()`, `head()`, and `summary()`

#algorithm-box[
  Think through the import process:

  - What steps would you take to import a CSV file and verify it loaded correctly?
  - Why might it matter whether "station" is stored as text versus as a categorical variable (factor)?
  - If you wanted dates to be recognized as actual dates (not just text), what would you need to specify?
  - How would you check if there are any problems with the import?
  - What's your algorithm for counting missing values in a specific column?
]

#hint-box[
  *Import:* `read.csv("filename.csv")` — base R function for reading CSV files

  *Check structure:* `str(data)` shows column types and first few values

  *Column type conversion:* `as.factor()`, `as.Date()`, `as.numeric()`, `as.integer()`, `as.character()`

  *Date conversion:* `as.Date(column, format = "%Y-%m-%d")` — specify the format string

  *Missing value handling:* `read.csv(..., na.strings = c("", "NA", "N/A", "-999", "-9999"))`

  *Count NAs:* `sum(is.na(column))` works because TRUE counts as 1

  *Check for problems:* `complete.cases(data)` returns TRUE/FALSE for each row; `which(!complete.cases(data))` gives row numbers with NAs
]

#python-hint-box[
  *Import:* `import pandas as pd` then `df = pd.read_csv("filename.csv", na_values=["-999", "-9999"])`

  *Check structure:* `df.dtypes` shows column types; `df.info()` gives a compact summary

  *Column type conversion:* `df['station'] = df['station'].astype('category')` — `pd.to_datetime(df['date'])` for dates

  *Count NAs:* `df['column'].isna().sum()` — or `df.isna().sum()` for all columns at once

  *Check for problems:* `df.dropna()` removes rows with any NAs; `df[df.isna().any(axis=1)]` shows rows with NAs
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
  *Quick structure:* `str(data)` shows all columns, types, and sample values compactly

  *Full summary:* `summary(data)` gives min, max, mean, median, quartiles, and NA count for numerics

  *Dimensions:* `dim(data)`, `nrow(data)`, `ncol(data)`, `names(data)`

  *Missing data audit:* `sapply(data, function(x) sum(is.na(x)))` applies NA count to every column

  *Unique values:* `unique(data$column)` returns unique values in a column

  *Logical checks:* `any(temp < 0 | temp > 35, na.rm = TRUE)` — returns TRUE if any value is out of range

  *Find problematic rows:* Use logical indexing: `data[data$temp_c < 0 | data$temp_c > 35, ]`

  *Which rows have problems:* `which(data$temp_c < 0 | data$temp_c > 35)` returns row indices
]

#python-hint-box[
  *Quick structure:* `df.info()` shows columns, types, and non-null counts; `df.shape` gives (rows, cols)

  *Full summary:* `df.describe()` gives count, mean, std, min, quartiles, max for numeric columns

  *Column names:* `df.columns` returns list of column names

  *Missing data audit:* `df.isna().sum()` for counts; `df.isna().mean() * 100` for percentages

  *Unique values:* `df['column'].unique()` or `df['column'].nunique()` for count

  *Boolean checks:* `((df['temp_c'] < 0) | (df['temp_c'] > 35)).any()` — parentheses required around each condition

  *Find problematic rows:* `df[(df['temp_c'] < 0) | (df['temp_c'] > 35)]`
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

Address both requests using base R subsetting:

*For the fisheries biologist:*
- Filter to July 23rd observations only using logical indexing
- Further filter to DO < 6.0 OR turbidity > 15
- Select only station, date, DO, and turbidity columns by name
- Sort by DO ascending (lowest/worst first) using `order()`

*For the researcher:*
- Filter for stations CB-5.1 OR CB-5.2 using the `%in%` operator
- AND temperature between 24-26°C (inclusive)
- AND DO is not missing
- Rename `do_mg_l` to `dissolved_oxygen` in your output

*Additional practice:*
- Count how many rows remain after each filter operation using `nrow()`
- Try selecting columns using `grep("^t", names(data))` to get all columns starting with "t"

#algorithm-box[
  Think through the data extraction process:

  - What's the difference between filtering (selecting rows) and selecting (choosing columns)?
  - When combining conditions with AND vs OR, how does the logic differ? Draw a Venn diagram if it helps.
  - Why does the fisheries biologist's request use OR (DO < 6 OR turbidity > 15) while the researcher's uses AND?
  - What's your algorithm for handling the "temperature between 24-26" condition?
  - When sorting by DO to see "worst conditions first," should you sort ascending or descending? What about NAs?
]

#hint-box[
  *Filter rows with logical indexing:* `data[condition, ]` — e.g., `data[data$temp > 24, ]`

  *Logical operators:* `&` (and), `|` (or), `!` (not) — `data[data$temp > 24 & data$temp < 26, ]`

  *Check for NA:* `is.na(x)` returns TRUE if missing; `!is.na(x)` for NOT missing

  *Select columns by name:* `data[, c("col1", "col2")]` or `data[c("col1", "col2")]`

  *Select columns by position:* `data[, 1:3]` selects first three columns

  *Drop columns:* `data[, -which(names(data) == "unwanted")]` or `data$unwanted <- NULL`

  *Rename columns:* `names(data)[names(data) == "old_name"] <- "new_name"`

  *Sort by column:* `data[order(data$col), ]` for ascending; `data[order(-data$col), ]` for descending (numeric) or `data[order(data$col, decreasing = TRUE), ]`
]

#python-hint-box[
  *Filter rows:* `df[df['temp_c'] > 24]` — or `df.query('temp_c > 24')`

  *Logical operators:* `&` (and), `|` (or), `~` (not) — must wrap each condition in parentheses: `df[(df['temp_c'] > 24) & (df['temp_c'] < 26)]`

  *Check membership:* `df[df['station'].isin(['CB-5.1', 'CB-5.2'])]`

  *Check for NA:* `df['col'].isna()` or `df['col'].notna()` for NOT missing

  *Select columns:* `df[['col1', 'col2']]` — or `df.loc[:, ['col1', 'col2']]`

  *Rename columns:* `df.rename(columns={'old_name': 'new_name'})`

  *Sort:* `df.sort_values('col')` for ascending; `df.sort_values('col', ascending=False)` for descending
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

Using base R column assignment (`data$new_col <- ...`), add these new columns to the water quality data:

- `temp_f`: temperature in Fahrenheit (F = C × 9/5 + 32)
- `do_percent_sat`: dissolved oxygen as percent of saturation
- `log_turbidity`: natural log of turbidity (useful for skewed distributions)
- `do_status`: water quality classification using nested `ifelse()` or a custom function
- `month`: extracted from the date
- `day_of_year`: day number within the year (1-365)
- `days_since_start`: days elapsed since the earliest date in the dataset
- `temp_zscore`: standardized temperature ((value - mean) / sd)

#algorithm-box[
  Plan your transformations:

  - What's the formula to convert Celsius to Fahrenheit?
  - In the water quality classification, why does the order of conditions matter? What happens if you check "DO < 5" before "DO < 2"?
  - When checking for NA in nested `ifelse()`, does it matter where you put that check? (Hint: yes!)
  - What date functions would you need to extract month, day of year, or day of week?
  - Write out the z-score formula. What R functions give you mean and standard deviation?
]

#hint-box[
  *Add columns:* `data$new_col <- expression` — e.g., `data$temp_f <- data$temp_c * 9/5 + 32`

  *Conditional classification with ifelse:*
  ```r
  ifelse(is.na(do_mg_l), "Unknown",
    ifelse(do_mg_l < 2, "Hypoxic",
      ifelse(do_mg_l < 5, "Stressed",
        ifelse(do_mg_l < 8, "Adequate", "Healthy"))))
  ```
  Note: Nested ifelse checks conditions in order (first TRUE wins)

  *Date functions (base R):* `format(date, "%Y")` for year, `format(date, "%m")` for month, `format(date, "%j")` for day of year, `weekdays(date)` for weekday name

  *Date arithmetic:* `as.numeric(difftime(date, min(date), units = "days"))` gives days between dates

  *Math functions:* `log()`, `sqrt()`, `abs()`, `round()`, `mean()`, `sd()`
]

#python-hint-box[
  *Add columns:* `df['new_col'] = expression` — e.g., `df['temp_f'] = df['temp_c'] * 9/5 + 32`

  *Conditional classification with np.select:*
  ```python
  conditions = [df['do'].isna(), df['do'] < 2, df['do'] < 5, df['do'] < 8]
  choices = ["Unknown", "Hypoxic", "Stressed", "Adequate"]
  df['status'] = np.select(conditions, choices, default="Healthy")
  ```

  *Date functions (pandas):* `df['date'].dt.month` for month, `df['date'].dt.day_of_year` for day of year, `df['date'].dt.day_name()` for weekday name

  *Date arithmetic:* `(df['date'] - df['date'].min()).dt.days` gives days between dates

  *Math functions:* `np.log()`, `np.sqrt()`, `np.abs()`, `.round()`, `.mean()`, `.std()`
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

Use `aggregate()` or `split()` + `lapply()` to group the data by station and calculate:
- Mean temperature
- Mean DO (handling missing values with `na.rm = TRUE`)
- Maximum turbidity
- Number of observations
- Proportion of observations with DO < 6

*Part 2: Station-relative analysis*

Without collapsing the data, add new columns showing:
- `station_mean_temp`: the average temperature for that observation's station (use `ave()`)
- `temp_vs_station`: how far each temp is from its station average
- `station_do_rank`: rank of each observation within its station by DO (highest DO = rank 1)

The `ave()` function is key here: it applies a function by group and returns a vector the same length as the input.

#algorithm-box[
  Think through the aggregation logic:

  - What's the difference between calculating the mean of ALL observations versus the mean FOR EACH station?
  - If a station has some missing DO values, what happens when you calculate the mean? How do you handle this?
  - How would you calculate "proportion of readings below 6"? (Hint: think about what TRUE/FALSE becomes when averaged)
  - What's the conceptual difference between `aggregate()` (collapses to one row per group) and `ave()` (adds values to each row)?
  - How would you rank observations within each station?
]

#hint-box[
  *Split data by group:* `split(data, data$station)` — returns a list of data frames, one per station

  *Apply function to each group:* Use `lapply()` or `sapply()` with split data
  ```r
  station_list <- split(data, data$station)
  sapply(station_list, function(x) mean(x$temp_c, na.rm = TRUE))
  ```

  *Aggregate function (base R):*
  ```r
  aggregate(cbind(temp_c, do_mg_l) ~ station, data = data,
            FUN = function(x) c(mean = mean(x), n = length(x)))
  ```

  *Proportion trick:* `mean(do_mg_l < 6, na.rm = TRUE)` — TRUE=1, FALSE=0, so mean gives proportion

  *Add group means to each row:* Use `ave()` function
  ```r
  data$station_mean <- ave(data$temp_c, data$station, FUN = mean)
  ```

  *Ranking within groups:* `ave(data$do_mg_l, data$station, FUN = function(x) rank(-x))`
]

#python-hint-box[
  *Group and aggregate:*
  ```python
  df.groupby('station').agg(
      mean_temp=('temp_c', 'mean'),
      mean_do=('do_mg_l', 'mean'),
      n_obs=('temp_c', 'count')
  )
  ```

  *Proportion trick:* `df.groupby('station')['do_mg_l'].apply(lambda x: (x < 6).mean())`

  *Add group stats to each row (like `ave()`):* `df['station_mean'] = df.groupby('station')['temp_c'].transform('mean')`

  *Ranking within groups:* `df['rank'] = df.groupby('station')['do_mg_l'].rank(ascending=False)`
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
temps_wide <- data.frame(
  station = c("CB-5.1", "CB-5.2"),
  jan = c(4.2, 3.8), apr = c(12.5, 11.9),
  jul = c(26.8, 27.1), oct = c(16.3, 15.8)
)
```)

- Use `reshape()` or `stack()` to create columns: station, month, temperature
- Verify you have 8 rows (2 stations × 4 months)

*Part 2: Pivot back to wide*
- Take your long data and pivot wider with stations as columns and months as rows
- When might this format be useful?

*Part 3: Tidy the multi-variable dataset*
#code-block(```r
water_wide <- data.frame(
  station = "CB-5.1",
  do_jun = 6.8, do_jul = 5.2,
  temp_jun = 24.5, temp_jul = 26.8
)
```)
- Reshape to long format to get columns: station, name, value
- Use `strsplit()` to split name into variable and month
- Reshape back to wide so do and temp become separate columns

#algorithm-box[
  Think about data shapes:

  - In the wide temperature data, how many "observations" are there really? (Hint: each station-month combination is one observation)
  - What does it mean to "pivot longer"? Which columns become values, and which stay as identifiers?
  - For the reverse operation (pivot wider), when would you want stations as columns instead of rows?
  - For the messier dataset, what three-step process would tidy it? (Hint: first make it long, then split the combined column names, then reshape variables into columns)
]

#hint-box[
  *Reshape wide to long (base R):*
  ```r
  reshape(data, direction = "long", varying = list(c("jan", "apr", "jul", "oct")),
          v.names = "temperature", timevar = "month", times = c("jan", "apr", "jul", "oct"))
  ```

  *Alternative using stack():* `stack(data[, c("jan", "apr", "jul", "oct")])` — creates a two-column data frame

  *Reshape long to wide (base R):*
  ```r
  reshape(data, direction = "wide", idvar = "month", timevar = "station", v.names = "temperature")
  ```

  *Split a string column:* `strsplit(data$name, "_")` returns a list; use `sapply()` to extract parts
  ```r
  parts <- strsplit(data$name, "_")
  data$variable <- sapply(parts, "[", 1)
  data$month <- sapply(parts, "[", 2)
  ```

  *Tidy data principles:* Each variable = column, each observation = row, each value = cell
]

#python-hint-box[
  *Melt (wide to long):*
  ```python
  pd.melt(df, id_vars='station', var_name='month', value_name='temperature')
  ```

  *Pivot (long to wide):*
  ```python
  df.pivot(index='month', columns='station', values='temperature')
  ```

  *Split a string column:* `df[['variable', 'month']] = df['name'].str.split('_', expand=True)`

  *Pivot table (handles duplicates):* `df.pivot_table(index=['station', 'month'], columns='variable', values='value')`
]

#pagebreak()

// =============================================================================
// EXERCISE 8: Combining Monitoring Databases
// =============================================================================

#exercise-header(number: 8, title: "Combining Monitoring Databases", difficulty: "Intermediate")

#context-box[
  The Chesapeake Bay Program maintains separate databases for different monitoring programs. You've been asked to consolidate data from multiple sources:

  1. Your existing *water quality data* from previous exercises.
  2. A *station metadata table* containing geographic and operational information:

  #code-block(```
  station  | region      | type      | lat     | lon
  ---------|-------------|-----------|---------|--------
  CB-5.1   | Main Stem   | Fixed     | 38.978  | -76.381
  CB-5.2   | Main Stem   | Fixed     | 38.856  | -76.372
  CB-5.3   | Main Stem   | Fixed     | 38.742  | -76.321
  CB-6.1   | Lower Bay   | Rotating  | 37.587  | -76.138
  ```)

  3. A separate *nutrient monitoring dataset* with some overlapping stations and dates:

  #code-block(```
  station  | date       | nitrogen_mg_l | phosphorus_mg_l
  ---------|------------|---------------|----------------
  CB-5.1   | 2025-06-15 | 1.2           | 0.08
  CB-5.2   | 2025-06-15 | 1.5           | 0.12
  CB-6.1   | 2025-06-15 | 0.9           | 0.06
  ```)

  Your supervisor wants all data consolidated into a single comprehensive dataset for analysis.
]

*Your Primary Tasks:*

*Part 1: Create and merge station metadata*

#code-block(```r
station_meta <- data.frame(
  station = c("CB-5.1", "CB-5.2", "CB-5.3", "CB-6.1"),
  region = c("Main Stem", "Main Stem", "Main Stem", "Lower Bay"),
  type = c("Fixed", "Fixed", "Fixed", "Rotating"),
  lat = c(38.978, 38.856, 38.742, 37.587),
  lon = c(-76.381, -76.372, -76.321, -76.138)
)
```)

- Use `merge()` to join station metadata with the water quality data by station
- Compare an inner join (default) vs. a left join (`all.x = TRUE`) — what changes in the row count?
- Identify which stations appear in the metadata but not in the water quality data (and vice versa)

*Part 2: Merge nutrient data*

#code-block(```r
nutrient_data <- data.frame(
  station = c("CB-5.1", "CB-5.2", "CB-6.1"),
  date = as.Date(c("2025-06-15", "2025-06-15", "2025-06-15")),
  nitrogen_mg_l = c(1.2, 1.5, 0.9),
  phosphorus_mg_l = c(0.08, 0.12, 0.06)
)
```)

- Merge nutrient data with water quality data by *both* station AND date
- How many rows match? Why might some rows not match?
- Try a left join to keep all water quality rows even without nutrient matches

*Part 3: Stacking datasets*

- Suppose you receive a second batch of water quality data with the same column structure
- Use `rbind()` to stack the two datasets vertically
- Verify the combined dataset has the expected number of rows
- What happens if the two datasets have different columns?

#algorithm-box[
  Think through the data combination process:

  - What's the difference between *merging* (adding columns from another table) and *stacking* (adding rows)?
  - When you merge two tables, what happens to rows that exist in one table but not the other? Draw a Venn diagram for inner, left, right, and full joins.
  - Why is it important to specify *which columns* to match on?
  - What could go wrong if two datasets have a column with the same name but different meanings?
  - How would you verify that a merge produced the correct result?
]

#hint-box[
  *Inner join (default):* `merge(x, y, by = "station")` — keeps only rows that match in both

  *Left join:* `merge(x, y, by = "station", all.x = TRUE)` — keeps all rows from x

  *Right join:* `merge(x, y, by = "station", all.y = TRUE)` — keeps all rows from y

  *Full join:* `merge(x, y, by = "station", all = TRUE)` — keeps all rows from both

  *Multi-column join:* `merge(x, y, by = c("station", "date"))` — match on multiple columns

  *Stack data frames:* `rbind(df1, df2)` — columns must match exactly

  *Find differences:* `setdiff(x$station, y$station)` — values in x but not y

  *Find overlap:* `intersect(x$station, y$station)` — values in both
]

#python-hint-box[
  *Inner join:* `pd.merge(df1, df2, on='station')` — or `df1.merge(df2, on='station')`

  *Left join:* `pd.merge(df1, df2, on='station', how='left')`

  *Multi-column join:* `pd.merge(df1, df2, on=['station', 'date'])`

  *Stack DataFrames:* `pd.concat([df1, df2], ignore_index=True)`

  *Find differences:* `set(df1['station']) - set(df2['station'])`

  *Find overlap:* `set(df1['station']) & set(df2['station'])`

  *Check merge result:* `df.shape` to verify row/column counts; use `indicator=True` in `pd.merge()` to see which rows matched
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

#python-hint-box[
  *Function structure:*
  ```python
  def my_function(arg1, arg2=default_value):
      result = # calculations
      return result
  ```

  *Arguments with defaults:* `def func(x, threshold=5):` — threshold is optional, defaults to 5

  *Multiple return values:* Return a dictionary
  ```python
  return {"mean_temp": mt, "mean_do": md, "n": n}
  ```

  *Access dict elements:* `result["mean_temp"]` or `result.get("mean_temp")`

  *Call with named arguments:* `my_function(arg2=10, arg1=5)` — order doesn't matter if named
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

*Part 4: Functional iteration with apply family*

Rewrite Part 2 using `lapply()` and `do.call()`:
```r
results <- lapply(unique_stations, function(st) {
  subset_data <- data[data$station == st, ]
  data.frame(station = st, mean_do = mean(subset_data$do_mg_l, na.rm = TRUE))
})
do.call(rbind, results)
```

Compare this approach to the explicit for loop—which do you find more readable?

#algorithm-box[
  Think about iteration patterns:

  - What's the algorithm for "do the same thing for each station"? How would you describe this process to someone?
  - When accumulating results in a loop, why do you need to create an empty container first?
  - What's the difference between a `for` loop (do this N times) and a `while` loop (do this until condition)?
  - In the hypoxia simulation, what could go wrong if you forget to update the DO value inside the loop?
  - How is `lapply()` different from a for loop? What are the trade-offs?
]

#hint-box[
  *For loop:*
  ```r
  for (station in unique(data$station)) {
    # do something with station
    print(paste("Processing", station))
  }
  ```

  *Accumulating results in a list:*
  ```r
  results <- list()
  stations <- unique(data$station)
  for (i in seq_along(stations)) {
    results[[i]] <- # create data frame for station i
  }
  do.call(rbind, results)  # combine list of data frames
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

  *Apply family:* `lapply()` returns list, `sapply()` simplifies to vector/matrix, `vapply()` for type-safe

  *Apply to each group:*
  ```r
  lapply(split(data, data$station), function(df) mean(df$do_mg_l, na.rm = TRUE))
  ```

  *Random numbers:* `runif(n, min, max)` — uniform distribution
]

#python-hint-box[
  *For loop:*
  ```python
  for station in df['station'].unique():
      subset = df[df['station'] == station]
      print(f"Processing {station}")
  ```

  *Accumulating results in a list:*
  ```python
  results = []
  for station in stations:
      results.append({"station": station, "mean_temp": ...})
  pd.DataFrame(results)
  ```

  *While loop:*
  ```python
  import random
  do_level = 8.0
  days = 0
  while do_level >= 2.0:
      do_level -= random.uniform(0.1, 0.5)
      days += 1
  ```

  *List comprehension:* `[mean(subset) for subset in groups]` — concise alternative to loops

  *Random numbers:* `random.uniform(min, max)` or `np.random.uniform(min, max)`
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
  You've now practiced the core workflow: *import* → *tidy* → *transform* → *combine*, plus essential programming skills (functions and iteration). You've done this using both R and Python to understand what happens "under the hood." In upcoming lectures, we'll introduce the tidyverse packages (R) and more advanced pandas patterns (Python) for more concise syntax—but now you'll understand what they're doing internally.
]

#v(0.5em)

#focus-box(title: "Resources for Further Practice", color: accent-color)[
  - *R for Data Science* (2nd ed.): #link("https://r4ds.hadley.nz")[r4ds.hadley.nz] — free online, covers everything in these exercises
  - *RStudio Cheatsheets*: #link("https://posit.co/resources/cheatsheets")[posit.co/resources/cheatsheets] — one-page reference guides
  - *Python Data Science Handbook*: #link("https://jakevdp.github.io/PythonDataScienceHandbook")[jakevdp.github.io/PythonDataScienceHandbook] — free online, covers pandas and NumPy
  - *pandas documentation*: #link("https://pandas.pydata.org/docs")[pandas.pydata.org/docs] — detailed function help
]

#v(2em)
#align(center)[
  #text(size: 10pt, fill: text-color.lighten(40%))[
    — End of Exercise Document —
  ]
]
