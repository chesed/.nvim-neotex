---
name: skill-remember
description: Add a memory to the vault with checkbox-based multi-select confirmation
allowed-tools: Bash, Edit, Read, Write, Grep, AskUserQuestion
---

# Remember Skill

Direct execution skill for adding memories to the vault using checkbox-based interactive confirmation.

<context>
  <system_context>OpenCode memory management with interactive multi-select.</system_context>
  <task_context>Add text or file content as memory entry with user-guided actions.</task_context>
</context>

<role>Direct execution skill for memory creation with checkbox-based confirmation.</role>

<task>Parse input, generate memory entry, search for similar memories, present checkbox options, execute selected actions.</task>

<execution>
  <stage id="1" name="ParseInput">
    <action>Determine if input is file path or text</action>
    <action>Read file if path exists, otherwise use text directly</action>
    <process>
      1. Check if input argument is an existing file path
      2. If file exists:
         - Read file content
         - Use filename as title base
      3. If file doesn't exist:
         - Treat input as text content
         - Use first line as title
    </process>
  </stage>
  
  <stage id="2" name="GenerateID">
    <action>Generate unique memory ID</action>
    <process>
      1. Scan .opencode/memory/10-Memories/ for existing MEM-YYYY-MM-DD-*.md files
      2. Extract sequence numbers for today's date
      3. Generate next number (001, 002, etc.)
      4. Format: MEM-YYYY-MM-DD-NNN (e.g., MEM-2026-03-06-001)
    </process>
  </stage>
  
  <stage id="3" name="CreateEntry">
    <action>Create memory entry from template</action>
    <process>
      1. Load template from .opencode/memory/30-Templates/memory-template.md
      2. Extract metadata:
         - Title: First line of text or filename
         - Date: Current date (YYYY-MM-DD)
         - Source: "user input" or file path
         - Tags: Empty (for future auto-extraction)
      3. Fill template placeholders:
         - {{date}} → current date
         - {{sequence}} → sequence number (001, 002, etc.)
         - {{title}} → extracted title
         - {{tags}} → empty or comma-separated tags
         - {{source}} → source description
         - {{content}} → full content
      4. Generate markdown content
    </process>
  </stage>
  
  <stage id="4" name="FindSimilar">
    <action>Search for similar existing memories</action>
    <process>
      1. Extract keywords from title/content
      2. Search .opencode/memory/10-Memories/ for matching content
      3. If MCP server available, use search_notes tool for better results
      4. Extract top 3 similar memories with IDs and titles
      5. Store for display in confirmation dialog
    </process>
  </stage>
  
  <stage id="5" name="InteractiveConfirm">
    <action>Show preview and present checkbox options</action>
    <process>
      1. Display memory preview:
         ```
         Memory Preview:
         ─────────────────────────────────────────
         ID: MEM-2026-03-06-001
         Title: Neovim LSP Configuration Best Practices
         Source: user input
         Date: 2026-03-06
         
         Content Preview (first 300 chars):
         When configuring LSP servers in Neovim, it's important to...
         ─────────────────────────────────────────
         
         Similar Memories Found:
         - MEM-2026-03-05-042: "LSP server setup guide"
         - MEM-2026-03-04-038: "Neovim configuration tips"
         ```
      
      2. Present checkbox options using AskUserQuestion with multiSelect:
         ```json
         {
           "question": "What would you like to do with this memory?",
           "options": [
             {"label": "Add as new memory", "value": "add_new"},
             {"label": "Update existing similar memory", "value": "update_existing"},
             {"label": "Edit content before saving", "value": "edit_content"},
             {"label": "Skip - don't save", "value": "skip"}
           ],
           "multiple": true
         }
         ```
      
      3. Handle user selections
    </process>
  </stage>
  
  <stage id="6" name="ExecuteActions">
    <action>Execute selected actions</action>
    <process>
      Based on user selections:
      
      **If "skip" selected (only option or with others)**:
      - Cancel operation
      - Return success with no actions taken
      
      **If "edit_content" selected**:
      - Open content in editable buffer
      - Allow user modifications
      - Use modified content for subsequent actions
      
      **If "add_new" selected**:
      - Generate filename: MEM-YYYY-MM-DD-NNN-slugified-title.md
      - Write to .opencode/memory/10-Memories/
      - Append link to .opencode/memory/20-Indices/index.md
      - Record "added" action
      
      **If "update_existing" selected**:
      - Display list of similar memories found in Stage 4
      - Let user select which memory to update
      - Read existing memory file
      - Append new content under "## Update History" section
      - Add timestamp: `### Update: YYYY-MM-DD HH:MM`
      - Record "updated" action
      
      **Handle multiple selections**:
      - Execute "edit_content" first (if selected)
      - Then execute "add_new" and/or "update_existing"
      - Support merge scenarios (add AND update in one flow)
    </process>
  </stage>
  
  <stage id="7" name="CommitAndReport">
    <action>Commit changes and report results</action>
    <process>
      1. Stage modified files with git add
      2. Create commit with descriptive message:
         - Single action: "memory: add MEM-2026-03-06-001"
         - Multiple actions: "memory: add MEM-2026-03-06-001, update MEM-2026-03-05-042"
      3. Generate success report:
         ```
         Memory Operations Completed:
         ✓ Added: MEM-2026-03-06-001 (.opencode/memory/10-Memories/...)
         ✓ Updated: MEM-2026-03-05-042 (appended new content)
         ✓ Index updated with 1 new link
         
         Git commit: <commit-hash>
         ```
      4. Return JSON with status, actions_taken, and memory IDs
    </process>
  </stage>
</execution>

<validation>Validate checkbox confirmation, file creation, and index updates.</validation>

<return_format>Return JSON: {"status": "completed", "memory_id": "...", "actions_taken": [...], "file_path": "..."}</return_format>

## Example Usage Flow

```
1. User: /remember "neovim lsp configuration best practices"
2. Skill: Generates ID, creates entry from template
3. Skill: Searches for similar memories
4. Skill: Shows preview + finds 2 similar memories
5. Skill: Displays checkbox:
   - [x] Add as new memory
   - [ ] Update existing similar memory
   - [ ] Edit content before saving
   - [ ] Skip - don't save
6. User selects: Add as new
7. Skill: Writes file to 10-Memories/
8. Skill: Updates index.md
9. Skill: Git commit
10. Skill: Returns success
```

## Error Handling

- **File not found**: Return error with guidance
- **Empty content**: Warn user, ask to confirm
- **MCP unavailable**: Continue with file-based search
- **User cancels**: Exit gracefully, no changes
- **Git errors**: Log warning, continue

## Similar Memories Detection

Uses simple keyword matching on titles and content:
1. Extract words from title (3+ characters)
2. Count matches in existing memory files
3. Return top 3 with most matches
4. If MCP available, use search_notes for better results
