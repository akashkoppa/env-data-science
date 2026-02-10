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

// Discussion prompt block (for interactive class)
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

// Compact blocks for visualization slides (tighter padding)
#let compact-block(title: "Note", color: accent-color, body) = {
  rect(
    fill: color.lighten(90%),
    stroke: (left: 3pt + color),
    width: 100%,
    inset: 0.6em,
    radius: 4pt,
    [
      #text(weight: "bold", fill: color, size: 0.9em, title) \
      #set text(size: 0.8em)
      #body
    ]
  )
}

#let compact-discuss(title: "What Do You See?", body) = {
  rect(
    fill: discuss-color.lighten(92%),
    stroke: (left: 3pt + discuss-color),
    width: 100%,
    inset: 0.6em,
    radius: 4pt,
    [
      #text(weight: "bold", fill: discuss-color, size: 0.9em, title) \
      #set text(size: 0.8em)
      #body
    ]
  )
}

// Data preview table styling
#let data-table(..args) = {
  set text(size: 0.75em, font: "DejaVu Sans Mono")
  table(
    inset: 0.4em,
    stroke: 0.5pt + luma(200),
    fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
    ..args
  )
}


// --- DOCUMENT START ---

#show: body => setup-theme(
  title: "Data Visualization and Interpretation",
  author: "Instructor: Akash Koppa",
  date: "Lecture 3 of Spring Semester 2026",
  body
)


// =============================================================================
// AGENDA & FORMAT
// =============================================================================

#lecture-slide(title: "Today's Agenda")[
  #focus-block(title: "Interactive Problem-Based Class", color: primary-color)[
    Today we explore *8 real environmental problems* using data visualization. For each problem, we will work through three stages together.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    focus-block(title: "1. Raw Data", color: primary-color)[
      We see the question and a *naive visualization* of the raw data. Can it answer the question?
    ],
    discuss-block(title: "2. Discussion")[
      _What transformation or different plot would actually answer the question?_
    ],
    focus-block(title: "3. Better Viz", color: accent-color)[
      We see the *transformed visualization* and discuss what it reveals.
    ],
  )

  #v(0.5em)

  #focus-block(title: "The 8 Problems", color: accent-color)[
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.5em,
      [1. Is Earth getting warmer?],
      [5. How fast are we losing the Amazon?],
      [2. Which sectors drive climate change?],
      [6. Can we compare climate indicators?],
      [3. Is the air safe to breathe?],
      [7. Does agriculture pollute our waterways?],
      [4. Does warmer water kill coral reefs?],
      [8. Are droughts getting worse?],
    )
  ]
]


// =============================================================================
// PROBLEM 1: Is Earth Getting Warmer?
// =============================================================================

#lecture-slide(title: "Problem 1: Is Earth Getting Warmer?")[
  #focus-block(title: "The Question", color: primary-color)[
    Climate scientists measure the *global mean surface temperature* each year. Given 125 years of annual measurements, *can we determine if and when the planet started warming?*
  ]

  #v(0.4em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob1_temperature_raw.png", width: 100%),
    [
      #compact-block(title: "The Raw Data", color: primary-color)[
        A simple time series of *absolute temperature* (~14\u{00b0}C). The y-axis spans 12--16\u{00b0}C.
      ]
      #v(0.1em)
      #compact-discuss(title: "Can You Answer the Question?")[
        - Is the planet warming? By how much?
        - When did warming start?
        - Why is it *hard to tell* from this plot?
        - What would you *change* to make the signal clearer?
      ]
    ]
  )
]


#lecture-slide(title: "Problem 1: What Would You Do Differently?")[
  #discuss-block(title: "Class Discussion")[
    The raw temperature plot is *uninformative* because the warming signal (~1\u{00b0}C over 125 years) is tiny compared to the absolute baseline (~14\u{00b0}C). The y-axis hides the trend.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "The Transformation", color: primary-color)[
        - Convert absolute temperature to *anomalies*: subtract the mean of a baseline period (1951--1980).
        - Now the y-axis is centered on zero and spans just \u{00b1}1.5\u{00b0}C.
        - The warming trend becomes *unmistakable*.
      ]
    ],
    [
      #focus-block(title: "Visualization Improvements", color: accent-color)[
        - *Color encode* the bars: blue = cool, red = warm.
        - Add a *10-year running mean* to reveal the long-term trend.
        - Add a *zero reference line* to separate warm from cool years.
      ]
    ]
  )
]


#lecture-slide(title: "Problem 1: Global Temperature Anomaly")[
  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob1_temperature.png", width: 100%),
    [
      #compact-block(title: "Visualization Choice", color: primary-color)[
        *Bar chart* with color encoding (blue = cool, red = warm) plus a *10-year running mean* to reveal the long-term trend.
      ]
      #v(0.1em)
      #compact-discuss()[
        - When did anomalies become consistently positive?
        - Where does the trend accelerate?
        - Why use a running mean instead of a straight line?
      ]
      #v(0.1em)
      #compact-block(title: "Key Insight", color: accent-color)[
        Warming accelerated sharply after ~1980. The last decade has no cool years at all.
      ]
    ]
  )
]


// =============================================================================
// PROBLEM 2: Which Sectors Drive Climate Change?
// =============================================================================

#lecture-slide(title: "Problem 2: Which Sectors Drive Climate Change?")[
  #focus-block(title: "The Question", color: primary-color)[
    Global greenhouse gas emissions come from many economic sectors. Understanding *which sectors contribute the most* is essential for prioritizing climate policy. Given the percentage breakdown, *how do we communicate the ranking effectively?*
  ]

  #v(0.2em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob2_emissions_raw.png", width: 100%, height: 14em, fit: "contain"),
    [
      #compact-block(title: "The Raw Data", color: primary-color)[
        A *pie chart* showing all 7 sectors as angular slices.
      ]
      #v(0.1em)
      #compact-discuss(title: "Can You Answer the Question?")[
        - Which sector is largest? By how much?
        - Can you rank Industry vs. Agriculture vs. Transport?
        - Why is it *hard to compare* similar-sized slices?
        - What plot type would make ranking *easy*?
      ]
    ]
  )
]


#lecture-slide(title: "Problem 2: What Would You Do Differently?")[
  #discuss-block(title: "Class Discussion")[
    Pie charts force us to compare *angles and areas*---humans are bad at this. Slices of 21%, 18.4%, and 16.2% look nearly identical. The ranking is ambiguous.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "The Transformation", color: primary-color)[
        - Switch from angular encoding (pie) to *length encoding* (bar chart).
        - *Sort* bars by value so the ranking is immediately visible.
        - Use *horizontal* bars so labels are easy to read.
      ]
    ],
    [
      #focus-block(title: "Visualization Improvements", color: accent-color)[
        - Place *value labels* at bar ends for direct reading.
        - Use *color intensity* to group high, medium, and low contributors.
        - Remove chart clutter (gridlines, frames).
      ]
    ]
  )
]


#lecture-slide(title: "Problem 2: Emissions by Sector")[
  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob2_emissions.png", width: 100%),
    [
      #compact-block(title: "Visualization Choice", color: primary-color)[
        *Horizontal bar chart*, sorted by value. Labels placed at bar ends for direct reading.
      ]
      #v(0.1em)
      #compact-discuss()[
        - Which sector dominates?
        - Why is a sorted bar chart better than a pie chart here?
        - What policy priorities does this suggest?
      ]
      #v(0.1em)
      #compact-block(title: "Key Insight", color: accent-color)[
        Electricity and industry together account for nearly half of all emissions. No single sector can be ignored.
      ]
    ]
  )
]


// =============================================================================
// PROBLEM 3: Is the Air Safe to Breathe?
// =============================================================================

#lecture-slide(title: "Problem 3: Is the Air Safe to Breathe?")[
  #focus-block(title: "The Question", color: primary-color)[
    Fine particulate matter (PM#sub[2.5]) causes millions of premature deaths annually. The WHO guideline is *15 #text(size: 0.9em)[\u{03bc}g/m\u{00b3}]*. Given daily measurements from 6 cities over one year, *which cities are safe and which are not?*
  ]

  #v(0.4em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob3_air_quality_raw.png", width: 100%),
    [
      #compact-block(title: "The Raw Data", color: primary-color)[
        A *bar chart of annual means* for each city. 365 daily measurements reduced to a single number.
      ]
      #v(0.1em)
      #compact-discuss(title: "Can You Answer the Question?")[
        - Which cities exceed the WHO limit on average?
        - But how often does Delhi hit 100+ \u{03bc}g/m\u{00b3}? You can't tell.
        - Does Stockholm *ever* have bad days?
        - What information is *hidden* by the mean?
      ]
    ]
  )
]


#lecture-slide(title: "Problem 3: What Would You Do Differently?")[
  #discuss-block(title: "Class Discussion")[
    The bar chart of means *hides variability*. Delhi's mean of ~53 hides days at 150+. Stockholm's mean of ~7 hides occasional spikes. For health, the *extremes* matter as much as the average.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "The Transformation", color: primary-color)[
        - Instead of reducing 365 values to 1 mean, show the *full distribution*.
        - Use *boxplots* to display: median, quartiles, whiskers, and outliers.
        - Every extreme day is now visible as an individual point.
      ]
    ],
    [
      #focus-block(title: "Visualization Improvements", color: accent-color)[
        - Add a *WHO guideline reference line* (15 \u{03bc}g/m\u{00b3}).
        - Use *color* to distinguish cities.
        - Outlier points reveal *acute health risk days* that the mean hides.
      ]
    ]
  )
]


#lecture-slide(title: "Problem 3: Air Quality Across Cities")[
  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob3_air_quality.png", width: 100%),
    [
      #compact-block(title: "Visualization Choice", color: primary-color)[
        *Boxplots* showing median, quartiles, whiskers, and outliers. A dashed reference line marks the WHO guideline.
      ]
      #v(0.1em)
      #compact-discuss()[
        - Which cities have medians above the WHO limit?
        - Why is Delhi's box so much wider than Stockholm's?
        - What do the outlier points represent physically?
      ]
      #v(0.1em)
      #compact-block(title: "Key Insight", color: accent-color)[
        Variability matters as much as the mean. Beijing and Delhi have extreme outlier days that pose acute health risks.
      ]
    ]
  )
]


// =============================================================================
// PROBLEM 4: Does Warmer Water Kill Coral?
// =============================================================================

#lecture-slide(title: "Problem 4: Does Warmer Water Kill Coral Reefs?")[
  #focus-block(title: "The Question", color: primary-color)[
    Corals expel their symbiotic algae when sea surface temperatures (SST) rise---a process called *bleaching*. Researchers measured SST anomalies and bleaching at 80 reef sites. *Is there a relationship, and is it linear?*
  ]

  #v(0.2em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob4_coral_bleaching_raw.png", width: 100%),
    [
      #compact-block(title: "The Raw Data", color: primary-color)[
        Two *separate bar charts*: SST anomaly per site (left) and bleaching % per site (right).
      ]
      #v(0.1em)
      #compact-discuss(title: "Can You Answer the Question?")[
        - Is there a relationship between SST and bleaching?
        - Can you tell from these two separate plots?
        - What is missing when variables are shown *independently*?
        - How would you show the *connection* between them?
      ]
    ]
  )
]


#lecture-slide(title: "Problem 4: What Would You Do Differently?")[
  #discuss-block(title: "Class Discussion")[
    Showing two variables in *separate plots* makes the relationship invisible. You cannot visually match Site 45's high SST to its high bleaching. The connection between cause and effect is lost.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "The Transformation", color: primary-color)[
        - *Combine both variables into one plot*: SST on x-axis, bleaching on y-axis.
        - A *scatter plot* is the natural choice for two continuous variables.
        - Now each point encodes *both* measurements simultaneously.
      ]
    ],
    [
      #focus-block(title: "Visualization Improvements", color: accent-color)[
        - Add a *quadratic fit* to reveal non-linearity.
        - Use *color gradient* to encode bleaching severity.
        - Mark the *critical threshold* (~1\u{00b0}C) with a vertical reference line.
      ]
    ]
  )
]


#lecture-slide(title: "Problem 4: Coral Bleaching vs. Temperature")[
  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob4_coral_bleaching.png", width: 100%),
    [
      #compact-block(title: "Visualization Choice", color: primary-color)[
        *Scatter plot* with a quadratic fit and color gradient encoding bleaching severity. A vertical reference marks the ~1\u{00b0}C threshold.
      ]
      #v(0.1em)
      #compact-discuss()[
        - Is the relationship linear or non-linear?
        - What happens beyond the 1\u{00b0}C threshold?
        - What does the color gradient add beyond the y-axis?
      ]
      #v(0.1em)
      #compact-block(title: "Key Insight", color: accent-color)[
        Bleaching accelerates non-linearly. Beyond ~1.5\u{00b0}C, most reefs experience severe (>50%) bleaching.
      ]
    ]
  )
]


// =============================================================================
// PROBLEM 5: How Fast Are We Losing the Amazon?
// =============================================================================

#lecture-slide(title: "Problem 5: How Fast Are We Losing the Amazon?")[
  #focus-block(title: "The Question", color: primary-color)[
    The Brazilian Amazon has experienced decades of deforestation. Brazil's PRODES satellite monitoring measures forest area. *Can we see the impact of policy interventions directly in the data?*
  ]

  #v(0.4em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob5_deforestation_raw.png", width: 100%),
    [
      #compact-block(title: "The Raw Data", color: primary-color)[
        *Total remaining forest area* over time. The y-axis starts at 0 and goes to 6 million km\u{00b2}.
      ]
      #v(0.1em)
      #compact-discuss(title: "Can You Answer the Question?")[
        - Did any policy intervention have an impact?
        - When was deforestation fastest?
        - Why does this plot make the problem look *small*?
        - What would you plot *instead* of the total?
      ]
    ]
  )
]


#lecture-slide(title: "Problem 5: What Would You Do Differently?")[
  #discuss-block(title: "Class Discussion")[
    The total remaining area (~5.5M to ~5.0M km\u{00b2}) looks like a gentle slope. The *rate of change*---not the total stock---is what reveals policy impact. A ~500,000 km\u{00b2} loss looks trivial against 5.5 million.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "The Transformation", color: primary-color)[
        - Plot *annual deforestation rate* (km\u{00b2}/year) instead of the cumulative total.
        - Now year-to-year changes are dramatic: 28,000 vs. 4,500 km\u{00b2}.
        - Policy impacts become unmistakable.
      ]
    ],
    [
      #focus-block(title: "Visualization Improvements", color: accent-color)[
        - *Color code* bars by policy era (pre-policy, PPCDAm, weakening).
        - Add *text annotations* marking key policy events.
        - Use *bar chart* (not line) to emphasize discrete yearly values.
      ]
    ]
  )
]


#lecture-slide(title: "Problem 5: Amazon Deforestation Over Time")[
  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob5_deforestation.png", width: 100%),
    [
      #compact-block(title: "Visualization Choice", color: primary-color)[
        *Bar chart* with bars colored by policy era and text annotations marking key periods.
      ]
      #v(0.1em)
      #compact-discuss()[
        - When was deforestation at its peak?
        - How effective was the PPCDAm plan (green bars)?
        - What happened after 2019?
      ]
      #v(0.1em)
      #compact-block(title: "Key Insight", color: accent-color)[
        Policy works. PPCDAm reduced deforestation by ~80%. Recent policy weakening has reversed progress.
      ]
    ]
  )
]


// =============================================================================
// PROBLEM 6: Can We Compare Climate Indicators That Use Different Units?
// =============================================================================

#lecture-slide(title: "Problem 6: Can We Compare Climate Indicators?")[
  #focus-block(title: "The Question", color: primary-color)[
    Four key climate indicators---temperature anomaly (#sym.degree C), CO#sub[2] (ppm), sea level rise (mm), and Arctic sea ice (million km#super[2])---are measured in completely different units. *Can we tell if they are changing in sync?*
  ]

  #v(0.4em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob6_climate_indicators_raw.png", width: 100%),
    [
      #compact-block(title: "The Raw Data", color: primary-color)[
        All *4 indicators on a shared y-axis*. CO#sub[2] ranges 315--420 ppm; temperature spans just #sym.minus 0.2 to 1.2#sym.degree C.
      ]
      #v(0.1em)
      #compact-discuss(title: "Can You Answer the Question?")[
        - Which variable dominates the y-axis?
        - Can you even *see* the temperature trend?
        - Why is a shared y-axis *meaningless* when units differ?
        - How would you make all four trends *comparable*?
      ]
    ]
  )
]


#lecture-slide(title: "Problem 6: What Would You Do Differently?")[
  #discuss-block(title: "Class Discussion")[
    The four indicators have completely different *units and magnitudes*. CO#sub[2] (~315--420 ppm) dominates the y-axis, making temperature (~#sym.minus 0.2 to 1.2#sym.degree C) and sea ice (~4.5--7.5 million km#super[2]) invisible. A shared y-axis is *meaningless* when units differ.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "The Transformation", color: primary-color)[
        - Apply *z-score standardization* to each variable: subtract its mean, divide by its standard deviation.
        - Now all variables are in the *same units*: standard deviations from mean.
        - A value of +2 means "2 standard deviations above average" regardless of the original unit.
      ]
    ],
    [
      #focus-block(title: "Visualization Improvements", color: accent-color)[
        - Overlay all standardized series on one plot---now they are *comparable*.
        - Add a *zero reference line* (the historical mean).
        - Use *distinct colors* and a clear legend per indicator.
      ]
    ]
  )
]


#lecture-slide(title: "Problem 6: Standardized Climate Indicators")[
  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob6_climate_indicators.png", width: 100%),
    [
      #compact-block(title: "Visualization Choice", color: primary-color)[
        *Overlaid line plots* of z-score standardized indicators. All four variables now share the same y-axis: standard deviations from mean.
      ]
      #v(0.1em)
      #compact-discuss()[
        - Do all four indicators move in the same direction?
        - Which indicator shows the strongest trend?
        - Why does Arctic sea ice go *down* while the others go *up*?
      ]
      #v(0.1em)
      #compact-block(title: "Key Insight", color: accent-color)[
        Z-score standardization reveals that all four indicators are changing in sync---a clear fingerprint of climate change.
      ]
    ]
  )
]


// =============================================================================
// PROBLEM 7: Does Agriculture Pollute Our Waterways?
// =============================================================================

#lecture-slide(title: "Problem 7: Does Agriculture Pollute Our Waterways?")[
  #focus-block(title: "The Question", color: primary-color)[
    Agricultural runoff carries nitrogen fertilizer into streams, causing algal blooms. Researchers measured *nitrate concentrations* in 60 watersheds along with agricultural cover, urban cover, and area. *What drives the differences in water quality?*
  ]

  #v(0.4em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob7_agriculture_water_raw.png", width: 100%),
    [
      #compact-block(title: "The Raw Data", color: primary-color)[
        A *bar chart* of nitrate concentration for each of the 60 watersheds, in arbitrary order.
      ]
      #v(0.1em)
      #compact-discuss(title: "Can You Answer the Question?")[
        - Which watersheds have high nitrate? You can see that.
        - But *why* do some have high nitrate?
        - Is it agriculture? Urban land? Watershed size?
        - What information is *completely missing* from this plot?
      ]
    ]
  )
]


#lecture-slide(title: "Problem 7: What Would You Do Differently?")[
  #discuss-block(title: "Class Discussion")[
    The bar chart shows *what* (nitrate levels vary) but not *why*. You have 4 variables in the dataset---agriculture %, urban %, area, nitrate---but the bar chart only shows one. The explanatory variables are invisible.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "The Transformation", color: primary-color)[
        - Use a *scatter plot* with agriculture % on x-axis and nitrate on y-axis.
        - Encode *urban %* as color and *watershed area* as point size.
        - Now all 4 variables are visible simultaneously.
      ]
    ],
    [
      #focus-block(title: "Visualization Improvements", color: accent-color)[
        - Add a *trend line* (quadratic fit) to reveal non-linearity.
        - Mark the *EPA limit* (10 mg/L) as a reference line.
        - Use *position, color, and size* to encode 4 dimensions in 2D.
      ]
    ]
  )
]


#lecture-slide(title: "Problem 7: Agriculture and Water Quality")[
  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob7_agriculture_water.png", width: 100%),
    [
      #compact-block(title: "Visualization Choice", color: primary-color)[
        *Scatter plot* encoding 4 variables: x = agriculture %, y = nitrate, color = urban %, size = watershed area. EPA limit as reference.
      ]
      #v(0.1em)
      #compact-discuss()[
        - At what agriculture % does the EPA limit get exceeded?
        - Do darker points (more urban) tend to be higher?
        - Is this plot too complex, or does it reward careful reading?
      ]
      #v(0.1em)
      #compact-block(title: "Key Insight", color: accent-color)[
        Nitrate rises non-linearly with agriculture. Urban cover compounds the effect. Above ~60% agriculture often exceeds EPA limits.
      ]
    ]
  )
]


// =============================================================================
// PROBLEM 8: Are Droughts Getting Worse?
// =============================================================================

#lecture-slide(title: "Problem 8: Are Droughts Getting Worse?")[
  #focus-block(title: "The Question", color: primary-color)[
    The *Palmer Drought Severity Index (PDSI)* measures moisture: negative = drought, positive = wet. Scientists track PDSI across 6 world regions over 35 years. *Are some regions experiencing a consistent drying trend?*
  ]

  #v(0.4em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob8_drought_raw.png", width: 100%),
    [
      #compact-block(title: "The Raw Data", color: primary-color)[
        *Line plots* for all 6 regions overlaid on a single panel.
      ]
      #v(0.1em)
      #compact-discuss(title: "Can You Answer the Question?")[
        - Which regions are getting drier?
        - Can you follow any single region's trajectory?
        - Where do lines overlap and create a *spaghetti mess*?
        - What visualization handles a *region #sym.times year matrix* better?
      ]
    ]
  )
]


#lecture-slide(title: "Problem 8: What Would You Do Differently?")[
  #discuss-block(title: "Class Discussion")[
    Six overlapping, noisy time series create a *spaghetti plot*. You cannot follow individual regions, and the crossing lines make it impossible to compare trends across regions simultaneously.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "The Transformation", color: primary-color)[
        - Recognize this is a *2D matrix*: regions #sym.times years.
        - A *heatmap* maps each cell to a color.
        - Spatial patterns (drying trends) become immediately visible as color gradients.
      ]
    ],
    [
      #focus-block(title: "Visualization Improvements", color: accent-color)[
        - Use a *diverging color palette*: brown = drought, green = wet, white = neutral.
        - The diverging scale is critical---zero is meaningful, not arbitrary.
        - Regions as rows, years as columns: compact and information-dense.
      ]
    ]
  )
]


#lecture-slide(title: "Problem 8: Drought Severity Over Time")[
  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/03_Visualization/03_prob8_drought.png", width: 100%),
    [
      #compact-block(title: "Visualization Choice", color: primary-color)[
        *Heatmap* with a diverging color scale: brown = drought, green = wet. Each cell is one region-year combination.
      ]
      #v(0.1em)
      #compact-discuss()[
        - Which regions show a clear drying trend?
        - Does the Great Plains show a trend or a cycle?
        - Where are the most severe droughts concentrated?
      ]
      #v(0.1em)
      #compact-block(title: "Key Insight", color: accent-color)[
        Southwest US, Mediterranean, and East Africa show persistent drying since 2000. Not all regions are affected equally.
      ]
    ]
  )
]


// =============================================================================
// KEY TAKEAWAYS
// =============================================================================

#lecture-slide(title: "Key Takeaways")[
  #focus-block(title: "The Right Visualization Transforms Understanding", color: primary-color)[
    For every problem, the *raw data* was uninformative. The right *transformation + visualization* revealed the answer:
  ]

  #v(0.3em)

  #set text(size: 0.75em)
  #table(
    columns: (1.5fr, 1.5fr, 1.5fr, 2fr),
    inset: 0.5em,
    stroke: 0.5pt + luma(200),
    fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
    [*Problem*], [*Raw (Uninformative)*], [*Better Visualization*], [*Key Transformation*],
    [Temperature], [Absolute temp time series], [Anomaly bar chart], [Subtract baseline → anomalies],
    [Emissions], [Pie chart], [Sorted horizontal bars], [Angles → lengths; sort by value],
    [Air quality], [Bar chart of means], [Boxplots], [Single mean → full distribution],
    [Coral bleaching], [Two separate bar charts], [Scatter plot], [Separate → combined (x vs y)],
    [Deforestation], [Total remaining area], [Annual rate bars], [Stock → flow (rate of change)],
    [Climate indicators], [All on shared y-axis], [Standardized (z-score) overlay], [Raw values #sym.arrow z-scores (subtract mean, divide by #sym.sigma)],
    [Water quality], [Nitrate bar by watershed], [Multi-variable scatter], [One variable → four (position, color, size)],
    [Drought], [Spaghetti line plot], [Heatmap], [Lines → color matrix],
  )
]


#lecture-slide(title: "Principles of Good Visualization")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #focus-block(title: "Design Choices That Worked", color: primary-color)[
        - *Color with meaning*: blue/red for cool/warm; diverging palettes for anomalies.
        - *Reference lines*: WHO limit, EPA threshold, bleaching threshold---provide context.
        - *Faceting*: separate panels prevent overplotting and enable comparison.
        - *Sorting*: ordered bars let readers quickly find the largest/smallest.
        - *Annotations*: text labels on the plot explain the story directly.
      ]

      #v(0.3em)

      #focus-block(title: "The Visualization Workflow", color: accent-color)[
        + Understand the *question*.
        + Examine the *data structure*.
        + Choose the *plot type*.
        + Add *context* (labels, reference lines, annotations).
        + *Interpret* and *communicate*.
      ]
    ],
    [
      #focus-block(title: "Common Pitfalls to Avoid", color: warning-color)[
        - Pie charts for comparing similar values.
        - Rainbow color scales (not perceptually uniform).
        - 3D effects that distort proportions.
        - Truncated axes that exaggerate small differences.
        - Missing axis labels or units.
        - Too many variables in a single plot.
      ]

      #v(0.3em)

      #focus-block(title: "Remember", color: primary-color)[
        _"The purpose of visualization is insight, not pictures."_ --- Ben Shneiderman

        A good figure should allow the reader to answer the question *without reading the caption*.
      ]
    ]
  )
]


#lecture-slide(title: "What's Next?")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #focus-block(title: "Today We Covered", color: primary-color)[
        - 8 environmental problems, each with a different visualization.
        - How to match *data type* to *plot type*.
        - How *color, faceting, annotations, and reference lines* add meaning.
        - How to *interpret* figures to answer scientific questions.
        - Why the same data can tell different stories depending on the visualization.
      ]
    ],
    [
      #focus-block(title: "Coming Up", color: accent-color)[
        - Hands-on exercises: recreate these plots in Python and R.
        - Introduction to `ggplot2` and `matplotlib` syntax.
        - Building multi-panel figures for publications.
        - Spatial data visualization and mapping.
      ]

      #v(0.5em)

      #focus-block(title: "Resources", color: accent-color)[
        - #link("https://r4ds.hadley.nz/data-visualize")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[R for Data Science --- Visualization]]]
        - #link("https://matplotlib.org/stable/gallery/index.html")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Matplotlib Gallery]]]
        - #link("https://clauswilke.com/dataviz/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Fundamentals of Data Visualization]]]
      ]
    ]
  )
]


#lecture-slide[
  #set align(center + horizon)
  #text(2em, fill: primary-color, [Questions?])
]
