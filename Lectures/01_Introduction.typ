#import "@preview/polylux:0.4.0": *
#import "@preview/fletcher:0.5.8": diagram, node, edge


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
  - *Philosophy of the Course*
  - *What is Environmental Data Science?*
  - *Some Important Definitions*
  - *Exploratory Data Analysis*
  - *Data and Methods*
  - *Software*
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
      - Maya Carp
    ]
  )
]

#lecture-slide(title: "Philosophy of the Course")[
  #focus-block(title: "Primary Goal", color: primary-color)[
    The focus is on how to apply data science techniques to environmental problems and not on the mathematics of data science.
  ]
  // Here, add a few more goals based on the learning outcomes

  #focus-block(title: "Learning Outcomes", color: primary-color)[
    - Ability to break down complex environmental problems.
    - Develop testable hypotheses and select appropriate methods to solve them.
    - Develop and apply statistical or machine learning models.
    - Scientifically interpret the results of your analysis.
    - Communicate your analysis clearly.
  ]

  #focus-block(title: "Teaching Philosophy and Expectations", color: accent-color)[
    - I emphasize algorithmic thinking and problem solving.
    - There are no exams but ...
    - I encourage use of artificial intelligence but ...
    - Be honest about feedback: This is the first edition of the course.
    - Have fun!
  ]
]

#lecture-slide(title: "What is Environmental Data Science?")[
  #focus-block(title: "Data Science", color: primary-color)[
  Data science is an interdisciplinary field that uses *scientific methods*, processes,
  algorithms and systems to *extract knowledge* and insights from *noisy, structured, and unstructured data*.
  ]

  #v(0.4em)

  #grid(
    columns: (1.2fr, 3fr, 1.2fr),
    gutter: 1em,
    align(center + horizon)[
      #stack(spacing: 0.2em,
        image("/Lectures/Data/01_Introduction/01_Lecture_Noisy.png", width: 80%),
        image("/Lectures/Data/01_Introduction/01_Lecture_Unstructured.png", width: 80%),
        image("/Lectures/Data/01_Introduction/01_Lecture_Structured.png", width: 80%)
      )
    ],
    align(center + horizon)[
      #diagram(
        node-stroke: 1pt,
        spacing: 2em,
        node((0,0), [*Noisy Data*], fill: luma(240), stroke: luma(200), corner-radius: 4pt, width: 8em),
        node((0,1), [*Unstructured Data*], fill: luma(240), stroke: luma(200), corner-radius: 4pt, width: 8em),
        node((0,2), [*Structured Data*], fill: luma(240), stroke: luma(200), corner-radius: 4pt, width: 8em),

        node((2,1), text(1.2em, weight: "bold", fill: primary-color)[Algorithms], fill: primary-color.lighten(90%), stroke: 2pt + primary-color, inset: 1em, corner-radius: 5pt),

        node((3.5,0.5), [*Outputs*], fill: accent-color.lighten(80%), stroke: accent-color, corner-radius: 4pt, width: 6em),
        node((3.5,1.5), [*Insights*], fill: accent-color.lighten(80%), stroke: accent-color, corner-radius: 4pt, width: 6em),

        edge((0,0), (1,0), (1,1), (2,1), "-|>", corner-radius: 5pt),
        edge((0,1), (2,1), "-|>", corner-radius: 5pt),
        edge((0,2), (1,2), (1,1), (2,1), "-|>", corner-radius: 5pt),

        edge((2,1), (2.8,1), (2.8,0.5), (3.5,0.5), "-|>", corner-radius: 5pt),
        edge((2,1), (2.8,1), (2.8,1.5), (3.5,1.5), "-|>", corner-radius: 5pt),
      )
    ],
    align(horizon)[
      #focus-block(title: "Model Output", color: accent-color)[
        $ Y = a x^3 + b x + c $
      ]
    ]
  )
]



#lecture-slide(title: "Some Important Definitions")[
  #focus-block(title: "Big Data", color: primary-color)[
    Data having a size or complexity too big to be processed effectively by traditional software.
  ]

  #focus-block(title: "Data Mining", color: primary-color)[
    The process of discovering patterns in large datasets or "big data".
  ]

  #focus-block(title: "Machine Learning", color: primary-color)[
    Building a model to represent an environmental process using observed data in order to make predictions.
  ]

  #focus-block(title: "Exploratory Data Analysis", color: primary-color)[
    Exploratory Data Analysis (EDA) is an approach or set of approaches for analyzing datasets to summarize their main characteristics, often using statistical graphics and visualization methods, before formal modeling.
  ]

]

#lecture-slide(title: "Exploratory Data Analysis")[
  #focus-block(title: "Definition", color: primary-color)[
    Exploratory Data Analysis (EDA) is an approach or set of approaches for analyzing datasets to summarize their main characteristics, often using statistical graphics and visualization methods, before formal modeling.
  ]

  #grid(
    columns: (3fr, 1fr),
    gutter: 1em,
    align(left + horizon)[
      #image("/Lectures/Data/01_Introduction/01_Lecture_EDA_Example.png", width: 100%)
    ],
    align(horizon)[
      #focus-block(title: "Source", color: accent-color)[
        Global Runoff Data Center: #link("https://portal.grdc.bafg.de/applications/public.html?publicuser=PublicUser#dataDownload/Stations")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link to the Data]]]
      ]
    ]
  )
]

#lecture-slide(title: "Data and Methods")[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    focus-block(title: "Time Series Analysis", color: primary-color)[
      - Seasonality Decomposition
      - Non-Parametric Trend Estimation
      - Change Point Detection
      - Spectral Analysis
      - Auto Correlation
      #image("/Lectures/Data/01_Introduction/01_Lecture_TimeSeries.png", width: 100%)
    ],

    focus-block(title: "Spatial Data Analysis", color: primary-color)[
      - Mapping of Spatial Datasets
      - Topological Analysis
      - Working with Raster and Shapefiles
      - Image Classification
      - Geostatistics
      #image("/Lectures/Data/01_Introduction/01_Lecture_SpatialData.png", width: 100%)
    ],

    focus-block(title: "Statistical Modeling", color: primary-color)[
      - Linear and Non-Linear Models
      - Random Forests
      - Support Vector Machines
      - Neural Networks
      - Convolutional Neural Networks
      #v(0.5em)
      #stack(spacing: 0.8em,
        align(center)[
          #text(0.9em)[$ Q_"runoff" = f("Rainfall", "Temperature", "Soil") $]
        ],
        align(center)[
          #diagram(
            spacing: 0.4em,
            node-stroke: 0.5pt,
            node((1,0), text(0.7em)[Input Data], fill: luma(240), corner-radius: 2pt),
            edge((1,0), (0,1), "-|>", corner-radius: 2pt),
            edge((1,0), (2,1), "-|>", corner-radius: 2pt),

            // Tree 1
            node((0,1), text(0.5em)[Tree 1], fill: primary-color.lighten(90%), stroke: primary-color, corner-radius: 2pt),

            node((1,1), [...], stroke: none),

            // Tree N
            node((2,1), text(0.5em)[Tree N], fill: primary-color.lighten(90%), stroke: primary-color, corner-radius: 2pt),

            edge((0,1), (1,2.2), "-|>", corner-radius: 2pt),
            edge((2,1), (1,2.2), "-|>", corner-radius: 2pt),
            node((1,2.2), text(0.6em)[Averaging], fill: accent-color.lighten(90%), stroke: accent-color, corner-radius: 2pt),
          )
        ],
        align(center)[
          #diagram(
            spacing: 0.8em,
            node-stroke: 0.5pt,
            node((0,0), text(0.7em)[$P, T$], fill: luma(240), corner-radius: 2pt),
            edge((0,0), (1,0), "-|>", corner-radius: 2pt),
            node((1,0), text(0.7em)[LSTM], fill: primary-color.lighten(90%), stroke: primary-color, corner-radius: 4pt),
            edge((1,0), (2,0), "-|>", corner-radius: 2pt),
            node((2,0), text(0.7em)[Runoff], fill: accent-color.lighten(90%), stroke: accent-color, corner-radius: 2pt),
            edge((1,0), (1,0), "--|>", bend: 130deg, label: text(0.5em)[$h_{t-1}$])
          )
        ],
        //align(center)[
        //  #diagram(
        //    spacing: 0.5em,
        //    node-stroke: 0.5pt,
        //    node((0,0), text(0.7em)[Raster], fill: luma(240), corner-radius: 2pt),
        //    edge((0,0), (1,0), "-|>", corner-radius: 2pt),
        //    node((1,0), text(0.6em)[Conv], fill: primary-color.lighten(90%), stroke: primary-color, corner-radius: 2pt),
        //    edge((1,0), (2,0), "-|>", corner-radius: 2pt),
        //    node((2,0), text(0.6em)[Pool], fill: primary-color.lighten(90%), stroke: primary-color, corner-radius: 2pt),
        //    edge((2,0), (3,0), "-|>", corner-radius: 2pt),
        //    node((3,0), text(0.6em)[FC], fill: primary-color.lighten(90%), stroke: primary-color, corner-radius: 2pt),
        //    edge((3,0), (4,0), "-|>", corner-radius: 2pt),
        //    node((4,0), text(0.7em)[Label], fill: accent-color.lighten(90%), stroke: accent-color, corner-radius: 2pt),
        //  )
        //]
      )
    ]
  )

]

#lecture-slide(title: "Software")[
  #focus-block(title: "R-Programming Language", color: primary-color)[
    R is a free software environment for statistical computing and graphics.
    - The software is available here: #link("https://www.r-project.org/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link]]].
    - R needs an integrated development environment (IDE) such as RStudio to be used effectively (#link("https://posit.co/download/rstudio-desktop/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link]]]).
    - We will be using packages in the the `tidyverse` suite (#link("https://www.tidyverse.org/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link]]]).
  ]

  #focus-block(title: "Git and GitHub", color: primary-color)[
    - Git is a distributed version control management system.
    - GitHub is a popular platform that uses Git to host code repositories (#link("https://github.com/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link]]]).
    - The Git repository for the course is here: #link("https://github.com/akashkoppa/env-data-science")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link]]].
  ]

  #focus-block(title: "Document Typesetting", color: primary-color)[
    - No preference.
    - LaTeX is a software system for typesetting documents, based on TeX (#link("https://www.latex-project.org/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link]]]).
    - Overleaf is an online solution (#link("https://www.overleaf.com/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link]]]).
    - Modern alternatives include Typst are more accessible (#link("https://typst.app/")[#text(fill: accent-color.darken(20%), weight: "bold")[#underline[Link]]]).
  ]
]

//#lecture-slide(title: "R-Programming Language")[
//  // Try and make this into vertical columns
//  #focus-block(title: "R-Programming Language", color: primary-color)[
//    Figure Here
//  ]

//  #focus-block(title: "Integrated Development Environment", color: primary-color)[
//    R-Studio
//  ]
//]

//#lecture-slide(title: "Logistics for the Course")[
//  // Try and make this into vertical columns
//  #focus-block(title: "R-Programming Language", color: primary-color)[
//    Figure Here
//  ]

//  #focus-block(title: "Integrated Development Environment", color: primary-color)[
//    R-Studio
//  ]
//]

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
