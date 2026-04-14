# Implementation Plan: Fix Artifact Linking Order in TODO.md

- **Task**: 431 - Fix artifact linking order and missing blank line in TODO.md
- **Status**: [PLANNED]
- **Effort**: small
- **Dependencies**: None
- **Research Inputs**: specs/431_fix_artifact_linking_order_todo/reports/01_artifact-linking-bug.md
- **Artifacts**: specs/431_fix_artifact_linking_order_todo/plans/01_artifact-linking-fix.md
- **Standards**: state-management-schema.md, artifact-formats.md
- **Type**: meta
- **Lean Intent**: true

## Overview

Fix two bugs in `link-artifact-todo.sh`: (1) blank line above `**Description**:` is consumed when inserting artifact lines before it, and (2) the `specs/` prefix is stripped from link paths while manual agent edits preserve it, causing inconsistency. A third issue -- task creation placing artifacts below Description -- is addressed by adding a defensive reorder in the script itself rather than auditing all task creation paths.

### Research Integration

The research report identified four bugs. Bug 1 (research link below Description) originates in task creation, not the script. Rather than auditing every task creation path (`/task`, `/meta`, `/fix-it`, `/review`, `/errors`, `/spawn`), this plan adds a post-insertion validation step in the script that detects and corrects misplaced artifact lines. Bug 2 (blank line consumption) is fixed by adjusting insertion logic. Bug 3 (specs/ prefix inconsistency) is fixed by removing the prefix stripping. Bug 4 (Summary next_field) is a non-issue once blank line preservation works.

## Goals & Non-Goals

**Goals:**
- Preserve blank line between last artifact field and `**Description**:` during insertion
- Standardize link paths to include `specs/` prefix (matching manual agent behavior)
- Ensure script is robust against pre-existing malformed entries

**Non-Goals:**
- Auditing all task creation commands for artifact placement (out of scope for this fix)
- Changing the `next_field` parameterization for Summary skill calls
- Retroactively fixing already-malformed TODO.md entries (cosmetic, will self-correct)

## Risks & Mitigations

- **Risk**: Blank line logic change may break entries without a blank line above Description
  - **Mitigation**: Check for blank line presence before adjusting; only shift insertion point when blank line exists
- **Risk**: Removing `specs/` stripping changes all future link formats
  - **Mitigation**: This matches the format agents already use in manual edits; existing links are functional either way
- **Risk**: sed line number arithmetic off-by-one errors
  - **Mitigation**: Test with `--dry-run` on representative entries before applying

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1    | 1      | --         |
| 2    | 2      | 1          |

### Phase 1: Fix link-artifact-todo.sh [NOT STARTED]

**Goal:** Fix blank line preservation and specs/ prefix handling in the script.

**Tasks:**
- [ ] In Case 1 (lines 124-134): Before inserting at `actual_next_line`, check if the line at `actual_next_line - 1` is blank. If so, insert at `actual_next_line - 1` instead (before the blank line), so the blank line remains between the new artifact line and `**Description**:`
- [ ] In Case 3 (lines 156-178): Apply the same blank line check before `insert_before`
- [ ] Remove the `specs/` prefix stripping on line 69 (`todo_link_path="${artifact_path#specs/}"` becomes `todo_link_path="$artifact_path"`)
- [ ] Add a comment explaining the blank line preservation logic

**Timing:** 15-20 minutes

**Depends on:** none

### Phase 2: Validate with dry-run tests [NOT STARTED]

**Goal:** Verify the fix handles all edge cases correctly.

**Tasks:**
- [ ] Run `--dry-run` against a task entry with blank line above Description (should insert before blank line)
- [ ] Run `--dry-run` against a task entry without blank line above Description (should insert normally)
- [ ] Run `--dry-run` against a task entry with existing multi-line field (Case 3)
- [ ] Run `--dry-run` against a task entry where artifact is already linked (Case 4 no-op)
- [ ] Verify link paths now include `specs/` prefix in dry-run output

**Timing:** 10 minutes

**Depends on:** 1

## Testing & Validation

- Run `bash .claude/scripts/link-artifact-todo.sh <task> '**Research**' '**Plan**' 'specs/431_.../reports/01_artifact-linking-bug.md' --dry-run` and verify output shows correct insertion point
- Run against a test task entry and verify blank line is preserved above `**Description**:`
- Run against Case 2 (inline-to-multiline conversion) to verify no regression
- Inspect resulting TODO.md formatting for the test entry

## Artifacts & Outputs

| Artifact | Path |
|----------|------|
| Modified script | `.claude/scripts/link-artifact-todo.sh` |
| This plan | `specs/431_fix_artifact_linking_order_todo/plans/01_artifact-linking-fix.md` |

## Rollback/Contingency

The script is version-controlled. If the fix introduces regressions, revert with `git checkout HEAD~1 -- .claude/scripts/link-artifact-todo.sh`. The changes are isolated to a single file with no downstream dependencies beyond the skill invocations that already call it.
