# skill-task

Task creation context loading skill for the OpenCode system.

## Purpose

This skill provides context injection for the `/task` command, enabling delegation to a task-creation agent while maintaining consistency with the preflight/skill/postflight pattern used by other commands (`/implement`, `/plan`, `/research`).

## Structure

```
opencode/skills/skill-task/
├── SKILL.md    - Skill definition with context injection patterns
└── README.md   - This file
```

## Usage

The skill is invoked by the `/task` command during CREATE mode:

```
→ Tool: skill
→ Name: skill-task
→ Prompt: Create task entry with description "..."
```

The skill:
1. Loads context files (return-metadata-file.md, postflight-control.md, etc.)
2. References task.md for CREATE mode steps
3. Delegates to task-creation-agent
4. Coordinates postflight status updates

## Important Notes

- **Context Only**: This skill ONLY loads context definitions. It does NOT execute workflows.
- **Command Responsibility**: The `/task` command must execute preflight and postflight steps.
- **Authoritative Source**: task.md contains the complete CREATE mode workflow steps.

## Pattern Consistency

This skill follows the same architectural pattern as:
- `skill-implementer` - For `/implement` command
- `skill-planner` - For `/plan` command
- `skill-researcher` - For `/research` command

All skills follow the "command orchestrates workflow" pattern:
1. Command executes preflight
2. Skill loads context and delegates to agent
3. Command executes postflight

## Related Files

- `.opencode/commands/task.md` - Task command definition (CREATE mode steps)
- `.opencode/skills/skill-implementer/SKILL.md` - Reference implementation
