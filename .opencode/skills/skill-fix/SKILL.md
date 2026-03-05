---
name: skill-fix
description: Scan files for FIX:/NOTE:/TODO: tags and create tasks.
allowed-tools: Task, Bash, Edit, Read, Write
---

# Fix Skill

Direct execution skill for scanning tags and creating tasks.

<context>
  <system_context>OpenCode tag scanning and task creation.</system_context>
  <task_context>Scan codebase tags and create tasks based on selections.</task_context>
</context>

<context_injection>
  <file path="specs/TODO.md" variable="todo_file" />
  <file path="specs/state.json" variable="state_file" />
</context_injection>

<role>Direct execution skill for tag discovery and task creation.</role>

<task>Scan FIX/NOTE/TODO tags and create tasks.</task>

<execution>
  <stage id="1" name="LoadContext">
    <action>Load {todo_file} and {state_file} for task management</action>
  </stage>
  <stage id="2" name="ScanTags">
    <action>Scan for FIX:/NOTE:/TODO: tags across codebase</action>
  </stage>
  <stage id="3" name="InteractiveSelection">
    <action>Present findings and let user select which to convert to tasks</action>
  </stage>
  <stage id="4" name="CreateTasks">
    <action>Create tasks in {todo_file} and {state_file} for selected tags</action>
  </stage>
</execution>

<validation>Validate tag parsing and task creation outputs.</validation>

<return_format>Return summary of created tasks.</return_format>

## Context References

Reference (do not load eagerly):
- Path: `@specs/TODO.md` - Current task list
- Path: `@specs/state.json` - Machine state

## Tag Patterns

Scans for these embedded comment tags:

| Tag | Purpose | Example |
|-----|---------|---------|
| `FIX:` | Bug or issue that needs fixing | `# FIX: Handle null pointer case` |
| `NOTE:` | Important observation or documentation | `# NOTE: This assumes positive integers` |
| `TODO:` | Pending work or implementation | `# TODO: Add input validation` |

## Workflow

1. **Scan Phase**: Recursively search specified paths (or entire project)
2. **Parse Phase**: Extract tag text, file path, and line number
3. **Interactive Phase**: Present findings with checkboxes for selection
4. **Creation Phase**: Generate tasks for selected tags with proper categorization

## Task Creation Rules

- FIX: tags -> Create "fix" type tasks
- NOTE: tags -> Create "note" type tasks (or documentation tasks)
- TODO: tags -> Create standard tasks