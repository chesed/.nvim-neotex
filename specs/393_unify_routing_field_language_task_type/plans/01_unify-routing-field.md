# Implementation Plan: Task #393

- **Task**: 393 - Unify routing field: replace separate language and task_type with single extension:task_type format
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: specs/393_unify_routing_field_language_task_type/reports/01_team-research.md
- **Artifacts**: plans/01_unify-routing-field.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Replace the two-field routing approach (`language` + `task_type`) with a single compound `language` field using colon-delimited format (e.g., `"present:grant"` instead of `"present"` + `"grant"`). The `task_type` field becomes deprecated. Core languages (`meta`, `general`, `markdown`, `neovim`, etc.) remain as bare strings without subtypes. Only the 2 extensions with sub-routing (founder, present) change to compound values. The work is mechanical across ~90 files: 14 extension commands, ~42 extension skills/agents, 5 core files, and ~30 documentation files.

### Research Integration

Team research (4 teammates) confirmed: (1) the routing commands already handle compound language values with fallback to base key, so the routing layer needs only a compatibility shim, not a rewrite; (2) `task_type` is dead code for routing -- extracted but never used in manifest lookup; (3) the manifest routing tables already use compound keys (`founder:deck`, `present:grant`); (4) three `meta` special-case checks in skill-implementer use `language == "meta"` for load-bearing behavior (ROAD_MAP.md vs claudemd_suggestions routing) and must not break; (5) context discovery `load_when.languages` uses exact matching and needs a companion fix for compound values.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Eliminate the `task_type` field from new task creation, storing compound values directly in `language`
- Update all extension commands to write `language: "founder:deck"` instead of `language: "founder"` + `task_type: "deck"`
- Add backward-compatible routing shim for existing tasks that still have `task_type`
- Update extension skills/agents to validate compound `language` instead of separate `task_type`
- Update context discovery to handle compound language values
- Add present sub-type keywords to `/task` language detection
- Update documentation and schema references

**Non-Goals**:
- Renaming the `language` field to `routing` or `domain` (cost: 261 files, no benefit)
- Making core languages use compound values (`meta:something` -- never needed)
- Supporting hierarchical routing beyond one colon level (`present:grant:nih`)
- Migrating archived tasks to new format (archive is read-only, base-key fallback works)
- Removing `task_type` from the schema entirely (keep deprecated for backward compat)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `meta` special-case breaks | H | L | Core languages stay bare; never add subtypes to `meta`; defensive prefix check |
| Context discovery fails for compound values | H | M | Update `load_when.languages` entries alongside command changes |
| Task 392 overlap causes merge conflicts | M | M | Mechanical changes are non-conflicting; phase 2 re-touches present files |
| Mixed-format coexistence during rollout | M | L | Routing shim constructs compound key from old format; base-key fallback preserved |
| validate-wiring.sh rejects compound keys | L | H | Update script in final phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 5 | 2, 3 |

### Phase 1: Core Schema and Routing Compatibility [NOT STARTED]

**Goal**: Establish the compatibility shim in routing commands and update schema documentation so compound values work end-to-end before touching extension files.

**Tasks**:
- [ ] Add compatibility shim to `research.md`: if `task_type` exists and `language` is bare, construct compound key `{language}:{task_type}` before routing lookup
- [ ] Add same shim to `plan.md` and `implement.md`
- [ ] Update `state-management-schema.md`: mark `task_type` as deprecated, document compound `language` format
- [ ] Update `CLAUDE.md` Language-Based Routing section: document compound format for extensions
- [ ] Update `CLAUDE.md` state.json structure example: remove `task_type`, show compound language
- [ ] Add present sub-type keywords to `/task` command language detection (grant, budget, timeline, funds, talk)
- [ ] Update `/task` to write compound `language` value instead of separate `language` + `task_type` for extension tasks

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `.claude/commands/research.md` - Add compatibility shim for task_type -> compound key
- `.claude/commands/plan.md` - Add same compatibility shim
- `.claude/commands/implement.md` - Add same compatibility shim
- `.claude/commands/task.md` - Update language detection keywords; update state.json write to use compound language
- `.claude/context/reference/state-management-schema.md` - Mark task_type deprecated, document compound format
- `.claude/CLAUDE.md` - Update routing table docs, state.json example

**Verification**:
- Grep confirms `task_type` is marked deprecated in schema
- `/task` keyword detection includes present sub-types
- Routing commands contain compatibility shim logic
- CLAUDE.md examples show compound language format

---

### Phase 2: Extension Commands (founder + present) [NOT STARTED]

**Goal**: Update all 14 extension commands to write compound `language` values directly instead of separate `language` + `task_type` fields.

**Tasks**:
- [ ] Update 9 founder commands: `analyze.md`, `deck.md`, `finance.md`, `legal.md`, `market.md`, `meeting.md`, `project.md`, `sheet.md`, `strategy.md` -- change task creation to use `language: "founder:{subtype}"`, remove `task_type` field
- [ ] Update 5 present commands: `budget.md`, `funds.md`, `grant.md`, `talk.md`, `timeline.md` -- change task creation to use `language: "present:{subtype}"`, remove `task_type` field
- [ ] For each command: update mode documentation, examples, and any references to `task_type`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/extensions/founder/commands/analyze.md`
- `.claude/extensions/founder/commands/deck.md`
- `.claude/extensions/founder/commands/finance.md`
- `.claude/extensions/founder/commands/legal.md`
- `.claude/extensions/founder/commands/market.md`
- `.claude/extensions/founder/commands/meeting.md`
- `.claude/extensions/founder/commands/project.md`
- `.claude/extensions/founder/commands/sheet.md`
- `.claude/extensions/founder/commands/strategy.md`
- `.claude/extensions/present/commands/budget.md`
- `.claude/extensions/present/commands/funds.md`
- `.claude/extensions/present/commands/grant.md`
- `.claude/extensions/present/commands/talk.md`
- `.claude/extensions/present/commands/timeline.md`

**Verification**:
- `grep -rn 'task_type' .claude/extensions/*/commands/*.md` returns zero results
- Each command sets compound `language` value (e.g., `"present:grant"`)

---

### Phase 3: Extension Skills and Agents [NOT STARTED]

**Goal**: Update all extension skill and agent files to validate and reference compound `language` values instead of separate `task_type` checks.

**Tasks**:
- [ ] Update founder skills (~10 files): `skill-market`, `skill-analyze`, `skill-strategy`, `skill-finance`, `skill-meeting`, `skill-deck-research`, `skill-deck-plan`, `skill-deck-implement`, `skill-founder-implement`, `skill-founder-plan` -- change `task_type` validation to compound language check (e.g., `language == "founder:deck"` instead of `task_type == "deck"`)
- [ ] Update present skills (~5 files): `skill-grant`, `skill-budget`, `skill-timeline`, `skill-funds`, `skill-talk` -- same compound language validation pattern
- [ ] Update founder agents (~8 files): change delegation metadata from `task_type` to compound `language`
- [ ] Update present agents (~6 files): same compound language delegation metadata
- [ ] For each file: update jq extraction (remove `task_type` extraction, use `language` directly), update documentation comments

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `.claude/extensions/founder/skills/*/SKILL.md` (~10 files)
- `.claude/extensions/present/skills/*/SKILL.md` (~5 files)
- `.claude/extensions/founder/agents/*.md` (~8 files)
- `.claude/extensions/present/agents/*.md` (~6 files)

**Verification**:
- `grep -rn 'task_type' .claude/extensions/*/skills/` returns zero results (excluding deprecated references)
- `grep -rn 'task_type' .claude/extensions/*/agents/` returns zero results
- Skills validate compound language (e.g., `language == "present:grant"`) not task_type

---

### Phase 4: Context Discovery and Core Skills [NOT STARTED]

**Goal**: Update context index `load_when.languages` entries and core skills that reference `task_type` or make `meta` special-case checks.

**Tasks**:
- [ ] Update `.claude/context/index.json`: for any entries with `load_when.languages` containing extension languages, ensure compound values are handled (add compound entries if extension context should load for sub-typed tasks, or add prefix-matching logic note)
- [ ] Review and update `skill-implementer/SKILL.md`: verify `meta` checks use exact match (already correct since meta stays bare); remove any `task_type` extraction code
- [ ] Review and update `skill-researcher/SKILL.md`: remove any `task_type` extraction code
- [ ] Update `skill-fix-it/SKILL.md`: update any hardcoded `"language": "meta"` examples if referencing task_type
- [ ] Add defensive prefix check for `meta` in `skill-implementer`: use `language | startswith("meta")` or `cut -d: -f1 == "meta"` pattern (future-proofing even though meta won't get subtypes)

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `.claude/context/index.json` - Update `load_when.languages` entries for extension context
- `.claude/skills/skill-implementer/SKILL.md` - Remove task_type extraction; defensive meta check
- `.claude/skills/skill-researcher/SKILL.md` - Remove task_type extraction
- `.claude/skills/skill-fix-it/SKILL.md` - Update examples

**Verification**:
- Context loads correctly for `language: "present:grant"` tasks (prefix match or explicit entries)
- `meta` special-case checks still work correctly
- No core skills reference `task_type` for routing decisions

---

### Phase 5: Documentation, Validation Scripts, and Cleanup [NOT STARTED]

**Goal**: Update all remaining documentation, validation scripts, and perform final verification that `task_type` is fully deprecated.

**Tasks**:
- [ ] Update `validate-wiring.sh`: add compound key awareness for language validation
- [ ] Update `.claude/context/formats/plan-format.md` if it references `task_type`
- [ ] Update `.claude/context/reference/artifact-templates.md` if it references `task_type`
- [ ] Update `.claude/context/orchestration/routing.md` and related orchestration docs
- [ ] Update any remaining context files that reference `task_type` (scan with grep)
- [ ] Run `validate-wiring.sh` to confirm all routing still passes
- [ ] Final grep audit: `grep -rn 'task_type' .claude/` should show only: (1) deprecated schema reference, (2) compatibility shim in routing commands, (3) this plan file
- [ ] Verify a sample extension routing path works: `language: "present:grant"` resolves to `skill-grant` via manifest lookup

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `.claude/scripts/validate-wiring.sh` - Add compound key support
- `.claude/context/formats/plan-format.md` - Remove task_type references if any
- `.claude/context/reference/artifact-templates.md` - Update examples
- `.claude/context/orchestration/routing.md` - Update routing documentation
- Various context/docs files identified by grep scan

**Verification**:
- `validate-wiring.sh` passes without errors
- `grep -rn 'task_type' .claude/` shows only deprecated/compat references
- Manual trace: `present:grant` task creation -> routing -> skill invocation works conceptually
- All compound keys in manifests have matching documentation

## Testing & Validation

- [ ] Compatibility shim correctly constructs compound key from legacy `language` + `task_type` format
- [ ] Core language routing (`meta`, `general`, `markdown`) is unaffected
- [ ] Extension routing resolves compound keys (`founder:deck` -> `skill-deck-research`)
- [ ] Context discovery loads correct entries for compound language values
- [ ] `meta` special-case checks in `skill-implementer` still correctly route ROAD_MAP.md vs claudemd_suggestions
- [ ] `/task` keyword detection produces compound values for present sub-types
- [ ] `validate-wiring.sh` passes with compound key awareness
- [ ] No active tasks in state.json reference `task_type` after migration

## Artifacts & Outputs

- Updated routing commands (research.md, plan.md, implement.md) with compatibility shim
- Updated `/task` command with present sub-type keywords and compound language output
- Updated 14 extension commands (9 founder, 5 present) using compound language
- Updated ~29 extension skill/agent files using compound language validation
- Updated context index for compound language matching
- Updated validation script and documentation
- Deprecated `task_type` field in schema (kept for backward compat)

## Rollback/Contingency

The compatibility shim in routing commands provides bidirectional support: old-format tasks (with `task_type`) work via shim-constructed compound keys, and new-format tasks (with compound `language`) work via direct manifest lookup. If issues arise mid-migration:

1. **Partial rollback**: Revert extension command changes only; the shim handles both formats
2. **Full rollback**: `git revert` the implementation commits; old-format tasks continue working since manifests already have both bare and compound keys
3. **Forward fix**: Since all changes are mechanical text replacements, any individual file can be corrected independently
