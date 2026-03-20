# Research Report: Task #252

**Task**: 252 - Create legal-council-agent
**Generated**: 2026-03-20
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Add contract review and negotiation legal counsel capability to the founder extension
**Scope**: New agent file in .claude/extensions/founder/agents/
**Affected Components**: agents/legal-council-agent.md
**Domain**: founder extension
**Language**: meta

## Task Requirements

Create `legal-council-agent.md` following the established agent pattern used by market-agent, analyze-agent, and strategy-agent in the founder extension.

### Key Patterns to Follow (from market-agent.md)

1. **Frontmatter**: name, description, mcp-servers (if applicable)
2. **Agent Metadata Block**: Name, Purpose, Invoked By, Return Format
3. **Allowed Tools**: AskUserQuestion (one-at-a-time forcing questions), Read, Write, Glob, WebSearch, Bash
4. **Context References**: @-references to legal context files (domain/legal-frameworks.md, patterns/contract-review.md)
5. **Execution Flow**: Stage 0 (early metadata), Stage 1 (parse delegation), Stage 2 (mode selection), Stages 3-5 (forcing questions), Stage 6 (generate report), Stage 7 (write report), Stage 8 (write metadata), Stage 9 (return summary)
6. **Push-Back Patterns**: Table of vague legal answers and specific push-back responses
7. **Error Handling**: User abandonment, partial completion, missing data

### Modes for Legal Agent

| Mode | Posture | Focus |
|------|---------|-------|
| REVIEW | Risk assessment | Identify problematic clauses, red flags, missing protections |
| NEGOTIATE | Position building | Counter-terms, leverage points, walk-away conditions |
| TERMS | Drafting assistance | Term sheet review, key terms, standard vs non-standard |
| DILIGENCE | Due diligence | IP assignment, liability, representations & warranties |

### Forcing Questions Structure

One question at a time via AskUserQuestion:
- Q1: Contract type and parties involved
- Q2: What are your primary concerns or objectives?
- Q3: What is your negotiating position (buyer/seller/partner)?
- Q4: Are there specific clauses you need reviewed?
- Q5: What is the deal value or financial exposure?
- Q6: What jurisdiction governs this agreement?
- Q7: What are your walk-away conditions?
- Q8: Are there precedent agreements or standard terms you expect?

### Output Format

Research report at `specs/{NNN}_{SLUG}/reports/01_{short-slug}.md` following the standard artifact format with legal-specific sections.

## Integration Points

- **Component Type**: agent
- **Affected Area**: .claude/extensions/founder/agents/
- **Action Type**: create
- **Related Files**:
  - `.claude/extensions/founder/agents/market-agent.md` (pattern reference)
  - `.claude/extensions/founder/context/project/founder/domain/legal-frameworks.md` (context to load)
  - `.claude/extensions/founder/context/project/founder/patterns/contract-review.md` (context to load)

## Dependencies

None - this task can be started independently.

## Interview Context

### User-Provided Information
User wants a legal council agent for contract review and negotiation within the founder extension. The agent should follow the same forcing question pattern as market-agent (one-at-a-time via AskUserQuestion) and produce research reports that feed into the /plan -> /implement workflow.

### Effort Assessment
- **Estimated Effort**: 2-3 hours
- **Complexity Notes**: Straightforward pattern replication from market-agent with legal domain adaptation

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 252 [focus]` with a specific focus prompt.*
