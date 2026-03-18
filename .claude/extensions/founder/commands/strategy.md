---
description: Go-to-market strategy development with task integration
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Read, Edit
argument-hint: "[description]" | TASK_NUMBER | /path/to/file.md | --quick [topic]
---

# /strategy Command

Go-to-market strategy command that develops positioning, channel strategy, and 90-day execution plans. Integrates with the task system for tracking and artifacts.

## Overview

This command produces GTM strategy artifacts through structured questioning. It creates a task, runs the founder-specific planning workflow with forcing questions, then executes the plan to generate actionable launch plans.

## Syntax

- `/strategy "B2B SaaS product launch"` - Create task and run full workflow
- `/strategy 234` - Operate on existing task (run /plan then /implement)
- `/strategy /path/to/strategy-notes.md` - Use file as context, create task
- `/strategy --quick B2B SaaS launch` - Legacy standalone mode (no task creation)

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
| **LAUNCH** | Maximize splash | Awareness, differentiation, initial traction |
| **SCALE** | Optimize engine | CAC optimization, channel scaling, automation |
| **PIVOT** | Find new wedge | Customer segments, value prop testing |
| **EXPAND** | Adjacent markets | New segments, expansion playbook |

---

## CHECKPOINT 1: GATE IN

**Display header**:
```
[Strategy] Go-to-Market Strategy Development
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
file_path=$(eval echo "$file_path")
if [ ! -f "$file_path" ]; then
  echo "Error: File not found: $file_path"
  exit 1
fi
context_content=$(cat "$file_path")
filename=$(basename "$file_path" | sed 's/\.[^.]*$//')
description="GTM strategy: $filename"
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
slug="gtm_strategy_$(echo "$description" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g' | cut -c1-40)"

jq --argjson num "$next_num" \
   --arg name "$slug" \
   --arg desc "GTM strategy: $description" \
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
task {N}: create GTM strategy task

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## STAGE 2: DELEGATE

### STAGE 2A: Legacy Mode (--quick)

**If input_type == "quick"**:

Invoke skill-strategy directly (original behavior):

```
skill: "skill-strategy"
args: "topic={topic} mode={mode} session_id={session_id}"
```

Skip to CHECKPOINT 2 (Legacy).

### STAGE 2B: Task Workflow Mode

**Run /plan {task_number}**:

Routes to `skill-founder-plan` based on language="founder".

The plan workflow:
1. Presents mode selection (LAUNCH, SCALE, PIVOT, EXPAND)
2. Conducts forcing questions for GTM strategy
3. Creates plan with gathered data stored
4. Returns when planning complete

**Run /implement {task_number}**:

Routes to `skill-founder-implement` based on language="founder".

The implement workflow:
1. Loads plan with gathered context
2. Executes phases (Positioning, Channels, Launch Plan, Metrics)
3. Generates report to `strategy/gtm-strategy-{slug}.md`
4. Creates summary in task directory
5. Updates task to completed

---

## CHECKPOINT 2: GATE OUT

### For Task Workflow Mode

1. **Verify Task Completed**
2. **Get Artifacts**
3. **Display Result**
   ```
   GTM strategy complete for Task #{N}

   Report: strategy/gtm-strategy-{slug}.md
   Summary: specs/{NNN}_{SLUG}/summaries/01_{short-slug}-summary.md

   Positioning:
   For {target} who {problem}, {product} is a {category} that {benefit}.
   Unlike {competitor}, we {differentiator}.

   Top Channels:
   1. {channel1} - CAC: ${CAC1}
   2. {channel2} - CAC: ${CAC2}

   Status: [COMPLETED]
   ```

### For Legacy Mode (--quick)

```
GTM strategy generated.

Mode: {MODE}
Artifact: founder/gtm-strategy-{datetime}.md

Summary:
{summary}

Positioning:
For {target} who {problem}, {product} is a {category} that {benefit}.

Top Channels:
1. {channel1} - CAC: ${CAC1}
2. {channel2} - CAC: ${CAC2}

Next: Review 90-day plan and assign owners
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

---

## Output Artifacts

### Task Workflow Mode

| Artifact | Location |
|----------|----------|
| Implementation plan | `specs/{NNN}_{SLUG}/plans/01_{short-slug}.md` |
| GTM strategy report | `strategy/gtm-strategy-{slug}.md` |
| Implementation summary | `specs/{NNN}_{SLUG}/summaries/01_{short-slug}-summary.md` |

### Legacy Mode (--quick)

| Artifact | Location |
|----------|----------|
| GTM strategy | `founder/gtm-strategy-{datetime}.md` |

---

## Examples

```bash
# Create new task with description
/strategy "B2B SaaS product launch"

# Operate on existing task
/strategy 234

# Use file as context
/strategy ~/startup/launch-notes.md

# Legacy standalone mode
/strategy --quick B2B SaaS launch
```
