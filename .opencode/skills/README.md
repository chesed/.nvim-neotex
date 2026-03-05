# Skills

Skill definitions for the OpenCode system. Skills are thin wrappers that delegate to subagents with proper context isolation.

## Skill Architecture

### Pattern: Skill → Subagent Delegation

All skills follow the delegation pattern with postflight handling:

```
Command → Skill (context: fork) → Subagent → Result → Postflight → User
```

### Postflight Pattern (Standard)

Every skill implements the 9-11 stage postflight pattern:

1. **LoadContext** - Read injected context files
2. **Preflight** - Validate inputs and prepare
3. **CreatePostflightMarker** - Create `.postflight-pending` file
4. **Delegate** - Invoke subagent via Task tool with `context: fork`
5. **ReadMetadata** - Parse `.return-meta.json` from subagent
6. **UpdateState** - Update state.json
7. **LinkArtifacts** - Add to artifacts array
8. **Commit** - Git commit with session ID
9. **Cleanup** - Remove marker files
10. **Return** - Brief text summary to user

### Postflight Marker File

Created before subagent invocation:

```bash
cat > "specs/{NNN}_{SLUG}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-{name}",
  "task_number": ${task_number},
  "reason": "Postflight pending: status update, artifact linking, git commit",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
```

**Purpose**: Prevents premature termination before postflight operations complete.

**Cleanup**: Removed after all operations complete.

### Context Isolation

All skills use `context: fork` to ensure subagents run in isolated context:

```yaml
---
name: skill-{name}
context: fork
agent: {subagent-name}
---
```

This ensures:
- Subagent cannot access main agent's context
- Clean separation of concerns
- Prevents context pollution
- Allows proper termination boundaries

## Available Skills

### Core Workflow Skills

These skills handle the main workflow commands:

- **skill-researcher** - Delegates to general-research-agent
  - Command: /research
  - Creates: research-001.md reports

- **skill-planner** - Delegates to planner-agent
  - Command: /plan
  - Creates: implementation-001.md plans

- **skill-implementer** - Delegates to general-implementation-agent
  - Command: /implement
  - Executes: Phase-by-phase implementation

- **skill-revisor** - Conditional routing (NEW in OC_135)
  - Command: /revise
  - Routes to: planner-agent (if plan exists) OR task-expander (if no plan)

### Utility Skills

- **skill-reviewer** - Delegates to code-reviewer-agent (NEW in OC_135)
  - Command: /review
  - Creates: review reports

- **skill-errors** - Delegates to error-analysis-agent (NEW in OC_135)
  - Command: /errors
  - Analyzes: error patterns

- **skill-todo** - Delegates to task-archive-agent (NEW in OC_135)
  - Command: /todo
  - Archives: completed/abandoned tasks

- **skill-refresh** - Delegates to cleanup-agent
  - Command: /refresh
  - Cleans: orphaned processes and temp data

- **skill-learn** - Delegates to tag-scan-agent
  - Command: /learn
  - Scans: FIX:/NOTE:/TODO: tags

- **skill-meta** - Delegates to meta-builder-agent
  - Command: /meta
  - Creates: system architecture tasks

### Specialized Skills

- **skill-neovim-research** - Neovim-specific research
- **skill-neovim-implementation** - Neovim configuration implementation
- **skill-git-workflow** - Git operation workflows
- **skill-status-sync** - Atomic status synchronization
- **skill-orchestrator** - Task routing and orchestration

## Skill Structure

### Required Elements

Every skill file must include:

1. **Frontmatter**:
```yaml
---
name: skill-{name}
description: Clear description of what this skill does
allowed-tools: Task, Bash, Edit, Read, Write, etc.
context: fork
agent: {subagent-name}
---
```

2. **Context Injection**:
```xml
<context_injection>
  <file path=".opencode/context/core/formats/return-metadata-file.md" variable="return_metadata" />
  <file path=".opencode/context/core/patterns/postflight-control.md" variable="postflight_control" />
</context_injection>
```

3. **Execution Stages**:
```xml
<execution>
  <stage id="1" name="LoadContext">...</stage>
  <stage id="2" name="Preflight">...</stage>
  <stage id="3" name="CreatePostflightMarker">...</stage>
  <stage id="4" name="Delegate">...</stage>
  <!-- ... remaining stages -->
</execution>
```

4. **Return Format**:
```xml
<return_format>Brief text summary; metadata file in `specs/{N}_{SLUG}/.return-meta.json`.</return_format>
```

### Subagent Return Format

Subagents must return JSON metadata to `.return-meta.json`:

```json
{
  "status": "completed",
  "summary": "Brief summary of what was done",
  "artifacts": [
    {
      "type": "research|plan|summary",
      "path": "specs/...",
      "summary": "One sentence description"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "...",
    "delegation_depth": 1,
    "delegation_path": ["..."]
  }
}
```

## Creating New Skills

### Template

See [Creating Skills Guide](../docs/guides/creating-skills.md) for detailed instructions.

Quick template:

```markdown
---
name: skill-{name}
description: What this skill does
allowed-tools: Task, Bash, Edit, Read, Write
context: fork
agent: {subagent-name}
---

# {Name} Skill

<context>
  <system_context>...</system_context>
  <task_context>...</task_context>
</context>

<context_injection>
  <file path="..." variable="..." />
</context_injection>

<role>...</role>

<task>...</task>

<execution>
  <stage id="1" name="LoadContext">...</stage>
  <stage id="2" name="Preflight">...</stage>
  <stage id="3" name="CreatePostflightMarker">...</stage>
  <stage id="4" name="Delegate">...</stage>
  <stage id="5" name="ReadMetadata">...</stage>
  <stage id="6" name="UpdateState">...</stage>
  <stage id="7" name="LinkArtifacts">...</stage>
  <stage id="8" name="Commit">...</stage>
  <stage id="9" name="Cleanup">...</stage>
  <stage id="10" name="Return">...</stage>
</execution>
```

## Postflight Best Practices

1. **Always create marker file** before subagent invocation
2. **Always use context: fork** for subagent isolation
3. **Always read metadata** after subagent returns
4. **Always update state** atomically (state.json + TODO.md)
5. **Always commit changes** before returning
6. **Always cleanup markers** after operations complete
7. **Always return brief summary** (NOT JSON) to user

## Error Handling

Skills handle these error cases:

- **Input validation errors** → Return immediately with guidance
- **Subagent timeout** → Keep status as in-progress for resume
- **Metadata file missing** → Log error, do not cleanup marker
- **Git commit failure** → Log warning, continue with success response
- **jq parse errors** → Use two-step patterns (see jq-escaping-workarounds.md)

## References

- [Command Routing Guide](../docs/guides/command-routing.md)
- [Creating Skills Guide](../docs/guides/creating-skills.md)
- [OC_135 Implementation](../specs/OC_135_enforce_workflow_command_delegation_to_prevent_direct_implementation/) - Postflight pattern implementation

---

## Navigation

- [← Parent Directory](../README.md)
- [Commands](../commands/README.md) - Commands that route to these skills
- [Agent Subagents](../agent/subagents/README.md) - Subagents delegated to by skills
