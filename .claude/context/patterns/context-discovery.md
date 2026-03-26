# Context Discovery Patterns

**Created**: 2026-02-24
**Updated**: 2026-03-25
**Purpose**: jq query patterns for three-layer context discovery

## Three-Layer Architecture

Context is discovered from three independent sources, loaded in parallel:

| Layer | Index | Path Prefix | Description |
|-------|-------|-------------|-------------|
| Agent context | `.claude/context/index.json` | `.claude/context/` | Core patterns + extension context (merged by loader) |
| Project context | `.context/index.json` | `.context/` | User-defined project conventions (may be empty) |
| Project memory | `.memory/` (no index) | `.memory/` | Learned facts, loaded directly as files |

Extension context is merged INTO `.claude/context/index.json` by the extension loader. There is no separate extension query.

## Layer 1: Agent Context

All paths in `.claude/context/index.json` are relative to `.claude/context/`.

### Query by Agent Name

```bash
jq -r '.entries[] |
  select(.load_when.agents[]? == "planner-agent") |
  .path' .claude/context/index.json
```

### Query by Language

```bash
jq -r '.entries[] |
  select(.load_when.languages[]? == "neovim") |
  .path' .claude/context/index.json
```

### Query by Command

```bash
jq -r '.entries[] |
  select(.load_when.commands[]? == "/implement") |
  .path' .claude/context/index.json
```

### Query by Domain

```bash
jq -r '.entries[] |
  select(.domain == "core") |
  .path' .claude/context/index.json
```

### Query Always-Load Files

```bash
jq -r '.entries[] |
  select(.load_when.always == true) |
  .path' .claude/context/index.json
```

### Exclude Deprecated Files

```bash
jq -r '.entries[] |
  select(.deprecated == true | not) |
  select(.load_when.agents[]? == "planner-agent") |
  .path' .claude/context/index.json
```

### Query by Topic or Keyword

```bash
# By topic
jq -r '.entries[] |
  select(.topics[]? == "delegation") |
  .path' .claude/context/index.json

# By keyword (case-insensitive)
jq -r '.entries[] |
  select(.keywords[]? | test("jq"; "i")) |
  .path' .claude/context/index.json
```

## Layer 2: Project Context

All paths in `.context/index.json` are relative to `.context/`. This layer may have no entries initially.

```bash
# Query project context (safe if file missing or entries empty)
jq -r '.entries[] | .path' .context/index.json 2>/dev/null
```

## Layer 3: Project Memory

`.memory/` files are loaded directly -- no index needed.

```bash
# List all memory files
find .memory -name "*.md" -type f 2>/dev/null
```

## Multi-Layer Discovery

### Full Context for an Agent

Query all three layers to build a complete context set:

```bash
# Layer 1: Agent context (core + extensions)
jq -r --arg a "planner-agent" '.entries[] |
  select(.load_when.agents[]? == $a) |
  ".claude/context/" + .path' .claude/context/index.json

# Layer 2: Project context (if any)
if [ -f .context/index.json ]; then
  jq -r '.entries[] | ".context/" + .path' .context/index.json
fi

# Layer 3: Project memory (independent)
if [ -d .memory ]; then
  find .memory -name "*.md" -type f
fi
```

## Budget-Aware Loading

### Get Line Counts

```bash
jq -r '.entries[] |
  select(.load_when.agents[]? == "planner-agent") |
  "\(.line_count)\t\(.path)"' .claude/context/index.json
```

### Filter by Line Count Budget

```bash
jq -r '.entries[] |
  select(.load_when.languages[]? == "neovim") |
  select(.line_count < 300) |
  .path' .claude/context/index.json
```

### Calculate Total Context Budget

```bash
jq '[.entries[] |
  select(.load_when.agents[]? == "planner-agent") |
  .line_count] | add' .claude/context/index.json
```

## Combined Queries

### Agent + Language

```bash
jq -r '.entries[] |
  select(
    (.load_when.agents[]? == "general-implementation-agent") or
    (.load_when.languages[]? == "neovim")
  ) |
  select(.deprecated == true | not) |
  .path' .claude/context/index.json
```

### Command with Budget Limit

```bash
jq -r '.entries[] |
  select(.load_when.commands[]? == "/implement") |
  select(.line_count < 500) |
  "\(.path) (\(.line_count) lines)"' .claude/context/index.json
```

## Priority Loading Strategy

1. Always-load files (critical patterns, standards)
2. Agent-specific files (from `load_when.agents`)
3. Language-specific files (from `load_when.languages`)
4. Project context (from `.context/index.json`)
5. Project memory (from `.memory/`)
6. Topic-specific files (as needed for task)

## Validation

### Check All Paths Exist

```bash
jq -r '.entries[].path' .claude/context/index.json | while read p; do
  [ -f ".claude/context/$p" ] || echo "MISSING: $p"
done
```

## Maintenance

When adding new context files:

1. Add entry to the appropriate `index.json` (agent context or project context)
2. Set appropriate `load_when` conditions
3. Include accurate `line_count`
4. Run validation to ensure paths exist

When deprecating files:

1. Set `deprecated: true`
2. Add `replacement` field with new file path
3. Update agents that reference the deprecated file
