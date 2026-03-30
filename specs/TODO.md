---
next_project_number: 323
---

# TODO

## Task Order

*Updated 2026-03-30. 2 active tasks remaining.*

### Pending

- **87** [RESEARCHED] -- Investigate terminal directory change in wezterm
- **78** [PLANNED] -- Fix Himalaya SMTP authentication failure

### Completed (Ready for Archive)

- **322** [COMPLETED] -- Add REVIEW mode to /project command

## Tasks

### 322. Add REVIEW mode to /project command for timeline analysis
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Dependencies**: None
- **Started**: 2026-03-30
- **Research Completed**: 2026-03-30
- **Planning Completed**: 2026-03-30
- **Implementation Completed**: 2026-03-30
- **Research**: [01_review-mode-design.md](322_add_review_mode_to_project_command/reports/01_review-mode-design.md)
- **Plan**: [01_implementation-plan.md](322_add_review_mode_to_project_command/plans/01_implementation-plan.md)
- **Summary**: [01_execution-summary.md](322_add_review_mode_to_project_command/summaries/01_execution-summary.md)

**Description**: Add a fourth REVIEW mode to the `/project` command that critically analyzes project timelines for gaps, issues, weaknesses, and improvement opportunities. Must support both external timeline files (e.g., `.typ`, `.md`) and existing task artifacts (research/plan reports). Analysis should cover: timeline gaps, feasibility issues, risk weaknesses, resource concerns, critical path vulnerabilities, missing dependencies, and unrealistic estimates. Update `project.md` command, `project-agent.md` agent, and create review-specific context/criteria as needed.

**Completion Summary**: Added REVIEW mode to /project command with 5 forcing questions (primary concern, changed constraints, validity window, risk tolerance, review depth), 7-category analysis framework with 30+ detection rules, 4-tier severity system (Critical/High/Medium/Low), and comprehensive review report generation. Modified project.md (+120 lines) and project-agent.md (+295 lines).

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
