#import "@preview/polylux:0.4.0": *

// --- CONFIGURATION & COLORS ---
#let primary-color = rgb("#2d5a27") // Sage Green
#let accent-color = rgb("#457b9d")  // Muted Steel Blue
#let bg-color = rgb("#fdfdfc")      // Soft Cream (easy on the eyes)
#let text-color = rgb("#2f2f2f")    // Soft Charcoal

#let setup-theme(title: "", author: "", date: none, body) = {
  set page(
    paper: "presentation-16-9",
    fill: bg-color,
    margin: 2.5em,
  )
  set text(size: 14pt, fill: text-color)

  // Title Slide
  // Note: In 0.4.0, the core function is simply 'slide'
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
// We name it 'lecture-slide' to avoid conflict with Polylux's 'slide'
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

// --- DOCUMENT START ---

#show: body => setup-theme(
  title: "Overview of Environmental Data Science",
  author: "Instructor: Akash Koppa",
  date: "Lecture 1 of Spring Semester 2026",
  body
)

#lecture-slide(title: "Today's Agenda")[
  - *Introductions*
  - *What is Environmental Data Science?*
  - *Goals of this Course*
  - *Some Important Definitions*
  - *Exploratory Data Analysis*
  - *Data and Methods*
  - *Software*
  - *R Programming Language*
  - *Logistics for the Course*
]

#lecture-slide(title: "Introductions")[
  #focus-block(title: "Instructor: Akash Koppa", color: primary-color)[
    - Civil Engineer by education.
    - Climate Scientist by choice.
  ]

  #grid(
    columns: (1.5fr, 1fr),
    gutter: 1em,
    image("/Lectures/Data/01_Introduction/01_Lecture_Map_Lived.png", width: 95%),
    focus-block(title: "Spring 2026 Cohort", color: accent-color)[
      - Maya Friedman
      - Alexis Ann Keys
      - Benjamin Payot
      - Claire Socash
      - Bryan Wong
      - Bria Young
      - Camryn Brown
    ]
  )
]

#lecture-slide(title: "What is Environmental Data Science?")[
  #focus-block(title: "Data Science has a Precise Definition", color: primary-color)[
  Data science is an interdisciplinary field that uses *scientific methods*, processes,
  algorithms and systems to *extract knowledge* and insights from *noisy, structured, and unstructured data*.
  ]
  // Here, I want to explain the difference between Data Science and Science. Use the board here to explain
  // the difference between physics and data-based science.
  // Physics - you know the rules and apply those rules to data. (e.g. Runoff)
  // Data Science - You use the data to extract the rules that govern the world.
  // Fundamentally different.

  // Here, show a visual represenation of how Environmental Data Science would work.
  // Basically Inputs ---> Model ---> Outputs/Insights
]

#lecture-slide(title: "Goals of this Course")[
  #focus-block(title: "What can we do with data science methods?", color: primary-color)[
    Not how to develop those methods.
  ]
  // Here, add a few more goals based on the learning outcomes
]

#lecture-slide(title: "Some Important Definitions")[
  #focus-block(title: "Big Data", color: primary-color)[
    What does this mean?
  ]

  #focus-block(title: "Data Mining", color: primary-color)[
    What does this mean?
  ]

  #focus-block(title: "Machine Learning", color: primary-color)[
    What does this mean?
  ]

  #focus-block(title: "Exploratory Data Analysis", color: primary-color)[
    What does this mean?
  ]
  // Here, add a few more goals based on the learning outcomes
]

#lecture-slide(title: "Exploratory Data Analysis")[
  #focus-block(title: "Definition", color: primary-color)[
    Exploratory Data Analysis (EDA) is an approach or set of approaches for analyzing datasets to summarize their main characteristics, often using statistical graphics and visualization methods, before formal modeling.
  ]

  #focus-block(title: "Data Abstraction and Visualization", color: primary-color)[
    Figure Here
  ]

  // Here, add an example and discuss with the students about how this dataset can be interpreted
]

#lecture-slide(title: "Data and Methods")[
  // Try and make this into vertical columns
  #focus-block(title: "Time Series Analysis", color: primary-color)[
    Figure Here
  ]

  #focus-block(title: "Spatial Data Analysis", color: primary-color)[
    Figure Here
  ]

  #focus-block(title: "Statistical Modeling and Machine Learning", color: primary-color)[
    Figure Here
  ]

  // Here, add an example and discuss with the students about how this dataset can be interpreted
]

#lecture-slide(title: "Software")[
  // Try and make this into vertical columns
  #focus-block(title: "R-Programming Language", color: primary-color)[
    Figure Here
  ]

  #focus-block(title: "GitHub", color: primary-color)[
    Figure Here
  ]

  #focus-block(title: "Document Typesetting", color: primary-color)[
    Figure Here
  ]
]

#lecture-slide(title: "R-Programming Language")[
  // Try and make this into vertical columns
  #focus-block(title: "R-Programming Language", color: primary-color)[
    Figure Here
  ]

  #focus-block(title: "Integrated Development Environment", color: primary-color)[
    R-Studio
  ]
]

#lecture-slide(title: "Logistics for the Course")[
  // Try and make this into vertical columns
  #focus-block(title: "R-Programming Language", color: primary-color)[
    Figure Here
  ]

  #focus-block(title: "Integrated Development Environment", color: primary-color)[
    R-Studio
  ]
]

//#lecture-slide(title: "Key Definition")[
//  #focus-block(title: "Definition: Entropy", color: primary-color)[
//    A thermodynamic quantity representing the unavailability of a system's thermal energy for conversion into mechanical work.
//  ]

//  #v(1em)

//  #focus-block(title: "Example Calculation", color: accent-color)[
//    If $Delta Q$ is the heat added to the system, then $d S = (d Q) / T$.
//  ]
//]

#lecture-slide[
  #set align(center + horizon)
  #text(2em, fill: primary-color, [Questions?])
]
