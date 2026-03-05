---
description: Execute implementation with resume support
---

Execute the implementation plan for the given task, phase by phase.

**Input**: $ARGUMENTS

---

## Parse Input

- First token: task number — accepts `OC_N` or `N` (strip `OC_` prefix to get integer N)
- `--force`: skip status validation
- Remaining tokens: optional custom instructions
- If invalid: "Usage: /implement <OC_N> [--force] [instructions]"

---

## Steps

### 1. Look up task

Strip `OC_` prefix, find task in `specs/state.json`:
```bash
jq --arg n "N" '.active_projects[] | select(.project_number == ($n | tonumber))' specs/state.json
```
If not found: "Task OC_N not found in state.json"

Extract: `language`, `status`, `project_name`, `description`

Zero-pad N to 3 digits: `NNN`

Directory: `specs/OC_NNN_<project_name>/`

### 2. Validate status (unless --force)

- `planned`, `partial`, `researched`, `not_started`: proceed
- `implementing`: warn "already implementing, resuming"
- `abandoned`: error "task is abandoned, use /task --recover first"
- `completed`: error "already completed, use --force to re-implement"

### 3. Display task header

The skill displays a visual header during its Preflight stage to show the active task:

```
╔══════════════════════════════════════════════════════════╗
║  Task OC_N: <project_name>                               ║
║  Action: IMPLEMENTING                                     ║
╚══════════════════════════════════════════════════════════╝
```

This header appears at the start of the implement command (after validation, before delegation) to clearly indicate which task is being implemented. The header is displayed by the skill-implementer before invoking the general-implementation-agent subagent.

### 4. Find implementation plan

Look for `specs/OC_NNN_<project_name>/plans/implementation-*.md` — use the highest version.

If no plan found: "No plan found. Run `/plan OC_N` first."

Read the plan to understand all phases and their current status (`[NOT STARTED]`, `[IN PROGRESS]`, `[COMPLETED]`, `[PARTIAL]`).

### 5. Update status to IMPLEMENTING

Edit `specs/state.json`: set `status` to `"implementing"`, update `last_updated`.

Edit `specs/TODO.md`: change current status marker to `[IMPLEMENTING]` on the `### OC_N.` entry.

### 6. Invoke skill-implementer

**Call skill tool** to execute the implementation workflow:

```
→ Tool: skill
→ Name: skill-implementer
→ Prompt: Execute implementation plan for task {N} with language {language}
```

The skill-implementer will:
1. Load context files (plan-format.md, status-markers.md)
2. Execute preflight (validate, display header, update status to IMPLEMENTING)
3. **Call Task tool with `subagent_type="general-implementation-agent"`** to execute phases
4. Execute postflight (update state.json to COMPLETED/IMPLEMENTING, create summary, update TODO.md, commit)
5. Return results

**CRITICAL**: Do NOT implement phase execution logic in this command. All implementation logic belongs in skill-implementer and general-implementation-agent.

**Phase Status Tracking**: The skill-implementer maintains phase status in the plan file as source of truth for resume points.

**Language-specific guidance**:
- **meta**: Edit `.opencode/` files, create/update agent and command definitions
- **lean**: Write Lean 4 proofs, use `lake build` to verify
- **typst**: Write Typst markup, use `typst compile` to verify
- **latex**: Write LaTeX, use `pdflatex` to verify
- **general**: Follow the plan steps using appropriate tools

### 7. Report results

Show:
- Phases completed
- Files changed
- Summary path
- Any follow-up suggestions

---

## Rules

- The skill-implementer handles ALL implementation logic - do not implement in command
- Execute phases in order — do not skip ahead
- Mark each phase `[COMPLETED]` in the plan file as you finish it
- If a phase fails, mark it `[PARTIAL]` in the plan and stop — do not mark task completed
- Write the summary BEFORE updating status to COMPLETED
- Directories use 3-digit padded number: `OC_174_slug` not `OC_17_slug`
- For Lean tasks, always verify with `lake build` after each phase
- **Commit after each phase completion** — stage only files modified in that phase
- **Commit when blocked** — if phase fails, commit partial progress before stopping
