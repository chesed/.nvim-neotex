## Z3 SMT Solver Extension

This section provides routing and context for Z3 SMT solver development.

### Language Routing

| Language | Research Agent | Implementation Agent |
|----------|----------------|---------------------|
| `z3` | z3-research | z3-implementation |

### Research Tools
- `read`, `grep`, `glob` - Codebase analysis
- `websearch`, `webfetch` - Z3 documentation lookup

### Implementation Tools
- `read`, `write`, `edit` - File operations
- `bash` - Run Z3 solver

### Verification

Always verify Z3 scripts:

```bash
z3 script.smt2
```

### Context Files

Load for Z3 development:

- `@.opencode/extensions/z3/context/project/z3/z3-api.md`
- `@.opencode/extensions/z3/context/project/z3/constraint-generation.md`
