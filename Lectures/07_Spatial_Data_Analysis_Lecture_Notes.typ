// =============================================================================
// LECTURE NOTES: 07 — Spatial Data Analysis
// Companion guide for the instructor
// =============================================================================

#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: "1 / 1",
)
#set text(size: 11pt, fill: rgb("#2f2f2f"))
#set par(justify: true)
#set heading(numbering: "1.1")

// --- Styling ---
#let primary   = rgb("#2d5a27")
#let accent    = rgb("#457b9d")
#let warning   = rgb("#c44536")
#let discuss   = rgb("#6a4c93")
#let board-col = rgb("#8B4513")

#let timing-box(mins) = {
  box(
    fill: accent.lighten(85%),
    inset: (x: 0.6em, y: 0.3em),
    radius: 3pt,
    text(size: 0.85em, weight: "bold", fill: accent, "~" + str(mins) + " min"),
  )
}

#let tip-box(body) = {
  rect(
    fill: primary.lighten(92%),
    stroke: (left: 3pt + primary),
    width: 100%,
    inset: 0.8em,
    radius: 3pt,
    [#text(weight: "bold", fill: primary, [Teaching Tip]) \ #body],
  )
}

#let transition-box(body) = {
  rect(
    fill: accent.lighten(92%),
    stroke: (left: 3pt + accent),
    width: 100%,
    inset: 0.8em,
    radius: 3pt,
    [#text(weight: "bold", fill: accent, [Transition]) \ #body],
  )
}

#let exercise-box(body) = {
  rect(
    fill: discuss.lighten(92%),
    stroke: (left: 3pt + discuss),
    width: 100%,
    inset: 0.8em,
    radius: 3pt,
    [#text(weight: "bold", fill: discuss, [Exercise Guidance]) \ #body],
  )
}

#let board-box(body) = {
  rect(
    fill: board-col.lighten(93%),
    stroke: (left: 3pt + board-col),
    width: 100%,
    inset: 0.8em,
    radius: 3pt,
    [#text(weight: "bold", fill: board-col, [Board Work]) \ #body],
  )
}

// --- Title ---
#align(center)[
  #block(
    stroke: (bottom: 2pt + primary),
    inset: 1em,
  )[
    #text(1.6em, weight: "bold", fill: primary)[Lecture 7 --- Spatial Data Analysis] \
    #text(1em)[Instructor Notes]
  ]
  #v(0.5em)
  #text(0.9em, fill: luma(100))[ENST431/631: Environmental Data Science -- Spring 2026]
]

#v(1em)

// --- Overview ---
= Lecture Overview

*Duration:* ~75 minutes (adjustable based on exercise depth)

*Prerequisites:* Students should have completed Lectures 5--6 on spatial data formats, coordinate reference systems, and basic mapping in R/Python.

*Learning objectives.* By the end of this lecture, students will be able to:

+ Distinguish between spatial descriptive statistics, point pattern analysis, spatial autocorrelation, and spatial interpolation.
+ Compute and interpret the Nearest Neighbor Index and Moran's I.
+ Explain the difference between IDW and Kriging, and when each is appropriate.
+ Read a variogram and identify the nugget, range, and sill.
+ Use Kriging variance maps to reason about prediction reliability and monitoring network design.

*Suggested pacing:*

#table(
  columns: (3fr, 1fr),
  inset: 0.5em,
  stroke: 0.5pt + luma(200),
  fill: (x, y) => if y == 0 { primary.lighten(88%) },
  [*Section*], [*Minutes*],
  [Part 1: From Spatial Data to Spatial Analysis (pages 2--3)], [5],
  [Part 2: Spatial Descriptive Statistics (pages 4--5)], [8],
  [Part 3: Point Pattern Analysis (pages 6--8)], [10],
  [Part 4: Kernel Density Estimation (pages 9--10)], [7],
  [Part 5: Spatial Autocorrelation (pages 11--15)], [15],
  [Part 6: Spatial Interpolation --- IDW (pages 16--19)], [10],
  [Part 7: Geostatistics --- Variograms & Kriging (pages 20--27)], [15],
  [Part 8: Choosing the Right Technique & Takeaways (pages 28--30)], [5],
)

#v(0.5em)

*General notes:*
- The lecture follows a "simple to complex" arc: descriptive statistics $arrow$ pattern detection $arrow$ interpolation $arrow$ geostatistics. Emphasize this progression explicitly so students see the logical thread.
- Every section ends with an interactive exercise grounded in environmental data (Chesapeake Bay, wildlife, soil, air quality). Use these to break up the conceptual density.
- The Chesapeake Bay is the recurring case study. Students should be familiar with it from earlier lectures. If not, a 30-second reminder ("long estuary, nutrient pollution, seasonal hypoxia") is sufficient.

#pagebreak()

// =========================================================================
= Part 1: From Spatial Data to Spatial Analysis (Pages 2--3)
// =========================================================================

== Page 2 --- Recap: Where We Are #h(1fr) #timing-box(2)

*What to say:*
- Open by connecting to previous lectures: "We've learned how to _store_ and _map_ spatial data. Today we ask: what can the spatial arrangement of data _tell_ us?"
- Walk through the pipeline figure briefly. Point out that the lecture follows this left-to-right progression: raw data $arrow$ pattern detection $arrow$ interpolation $arrow$ prediction with uncertainty.
- Frame the central question on the slide: _What spatial patterns exist, and can we predict values at unmeasured locations?_ This is the guiding thread for the entire lecture.

#board-box[
  Write the lecture pipeline as a horizontal flow:

  #align(center)[
    *Raw Spatial Data* #sym.arrow.long *Describe Patterns* #sym.arrow.long *Detect Clusters* #sym.arrow.long *Interpolate* #sym.arrow.long *Predict + Uncertainty*
  ]

  Write the central question below the pipeline:

  #align(center)[_"What spatial patterns exist in the data, and can we predict values at unmeasured locations?"_]

  Sketch a simple map outline (e.g., the Bay) with 5--6 dots (stations) and a question mark between them to illustrate "predicting the unknown."
]

#tip-box[
  Ask the class: "If I give you temperature measurements at 10 weather stations, what questions might you want to answer?" Let them volunteer ideas (are temperatures clustered? can we estimate temperature between stations?). Then show how the lecture addresses exactly these questions.
]

== Page 3 --- Tobler's First Law of Geography #h(1fr) #timing-box(3)

*What to say:*
- Read the quote aloud. Emphasize the word "near" --- this single idea is the engine behind everything in the lecture.
- Walk through the figure:
  - *Left panel:* a temperature field where two nearby points have similar values, and two distant points differ. This is the intuitive version of the law.
  - *Right panel:* correlation decays with distance. This is the quantitative version. The exponential curve is not just a visual --- it's exactly the kind of relationship a variogram will capture later.
- Briefly connect the three bullet points (autocorrelation, interpolation, geostatistics) to the lecture outline: "We'll cover each of these in order."
- End with the provocative closing line: _If this law didn't hold, spatial analysis would be pointless._ Pause and let that land. It motivates everything that follows.

#board-box[
  Write the quote:

  #align(center)[_"Everything is related to everything else, but *near things are more related* than distant things." --- Tobler, 1970_]

  Sketch a correlation-vs-distance curve below the quote. Draw axes:
  - x-axis: *Distance*
  - y-axis: *Correlation* (or *Similarity*)

  Draw a smooth exponential decay curve from high correlation at distance 0 down toward zero at large distances. Label: "This decay is the foundation of everything today."

  Write the three consequences underneath:
  + *Spatial autocorrelation* --- nearby values are correlated
  + *Interpolation* --- predict unknowns from nearby knowns
  + *Geostatistics* --- model the decay of correlation with distance
]

#tip-box[
  A good analogy: "Tobler's Law is to spatial analysis what the assumption of normality is to classical statistics --- it's the foundational assumption that makes the math work. Most of the time it holds. When it doesn't, we need different tools."
]

#transition-box[
  "So if near things are more related, let's start with the simplest question: _where_ are the things? That's spatial descriptive statistics."
]

#pagebreak()

// =========================================================================
= Part 2: Spatial Descriptive Statistics (Pages 4--5)
// =========================================================================

== Page 4 --- Spatial Descriptive Statistics #h(1fr) #timing-box(3)

*What to say:*
- Draw the analogy explicitly: "You all know how to compute a mean and standard deviation for a column of numbers. Now imagine the numbers have _locations_."
- Walk through the three-panel figure:
  - *Mean Center* (panel a): the geographic center of gravity. It's just the average of x-coordinates and y-coordinates separately. Simple, but immediately useful --- "where is the center of this phenomenon?"
  - *Standard Distance* (panel b): how spread out are the points around the mean center? The spatial equivalent of standard deviation. The circle shows the radius.
  - *Std. Deviational Ellipse* (panel c): adds directionality. The covariance matrix of x and y coordinates gives the orientation and elongation. An elongated ellipse says the data has a directional trend.
- Point out the formulas at the bottom. Stress that these are _not_ new math --- they are just the familiar mean and standard deviation applied to coordinates.

#board-box[
  Write all three formulas on the board:

  *1. Mean Center:*
  $ overline(x) = 1/n sum_(i=1)^n x_i #h(3em) overline(y) = 1/n sum_(i=1)^n y_i $

  *2. Standard Distance:*
  $ "SD" = sqrt(1/n sum_(i=1)^n d_i^2) #h(2em) "where" #h(0.5em) d_i = sqrt((x_i - overline(x))^2 + (y_i - overline(y))^2) $

  *3. Weighted Mean Center* (useful for the exercise on the next slide):
  $ overline(x)_w = (sum_(i=1)^n w_i x_i) / (sum_(i=1)^n w_i) #h(3em) overline(y)_w = (sum_(i=1)^n w_i y_i) / (sum_(i=1)^n w_i) $

  Sketch three small diagrams side by side:
  - *(a)* Scatter of dots with a *+* at the center (mean center)
  - *(b)* Same dots with a *dashed circle* around the center (standard distance)
  - *(c)* Same dots with a *dashed ellipse* tilted at an angle (deviational ellipse)

  Label: "These are just mean and std dev applied to coordinates."
]

#tip-box[
  Don't spend too long on the formulas. The visual is the important part. Students should look at the figure and say: "The mean center is _there_, the spread is _this big_, and the trend goes in _that_ direction." If they can do that, they've understood.
]

== Page 5 --- Example: Where Is the Center of Pollution? #h(1fr) #timing-box(5)

*What to say:*
- This is the first interactive exercise. Set it up by saying: "You're an environmental analyst. You have 12 monitoring stations in the Bay. The first thing you want to know is: where is the nutrient problem centered?"
- Walk through the table briefly. Point out the range of nitrogen concentrations (1.4 to 5.1 mg/L) and that the higher values are at southern stations.

#board-box[
  Demonstrate the weighted mean center calculation with a simple 3-station example:

  #table(
    columns: (auto, auto, auto, auto),
    inset: 0.4em,
    stroke: 0.5pt + luma(200),
    [*Station*], [*Lon*], [*Lat*], [*Weight (N)*],
    [A], [-76.4], [38.6], [1.0],
    [B], [-76.2], [37.5], [5.0],
    [C], [-76.1], [38.0], [2.0],
  )

  Show the calculation step by step:

  $ overline(x)_w = (1.0 times (-76.4) + 5.0 times (-76.2) + 2.0 times (-76.1)) / (1.0 + 5.0 + 2.0) = (-76.4 - 381.0 - 152.2) / 8.0 approx -76.2 $

  Key point to write: "Unweighted center $approx$ geographic center. Weighted center shifts _toward high-concentration stations_ (south)."

  Sketch an outline of the Bay with two + marks: one for unweighted center, one for weighted center, with an arrow showing the shift southward.
]

#exercise-box[
  *How to run this exercise:*
  - Give students 2--3 minutes to think about questions 1--2 (mean center and weighted mean center). They don't need to compute exact numbers --- the intuition is what matters.
  - For question 2, emphasize the concept: "When you weight by concentration, the center _shifts toward the high values_." This is the key insight.
  - For question 3, prompt: "The shift tells you the nutrient loading is concentrated in the _south_, even though stations are spread across the Bay."
  - Question 4 is about the ellipse direction: the Bay runs NNW--SSE, so the ellipse should be elongated in that direction. This is a nice connection between geography and statistics.
  - If short on time, do questions 1--2 as a class and leave 3--4 as "think about this."
]

#transition-box[
  "Descriptive statistics tell us _where_ and _how spread out_. But they don't answer a deeper question: is the pattern _random_, or is something causing the points to cluster? That's what point pattern analysis does."
]

#pagebreak()

// =========================================================================
= Part 3: Point Pattern Analysis (Pages 6--8)
// =========================================================================

== Page 6 --- Point Pattern Analysis: Is It Random? #h(1fr) #timing-box(3)

*What to say:*
- This slide sets up the null hypothesis for point pattern analysis. The key idea: _we compare an observed pattern to what randomness would look like._
- Walk through the three-panel figure:
  - *CSR (random):* each point could be anywhere with equal probability. This is the null hypothesis.
  - *Clustered:* points bunch together. Examples: disease outbreaks near a contamination source, bird nests near food sources.
  - *Dispersed:* points repel each other. Examples: territorial animals, trees in a plantation.
- Stress that the human eye is _terrible_ at distinguishing random from clustered. Show the random panel and ask: "Does this look random to you?" Most students will see patterns where none exist. This motivates the need for a formal test.

#board-box[
  Draw three small squares side by side and fill each with dots:

  - *(a) Random (CSR):* scatter dots irregularly but without obvious clumps. Label: "$H_0$: Complete Spatial Randomness."
  - *(b) Clustered:* draw two tight clumps of dots with empty space between. Label: "Points aggregate."
  - *(c) Dispersed/Regular:* draw dots in a roughly even grid. Label: "Points repel each other."

  Write the null hypothesis clearly:

  $ H_0: "The point pattern is generated by Complete Spatial Randomness (CSR)" $

  Write below: "Our goal: a _statistical test_ to distinguish these three patterns."
]

#tip-box[
  The "patternicity" of the human brain is a great hook here. Consider saying: "Our brains evolved to find patterns --- even when there are none. That's why we need statistics, not just eyeballing."
]

== Page 7 --- Nearest Neighbor Analysis #h(1fr) #timing-box(3)

*What to say:*
- Introduce the NNI as a simple, elegant test. The logic: "If points are clustered, each point's nearest neighbor is _closer_ than expected under randomness."
- Walk through the formula step by step:
  - $overline(d)_"observed"$: measure the distance from each point to its nearest neighbor, then average.
  - $overline(d)_"expected"$: what that average distance _would be_ if the points were randomly scattered across the study area. This depends on the density $n/A$.
  - NNI is the ratio. Less than 1 = clustered, equal to 1 = random, greater than 1 = dispersed.
- Point to the figure:
  - *Left panel:* shows actual nearest-neighbor distances for a set of points. Some are short (0.25, 0.39), some long (1.48). The average of all of these is $overline(d)_"observed"$.
  - *Right panel:* the interpretation scale. A nice visual reference students can return to.
- Mention the z-test for significance: "NNI = 0.95 might look clustered, but is it _statistically_ clustered? The z-test answers that."

#board-box[
  Write the two key equations:

  *Nearest Neighbor Index:*
  $ "NNI" = overline(d)_"observed" / overline(d)_"expected" $

  *Expected mean nearest-neighbor distance under CSR:*
  $ overline(d)_"expected" = 1 / (2 sqrt(n slash A)) $

  where $n$ = number of points, $A$ = area of the study region.

  Write the interpretation scale:

  #table(
    columns: (1fr, 1fr),
    inset: 0.4em,
    stroke: 0.5pt + luma(200),
    [*NNI value*], [*Interpretation*],
    [$"NNI" < 1$], [Clustered (neighbors closer than expected)],
    [$"NNI" = 1$], [Random (CSR)],
    [$"NNI" > 1$], [Dispersed (neighbors farther than expected)],
  )

  Draw a simple number line from 0 to 2, mark 1.0 in the center, label the left side "Clustered" and the right side "Dispersed."
]

== Page 8 --- Example: Are Hypoxia Events Clustered? #h(1fr) #timing-box(4)

*What to say:*
- This is a worked-example exercise. Give students 1--2 minutes to attempt the calculation, then walk through it on the board.

#board-box[
  Write the given values:

  $ n = 30 "points" #h(2em) A = 11 500 "km"^2 #h(2em) overline(d)_"observed" = 8.2 "km" $

  *Step 1:* Compute expected distance:
  $ overline(d)_"expected" = 1 / (2 sqrt(n slash A)) = 1 / (2 sqrt(30 slash 11500)) = 1 / (2 sqrt(0.00261)) = 1 / (2 times 0.0511) = 1 / 0.1021 approx 9.8 "km" $

  *Step 2:* Compute NNI:
  $ "NNI" = overline(d)_"observed" / overline(d)_"expected" = 8.2 / 9.8 approx 0.84 $

  *Step 3:* Interpret:
  $ "NNI" = 0.84 < 1 #h(1em) arrow.long.double #h(1em) "Clustered" $

  Write conclusion: "Hypoxia events are closer together than expected by chance. They cluster in the deep central channel."
]

#exercise-box[
  *How to run this exercise:*
  - Walk through the calculation on the board step by step, pausing to let students verify each number.
  - Question 4 is the environmental reasoning: _why_ do they cluster? Hypoxia clusters in the deep central channel because of stratification, poor circulation, and nutrient-driven oxygen demand. This is a great moment to show that spatial statistics _describes_ patterns but domain knowledge _explains_ them.
  - If students ask about significance: "At 30 points with NNI = 0.84, the z-test would give a significant result. But the exact p-value depends on the z-score calculation, which we'll leave for the exercises."
]

#transition-box[
  "NNI tells us _whether_ points are clustered, but not _where_ the clusters are. For that, we need to convert points into a continuous surface. That's Kernel Density Estimation."
]

#pagebreak()

// =========================================================================
= Part 4: Kernel Density Estimation (Pages 9--10)
// =========================================================================

== Page 9 --- Kernel Density Estimation: From Points to Surfaces #h(1fr) #timing-box(3)

*What to say:*
- Motivate KDE by pointing out the limitation of raw point maps: "When you have 500 points on a map, you can't see the pattern. KDE solves this by converting points into a smooth density surface."
- Walk through the "How it works" steps:
  1. Place a smooth bump (kernel) over each point --- imagine dropping a bell curve on each location.
  2. Sum all the bumps across a grid --- where many bumps overlap, density is high.
  3. The result is a heat map showing intensity (events per unit area).
- The bandwidth parameter $h$ is the most important user choice:
  - *Small h*: captures fine detail but is noisy (every point creates its own hotspot).
  - *Large h*: smooth and easy to interpret but may merge real clusters into one blob.
  - Use the analogy: "Bandwidth is like the zoom level on a microscope. Too close and you see noise; too far and you miss the interesting structures."

#board-box[
  Sketch the KDE process in 1D (easier to draw than 2D):

  *Step 1:* Draw a horizontal axis with 4--5 tick marks representing point locations.

  *Step 2:* Above each point, draw a small bell curve (the "kernel"). Make two of the points close together so their curves overlap.

  *Step 3:* Draw the sum of all curves as a smooth line. Where two kernels overlap, the summed curve is higher. Label: "High density here."

  Write below the sketch:
  $ hat(f)(x) = 1 / (n h) sum_(i=1)^n K lr((x - x_i) / h) $

  where $K$ is the kernel function (e.g., Gaussian), $h$ is the bandwidth.

  Draw two versions of the summed curve side by side:
  - *Small $h$:* jagged, multiple peaks (overfitting). Label: "Noisy."
  - *Large $h$:* one broad smooth hump (underfitting). Label: "Oversmooth."
]

#tip-box[
  If students have seen KDE in a 1D statistics context (kernel density plots of distributions), connect it: "This is _exactly_ the same thing, just in 2D instead of 1D. Instead of a density curve, you get a density _surface_."
]

== Page 10 --- Example: Mapping Wildlife Sighting Density #h(1fr) #timing-box(4)

*What to say:*
- This is a discussion-based exercise, not a computation.

#board-box[
  Draw a simple comparison table:

  #table(
    columns: (1fr, 1fr),
    inset: 0.5em,
    stroke: 0.5pt + luma(200),
    [*Small bandwidth (500 m)*], [*Large bandwidth (2 km)*],
    [Two distinct hotspots], [One merged blob],
    [More actionable (where?)], [More stable (less noise)],
    [Risk: noise as false hotspot], [Risk: blurs real clusters],
  )

  Write the key takeaway: "KDE shows _where_ density is high, not _why_. Always overlay with environmental layers."

  Sketch a rectangle (the reserve) with two density contours inside it and the density "leaking" slightly outside the boundary on one side. Label: "Boundary effect --- density can leak outside the study area."
]

#exercise-box[
  *How to run this exercise:*
  - Let students talk in pairs for 2 minutes, then debrief.
  - Question 1 (KDE vs. raw points): KDE gives a _continuous_ surface that a manager can overlay with habitat maps. Raw points are hard to interpret visually and don't communicate density.
  - Question 2 (elevation): If the species prefers mid-elevation, KDE would show high density in a band at 300--500 m. This is where overlaying KDE with environmental layers becomes powerful.
  - Question 3 (bandwidth choice): The 500 m bandwidth (two hotspots) preserves more spatial detail and is more actionable for a reserve manager. But mention the caveat: "If the two hotspots are just noise from a small sample, the 2 km bandwidth might be more honest."
  - Question 4 (boundary effects): KDE can "leak" density outside the study area boundary. Mention boundary correction as an advanced topic.
]

#transition-box[
  "KDE shows us where density is high, but it doesn't test whether the spatial pattern is statistically significant. For that, we need spatial autocorrelation --- a way to _quantify_ whether nearby locations really do have similar values."
]

#pagebreak()

// =========================================================================
= Part 5: Spatial Autocorrelation (Pages 11--15)
// =========================================================================

This is the most conceptually dense section. Take it slowly and use the figures heavily.

== Page 11 --- Spatial Autocorrelation: Quantifying Spatial Patterns #h(1fr) #timing-box(3)

*What to say:*
- Connect back to Tobler's Law: "Remember --- near things are more related. Spatial autocorrelation is the _formal test_ of whether that's true for your data."
- Walk through the figure showing positive, zero, and negative autocorrelation.
  - *Positive:* similar values cluster. This is the most common case in environmental data (temperature, rainfall, vegetation, pollution).
  - *Zero:* no spatial pattern. Values could be shuffled randomly across locations and look the same.
  - *Negative:* dissimilar values are neighbors. This is rare in nature. The classic example is a checkerboard pattern. Mention competitive exclusion in ecology as a possible real-world case.
- The key message: "Positive spatial autocorrelation is _so_ common in environmental data that you should be surprised when you _don't_ find it."

#board-box[
  Draw a 3#sym.times 3 or 4#sym.times 4 grid of cells. Fill each grid three times to illustrate:

  *Positive autocorrelation:* shade one corner dark and the opposite corner light, with gradual transition. Write values like: 8, 7, 7, 6 in the top-left and 2, 2, 3, 3 in the bottom-right. Label: "Similar neighbors."

  *No autocorrelation (random):* fill cells with random-looking values (e.g., 3, 8, 2, 7, 5, 1, 9, 4, 6). Label: "No spatial pattern."

  *Negative autocorrelation:* fill cells in a checkerboard pattern alternating high and low values (e.g., 9, 1, 9, 1 / 1, 9, 1, 9). Label: "Dissimilar neighbors (rare in nature)."

  Write: "Environmental data is almost always _positively_ autocorrelated."
]

== Page 12 --- Global Moran's I #h(1fr) #timing-box(4)

*What to say:*
- This is the slide with the most mathematical content. Don't rush through the formula --- but don't dwell on every subscript either.
- High-level explanation of the formula: "Moran's I is essentially a _spatial correlation coefficient_. It multiplies the deviations of each pair of neighbors from the mean, then averages. If neighbors tend to deviate in the same direction (both above or both below the mean), Moran's I is positive."
- Walk through the interpretation scale: +1 (clustered), 0 (random), --1 (dispersed).
- *The Spatial Weights Matrix (W):* This is the key methodological choice. Stress that W defines what "neighbor" means, and the results _change_ depending on how you define it.
  - Queen contiguity (shares any boundary) vs. Rook (shares an edge only) --- use a chessboard analogy.
  - Distance-based: all locations within X km are neighbors.
  - k-Nearest: each location has exactly k neighbors.
  - "Always justify your choice of W in a report."
- The hypothesis test: Mention both the z-test (asymptotic) and the permutation test (shuffle values 999 times). The permutation test is more robust and easier to explain intuitively.

#board-box[
  Write the full Moran's I formula:

  $ I = n / (sum_(i) sum_(j) w_(i j)) dot (sum_(i) sum_(j) w_(i j) (x_i - overline(x))(x_j - overline(x))) / (sum_(i) (x_i - overline(x))^2) $

  Break it down in words next to the formula:
  - $n$ = number of locations
  - $x_i$ = observed value at location $i$
  - $overline(x)$ = global mean
  - $w_(i j)$ = 1 if $i$ and $j$ are neighbors, 0 otherwise

  Write the interpretation:
  $ I approx +1 : "strong positive (clustered)" $
  $ I approx 0 : "no spatial pattern (random)" $
  $ I approx -1 : "strong negative (checkerboard)" $

  Draw a small 3#sym.times 3 grid to illustrate the spatial weights matrix *W*. Shade the center cell and mark its Queen neighbors (all 8 surrounding cells) vs.\ Rook neighbors (only 4 edge-sharing cells). Write: "Choice of W affects the result."

  Write the hypothesis test:
  $ H_0 : "values are randomly arranged in space" $
  $ H_a : "values exhibit spatial clustering (or dispersion)" $
  Write: "Test via z-test or permutation test (shuffle 999+ times)."
]

#tip-box[
  For the formula, consider saying: "Don't memorize this. Understand the intuition: it's asking 'do neighbors look alike?' If you can explain that, you understand Moran's I." Save the formula for reference, not for an exam.
]

== Page 13 --- Moran's I Scatter Plot #h(1fr) #timing-box(3)

*What to say:*
- This slide is _very_ visual. Let the figure do the work.
- Explain the axes: x-axis is the value at each location, y-axis is the _spatial lag_ (weighted average of its neighbors' values).
- Walk through the four quadrants:
  - *HH (upper right):* high value, high neighbors $arrow$ hot spot.
  - *LL (lower left):* low value, low neighbors $arrow$ cold spot.
  - *HL (lower right):* high value, low neighbors $arrow$ spatial outlier.
  - *LH (upper left):* low value, high neighbors $arrow$ spatial outlier.
- Key insight: "The slope of the regression line through this scatter plot _is_ Moran's I." If the slope is steep and positive, you have strong positive autocorrelation. If points are scattered everywhere, Moran's I is near zero.
- "Most points in HH and LL means positive autocorrelation. This is what we expect for something like temperature or rainfall."

#board-box[
  Draw a large set of axes:
  - x-axis: $x_i - overline(x)$ (value at location $i$, centered)
  - y-axis: $sum_j w_(i j)(x_j - overline(x))$ (spatial lag --- average of neighbors, centered)

  Draw dashed vertical and horizontal lines through the origin, creating four quadrants. Label each quadrant:

  #table(
    columns: (1fr, 1fr),
    inset: 0.4em,
    stroke: 0.5pt + luma(200),
    [*LH* (upper left) \ Low value, high neighbors \ "Spatial outlier"], [*HH* (upper right) \ High value, high neighbors \ "Hot spot"],
    [*LL* (lower left) \ Low value, low neighbors \ "Cold spot"], [*HL* (lower right) \ High value, low neighbors \ "Spatial outlier"],
  )

  Draw a regression line through the scatter with a positive slope. Label: "Slope = Moran's I."

  Write: "Most points in HH + LL $arrow$ positive autocorrelation. Points in all four $arrow$ no pattern."
]

== Page 14 --- Local Moran's I (LISA) #h(1fr) #timing-box(3)

*What to say:*
- Motivate the transition: "Global Moran's I gives _one number_ for the whole study area. But we often want to know _where_ the clusters are, not just _whether_ they exist."
- LISA decomposes the global statistic into per-location contributions. Each location $i$ gets its own $I_i$ and its own significance test.
- The LISA cluster map is the main output. Walk through the color coding:
  - Red (HH): hot spots --- clusters of high values.
  - Blue (LL): cold spots --- clusters of low values.
  - Orange/light (HL): high outliers surrounded by low values.
  - Light blue (LH): low outliers surrounded by high values.
  - Gray/not significant: no detectable local pattern.
- "LISA maps are extremely useful for environmental management. They answer: _where exactly_ are the problem areas?"

#board-box[
  Write the Local Moran's I formula:

  $ I_i = (x_i - overline(x)) / s^2 sum_(j) w_(i j)(x_j - overline(x)) $

  where $s^2 = 1/n sum_(i)(x_i - overline(x))^2$ is the variance.

  Write: "Each location gets its own $I_i$ value and its own significance test."

  Write: "Global Moran's I $=$ average of all local $I_i$ values (approximately)."

  Draw a color-coded key for the LISA cluster map:
  - Red: *HH* (hot spot --- high value, high neighbors)
  - Blue: *LL* (cold spot --- low value, low neighbors)
  - Orange: *HL* (high outlier amid low neighbors)
  - Light blue: *LH* (low outlier amid high neighbors)
  - Gray: *Not significant*

  Sketch a rough map outline with colored regions to show how the Moran scatter quadrants map onto actual geography.
]

#tip-box[
  Draw the connection: "The Moran scatter plot shows the _quadrants_. The LISA map shows _where on the actual map_ each quadrant is located. It's the spatial version of the scatter plot."
]

== Page 15 --- Example: Is Water Quality Spatially Clustered? #h(1fr) #timing-box(5)

*What to say:*
- This ties together Global Moran's I, the scatter plot, and LISA into one applied scenario.

#board-box[
  Write the given result prominently:

  $ I = 0.62 #h(2em) p < 0.001 $

  Write the interpretation in plain English: "Watersheds near each other tend to have _similar_ DO levels. Strong positive spatial autocorrelation."

  Draw a quick sketch of the Bay with annotations:
  - Mid-Bay region: shade and label "LL cluster (cold spot) --- the hypoxic zone"
  - Upper Bay: mark one watershed and label "LH outlier --- low DO amid healthy neighbors"

  Write the environmental explanation: "LL cluster = nutrient-driven oxygen depletion in the deep channel. LH outlier = localized point source (urban runoff? wastewater outfall?)."
]

#exercise-box[
  *How to run this exercise:*
  - Question 1: "Moran's I = 0.62 means watersheds near each other tend to have similar DO levels. This is strong positive spatial autocorrelation." Practice translating statistics into plain language.
  - Question 2: Most points in LL means most of the Bay has _low DO surrounded by low DO_. This is the hypoxic zone signal.
  - Question 3: The LL cluster in the mid-Bay is the hypoxic zone --- driven by nutrient loading, stratification, and poor bottom-water circulation. This is where statistics meets environmental science.
  - Question 4: An LH outlier (low DO among high-DO neighbors) could be a locally impacted watershed --- point source pollution, urban runoff, or a wastewater treatment outfall. "One bad watershed in an otherwise healthy region."
  - This is a good moment to show students that spatial statistics can _identify_ anomalies that deserve further investigation.
]

#transition-box[
  "Autocorrelation tells us that spatial structure exists. Now let's _exploit_ that structure. If nearby values are similar, we can _predict_ values at locations where we have no measurements. That's spatial interpolation."
]

#pagebreak()

// =========================================================================
= Part 6: Spatial Interpolation --- IDW (Pages 16--19)
// =========================================================================

== Page 16 --- Spatial Interpolation: Predicting the Unknown #h(1fr) #timing-box(2)

*What to say:*
- This is a transition slide. The figure shows the motivating problem: sparse monitoring stations on the left, a continuous interpolated surface on the right.
- Emphasize the practical need: "Monitoring stations are expensive. We can't put a sensor everywhere. But managers need _wall-to-wall_ maps. Interpolation fills the gaps."
- Point to the figure: "The left panel shows what we _have_ (a few dots). The right panel shows what we _want_ (a continuous surface that reveals the hypoxic zone)."

#board-box[
  Sketch two side-by-side panels:

  *Left:* Draw a rectangle with 5--6 dots scattered inside. Label each dot with a value (e.g., 8.2, 3.1, 5.5, 7.0, 2.8). Write "?" between the dots. Label: "What we _have_ --- sparse observations."

  *Right:* Draw the same rectangle, now filled with contour lines or shading (smooth gradient). Label: "What we _want_ --- a continuous prediction surface."

  Write: "Interpolation: use _known values_ at measured locations to _predict_ values at unmeasured locations."
]

== Page 17 --- Inverse Distance Weighting (IDW) #h(1fr) #timing-box(3)

*What to say:*
- IDW is the simplest interpolation method. The intuition: "To predict the value at an unknown location, take a weighted average of the known values. Give _more weight_ to nearby stations and _less weight_ to distant ones."
- Walk through the formula:
  - The weights $w_i = 1 / d^p$ decay with distance. Closer stations contribute more.
  - The predicted value is just the weighted average: $hat(z) = (sum w_i z_i) / (sum w_i)$.
- The power parameter $p$ controls how quickly the weights decay:
  - $p = 1$: gentle decay, many stations contribute $arrow$ smooth surface.
  - $p = 2$: the standard default.
  - $p = 5$+: sharp decay, only the very nearest stations matter $arrow$ "bull's-eye" artifacts.
- Mention strengths and weaknesses:
  - Strengths: simple, fast, exact interpolator (passes through data points).
  - Weaknesses: no uncertainty estimate, bull's-eye artifacts, ignores spatial structure.
  - "The biggest weakness: IDW doesn't tell you _how confident_ the prediction is."

#board-box[
  Write the IDW prediction formula:

  $ hat(z)(s_0) = (sum_(i=1)^n w_i dot z(s_i)) / (sum_(i=1)^n w_i) $

  Write the weight definition:

  $ w_i = 1 / d(s_0, s_i)^p $

  Annotate each symbol:
  - $hat(z)(s_0)$ = predicted value at unknown location $s_0$
  - $z(s_i)$ = observed value at station $i$
  - $d(s_0, s_i)$ = distance from prediction point to station $i$
  - $p$ = power parameter

  Draw a small diagram: a star ($s_0$) surrounded by three dots (stations). Draw dashed lines from the star to each dot and label with $d_1$, $d_2$, $d_3$. Write weights next to each: "Close $arrow$ high weight, Far $arrow$ low weight."

  Write the power parameter effect:

  #table(
    columns: (auto, auto),
    inset: 0.4em,
    stroke: 0.5pt + luma(200),
    [$p = 1$], [gentle decay $arrow$ smooth surface],
    [$p = 2$], [standard default],
    [$p = 5$+], [sharp decay $arrow$ bull's-eye artifacts],
  )
]

== Page 18 --- IDW: Effect of the Power Parameter #h(1fr) #timing-box(2)

*What to say:*
- This is a visual slide. Let the three panels speak.
- Walk left to right:
  - *$p = 1$:* Very smooth. Notice how the surface varies gradually --- even distant stations pull the prediction.
  - *$p = 2$:* Balanced. This is the default and a reasonable starting point.
  - *$p = 5$:* Sharp bull's-eye effect. Each station dominates a small area around it, and between stations the surface is flat. This is often unphysical.
- Ask the class: "Which power would you choose for temperature? For soil contamination near a factory?" (Temperature: low power for smooth trends. Contamination: possibly higher power if you expect sharp local gradients.)

#board-box[
  Sketch three weight-decay curves on the same axes to show the effect of $p$ visually:

  Draw axes: x-axis = distance $d$, y-axis = weight $w = 1 slash d^p$.

  Draw three curves:
  - $p = 1$: gentle hyperbola (slow decay). Label "$p = 1$."
  - $p = 2$: steeper curve. Label "$p = 2$."
  - $p = 5$: very steep, drops to near zero quickly. Label "$p = 5$."

  Write next to the curves: "Higher $p$ $arrow$ only nearest stations matter $arrow$ more local, more artifacts."

  Write: "Rule of thumb --- start with $p = 2$, adjust based on domain knowledge."
]

== Page 19 --- Example: Interpolating Temperature from Weather Stations #h(1fr) #timing-box(5)

*What to say:*
- This is a hands-on calculation. Give students 3--4 minutes to work through the steps (or do it as a class walk-through on the board).

#board-box[
  Write the station data on the board:

  #table(
    columns: (auto, auto, auto, auto),
    inset: 0.4em,
    stroke: 0.5pt + luma(200),
    [*Station*], [*X*], [*Y*], [*Temp (°C)*],
    [A], [2], [8], [22.1],
    [B], [5], [5], [18.5],
    [C], [8], [7], [20.3],
    [D], [3], [2], [24.8],
    [E], [7], [2], [23.0],
  )

  Write: *Predict temperature at P = (5, 3) using IDW with $p = 2$.*

  *Step 1: Compute distances.*
  $ d_A = sqrt((5-2)^2 + (3-8)^2) = sqrt(9 + 25) = sqrt(34) approx 5.83 "km" $
  $ d_B = sqrt((5-5)^2 + (3-5)^2) = sqrt(0 + 4) = 2.0 "km" $
  $ d_C = sqrt((5-8)^2 + (3-7)^2) = sqrt(9 + 16) = 5.0 "km" $
  $ d_D = sqrt((5-3)^2 + (3-2)^2) = sqrt(4 + 1) = sqrt(5) approx 2.24 "km" $
  $ d_E = sqrt((5-7)^2 + (3-2)^2) = sqrt(4 + 1) = sqrt(5) approx 2.24 "km" $

  *Step 2: Compute weights* $w_i = 1 slash d_i^2$:
  $ w_A = 1/34 approx 0.029 #h(1.5em) w_B = 1/4 = 0.250 #h(1.5em) w_C = 1/25 = 0.040 $
  $ w_D = 1/5 = 0.200 #h(1.5em) w_E = 1/5 = 0.200 $

  $sum w_i approx 0.719$

  *Step 3: Weighted average:*
  $ hat(z)(P) = (0.029 times 22.1 + 0.250 times 18.5 + 0.040 times 20.3 + 0.200 times 24.8 + 0.200 times 23.0) / 0.719 $
  $ = (0.64 + 4.63 + 0.81 + 4.96 + 4.60) / 0.719 = 15.64 / 0.719 approx 21.8 degree "C" $

  Circle the result. Write: "Station D (closest) dominates. What if D was broken and read 40°C? IDW would still trust it."
]

#exercise-box[
  *How to run this exercise:*
  - Walk through each step on the board. Pause after Step 1 and let students verify one distance.
  - The final question is critical: "What if Station D's thermometer was broken?" IDW has _no way to detect outliers_. It treats all data as equally trustworthy. This motivates Kriging.
  - If you have time, ask: "What happens if we change $p$ from 2 to 5?" (Answer: Station D's weight increases even more, pulling the prediction closer to 24.8°C.)
]

#transition-box[
  "IDW is simple and fast, but it has a fatal flaw: _no uncertainty estimate_. You don't know where the prediction is good and where it's bad. Geostatistics --- specifically Kriging --- fixes this by first _modeling_ the spatial structure."
]

#pagebreak()

// =========================================================================
= Part 7: Geostatistics --- Variograms & Kriging (Pages 20--27)
// =========================================================================

This is the most technical section. Pace carefully and lean on figures and analogies. The goal is conceptual understanding, not mathematical derivation.

== Page 20 --- Geostatistics: The Science of Spatial Prediction #h(1fr) #timing-box(2)

*What to say:*
- Frame geostatistics as the upgrade from IDW. Three key improvements: (1) model the spatial structure, (2) use that model for optimal prediction, (3) quantify uncertainty.
- Walk through the three boxes: "First, we build a variogram --- a model of how dissimilarity changes with distance. Then we use that model to compute optimal weights. Finally, we get a _variance map_ that tells us where our predictions are reliable."
- Emphasize the BLUP acronym: Best Linear Unbiased Predictor. "Kriging isn't just _a_ way to interpolate --- it's the _best_ way, given the assumptions."
- Don't go deeper here --- the next slides will develop each piece.

#board-box[
  Write the three-step geostatistics pipeline:

  #align(center)[
    *Step 1: Variogram* #sym.arrow.long *Step 2: Kriging Weights* #sym.arrow.long *Step 3: Prediction + Variance Map*
  ]

  Under each step, write a one-liner:
  - Step 1: "How does dissimilarity change with distance?"
  - Step 2: "Compute _optimal_ weights to minimize prediction error."
  - Step 3: "Predict values _and_ map where we're confident vs.\ uncertain."

  Write: *Kriging = Best Linear Unbiased Predictor (BLUP)*

  Write the comparison:
  - *IDW:* prediction only, no uncertainty
  - *Kriging:* prediction _and_ uncertainty (the key upgrade)
]

== Page 21 --- The Variogram: Fingerprint of Spatial Structure #h(1fr) #timing-box(4)

*What to say:*
- The variogram is the core concept of geostatistics. Spend time here.
- Intuition: "Take every pair of data points. Compute the squared difference in their values. Plot that against the distance between them. If Tobler's Law holds, nearby pairs will have _small_ squared differences and distant pairs will have _large_ ones."
- Walk through the formula: $hat(gamma)(h) = 1/(2N(h)) sum [z(s_i) - z(s_i + h)]^2$. The key: it's an _average_ of squared differences at each lag distance $h$.
- Point to the figure:
  - The dots are the _empirical variogram_ (computed from data).
  - The curve is the _fitted model_ (spherical, exponential, or Gaussian).
  - The model captures the smooth trend: semivariance increases with distance and then levels off.
- "The variogram is like a fingerprint --- it uniquely describes the spatial structure of your data."

#board-box[
  Write the empirical variogram formula:

  $ hat(gamma)(h) = 1 / (2 N(h)) sum_(i=1)^(N(h)) [z(s_i) - z(s_i + h)]^2 $

  Annotate each symbol:
  - $h$ = lag distance (separation between a pair of points)
  - $N(h)$ = number of point pairs separated by distance $h$
  - $z(s_i)$ = observed value at location $s_i$
  - $hat(gamma)(h)$ = semivariance at lag $h$

  Sketch an empirical variogram:
  - x-axis: *Distance ($h$)*
  - y-axis: *Semivariance $gamma(h)$*
  - Draw scattered dots that rise from near zero and level off at a plateau.
  - Draw a smooth fitted curve (S-shaped rise to a plateau) through the dots.
  - Label the three key features on the sketch:
    - *Nugget ($C_0$):* y-intercept (where the curve meets the y-axis)
    - *Sill ($C_0 + C_1$):* the plateau value
    - *Range ($a$):* the x-value where the curve reaches the sill

  This sketch will be used again on the next slide. Keep it visible.
]

#tip-box[
  Use a concrete analogy: "Imagine measuring temperature at pairs of weather stations. Stations 1 km apart will have very similar temperatures (low semivariance). Stations 100 km apart will have very different temperatures (high semivariance). The variogram captures this relationship."
]

== Page 22 --- Reading the Variogram #h(1fr) #timing-box(3)

*What to say:*
- This slide breaks the variogram into its three parameters. Spend time on each.
- *Nugget ($C_0$):* The semivariance at distance zero. "If you could put two sensors at _exactly_ the same location, they'd still disagree a bit --- that's measurement error. Plus, there may be real variation at scales smaller than your station spacing."
  - Large nugget = noisy data. Small nugget = clean, gradually varying data.
- *Range ($a$):* "Beyond this distance, observations are _independent_. Knowing the value here tells you nothing about the value _there_."
  - The range determines how far Kriging can "reach" for useful information.
  - Practical implication: if your station spacing is larger than the range, Kriging can't help much.
- *Sill ($C_0 + C_1$):* The total variance. The plateau where the variogram levels off.
  - The partial sill ($C_1$) is the _spatially structured_ variance. A high partial sill relative to the nugget means most of the variation is spatial --- ideal for Kriging.
- End with the bottom-line message: "A variogram with a high nugget relative to the sill means most variation is _noise_, not spatial structure. Kriging won't help much in that case."

#board-box[
  Annotate the variogram sketch from the previous slide (or redraw a clean version) with detailed labels:

  Draw a clear variogram curve with annotations:

  *Nugget ($C_0$):*
  - Mark the y-intercept. Draw a bracket from 0 to $C_0$.
  - Write: "measurement error + micro-scale variability"

  *Range ($a$):*
  - Draw a vertical dashed line from the x-axis up to the sill. Mark the x-value as $a$.
  - Write: "beyond this distance, observations are independent"

  *Sill ($C_0 + C_1$):*
  - Draw a horizontal dashed line at the plateau. Label: "total variance"

  *Partial sill ($C_1 = "Sill" - "Nugget"$):*
  - Draw a bracket from $C_0$ to the sill. Label: "spatially structured variance"

  Write the diagnostic rule:
  $ "Nugget" / "Sill" approx 1 #h(1em) arrow.long.double #h(1em) "mostly noise, Kriging won't help" $
  $ "Nugget" / "Sill" approx 0 #h(1em) arrow.long.double #h(1em) "strong spatial structure, Kriging works well" $
]

== Page 23 --- Example: Reading Real Variograms #h(1fr) #timing-box(5)

*What to say:*
- This is a think-pair-share exercise. Give students 2--3 minutes to discuss scenarios in pairs, then walk through each.

#board-box[
  Sketch four small variograms side by side, one for each scenario:

  *Scenario A --- Soil pH:*
  - Small nugget (starts near zero), gradual rise, range $approx$ 500 m, moderate sill.
  - Draw: low starting point, smooth S-curve leveling off at moderate height.

  *Scenario B --- Rainfall over mountains:*
  - Small nugget, but potentially _different_ curves in different directions (anisotropy).
  - Draw: two curves --- one gentle (along the slope), one steep (across the ridge).
  - Label: "Anisotropic --- structure depends on direction."

  *Scenario C --- City air quality (PM#sub[2.5]):*
  - Large nugget (almost reaching the sill), short range, high sill.
  - Draw: curve that starts high and levels off quickly.
  - Write: "Nugget/Sill $approx$ 0.7 --- mostly noise."

  *Scenario D --- Sea surface temperature:*
  - Very small nugget, very long range (hundreds of km), low sill.
  - Draw: curve that starts near zero and rises slowly over a very long x-axis.
  - Write: "Kriging can interpolate reliably over large distances."
]

#exercise-box[
  - *Scenario A (soil pH):* Textbook variogram --- Kriging works well here.
  - *Scenario B (rainfall):* Mention anisotropy (directional variograms) as an advanced topic.
  - *Scenario C (PM#sub[2.5]):* Kriging will struggle because the nugget dominates --- most variation is noise, not spatial structure.
  - *Scenario D (SST):* Very long range means Kriging can reach far --- ideal for ocean applications.
  - If short on time, do scenarios A and C as a class and leave B and D as homework.
]

== Page 24 --- Ordinary Kriging #h(1fr) #timing-box(3)

*What to say:*
- Frame Kriging as "IDW with a brain." Both compute a weighted average, but Kriging uses the variogram to determine the weights.
- *The prediction:* $hat(z)(s_0) = sum lambda_i z(s_i)$. Looks like IDW. But the weights $lambda_i$ are found by _solving a system of equations_ that minimizes prediction variance while ensuring unbiasedness.
- Key difference from IDW: "In IDW, a station's weight depends only on its distance to the prediction point. In Kriging, the weight also depends on the _spatial configuration of all stations_. If two stations are close to each other, they share information --- Kriging will down-weight one of them."
- *The uncertainty:* $sigma^2_K$ gives a prediction variance at every location. This is the game-changer.
  - Low variance near stations, high variance far from stations.
  - The variance depends only on station locations and the variogram --- _not_ on the actual data values. This has a profound practical implication (next slide).
- Don't try to derive the Kriging system of equations. The conceptual understanding is what matters.

#board-box[
  Write the Kriging prediction:

  $ hat(z)(s_0) = sum_(i=1)^n lambda_i dot z(s_i) $

  Write the constraint:

  $ sum_(i=1)^n lambda_i = 1 #h(2em) "(unbiasedness)" $

  Write: "The weights $lambda_i$ minimize prediction error using the variogram model."

  Write the Kriging variance:

  $ sigma^2_K (s_0) = sum_(i=1)^n lambda_i gamma(s_i, s_0) + mu $

  where $mu$ is a Lagrange multiplier from the constrained optimization.

  Draw a key comparison diagram:

  *IDW:* draw a star ($s_0$) with three stations. Weights depend _only_ on distances $d_1, d_2, d_3$.

  *Kriging:* draw the same star with three stations, but now also draw dashed lines _between_ the stations themselves. Write: "Weights also depend on the _configuration_ of stations. Two nearby stations share information $arrow$ Kriging downweights one."

  Write the key properties of Kriging variance:
  - Low near observations, high far from observations
  - High when nugget is large
  - *Does not depend on the actual data values!*

  Write the one-liner: "IDW tells you _what_. Kriging tells you _what_ and _how much to trust it_."
]

#tip-box[
  A powerful one-liner: "IDW tells you _what_ the prediction is. Kriging tells you what the prediction is _and how much you should trust it_."
]

== Page 25 --- Kriging: Prediction and Uncertainty #h(1fr) #timing-box(2)

*What to say:*
- This is a visual payoff slide. Let the figure do the work.
- *Left panel (prediction):* "Smooth transitions between stations. The surface respects the variogram's spatial structure."
- *Right panel (variance):* "Yellow/low near stations, red/high far away. This map tells managers exactly _where_ they need more data."
- Emphasize: "The variance map is often _more useful_ than the prediction map for decision-making. It answers: 'Where are we confident, and where are we guessing?'"

#board-box[
  No equations needed --- this is a visual slide. Write the key interpretation:

  #table(
    columns: (1fr, 1fr),
    inset: 0.5em,
    stroke: 0.5pt + luma(200),
    [*Prediction map*], [*Variance map*],
    [Shows estimated values everywhere], [Shows _reliability_ of those estimates],
    [Smooth transitions between stations], [Low near stations, high far away],
    [Answers: "What is the value here?"], [Answers: "Should I trust this prediction?"],
  )

  Write: "The variance map is often _more useful_ than the prediction map for managers."

  Write: "$sigma^2_K$ depends on station locations + variogram, _not_ on the data values. You can compute it _before_ collecting data."
]

== Page 26 --- IDW vs. Kriging: A Direct Comparison #h(1fr) #timing-box(2)

*What to say:*
- This is a summary/comparison slide. Walk through the two boxes side by side.
- IDW: simple, fast, no model needed. But no uncertainty, bull's-eye artifacts, and weights ignore spatial structure.
- Kriging: requires variogram modeling (more effort), but provides optimal predictions and uncertainty estimates.
- Practical guidance: "Use IDW for quick exploration or when you have very dense data. Use Kriging for formal analysis, sparse data, or when you need to communicate confidence."
- "If you're writing a report or a paper, Kriging is almost always the right choice because it comes with uncertainty. If you're doing a quick-and-dirty exploration in the field, IDW is fine."

#board-box[
  Draw a comparison table:

  #table(
    columns: (auto, 1fr, 1fr),
    inset: 0.5em,
    stroke: 0.5pt + luma(200),
    [], [*IDW*], [*Kriging*],
    [Model needed?], [No], [Yes (variogram)],
    [Weight basis], [Distance only], [Distance + spatial config],
    [Uncertainty?], [No], [Yes ($sigma^2_K$ map)],
    [Optimal?], [No], [Yes (BLUP)],
    [Artifacts], [Bull's-eye at high $p$], [Smooth],
    [Speed], [Fast], [Slower],
    [When to use], [Quick look, dense data], [Formal analysis, sparse data],
  )

  Write: "For a report or publication $arrow$ Kriging. For a quick field estimate $arrow$ IDW."
]

== Page 27 --- Example: Designing a Monitoring Network #h(1fr) #timing-box(5)

*What to say:*
- This exercise connects Kriging variance to _real-world decision-making_. It's the capstone exercise.

#board-box[
  Write the key insight prominently:

  #align(center)[
    #rect(
      inset: 0.6em,
      stroke: 1pt + board-col,
      [$ sigma^2_K "depends on station locations" + "variogram only" $
      $ arrow.long.double #h(0.5em) "NOT on the data values themselves" $]
    )
  ]

  Write the implication: "You can design an optimal monitoring network _before collecting any data_. This is called *variance-guided sampling design*."

  Sketch a rectangle (study area) with dots (existing stations). Shade one corner red (high $sigma^2_K$, no stations nearby). Draw proposed new station locations spread across the red zone. Show that the red zone would turn yellow (lower variance) after adding stations.

  Write the decision rule: "If $sqrt(sigma^2_K) < 0.5$ mg/kg everywhere $arrow$ network is sufficient. If not $arrow$ add more stations in high-variance regions."
]

#exercise-box[
  *How to run this exercise:*
  - Question 1: Uncertainty is high in the NW corner because _there are no stations there_. Kriging variance depends on station locations --- no nearby data means high variance.
  - Question 2: Spread the 5 stations across the red region, not cluster them. Clustered stations share information (redundancy), so spreading them reduces variance more efficiently.
  - Question 3: After adding stations: (a) the prediction surface will change in the NW region as new data informs it; (b) the variance map will show reduced uncertainty (yellow instead of red) where the new stations are placed.
  - Question 4: Compare $sqrt(sigma^2_K)$ at every grid cell to the 0.5 mg/kg threshold. If any cell exceeds it, more stations are needed. This is _variance-guided sampling design_.
  - The Key Insight box is the most important point: let it sink in.
]

#transition-box[
  "We've covered a lot of techniques today. The natural question is: _which one should I use?_ The last section provides a decision framework."
]

#pagebreak()

// =========================================================================
= Part 8: Choosing the Right Technique & Wrap-Up (Pages 28--30)
// =========================================================================

== Page 28 --- Choosing the Right Spatial Analysis Technique #h(1fr) #timing-box(2)

*What to say:*
- Walk through the decision framework figure. The key message: _match the technique to the question_.
  - "Do I want to _describe_ the spatial distribution?" $arrow$ Descriptive statistics.
  - "Is the pattern _random or clustered_?" $arrow$ NNI, KDE.
  - "Is the variable _spatially autocorrelated_?" $arrow$ Moran's I.
  - "_Where_ are the clusters?" $arrow$ LISA.
  - "Can I _predict_ values at unmeasured locations?" $arrow$ IDW or Kriging.
  - "Do I need _uncertainty_?" $arrow$ Kriging.
- Emphasize the closing line: "Complexity is only justified when the simpler method cannot answer your question. Start simple, add complexity only when needed."

#board-box[
  Write a decision tree on the board:

  *"What is your question?"*

  + *Where is the center/spread?* $arrow$ Mean Center, Std Distance, Ellipse
  + *Is the pattern random?* $arrow$ Nearest Neighbor Index (NNI)
  + *Where is density high?* $arrow$ Kernel Density Estimation (KDE)
  + *Are values spatially correlated?* $arrow$ Moran's I (global)
  + *Where are the hot/cold spots?* $arrow$ LISA (local Moran's I)
  + *Predict values at unsampled locations?*
    - Quick estimate, no uncertainty needed $arrow$ *IDW*
    - Formal analysis, need uncertainty $arrow$ *Kriging*

  Write at the bottom: "Start simple. Add complexity only when the simpler method _cannot_ answer your question."
]

== Page 29 --- Key Takeaways #h(1fr) #timing-box(2)

*What to say:*
- Walk through the summary table row by row. This is a rapid review --- don't re-explain, just anchor each technique to its one-sentence purpose.
- Point out the resources at the bottom. Mention which ones you recommend for students who want to go deeper:
  - "Spatial Data Science with R" is the most comprehensive free resource.
  - PySAL is the Python equivalent.
  - Gimond's "Intro to GIS and Spatial Analysis" is beginner-friendly and well-illustrated.

#board-box[
  Write a condensed version of the summary table --- just technique names and one-word purpose:

  + *Mean Center / Std Distance* --- describe
  + *NNI* --- test randomness
  + *KDE* --- visualize density
  + *Moran's I* --- test autocorrelation
  + *LISA* --- locate clusters
  + *IDW* --- predict (no uncertainty)
  + *Variogram* --- model spatial structure
  + *Kriging* --- predict + uncertainty

  Leave this on the board as students review. It serves as a mental map of the entire lecture.
]

== Page 30 --- Questions #h(1fr) _remaining time_

*What to say:*
- Open the floor. If no questions, prompt with:
  - "What's the one thing you're still confused about?"
  - "If you had to interpolate river discharge across a watershed, which method would you start with and why?"
  - "Can anyone think of an environmental variable where Tobler's Law _doesn't_ hold?"

#board-box[
  Erase the board and leave only the condensed technique list from Page 29. This gives students a reference while they formulate questions.

  If a student asks a question that benefits from a sketch or equation, use the board live. Common questions that benefit from board work:
  - "What's the difference between the variogram and the correlogram?" $arrow$ sketch both side by side (variogram rises, correlogram decays --- they are mirrors).
  - "Why does Kriging variance not depend on data values?" $arrow$ write $sigma^2_K = f("station locations", gamma)$ and note that $z(s_i)$ does not appear.
  - "What if I have a trend in my data?" $arrow$ sketch a linear trend and explain that Ordinary Kriging assumes a constant mean; Universal Kriging handles trends.
]

#pagebreak()

// =========================================================================
= Appendix A: All Equations at a Glance
// =========================================================================

A quick reference for all equations used in the lecture, in the order they appear. Use this to prepare your board work before class.

#set text(size: 10pt)

*Spatial Descriptive Statistics (Page 4):*
$ overline(x) = 1/n sum x_i #h(3em) overline(y) = 1/n sum y_i #h(3em) "SD" = sqrt(1/n sum d_i^2) $
$ overline(x)_w = (sum w_i x_i) / (sum w_i) #h(3em) overline(y)_w = (sum w_i y_i) / (sum w_i) $

*Nearest Neighbor Index (Page 7):*
$ "NNI" = overline(d)_"observed" / overline(d)_"expected" #h(3em) overline(d)_"expected" = 1 / (2 sqrt(n slash A)) $

*KDE (Page 9):*
$ hat(f)(x) = 1 / (n h) sum_(i=1)^n K lr((x - x_i) / h) $

*Global Moran's I (Page 12):*
$ I = n / (sum_(i) sum_(j) w_(i j)) dot (sum_(i) sum_(j) w_(i j) (x_i - overline(x))(x_j - overline(x))) / (sum_(i) (x_i - overline(x))^2) $

*Local Moran's I / LISA (Page 14):*
$ I_i = (x_i - overline(x)) / s^2 sum_(j) w_(i j)(x_j - overline(x)) $

*Inverse Distance Weighting (Page 17):*
$ hat(z)(s_0) = (sum_(i=1)^n w_i dot z(s_i)) / (sum_(i=1)^n w_i) #h(3em) w_i = 1 / d(s_0, s_i)^p $

*Empirical Variogram (Page 21):*
$ hat(gamma)(h) = 1 / (2 N(h)) sum_(i=1)^(N(h)) [z(s_i) - z(s_i + h)]^2 $

*Ordinary Kriging --- Prediction (Page 24):*
$ hat(z)(s_0) = sum_(i=1)^n lambda_i dot z(s_i) #h(3em) "subject to" sum_(i=1)^n lambda_i = 1 $

*Ordinary Kriging --- Variance (Page 24):*
$ sigma^2_K (s_0) = sum_(i=1)^n lambda_i gamma(s_i, s_0) + mu $

#set text(size: 11pt)

#pagebreak()

// =========================================================================
= Appendix B: Common Student Questions
// =========================================================================

*Q: What if my data violates Tobler's Law?*\
A: Some environmental variables have discontinuities (e.g., soil type across a geological fault, temperature across a lake boundary). In these cases, standard geostatistics may not apply directly. Solutions include stratified analysis (separate variograms per zone) or co-Kriging with auxiliary variables.

*Q: How do I choose the right bandwidth for KDE?*\
A: Cross-validation (leave-one-out) is the standard approach. In practice, try multiple bandwidths and look for stable features that persist across a range of bandwidths --- those are likely real patterns, not noise.

*Q: Is Kriging always better than IDW?*\
A: Not necessarily. If your data is very dense and you don't need uncertainty, IDW is fine and faster. Kriging also assumes stationarity (the spatial structure is the same everywhere), which may not hold for large or heterogeneous study areas.

*Q: What's the difference between Ordinary Kriging and other types?*\
A: Ordinary Kriging assumes an unknown but constant mean. Simple Kriging assumes a known mean. Universal Kriging allows a spatially varying mean (trend). For most applications, Ordinary Kriging is the right starting point.

*Q: Can I Krige categorical data (e.g., land cover types)?*\
A: Not directly. Kriging is for continuous variables. For categorical data, consider Indicator Kriging (Krige the probability of each class) or machine learning approaches.
