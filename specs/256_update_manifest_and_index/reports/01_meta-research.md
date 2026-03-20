# Research Report: Task #256

**Task**: 256 - Update manifest.json and index-entries.json
**Generated**: 2026-03-20
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Register all new legal components in the extension's manifest and context index
**Scope**: Two existing files in .claude/extensions/founder/
**Affected Components**: manifest.json, index-entries.json
**Domain**: founder extension
**Language**: meta

## Task Requirements

### manifest.json Updates

**provides.agents**: Add `"legal-council-agent.md"`
**provides.skills**: Add `"skill-legal"`
**provides.commands**: Add `"legal.md"`

**routing.research**: Add `"founder:legal": "skill-legal"`

Current routing section:
```json
"routing": {
  "research": {
    "founder": "skill-market",
    "founder:market": "skill-market",
    "founder:analyze": "skill-analyze",
    "founder:strategy": "skill-strategy"
  },
  "plan": { "founder": "skill-founder-plan" },
  "implement": { "founder": "skill-founder-implement" }
}
```

Updated routing.research:
```json
"founder:legal": "skill-legal"
```

### index-entries.json Updates

Add three new entries for the legal context files:

```json
{
  "path": ".claude/extensions/founder/context/project/founder/domain/legal-frameworks.md",
  "summary": "Contract law basics, negotiation principles, legal terminology for founders",
  "line_count": 250,
  "load_when": {
    "agents": ["legal-council-agent", "founder-plan-agent", "founder-implement-agent"],
    "languages": ["founder"],
    "commands": ["/legal", "/plan", "/implement"]
  }
},
{
  "path": ".claude/extensions/founder/context/project/founder/patterns/contract-review.md",
  "summary": "Systematic contract review checklist, red flags, push-back patterns",
  "line_count": 230,
  "load_when": {
    "agents": ["legal-council-agent", "founder-plan-agent"],
    "languages": ["founder"],
    "commands": ["/legal", "/plan"]
  }
},
{
  "path": ".claude/extensions/founder/context/project/founder/templates/contract-analysis.md",
  "summary": "Output template for contract review analysis reports",
  "line_count": 260,
  "load_when": {
    "agents": ["legal-council-agent", "founder-implement-agent"],
    "languages": ["founder"],
    "commands": ["/legal", "/implement"]
  }
}
```

**Pattern**: Follow existing entries - domain files load for more agents, templates load for implement-agent.

## Integration Points

- **Component Type**: configuration
- **Affected Area**: .claude/extensions/founder/
- **Action Type**: modify
- **Related Files**:
  - `.claude/extensions/founder/manifest.json` (modify)
  - `.claude/extensions/founder/index-entries.json` (modify)

## Dependencies

- Task #252: legal-council-agent must exist before referencing in manifest
- Task #253: skill-legal must exist before referencing in manifest
- Task #254: legal.md command must exist before referencing in manifest
- Task #255: context files must exist before referencing in index-entries.json

## Interview Context

### User-Provided Information
The extension is loaded by the <leader>ac picker. Manifest registration is required for the extension loader to discover and activate legal components. Index entries enable automated context discovery via jq queries against index.json.

### Effort Assessment
- **Estimated Effort**: 1 hour
- **Complexity Notes**: Straightforward JSON edits following existing patterns

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 256 [focus]` with a specific focus prompt.*
