# Research Report: Task #257

**Task**: 257 - Update EXTENSION.md documentation
**Generated**: 2026-03-20
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Document the /legal command and legal task_type in EXTENSION.md
**Scope**: Existing file in .claude/extensions/founder/
**Affected Components**: EXTENSION.md
**Domain**: founder extension
**Language**: meta

## Task Requirements

Update EXTENSION.md to document the new /legal capability. Follow the existing documentation patterns.

### Sections to Update

**Commands Table**: Add /legal row
```markdown
| `/legal` | `/legal "SaaS agreement review"` | Ask forcing questions, create task (stops at [NOT STARTED]) |
```

**task_type Field Table**: Add legal row
```markdown
| /legal | legal | skill-legal |
```

**Skill-to-Agent Mapping Table**: Add legal row
```markdown
| skill-legal | legal-council-agent | Contract review and negotiation (uses forcing_data) |
```

**Language-Based Routing Table**: Add legal routing rows
```markdown
| `/research` (task_type: legal) | founder:legal | skill-legal | legal-council-agent |
```

**Context Files Table**: Add three legal context entries
```markdown
| `context/project/founder/domain/legal-frameworks.md` | Contract law, negotiation principles |
| `context/project/founder/patterns/contract-review.md` | Review checklist, red flags |
| `context/project/founder/templates/contract-analysis.md` | Contract analysis output template |
```

**Pre-Task Forcing Questions Section**: Add /legal example workflow

**Version**: Bump to v2.2 (or whatever current version convention suggests)

## Integration Points

- **Component Type**: documentation
- **Affected Area**: .claude/extensions/founder/
- **Action Type**: modify
- **Related Files**:
  - `.claude/extensions/founder/EXTENSION.md` (modify)

## Dependencies

- Task #256: manifest and index updates should be completed first so documentation reflects final state

## Interview Context

### User-Provided Information
EXTENSION.md is merged into .claude/CLAUDE.md when the extension is loaded. It provides the user-facing documentation for all founder extension capabilities.

### Effort Assessment
- **Estimated Effort**: 30 minutes
- **Complexity Notes**: Adding rows to existing tables and a brief workflow example

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 257 [focus]` with a specific focus prompt.*
