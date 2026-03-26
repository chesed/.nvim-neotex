# Research Report: Task #286

**Task**: 286 - Create .context/ directory structure and index.json schema
**Generated**: 2026-03-25
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Establish protected project context directory separate from .claude/ agent system
**Scope**: Create new .context/ directory at project root with index.json schema
**Affected Components**: New directory structure, index schema design
**Domain**: meta
**Language**: meta

## Task Requirements

Create the `.context/` directory structure that will hold project-specific context files protected from `.claude/` reloads. This includes:

1. Directory structure mirroring relevant parts of current `.claude/context/project/`
2. `index.json` schema compatible with existing context discovery patterns
3. README.md documenting the directory's purpose and usage

### Directory Structure to Create

```
.context/
├── index.json              # Discovery index for project context
├── README.md               # Documentation
├── repo/                   # Repository-specific information
├── processes/              # Project workflows
└── hooks/                  # Project-specific hooks context
```

### index.json Schema Design

```json
{
  "version": "1.0",
  "generated": "ISO8601",
  "scope": "project",
  "entries": [
    {
      "path": "repo/project-overview.md",
      "topics": ["project-structure", "technology-stack"],
      "keywords": ["neovim", "lua", "lazy.nvim"],
      "summary": "Repository overview and structure",
      "line_count": 145,
      "load_when": {
        "always": true
      }
    }
  ]
}
```

Key differences from `.claude/context/index.json`:
- `scope: "project"` field to distinguish from core context
- Simpler structure (no domain/subdomain fields needed)
- Paths are relative to `.context/` directory

## Integration Points

- **Component Type**: directory structure, JSON schema
- **Affected Area**: project root, .context/
- **Action Type**: create
- **Related Files**:
  - `.claude/context/index.json` (reference schema)
  - `.claude/context/index.schema.json` (JSON schema definition)

## Dependencies

None - this task is foundational.

## Interview Context

### User-Provided Information
User wants to separate project context from agent system context to prevent overwrites when reloading `.claude/` directory. The `.context/` directory should be protected and permanent.

### Effort Assessment
- **Estimated Effort**: 2 hours
- **Complexity Notes**: Straightforward directory creation and schema design. Main work is ensuring compatibility with existing discovery patterns.

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 286 [focus]` with a specific focus prompt.*
