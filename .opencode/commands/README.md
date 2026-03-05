# Commands

Slash command definitions for the OpenCode system.

## Command Architecture (Post-OC_135)

All workflow commands are **routing specifications** that delegate to skills. They do NOT contain implementation steps.

### Routing Pattern

```
User Input → Command Router → Skill (context: fork) → Subagent → Result
```

**Key Principle**: Commands are pure routing signals. They validate inputs and invoke the Skill tool, but never execute implementation steps themselves.

### Command Structure

All commands follow this structure:

```markdown
---
description: Brief purpose
---

Route to skill-{name} for {operation}.

**Command Pattern**: /{command} <OC_N> [args]

**Routing**:
- Target: skill-{name}
- Subagent: {agent-name}
- Context: fork

**Validation**:
- Task exists in state.json
- Status allows {operation}

**Skill Arguments**:
- task_number: {N}
- [other args]

**Execution Rule**:

**CRITICAL**: This command MUST be handled by skill delegation.

**DO NOT**:
- Parse arguments yourself
- Validate status yourself
- Update state.json yourself
- Execute any workflow steps

**DO**:
- Extract task number and args from input
- Invoke Skill(skill-{name}, args)
- Return skill result to user
```

## Available Commands

### Workflow Commands (Require Task Number)

These commands operate on tasks and require a task number:

- **`/research <OC_N> [focus]`** → Routes to skill-researcher → general-research-agent
  - Creates research reports
  - Status: [RESEARCHING] → [RESEARCHED]

- **`/plan <OC_N> [notes]`** → Routes to skill-planner → planner-agent
  - Creates implementation plans
  - Status: [PLANNING] → [PLANNED]

- **`/implement <OC_N> [--force] [instructions]`** → Routes to skill-implementer → general-implementation-agent
  - Executes implementation plans phase by phase
  - Status: [IMPLEMENTING] → [COMPLETED]/[PARTIAL]

- **`/revise <OC_N> [REASON]`** → Routes to skill-revisor (conditional routing)
  - If plan exists: → planner-agent (creates new plan version)
  - If no plan: → task-expander (updates description)
  - Status: [REVISING] → [REVISED]

### Utility Commands (May Not Require Task Number)

- **`/review [scope] [--create-tasks]`** → Routes to skill-reviewer → code-reviewer-agent
  - Analyzes codebase and creates review reports
  - Scope: file, directory, or "all"

- **`/errors [--fix <OC_N>]`** → Routes to skill-errors → error-analysis-agent
  - Analyzes error patterns or fixes specific task errors
  - Analysis mode (no args) or fix mode (--fix)

- **`/todo [--dry-run]`** → Routes to skill-todo → task-archive-agent
  - Archives completed and abandoned tasks

- **`/refresh [--dry-run] [--force]`** → Routes to skill-refresh → cleanup-agent
  - Cleans up orphaned processes and temporary data

- **`/learn [PATH...]`** → Routes to skill-learn → tag-scan-agent
  - Scans for FIX:/NOTE:/TODO: tags and creates tasks

### Other Commands

- **`/convert`** - Convert documents between formats
- **`/lake`** - Build Lean 4 project with automatic error repair
- **`/lean`** - Manage Lean toolchain and Mathlib versions
- **`/meta`** - Interactive system builder for architecture changes
- **`/task`** - Create, recover, divide, sync, or abandon tasks

## Command Routing Enforcement

**Implemented**: OC_135 - Command Routing Enforcement

All workflow commands are now **routing specifications only**. They:

1. Extract task number and arguments from input
2. Invoke the appropriate skill via Skill tool
3. Return skill result to user

They do NOT:
- Execute bash commands
- Modify files directly
- Update state.json or TODO.md
- Call subagents directly (skills handle this)

## Validation Rules

### Task Number Format
- Accepts: `135` or `OC_135`
- Normalized: OC_ prefix stripped for state.json lookup

### Status Requirements by Command

| Command | Allowed Statuses |
|---------|-----------------|
| /research | not_started, partial, researched |
| /plan | researched, not_started, partial |
| /implement | planned, partial, researched, not_started |
| /revise | planned, researched, partial, revised, completed |

### Error Messages

- Task not found: "Task OC_N not found in state.json"
- Invalid status: Status-specific message with --force hint (if applicable)
- Missing plan: "No plan found. Run `/plan OC_N` first."

## Migration from Old Commands

**Old Pattern** (pre-OC_135):
Commands contained detailed step-by-step instructions that the main agent executed directly.

**New Pattern** (post-OC_135):
Commands are routing specifications that delegate to skills with `context: fork`.

**Why**: Prevents direct execution by main agent, ensures proper delegation boundaries, aligns with industry best practices ("orchestrator must never execute").

---

## Navigation

- [← Parent Directory](../README.md)
- [Agent Subagents](../agent/subagents/README.md) - Subagents that handle implementation
- [Skills](../skills/README.md) - Skills that wrap subagents

**Documentation**:  
- [Command Routing Guide](../docs/guides/command-routing.md) - Detailed routing documentation
- [OC_135 Implementation](../specs/OC_135_enforce_workflow_command_delegation_to_prevent_direct_implementation/) - Task that implemented routing enforcement
