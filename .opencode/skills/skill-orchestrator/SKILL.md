---
name: skill-orchestrator
description: Route commands to appropriate workflows based on task language and status.
allowed-tools: Read, Glob, Grep, Task
---

# Orchestrator Skill

Central routing for task workflows. Delegates to research, plan, implement, and meta skills based on task language.

<context>
  <system_context>OpenCode routing and task orchestration.</system_context>
  <task_context>Route tasks to appropriate skills based on language and status.</task_context>
</context>

<context_injection>
  <file path=".opencode/context/core/orchestration/orchestration-core.md" variable="orchestration_core" />
  <file path=".opencode/context/core/orchestration/state-management.md" variable="state_management" />
</context_injection>

<role>Routing skill for command workflows.</role>

<task>Validate task context and route to the correct skill.</task>

<execution>
  <stage id="1" name="LoadContext">
    <action>Read context files defined in <context_injection></action>
  </stage>
  <stage id="2" name="Route">
    <action>Validate status and route to appropriate skill using injected context</action>
  </stage>
</execution>

<validation>Validate task status and language routing decisions.</validation>

<return_format>Return structured routing result.</return_format>

## Trigger Conditions

- A slash command needs language-based routing
- Task context needs gathering before delegation

## Execution Flow

1. **Load Context**:
   - Read `orchestration-core.md` -> `{orchestration_core}`
   - Read `state-management.md` -> `{state_management}`

2. **Route**:
   - Lookup task in `specs/state.json`.
   - Validate status for requested operation using `{state_management}`.
   - Route to appropriate skill based on language using `{orchestration_core}`.
   - Return structured result to caller.
