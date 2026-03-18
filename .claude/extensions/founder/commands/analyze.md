---
description: Competitive landscape research with task integration
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Read, Edit
argument-hint: "[description]" | TASK_NUMBER | /path/to/file.md | --quick [competitors]
---

# /analyze Command

Competitive analysis research command that gathers competitive intelligence through structured forcing questions. Integrates with the task system for tracking and artifacts.

## Overview

This command initiates competitive analysis research through structured questioning. It creates a task (if needed) and runs the research phase to gather competitor data, positioning insights, and strategic observations. After research completes, the user explicitly runs `/plan` and `/implement` to generate final strategy output.

## Syntax

- `/analyze "fintech payments competitors"` - Create task and run research
- `/analyze 234` - Resume research on existing task
- `/analyze /path/to/competitors.md` - Use file as context, create task, run research
- `/analyze --quick stripe,square,adyen` - Legacy standalone mode (no task creation)

## Input Types

| Input | Behavior |
|-------|----------|
| Description string | Create task, run research, stop at [RESEARCHED] |
| Task number | Load existing task, run research, stop at [RESEARCHED] |
| File path | Read file for context, create task, run research |
| `--quick [args]` | Legacy standalone mode (skip task creation) |

## Modes

| Mode | Posture | Focus |
|------|---------|-------|
| **LANDSCAPE** | Map the field | All competitors, categories |
| **DEEP** | Focus on key rivals | Top 3-5 detailed analysis |
| **POSITION** | Find white space | 2x2 maps, differentiation |
| **BATTLE** | Prepare for competition | Battle cards, objection handling |

---

## CHECKPOINT 1: GATE IN

**Display header**:
```
[Analyze] Competitive Landscape Research
```

### Step 1: Generate Session ID

```bash
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
```

### Step 2: Detect Input Type

```bash
# Check for --quick flag (legacy mode)
if echo "$ARGUMENTS" | grep -qE '^--quick'; then
  input_type="quick"
  args=$(echo "$ARGUMENTS" | sed 's/^--quick *//')

# Check for task number
elif echo "$ARGUMENTS" | grep -qE '^[0-9]+$'; then
  input_type="task_number"
  task_number="$ARGUMENTS"

# Check for file path
elif echo "$ARGUMENTS" | grep -qE '^\.|^/|^~|\.md$|\.txt$'; then
  input_type="file_path"
  file_path="$ARGUMENTS"

# Default: treat as description for new task
else
  input_type="description"
  description="$ARGUMENTS"
fi
```

### Step 3: Handle Input Type

**If `--quick` (legacy mode)**:
Skip to STAGE 2A (legacy delegation).

**If file path**:
```bash
file_path=$(eval echo "$file_path")
if [ ! -f "$file_path" ]; then
  echo "Error: File not found: $file_path"
  exit 1
fi
context_content=$(cat "$file_path")
filename=$(basename "$file_path" | sed 's/\.[^.]*$//')
description="Competitive analysis: $filename"
```

**If task number**:
```bash
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found"
  exit 1
fi

task_lang=$(echo "$task_data" | jq -r '.language')
if [ "$task_lang" != "founder" ]; then
  echo "Error: Task $task_number is not a founder task (language: $task_lang)"
  exit 1
fi
```

**If description (new task)**:
Create task in next step.

### Step 4: Create Task (if needed)

```bash
next_num=$(jq -r '.next_project_number' specs/state.json)
slug="competitive_analysis_$(echo "$description" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g' | cut -c1-40)"

jq --argjson num "$next_num" \
   --arg name "$slug" \
   --arg desc "Competitive analysis: $description" \
   --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '. + {next_project_number: ($num + 1)} |
    .active_projects += [{
      project_number: $num,
      project_name: $name,
      status: "not_started",
      language: "founder",
      description: $desc,
      created: $ts,
      artifacts: []
    }]' specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json

task_number=$next_num
```

### Step 5: Update TODO.md

Add task entry (if new task).

### Step 6: Git Commit (Task Creation)

```bash
git add specs/state.json specs/TODO.md
git commit -m "$(cat <<'EOF'
task {N}: create competitive analysis task

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## STAGE 2: DELEGATE

### STAGE 2A: Legacy Mode (--quick)

**If input_type == "quick"**:

Invoke skill-analyze directly (original behavior):

```
skill: "skill-analyze"
args: "competitors={competitors} mode={mode} session_id={session_id}"
```

Skip to CHECKPOINT 2 (Legacy).

### STAGE 2B: Task Workflow Mode

**Run research via skill-analyze**:

```
skill: "skill-analyze"
args: "task_number={task_number} session_id={session_id}"
```

The skill workflow:
1. Updates status to [RESEARCHING] (preflight)
2. Invokes analyze-agent for forcing questions
3. Agent creates research report at `specs/{NNN}_{SLUG}/reports/01_{short-slug}.md`
4. Updates status to [RESEARCHED] (postflight)
5. Links artifact and commits

**Note**: This command does NOT auto-invoke /plan or /implement. The user runs those separately.

---

## CHECKPOINT 2: GATE OUT

### For Task Workflow Mode

1. **Verify Research Completed**
   ```bash
   status=$(jq -r --argjson num "$task_number" \
     '.active_projects[] | select(.project_number == $num) | .status' \
     specs/state.json)

   if [ "$status" != "researched" ]; then
     echo "Research incomplete. Status: [$status]"
     echo "Resume: /analyze $task_number"
     exit 1
   fi
   ```

2. **Get Research Artifact**
   ```bash
   research_path=$(jq -r --argjson num "$task_number" \
     '.active_projects[] | select(.project_number == $num) | .artifacts[] | select(.type == "research") | .path' \
     specs/state.json)
   ```

3. **Display Result**
   ```
   Competitive analysis research complete for Task #{N}

   Research Report: {research_path}

   Data Gathered:
   - Direct competitors: {captured}
   - Indirect competitors: {captured}
   - Per-competitor analysis: {captured}
   - Positioning dimensions: {captured}
   - Strategic observations: {captured}

   Status: [RESEARCHED]

   Next Steps:
   - Review research report for accuracy
   - Run /plan {N} to create implementation plan
   - Run /implement {N} to generate full competitive analysis with positioning map
   ```

### For Legacy Mode (--quick)

```
Competitive analysis generated.

Mode: {MODE}
Artifact: founder/competitive-analysis-{datetime}.md

Summary:
{summary}

Competitors Analyzed:
- {competitor1}: {positioning}
- {competitor2}: {positioning}

Next: Review artifact and prepare for competitive situations
```

---

## Error Handling

### Task Not Found

```
Error: Task {N} not found in state.json
Run /task "description" to create a new task
```

### File Not Found

```
Error: File not found: {path}
Verify the file path and try again
```

### Research Incomplete

```
Research incomplete for Task #{N}
Status: [{current_status}]
Resume: /analyze {N}
```

---

## Output Artifacts

### Task Workflow Mode

| Artifact | Location |
|----------|----------|
| Research report | `specs/{NNN}_{SLUG}/reports/01_{short-slug}.md` |

**Note**: Full competitive analysis (`strategy/competitive-analysis-*.md`) is generated by `/implement`, not `/analyze`.

### Legacy Mode (--quick)

| Artifact | Location |
|----------|----------|
| Competitive analysis | `founder/competitive-analysis-{datetime}.md` |

---

## Workflow Summary

The standard three-stage workflow:

```
/analyze "description"  -> Creates task, runs research, stops at [RESEARCHED]
/plan {N}               -> Reads research report, creates implementation plan
/implement {N}          -> Executes plan, generates strategy/competitive-analysis-*.md
```

Each stage is a separate command invocation, giving the user control over the workflow.

---

## Examples

```bash
# Create new task with description - runs research only
/analyze "fintech payments competitors"

# Resume research on existing task
/analyze 234

# Use file as context
/analyze ~/startup/competitor-notes.md

# Legacy standalone mode (generates full output immediately)
/analyze --quick stripe,square,adyen
```
