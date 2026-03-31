---
next_project_number: 336
---

# TODO

## Task Order

*Updated 2026-03-31. 7 active tasks remaining.*

### Pending

- **333** [COMPLETED] -- Add plan format verification to founder-plan-agent
  - **Research**: [01_format-verification.md](333_add_plan_format_verification_to_founder_plan_agent/reports/01_format-verification.md)
  - **Plan**: [01_format-verification.md](333_add_plan_format_verification_to_founder_plan_agent/plans/01_format-verification.md)
- **334** [IMPLEMENTING] -- Add generic/edit task_type fallback to founder-plan-agent
  - **Research**: [01_generic-fallback.md](334_add_generic_edit_task_type_to_founder_plan_agent/reports/01_generic-fallback.md)
  - **Plan**: [01_generic-fallback.md](334_add_generic_edit_task_type_to_founder_plan_agent/plans/01_generic-fallback.md)
- **335** [COMPLETED] -- Create plan-format enforcement rule
  - **Research**: [01_enforcement-rule.md](335_create_plan_format_enforcement_rule/reports/01_enforcement-rule.md)
  - **Plan**: [01_enforcement-rule.md](335_create_plan_format_enforcement_rule/plans/01_enforcement-rule.md)
- **330** [COMPLETED] -- Create /finance command, skill, and agent
  - **Research**: [01_finance-command-research.md](330_create_finance_command_skill_agent/reports/01_finance-command-research.md)
  - **Plan**: [01_finance-command-plan.md](330_create_finance_command_skill_agent/plans/01_finance-command-plan.md)
- **332** [COMPLETED] -- Integrate finance into founder extension (depends on 330, 331)
- **87** [RESEARCHED] -- Investigate terminal directory change in wezterm
- **78** [PLANNED] -- Fix Himalaya SMTP authentication failure

## Tasks

### 333. Add plan format verification to founder-plan-agent
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Language**: meta
- **Dependencies**: None
- **Created**: 2026-03-31

**Description**: Add Stage 6a verification checklist to founder-plan-agent.md mirroring planner-agent's pattern. Verify all 7 required metadata fields (Status, Task, Effort, Dependencies, Research Inputs, Artifacts, Standards, Type), all 7 required sections, phase heading format, and per-phase fields.

---

### 334. Add generic/edit task_type fallback to founder-plan-agent
- **Effort**: 1 hour
- **Status**: [RESEARCHING]
- **Language**: meta
- **Dependencies**: None
- **Created**: 2026-03-31

**Description**: Add generic/edit task_type fallback path to founder-plan-agent.md. When task doesn't fit specialized templates (market-sizing, competitive-analysis, etc.), fall back to standard plan-format.md template instead of improvising.

---

### 335. Create plan-format enforcement rule
- **Effort**: 30 minutes
- **Status**: [COMPLETED]
- **Language**: meta
- **Dependencies**: None
- **Created**: 2026-03-31

**Description**: Create .claude/rules/plan-format-enforcement.md with path glob specs/**/plans/**. Lists required metadata fields and section headings as a checklist for any agent writing plans. Defense-in-depth enforcement.

---

### 332. Integrate finance into founder extension
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Dependencies**: 330, 331
- **Created**: 2026-03-31
- **Completed**: 2026-03-30

**Description**: Wire /finance into the founder extension: add finance-agent, skill-finance, and /finance command to manifest.json routing tables. Add context entries to index-entries.json. Update EXTENSION.md documentation.

**Completion Summary**: Integration completed as part of task 330 Phase 2. All routing, documentation, and context discovery entries are in place.

---

### 330. Create /finance command, skill, and agent
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Dependencies**: None
- **Created**: 2026-03-31
- **Completed**: 2026-03-30
- **Research**: [01_finance-command-research.md](specs/330_create_finance_command_skill_agent/reports/01_finance-command-research.md)
- **Plan**: [01_finance-command-plan.md](specs/330_create_finance_command_skill_agent/plans/01_finance-command-plan.md)

**Description**: Create the /finance command (finance.md), research skill (skill-finance/SKILL.md), and research agent (finance-agent.md) for the founder extension.

**Completion Summary**: Created 3 core files: finance.md command (AUDIT/MODEL/FORECAST/VALIDATE modes, 5 forcing questions), skill-finance/SKILL.md (11-stage execution), finance-agent.md (document analysis + XLSX verification). Updated 3 integration files: manifest.json (routing entries), EXTENSION.md (docs), index-entries.json (3 new entries + finance-agent added to 3 existing entries).

---

### 87. Investigate terminal directory change when opening neovim in wezterm
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Research Started**: 2026-02-13
- **Research Completed**: 2026-02-13
- **Language**: neovim
- **Dependencies**: None
- **Research**: [research-001.md](087_investigate_wezterm_terminal_directory_change/reports/research-001.md)

**Description**: Investigate why the terminal working directory changes to a project root when opening neovim sessions in wezterm from the home directory (~). Determine whether this behavior is caused by neovim or wezterm (configured in ~/.dotfiles/config/). Identify if any functionality depends on this behavior before modifying it. Goal is to avoid changing the terminal directory unless necessary.

---

### 78. Fix Himalaya SMTP authentication failure when sending emails
- **Effort**: 1-2 hours
- **Status**: [PLANNED]
- **Research Started**: 2026-02-13
- **Research Completed**: 2026-02-13
- **Planning Started**: 2026-02-13
- **Planning Completed**: 2026-02-13
- **Language**: neovim
- **Dependencies**: None
- **Research**: [research-001.md](078_fix_himalaya_smtp_authentication_failure/reports/research-001.md)
- **Plan**: [implementation-001.md](078_fix_himalaya_smtp_authentication_failure/plans/implementation-001.md)

**Description**: Fix Gmail SMTP authentication failure when sending emails via Himalaya (<leader>me). Error: "Authentication failed: Code: 535, Enhanced code: 5.7.8, Message: Username and Password not accepted". The error occurs with TLS connection attempts and persists through multiple retry attempts. Identify and fix the root cause of the SMTP credential configuration.

---
