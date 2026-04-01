# Present Extension

Grant writing support tools for Claude Code. Provides structured proposal development with funder research, budget planning, and narrative drafting.

## Table of Contents

- [Overview](#overview)
- [Commands](#commands)
- [Grant Writing](#grant-writing)

## Overview

The present extension provides grant writing capabilities:

| Feature | Command | Purpose |
|---------|---------|---------|
| Grant Writing | `/grant` | Structured proposal development with funder research |

**Note**: Pitch deck generation has moved to the `founder` extension. Use `/deck` via the founder extension.

## Commands

### /grant - Grant Writing

Structured proposal development for research funding.

```bash
# Create a grant task
/grant "Research NIH R01 funding for AI safety project"

# Draft narrative sections
/grant 500 --draft "Focus on methodology"

# Develop budget
/grant 500 --budget "Include travel for 3 conferences"

# Revise existing grant
/grant --revise 500 "Update based on reviewer feedback"
```

## Grant Writing

See [EXTENSION.md](EXTENSION.md) for complete grant writing documentation.

Quick reference:
```bash
/grant "Description"           # Create task
/research N                    # Research funders
/grant N --draft              # Draft narrative
/grant N --budget             # Develop budget
/plan N                       # Create implementation plan
/implement N                  # Assemble materials
```

## Related Files

- [EXTENSION.md](EXTENSION.md) - Full extension documentation
- [context/project/present/domain/grant-workflow.md](context/project/present/domain/grant-workflow.md) - Grant workflow reference
- [context/project/present/patterns/proposal-structure.md](context/project/present/patterns/proposal-structure.md) - Proposal structure patterns
