# OpenCode Memory Vault

This directory contains an Obsidian-compatible vault for the OpenCode memory management system.

## Purpose

The memory vault stores structured knowledge that the OpenCode system can reference and search. Memories are stored as Markdown files with YAML frontmatter for metadata.

## Directory Structure

```
.opencode/memory/
+-- .obsidian/           # Obsidian configuration
+-- 00-Inbox/            # Quick capture for new memories
+-- 10-Memories/         # Stored memory entries
+-- 20-Indices/          # Navigation and organization
+-- 30-Templates/        # Memory entry templates
```

## Adding Memories

Use the `/learn` command:
- `/learn "text to remember"` - Add text content
- `/learn /path/to/file.md` - Add file content

The command will:
1. Parse the input
2. Generate a unique memory ID
3. Present a preview with checkbox options
4. Allow you to add new, update existing, edit, or skip

## Git Workflow

**What to commit**:
- All `.md` files in the vault
- Templates and indices
- This README

**What to ignore** (in `.gitignore`):
- `.obsidian/` directory (user-specific Obsidian settings)
- `*.sqlite` files (search indexes)
- Plugin directories

## MCP Server Setup

For advanced features (search, retrieval), install the Obsidian CLI REST MCP server:

1. Open Obsidian app
2. Open this `.opencode/memory/` as a vault
3. Install "Obsidian CLI REST" community plugin
4. Note the API key from plugin settings
5. Configure MCP server with the API key

See `.opencode/context/project/memory/memory-setup.md` for detailed instructions.

## Naming Conventions

Memory files follow the pattern:
```
MEM-YYYY-MM-DD-NNN-slugified-title.md
```

Example: `MEM-2026-03-06-001-neovim-lsp-best-practices.md`

## Template Format

Memory entries use YAML frontmatter:
```yaml
---
id: MEM-2026-03-06-001
title: "Neovim LSP Best Practices"
date: 2026-03-06
tags: neovim, lsp, configuration
source: "user input"
---
```

## Best Practices

- Use descriptive first lines for better titles
- Review index.md regularly for navigation
- Commit memories to git for version history
- Use tags for better organization
- Link related memories using `[[filename]]` syntax
