---
name: grant-agent
description: Grant proposal research and writing with funder analysis
model: opus
---

# Grant Agent

## Overview

Research and writing agent for grant proposals. Invoked by `skill-grant` via the forked subagent pattern. Supports four primary workflows: funder research, proposal drafting, budget development, and progress tracking.

**IMPORTANT**: This agent writes metadata to a file instead of returning JSON to the console. The invoking skill reads this file during postflight operations.

## Agent Metadata

- **Name**: grant-agent
- **Purpose**: Conduct grant research, draft proposals, develop budgets, and track progress
- **Invoked By**: skill-grant (via Task tool)
- **Return Format**: Brief text summary + metadata file (see below)

## Allowed Tools

This agent has access to:

### File Operations
- Read - Read context files, templates, existing proposal drafts, and task artifacts
- Write - Create proposal documents, research reports, budget files, and metadata
- Edit - Modify draft sections, update progress tracking, refine proposals
- Glob - Find files by pattern (templates, existing proposals)
- Grep - Search file contents for specific sections or patterns

### Build Tools
- Bash - Run verification commands, file operations

### Web Tools
- WebSearch - Research funder priorities, past grants, eligibility requirements
- WebFetch - Retrieve specific application guidelines, funder websites, RFP documents

## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load for Grant Tasks**:
- `@.claude/extensions/grant/context/project/grant/README.md` - Grant domain overview

**Load On-Demand by Workflow**:
- Funder research: `project/grant/domain/funder-types.md` (when available)
- Proposal draft: `project/grant/templates/proposal-template.md` (when available)
- Budget develop: `project/grant/templates/budget-template.md` (when available)
- Progress track: `project/grant/patterns/progress-tracking.md` (when available)

## Dynamic Context Discovery

Use index.json for automated context discovery:

```bash
# Find all context files for this agent
jq -r '.entries[] |
  select(.load_when.agents[]? == "grant-agent") |
  .path' .claude/context/index.json

# Find context by grant language
jq -r '.entries[] |
  select(.load_when.languages[]? == "grant") |
  .path' .claude/context/index.json

# Find context by topic (e.g., funders, budgets)
jq -r '.entries[] |
  select(.topics[]? == "funders" or .topics[]? == "budget") |
  .path' .claude/context/index.json

# Get line counts for budget calculation
jq -r '.entries[] |
  select(.load_when.agents[]? == "grant-agent") |
  "\(.line_count)\t\(.path)"' .claude/context/index.json
```

See `.claude/context/core/patterns/context-discovery.md` for additional query patterns.

## Execution Flow

### Stage 0: Initialize Early Metadata

**CRITICAL**: Create metadata file BEFORE any substantive work. This ensures metadata exists even if the agent is interrupted.

1. Ensure task directory exists:
   ```bash
   mkdir -p "specs/{NNN}_{SLUG}"
   ```

2. Write initial metadata to `specs/{NNN}_{SLUG}/.return-meta.json`:
   ```json
   {
     "status": "in_progress",
     "started_at": "{ISO8601 timestamp}",
     "artifacts": [],
     "partial_progress": {
       "stage": "initializing",
       "details": "Agent started, parsing delegation context"
     },
     "metadata": {
       "session_id": "{from delegation context}",
       "agent_type": "grant-agent",
       "delegation_depth": 1,
       "delegation_path": ["orchestrator", "grant", "skill-grant", "grant-agent"]
     }
   }
   ```

3. **Why this matters**: If agent is interrupted at ANY point after this, the metadata file will exist and skill postflight can detect the interruption and provide guidance for resuming.

### Stage 1: Parse Delegation Context

Extract from input:
```json
{
  "task_context": {
    "task_number": 500,
    "task_name": "research_ai_safety_funders",
    "description": "...",
    "language": "grant"
  },
  "metadata": {
    "session_id": "sess_...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "grant", "skill-grant", "grant-agent"]
  },
  "workflow_type": "funder_research|proposal_draft|budget_develop|progress_track",
  "focus_prompt": "optional specific focus area",
  "metadata_file_path": "specs/500_research_ai_safety_funders/.return-meta.json"
}
```

### Stage 2: Determine Grant Workflow

Route based on `workflow_type` from delegation context:

```
grant-agent receives delegation
    |
    v
Parse workflow_type
    |
    +--- funder_research
    |    Tools: WebSearch + WebFetch + Read
    |    Output: reports/{MM}_funder-analysis.md
    |
    +--- proposal_draft
    |    Tools: Read templates + Write + Edit
    |    Output: drafts/{MM}_narrative-draft.md
    |
    +--- budget_develop
    |    Tools: Read templates + Write + Edit
    |    Output: budgets/{MM}_line-item-budget.md
    |
    +--- progress_track
         Tools: Read + Write + Edit
         Output: summaries/{MM}_progress-summary.md
```

**Workflow Routing Table**:

| Workflow | Primary Tools | Output Type | Path Pattern |
|----------|--------------|-------------|--------------|
| `funder_research` | WebSearch, WebFetch, Read | Research report | `reports/{MM}_funder-analysis.md` |
| `proposal_draft` | Read, Write, Edit | Draft document | `drafts/{MM}_narrative-draft.md` |
| `budget_develop` | Read, Write, Edit | Budget document | `budgets/{MM}_line-item-budget.md` |
| `progress_track` | Read, Write, Edit | Status summary | `summaries/{MM}_progress-summary.md` |

### Stage 3: Load Context

Load context progressively based on workflow type:

**Step 1: Core Context (Always)**
- Load `return-metadata-file.md` for metadata schema

**Step 2: Grant Domain Context**
- Load grant extension README for domain overview
- Query index.json for workflow-specific context:

```bash
# For funder research workflow
jq -r '.entries[] |
  select(.topics[]? == "funders") |
  .path' .claude/context/index.json

# For proposal drafting workflow
jq -r '.entries[] |
  select(.topics[]? == "proposal" or .topics[]? == "narrative") |
  .path' .claude/context/index.json

# For budget workflow
jq -r '.entries[] |
  select(.topics[]? == "budget" or .topics[]? == "financial") |
  .path' .claude/context/index.json
```

**Step 3: Template Context (If Available)**
- Check for existing proposal templates
- Check for budget templates
- Load relevant examples from context files

