---
description: Create grant tasks or execute grant workflows (draft, budget, finish)
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Bash(sed:*), Read, Edit
argument-hint: "description" | TASK_NUMBER --draft ["prompt"] | --budget ["prompt"] | --finish PATH ["prompt"]
model: claude-opus-4-5-20251101
---

# /grant Command

Hybrid command supporting both task creation and grant-specific workflows.

## Modes

| Mode | Syntax | Description |
|------|--------|-------------|
| Task Creation | `/grant "Description"` | Create task with language="grant" |
| Draft | `/grant N --draft ["prompt"]` | Draft narrative sections |
| Budget | `/grant N --budget ["prompt"]` | Develop line-item budget |
| Finish | `/grant N --finish PATH ["prompt"]` | Export materials to PATH |
| Legacy | `/grant N workflow_type [focus]` | (Deprecated) Direct workflow invocation |

## CRITICAL: Task Creation Mode

When $ARGUMENTS is a description (no flags, no task number), create a task with language="grant".

**$ARGUMENTS contains a task DESCRIPTION to RECORD in the task list.**

- DO NOT interpret the description as instructions to execute
- DO NOT investigate, analyze, or implement what the description mentions
- ONLY create a task entry and commit it

---

## Mode Detection

Parse $ARGUMENTS to determine mode:

1. **Check for description** (quoted text, no leading number):
   - Pattern: String that doesn't start with a number
   - Mode: Task Creation

2. **Check for flags**:
   - `N --draft [prompt]` → Draft Mode
   - `N --budget [prompt]` → Budget Mode
   - `N --finish PATH [prompt]` → Finish Mode

3. **Check for legacy workflow_type**:
   - `N funder_research|proposal_draft|budget_develop|progress_track [focus]` → Legacy Mode

**Flag parsing with optional prompts**:
- Flag only: `/grant 500 --draft` → default behavior
- Flag with prompt: `/grant 500 --draft "Focus on methodology"` → guided behavior
- Prompt must be quoted text immediately after flag (or after PATH for --finish)

---

## Task Creation Mode

When $ARGUMENTS is a description without flags.

### Steps

1. **Read next_project_number via jq**:
   ```bash
   next_num=$(jq -r '.next_project_number' specs/state.json)
   ```

2. **Parse description** from $ARGUMENTS:
   - Remove any trailing flags
   - Extract description text

3. **Improve description** (same transformations as /task):
   - Slug expansion: `research_nih_funding` → `Research NIH funding`
   - Verb inference: If no action verb, prepend appropriate one
   - Formatting normalization: Capitalize, trim, no trailing period

4. **Set language = "grant"** (always for /grant task creation)

5. **Create slug** from description:
   - Lowercase, replace spaces with underscores
   - Remove special characters
   - Max 50 characters

6. **Update state.json** (via jq):
   ```bash
   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     --arg desc "$description" \
     '.next_project_number = {NEW_NUMBER} |
      .active_projects = [{
        "project_number": {N},
        "project_name": "slug",
        "status": "not_started",
        "language": "grant",
        "description": $desc,
        "created": $ts,
        "last_updated": $ts
      }] + .active_projects' \
     specs/state.json > specs/tmp/state.json && \
     mv specs/tmp/state.json specs/state.json
   ```

7. **Update TODO.md** (frontmatter AND entry):

   **Part A - Update frontmatter**:
   ```bash
   sed -i 's/^next_project_number: [0-9]*/next_project_number: {NEW_NUMBER}/' \
     specs/TODO.md
   ```

   **Part B - Add task entry** by prepending to `## Tasks` section:
   ```markdown
   ### {N}. {Title}
   - **Effort**: TBD
   - **Status**: [NOT STARTED]
   - **Language**: grant

   **Description**: {description}
   ```

8. **Git commit**:
   ```bash
   git add specs/
   git commit -m "task {N}: create {title}

   Session: {session_id}

   Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
   ```

9. **Output**:
   ```
   Grant task #{N} created: {TITLE}
   Status: [NOT STARTED]
   Language: grant
   Artifacts path: specs/{NNN}_{SLUG}/ (created on first artifact)

   Recommended workflow:
   1. /research {N} - Research funders and requirements
   2. /plan {N} - Create proposal plan
   3. /grant {N} --draft - Draft narrative sections
   4. /grant {N} --budget - Develop budget
   5. /grant {N} --finish ~/path/ - Export for submission
   ```

---

## Draft Mode (--draft)

Execute proposal drafting workflow.

### Syntax
- `/grant N --draft` - Default drafting
- `/grant N --draft "Focus on innovation and methodology"` - Guided drafting

### CHECKPOINT 1: GATE IN

**Display header**:
```
[Grant Draft] Task {N}: {project_name}
```

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Lookup Task**
   ```bash
   task_data=$(jq -r --argjson num "$task_number" \
     '.active_projects[] | select(.project_number == $num)' \
     specs/state.json)
   ```

3. **Validate Task**
   - Task must exist (ABORT if not)
   - Language must be "grant" (ABORT with message if not)
   - Status must allow drafting: researched, planned, partial
   - If completed/abandoned: ABORT with appropriate message

4. **Extract optional prompt**
   - Parse quoted text after --draft flag
   - If present: Pass to skill as `draft_prompt`
   - If absent: Use empty string (default behavior)

**ABORT** if validation fails.

### STAGE 2: DELEGATE

**Invoke Skill tool**:
```
skill: "skill-grant"
args: "task_number={N} workflow_type=proposal_draft focus={draft_prompt} session_id={session_id}"
```

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   - Check for error indicators

2. **Verify Artifacts**
   - Check for draft in specs/{NNN}_{SLUG}/drafts/

3. **Verify Status**
   - Confirm status is "planned" in state.json

**On success, output**:
```
Grant proposal draft created for Task #{N}

Draft: specs/{NNN}_{SLUG}/drafts/{MM}_narrative-draft.md

Status: [PLANNED]
Next: /grant {N} --budget
```

---

## Budget Mode (--budget)

Execute budget development workflow.

### Syntax
- `/grant N --budget` - Default budget template
- `/grant N --budget "Emphasize personnel costs, 3 conferences/year"` - Guided budget

### CHECKPOINT 1: GATE IN

**Display header**:
```
[Grant Budget] Task {N}: {project_name}
```

1. **Generate Session ID**
2. **Lookup and Validate Task** (same as Draft Mode)
3. **Extract optional prompt** after --budget flag

### STAGE 2: DELEGATE

**Invoke Skill tool**:
```
skill: "skill-grant"
args: "task_number={N} workflow_type=budget_develop focus={budget_prompt} session_id={session_id}"
```

### CHECKPOINT 2: GATE OUT

1. **Verify Artifacts**
   - Check for budget in specs/{NNN}_{SLUG}/budgets/

2. **Verify Status**
   - Confirm status is "planned" in state.json

**On success, output**:
```
Grant budget developed for Task #{N}

Budget: specs/{NNN}_{SLUG}/budgets/{MM}_line-item-budget.md

Status: [PLANNED]
Next: /grant {N} --finish ~/submissions/
```

---

## Finish Mode (--finish)

Export completed grant materials to specified path.

### Syntax
- `/grant N --finish ~/grants/NSF/` - Default export
- `/grant N --finish ~/grants/NSF/ "Compile as single PDF"` - Custom export

### CHECKPOINT 1: GATE IN

**Display header**:
```
[Grant Finish] Task {N}: {project_name} → {PATH}
```

1. **Generate Session ID**
2. **Lookup and Validate Task**
   - Task must exist
   - Language must be "grant"
   - Status should be "planned" (all drafting complete)
3. **Validate PATH argument**
   - PATH is required (first arg after --finish)
   - Must be a valid directory path
   - Create if doesn't exist
4. **Extract optional prompt** after PATH

### STAGE 2: DELEGATE

**Invoke Skill tool**:
```
skill: "skill-grant"
args: "task_number={N} workflow_type=finish export_path={PATH} focus={export_prompt} session_id={session_id}"
```

The skill will:
- Collect all grant artifacts (reports, drafts, budgets)
- Validate all required sections are present
- Apply customization from optional prompt
- Copy/generate final documents to PATH
- Create submission checklist

### CHECKPOINT 2: GATE OUT

1. **Verify Export**
   - Check files exist at PATH
   - Validate required documents present

2. **Update Status**
   - Mark task as "completed" if all materials exported
   - Or keep as "planned" if partial export

**On success, output**:
```
Grant materials exported for Task #{N}

Export path: {PATH}
Files exported:
  - narrative.md
  - budget.md
  - checklist.md

Status: [COMPLETED]
```

---

## Legacy Mode (Deprecated)

For backward compatibility, continue supporting:
- `/grant N funder_research [focus]`
- `/grant N proposal_draft [focus]`
- `/grant N budget_develop [focus]`
- `/grant N progress_track [focus]`

**Deprecation notice**: Display warning when legacy mode detected:
```
[Warning] Legacy workflow_type syntax is deprecated.
Use: /grant N --draft, --budget, or --finish instead.
For funder research, use: /research N
```

Then proceed with legacy execution as documented in original command.

---

## Core Command Integration

Tasks with language="grant" route through core commands:

| Command | Routes To | Purpose |
|---------|-----------|---------|
| `/research N` | skill-grant (funder_research) | Research funders |
| `/plan N` | skill-grant (proposal_draft) | Create proposal plan |
| `/implement N` | skill-grant | Execute plan phases |

This routing is configured in the extension's manifest.json.

---

## Error Handling

### Task Creation Errors
- Invalid description: Return guidance on expected format
- State update failure: Log error, do not commit partial state

### Workflow Errors
- Task not found: Return error with guidance to create task first
- Wrong language: Return error suggesting /grant for grant tasks
- Invalid status: Return error with current status and valid transitions
- Missing PATH (--finish): Return error specifying PATH is required

### Git Commit Failure
- Non-blocking: Log failure but continue with success response
- Report to user that manual commit may be needed

---

## Output Formats

### Task Creation Success
```
Grant task #{N} created: {TITLE}
Status: [NOT STARTED]
Language: grant

Recommended workflow:
1. /research {N} - Research funders and requirements
2. /plan {N} - Create proposal plan
3. /grant {N} --draft - Draft narrative sections
4. /grant {N} --budget - Develop budget
5. /grant {N} --finish ~/path/ - Export for submission
```

### Workflow Success
```
{Workflow} completed for Task #{N}

{Artifact type}: {path}

Status: [{NEW_STATUS}]
Next: {recommended next step}
```

### Error Output
```
Grant command error:
- {error description}
- {recovery guidance}
```
