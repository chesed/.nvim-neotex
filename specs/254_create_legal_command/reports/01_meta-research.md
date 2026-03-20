# Research Report: Task #254

**Task**: 254 - Create /legal command
**Generated**: 2026-03-20
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Create /legal command with pre-task forcing questions for contract review
**Scope**: New command file in .claude/extensions/founder/commands/
**Affected Components**: commands/legal.md
**Domain**: founder extension
**Language**: meta

## Task Requirements

Create `legal.md` following the pre-task forcing question pattern used by market.md, analyze.md, and strategy.md.

### Key Patterns to Follow (from market.md)

1. **Frontmatter**: description, allowed-tools, argument-hint
2. **Syntax Section**: Multiple input types (description, task number, file path, --quick)
3. **Input Types Table**: Description string, task number, file path, --quick flag
4. **Modes Table**: REVIEW, NEGOTIATE, TERMS, DILIGENCE
5. **STAGE 0: Pre-Task Forcing Questions**:
   - Step 0.1: Mode selection via AskUserQuestion
   - Step 0.2: Essential forcing questions (one at a time)
   - Step 0.3: Store forcing_data JSON object
6. **CHECKPOINT 1: GATE IN**:
   - Session ID generation
   - Input type detection
   - Task creation in state.json with task_type: "legal" and forcing_data
   - TODO.md update with forcing data summary
   - Git commit
   - Display summary and STOP for new tasks
7. **STAGE 2: DELEGATE**: Only for task_number or --quick input
8. **CHECKPOINT 2: GATE OUT**: Verify research completed, display result

### Forcing Questions for Legal

**Question 1: Contract Type**
```
What type of contract or agreement are you reviewing?
Be specific - "business agreement" is too vague. Is it SaaS, employment, partnership, IP license, NDA, investment?
```
Store as `forcing_data.contract_type`.

**Question 2: Primary Concern**
```
What is your primary objective or concern with this agreement?
Examples: "Limit liability exposure", "Ensure IP protection", "Negotiate better payment terms"
```
Store as `forcing_data.primary_concern`.

**Question 3: Your Position**
```
What is your role in this agreement?
Are you the service provider, customer, investor, employee, or partner?
```
Store as `forcing_data.position`.

**Question 4: Financial Exposure**
```
What is the approximate financial value or exposure of this agreement?
This helps calibrate the depth of review needed.
```
Store as `forcing_data.financial_exposure`.

### Allowed Tools

```
Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Read, Edit, AskUserQuestion
```

### Argument Hint

```
"[description]" | TASK_NUMBER | /path/to/contract.md | --quick [contract type]
```

## Integration Points

- **Component Type**: command
- **Affected Area**: .claude/extensions/founder/commands/
- **Action Type**: create
- **Related Files**:
  - `.claude/extensions/founder/commands/market.md` (pattern reference)
  - `.claude/extensions/founder/skills/skill-legal/SKILL.md` (delegated skill)

## Dependencies

None - this task can be started independently.

## Interview Context

### User-Provided Information
Command should support contract file input as a primary use case (reading a contract file for review). The --quick mode enables standalone contract review without task creation.

### Effort Assessment
- **Estimated Effort**: 2-3 hours
- **Complexity Notes**: Follows market.md closely; contract file input adds minor complexity

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 254 [focus]` with a specific focus prompt.*
