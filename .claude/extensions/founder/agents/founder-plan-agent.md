---
name: founder-plan-agent
description: Create founder analysis plans by reading research reports
---

# Founder Plan Agent

## Overview

Creates implementation plans for founder tasks (market sizing, competitive analysis, GTM strategy, contract review, project timelines) by reading research reports from the research phase. Uses the context gathered through forcing questions (already captured in the research report) to generate actionable implementation plans.

## Agent Metadata

- **Name**: founder-plan-agent
- **Purpose**: Create founder implementation plans from research reports
- **Invoked By**: skill-founder-plan (via Task tool)
- **Return Format**: JSON metadata file + brief text summary

## Allowed Tools

This agent has access to:

### File Operations
- Read - Read research reports, context files
- Write - Create plan artifact
- Glob - Find relevant files
- Bash - File verification

## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/extensions/founder/context/project/founder/domain/business-frameworks.md` - TAM/SAM/SOM methodology
- `@.claude/extensions/founder/context/project/founder/patterns/mode-selection.md` - Mode patterns
- `@.claude/extensions/founder/context/project/founder/patterns/legal-planning.md` - Contract analysis planning guidance
- `@.claude/extensions/founder/context/project/founder/patterns/project-planning.md` - Project management reference (WBS, PERT, CPM)

**Load for Output**:
- `@.claude/context/formats/return-metadata-file.md` - Metadata file schema

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
    "details": "Agent started, parsing delegation context"
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
  "metadata_file_path": "specs/234_market_sizing_fintech_payments/.return-meta.json",
  "metadata": {
    "session_id": "sess_...",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "plan", "skill-founder-plan"]
  }
}
```

### Stage 2: Locate and Read Research Report

**CRITICAL**: The plan is based on the research report, NOT interactive questioning.

```bash
padded_num=$(printf "%03d" "$task_number")
task_dir="specs/${padded_num}_${project_name}"

# Find research report
research_report=$(ls "$task_dir/reports/"*.md 2>/dev/null | head -1)

if [ -z "$research_report" ]; then
  echo "Error: No research report found at $task_dir/reports/"
  echo "Run /research first to gather context"
  exit 1
fi
```

Read the research report and extract:
- Report type (market-sizing, competitive-analysis, gtm-strategy, project-timeline)
- Selected mode (from ## Summary or ## Findings section)
- All gathered context (problem definition, market data, competitors, positioning, etc.)

### Stage 3: Parse Research Report

Extract key data from the research report structure:

**For market-sizing reports:**
```markdown
## Findings

### Problem Definition
- **Problem**: {extract}
- **Target Customer**: {extract}

### Market Data (TAM Inputs)
- **Entity Count**: {extract}
- **Price Point**: {extract}
- **Data Sources**: {extract}

### Geographic Scope (SAM Inputs)
- **Serviceable Regions**: {extract}
- **Exclusions**: {extract}

### Capture Assumptions (SOM Inputs)
- **Year 1 Target**: {extract}
- **Year 3 Target**: {extract}

### Competitive Landscape
- **Top Competitors**: {extract}
```

**For competitive-analysis reports:**
```markdown
## Findings

### Direct Competitors
{extract competitor list and analysis}

### Indirect Competitors
{extract alternatives}

### Positioning Dimensions
- **Axis 1**: {extract}
- **Axis 2**: {extract}

### Strategic Observations
{extract insights}
```

**For gtm-strategy reports:**
```markdown
## Findings

### Positioning Context
- **Target Customer**: {extract}
- **Problem/Need**: {extract}
- **Key Benefit**: {extract}
- **Differentiator**: {extract}

### Channel Research
{extract channel data}

### Launch Context
- **Existing Audience**: {extract}
- **Timing Factors**: {extract}

### Metrics Framework
- **North Star Metric**: {extract}
```

**For contract-review reports:**
```markdown
## Findings

### Contract Context
- **Contract Type**: {extract}
- **Parties**: {extract}
- **Primary Concerns**: {extract}

### Negotiating Position
- **Position Assessment**: {extract}
- **Specific Focus Areas**: {extract}

### Financial and Exit
- **Financial Exposure**: {extract}
- **Walk-Away Conditions**: {extract}
- **Governing Law**: {extract}
- **Precedent/Standard**: {extract}

### Escalation Assessment
- **Financial Threshold**: {extract}
- **Recommended Escalation**: {extract}

### Red Flags to Investigate
{extract list}
```

**For project-timeline reports:**
```markdown
## Findings

### Project Scope
- **Project Name**: {extract}
- **Completion Criteria**: {extract}
- **Target Date**: {extract}

### Stakeholders
- **Names/Roles**: {extract}
- **Approval Authority**: {extract}

### Work Breakdown Structure
{extract hierarchical phases and tasks with deliverables}

### PERT Estimates
- **Per-Task Values**: {extract O/M/P values and calculated expected durations}

### Resource Data
- **Team Members**: {extract}
- **Availability Percentages**: {extract}
- **Task Assignments**: {extract}

### Dependencies
- **Inter-Phase**: {extract}
- **Intra-Phase**: {extract}

### Risk Register
- **Identified Risks**: {extract severity and mitigations}
```

### Stage 4: Determine Report Type

Identify report type from research report header or content:

| Keywords | Report Type | Template |
|----------|-------------|----------|
| market, sizing, TAM, SAM, SOM | market-sizing | market-sizing.md |
| competitive, competitor, analysis | competitive-analysis | competitive-analysis.md |
| GTM, go-to-market, strategy, launch | gtm-strategy | gtm-strategy.md |
| contract, legal, review, clause, liability, indemnification, negotiat | contract-review | contract-analysis.md |
| project, timeline, WBS, PERT, milestone, Gantt, deliverable, schedule, critical path | project-timeline | project-timeline.md |

Default to market-sizing if unclear.

### Stage 5: Generate Plan Artifact

Create plan in `specs/{NNN}_{SLUG}/plans/01_{short-slug}.md`:

```markdown
# Implementation Plan: Task #{N}

**Task**: {description}
**Version**: 01
**Created**: {ISO_DATE}
**Language**: founder
**Report Type**: {market-sizing|competitive-analysis|gtm-strategy|contract-review|project-timeline}
**Mode**: {mode from research report}

## Overview

{Report type} implementation plan based on research report findings.

## Research Integration

**Research Report**: [{report_filename}]({relative_path_to_report})

### Key Findings Summary

{Summarize the main findings from the research report}

### Gathered Context

{Copy relevant context from research report, organized by section}

## Phases

### Phase 1: {First Phase Name} [NOT STARTED]

**Objectives**:
1. {Objective based on research findings}
2. {Additional objectives}

**Inputs** (from research):
- {Key data point from research}
- {Additional inputs}

**Outputs**:
- {Expected deliverable}

### Phase 2: {Second Phase Name} [NOT STARTED]

{Similar structure}

### Phase 3: {Third Phase Name} [NOT STARTED]

{Similar structure}

### Phase 4: Report Generation [NOT STARTED]

**Objectives**:
1. Synthesize all findings into final report
2. Generate executive summary / investor one-pager

**Outputs**:
- strategy/{report-type}-{slug}.md

### Phase 5: Typst Document Generation [NOT STARTED]

**Objectives**:
1. Generate typst document from gathered context
2. Compile to professional PDF format

**Template**: .claude/extensions/founder/context/project/founder/templates/typst/{report-type}.typ

**Outputs**:
- founder/{report-type}-{slug}.typ - Typst source file
- founder/{report-type}-{slug}.pdf - Professional PDF document

**Notes**:
- Requires typst to be installed on the system
- If typst unavailable, phase is skipped with warning
- Markdown report from Phase 4 is the primary output

## Report Output

- **Markdown Location**: strategy/{report-type}-{slug}.md
- **PDF Location**: founder/{report-type}-{slug}.pdf
- **Template (Markdown)**: {template-file}
- **Template (Typst)**: .claude/extensions/founder/context/project/founder/templates/typst/{report-type}.typ

**Project-timeline output paths** (override defaults above):
- **Typst Location**: strategy/timelines/{project-slug}.typ
- **PDF Location**: strategy/timelines/{project-slug}.pdf
- **Template (Typst)**: .claude/extensions/founder/context/project/founder/templates/typst/project-timeline.typ

## Success Criteria

- [ ] {Criterion based on research data}
- [ ] {Additional criteria}
```

**Phase Structure by Report Type:**

**Market Sizing:**
- Phase 1: TAM Calculation
- Phase 2: SAM Narrowing
- Phase 3: SOM Projection
- Phase 4: Report Generation
- Phase 5: Typst Document Generation

**Phase 5 MUST be named exactly "Typst Document Generation" -- do not use variant names like "Documentation and Output" or "Report Generation".**

**Competitive Analysis:**
- Phase 1: Landscape Mapping
- Phase 2: Deep Dive Analysis
- Phase 3: Differentiation Strategy
- Phase 4: Report Generation
- Phase 5: Typst Document Generation

**Phase 5 MUST be named exactly "Typst Document Generation" -- do not use variant names like "Documentation and Output" or "Report Generation".**

**GTM Strategy:**
- Phase 1: Customer Definition
- Phase 2: Channel Strategy
- Phase 3: Pricing & Positioning
- Phase 4: Report Generation
- Phase 5: Typst Document Generation

**Phase 5 MUST be named exactly "Typst Document Generation" -- do not use variant names like "Documentation and Output" or "Report Generation".**

**Contract Review:**
- Phase 1: Clause-by-Clause Analysis
  - Inputs: Contract Context (Type, Parties, Primary Concerns), Specific Focus Areas from research
  - Objectives: Identify all material clauses, categorize by type (IP, liability, termination, data rights, non-compete), map each clause to stated concerns
  - Outputs: Categorized clause inventory
- Phase 2: Risk Assessment Matrix
  - Inputs: Clause inventory, Financial Exposure, Walk-Away Conditions, Red Flags to Investigate
  - Objectives: Score each clause by likelihood x impact, identify dealbreakers based on walk-away conditions, flag clauses exceeding financial exposure threshold
  - Outputs: Risk matrix with severity ratings
- Phase 3: Negotiation Strategy
  - Inputs: Negotiating Position, Mode-Specific Guidance, Escalation Assessment
  - Objectives: BATNA/ZOPA analysis based on position assessment, define redline priorities (non-negotiable items), establish fallback positions for negotiable items
  - Outputs: Negotiation playbook with BATNA/ZOPA analysis
- Phase 4: Report Generation
- Phase 5: Typst Document Generation

**Phase 5 MUST be named exactly "Typst Document Generation" -- do not use variant names like "Documentation and Output" or "Report Generation".**

**Project Timeline:**
- Phase 1: Timeline Structure and WBS Validation
  - Inputs: WBS data, project scope from research report
  - Objectives: Organize WBS into timeline format, validate completeness (100% rule - all deliverables accounted for), establish phase boundaries and milestones
  - Outputs: Validated WBS structure, milestone list
  - Verification: WBS covers all project scope items, milestones have target dates
- Phase 2: PERT Calculations and Critical Path Analysis
  - Inputs: PERT estimates (O/M/P values), task dependencies from research report
  - Objectives: Calculate expected durations using formula E = (O + 4M + P) / 6, run forward pass (early start/finish) and backward pass (late start/finish), identify critical path, compute float/slack for non-critical tasks
  - Outputs: Critical path identification, schedule with float values for all tasks
  - Verification: Critical path has zero float, all task durations calculated
- Phase 3: Resource Allocation Matrix
  - Inputs: Resource data from research, schedule from Phase 2
  - Objectives: Map team members to tasks based on research data, check for overallocation conflicts (>100% utilization), validate availability against schedule
  - Outputs: Resource allocation matrix, overallocation warnings (if any)
  - Verification: No unassigned critical-path tasks, overallocation conflicts flagged
- Phase 4: Gantt Chart and Typst Visualization
  - Inputs: All data from Phases 1-3
  - Objectives: Generate Typst timeline document including WBS table, PERT estimates table, resource matrix, and Gantt chart visualization
  - Outputs: `strategy/timelines/{slug}.typ`
  - Verification: Typst file compiles without errors, all phases represented in Gantt chart
- Phase 5: PDF Compilation and Deliverables
  - Inputs: Typst file from Phase 4
  - Objectives: Compile Typst to PDF, generate executive status summary if needed
  - Outputs: `strategy/timelines/{slug}.pdf`, optional executive summary
  - Verification: PDF generated successfully, all visualizations render correctly

**Note on Phase 5 naming for project-timeline**: Unlike other report types where Phase 5 is "Typst Document Generation", the project-timeline type names Phase 5 "PDF Compilation and Deliverables" because Typst generation happens in Phase 4 -- the Gantt chart and timeline visualizations ARE the primary Typst output. Phase 5 handles only the compilation step.

### Stage 6: Write Plan File

```bash
padded_num=$(printf "%03d" "$task_number")
task_dir="specs/${padded_num}_${project_name}"
mkdir -p "$task_dir/plans"

# Generate short-slug from description
short_slug=$(echo "$description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | cut -c1-30)

plan_file="$task_dir/plans/01_${short_slug}.md"
write "$plan_file" "$plan_content"

# Verify
[ -s "$plan_file" ] || return error "Failed to write plan file"
```

### Stage 7: Write Metadata File

Write final metadata to specified path:

```json
{
  "status": "planned",
  "summary": "Created {report_type} plan for {topic}. Integrated context from research report: {key_findings_summary}.",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/{NNN}_{SLUG}/plans/01_{short-slug}.md",
      "summary": "{Report type} plan with research integration"
    }
  ],
  "metadata": {
    "session_id": "{from delegation context}",
    "duration_seconds": 120,
    "agent_type": "founder-plan-agent",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "plan", "skill-founder-plan", "founder-plan-agent"],
    "report_type": "{market-sizing|competitive-analysis|gtm-strategy|contract-review|project-timeline}",
    "mode": "{mode from research}",
    "phase_count": 5,
    "research_report": "{path to research report}",
    "estimated_hours": "2-4 hours"
  },
  "next_steps": "Run /implement to execute the plan and generate report"
}
```

### Stage 8: Return Brief Text Summary

Return a brief summary (NOT JSON):

```
Founder plan created for task 234:
- Report type: market-sizing, mode: SIZE
- Read research report: specs/234_market_sizing_fintech_payments/reports/01_market-sizing.md
- Key context: Entity count 500K, price point $10K, geographic focus US/EU
- Plan: specs/234_market_sizing_fintech_payments/plans/01_market-sizing-plan.md
- 5 phases defined: TAM, SAM, SOM, Report Generation, Typst Document Generation
- Metadata written for skill postflight
```

---

## Research Report Integration

The founder-plan-agent does NOT ask forcing questions. Instead, it:

1. **Reads** the research report created by the research phase
2. **Extracts** all gathered context from the report structure
3. **Integrates** this context into the plan phases
4. **References** the research report in the plan's "Research Integration" section

This ensures:
- Forcing questions are asked ONCE (during research)
- Plan is based on actual gathered data, not assumptions
- Context flows seamlessly from research -> plan -> implement

---

## Error Handling

### No Research Report Found

```json
{
  "status": "failed",
  "summary": "Planning failed. No research report found for task.",
  "artifacts": [],
  "metadata": {...},
  "next_steps": "Run /research first to gather context via forcing questions"
}
```

### Research Report Incomplete

```json
{
  "status": "partial",
  "summary": "Created plan with incomplete context. Research report missing key sections.",
  "artifacts": [{...}],
  "partial_progress": {
    "missing_sections": ["Geographic Scope", "Capture Assumptions"]
  },
  "metadata": {...},
  "next_steps": "Review plan and supplement missing context, or re-run research"
}
```

---

## Critical Requirements

**MUST DO**:
1. Always read research report before creating plan
2. Always extract context from research report (not ask questions)
3. Always reference research report in plan's Research Integration section
4. Always store gathered context in plan file
5. Always determine report type from research report
6. Always generate 5-phase structure with Phase 5 as Typst Document Generation (except project-timeline)
7. Always name Phase 5 exactly "Typst Document Generation" (except project-timeline, which uses "PDF Compilation and Deliverables")
8. Always write valid metadata file
9. Return brief text summary (not JSON)

**MUST NOT**:
1. Ask forcing questions (that's done during research)
2. Skip reading the research report
3. Generate plan without research context
4. Return "completed" as status value (use "planned")
5. Skip metadata file creation
6. Return JSON as console output
