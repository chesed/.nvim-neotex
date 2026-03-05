---
description: Research a task and create a research report
---

Research the given task and write a research report. Do NOT implement anything.

**Input**: $ARGUMENTS

---

## Parse Input

- First token: task number — accepts `OC_N` or `N` (strip `OC_` prefix to get integer N)
- `--remember` flag: include memory vault search in research context
- Remaining tokens: optional focus prompt
- If invalid: "Usage: /research <OC_N> [--remember] [focus]"

---

## Steps

### 1. Look up task

Strip `OC_` prefix, find task in `specs/state.json`:
```bash
jq --arg n "N" '.active_projects[] | select(.project_number == ($n | tonumber))' specs/state.json
```
If not found: "Task OC_N not found in state.json"

Extract: `language`, `status`, `project_name`, `description`

Zero-pad N to 3 digits for paths: `NNN` (e.g. 174 → 174, keep as-is if already ≥3 digits... use printf "%03d")

Directory: `specs/OC_NNN_<project_name>/`

### 2. Validate status

- `not_started`, `partial`, `researched`: proceed
- `researching`: warn "already researching, proceeding anyway"
- `abandoned`: error "task is abandoned, use /task --recover first"
- `completed`: warn "already completed, re-researching"

### 3. Display task header

The skill displays a visual header during its Preflight stage to show the active task:

```
╔══════════════════════════════════════════════════════════╗
║  Task OC_N: <project_name>                               ║
║  Action: RESEARCHING                                     ║
╚══════════════════════════════════════════════════════════╝
```

This header appears at the start of the research command (after validation, before delegation) to clearly indicate which task is being worked on. The header is displayed by the skill-researcher before invoking the general-research-agent subagent.

### 4. Update status to RESEARCHING

Edit `specs/state.json`: set `status` to `"researching"` and update `last_updated` for this task.

Edit `specs/TODO.md`: change `[NOT STARTED]` (or current status marker) to `[RESEARCHING]` on the `### OC_N.` entry.

### 5. Memory Search (if --remember flag present)

If `--remember` was passed in arguments:

**Build search query**:
- Extract keywords from task description
- Add focus prompt keywords if provided
- Limit to 3-5 most significant terms

**Query memory vault**:
- Use MCP tool: `search_notes`
- Query: extracted keywords
- Limit: 5 results

**Process results**:
- If results found: Read full content of top 3 memories
- If no results: Note "No relevant memories found"

**Include in research context**:
- Add "## Prior Knowledge from Memory Vault" section to research report
- Include memory summaries (truncated to 1000 chars each)
- List memory IDs for reference
- Mark report as "memory_augmented: true"

**Graceful degradation**:
- If MCP unavailable: Skip memory search, continue with standard research
- If no memories found: Note in report, continue

### 6. Invoke skill-researcher

**Call skill tool** to execute the research workflow:

```
→ Tool: skill
→ Name: skill-researcher
→ Prompt: Research task {N} with language {language} and focus {focus}. Include memory context: {memory_results}
```

The skill-researcher will:
1. Load context files
2. Execute preflight (validate, display header, update status to RESEARCHING)
3. **Call Task tool with `subagent_type="general-research-agent"`** (or specialized agent based on language)
4. Execute postflight (update state.json to RESEARCHED, update TODO.md, commit changes)
5. Return results

**CRITICAL**: Do NOT implement research logic in this command. All research logic belongs in skill-researcher and general-research-agent.

**Research strategy** (handled by skill/agent based on language):
- **meta**: Focus on existing `.opencode/` files, conventions, patterns
- **lean**: Search codebase for existing proofs, check Lean/Mathlib patterns
- **typst/latex**: Read existing documents, check style and structure
- **general**: Web search + codebase exploration

### 7. Report results

Show a brief summary:
- Task researched
- Key findings (3-5 bullets)
- Report path
- Next step: `/plan OC_N`

---

## Rules

- The skill-researcher handles ALL research logic - do not implement in command
- Write the report BEFORE updating status to RESEARCHED
- Never fabricate findings — only report what you actually discovered
- Keep the report focused and actionable
- Directories use 3-digit padded number: `OC_174_slug` not `OC_17_slug`
- Commit changes after completing research (non-blocking — log warning if commit fails)
