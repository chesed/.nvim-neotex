## Python Extension

This section provides routing and context for Python development.

### Language Routing

| Language | Research Agent | Implementation Agent |
|----------|----------------|---------------------|
| `python` | python-research | python-implementation |

### Research Tools
- `read`, `grep`, `glob` - Codebase analysis
- `websearch`, `webfetch` - Documentation lookup

### Implementation Tools
- `read`, `write`, `edit` - File operations
- `bash` - Run pytest, mypy, python

### Verification

Always verify before completing:

```bash
pytest                    # Run tests
mypy src/                 # Type checking
python -m py_compile X    # Syntax check
```

### Context Files

Load for Python development:

- `@.opencode/extensions/python/context/project/python/code-style.md`
- `@.opencode/extensions/python/context/project/python/testing-patterns.md`
