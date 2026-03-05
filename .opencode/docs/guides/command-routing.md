# Command Routing Guide

**Purpose**: Understand and troubleshoot the command routing system implemented in OC_135.

## Overview

The OpenCode system uses a **routing architecture** where:
- **Commands** are pure routing specifications (not implementation guides)
- **Skills** are thin wrappers that delegate to subagents
- **Subagents** perform the actual implementation work
- **Context: fork** ensures isolation between layers

This prevents the main agent from executing workflow commands directly.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Input                               │
└────────────────────────┬────────────────────────────────────────┘
                         │
              ┌──────────┴──────────┐
              │  Command Router     │ ← OC_135 Addition
              │  (Interception)     │
              └──────────┬──────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   Non-workflow     Workflow          Invalid
   commands         commands          commands
        │                │                │
        ▼                ▼                ▼
   Pass through    Route to skill    Return error
                         │
              ┌──────────┴──────────┐
              │      Skill            │
              │  (context: fork)      │
              │                     │
              │  ┌───────────────┐   │
              │  │  Preflight    │   │
              │  │  - Validate   │   │
              │  │  - Update status│  │
              │  └───────┬───────┘   │
              │          │            │
              │  ┌───────┴───────┐   │
              │  │  Delegate     │   │
              │  │  → Subagent   │   │
              │  └───────┬───────┘   │
              │          │            │
              │  ┌───────┴───────┐   │
              │  │  Postflight   │   │
              │  │  - Link artifacts││
              │  │  - Commit     │   │
              │  └───────────────┘   │
              └──────────┬──────────┘
                         │
                         ▼
                     User Result
```

## Command-to-Skill Mapping

| Command | Skill | Subagent | Purpose |
|---------|-------|----------|---------|
| `/research` | skill-researcher | general-research-agent | Research tasks |
| `/plan` | skill-planner | planner-agent | Create plans |
| `/implement` | skill-implementer | general-implementation-agent | Execute plans |
| `/revise` | skill-revisor | planner-agent OR task-expander | Revise plans |
| `/review` | skill-reviewer | code-reviewer-agent | Code analysis |
| `/errors` | skill-errors | error-analysis-agent | Error analysis |
| `/todo` | skill-todo | task-archive-agent | Archive tasks |
| `/refresh` | skill-refresh | cleanup-agent | Cleanup |
| `/learn` | skill-learn | tag-scan-agent | Tag scanning |

## Command Structure

### Correct (Post-OC_135)

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

**Execution Rule**:

**CRITICAL**: This command MUST be handled by skill delegation.

**DO NOT**:
- Execute any workflow steps
- Modify files directly
- Update state.json yourself

**DO**:
- Extract task number and args
- Invoke Skill(skill-{name}, args)
- Return skill result to user
```

### Incorrect (Pre-OC_135)

```markdown
## Steps

### 1. Look up task
Strip OC_ prefix, find task in state.json...

### 2. Validate status
Check if status allows operation...

### 3. Update status
Edit state.json to set status...

### 4. Execute work
[Detailed implementation steps]
```

**Problem**: Main agent sees steps and executes them directly instead of delegating.

## Validation Flow

### Task Number Validation

1. **Format Check**: Accepts `135` or `OC_135`
2. **Normalization**: Strip `OC_` prefix → `135`
3. **Existence Check**: Query state.json for project_number
4. **Status Check**: Verify status allows operation

### Status Requirements

| Command | Allowed Statuses | Error if... |
|---------|-----------------|-------------|
| research | not_started, partial, researched | Task not found |
| plan | researched, not_started, partial | Wrong status |
| implement | planned, partial, researched | No plan exists |
| revise | planned, researched, partial, revised | Implementation in progress |

## Troubleshooting

### Issue: Command Not Routing to Skill

**Symptoms**: Main agent executes command steps directly

**Causes**:
1. Command still has implementation steps (not routing spec)
2. Router not integrated at entry point
3. Skill not found or invalid

**Solutions**:
1. Check command file follows routing spec format
2. Verify skill file exists and is valid
3. Check `.opencode/agent/command-router.md` is properly configured

### Issue: Skill Not Delegating to Subagent

**Symptoms**: Skill executes work instead of delegating

**Causes**:
1. Missing `context: fork` in skill frontmatter
2. Not using Task tool for delegation
3. Subagent file missing

**Solutions**:
1. Add `context: fork` to skill frontmatter
2. Verify skill uses Task tool with subagent_type
3. Check subagent file exists at correct path

### Issue: Postflight Not Completing

**Symptoms**: Status updates missing, no commits

**Causes**:
1. Postflight marker not created
2. Metadata file missing or invalid
3. jq parse errors

**Solutions**:
1. Check skill creates `.postflight-pending` before subagent
2. Verify subagent writes `.return-meta.json`
3. Use two-step jq patterns to avoid escaping issues

### Issue: Premature Termination

**Symptoms**: Work starts but never completes, no status updates

**Causes**:
1. Postflight marker not preventing termination
2. Stop hook active
3. Context timeout

**Solutions**:
1. Verify marker file created before subagent invocation
2. Check stop_hook_active is false in marker
3. Increase timeout if needed

## Testing Commands

### Valid Routing Test

```bash
# Test research command
/research 135
# Expected: Routes to skill-researcher → general-research-agent
# Expected: Status changes: [RESEARCHING] → [RESEARCHED]

# Test plan command  
/plan 135
# Expected: Routes to skill-planner → planner-agent
# Expected: Status changes: [PLANNING] → [PLANNED]
```

### Error Handling Test

```bash
# Test invalid task
/research 99999
# Expected: Error "Task OC_99999 not found in state.json"

# Test wrong status
/implement 135
# Expected: Warning "Task 135 status is researching, not planned"
```

### Pass-Through Test

```bash
# Non-workflow command
hello world
# Expected: Passes to main agent, normal processing
```

## Best Practices

### For Command Authors

1. **Never include implementation steps** in commands
2. **Always specify Skill tool invocation**
3. **Include "DO NOT implement" warnings**
4. **Document routing target clearly**
5. **Specify validation rules** for skill to check

### For Skill Authors

1. **Always use context: fork**
2. **Always create postflight marker** before subagent
3. **Always read metadata** after subagent returns
4. **Always update state atomically** (state.json + TODO.md)
5. **Always commit before returning**
6. **Always cleanup markers** after operations
7. **Always return brief text summary** (NOT JSON)

### For System Maintainers

1. **Monitor routing decisions** via logs
2. **Check for direct execution** in session logs
3. **Verify skill isolation** with context: fork
4. **Test all workflow commands** after changes
5. **Document any new commands** as routing specs

## Migration Guide

### Converting Old Commands

1. **Remove all implementation steps**
2. **Add routing section** with Target/Subagent/Context
3. **Add execution rule** with DO NOT/DO sections
4. **Specify skill arguments**
5. **Document expected skill behavior**
6. **Test thoroughly** before deployment

### Updating Old Skills

1. **Add context: fork** to frontmatter if missing
2. **Add context_injection** block
3. **Implement postflight stages** (9-11 stages)
4. **Add postflight marker creation**
5. **Add metadata file handling**
6. **Test with subagent**

## References

- [OC_135 Task](../../specs/OC_135_enforce_workflow_command_delegation_to_prevent_direct_implementation/) - Implementation details
- [Commands README](../commands/README.md) - Command specifications
- [Skills README](../skills/README.md) - Skill specifications
- [Postflight Control Patterns](../context/core/patterns/postflight-control.md) - Marker file protocol

---

**Version**: 1.0 (OC_135 Implementation)  
**Last Updated**: 2026-03-05  
**Maintainer**: OpenCode System Team
