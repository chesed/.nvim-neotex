---
description: Go-to-market strategy research with task integration
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Read, Edit
argument-hint: "[description]" | TASK_NUMBER | /path/to/file.md | --quick [topic]
---

# /strategy Command

Go-to-market strategy research command that gathers positioning, channel, and launch context through structured forcing questions. Integrates with the task system for tracking and artifacts.

## Overview

This command initiates GTM strategy research through structured questioning. It creates a task (if needed) and runs the research phase to gather strategic context. After research completes, the user explicitly runs `/plan` and `/implement` to generate final strategy output with 90-day plans.

## Syntax

- `/strategy "B2B SaaS product launch"` - Create task and run research
- `/strategy 234` - Resume research on existing task
- `/strategy /path/to/strategy-notes.md` - Use file as context, create task, run research
- `/strategy --quick B2B SaaS launch` - Legacy standalone mode (no task creation)

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
| **LAUNCH** | Maximize splash | Awareness, differentiation, initial traction |
| **SCALE** | Optimize engine | CAC optimization, channel scaling, automation |
| **PIVOT** | Find new wedge | Customer segments, value prop testing |
| **EXPAND** | Adjacent markets | New segments, expansion playbook |

---

## CHECKPOINT 1: GATE IN

**Display header**:
```
[Strategy] Go-to-Market Strategy Research
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

**Run research via skill-strategy**:

```
skill: "skill-strategy"
args: "task_number={task_number} session_id={session_id}"
```

The skill workflow:
1. Updates status to [RESEARCHING] (preflight)
2. Invokes strategy-agent for forcing questions
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
     echo "Resume: /strategy $task_number"
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
   GTM strategy research complete for Task #{N}

   Research Report: {research_path}

   Data Gathered:
   - Target customer: {captured}
   - Problem/need: {captured}
   - Key benefit: {captured}
   - Differentiator: {captured}
   - Channel data: {captured}
   - Launch context: {captured}
   - North Star metric: {captured}

   Status: [RESEARCHED]

   Next Steps:
   - Review research report for accuracy
   - Run /plan {N} to create implementation plan
   - Run /implement {N} to generate full GTM strategy with 90-day plan
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

### Research Incomplete

```
Research incomplete for Task #{N}
Status: [{current_status}]
Resume: /strategy {N}
```

---

## Output Artifacts

### Task Workflow Mode

| Artifact | Location |
|----------|----------|
| Research report | `specs/{NNN}_{SLUG}/reports/01_{short-slug}.md` |

**Note**: Full GTM strategy (`strategy/gtm-strategy-*.md`) is generated by `/implement`, not `/strategy`.

### Legacy Mode (--quick)

| Artifact | Location |
|----------|----------|
| GTM strategy | `founder/gtm-strategy-{datetime}.md` |

---

## Workflow Summary

The standard three-stage workflow:

```
/strategy "description" -> Creates task, runs research, stops at [RESEARCHED]
/plan {N}               -> Reads research report, creates implementation plan
/implement {N}          -> Executes plan, generates strategy/gtm-strategy-*.md
```

Each stage is a separate command invocation, giving the user control over the workflow.

---

## Examples

```bash
# Create new task with description - runs research only
/strategy "B2B SaaS product launch"

# Resume research on existing task
/strategy 234

# Use file as context
/strategy ~/startup/launch-notes.md

# Legacy standalone mode (generates full output immediately)
/strategy --quick B2B SaaS launch
```
