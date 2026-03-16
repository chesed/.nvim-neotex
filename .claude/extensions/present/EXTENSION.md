## Present Extension

This project includes presentation support via the present extension. Provides structured proposal development (grants) and investor pitch deck generation (decks) in Typst format.

---

## Grant Writing

Structured proposal development, budget planning, and funder-specific guidance for research and project funding applications.

### Command Reference

The `/grant` command supports both task creation and grant-specific workflows.

#### Task Creation Mode
```bash
/grant "Description"
```
Creates a task with `language="grant"`. The description is recorded, not executed.

**Example**:
```bash
/grant "Research NIH R01 funding for AI safety project"
```

Output:
```
Grant task #500 created: Research NIH R01 funding for AI safety project
Status: [NOT STARTED]
Language: grant

Recommended workflow:
1. /research 500 - Research funders and requirements
2. /plan 500 - Create proposal plan
3. /grant 500 --draft - Draft narrative sections
4. /grant 500 --budget - Develop budget
5. /grant 500 --finish ~/submissions/ - Export for submission
```

#### Draft Mode (--draft)
```bash
/grant N --draft                     # Default drafting
/grant N --draft "Optional prompt"   # Guided drafting
```

Drafts narrative sections of the proposal. Optional prompt provides focus guidance.

**Examples**:
```bash
/grant 500 --draft
/grant 500 --draft "Focus on innovation and methodology sections"
/grant 500 --draft "Expand the specific aims with more detail on experimental design"
```

#### Budget Mode (--budget)
```bash
/grant N --budget                    # Default budget template
/grant N --budget "Optional prompt"  # Guided budget
```

Develops line-item budget with justification. Optional prompt provides budget guidance.

**Examples**:
```bash
/grant 500 --budget
/grant 500 --budget "Include travel for 3 conferences per year"
/grant 500 --budget "Focus on personnel costs, minimize equipment requests"
```

#### Finish Mode (--finish)
```bash
/grant N --finish PATH                    # Default export
/grant N --finish PATH "Optional prompt"  # Custom export
```

Exports completed grant materials to PATH. PATH is required. Optional prompt customizes export.

**Examples**:
```bash
/grant 500 --finish ~/grants/NSF_CAREER/
/grant 500 --finish ~/grants/NSF_CAREER/ "Compile as single PDF"
/grant 500 --finish ~/submissions/ "Include only narrative and budget, exclude appendices"
```

#### Legacy Mode (Deprecated)
```bash
/grant N workflow_type [focus]
```

Legacy workflow_type syntax is deprecated but still supported:
- `funder_research` - Use `/research N` instead
- `proposal_draft` - Use `/grant N --draft` instead
- `budget_develop` - Use `/grant N --budget` instead
- `progress_track` - Still supported

### Language Routing

| Language | Research Skill | Implementation Skill | Tools |
|----------|----------------|---------------------|-------|
| `grant` | `skill-grant` | `skill-grant` | WebSearch, WebFetch, Read, Write, Edit |

**Core Command Integration**: Tasks with `language="grant"` route through core commands:

| Command | Routes To | Purpose |
|---------|-----------|---------|
| `/research N` | skill-grant (funder_research) | Research funders |
| `/plan N` | skill-grant | Create proposal plan |
| `/implement N` | skill-grant | Execute plan phases |

### Skill-Agent Mapping

| Skill | Agent | Model | Purpose |
|-------|-------|-------|---------|
| skill-grant | grant-agent | opus | Grant proposal research and drafting |

### Recommended Workflow

1. **Create task**: `/grant "Research NSF CAREER funding for AI interpretability"`
2. **Research funders**: `/research 500` (routes to skill-grant)
3. **Create plan**: `/plan 500` (routes to skill-grant)
4. **Draft narrative**: `/grant 500 --draft ["focus prompt"]`
5. **Develop budget**: `/grant 500 --budget ["budget guidance"]`
6. **Export materials**: `/grant 500 --finish ~/submissions/ ["export options"]`

### Grant Writing Components

- **Narrative Sections**: Problem statement, methodology, impact, sustainability
- **Budget Development**: Personnel, equipment, travel, indirect costs
- **Compliance**: Funder-specific requirements, format guidelines, submission procedures

### Context Imports

Domain knowledge (load as needed):
- @.claude/context/project/present/README.md
- @.claude/context/project/present/domain/
- @.claude/context/project/present/templates/
- @.claude/context/project/present/patterns/

---

## Pitch Deck Generation

YC-style investor pitch deck generation in Typst format using the touying package.

### Language Routing

| Language | Research Skill | Implementation Skill | Tools |
|----------|----------------|---------------------|-------|
| `deck` | `skill-deck` | `skill-deck` | Read, Write, Glob, Bash |

### Skill-Agent Mapping

| Skill | Agent | Model | Purpose |
|-------|-------|-------|---------|
| skill-deck | deck-agent | - | Pitch deck generation in Typst |

### Deck Generation Workflow

1. **Input Phase**: Accept prompt describing startup or file with startup information
2. **Content Mapping**: Map content to YC's 10-slide structure
3. **Generation Phase**: Generate complete Typst file with touying syntax
4. **Output Phase**: Write .typ file ready for compilation

### Key Components

- **YC Slide Structure**: Title, Problem, Solution, Traction, Why Us/Now, Business Model, Market, Team, The Ask, Closing
- **Touying Integration**: Modern Typst presentation package with theme support
- **Design Principles**: Legibility, Simplicity, Obviousness (YC guidelines)

### Context Imports

Domain knowledge (load as needed):
- @.claude/context/project/present/patterns/pitch-deck-structure.md
- @.claude/context/project/present/patterns/touying-pitch-deck-template.md
