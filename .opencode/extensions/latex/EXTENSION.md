## LaTeX Extension

This section provides routing and context for LaTeX document development.

### Language Routing

| Language | Research Agent | Implementation Agent |
|----------|----------------|---------------------|
| `latex` | latex-research | latex-implementation |

### Research Tools
- `read`, `grep`, `glob` - Codebase analysis
- `websearch`, `webfetch` - Documentation lookup

### Implementation Tools
- `read`, `write`, `edit` - File operations
- `bash` - Run `pdflatex`, `latexmk`, `bibtex`

### Build Verification

Always verify before completing:

```bash
latexmk -pdf document.tex
```

### Context Files

Load for LaTeX development:

- `@.opencode/extensions/latex/context/project/latex/document-structure.md`
- `@.opencode/extensions/latex/context/project/latex/theorem-environments.md`
