## Typst Extension

This section provides routing and context for Typst document development.

### Language Routing

| Language | Research Agent | Implementation Agent |
|----------|----------------|---------------------|
| `typst` | typst-research | typst-implementation |

### Research Tools
- `read`, `grep`, `glob` - Codebase analysis
- `websearch`, `webfetch` - Documentation lookup

### Implementation Tools
- `read`, `write`, `edit` - File operations
- `bash` - Run `typst compile`

### Build Verification

Always verify before completing:

```bash
typst compile document.typ
```

### Context Files

Load for Typst development:

- `@.opencode/extensions/typst/context/project/typst/theorem-environments.md`
- `@.opencode/extensions/typst/context/project/typst/compilation-guide.md`
