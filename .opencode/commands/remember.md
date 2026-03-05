---
description: Add a memory to the vault with interactive checkbox confirmation
---

# Command: /remember

**Purpose**: Takes text or file paths, analyzes content, and adds them to the memory vault with interactive checkbox confirmation  
**Layer**: 2 (Command File - Argument Parsing Agent)  
**Delegates To**: skill-remember (direct execution)

---

## Argument Parsing

<argument_parsing>
  <step_1>
    Parse arguments:
    - First argument is either text content or file path
    - If path exists: treat as file
    - If path doesn't exist: treat as text content
    
    input = remaining args joined with spaces
    is_file = file_exists(input)
  </step_1>
</argument_parsing>

---

## Workflow Execution

<workflow_execution>
  <step_1>
    <action>Delegate to Remember Skill</action>
    <input>
      - skill: "skill-remember"
      - args: "input={input}, is_file={is_file}"
    </input>
    <expected_return>
      {
        "status": "completed",
        "memory_id": "MEM-YYYY-MM-DD-NNN",
        "actions_taken": ["added", "updated"],
        "file_path": "path/to/memory.md"
      }
    </expected_return>
  </step_1>

  <step_2>
    <action>Present Results</action>
    <process>
      Display memory operations completed:
      - List of memories added/updated
      - File paths
      - Git commit info
      - Next steps guidance
    </process>
  </step_2>
</workflow_execution>

---

## Error Handling

<error_handling>
  <argument_errors>
    - No arguments provided -> "Usage: /remember <text or file path>"
    - Invalid file path -> "File not found: {path}"
  </argument_errors>
  
  <execution_errors>
    - Skill failure -> Return error details
    - MCP unavailable -> Continue with direct file access
  </execution_errors>
  
  <interactive_errors>
    - User cancels -> Exit gracefully, no files created
  </interactive_errors>
</error_handling>

---

## State Management

<state_management>
  <reads>
    - specs/OC_136_*/plans/implementation-003.md
    - .opencode/memory/30-Templates/memory-template.md
    - .opencode/memory/10-Memories/ (for ID generation)
  </reads>
  
  <writes>
    - .opencode/memory/10-Memories/*.md (new memory files)
    - .opencode/memory/20-Indices/index.md (updated links)
  </writes>
</state_management>
