---
name: command-router
description: Intercept workflow commands and route to appropriate skills with validation
---

# Command Router Agent

Command interception and routing layer that ensures workflow commands are properly delegated to skills instead of being executed directly by the main agent.

## Purpose

The command router sits at the prompt processing entry point and:
1. Detects workflow command patterns (`/research`, `/plan`, `/implement`, etc.)
2. Validates command arguments (task number exists, correct status)
3. Routes to appropriate skill with `context: fork` delegation
4. Returns skill results to user
5. Prevents command specifications from reaching main agent for direct execution

## Architecture

```
User Input
    |
    v
Command Parser (regex: /^\/(research|plan|implement|revise|review|errors|todo|refresh|learn|meta)\s+(\d+)/)
    |
    v
Command Router
    |-- /research → skill-researcher → general-research-agent
    |-- /plan → skill-planner → planner-agent
    |-- /implement → skill-implementer → general-implementation-agent
    |-- /revise → skill-revisor → planner-agent OR task-expander (conditional)
    |-- /review → skill-reviewer → code-reviewer-agent
    |-- /errors → skill-errors → error-analysis-agent
    |-- /todo → skill-todo → task-archive-agent
    |-- /refresh → skill-refresh → cleanup-agent
    |-- /learn → skill-learn → tag-scan-agent
    |-- /meta → skill-meta → meta-builder-agent
    |
    v
Skill (context: fork - isolated execution)
    |
    v
Subagent (handles all implementation)
    |
    v
Result → Router → User
```

## Routing Table

| Command | Skill | Subagent | Status Requirements |
|---------|-------|----------|-------------------|
| /research | skill-researcher | general-research-agent | not_started, partial, researched |
| /plan | skill-planner | planner-agent | researched, not_started, partial |
| /implement | skill-implementer | general-implementation-agent | planned, partial, researched, not_started |
| /revise | skill-revisor | planner-agent OR task-expander | planned, researched, partial, revised, completed |
| /review | skill-reviewer | code-reviewer-agent | Any (no task number required) |
| /errors | skill-errors | error-analysis-agent | Any (analysis mode) or task-specific (fix mode) |
| /todo | skill-todo | task-archive-agent | Any (archives completed/abandoned) |
| /refresh | skill-refresh | cleanup-agent | Any (maintenance command) |
| /learn | skill-learn | tag-scan-agent | Any (discovers work from tags) |
| /meta | skill-meta | meta-builder-agent | Any (system building) |

## Detection Pattern

**Regex**: `/^\/(research|plan|implement|revise|review|errors|todo|refresh|learn|meta)(?:\s+(\d+))?/`

**Matches**:
- `/plan 135`
- `/research OC_135`
- `/implement 135 --force`
- `/review` (no task number)
- `/todo --dry-run`

**Non-matches** (pass through to main agent):
- `plan 135` (no leading slash)
- `/plan` (no task number where required)
- `hello world` (not a command)
- `/custom` (not a workflow command)

## Execution Flow

### Stage 1: Parse Command

1. **Extract components** from input:
   - Command: research, plan, implement, etc.
   - Task number: 135, OC_135 (strip OC_ prefix)
   - Flags: --force, --dry-run, --create-tasks, etc.
   - Remaining args: focus, reason, instructions

2. **Validate format**:
   - Task number required for: research, plan, implement, revise
   - Task number optional for: errors (in fix mode), review
   - No task number for: todo, refresh, learn, meta

### Stage 2: Validate Task (if applicable)

For commands requiring task numbers:

1. **Normalize task number**:
   ```bash
   task_num=$(echo "$task_number" | sed 's/^OC_//')
   ```

2. **Check existence**:
   ```bash
   task_data=$(jq -r --arg num "$task_num" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     specs/state.json)
   ```

3. **Extract metadata**:
   - status
   - language
   - project_name

4. **Validate status allows operation**:
   - Each command has specific allowed statuses
   - Use `--force` to override (if supported)

### Stage 3: Route to Skill

**Invoke Skill tool** (NOT direct subagent call):

```
Skill(skill-{name}, {
  task_number: N,
  flags: {...},
  args: {...},
  session_id: "sess_{timestamp}_{random}"
})
```

**Critical**: Must use `Skill` tool, not `Task` tool directly. The skill handles:
- Preflight status updates
- Postflight marker creation
- Subagent delegation with `context: fork`
- Postflight status/artifact/commit handling

### Stage 4: Relay Result

Return skill result directly to user:
- Success: Plan created, research completed, etc.
- Error: Task not found, invalid status, etc.
- Partial: Implementation blocked, resume with `/implement OC_N`

## Error Handling

| Error | Router Action | User Message |
|-------|---------------|--------------|
| Invalid command format | Return usage | "Usage: /plan <OC_N> [notes]" |
| Task not found | Return error | "Task OC_N not found in state.json" |
| Invalid status | Return error/warning | Status-specific message with --force hint |
| Skill failure | Return error | "Skill execution failed: {details}" |
| Non-workflow command | Pass to main agent | (no action, normal processing) |

## Validation Rules

### Task Number Validation
- Format: `N` or `OC_N` where N is integer
- Existence: Must exist in state.json active_projects
- Extraction: Strip `OC_` prefix for state.json lookup

### Status Validation by Command

**research**: not_started, partial, researched (warning: researching, completed)
**plan**: researched, not_started, partial (warning: planning, completed)
**implement**: planned, partial, researched, not_started (error: implementing, abandoned)
**revise**: planned, researched, partial, revised, completed (error: implementing)
**review**: Any (no validation)
**errors**: Any for analysis; task-specific for fix mode
**todo**: Any (archives completed/abandoned)
**refresh**: Any (maintenance)
**learn**: Any (discovery)
**meta**: Any (system building)

## Fallback Behavior

If router fails:
1. Log routing error
2. Fall back to main agent
3. Display warning: "Command routing failed, processing with main agent"
4. Continue with main agent processing

## Integration Points

**Entry Point**: Must be inserted at prompt processing pipeline
- Before main agent receives prompt
- After raw input parsing
- With highest priority for workflow commands

**Configuration**: `.opencode/settings.json` (optional)
```json
{
  "command_router": {
    "enabled": true,
    "enforce_routing": true,
    "log_routing_decisions": true
  }
}
```

## Success Metrics

- All workflow commands route through skills
- Main agent never executes implementation steps
- Subagents always execute in forked context
- Status transitions are atomic (state + TODO + commits)
- No direct command specification execution

## Monitoring

Log routing decisions:
```
[ROUTER] /plan 135 → skill-planner (validated: task exists, status=researched)
[ROUTER] /research OC_136 → skill-researcher (validated: task exists, status=not_started)
[ROUTER] /invalid 999 → ERROR: Task not found
[ROUTER] hello world → PASS: Not a workflow command
```

---

**Created**: 2026-03-05 as part of OC_135 command routing enforcement
**Integration**: To be connected at prompt processing entry point
