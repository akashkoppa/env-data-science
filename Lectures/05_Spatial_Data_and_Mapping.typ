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
  title: "Spatial Data and Mapping",
  author: "Instructor: Akash Koppa",
  date: "Lecture 5 of Spring Semester 2026",
  body
)



// =============================================================================
// PART 1: WHY SPATIAL DATA?
// =============================================================================

#lecture-slide(title: "Why Does Location Matter?")[
  #align(center)[#image("/Lectures/Data/05_Spatial/05_proximity.png", height: 20em)]
  #v(0.3em)
  #text(size: 0.85em)[*Proximity*: Pollution decays with distance from the source. A sensor at 50 m tells a different story than one at 5 km.]
]

#lecture-slide(title: "Why Does Location Matter?")[
  #align(center)[#image("/Lectures/Data/05_Spatial/05_spatial_patterns.png", height: 20em)]
  #v(0.3em)
  #text(size: 0.85em)[*Spatial Patterns*: Deforestation clusters along roads and rivers---detecting the pattern requires knowing _where_.]
]

#lecture-slide(title: "Why Does Location Matter?")[
  #align(center)[#image("/Lectures/Data/05_Spatial/05_scale.png", height: 22em)]
  #v(0.3em)
  #text(size: 0.85em)[*Scale*: A drought at one station looks different from one mapped across a continent. Scale changes the story.]
]


// =============================================================================
// PART 2: THE TWO SPATIAL MODELS
// =============================================================================

#lecture-slide(title: "Vector vs. Raster: Two Ways to Represent the World")[
  #align(center)[#image("/Lectures/Data/05_Spatial/05_vector_vs_raster.png", height: 20em)]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    align: left,
    [
      *Vector* = discrete objects with precise boundaries
      - *Points*: stations, cities · *Lines*: rivers, roads · *Polygons*: watersheds, borders
      - Each object carries a *geometry* + *attributes*
    ],
    [
      *Raster* = continuous grid of cells (pixels)
      - Satellite imagery, elevation models, climate grids
      - Defined by *origin*, *resolution*, *extent*, and *bands*
    ]
  )
]


// =============================================================================
// PART 3: POINTS
// =============================================================================

#lecture-slide(title: "Points: The Simplest Geometry")[
  #grid(
    columns: (1.2fr, 2fr, 1.2fr),
    gutter: 0.8em,
    align(center + horizon)[
      A point is a single location: *(longitude, latitude)*.

      #v(0.3em)

      #set text(size: 0.75em, font: "DejaVu Sans Mono")
      #table(
        columns: (auto, auto, auto, auto),
        inset: 0.3em,
        stroke: 0.5pt + luma(200),
        fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
        [*station*], [*lon*], [*lat*], [*DO*],
        [CB3.3], [-76.38], [38.55], [7.2],
        [CB4.1], [-76.32], [38.08], [4.1],
        [CB5.2], [-76.17], [37.41], [2.3],
      )

      #v(0.3em)
      #text(size: 1em)[Geometry + attributes travel *together* as one object.]
    ],
    image("/Lectures/Data/05_Spatial/05_chesapeake_stations.png", height: 24em),
    align(center + horizon)[
      #focus-block(title: "Rich Attribute Data", color: accent-color)[
        *Physical Parameters*
        - Temp (21.5°C), Depth (4.2m)
        - Turbidity (12 NTU)

        *Chemical Properties*
        - Salinity (14.2 ppt)
        - pH (7.8), Nitrate (0.4 mg/L)

        *Metadata*
        - Sensor ID (YSI-6600)
        - Last Service (2024-05-12)
      ]
    ]
  )
]


#lecture-slide(title: "Points in Environmental Science")[
  #grid(
    columns: (2fr, 3fr),
    gutter: 1.5em,
    [
      *Where do points show up?*
      - Water quality monitoring stations
      - GPS coordinates of species sightings
      - PM#sub[2.5] air quality sensor networks
      - Earthquake epicenters
      - Weather stations and rain gauges
      - Soil sampling locations

      #v(0.3em)

      _Why not just use a spreadsheet?_ Because spatial points let you compute *distances*, *densities*, and *nearest neighbors*.
    ],
    image("/Lectures/Data/05_Spatial/05_earthquake_map.png", height: 20em),
  )
]


#lecture-slide(title: "Problem: Placing a New Monitoring Station")[
  #align(center)[Budget allows *one new station*. Where should it go to maximize information gain?]

  #v(0.3em)

  #grid(
    columns: (1fr, 1.5fr, 1fr),
    gutter: 0.8em,
    align(center + horizon)[
      #focus-block(title: "Geometric Strategy", color: accent-color)[
        + Compute *Voronoi tessellation* to partition space by nearest station
        + Identify cells with *largest area* = biggest coverage gaps
        + Consider environmental gradients (salinity, depth, land use)
        + Use *distance matrices* to find the most isolated region
        + Place new station in the largest gap, weighted by environmental variability
      ]
    ],
    align(center + horizon)[#image("/Lectures/Data/05_Spatial/05_voronoi_coverage.png", height: 22em)],
    align(center + horizon)[
      #focus-block(title: "Alternative Strategies", color: discuss-color)[
        *Geostatistics (Kriging)*
        - Minimize prediction error variance.

        *Isohyetal Method*
        - Draw contours from existing stations; place new ones where contour spacing is widest.

        *Inverse Distance Weighting*
        - Interpolate using nearby values; target areas with highest interpolation uncertainty.
      ]
    ]
  )
]


// =============================================================================
// PART 4: LINES
// =============================================================================

#lecture-slide(title: "Lines: Connected Sequences of Points")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align(center + horizon)[
      Lines have *length and direction* but no area.

      #v(0.3em)

      *Properties*
      - *Length*: distance along line
      - *Direction*: upstream/downstream
      - *Connectivity*: form *networks*
      - *Topology*: what connects?

      #v(0.3em)

      *Examples*
      - River/stream networks
      - Animal GPS trajectories
      - Contaminant pathways
      - Roads fragmenting habitat
    ],
    align(center + horizon)[#image("/Lectures/Data/05_Spatial/05_stream_network.png", height: 25em)],
  )
]


// =============================================================================
// PART 5: POLYGONS
// =============================================================================

#lecture-slide(title: "Polygons: Bounded Regions")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align(center + horizon)[
      Closed rings defining *area*, *perimeter*. Can be adjacent, nested, or overlapping.

      #v(0.3em)

      *Examples*
      - Watershed boundaries
      - Land use / land cover zones
      - National parks, reserves
      - FEMA flood zones
      - Species habitat ranges

      #v(0.3em)

      Can have *holes* or be a *multi-polygon* (one state, many islands).
    ],
    align(center + horizon)[#image("/Lectures/Data/05_Spatial/05_watersheds.png", height: 25em)],
  )
]


#lecture-slide(title: "Problem: Which Communities Are in the Flood Zone?")[
  Which communities lie within the *100-year floodplain*? Data: FEMA flood zones + census tracts.

  #v(0.3em)

  #grid(
    columns: (3fr, 2fr),
    gutter: 1em,
    image("/Lectures/Data/05_Spatial/05_flood_overlay.png", height: 22em),
    [
      #focus-block(title: "Solution Steps", color: accent-color)[
        + *Intersect* flood zone polygons with census tract polygons
        + Compute area of each intersection fragment
        + Calculate *fraction flooded* per tract: intersection area / tract area
        + *Spatial join*: attach population data to intersection results
        + Estimate *at-risk population* = fraction #sym.times total population
      ]

      #v(0.3em)

      _This is impossible in a spreadsheet---you need the geometry._
    ]
  )
]


// =============================================================================
// PART 6: THE SIMPLE FEATURES STANDARD
// =============================================================================

#lecture-slide(title: "Putting It Together: Simple Features")[
  The *Simple Features* standard (ISO 19125) is how vector data is stored. Every feature is a row in a table where one column holds the *geometry* and the rest hold *attributes*.

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      #set text(size: 0.8em, font: "DejaVu Sans Mono")
      #table(
        columns: (auto, auto, auto, auto),
        inset: 0.4em,
        stroke: 0.5pt + luma(200),
        fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
        [*name*], [*type*], [*area_km2*], [*geometry*],
        [Patuxent], [watershed], [2337], [POLYGON((...))],
        [Potomac], [watershed], [38000], [POLYGON((...))],
        [James], [watershed], [26164], [POLYGON((...))],
      )

      #v(0.5em)

      *File formats*
      - *Shapefile* (`.shp`): legacy, widely used, multi-file
      - *GeoJSON* (`.geojson`): text-based, web-friendly
      - *GeoPackage* (`.gpkg`): modern, single-file, recommended
    ],
    [
      #v(1em)
      #align(center)[
        #diagram(
          node-stroke: 1pt,
          spacing: (3em, 2em),
          node((1,0), [*Geometry*], fill: primary-color.lighten(85%), stroke: primary-color, corner-radius: 4pt),

          node((0,1), [*Point*], fill: luma(240), stroke: luma(180), corner-radius: 4pt),
          node((1,1), [*Line*], fill: luma(240), stroke: luma(180), corner-radius: 4pt),
          node((2,1), [*Polygon*], fill: luma(240), stroke: luma(180), corner-radius: 4pt),

          node((0,2), [*Multi-\ Point*], fill: accent-color.lighten(85%), stroke: accent-color, corner-radius: 4pt),
          node((1,2), [*Multi-\ Line*], fill: accent-color.lighten(85%), stroke: accent-color, corner-radius: 4pt),
          node((2,2), [*Multi-\ Polygon*], fill: accent-color.lighten(85%), stroke: accent-color, corner-radius: 4pt),

          edge((1,0), (0,1), "-|>"),
          edge((1,0), (1,1), "-|>"),
          edge((1,0), (2,1), "-|>"),
          edge((0,1), (0,2), "-|>"),
          edge((1,1), (1,2), "-|>"),
          edge((2,1), (2,2), "-|>"),
        )
      ]
      #v(1em)
      #align(center)[
        _The Simple Features geometry hierarchy_
      ]
    ]
  )
]


// =============================================================================
// PART 7: RASTER DATA
// =============================================================================

#lecture-slide(title: "Raster Data: The World as a Grid")[
  A raster is a *regular grid of cells*---a matrix with geographic coordinates attached.

  #v(0.3em)

  #grid(
    columns: (2fr, 3fr),
    gutter: 1.5em,
    [
      *Anatomy of a raster*
      - *Extent*: geographic bounding box
      - *Resolution*: cell size (e.g., 30 m #sym.times 30 m)
      - *Origin*: corner from which cells are counted
      - *CRS*: coordinate reference system
      - *Bands*: layers (1 for elevation, 3+ for multispectral)
      - *NoData*: marks empty cells

      #v(0.3em)

      #align(center)[
        #set text(size: 0.8em, font: "DejaVu Sans Mono")
        #table(
          columns: (2.5em, 2.5em, 2.5em, 2.5em),
          inset: 0.4em,
          stroke: 0.5pt + luma(200),
          fill: (x, y) => {
            let vals = ((120, 135, 142, 150), (118, 130, 145, 155), (105, 115, 138, 160), (98, 108, 125, 148))
            let v = vals.at(y).at(x)
            rgb("#2d5a27").lighten(100% - (v - 90) * 0.8%)
          },
          [120], [135], [142], [150],
          [118], [130], [145], [155],
          [105], [115], [138], [160],
          [98], [108], [125], [148],
        )
      ]
      #align(center, text(0.8em)[_Elevation raster (meters)_])
    ],
    image("/Lectures/Data/05_Spatial/05_raster_concept.png", width: 100%),
  )
]


#lecture-slide(title: "Common Environmental Rasters")[
  #grid(
    columns: (1fr, 3fr),
    gutter: 1em,
    [
      *Sources and types*
      - *DEMs*: terrain height (SRTM 30 m)
      - *Satellite*: Landsat, Sentinel-2, MODIS
      - *Climate*: temperature, precip (ERA5)
      - *Land cover*: categorical maps
      - *NDVI*: vegetation health

      *Formats:* GeoTIFF, NetCDF, HDF5

      #v(0.3em)

      $ "NDVI" = ("NIR" - "Red") / ("NIR" + "Red") $

      Values from #sym.minus 1 (water) to +1 (dense vegetation). Computed *pixel by pixel*.
    ],
    image("/Lectures/Data/05_Spatial/05_ndvi_map.png", height: 24em),
  )
]


// =============================================================================
// PART 8: RESOLUTION
// =============================================================================

#lecture-slide(title: "Resolution: How Much Detail Can You See?")[
  Resolution is the size of each raster cell on the ground. Higher resolution = more detail, but also larger files.

  #v(0.3em)

  #align(center)[#image("/Lectures/Data/05_Spatial/05_resolution.png", height: 16em)]

  #v(0.3em)

  _A 10 m raster of the US #sym.approx 1 trillion pixels. A 1 km raster #sym.approx 10 million. When do you need 10 m?_
]


// =============================================================================
// PART 9: VECTOR VS. RASTER --- INTERACTIVE
// =============================================================================

#lecture-slide(title: "Vector or Raster?")[
  #discuss-block(title: "For Each Scenario, Which Model Would You Choose?")[
    Think about whether the phenomenon is *discrete* (clear boundaries) or *continuous* (varies smoothly across space).
  ]

  #v(0.5em)

  #set text(size: 0.9em)
  #table(
    columns: (3fr, 1fr, 1fr, 3fr),
    inset: 0.5em,
    stroke: 0.5pt + luma(200),
    fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
    [*Scenario*], [*Vector?*], [*Raster?*], [*Why?*],
    [Mapping watershed boundaries], [], [], [],
    [Surface temperature across a continent], [], [], [],
    [Locations of endangered species], [], [], [],
    [Land cover from satellite imagery], [], [], [],
    [A river network], [], [], [],
    [Urban sprawl over 20 years], [], [], [],
  )

  #v(0.5em)

  Many real analyses need *both*. Urban sprawl might use raster satellite imagery classified into land cover, then convert to vector polygons for area calculations.
]


// =============================================================================
// PART 10: COORDINATE REFERENCE SYSTEMS
// =============================================================================

#lecture-slide(title: "Coordinate Reference Systems")[
  A CRS defines how coordinates on a curved Earth map to numbers. Without one, coordinates are meaningless.

  #v(0.3em)

  #grid(
    columns: (2fr, 3fr),
    gutter: 1.5em,
    [
      *Geographic CRS* (degrees)
      - Coordinates in longitude/latitude
      - Based on a *datum*: model of Earth's shape
      - Most common: *WGS84* (EPSG:4326)
      - Units are *degrees*, not meters

      #v(0.3em)

      *Projected CRS* (meters)
      - Projects curved Earth onto flat surface
      - Coordinates in meters (or feet)
      - Every projection *distorts something*
      - Common: *UTM* (60 zones)

      #v(0.3em)

      *EPSG codes*: WGS84 = `4326`, UTM 18N = `32618`. CRS *must match* when combining datasets.
    ],
    image("/Lectures/Data/05_Spatial/05_crs_diagram.png", width: 100%),
  )
]


#lecture-slide(title: "Map Projections: Unavoidable Distortion")[
  You cannot flatten a sphere without distortion. The question is not *whether* a map distorts, but *what* it distorts.

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    [
      *Conformal* (preserves shape)

      #image("/Lectures/Data/05_Spatial/05_proj_mercator.png", height: 16em)

      Distorts *area*. Greenland looks as large as Africa (14#sym.times smaller).
    ],
    [
      *Equal-area* (preserves area)

      #image("/Lectures/Data/05_Spatial/05_proj_mollweide.png", height: 16em)

      Distorts *shape*. Essential for area comparisons.
    ],
    [
      *Equidistant* (preserves distance)

      #image("/Lectures/Data/05_Spatial/05_proj_azimuthal.png", height: 16em)

      Preserves distance from center. Useful for coverage maps.
    ],
  )
]


#lecture-slide(title: "The Mercator Problem")[
  #image("/Lectures/Data/05_Spatial/05_mercator_vs_equalarea.png", height: 19em)

  #v(0.2em)

  Using Mercator for area calculations? Tropical forests appear *smaller*, high-latitude forests *larger*. Climate policy based on these numbers would be *biased*. _Always use an equal-area projection for area calculations._
]


#lecture-slide(title: "CRS in Practice: What Goes Wrong")[
  #focus-block(title: "The #1 Source of Errors in Spatial Analysis", color: warning-color)[
    Your data appears in the wrong place---or two layers don't align---because the CRS is *missing, wrong, or mismatched*.
  ]

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *Symptoms*
      - Data plots in the middle of the ocean
      - Two layers that should overlap are thousands of km apart
      - Distance/area calculations return absurd values

      #v(0.3em)

      *Rule of thumb*
      - Store in *WGS84* for portability
      - Reproject to *local projected CRS* for analysis
      - Use *equal-area* for thematic mapping
    ],
    [
      *The fix* --- always check CRS before doing anything:

      #set text(size: 0.8em, font: "DejaVu Sans Mono")
      ```
      # R
      st_crs(data)
      st_transform(data, "EPSG:32618")

      # Python
      data.crs
      data.to_crs("EPSG:32618")
      ```

      #v(0.3em)
      #text(size: 1em)[Reproject to a common CRS *before* combining layers. Never calculate distances in degrees.]
    ]
  )
]


// =============================================================================
// PART 11: SPATIAL OPERATIONS
// =============================================================================

#lecture-slide(title: "Vector Spatial Operations")[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.8em,
    [
      #image("/Lectures/Data/05_Spatial/05_spatial_op_buffer.png", width: 100%)
      #set text(size: 0.85em)
      *Buffer*: create a zone around a feature (e.g., 500 m setback from a river)
    ],
    [
      #image("/Lectures/Data/05_Spatial/05_spatial_op_intersection.png", width: 100%)
      #set text(size: 0.85em)
      *Intersection*: area shared by two layers (flood zone #sym.inter census tracts)
    ],
    [
      #image("/Lectures/Data/05_Spatial/05_spatial_op_spatial_join.png", width: 100%)
      #set text(size: 0.85em)
      *Spatial Join*: attach attributes from one layer to another by location
    ],
  )
]


#lecture-slide(title: "More Spatial Operations")[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.8em,
    [
      #image("/Lectures/Data/05_Spatial/05_spatial_op_dissolve.png", width: 100%)
      #set text(size: 0.85em)
      *Dissolve*: merge features sharing an attribute (counties #sym.arrow state)
    ],
    [
      #image("/Lectures/Data/05_Spatial/05_spatial_op_zonal_stats.png", width: 100%)
      #set text(size: 0.85em)
      *Zonal Statistics*: summarize raster values within vector zones
    ],
    [
      #image("/Lectures/Data/05_Spatial/05_spatial_op_map_algebra.png", width: 100%)
      #set text(size: 0.85em)
      *Map Algebra*: cell-by-cell math (e.g., NDVI from two bands)
    ],
  )
]


// =============================================================================
// PART 12: INTERACTIVE PROBLEM
// =============================================================================

#lecture-slide(title: "Problem: Forest Loss in Protected Areas")[
  You have *polygon* protected areas in the Amazon and annual *raster* tree cover loss maps (Hansen et al., 30 m). Quantify deforestation inside vs. outside over 20 years.

  #v(0.3em)

  #grid(
    columns: (2fr, 3fr),
    gutter: 1.5em,
    [
      #discuss-block(title: "Class Discussion")[
        - Protected area boundary: vector or raster?
        - Tree cover loss: vector or raster?
        - How do you combine them?
        - What projection for area in the tropics?
      ]

      #v(0.3em)

      *The workflow*
      + Load polygons and rasters; harmonize CRS
      + Clip/mask raster to protected area
      + Zonal statistics: loss pixels per year
      + Convert pixels to area (30 m #sym.times 30 m)
      + Compare inside vs. outside
    ],
    image("/Lectures/Data/05_Spatial/05_amazon_deforestation.png", height: 20em),
  )
]


// =============================================================================
// PART 13: MAKING MAPS
// =============================================================================

#lecture-slide(title: "Making Maps")[
  A map is a visualization with a spatial dimension. Everything from Lecture 3 applies---but with additional cartographic elements.

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *Essential map elements*
      - Title: what is this map showing?
      - Legend: what do colors and symbols mean?
      - Scale bar: how big is this area?
      - North arrow (optional for familiar areas)
      - Data source and projection note

      #v(0.5em)

      *Color palettes matter*
      - *Sequential*: continuous data (elevation, concentration)
      - *Diverging*: anomalies with a meaningful center (temperature departure)
      - *Qualitative*: categories (land cover types)
    ],
    [
      *Types of thematic maps*
      - *Choropleth*: polygons colored by attribute (income per county)
      - *Proportional symbol*: scaled circles at point locations
      - *Dot density*: random dots within polygons for distribution
      - *Heatmap*: continuous surface from point data
      - *Raster map*: direct display of gridded data

      #v(0.5em)

      _A choropleth of "total pollution per county" makes large rural counties look worse than small urban ones. The fix: normalize by area or population._
    ]
  )
]


#lecture-slide(title: "A Good Map vs. a Bad Map")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.5em,
    image("/Lectures/Data/05_Spatial/05_bad_map.png", height: 22em),
    image("/Lectures/Data/05_Spatial/05_good_map.png", height: 22em),
  )

  #v(0.2em)

  #align(center)[_Same data, two very different maps. Cartographic design is data visualization._]
]


// =============================================================================
// PART 14: SOFTWARE
// =============================================================================

#lecture-slide(title: "Software for Spatial Data Science")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *R ecosystem*
      - `sf`: vector data (Simple Features), integrates with `dplyr` and `ggplot2`
      - `terra`: fast raster processing
      - `tmap`: thematic maps with a `ggplot2`-like grammar
      - `stars`: spatiotemporal raster arrays
      - `leaflet`: interactive web maps

      #v(0.3em)

      #set text(size: 0.75em, font: "DejaVu Sans Mono")
      ```r
      library(sf)
      library(tmap)
      ws <- st_read("chesapeake.gpkg")
      tm_shape(ws) +
        tm_polygons("nitrogen_load",
          palette = "YlOrRd")
      ```
    ],
    [
      *Python ecosystem*
      - `geopandas`: vector data as GeoDataFrames (extends `pandas`)
      - `rasterio`: reading and writing rasters
      - `xarray`: multi-dimensional arrays (great for NetCDF)
      - `folium`: interactive web maps
      - `matplotlib` + `cartopy`: publication-quality maps

      #v(0.3em)

      #set text(size: 0.75em, font: "DejaVu Sans Mono")
      ```python
      import geopandas as gpd
      ws = gpd.read_file("chesapeake.gpkg")
      ws.plot(column="nitrogen_load",
              cmap="YlOrRd",
              legend=True)
      ```
    ]
  )
]



// =============================================================================
// TAKEAWAYS
// =============================================================================

#lecture-slide(title: "Key Takeaways")[
  #set text(size: 0.8em)
  #table(
    columns: (1.5fr, 1.5fr, 2.5fr),
    inset: 0.4em,
    stroke: 0.5pt + luma(200),
    fill: (x, y) => if y == 0 { primary-color.lighten(85%) },
    [*Concept*], [*Key Term*], [*Example*],
    [Vector: Point], [Feature], [Monitoring station location],
    [Vector: Line], [Network], [River system, animal track],
    [Vector: Polygon], [Region], [Watershed boundary, flood zone],
    [Raster], [Grid cell / pixel], [Satellite image, elevation model],
    [CRS], [EPSG code], [WGS84 = 4326, UTM 18N = 32618],
    [Projection], [Distortion trade-off], [Mercator (shape) vs. Mollweide (area)],
    [Buffer], [Proximity zone], [500 m setback from a river],
    [Overlay / Intersection], [Spatial combination], [Flood zone #sym.inter census tracts],
    [Zonal statistics], [Raster + vector summary], [Mean elevation per watershed],
  )

  #v(0.3em)

  Spatial data is not just "data with coordinates." The *geometry* enables operations that are impossible with tabular data alone.

  #v(0.3em)

  *Resources:*
  #link("https://r-spatial.org/book/")[#text(fill: accent-color.darken(20%))[Spatial Data Science with R]] #sym.dot.c
  #link("https://geopandas.org/en/stable/gallery/index.html")[#text(fill: accent-color.darken(20%))[GeoPandas Gallery]] #sym.dot.c
  #link("https://geocompr.robinlovelace.net/")[#text(fill: accent-color.darken(20%))[Geocomputation with R]]
]


#lecture-slide[
  #set align(center + horizon)
  #text(2em, fill: primary-color, [Questions?])
]
