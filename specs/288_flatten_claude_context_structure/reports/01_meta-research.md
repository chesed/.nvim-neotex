# Research Report: Task #288

**Task**: 288 - Update .claude/context/ to contain only core/ files (flatten structure)
**Generated**: 2026-03-25
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Simplify .claude/context/ to contain only core agent system files
**Scope**: Flatten structure by removing project/ subdirectory, keeping only core/
**Affected Components**: .claude/context/ directory structure, index.json
**Domain**: meta
**Language**: meta

## Task Requirements

After project files are migrated to `.context/`, restructure `.claude/context/` to contain only core agent system patterns. The `core/` subdirectory becomes the root.

### Current Structure

```
.claude/context/
├── core/                   # Agent system patterns
│   ├── orchestration/
│   ├── formats/
│   ├── standards/
│   ├── workflows/
│   ├── templates/
│   ├── schemas/
│   ├── checkpoints/
│   ├── patterns/
│   ├── guides/
│   ├── reference/
│   ├── architecture/
│   └── troubleshooting/
├── project/                # To be removed (migrated to .context/)
│   ├── meta/              # KEEP - move to core level
│   └── [others migrated]
├── index.json
├── index.schema.json
└── README.md
```

### Target Structure

```
.claude/context/
├── orchestration/          # Flattened from core/
├── formats/
├── standards/
├── workflows/
├── templates/
├── schemas/
├── checkpoints/
├── patterns/
├── guides/
├── reference/
├── architecture/
├── troubleshooting/
├── meta/                   # Moved from project/meta/ (agent system context)
├── index.json              # Updated paths
├── index.schema.json
└── README.md
```

### Update Requirements

1. Move contents of `core/` to `.claude/context/` root
2. Move `project/meta/` to `.claude/context/meta/` (agent system patterns)
3. Remove empty `core/` and `project/` directories
4. Update all paths in `index.json` (remove `core/` prefix)
5. Update all @-references in agents, skills, commands
6. Update README.md to reflect new structure

### Path Changes

| Old Path | New Path |
|----------|----------|
| `core/orchestration/` | `orchestration/` |
| `core/formats/` | `formats/` |
| `project/meta/` | `meta/` |
| etc. | etc. |

## Integration Points

- **Component Type**: directory restructure
- **Affected Area**: .claude/context/
- **Action Type**: refactor
- **Related Files**:
  - All files in .claude/context/
  - .claude/context/index.json
  - All agents, skills, commands with @-references

## Dependencies

- Task #287: Migrate project context files (must complete first to avoid moving files that should go to .context/)

## Interview Context

### User-Provided Information
The flattening removes the now-unnecessary `core/` subdirectory since all remaining content is core agent system context. The `project/meta/` content stays because it's agent system patterns (meta-builder context), not project-specific information.

### Effort Assessment
- **Estimated Effort**: 2 hours
- **Complexity Notes**: Many file moves and path updates. Need to verify all @-references still work after restructure.

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 288 [focus]` with a specific focus prompt.*
