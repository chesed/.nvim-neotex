# Research Report: Task #289

**Task**: 289 - Clarify context architecture: extension loader copies core + extension context to .claude/context/; project-level .context/ managed via index.json
**Generated**: 2026-03-25
**Updated**: 2026-03-25
**Source**: /meta interview (auto-generated), revised per user direction
**Status**: Pre-populated from interview context, revised

---

## Context Summary

**Purpose**: Clarify the separation of concerns between agent context (managed by extension loader) and project context (managed by index.json)
**Scope**: Extension loader behavior, .context/ directory, .memory/ integration
**Affected Components**: Extension loader Lua code, .context/index.json, agent context discovery
**Domain**: meta
**Language**: meta

## Task Requirements

The context system has two distinct halves with different management strategies:

### 1. Agent Context (.claude/context/) — Managed by Extension Loader

The extension loader **copies and merges** context files into `.claude/context/`. This includes:

- **Core context files**: Agent system patterns, templates, reference docs (from `.claude/context/core/`)
- **Extension context files**: Language-specific context from each loaded extension (from `.claude/extensions/*/context/`)

The extension loader's job is to assemble a complete `.claude/context/` directory that contains everything the agent system needs. Extensions contribute their context files by copying them into this directory during loading.

### 2. Project Context (.context/) — Managed by index.json

Project-specific context lives in a top-level `.context/` directory, **outside** `.claude/`. This includes:

- Project conventions the user wants to follow
- Domain-specific knowledge and standards
- Any project-level information that isn't part of the agent system itself

A `.context/index.json` file manages these entries. The core agent system references this index to discover and load project-specific context as needed.

### 3. Project Memory (.memory/) — Complementary to .context/

The `.memory/` directory stores persistent information about the project that agents have learned over time. The `.context/index.json` can reference `.memory/` files, creating a unified discovery mechanism for both static project context and dynamic project memory.

### Key Distinction

| Aspect | Agent Context | Project Context |
|--------|--------------|-----------------|
| Location | `.claude/context/` | `.context/` |
| Managed by | Extension loader | `index.json` |
| Contains | Core + extension agent files | Project conventions, domain knowledge |
| Lifecycle | Rebuilt on extension load | Persistent, user-managed |
| Memory integration | None | Keys into `.memory/` files |

### Changes Required

1. **Extension loader** (keeps current copy/merge behavior):
   - Continues copying core context to `.claude/context/`
   - Continues copying extension context to `.claude/context/` on load
   - No change to current behavior — this is the correct approach

2. **Project .context/ directory**:
   - Create `.context/` at project root (outside `.claude/`)
   - Create `.context/index.json` schema for project context discovery
   - Migrate project-specific files from `.claude/context/project/` to `.context/`

3. **index.json schema**:
   - Entries for project context files in `.context/`
   - Entries that reference `.memory/` files for dynamic project knowledge
   - Query patterns for agents to discover project-specific context

4. **Agent context discovery**:
   - Core + extension context: read from `.claude/context/` (as today)
   - Project context: query `.context/index.json`
   - Project memory: follow references from index.json to `.memory/`

## Integration Points

- **Component Type**: Directory structure, JSON schema, Lua code
- **Affected Area**: Context discovery, extension loading, project configuration
- **Action Type**: clarify and restructure
- **Related Files**:
  - Extension loader (Lua code — no changes needed)
  - `.context/index.json` (new)
  - `.context/` directory (new, receives migrated project files)
  - `.memory/` directory (referenced by index.json)
  - `.claude/context/index.json` (existing, for agent context)

## Dependencies

- Task #288: Flatten .claude/context/ structure (context structure must be stable first)

## Interview Context

### User-Provided Information
The key insight is that context has two audiences: the agent system (core + extensions, managed by the loader) and the project (conventions, domain knowledge, managed by index.json). The extension loader should continue copying/merging — the change is clarifying that project context lives separately in .context/ with its own index.json, and that this index can reference .memory/ for project-specific learned information.

### Effort Assessment
- **Estimated Effort**: 3 hours
- **Complexity Notes**: Primarily a structural clarification. Extension loader behavior stays the same. Main work is designing the .context/index.json schema and migration of project files.

---

*This research report was auto-generated during task creation via /meta command.*
*Revised 2026-03-25 to reflect clarified context architecture.*
*For deeper investigation, run `/research 289 [focus]` with a specific focus prompt.*
