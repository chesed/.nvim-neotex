## Present Extension

Structured proposal development (grants) in Typst format.

### Skill-Agent Mapping

| Skill | Agent | Model | Purpose |
|-------|-------|-------|---------|
| skill-grant | grant-agent | opus | Grant proposal research and drafting |

### Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `/grant` | `/grant "Description"` | Create grant task (stops at [NOT STARTED]) |
| `/grant` | `/grant N --draft ["focus"]` | Draft narrative sections (exploratory) |
| `/grant` | `/grant N --budget ["guidance"]` | Develop budget with justification |
| `/grant` | `/grant --revise N "description"` | Create revision task for existing grant |

### Language Routing

| Language | Research Skill | Implementation Skill | Tools |
|----------|----------------|---------------------|-------|
| `grant` | `skill-grant` | `skill-grant` | WebSearch, WebFetch, Read, Write, Edit |
