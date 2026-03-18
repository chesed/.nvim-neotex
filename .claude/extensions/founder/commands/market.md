---
description: Market sizing research using TAM/SAM/SOM framework with task integration
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Read, Edit
argument-hint: "[description]" | TASK_NUMBER | /path/to/file.md | --quick [industry] [segment]
---

# /market Command

Market sizing research command using TAM/SAM/SOM framework with task system integration.

## Overview

This command initiates market sizing research through structured forcing questions. It creates a task (if needed) and runs the research phase to gather market data. After research completes, the user explicitly runs `/plan` and `/implement` to generate final strategy output.

## Syntax

- `/market "fintech payments app"` - Create task and run research
- `/market 234` - Resume research on existing task
- `/market /path/to/context.md` - Use file as context, create task, run research
- `/market --quick fintech payments` - Legacy standalone mode (no task creation)

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
| **VALIDATE** | Test assumptions | Evidence gathering, bottom-up sizing |
| **SIZE** | Comprehensive | All three tiers with methodology |
| **SEGMENT** | Deep dive | Specific segment breakdown |
| **DEFEND** | Investor-ready | Credibility, data sources, conservative estimates |

---

## CHECKPOINT 1: GATE IN

**Display header**:
```
[Market] TAM/SAM/SOM Market Sizing Research
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

**Run research via skill-market**:

```
skill: "skill-market"
args: "task_number={task_number} session_id={session_id}"
```

The skill workflow:
1. Updates status to [RESEARCHING] (preflight)
2. Invokes market-agent for forcing questions
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
     echo "Resume: /market $task_number"
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
   Market sizing research complete for Task #{N}

   Research Report: {research_path}

   Data Gathered:
   - Problem definition: {captured}
   - Entity count: {captured}
   - Price point: {captured}
   - Geographic scope: {captured}
   - Capture rates: {captured}
   - Competitive context: {captured}

   Status: [RESEARCHED]

   Next Steps:
   - Review research report for accuracy
   - Run /plan {N} to create implementation plan
   - Run /implement {N} to generate final market sizing report
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

### Research Incomplete

```
Research incomplete for Task #{N}
Status: [{current_status}]
Resume: /market {N}
```

### User Abandons Forcing Questions

Return partial status, task remains in [RESEARCHING]:
```
Market sizing research partially completed.

Completed: {questions_completed}/{questions_total} forcing questions
Task: #{N} - Status: [RESEARCHING]

Resume: /market {N}
```

---

## Output Artifacts

### Task Workflow Mode

| Artifact | Location |
|----------|----------|
| Research report | `specs/{NNN}_{SLUG}/reports/01_{short-slug}.md` |

**Note**: Final market sizing report (`strategy/market-sizing-*.md`) is generated by `/implement`, not `/market`.

### Legacy Mode (--quick)

| Artifact | Location |
|----------|----------|
| Market sizing analysis | `founder/market-sizing-{datetime}.md` |

---

## Workflow Summary

The standard three-stage workflow:

```
/market "description"   -> Creates task, runs research, stops at [RESEARCHED]
/plan {N}               -> Reads research report, creates implementation plan
/implement {N}          -> Executes plan, generates strategy/market-sizing-*.md
```

Each stage is a separate command invocation, giving the user control over the workflow.

---

## Examples

```bash
# Create new task with description - runs research only
/market "fintech payments for SMBs"

# Resume research on existing task
/market 234

# Use file as context
/market ~/startup/pitch-deck.md

# Legacy standalone mode (generates full output immediately)
/market --quick fintech payments
```
