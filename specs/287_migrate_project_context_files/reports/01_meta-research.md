# Research Report: Task #287

**Task**: 287 - Migrate project context files from .claude/context/project/ to .context/
**Generated**: 2026-03-25
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Move project-specific context files to protected .context/ directory
**Scope**: Migrate files from .claude/context/project/ to .context/
**Affected Components**: Context file locations, index entries
**Domain**: meta
**Language**: meta

## Task Requirements

Migrate project-specific context files from `.claude/context/project/` to the new `.context/` directory. This ensures these files survive `.claude/` reloads.

### Files to Migrate

Current `.claude/context/project/` structure:
```
project/
├── meta/                       # Meta-builder context (KEEP in .claude/)
│   ├── domain-patterns.md
│   ├── architecture-principles.md
│   ├── meta-guide.md
│   ├── interview-patterns.md
│   ├── standards-checklist.md
│   └── context-revision-guide.md
├── repo/                       # MIGRATE to .context/
│   ├── project-overview.md
│   ├── update-project.md
│   └── self-healing-implementation-details.md
├── processes/                  # MIGRATE to .context/
│   ├── implementation-workflow.md
│   ├── research-workflow.md
│   └── planning-workflow.md
└── hooks/                      # MIGRATE to .context/
    └── wezterm-integration.md
```

### Migration Decision Matrix

| Directory | Migrate? | Reason |
|-----------|----------|--------|
| `meta/` | No | Agent system patterns, not project-specific |
| `repo/` | Yes | Project-specific repository information |
| `processes/` | Yes | Project-specific workflows |
| `hooks/` | Yes | Project-specific hook documentation |

### Migration Steps

1. Copy files from `.claude/context/project/{repo,processes,hooks}/` to `.context/`
2. Update `.context/index.json` with migrated file entries
3. Remove migrated entries from `.claude/context/index.json`
4. Verify no broken references in agents/skills

## Integration Points

- **Component Type**: file migration
- **Affected Area**: .claude/context/project/, .context/
- **Action Type**: migrate
- **Related Files**:
  - `.claude/context/index.json` (remove entries)
  - `.context/index.json` (add entries)
  - All migrated files

## Dependencies

- Task #286: Create .context/ directory structure and index.json schema

## Interview Context

### User-Provided Information
The migration separates project-specific context (repo info, workflows, hooks) from agent system context (meta patterns, orchestration). Meta-related context stays in `.claude/` as it's part of the agent system.

### Effort Assessment
- **Estimated Effort**: 3 hours
- **Complexity Notes**: Careful attention needed to update all index references and verify no broken links.

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 287 [focus]` with a specific focus prompt.*
