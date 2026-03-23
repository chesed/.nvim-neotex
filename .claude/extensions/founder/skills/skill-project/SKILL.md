---
name: skill-project
description: Project timeline management with WBS, PERT estimation, and resource allocation
allowed-tools: Task, Bash, Edit, Read, Write
---

# Project Skill

Thin wrapper that routes project timeline requests to the `project-agent`.

**IMPORTANT**: This skill implements the skill-internal postflight pattern. After the subagent returns,
this skill handles all postflight operations (status update, artifact linking, git commit) before returning.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/formats/subagent-return.md`
- Purpose: Return validation
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:

### Direct Invocation
- User explicitly runs `/project` command with task number
- User runs `/research` on a founder task with `task_type: "project"`

### Implicit Invocation (during task implementation)

When an implementing agent encounters any of these patterns:

**Plan step language patterns**:
- "Create project timeline"
- "Build project schedule"
- "Estimate project duration"
- "Track project progress"

**Target mentions**:
- "WBS", "work breakdown structure"
- "PERT", "three-point estimates"
- "Gantt chart", "critical path"
- "project timeline", "resource allocation"

### When NOT to trigger

Do not invoke for:
- Market sizing analysis (use skill-market)
- Competitive analysis (use skill-analyze)
- Business strategy (use skill-strategy)
- General research without project planning focus (use skill-researcher)

---

## Execution Flow

### Stage 1: Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- `mode` - Optional, one of: PLAN, TRACK, REPORT

```bash
# Lookup task
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

# Validate exists
if [ -z "$task_data" ]; then
  return error "Task $task_number not found"
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "founder"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')

# Extract pre-gathered forcing_data (if present)
forcing_data=$(echo "$task_data" | jq -r '.forcing_data // null')

# Validate mode if provided
if [ -n "$mode" ]; then
  case "$mode" in
    PLAN|TRACK|REPORT) ;;
    *) return error "Invalid mode: $mode. Must be PLAN, TRACK, or REPORT" ;;
  esac
fi
```

---

### Stage 2: Preflight Status Update

Update task status to "planning" BEFORE invoking subagent.

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "planning" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid
  }' specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker to `[PLANNING]`.

---

### Stage 3: Create Postflight Marker

```bash
padded_num=$(printf "%03d" "$task_number")
mkdir -p "specs/${padded_num}_${project_name}"

cat > "specs/${padded_num}_${project_name}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-project",
  "task_number": ${task_number},
  "operation": "project",
  "reason": "Postflight pending: status update, artifact linking, git commit",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
```

---

### Stage 4: Prepare Delegation Context

Include pre-gathered forcing_data when available:

```json
{
  "task_context": {
    "task_number": N,
    "project_name": "{project_name}",
    "description": "{description}",
    "language": "founder",
    "task_type": "project"
  },
  "forcing_data": {
    "project_name": "{pre_gathered_name}",
    "target_date": "{pre_gathered_date}",
    "stakeholders": "{pre_gathered_stakeholders}",
    "gathered_at": "{timestamp}"
  },
  "mode": "PLAN|TRACK|REPORT or null",
  "metadata_file_path": "specs/{NNN}_{SLUG}/.return-meta.json",
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "project", "skill-project"]
  }
}
```

**Note**: If `forcing_data` is present from pre-task gathering, pass it to the agent.
The agent will use pre-gathered data and only ask follow-up questions for missing details.

---

### Stage 5: Invoke Agent

**CRITICAL**: You MUST use the **Task** tool to spawn the agent.

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "project-agent"
  - prompt: [Include task_context, forcing_data, mode, metadata_file_path, metadata]
  - description: "Project timeline with WBS, PERT estimation, and resource allocation"
```

The agent will:
- Use pre-gathered forcing_data if available (skip already-answered questions)
- Present mode selection if not pre-selected
- Ask forcing questions for project scope, phases, tasks, and estimates
- Create timeline at strategy/timelines/
- Write metadata file
- Return brief text summary

---

### Stage 6: Parse Subagent Return

```bash
padded_num=$(printf "%03d" "$task_number")
metadata_file="specs/${padded_num}_${project_name}/.return-meta.json"

if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
    status=$(jq -r '.status' "$metadata_file")
    artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
    artifact_type=$(jq -r '.artifacts[0].type // ""' "$metadata_file")
    artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
    mode_used=$(jq -r '.metadata.mode // ""' "$metadata_file")
else
    status="failed"
fi
```

---

### Stage 7: Update Task Status (Postflight)

Map mode to final status value:
- PLAN mode: `status: "planned"`, TODO.md: `[PLANNED]`
- TRACK mode: `status: "tracked"`, TODO.md: `[TRACKED]`
- REPORT mode: `status: "reported"`, TODO.md: `[REPORTED]`

**Update state.json**:
```bash
# Determine final status based on mode
case "$mode_used" in
  PLAN) final_status="planned" ;;
  TRACK) final_status="tracked" ;;
  REPORT) final_status="reported" ;;
  *) final_status="planned" ;;  # Default to planned
esac

jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "$final_status" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts
  }' specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker to appropriate final marker (`[PLANNED]`, `[TRACKED]`, or `[REPORTED]`).

---

### Stage 8: Link Artifacts

Add artifact to state.json with summary.

**IMPORTANT**: Use two-step jq pattern to avoid escaping issues.

```bash
if [ -n "$artifact_path" ]; then
    # Step 1: Filter out existing timeline artifacts (use "| not" pattern)
    jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
        [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type == "timeline" | not)]' \
      specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json

    # Step 2: Add new timeline artifact
    jq --arg path "$artifact_path" \
       --arg type "$artifact_type" \
       --arg summary "$artifact_summary" \
      '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
      specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json
fi
```

**Update TODO.md**: Add timeline artifact link.

**Note**: For strategy/timelines/ artifacts, do NOT strip `specs/` prefix since path is already outside specs/.

Use count-aware artifact linking format per `.claude/rules/state-management.md` "Artifact Linking Format".

---

### Stage 9: Git Commit

```bash
git add -A
git commit -m "task ${task_number}: complete project ${mode_used,,}

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Note**: Commit message uses lowercase mode (plan, track, report).

---

### Stage 10: Cleanup

```bash
rm -f "specs/${padded_num}_${project_name}/.postflight-pending"
rm -f "specs/${padded_num}_${project_name}/.postflight-loop-guard"
rm -f "specs/${padded_num}_${project_name}/.return-meta.json"
```

---

### Stage 11: Return Brief Summary

**PLAN Mode**:
```
Project timeline created for task {N}:
- Mode: PLAN, {questions_asked} forcing questions completed
- Project: {project_name} (target: {target_date})
- WBS: {phase_count} phases, {task_count} tasks
- Timeline: strategy/timelines/{project-slug}.typ
- Status updated to [PLANNED]
- Changes committed
- Next: Use TRACK mode to update progress or REPORT for status summary
```

**TRACK Mode**:
```
Project timeline updated for task {N}:
- Mode: TRACK, progress recorded for {updated_count} tasks
- Project: {project_name}
- Progress: {percent}% complete ({completed} of {total} tasks)
- Timeline: strategy/timelines/{project-slug}.typ (updated)
- Status updated to [TRACKED]
- Changes committed
- Next: Generate REPORT for stakeholder summary
```

**REPORT Mode**:
```
Status report generated for task {N}:
- Mode: REPORT
- Project: {project_name}
- Status: {On Track|At Risk|Delayed}
- Report: strategy/timelines/{project-slug}-report.typ
- Status updated to [REPORTED]
- Changes committed
- Next: Share report with stakeholders
```

---

## Return Format

Brief text summary (NOT JSON).

Expected successful return follows mode-specific templates above.

---

## Error Handling

### Input Validation Errors

Return immediately if task not found or invalid mode:

```
Error: Task {N} not found in state.json
```

```
Error: Invalid mode: {mode}. Must be PLAN, TRACK, or REPORT
```

### Metadata File Missing

If `.return-meta.json` is missing or invalid after agent execution:
- Keep status as "planning" for resume
- Return partial status with recommendation to retry

### No Existing Timeline (TRACK/REPORT modes)

Agent will return error if timeline doesn't exist. Skill propagates:

```
Error: No existing timeline found. Use PLAN mode first.
```

### User Abandonment

If user abandons forcing questions:
- Agent writes partial metadata
- Skill keeps status as "planning"
- User can resume later

### Git Commit Failure

Non-blocking: Log failure but continue.
- Preserve changes for manual commit
- Return success with note about uncommitted changes

### Directory Creation Failure

If `strategy/timelines/` cannot be created:
- Agent will fail with error
- Skill propagates error to user
- Recommend checking permissions

---
