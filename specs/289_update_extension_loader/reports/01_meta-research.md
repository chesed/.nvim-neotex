# Research Report: Task #289

**Task**: 289 - Modify extension loader to keep context in extension directories
**Generated**: 2026-03-25
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Change extension loading to reference context in-place instead of copying
**Scope**: Modify Neovim extension loader and extension manifest format
**Affected Components**: Extension loader Lua code, manifest.json format, index-entries.json
**Domain**: meta
**Language**: meta

## Task Requirements

Currently, extensions copy their context files to `.claude/context/project/`. This creates merge conflicts and gets overwritten on `.claude/` reloads. The new approach keeps context in extension directories and uses path prefixes in the merged index.

### Current Behavior

```lua
-- Extension loading copies files:
-- .claude/extensions/nvim/context/project/neovim/ -> .claude/context/project/neovim/
```

### New Behavior

```lua
-- Extension loading only merges index entries with prefixed paths:
-- Entry path: "project/neovim/README.md"
-- Becomes: "extension/nvim/context/project/neovim/README.md"
```

### Changes Required

1. **Extension loader** (`~/.config/nvim/lua/claude/extensions.lua` or similar):
   - Remove context directory copying logic
   - Update index merging to prefix paths with `extension/{name}/context/`
   - Update verification to check files exist in extension directories

2. **Extension manifest.json**:
   - Change `provides.context` to be informational only (no copying)
   - Document new path resolution in README

3. **Extension index-entries.json**:
   - Entries can stay as-is (paths are prefixed during merge)
   - Alternative: entries use `extension/{name}/` prefix directly

4. **Agent context loading**:
   - Update path resolution to handle `extension/` prefix
   - Query pattern: check both `.claude/context/` and `.claude/extensions/*/context/`

### Path Resolution Strategy

Option A: Prefix during merge (recommended)
```json
// In merged index.json
{
  "path": "extension/nvim/context/project/neovim/README.md",
  "domain": "extension",
  "extension_name": "nvim"
}
```

Option B: Two-index query
```bash
# Query core index
jq ... .claude/context/index.json
# Query extension indices
for ext in .claude/extensions/*/; do
  jq ... "$ext/index-entries.json"
done
```

Recommendation: Option A for simplicity - single merged index with extension paths.

## Integration Points

- **Component Type**: Lua code, JSON schema
- **Affected Area**: Extension loading system
- **Action Type**: modify
- **Related Files**:
  - `~/.config/nvim/lua/claude/extensions.lua` (or picker implementation)
  - `.claude/extensions/*/manifest.json`
  - `.claude/extensions/*/index-entries.json`
  - `.claude/context/index.json`

## Dependencies

- Task #288: Flatten .claude/context/ structure (context structure must be stable first)

## Interview Context

### User-Provided Information
The key insight is that extension context should stay in extension directories, only index entries are merged. This prevents overwrites and simplifies the extension loading process.

### Effort Assessment
- **Estimated Effort**: 3 hours
- **Complexity Notes**: Requires Lua code changes to extension loader. Need to test with all 14 extensions to ensure compatibility.

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 289 [focus]` with a specific focus prompt.*
