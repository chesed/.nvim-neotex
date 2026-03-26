# Research Report: Task #292

**Task**: 292 - Document role boundaries for .context/, .memory/, Claude auto-memory
**Generated**: 2026-03-25
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Create clear documentation defining the purpose and boundaries of each context/memory system
**Scope**: Documentation for .context/, .memory/, and Claude Code auto-memory
**Affected Components**: Documentation files, CLAUDE.md
**Domain**: meta
**Language**: meta

## Task Requirements

Create comprehensive documentation that clearly defines when to use each system and what belongs in each.

### Role Definitions

| System | Location | Purpose | What Belongs Here |
|--------|----------|---------|-------------------|
| `.context/` | Project root | Project-specific reference docs | Repo overview, workflows, standards specific to THIS project |
| `.memory/` | Project root | Domain facts from work | Learned patterns, discoveries, decisions made during development |
| `.claude/context/` | .claude/ | Core agent system | Orchestration, formats, standards, patterns for the agent system |
| Claude auto-memory | ~/.claude/projects/ | Small gaps | User preferences, session corrections, behavioral adjustments |

### Documentation to Create

1. **`.context/README.md`** (new):
   ```markdown
   # Project Context

   Protected project-specific context that survives .claude/ reloads.

   ## What Belongs Here
   - Repository overview and structure
   - Project-specific workflows
   - Integration documentation (hooks, tools)
   - Standards specific to this project

   ## What Does NOT Belong Here
   - Agent system patterns (use .claude/context/)
   - Learned facts from work (use .memory/)
   - User preferences (use Claude auto-memory)
   ```

2. **`.memory/README.md`** (update existing):
   - Add role boundary section
   - Clarify: domain facts, not reference docs

3. **`.claude/context/README.md`** (update):
   - Add role boundary section
   - Clarify: agent system patterns only

4. **`.claude/CLAUDE.md`** (update):
   - Add "Context Architecture" section explaining the three systems

### Decision Tree for New Content

```
Is this reference documentation for the project?
  -> Yes: .context/
  -> No: Continue

Is this a fact learned during work (pattern, discovery, decision)?
  -> Yes: .memory/
  -> No: Continue

Is this an agent system pattern (orchestration, format, standard)?
  -> Yes: .claude/context/
  -> No: Continue

Is this a user preference or behavioral correction?
  -> Yes: Claude auto-memory (automatic)
  -> No: Probably doesn't need to be stored
```

## Integration Points

- **Component Type**: documentation
- **Affected Area**: README files, CLAUDE.md
- **Action Type**: create/update
- **Related Files**:
  - `.context/README.md` (new)
  - `.memory/README.md`
  - `.claude/context/README.md`
  - `.claude/CLAUDE.md`

## Dependencies

- Task #291: Update CLAUDE.md references (CLAUDE.md must be updated first)

## Interview Context

### User-Provided Information
The key insight is clear separation of concerns:
- `.context/` = stable project reference docs
- `.memory/` = dynamic facts learned during work
- `.claude/context/` = reloadable agent system patterns
- Claude auto-memory = automatic gap-filling

### Effort Assessment
- **Estimated Effort**: 1 hour
- **Complexity Notes**: Straightforward documentation task. Main work is writing clear, helpful content.

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 292 [focus]` with a specific focus prompt.*
