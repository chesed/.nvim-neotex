# Implementation Summary: Task #183

**Completed**: 2026-03-11
**Duration**: ~45 minutes

## Changes Made

Implemented opencode.json management in the extension system, allowing extensions to add/remove agent definitions during load/unload. The core agent system now installs a base opencode.json template with core agent definitions, and extensions contribute their agent definitions via a new `opencode_json` merge target.

## Files Modified

### Core Lua Modules
- `lua/neotex/plugins/ai/shared/extensions/merge.lua` - Added `merge_opencode_agents()` and `unmerge_opencode_agents()` functions for tracked-key merge/unmerge of agent definitions
- `lua/neotex/plugins/ai/shared/extensions/init.lua` - Added `opencode_json` processing to `process_merge_targets()` and `reverse_merge_targets()` functions
- `lua/neotex/plugins/ai/opencode/core/init.lua` - Created new file with `install_base_opencode_json()` function for template installation with backup strategy

### Templates
- `.opencode/templates/opencode.json` - Created base template with `_managed_by` marker and core agent definitions (build, plan, task-planner, general-research, general-implementation, meta-builder, code-reviewer)

### Extension Agent Definitions (11 new files)
- `.claude/extensions/epidemiology/opencode-agents.json`
- `.claude/extensions/filetypes/opencode-agents.json`
- `.claude/extensions/formal/opencode-agents.json`
- `.claude/extensions/latex/opencode-agents.json`
- `.claude/extensions/lean/opencode-agents.json`
- `.claude/extensions/nix/opencode-agents.json`
- `.claude/extensions/nvim/opencode-agents.json`
- `.claude/extensions/python/opencode-agents.json`
- `.claude/extensions/typst/opencode-agents.json`
- `.claude/extensions/web/opencode-agents.json`
- `.claude/extensions/z3/opencode-agents.json`

### Extension Manifests (11 updated files)
- All extension `manifest.json` files updated to include `opencode_json` merge target pointing to their respective `opencode-agents.json`

## Verification

- Merge module loads without errors: Passed
- OpenCode extensions module loads without errors: Passed
- OpenCode core module loads without errors: Passed
- `install_base_opencode_json` installs template: Passed
- `_managed_by` marker present in installed template: Passed
- `merge_opencode_agents` adds agent keys: Passed
- `unmerge_opencode_agents` removes tracked keys: Passed
- Backup strategy creates .user-backup for unmanaged files: Passed
- All JSON files valid: Passed

## Architecture

### Merge Strategy
- Uses tracked-key merge/unmerge pattern (similar to settings merge)
- Agent keys are added only if they don't exist (no overwrite)
- Unmerge removes only the keys that were previously added
- Supports both `{agent: {...}}` object format and bare object format in source files

### Template Installation
- Checks for `_managed_by: "neotex-extensions"` marker
- If file exists and is managed: overwrite with template
- If file exists and is not managed: backup to `.user-backup`, then install template
- If file doesn't exist: install template

### Extension Lifecycle
- On extension load: merge_opencode_agents adds agent definitions
- On extension unload: unmerge_opencode_agents removes tracked keys
- Core agents are preserved across extension load/unload cycles

## Notes

- The base template installation is not automatically triggered; it can be called via `require('neotex.plugins.ai.opencode.core').install_base_opencode_json()`
- Agent definitions in extensions use `{file:.opencode/agent/subagents/...}` paths that reference the location after extension agents are copied
- The `agents_subdir` configuration for OpenCode is `agent/subagents`, so extension agents are copied there
