## Lean 4 Extension

This section provides routing and context for Lean 4 theorem proving tasks.

### Language Routing

| Language | Research Agent | Implementation Agent |
|----------|----------------|---------------------|
| `lean4` | lean-research | lean-implementation |

### Research Tools
- `read`, `grep`, `glob` - Codebase analysis
- Lean MCP tools - `lean_leansearch`, `lean_loogle`, `lean_local_search`

### Implementation Tools
- `read`, `write`, `edit` - File operations
- `bash` - Run `lake build`
- Lean MCP tools - `lean_goal`, `lean_multi_attempt`, `lean_hover_info`

### Build Verification

Always verify before completing:

```bash
lake build
```

### Context Files

Load for Lean development:

- `@.opencode/extensions/lean/context/project/lean4/mathlib-overview.md`
- `@.opencode/extensions/lean/context/project/lean4/lean4-style-guide.md`
- `@.opencode/extensions/lean/context/project/lean4/tactic-patterns.md`
