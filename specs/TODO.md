---
next_project_number: 152
---

# TODO

## Tasks

### OC_152. Fix git commit co-author attribution showing Claude Opus instead of actual model
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: meta
- **Dependencies**: None

**Description**: Fix git commit co-author attribution showing 'Co-Authored-By: Claude Opus 4.5' when using Kimi K2.5 in OpenCode. The commit messages incorrectly attribute co-authorship to Claude Opus when the actual model being used is Kimi K2.5. Need to investigate where this attribution is coming from and either correct it to reflect the actual model or remove it entirely.

---

### OC_151. Rename /remember command to /learn
- **Effort**: 1-2 hours
- **Status**: [PLANNING]
- **Language**: meta
- **Dependencies**: None
- **Research**: [research-001.md](OC_151_rename_remember_command_to_learn/reports/research-001.md) - Comprehensive research report identifying 47+ references to skill-remember and /remember across the OpenCode system. Categorized by priority and provided clean-break rename recommendations based on OC_142 precedent.

**Description**: Rename the /remember command to /learn throughout the OpenCode system. This involves updating the skill definition (skill-remember → skill-learn), command registration, and all documentation references.

---
### 87. Investigate terminal directory change when opening neovim in wezterm
- **Effort**: TBD
- **Status**: [COMPLETED]
- **Research Started**: 2026-02-13
- **Research Completed**: 2026-02-13
- **Language**: neovim
- **Dependencies**: None
- **Research**: [research-001.md](087_investigate_wezterm_terminal_directory_change/reports/research-001.md)

**Description**: Investigate why the terminal working directory changes to a project root when opening neovim sessions in wezterm from the home directory (~). Determine whether this behavior is caused by neovim or wezterm (configured in ~/.dotfiles/config/). Identify if any functionality depends on this behavior before modifying it. Goal is to avoid changing the terminal directory unless necessary.

### 78. Fix Himalaya SMTP authentication failure when sending emails
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Research Started**: 2026-02-13
- **Research Completed**: 2026-02-13
- **Planning Started**: 2026-02-13
- **Planning Completed**: 2026-02-13
- **Language**: neovim
- **Dependencies**: None
- **Research**: [research-001.md](078_fix_himalaya_smtp_authentication_failure/reports/research-001.md)
- **Plan**: [implementation-001.md](078_fix_himalaya_smtp_authentication_failure/plans/implementation-001.md)

**Description**: Fix Gmail SMTP authentication failure when sending emails via Himalaya (<leader>me). Error: "Authentication failed: Code: 535, Enhanced code: 5.7.8, Message: Username and Password not accepted". The error occurs with TLS connection attempts and persists through multiple retry attempts. Identify and fix the root cause of the SMTP credential configuration.

### 72. Fix himalaya sidebar help showing leader keybindings that conflict with toggle selection
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Language**: neovim
- **Dependencies**: None

**Description**: Fix himalaya sidebar help display (shown via '?') incorrectly showing leader keybindings (`<leader>mA` - Switch account, `<leader>mf` - Change folder, `<leader>ms` - Sync folder) in the Folder Management section. These leader commands should not be accessible or defined in the sidebar since `<leader>` is `<Space>` which is used for toggle selections in that buffer.
