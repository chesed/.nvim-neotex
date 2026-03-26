# Research Report: Task #291

**Task**: 291 - Update CLAUDE.md and agent references for new paths
**Generated**: 2026-03-25
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Update all documentation and code references to use new context paths
**Scope**: CLAUDE.md files, agent definitions, skill definitions
**Affected Components**: Documentation, agent/skill @-references
**Domain**: meta
**Language**: meta

## Task Requirements

After restructuring, update all references to context files throughout the codebase.

### Path Changes Summary

| Old Path | New Path |
|----------|----------|
| `.claude/context/core/*` | `.claude/context/*` |
| `.claude/context/project/repo/*` | `.context/repo/*` |
| `.claude/context/project/processes/*` | `.context/processes/*` |
| `.claude/context/project/hooks/*` | `.context/hooks/*` |
| `.claude/context/project/meta/*` | `.claude/context/meta/*` |
| `.claude/context/project/{ext}/*` | `.claude/extensions/{ext}/context/*` |

### Files to Update

1. **CLAUDE.md files**:
   - `~/.config/nvim/.claude/CLAUDE.md` - Context Discovery, Context Imports sections
   - `~/.config/nvim/CLAUDE.md` - Related Documentation section

2. **Agent definitions** (`.claude/agents/*.md`):
   - Update all @-reference paths
   - grep for `@.claude/context/core/` and `@.claude/context/project/`

3. **Skill definitions** (`.claude/skills/*/SKILL.md`):
   - Update context loading instructions

4. **Command definitions** (`.claude/commands/*.md`):
   - Update any hardcoded context paths

5. **Rules** (`.claude/rules/*.md`):
   - Update context path references

6. **Context README**:
   - `.claude/context/README.md` - Complete rewrite for new structure

### Search and Replace Patterns

```bash
# Find all references to old paths
grep -r "@.claude/context/core/" .claude/
grep -r "@.claude/context/project/" .claude/
grep -r ".claude/context/core/" .claude/
grep -r ".claude/context/project/" .claude/
```

### Verification

After updates, run:
```bash
# Verify no broken @-references remain
.claude/scripts/validate-wiring.sh --all
```

## Integration Points

- **Component Type**: documentation
- **Affected Area**: All .claude/ files with context references
- **Action Type**: update
- **Related Files**:
  - All files in `.claude/` with context path references

## Dependencies

- Task #290: Update context discovery patterns (patterns must be defined first)

## Interview Context

### User-Provided Information
This is a cleanup task to ensure all references use the new paths. Should be done systematically with grep to find all occurrences.

### Effort Assessment
- **Estimated Effort**: 1 hour
- **Complexity Notes**: Straightforward search and replace, but need to be thorough.

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 291 [focus]` with a specific focus prompt.*
