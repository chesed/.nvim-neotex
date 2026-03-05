---
description: Create a phased implementation plan for a task
---

Create an implementation plan for the given task. Do NOT implement anything.

**Input**: $ARGUMENTS

---

## Parse Input

- First token: task number — accepts `OC_N` or `N` (strip `OC_` prefix to get integer N)
- Remaining tokens: optional notes/constraints
- If invalid: "Usage: /plan <OC_N> [notes]"

---

## Steps

### 1. Look up task

Strip `OC_` prefix, find task in `specs/state.json`:
```bash
jq --arg n "N" '.active_projects[] | select(.project_number == ($n | tonumber))' specs/state.json
```
If not found: "Task OC_N not found in state.json"

Extract: `language`, `status`, `project_name`, `description`

Zero-pad N to 3 digits: `NNN` (e.g. `printf "%03d" N`)

Directory: `specs/OC_NNN_<project_name>/`

### 2. Validate status

- `researched`, `not_started`, `partial`: proceed
- `planning`: warn "already planning, proceeding"
- `abandoned`: error "task is abandoned, use /task --recover first"
- `completed`: warn "already completed, re-planning"

### 3. Display task header

The skill displays a visual header during its Preflight stage to show the active task:

```
╔══════════════════════════════════════════════════════════╗
║  Task OC_N: <project_name>                               ║
║  Action: PLANNING                                         ║
╚══════════════════════════════════════════════════════════╝
```

This header appears at the start of the plan command (after validation, before delegation) to clearly indicate which task is being planned. The header is displayed by the skill-planner before invoking the planner-agent subagent.

### 4. Update status to PLANNING

Edit `specs/state.json`: set `status` to `"planning"`, update `last_updated`.

Edit `specs/TODO.md`: change current status marker to `[PLANNING]` on the `### OC_N.` entry.

### 5. Read existing research

Check for `specs/OC_NNN_<project_name>/reports/research-001.md`. If it exists, read it for context. If not, plan from the task description alone.

### 6. Invoke skill-planner

**Call skill tool** to execute the planning workflow:

```
→ Tool: skill
→ Name: skill-planner
→ Prompt: Create implementation plan for task {N} with language {language} and research context from {research_content}
```

The skill-planner will:
1. Load context files (plan-format.md, status-markers.md, task-breakdown.md)
2. Execute preflight (validate, display header, update status to PLANNING)
3. **Call Task tool with `subagent_type="planner-agent"`** to create the plan
4. Execute postflight (update state.json to PLANNED, update TODO.md, commit changes)
5. Return results

**CRITICAL**: Do NOT implement planning logic in this command. All planning logic belongs in skill-planner and planner-agent.

### 7. Report results

Show:
- Plan path
- Number of phases and estimated total effort
- Next step: `/implement OC_N`

---

## Rules

- The skill-planner handles ALL planning logic - do not implement in command
- Phases should be granular enough to be resumable if interrupted
- Directories use 3-digit padded number: `OC_174_slug` not `OC_17_slug`
- If plan already exists, create `implementation-002.md` (increment version)
- **NEVER use embedded plan templates** - always delegate to planner-agent with injected plan-format.md context
- **NO EMBEDDED TEMPLATES**: Do not include example plan structures in this file - they violate plan-format.md
