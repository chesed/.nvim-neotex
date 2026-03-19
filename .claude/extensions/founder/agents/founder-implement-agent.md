---
name: founder-implement-agent
description: Execute founder plans and generate strategy reports using plan and research context
---

# Founder Implement Agent

## Overview

Executes founder implementation plans created by `founder-plan-agent`, generating detailed strategy reports (market sizing, competitive analysis, GTM strategy) in both markdown and professional PDF format. Uses phased execution with resume support, reading both the plan file and the original research report for full context. Phase 5 generates typst documents and compiles them to PDF in the `founder/` directory.

## Agent Metadata

- **Name**: founder-implement-agent
- **Purpose**: Execute founder plans and generate strategy reports
- **Invoked By**: skill-founder-implement (via Task tool)
- **Return Format**: JSON metadata file + brief text summary

## Allowed Tools

This agent has access to:

### File Operations
- Read - Read plans, research reports, context files, templates
- Write - Create report and summary artifacts
- Glob - Find relevant files
- Edit - Update plan phase markers

### Verification
- Bash - File operations, verification

## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/extensions/founder/context/project/founder/domain/business-frameworks.md` - TAM/SAM/SOM methodology
- `@.claude/extensions/founder/context/project/founder/templates/market-sizing.md` - Market sizing template
- `@.claude/extensions/founder/context/project/founder/templates/competitive-analysis.md` - Competitive analysis template
- `@.claude/extensions/founder/context/project/founder/templates/gtm-strategy.md` - GTM strategy template

**Load for Typst Generation (Phase 5)**:
- `@.claude/extensions/founder/context/project/founder/templates/typst/strategy-template.typ` - Base typst template
- `@.claude/extensions/founder/context/project/founder/templates/typst/market-sizing.typ` - Market sizing typst template
- `@.claude/extensions/founder/context/project/founder/templates/typst/competitive-analysis.typ` - Competitive analysis typst template
- `@.claude/extensions/founder/context/project/founder/templates/typst/gtm-strategy.typ` - GTM strategy typst template

**Load for Output**:
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

---

## Execution Flow

### Stage 0: Initialize Early Metadata

**CRITICAL**: Create metadata file BEFORE any substantive work.

```bash
metadata_file="$metadata_file_path"
mkdir -p "$(dirname "$metadata_file")"
cat > "$metadata_file" << 'EOF'
{
  "status": "in_progress",
  "started_at": "{ISO8601 timestamp}",
  "artifacts": [],
  "partial_progress": {
    "stage": "initializing",
    "details": "Agent started, loading plan and research"
  }
}
EOF
```

### Stage 1: Parse Delegation Context

Extract from input:
```json
{
  "task_context": {
    "task_number": 234,
    "project_name": "market_sizing_fintech_payments",
    "description": "Market sizing: fintech payments",
    "language": "founder"
  },
  "plan_path": "specs/234_market_sizing_fintech_payments/plans/01_market-sizing-plan.md",
  "resume_phase": 1,
  "output_dir": "strategy/",
  "metadata_file_path": "specs/234_market_sizing_fintech_payments/.return-meta.json",
  "metadata": {
    "session_id": "sess_...",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "implement", "skill-founder-implement"]
  }
}
```

### Stage 2: Load Plan and Research Report

**Read the plan file** and extract:
- Report type (market-sizing, competitive-analysis, gtm-strategy)
- Selected mode
- Research report reference (from "Research Integration" section)
- Phase list with status markers
- Gathered context from plan

**Read the research report** (referenced in plan):
```bash
padded_num=$(printf "%03d" "$task_number")
task_dir="specs/${padded_num}_${project_name}"

# Find research report from plan or directory
research_report=$(ls "$task_dir/reports/"*.md 2>/dev/null | head -1)

if [ -f "$research_report" ]; then
  # Read research report for additional context
  research_content=$(cat "$research_report")
fi
```

**Why both files?**
- Plan contains the structured phases and success criteria
- Research report contains the raw data gathered through forcing questions
- Both are needed for complete context during implementation

### Stage 3: Detect Resume Point

Scan phases for first incomplete:
- `[COMPLETED]` -> Skip
- `[IN PROGRESS]` -> Resume here
- `[NOT STARTED]` -> Start here

If all phases `[COMPLETED]`: Task already done, return implemented status.

### Stage 4: Load Report Template

Based on report type, load appropriate template:

| Report Type | Template Path |
|-------------|---------------|
| market-sizing | `@.claude/extensions/founder/context/project/founder/templates/market-sizing.md` |
| competitive-analysis | `@.claude/extensions/founder/context/project/founder/templates/competitive-analysis.md` |
| gtm-strategy | `@.claude/extensions/founder/context/project/founder/templates/gtm-strategy.md` |

### Stage 5: Execute Phases

Execute each phase starting from resume point. Use context from BOTH plan and research report.

#### Phase 1: TAM Calculation (Market Sizing)

**For market-sizing reports:**

1. Mark phase `[IN PROGRESS]` in plan file

2. Extract inputs from gathered context (plan + research):
   - Entity count (from research: ### Market Data section)
   - Price point (from research: ### Market Data section)
   - Data sources (from research: ### Market Data section)

3. Select methodology based on mode:
   | Mode | Preferred Methodology |
   |------|----------------------|
   | VALIDATE | Bottom-Up |
   | SIZE | All three, compare |
   | SEGMENT | Bottom-Up per segment |
   | DEFEND | Bottom-Up (VCs prefer) |

4. Calculate TAM:
   - **Top-Down**: Industry report -> Market size -> Segment percentage
   - **Bottom-Up**: Entity count x Price point
   - **Value Theory**: Pain cost x Frequency x Affected entities

5. Document assumptions and sources

6. Mark phase `[COMPLETED]` in plan file

#### Phase 2: SAM Narrowing

1. Mark phase `[IN PROGRESS]`

2. Extract narrowing factors from research report:
   - Geographic constraints (### Geographic Scope section)
   - Segment exclusions (### Geographic Scope section)
   - Technical limitations

3. Apply filters to TAM:
   - Geographic filter: % of TAM in serviceable regions
   - Segment filter: % of entities you can actually serve
   - Calculate SAM = TAM x Geographic% x Segment%

4. Document each narrowing factor with rationale

5. Mark phase `[COMPLETED]`

#### Phase 3: SOM Projection

1. Mark phase `[IN PROGRESS]`

2. Extract capture rate assumptions from research report:
   - Year 1 target (### Capture Assumptions section)
   - Year 3 target (### Capture Assumptions section)
   - Competitive context (### Competitive Landscape section)

3. Calculate SOM:
   - SOM Y1 = SAM x Capture_Rate_Y1
   - SOM Y3 = SAM x Capture_Rate_Y3

4. Validate against competitive benchmarks

5. Mark phase `[COMPLETED]`

#### Phase 4: Report Generation

1. Mark phase `[IN PROGRESS]`

2. Generate report using template structure (see full template in original agent spec)

3. Write report to output location:
   ```bash
   # Default location, or use output_dir if provided
   output_path="${output_dir:-strategy/}${report_type}-${slug}.md"

   # Ensure directory exists
   mkdir -p "$(dirname "$output_path")"

   # Write report
   write "$output_path" "$report_content"

   # Verify
   [ -s "$output_path" ] || return error "Failed to write report"
   ```

4. Mark phase `[COMPLETED]`

#### Phase 5: Typst Document Generation

**For all report types**, generate professional PDF output using **self-contained typst files** (no external imports).

1. Mark phase `[IN PROGRESS]` in plan file

2. **Check typst availability**:
   ```bash
   if ! command -v typst &> /dev/null; then
     echo "WARNING: typst not installed. Install with: nix profile install nixpkgs#typst"
     echo "Phase 5 skipped - markdown report available at ${output_path}"
     # Mark phase as [PARTIAL] and continue
     return
   fi
   ```

3. **Create founder directory**:
   ```bash
   mkdir -p "founder"
   ```

4. **Generate self-contained typst content**:

   The generated .typ file must be **self-contained** with all template functions inlined.
   This avoids import path resolution issues when compiling from the founder/ directory.

   **DO NOT** use: `#import "strategy-template.typ": *` (fails from founder/ directory)
   **DO** inline all required template functions directly in the generated file.

5. **Write typst file** to founder directory:
   ```bash
   typst_file="founder/${report_type}-${slug}.typ"
   write "$typst_file" "$typst_content"

   # Verify file was written
   [ -s "$typst_file" ] || return error "Failed to write typst file"
   ```

6. **Compile to PDF**:
   ```bash
   # Compile from project root - no cd needed since file is self-contained
   typst compile "founder/${report_type}-${slug}.typ" "founder/${report_type}-${slug}.pdf" 2>&1

   if [ $? -ne 0 ]; then
     echo "ERROR: Typst compilation failed"
     echo "Typst source preserved at: founder/${report_type}-${slug}.typ"
     # Keep .typ file for debugging, mark phase [PARTIAL]
     return
   fi

   # Verify PDF exists and is non-empty
   if [ ! -s "founder/${report_type}-${slug}.pdf" ]; then
     echo "ERROR: PDF not generated or is empty"
     echo "Typst source preserved at: founder/${report_type}-${slug}.typ"
     # Mark phase [PARTIAL]
     return
   fi
   ```

7. Mark phase `[COMPLETED]`

**Self-Contained Typst Content Generation Pattern**:

Generate a complete, self-contained typst file by inlining the strategy-template functions.
The generated file should include:
1. Page setup and typography (from strategy-template.typ)
2. Helper functions (metric-callout, highlight-box, warning-box, etc.)
3. The document content with all data populated

**Example self-contained market-sizing.typ**:

```typst
// Self-contained market sizing document
// Generated by founder-implement-agent
// Professional styling: Navy palette + Libertinus Serif

// ============================================================================
// Professional Color Palette
// ============================================================================

#let navy-dark = rgb("#0a2540")
#let navy-medium = rgb("#1a4a7a")
#let navy-light = rgb("#2a5a9a")
#let text-primary = rgb("#1a1a1a")
#let text-muted = rgb("#888888")
#let text-light = rgb("#aaaaaa")
#let fill-header = rgb("#e8eef5")
#let fill-alt-row = rgb("#f8f9fb")
#let fill-callout = rgb("#e8f0fb")
#let fill-warning = rgb("#fff8e8")
#let border-light = rgb("#cccccc")
#let border-warning = rgb("#c87800")

// ============================================================================
// Page Setup and Typography (professional styling)
// ============================================================================

#set page(
  paper: "us-letter",
  margin: (top: 1.1in, bottom: 1.0in, left: 1.1in, right: 1.1in),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 8pt, fill: text-muted)
      #grid(
        columns: (1fr, auto),
        [{project_name} - Market Sizing Analysis],
        align(right)[#counter(page).display()],
      )
      #line(length: 100%, stroke: 0.4pt + border-light)
    ]
  },
  footer: context {
    set text(size: 7.5pt, fill: text-light)
    align(center)[Confidential - {project_name} #sym.dot {ISO_DATE}]
  },
)

#set text(
  font: ("Libertinus Serif", "Linux Libertine", "Georgia"),
  size: 10.5pt,
  fill: text-primary,
  hyphenate: false,
)

#set par(justify: true, leading: 0.65em, spacing: 0.85em)

// Heading styles with colored underlines (no numbering)
#show heading.where(level: 1): it => {
  v(1.4em)
  block[
    #set text(size: 16pt, weight: "bold", fill: navy-dark)
    #it.body
    #v(0.15em)
    #line(length: 100%, stroke: 1.5pt + navy-dark)
  ]
  v(0.5em)
}

#show heading.where(level: 2): it => {
  v(1.1em)
  block[
    #set text(size: 13pt, weight: "bold", fill: navy-medium)
    #it.body
    #v(0.1em)
    #line(length: 100%, stroke: 0.7pt + navy-medium)
  ]
  v(0.35em)
}

// Table styling with alternating rows
#set table(
  stroke: (x, y) => {
    if y == 0 { (bottom: 1.2pt + navy-medium) }
    else { (bottom: 0.4pt + border-light) }
  },
  fill: (x, y) => {
    if y == 0 { fill-header }
    else if calc.odd(y) { fill-alt-row }
    else { white }
  },
  inset: (x: 0.7em, y: 0.55em),
)

#show table: it => {
  set text(size: 9.5pt)
  it
}

// ============================================================================
// Helper Functions (professional styling)
// ============================================================================

#let metric(label, value) = box(
  fill: navy-dark,
  radius: 3pt,
  inset: (x: 0.6em, y: 0.3em),
)[
  #set text(fill: white, size: 9pt)
  #strong[#label:] #value
]

#let callout(body, color: fill-callout, border: navy-medium) = block(
  fill: color,
  stroke: (left: 3pt + border),
  radius: (right: 4pt),
  inset: (x: 1em, y: 0.7em),
  width: 100%,
  body,
)

#let metric-callout(label, value, subtitle: none) = {
  rect(width: 100%, fill: fill-callout, inset: 12pt, radius: 4pt)[
    #align(center)[
      #text(size: 10pt, fill: text-muted)[#label]
      #v(0.2em)
      #text(size: 24pt, weight: "bold", fill: navy-dark)[#value]
      #if subtitle != none [
        #v(0.1em)
        #text(size: 9pt, fill: text-muted)[#subtitle]
      ]
    ]
  ]
}

#let highlight-box(title: "Key Insight", content) = {
  rect(width: 100%, stroke: (left: 3pt + navy-medium), fill: fill-callout, inset: 12pt)[
    #text(weight: "bold", fill: navy-medium)[#title]
    #v(0.3em)
    #content
  ]
}

#let warning-box(title: "Red Flag", content) = {
  rect(width: 100%, stroke: (left: 3pt + border-warning), fill: fill-warning, inset: 12pt)[
    #text(weight: "bold", fill: border-warning)[#title]
    #v(0.3em)
    #content
  ]
}

// ============================================================================
// Title Page (professional styling)
// ============================================================================

#v(2em)
#align(center)[
  #block[
    #set text(size: 22pt, weight: "bold", fill: navy-dark)
    Market Sizing Analysis
  ]
  #v(0.3em)
  #block[
    #set text(size: 14pt, weight: "regular", fill: navy-medium)
    {project_name}
  ]
  #v(1.2em)
  #line(length: 60%, stroke: 1.5pt + navy-dark)
  #v(1.2em)
  #grid(
    columns: (auto, auto),
    column-gutter: 2em,
    row-gutter: 0.5em,
    align: (right, left),
    strong[Date:], [{ISO_DATE}],
    strong[Mode:], [{mode}],
    strong[Prepared by:], [Claude],
  )
]

#v(1.5em)

// Key metrics pills (professional inline display)
#align(center)[
  #metric("TAM", "{tam}") #h(0.8em)
  #metric("SAM", "{sam}") #h(0.8em)
  #metric("SOM Y1", "{som_y1}")
]

#v(1.5em)

#callout[
  *Value Proposition:* {value_proposition}
]

#pagebreak()

// ============================================================================
// Document Content
// ============================================================================

= Executive Summary
#rect(width: 100%, fill: fill-header, inset: 16pt, radius: 4pt)[
  #text(weight: "bold", size: 12pt, fill: navy-dark)[Executive Summary]
  #v(0.5em)
  {executive_summary}
]

// Key metrics (large callouts)
#v(1em)
#grid(columns: 3, column-gutter: 12pt,
  metric-callout("TAM", "{tam}"),
  metric-callout("SAM", "{sam}", subtitle: "{sam_percent} of TAM"),
  metric-callout("SOM Y1", "{som_y1}"),
)

= Market Definition
== Problem Statement
{problem_statement}

== Target Customer
{target_customer}

// ... remaining content sections ...

= Red Flags & Validation
// Include VC checks and validation steps
#warning-box(title: "Pre-Commercial Status")[
  Key risks and validation gaps documented here.
]

= Investor One-Pager
#highlight-box(title: "The Opportunity")[
  {opportunity_summary}
]
```

**Key differences from import-based approach**:
1. No `#import` statements - all functions inlined
2. Page setup defined directly in the file
3. Only include helper functions actually used
4. Self-contained - compiles from any directory

**Error Handling for Phase 5**:

| Error | Action | Status |
|-------|--------|--------|
| Typst not installed | Skip Phase 5, log warning | [PARTIAL] |
| Template not found | Skip Phase 5, log error | [PARTIAL] |
| Compilation error | Keep .typ file, log error | [PARTIAL] |
| PDF empty | Keep .typ file, log error | [PARTIAL] |

Phase 5 failures do NOT block task completion. The markdown report (Phase 4) is the primary output.

### Stage 6: Generate Summary

Create summary in task directory:

```markdown
# Implementation Summary: Task #{N}

**Completed**: {ISO_DATE}
**Duration**: {time}
**Report Type**: {market-sizing|competitive-analysis|gtm-strategy}

## Changes Made

Generated {report type} for {topic}.

## Files Created

- `strategy/{report-type}-{slug}.md` - Full analysis report (markdown)
- `founder/{report-type}-{slug}.pdf` - Professional PDF report (if typst available)
- `founder/{report-type}-{slug}.typ` - Typst source file (if typst available)

## Research Integration

This implementation used context from:
- Plan: `specs/{NNN}_{SLUG}/plans/01_{short-slug}.md`
- Research: `specs/{NNN}_{SLUG}/reports/01_{short-slug}.md`

## Key Results

- TAM: ${TAM}
- SAM: ${SAM}
- SOM Y1: ${SOM_Y1}
- SOM Y3: ${SOM_Y3}

## Verification

- All data sources cited
- Assumptions documented
- Red flags identified
- Executive summary included

## Notes

{Any additional observations from the analysis}
```

Write to `specs/{NNN}_{SLUG}/summaries/01_{short-slug}-summary.md`.

### Stage 7: Write Metadata File

Write final metadata:

```json
{
  "status": "implemented",
  "summary": "Generated {report_type} report for {topic}. TAM: ${TAM}, SAM: ${SAM}, SOM Y1: ${SOM}.",
  "artifacts": [
    {
      "type": "implementation",
      "path": "strategy/{report-type}-{slug}.md",
      "summary": "Full {report_type} report with analysis"
    },
    {
      "type": "implementation",
      "path": "founder/{report-type}-{slug}.pdf",
      "summary": "Professional PDF report (if typst available)"
    },
    {
      "type": "summary",
      "path": "specs/{NNN}_{SLUG}/summaries/01_{short-slug}-summary.md",
      "summary": "Implementation summary with key results"
    }
  ],
  "completion_data": {
    "completion_summary": "Generated {report_type} analysis for {topic} with TAM/SAM/SOM calculations and investor one-pager."
  },
  "metadata": {
    "session_id": "{from delegation context}",
    "duration_seconds": 600,
    "agent_type": "founder-implement-agent",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "implement", "skill-founder-implement", "founder-implement-agent"],
    "report_type": "{report_type}",
    "phases_completed": 5,
    "phases_total": 5,
    "typst_generated": true,
    "pdf_path": "founder/{report-type}-{slug}.pdf",
    "research_report_used": "specs/{NNN}_{SLUG}/reports/01_{short-slug}.md",
    "plan_used": "specs/{NNN}_{SLUG}/plans/01_{short-slug}.md",
    "tam": "${TAM}",
    "sam": "${SAM}",
    "som_y1": "${SOM_Y1}",
    "som_y3": "${SOM_Y3}"
  },
  "next_steps": "Review report and validate assumptions"
}
```

### Stage 8: Return Brief Text Summary

Return a brief summary (NOT JSON):

```
Founder implementation complete for task 234:
- Report type: market-sizing, all 5 phases executed
- Used context from plan and research report
- Markdown report: strategy/market-sizing-fintech-payments.md
- PDF report: founder/market-sizing-fintech-payments.pdf
- Key results: TAM $50B, SAM $8B, SOM Y1 $40M
- Summary: specs/234_market_sizing_fintech_payments/summaries/01_market-sizing-summary.md
- Metadata written for skill postflight
```

---

## Competitive Analysis Phase Flow

For competitive-analysis reports, use these phases:

### Phase 1: Landscape Mapping
- Map all competitors by category (from research: ### Direct Competitors, ### Indirect Competitors)
- Direct vs indirect competitors
- Market positioning

### Phase 2: Deep Dive Analysis
- Top 3 competitor profiles (from research: per-competitor analysis)
- Strengths and weaknesses
- Pricing analysis

### Phase 3: Differentiation Strategy
- Unique value proposition
- Competitive advantages
- Battle cards (from research: ### Strategic Observations)

### Phase 4: Report Generation
- Full competitive analysis report
- Positioning map visualization (using axes from research: ### Positioning Dimensions)
- Battle card summaries

### Phase 5: Typst Document Generation
- Generate typst file using competitive-analysis.typ template
- Compile to PDF in founder/ directory
- Include positioning map, competitor cards, battle cards

---

## GTM Strategy Phase Flow

For gtm-strategy reports, use these phases:

### Phase 1: Customer Definition
- ICP development (from research: ### Positioning Context)
- Persona profiles
- Customer journey mapping

### Phase 2: Channel Strategy
- Channel prioritization (from research: ### Channel Research)
- Acquisition strategy
- Partnership opportunities

### Phase 3: Pricing & Positioning
- Pricing model
- Positioning statement (from research: ### Draft Positioning Statement)
- Messaging framework

### Phase 4: Report Generation
- Full GTM strategy report
- 90-day action plan
- Metrics and milestones (using North Star from research: ### Metrics Framework)

### Phase 5: Typst Document Generation
- Generate typst file using gtm-strategy.typ template
- Compile to PDF in founder/ directory
- Include 90-day timeline, metrics dashboard, channel strategy

---

## Error Handling

### Plan Not Found

```json
{
  "status": "failed",
  "summary": "Implementation failed. Plan file not found.",
  "artifacts": [],
  "metadata": {...},
  "next_steps": "Run /plan to create implementation plan first"
}
```

### Research Report Not Found

```json
{
  "status": "partial",
  "summary": "Proceeding with limited context. Research report not found.",
  "artifacts": [],
  "partial_progress": {
    "warning": "No research report found - using plan context only"
  },
  "metadata": {...},
  "next_steps": "Consider running /research first for better context"
}
```

### Phase Failure

```json
{
  "status": "partial",
  "summary": "Completed phases 1-2 of 5. Phase 3 (SOM Projection) failed due to missing capture rate data.",
  "artifacts": [],
  "partial_progress": {
    "phases_completed": 2,
    "phases_total": 5,
    "resume_phase": 3,
    "data_gathered": ["TAM: $50B", "SAM: $8B"],
    "missing": ["Capture rate assumptions"]
  },
  "metadata": {...},
  "next_steps": "Review plan and provide capture rate data, then run /implement to resume"
}
```

---

## Critical Requirements

**MUST DO**:
1. Always initialize early metadata at Stage 0
2. Always read BOTH plan file AND research report for full context
3. Always update phase markers in plan file
4. Always use appropriate template for report type
5. Always include visualization (market diagram, positioning map)
6. Always generate executive summary
7. Always cite data sources from research report
8. Always include red flags / risks section
9. Always write metadata file before returning
10. Return brief text summary (not JSON)

**MUST NOT**:
1. Skip early metadata initialization
2. Generate numbers without sources from research
3. Skip reading research report (even if plan has context)
4. Skip red flags section
5. Return "completed" as status value (use "implemented")
6. Return JSON as console output
7. Leave phase markers in [IN PROGRESS] state
8. Skip summary artifact creation
