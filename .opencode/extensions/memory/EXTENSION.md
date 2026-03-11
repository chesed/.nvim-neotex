## Memory Extension

This project includes the memory vault extension for knowledge capture and retrieval.

### Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `/learn` | `/learn "text"` | Add text as memory |
| `/learn` | `/learn /path/to/file` | Add file content as memory |
| `/learn` | `/learn --task N` | Review task artifacts and create memories |

### Memory-Augmented Research

The `--remember` flag on `/research` enables memory-augmented research:

```bash
/research N --remember
```

When the memory extension is loaded, this flag:
1. Searches the memory vault for relevant prior knowledge
2. Includes top matching memories in research context
3. Adds "Prior Knowledge from Memory Vault" section to the report

**Note**: The `--remember` flag requires this extension to be loaded. If the extension is not loaded, the flag is ignored gracefully.

### Skill-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-memory | (direct execution) | Memory creation and management |

### MCP Integration

The `obsidian-memory` MCP server provides:
- `search_notes` - Search memories by keywords
- `read_note` - Retrieve full memory content
- `write_note` - Create new memory
- `list_notes` - Enumerate all memories

**Setup**: See memory-setup.md context file for MCP server configuration.

**Graceful Degradation**: If MCP is unavailable, direct file access still works.

### Memory Vault Structure

```
.memory/
+-- .obsidian/           # Obsidian configuration
+-- 00-Inbox/            # Quick capture for new memories
+-- 10-Memories/         # Stored memory entries
+-- 20-Indices/          # Navigation and organization
+-- 30-Templates/        # Memory entry templates
```

### Memory Classification

When using `/learn --task N`, memories are classified into categories:

- **[TECHNIQUE]** - Reusable method or approach
- **[PATTERN]** - Design or implementation pattern
- **[CONFIG]** - Configuration or setup knowledge
- **[WORKFLOW]** - Process or procedure
- **[INSIGHT]** - Key learning or understanding
