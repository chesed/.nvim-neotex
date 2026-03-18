---
description: Analyze market size using TAM/SAM/SOM framework with task integration
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Read, Edit
argument-hint: "[description]" | TASK_NUMBER | /path/to/file.md | --quick [industry] [segment]
---

# /market Command

Market sizing analysis command using TAM/SAM/SOM framework with task system integration.

## Overview

This command produces market sizing analysis artifacts through structured questioning. It creates a task, runs the founder-specific planning workflow with forcing questions, then executes the plan to generate investor-ready market sizing documents.

## Syntax

- `/market "fintech payments app"` - Create task and run full workflow
- `/market 234` - Operate on existing task (run /plan then /implement)
- `/market /path/to/context.md` - Use file as context, create task
- `/market --quick fintech payments` - Legacy standalone mode (no task creation)

## Input Types

| Input | Behavior |
|-------|----------|
| Description string | Create task, run /plan, run /implement |
| Task number | Load existing task, run /plan, run /implement |
| File path | Read file for context, create task, run workflow |
| `--quick [args]` | Legacy standalone mode (skip task creation) |

## Modes

| Mode | Posture | Focus |
|------|---------|-------|
| **VALIDATE** | Test assumptions | Evidence gathering, bottom-up sizing |
| **SIZE** | Comprehensive | All three tiers with methodology |
| **SEGMENT** | Deep dive | Specific segment breakdown |
| **DEFEND** | Investor-ready | Credibility, data sources, conservative estimates |

---

## CHECKPOINT 1: GATE IN

**Display header**:
```
[Market] TAM/SAM/SOM Market Sizing Analysis
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
  # Remove --quick from arguments
  args=$(echo "$ARGUMENTS" | sed 's/^--quick *//')
fi

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
# Expand path
file_path=$(eval echo "$file_path")

# Verify file exists
if [ ! -f "$file_path" ]; then
  echo "Error: File not found: $file_path"
  exit 1
fi

# Read file as context
context_content=$(cat "$file_path")

# Create description from filename
filename=$(basename "$file_path" | sed 's/\.[^.]*$//')
description="Market sizing: $filename"
```

**If task number**:
```bash
# Load existing task
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found"
  exit 1
fi

# Validate language is founder
task_lang=$(echo "$task_data" | jq -r '.language')
if [ "$task_lang" != "founder" ]; then
  echo "Error: Task $task_number is not a founder task (language: $task_lang)"
  exit 1
fi
```

**If description (new task)**:
Create task in next step.

### Step 4: Create Task (if needed)

Skip if task_number already exists.

```bash
# Get next task number
next_num=$(jq -r '.next_project_number' specs/state.json)

# Create slug from description
slug="market_sizing_$(echo "$description" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g' | cut -c1-40)"

# Create task in state.json
jq --argjson num "$next_num" \
   --arg name "$slug" \
   --arg desc "Market sizing: $description" \
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

# Update TODO.md
task_number=$next_num
```

### Step 5: Update TODO.md

Add task entry to TODO.md (if new task):

```markdown
### {task_number}. Market sizing: {description}
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: founder
- **Dependencies**: None
- **Started**: {ISO timestamp}

**Description**: {full description}
```

### Step 6: Git Commit (Task Creation)

```bash
git add specs/state.json specs/TODO.md
git commit -m "$(cat <<'EOF'
task {N}: create market sizing task

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## STAGE 2: DELEGATE

### STAGE 2A: Legacy Mode (--quick)

**If input_type == "quick"**:

Invoke skill-market directly (original behavior):

```
skill: "skill-market"
args: "industry={industry} segment={segment} mode={mode} session_id={session_id}"
```

Skip to CHECKPOINT 2 (Legacy).

### STAGE 2B: Task Workflow Mode

**Run /plan {task_number}**:

This routes to `skill-founder-plan` based on language="founder".

The plan workflow:
1. Presents mode selection
2. Conducts forcing questions to gather context
3. Creates plan with gathered data stored
4. Returns when planning complete

**Run /implement {task_number}**:

This routes to `skill-founder-implement` based on language="founder".

The implement workflow:
1. Loads plan with gathered context
2. Executes phases (TAM, SAM, SOM, Report)
3. Generates report to `strategy/market-sizing-{slug}.md`
4. Creates summary in task directory
5. Updates task to completed

---

## CHECKPOINT 2: GATE OUT

### For Task Workflow Mode

1. **Verify Task Completed**
   ```bash
   status=$(jq -r --argjson num "$task_number" \
     '.active_projects[] | select(.project_number == $num) | .status' \
     specs/state.json)
   ```

2. **Get Artifacts**
   ```bash
   artifacts=$(jq -r --argjson num "$task_number" \
     '.active_projects[] | select(.project_number == $num) | .artifacts' \
     specs/state.json)
   ```

3. **Display Result**
   ```
   Market sizing complete for Task #{N}

   Report: strategy/market-sizing-{slug}.md
   Summary: specs/{NNN}_{SLUG}/summaries/01_{short-slug}-summary.md

   Key Numbers:
   - TAM: ${TAM}
   - SAM: ${SAM}
   - SOM Y1: ${SOM}

   Status: [COMPLETED]
   ```

### For Legacy Mode (--quick)

```
Market sizing analysis generated.

Mode: {MODE}
Artifact: founder/market-sizing-{datetime}.md

Summary:
{summary}

Key Numbers:
- TAM: ${TAM}
- SAM: ${SAM}
- SOM: ${SOM}

Next: Review artifact and validate assumptions
```

---

## Error Handling

### Task Not Found (task number mode)

```
Error: Task {N} not found in state.json
Run /task "description" to create a new task
```

### File Not Found (file path mode)

```
Error: File not found: {path}
Verify the file path and try again
```

### Plan Creation Failed

```
Planning failed for Task #{N}
Error: {error_message}
Resume: /plan {N}
```

### Implementation Failed

```
Implementation failed for Task #{N}
Error: {error_message}
Resume: /implement {N}
```

### User Abandons Forcing Questions

Return partial status, task remains in [PLANNING]:
```
Market sizing planning partially completed.

Completed: {questions_completed}/{questions_total} forcing questions
Task: #{N} - Status: [PLANNING]

Resume: /plan {N}
```

---

## Output Artifacts

### Task Workflow Mode

| Artifact | Location |
|----------|----------|
| Implementation plan | `specs/{NNN}_{SLUG}/plans/01_{short-slug}.md` |
| Market sizing report | `strategy/market-sizing-{slug}.md` |
| Implementation summary | `specs/{NNN}_{SLUG}/summaries/01_{short-slug}-summary.md` |

### Legacy Mode (--quick)

| Artifact | Location |
|----------|----------|
| Market sizing analysis | `founder/market-sizing-{datetime}.md` |

---

## Examples

```bash
# Create new task with description
/market "fintech payments for SMBs"

# Operate on existing task
/market 234

# Use file as context
/market ~/startup/pitch-deck.md

# Legacy standalone mode
/market --quick fintech payments
```
