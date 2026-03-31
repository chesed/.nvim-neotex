// Minimal Light Theme - Reusable Pitch Deck Template
// Palette: minimal-light
// Colors: #2d3748 (titles), #4a5568 (subtitles), #3182ce (accent), #f7fafc (bg), #1a202c (body)
// Typography: Montserrat headings, Inter body (dark text on light)
// Best for: Data/analytics, enterprise software, clean and professional
// Touying: 0.6.3 | Theme: simple | Aspect: 16:9
// YC Compliant: 24pt+ minimum, 32pt body, 40pt h2, 48pt h1, max 10 slides

#import "@preview/touying:0.6.3": *
#import themes.simple: *

// == PARAMETERS ================================================================
// Modify these for your deck. The deck-builder agent substitutes these values.
#let company-name = [Your Company Name]
#let company-subtitle = [One-line description of what you do]
#let author-name = [Founder Name]
#let funding-round = [Seed Round]
#let funding-date = datetime.today()

// == PALETTE ===================================================================
#let palette-primary   = rgb("#2d3748")  // Dark charcoal -- titles, headings
#let palette-secondary = rgb("#4a5568")  // Medium gray -- subtitles, metadata
#let palette-accent    = rgb("#3182ce")  // Blue -- emphasis, links, markers
#let palette-bg        = rgb("#f7fafc")  // Near-white -- page background
#let palette-text      = rgb("#1a202c")  // Near-black -- body text

// == THEME SETUP ===============================================================
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: company-name,
    subtitle: company-subtitle,
    author: author-name,
    date: funding-date,
  ),
  config-colors(
    primary:          palette-primary,
    secondary:        palette-secondary,
    tertiary:         palette-accent,
    neutral:          palette-bg,
    neutral-lightest: palette-bg,
  ),
  config-page(
    fill: palette-bg,
    margin: (x: 3em, top: 2.5em, bottom: 2em),
  ),
)

// == TYPOGRAPHY ================================================================
#set text(font: ("Inter", "Liberation Sans"), size: 32pt, fill: palette-text)
#set par(leading: 0.7em, justify: false)
#set list(marker: text(fill: palette-accent)[--], spacing: 0.6em)

#show heading.where(level: 1): set text(
  font: ("Montserrat", "Liberation Sans"),
  size: 48pt, weight: "bold", fill: palette-primary,
)
#show heading.where(level: 2): set text(
  font: ("Montserrat", "Liberation Sans"),
  size: 40pt, weight: "bold", fill: palette-primary,
)

// == DETAIL TEXT SIZES (use inline in slide content as needed) =================
// 28pt -- detail text (secondary information, grid cell content)
// 26pt -- small detail (supporting data, secondary metrics)
// 24pt -- footnote/citation (minimum YC-compliant size)

// == SPACING RHYTHM (standard vertical gaps) ==================================
// #v(0.4em) -- after heading (heading -> sub-heading)
// #v(0.6em) -- after sub-heading (sub-heading -> content)
// #v(0.8em) -- between content blocks
// #v(2em)   -- title slide dramatic gap

// == CARD PATTERN (visual containers -- light theme variant) ==================
// #rect(fill: palette-bg.darken(5%), radius: 6pt, inset: 14pt, width: 100%)[
//   #text(size: 32pt, weight: "bold", fill: palette-accent)[Card Title]
//   #v(0.3em)
//   #text(size: 28pt)[Card content here]
// ]

// == TABLE PATTERN (structured data -- light theme variant) ===================
// #table(
//   columns: (1.2fr, 1fr, 1fr),
//   stroke: 0.5pt + palette-secondary.lighten(40%),
//   inset: 8pt,
//   fill: (x, y) => if y == 0 { palette-bg.darken(5%) } else { none },
//   align: left,
//   table.header([Header 1], [Header 2], [Header 3]),
//   [Data], [Data], [Data],
// )

// =============================================================================
// SLIDE 1: Title
// =============================================================================
= #company-name

#align(center)[
  #text(size: 36pt, fill: palette-secondary)[
    #company-subtitle
  ]

  #v(0.6em)

  #text(size: 28pt, fill: palette-text)[
    [TODO: One-sentence tagline that captures your value proposition]
  ]

  #v(2em)

  #text(size: 24pt, fill: palette-secondary)[
    #funding-round | [TODO: Amount] | [TODO: Timeline]
  ]
]

#speaker-note[
  Open with your name, title, and a confident one-liner about what the company does.
  Keep it under 15 seconds. A clean, minimal opening sets the tone for a data-driven pitch.
]

// =============================================================================
// SLIDE 2: Problem
// =============================================================================
== The Problem

#v(0.4em)

#text(size: 32pt, weight: "semibold", fill: palette-accent)[
  [TODO: One sentence that captures the core pain point your customers face]
]

#v(0.6em)

- [TODO: Key statistic or evidence point showing the problem is real and large]
- [TODO: Why existing solutions fail or are inadequate]
- [TODO: What happens if this problem is not solved -- the cost of inaction]

#speaker-note[
  Lead with data. For an analytics-focused pitch, quantify the pain.
  Use specific numbers and cite sources where possible.
  Keep to 3 bullets maximum -- let the data speak.
]

// =============================================================================
// SLIDE 3: Solution
// =============================================================================
== Our Solution

#v(0.4em)

#text(size: 32pt, weight: "semibold", fill: palette-accent)[
  [TODO: One sentence describing how you solve the problem]
]

#v(0.6em)

#grid(
  columns: (1fr, 1fr),
  gutter: 2.5em,
  [
    #text(weight: "bold", fill: palette-accent)[[TODO: Feature 1 Name]]
    #v(0.3em)
    #text(size: 28pt)[
      [TODO: Brief description of what this feature does and why it matters]
    ]
  ],
  [
    #text(weight: "bold", fill: palette-accent)[[TODO: Feature 2 Name]]
    #v(0.3em)
    #text(size: 28pt)[
      [TODO: Brief description of what this feature does and why it matters]
    ]
  ],
)

#speaker-note[
  Show, do not tell. If you have a product demo or data visualization, this is where it goes.
  Explain the solution in terms of the problem you just described.
  Keep the language precise and analytical.
]

// =============================================================================
// SLIDE 4: Traction
// =============================================================================
== Traction

#v(0.4em)

#text(size: 32pt, weight: "semibold", fill: palette-accent)[
  [TODO: One sentence summarizing your traction or momentum]
]

#v(0.6em)

- #text(size: 40pt, weight: "bold", fill: palette-accent)[[TODO: Key Metric 1]] #text(size: 28pt)[-- e.g., MRR, users, growth rate]
- #text(size: 40pt, weight: "bold", fill: palette-accent)[[TODO: Key Metric 2]] #text(size: 28pt)[-- e.g., retention, NPS, partnerships]
- #text(size: 40pt, weight: "bold", fill: palette-accent)[[TODO: Key Metric 3]] #text(size: 28pt)[-- e.g., pipeline, LOIs, pilots]

#speaker-note[
  This is your proof slide. Lead with your strongest metric.
  If pre-revenue, show engagement, waitlist, LOIs, or pilot results.
  Growth rate matters more than absolute numbers at seed stage.
]

// =============================================================================
// SLIDE 5: Why Us / Why Now
// =============================================================================
== Why Us / Why Now

#v(0.4em)

#text(size: 32pt, weight: "semibold", fill: palette-accent)[
  [TODO: What makes this the right team and the right moment?]
]

#v(0.6em)

#grid(
  columns: (1fr, 1fr),
  gutter: 2.5em,
  [
    #text(weight: "bold", fill: palette-primary)[Why Us]
    #v(0.3em)
    - [TODO: Unique insight or expertise]
    - [TODO: Unfair advantage or moat]
  ],
  [
    #text(weight: "bold", fill: palette-primary)[Why Now]
    #v(0.3em)
    - [TODO: Market shift or catalyst]
    - [TODO: Technology or regulatory tailwind]
  ],
)

#speaker-note[
  Investors ask "why you?" and "why now?" on every deal.
  Answer both directly. Your moat can be technical, data, network, or expertise.
  For data/analytics companies, emphasize proprietary data or algorithms.
]

// =============================================================================
// SLIDE 6: Business Model
// =============================================================================
== Business Model

#v(0.4em)

#text(size: 32pt, weight: "semibold", fill: palette-accent)[
  [TODO: One sentence describing how you make money]
]

#v(0.6em)

- [TODO: Pricing model -- e.g., SaaS subscription, usage-based, enterprise license]
- [TODO: Unit economics -- e.g., ACV, CAC, LTV, or target margins]
- [TODO: Expansion path -- e.g., upsell, cross-sell, platform fees]

#speaker-note[
  Keep it simple. Investors want to see a clear path to revenue.
  If pre-revenue, explain your planned pricing and comparable benchmarks.
  Show that you understand unit economics even if early stage.
]

// =============================================================================
// SLIDE 7: Market Opportunity
// =============================================================================
== Market Opportunity

#v(0.4em)

#text(size: 32pt, weight: "semibold", fill: palette-accent)[
  [TODO: One sentence framing the market size]
]

#v(0.6em)

- #text(weight: "bold", fill: palette-accent)[TAM:] [TODO: Total Addressable Market with source]
- #text(weight: "bold", fill: palette-accent)[SAM:] [TODO: Serviceable Addressable Market]
- #text(weight: "bold", fill: palette-accent)[SOM:] [TODO: Serviceable Obtainable Market -- your realistic 3-year target]

#v(0.4em)

#text(size: 26pt, fill: palette-secondary)[
  [TODO: Source attribution for market data]
]

#speaker-note[
  Bottom-up sizing is more credible than top-down.
  Show your SOM is realistic given your go-to-market.
  Cite specific sources for market data -- credibility matters for analytical audiences.
]

// =============================================================================
// SLIDE 8: Team
// =============================================================================
== Team

#v(0.4em)

#grid(
  columns: (1fr, 1fr),
  gutter: 2.5em,
  [
    #text(size: 32pt, weight: "bold", fill: palette-primary)[[TODO: Founder 1 Name]]
    #text(size: 26pt, fill: palette-secondary)[[TODO: Title]]
    #v(0.3em)
    #text(size: 28pt)[
      [TODO: 1-2 sentences on relevant background, expertise, and why they are
      uniquely qualified to solve this problem]
    ]
  ],
  [
    #text(size: 32pt, weight: "bold", fill: palette-primary)[[TODO: Founder 2 Name]]
    #text(size: 26pt, fill: palette-secondary)[[TODO: Title]]
    #v(0.3em)
    #text(size: 28pt)[
      [TODO: 1-2 sentences on relevant background, expertise, and why they are
      uniquely qualified to solve this problem]
    ]
  ],
)

#v(0.6em)

#text(size: 26pt, fill: palette-secondary)[
  [TODO: Notable advisors, key hires, or institutional backing if applicable]
]

#speaker-note[
  At seed stage, team is often the deciding factor.
  Highlight domain expertise, previous exits, and relevant experience.
  For data companies, emphasize ML/data science credentials.
]

// =============================================================================
// SLIDE 9: The Ask
// =============================================================================
== The Ask

#v(0.4em)

#text(size: 40pt, weight: "bold", fill: palette-accent)[
  [TODO: Raising \$X at \$Y valuation / on \$Z terms]
]

#v(0.6em)

- [TODO: Milestone 1 -- what you will achieve with this capital]
- [TODO: Milestone 2 -- specific, measurable 12-18 month goal]
- [TODO: Milestone 3 -- what this positions you for (Series A, profitability)]

#v(0.4em)

#text(size: 26pt, fill: palette-secondary)[
  [TODO: Current commitments, lead investor status, or round progress]
]

#speaker-note[
  Be specific about how you will use the money and what milestones it funds.
  Investors want to know: what does success look like in 18 months?
  If you have a lead or commitments, mention them to create urgency.
]

// =============================================================================
// SLIDE 10: Closing
// =============================================================================
== Thank You

#v(0.6em)

#align(center)[
  #text(size: 40pt, weight: "bold", fill: palette-primary)[
    #company-name
  ]

  #v(0.6em)

  #text(size: 32pt, fill: palette-accent)[
    [TODO: Memorable closing tagline or call to action]
  ]

  #v(1.5em)

  #text(size: 28pt, fill: palette-secondary)[
    #author-name \
    [TODO: email\@company.com] \
    [TODO: company website]
  ]
]

#speaker-note[
  End with energy. Restate your one-liner and invite questions.
  Have your appendix slides ready for deep-dive questions on methodology and data.
  Thank the investors for their time.
]

// =============================================================================
// APPENDIX (optional -- add slides below as needed)
// =============================================================================
// Appendix slides are not counted toward the 10-slide YC limit.
// Common appendix topics:
//   - Competitive landscape / comparison matrix
//   - Detailed financial projections
//   - Technical architecture diagram
//   - Customer case studies or testimonials
//   - Go-to-market strategy details
//   - IP / patent portfolio
