---
description: Create, recover, expand, sync, or abandon tasks
---

Manage tasks in specs/TODO.md and specs/state.json. Do NOT implement the task — only manage the task entry.

**Input**: $ARGUMENTS

---

## Parse Input

- No flags → **create** mode (input is the task description)
- `--recover OC_N` → **recover** mode (restore abandoned task N to [NOT STARTED])
- `--expand OC_N "prompt"` → **expand** mode (add details to existing task N)
- `--sync` → **sync** mode (reconcile TODO.md and state.json)
- `--abandon OC_N` → **abandon** mode (mark task N as [ABANDONED])

Strip the `OC_` prefix to get the integer N for state.json lookups.

---

## CREATE mode

**CRITICAL: DO NOT IMPLEMENT**

When processing /task command in CREATE mode:
- **ONLY** create task entries in specs/TODO.md and specs/state.json
- **NEVER** write code, scripts, or solutions
- **NEVER** create files outside of specs/TODO.md and state.json
- **NEVER** interpret problem descriptions as requests to fix the problem

If the task description mentions a problem or bug, create the task entry ONLY.
Let the user decide later if they want to research/plan/implement via separate commands.

### Agent Role for /task

You are a **task administrator**, not a problem solver. Your job is to:
- Record tasks in the tracking system
- Update task statuses
- Manage task lifecycle (create, abandon, recover, expand, sync)

You do NOT:
- Write implementation code
- Create scripts or tools
- Research solutions
- Execute plans

Stay within the boundaries of task management only. If a task description 
describes a problem, your only action is to create the task entry.

---

### Step 1: Validate Input

Before processing a task creation request, check:

**CHECK**: Does the description mention a problem that needs fixing?  
**ACTION**: Create task entry ONLY. Do NOT attempt to fix the problem.  
**WHY**: /task creates tracking entries. Use /research, /plan, /implement to solve problems.

**CHECK**: Does the user seem to be asking for code, scripts, or solutions?  
**ACTION**: Create task entry with the description as-is. Do NOT write the code.  
**WHY**: Let the user explicitly invoke /implement when they're ready.

**CHECK**: Is the user describing a bug or issue they want tracked?  
**ACTION**: Create task entry. Do NOT investigate or fix the bug.  
**WHY**: Investigation belongs in /research phase, fixes in /implement phase.

**STOP**: If you find yourself wanting to write code, create scripts, or implement solutions, STOP. Your role is task administration only.

---

### Step 2: Initialize specs/ Directory if Missing

- If `specs/` directory does not exist, create it with `mkdir -p specs/archive`
- If `specs/state.json` does not exist, create it with initial content:
  ```json
  {
    "version": "1.0.0",
    "next_project_number": 1,
    "active_projects": [],
    "completed_projects": [],
    "repository_health": {}
  }
  ```
- If `specs/TODO.md` does not exist, create it with initial content:
  ```markdown
  # Task List

  ## Tasks
  ```
- Report: "Initialized task tracking system in specs/"

---

### Step 3: Execute Preflight

**CRITICAL**: Commands must execute preflight BEFORE delegating to agents. The skill tool only loads skill definitions but does NOT execute workflows.

**Calculate task details**:
1. Read `specs/state.json` to get `next_project_number` (call it N)
2. Generate slug from title: lowercase, spaces→underscores, strip punctuation
3. Infer language: `lean` (proofs/theorems/Lean), `typst` (Typst docs), `latex` (LaTeX docs), `meta` (.opencode/.claude/ changes), `general` (everything else)
4. Estimate effort from description complexity (e.g. "2 hours", "4-6 hours")
5. Zero-pad N to 3 digits: `NNN` (e.g. `printf "%03d" N`)
6. Directory will be: `specs/OC_NNN_<project_name>/`

**Update state.json to creating**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "creating" \
  '(.active_projects[] | select(.project_number == N)) |= . + {
    status: $status,
    last_updated: $ts,
    creating: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md to [CREATING]**:
- Edit file: `specs/TODO.md`
- Find line: `- **Status**: [NOT STARTED]` (or current status) for task OC_N
- Change to: `- **Status**: [CREATING]`

**Create task-creating marker file**:
```bash
touch "specs/OC_NNN_<project_name>/.task-creating"
```

---

### Step 4: Delegate to Task Agent

**Call skill tool** to load skill context and delegate to task-creation agent:

```
→ Tool: skill
→ Name: skill-task
→ Prompt: Create task entry for task {N} with description "...", language {language}, effort {effort}
```

The skill-task will:
1. Load context files (return-metadata-file.md, postflight-control.md, etc.)
2. **Call Task tool with `subagent_type="task-creation-agent"`** to create the task entry
3. Return results (subagent writes .return-meta.json)

**CRITICAL**: The skill tool ONLY loads skill definitions. It does NOT execute preflight/postflight workflows. This command MUST execute status updates before and after delegation.

---

### Step 5: Execute Postflight

**CRITICAL**: Commands must execute postflight AFTER agents return. The skill tool does NOT execute workflows.

**Step 5a: Read metadata file**:
```bash
metadata_file="specs/OC_NNN_<project_name>/.return-meta.json"
if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
    status=$(jq -r '.status' "$metadata_file")
    task_number=$(jq -r '.metadata.task_number // 0' "$metadata_file")
    project_name=$(jq -r '.metadata.project_name // ""' "$metadata_file")
fi
```

**Step 5b: Determine final status**:
- If `status` == "created": final_status="not_started"
- If `status` == "partial": final_status="partial"
- Otherwise: final_status="not_started" (default)

**Step 5c: Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "$final_status" \
  '(.active_projects[] | select(.project_number == N)) |= . + {
    status: $status,
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Step 5d: Update TODO.md**:
- Edit file: `specs/TODO.md`
- Find line: `- **Status**: [CREATING]` for task OC_N
- Change to: `- **Status**: [NOT STARTED]` (or [PARTIAL] if final_status is "partial")

**Step 5e: Verify task entry**:
- Verify task entry exists in state.json
- Verify task entry exists in TODO.md
- Verify task directory was created

**Step 5f: Git commit**:
```bash
git add -A
git commit -m "task N: create task entry

Session: ${session_id}"
```

**Step 5g: Cleanup**:
```bash
rm -f "specs/OC_NNN_<project_name>/.task-creating"
rm -f "specs/OC_NNN_<project_name>/.return-meta.json"
```

**Step 5h: Report results**:
- Show: Task number, status, directory path

---

## CREATE Mode: Task Entry Details

The task-creation-agent follows these steps to create the task entry:

1. **Write state.json**: Increment `next_project_number`, append to `active_projects`:
```json
{
  "project_number": N,
  "project_name": "slug_here",
  "status": "not_started",
  "language": "general",
  "created": "2026-01-01T00:00:00Z",
  "last_updated": "2026-01-01T00:00:00Z",
  "artifacts": []
}
```

2. **Prepend to the `## Tasks` section of TODO.md** (before existing tasks):
```markdown
### OC_N. Title Here
- **Effort**: X hours
- **Status**: [NOT STARTED]
- **Language**: general

**Description**: Full description here.

---
```

3. **Report**: "Created task OC_N: Title"

---

## RECOVER mode (`--recover N`)

1. Find task N in state.json and TODO.md
2. Change status from `abandoned` → `not_started` in state.json
3. Change `[ABANDONED]` → `[NOT STARTED]` in TODO.md
4. Move task back to active_projects in state.json (remove from archive if present)
5. Report: "Recovered task N"

---

## EXPAND mode (`--expand N "additional details"`)

1. Find task N in state.json and TODO.md
2. Append the additional details to the description in TODO.md
3. Update `last_updated` in state.json
4. Report: "Expanded task N with additional details"

---

## SYNC mode (`--sync`)

1. Compare active_projects in state.json against TODO.md entries
2. For each mismatch, update TODO.md to match state.json (state.json is authoritative)
3. Report: "Synced N entries"

---

## ABANDON mode (`--abandon N`)

Archives a task by moving it from active state to archive, consistent with the `/todo` command behavior.

1. Find task N in state.json and TODO.md
2. Verify task is not already archived (check archive/state.json)
3. Change status to `abandoned` in state.json and add `abandoned` timestamp (ISO 8601 format)
4. Move task from state.json active_projects to archive/state.json completed_projects:
   ```bash
   # Remove from active_projects
   jq 'del(.active_projects[] | select(.project_number == N))' specs/state.json
   
   # Add to completed_projects with archived timestamp
   jq '.completed_projects += [{...task with "archived": "timestamp"}]' specs/archive/state.json
   ```
5. Move task directory from specs/ to specs/archive/ (if directory exists):
   - Check for: `specs/OC_NNN_slug/` or `specs/N_slug/`
   - Move to: `specs/archive/OC_NNN_slug/` or `specs/archive/N_slug/`
   - Skip if directory doesn't exist (gracefully handle missing directories)
6. Remove task entry from specs/TODO.md:
   - Remove entire task block: from `### OC_N.` header through `---` separator
7. Report: "Abandoned and archived task OC_N"

**Note**: This archival workflow is consistent with the `/todo` command. Abandoned tasks should be fully archived to keep the active task list clean.

---

## Rules

- This command executes preflight (status → creating) BEFORE delegating to skill-task
- This command executes postflight (status → not_started, verify entries) AFTER skill-task returns
- The skill-task only loads context and delegates to task-creation-agent — it does NOT execute workflows
- **NEVER** create directories or files other than TODO.md and state.json edits (except for archival moves in ABANDON mode, and initial specs/ directory creation)
- **NEVER** start implementing the task
- Timestamps use ISO 8601 format: `2026-01-01T00:00:00Z`
- Task numbers are plain integers (no OC_ prefix in these files)
- After all edits, show a brief summary of what changed

---

## Critical Notes

**The skill tool only loads SKILL.md content — it does NOT execute preflight/postflight workflows.**

Commands must execute these workflows themselves:
1. **Preflight** (Step 3): Calculate task details, update state.json to "creating", TODO.md to [CREATING], create marker file
2. **Delegation** (Step 4): Call skill-task to load context and invoke task-creation-agent
3. **Postflight** (Step 5): Read .return-meta.json, verify task entries, update state.json to "not_started", update TODO.md, commit, cleanup

This pattern ensures:
- Status updates happen automatically without orchestrator intervention
- Consistency with `/implement`, `/plan`, `/research` commands
- Agents follow the expected "command orchestrates workflow" pattern

## Workflow Phases

The agent system follows a strict phased workflow. Each command corresponds to 
a specific phase. **Never skip phases.**

| Phase | Command | Purpose | Creates Artifacts? |
|-------|---------|---------|-------------------|
| 1 | `/task` | Create tracking entry only | No (only TODO.md/state.json) |
| 2 | `/research OC_N` | Investigate and document findings | Yes (research-NNN.md) |
| 3 | `/plan OC_N` | Create implementation strategy | Yes (implementation-NNN.md) |
| 4 | `/implement OC_N` | Execute the solution | Yes (code files, summaries) |

### Key Principle

**Creating a task does NOT imply researching, planning, or implementing it.**

When a user runs `/task "Fix the login bug"`, they are saying:
- "I want to track this problem"
- NOT "Fix this problem now"

The user will explicitly invoke subsequent commands when ready:
- `/research OC_N` when they want investigation
- `/plan OC_N` when they want a strategy
- `/implement OC_N` when they want execution
