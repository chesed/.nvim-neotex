# Research Report: Task #255

**Task**: 255 - Create legal context files
**Generated**: 2026-03-20
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Create domain knowledge, review patterns, and output templates for legal analysis
**Scope**: Three new context files in .claude/extensions/founder/context/project/founder/
**Affected Components**: domain/legal-frameworks.md, patterns/contract-review.md, templates/contract-analysis.md
**Domain**: founder extension
**Language**: meta

## Task Requirements

Create three context files following the patterns established by existing founder context files (business-frameworks.md, forcing-questions.md, market-sizing.md).

### File 1: domain/legal-frameworks.md

**Purpose**: Contract law basics, negotiation principles, legal terminology for founders

**Content Areas**:
- Common contract types for startups (SaaS, employment, NDA, SAFE, partnership)
- Key legal concepts founders must understand (indemnification, liability caps, IP assignment, non-compete, representations & warranties)
- Negotiation frameworks (BATNA, ZOPA, anchoring, concession patterns)
- Red flag checklist (unlimited liability, broad IP assignment, non-standard terms)
- Jurisdiction considerations
- When to escalate to a real attorney

**Pattern Reference**: `domain/business-frameworks.md` (~240 lines, structured with sections, tables, frameworks)

### File 2: patterns/contract-review.md

**Purpose**: Systematic contract review checklist and red flag detection

**Content Areas**:
- Review methodology (clause-by-clause systematic approach)
- Priority sections to review first (liability, IP, termination, payment)
- Common red flags by contract type
- Push-back patterns for legal forcing questions (similar to forcing-questions.md)
- Risk assessment matrix (likelihood x severity)
- Standard vs non-standard clause identification
- Counter-proposal generation patterns

**Pattern Reference**: `patterns/forcing-questions.md` (~221 lines, structured with question format, push-back triggers)

### File 3: templates/contract-analysis.md

**Purpose**: Output template for contract review analysis reports

**Content Areas**:
- Executive summary section
- Clause-by-clause analysis table
- Risk assessment matrix visualization
- Recommended modifications table
- Negotiation position summary
- Walk-away conditions
- Action items with priority

**Pattern Reference**: `templates/market-sizing.md` (~250 lines, structured markdown template with sections)

## Integration Points

- **Component Type**: context
- **Affected Area**: .claude/extensions/founder/context/project/founder/
- **Action Type**: create
- **Related Files**:
  - `.claude/extensions/founder/context/project/founder/domain/business-frameworks.md` (pattern reference)
  - `.claude/extensions/founder/context/project/founder/patterns/forcing-questions.md` (pattern reference)
  - `.claude/extensions/founder/context/project/founder/templates/market-sizing.md` (pattern reference)
  - `.claude/extensions/founder/agents/legal-council-agent.md` (consumer of these files)

## Dependencies

None - this task can be started independently.

## Interview Context

### User-Provided Information
Context files should provide the legal-council-agent with domain knowledge for contract review. They are loaded via @-references in the agent file and registered in index-entries.json for automated context discovery.

### Effort Assessment
- **Estimated Effort**: 2-3 hours
- **Complexity Notes**: Three files with substantial domain content; requires legal domain knowledge

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 255 [focus]` with a specific focus prompt.*
