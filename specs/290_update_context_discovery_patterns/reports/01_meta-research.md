# Research Report: Task #290

**Task**: 290 - Update context discovery patterns (index.json queries)
**Generated**: 2026-03-25
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Update jq queries and discovery patterns for new context architecture
**Scope**: Modify context discovery to query multiple indices
**Affected Components**: Context discovery patterns, agent context loading
**Domain**: meta
**Language**: meta

## Task Requirements

With context split across `.context/`, `.claude/context/`, and extension directories, discovery patterns must query all relevant sources.

### Current Pattern

Single index query:
```bash
jq -r '.entries[] | select(.load_when.agents[]? == "planner-agent") | .path' \
  .claude/context/index.json
```

### New Pattern

Multi-source query with path resolution:
```bash
# Core agent context (paths relative to .claude/context/)
jq -r '.entries[] | select(.load_when.agents[]? == "planner-agent") |
  ".claude/context/" + .path' .claude/context/index.json

# Project context (paths relative to .context/)
jq -r '.entries[] | select(.load_when.always == true) |
  ".context/" + .path' .context/index.json

# Extension context (paths already include extension/ prefix after merge)
jq -r '.entries[] | select(.domain == "extension") |
  ".claude/" + .path' .claude/context/index.json
```

### Files to Update

1. **Context discovery pattern documentation**:
   - `.claude/context/core/patterns/context-discovery.md` -> `.claude/context/patterns/context-discovery.md`
   - Add multi-index query examples

2. **Agent instructions**:
   - Update context loading instructions in agent definitions
   - Add `.context/` to search paths

3. **CLAUDE.md Context Discovery section**:
   - Document new query patterns
   - Show how to query each context source

### Query Helper Function

Consider adding a helper script:
```bash
#!/bin/bash
# .claude/scripts/query-context.sh
# Usage: query-context.sh --agent planner-agent
# Returns: full paths to all relevant context files

query_by_agent() {
  local agent=$1

  # Core context
  jq -r --arg a "$agent" '.entries[] | select(.load_when.agents[]? == $a) |
    ".claude/context/" + .path' .claude/context/index.json

  # Extension context (merged into main index with extension/ prefix)
  jq -r --arg a "$agent" '.entries[] | select(.domain == "extension" and
    (.load_when.agents[]? == $a)) | ".claude/" + .path' .claude/context/index.json

  # Project context (always loaded)
  jq -r '.entries[] | select(.load_when.always == true) |
    ".context/" + .path' .context/index.json 2>/dev/null
}
```

## Integration Points

- **Component Type**: documentation, scripts
- **Affected Area**: Context discovery system
- **Action Type**: update
- **Related Files**:
  - `.claude/context/patterns/context-discovery.md`
  - `.claude/CLAUDE.md` (Context Discovery section)
  - Agent definition files

## Dependencies

- Task #288: Flatten .claude/context/ structure
- Task #289: Update extension loader

## Interview Context

### User-Provided Information
The two-index approach is preferred for clarity, but extension context is merged into the main index with prefixed paths for simpler runtime queries.

### Effort Assessment
- **Estimated Effort**: 2 hours
- **Complexity Notes**: Mostly documentation and pattern updates. Need to verify jq queries work correctly with new structure.

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 290 [focus]` with a specific focus prompt.*
