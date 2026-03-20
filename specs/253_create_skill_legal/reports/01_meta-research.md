# Research Report: Task #253

**Task**: 253 - Create skill-legal
**Generated**: 2026-03-20
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Create thin wrapper skill that delegates to legal-council-agent
**Scope**: New skill directory in .claude/extensions/founder/skills/
**Affected Components**: skills/skill-legal/SKILL.md
**Domain**: founder extension
**Language**: meta

## Task Requirements

Create `skill-legal/SKILL.md` following the thin wrapper pattern used by skill-market, skill-analyze, and skill-strategy.

### Key Patterns to Follow (from skill-market/SKILL.md)

1. **Frontmatter**: name, description, allowed-tools (Task, Bash, Edit, Read, Write)
2. **Context Pointers**: Reference to subagent-return.md (do not load eagerly)
3. **Trigger Conditions**: Direct invocation (/legal command), implicit invocation (plan step patterns)
4. **Execution Flow**:
   - Stage 1: Input validation (task_number, validate exists in state.json, validate language is founder)
   - Stage 2: Preflight status update (set to "researching")
   - Stage 3: Create postflight marker (.postflight-pending)
   - Stage 4: Prepare delegation context (task_context, forcing_data, metadata_file_path)
   - Stage 5: Invoke agent via Task tool (legal-council-agent)
   - Stage 6: Parse subagent return (.return-meta.json)
   - Stage 7: Update task status (postflight to "researched")
   - Stage 8: Link artifacts (two-step jq pattern)
   - Stage 9: Git commit
   - Stage 10: Cleanup (remove .postflight-pending, .return-meta.json)
   - Stage 11: Return brief summary

### Trigger Patterns for Legal

**Plan step language patterns**:
- "Review contract terms"
- "Analyze legal implications"
- "Contract review and negotiation"
- "Legal due diligence"

**Target mentions**:
- "contract review", "legal analysis"
- "term sheet", "negotiation terms"
- "indemnification", "liability", "IP assignment"

### When NOT to Trigger

- Market analysis (use skill-market)
- Competitive analysis (use skill-analyze)
- GTM strategy (use skill-strategy)
- General business research (use skill-researcher)

## Integration Points

- **Component Type**: skill
- **Affected Area**: .claude/extensions/founder/skills/
- **Action Type**: create
- **Related Files**:
  - `.claude/extensions/founder/skills/skill-market/SKILL.md` (pattern reference)
  - `.claude/extensions/founder/agents/legal-council-agent.md` (delegated agent)

## Dependencies

None - this task can be started independently.

## Interview Context

### User-Provided Information
Skill should be a thin wrapper following the established skill-internal postflight pattern. It delegates all substantive work to legal-council-agent via the Task tool.

### Effort Assessment
- **Estimated Effort**: 1-2 hours
- **Complexity Notes**: Direct pattern copy from skill-market with legal-specific trigger conditions

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 253 [focus]` with a specific focus prompt.*
