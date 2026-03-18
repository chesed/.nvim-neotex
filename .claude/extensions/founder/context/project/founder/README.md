# Founder Context

Strategic business analysis context for founders and entrepreneurs.

## Overview

This context directory provides domain knowledge, decision frameworks, and templates for strategic business analysis. Inspired by Y Combinator office hours methodology and CEO cognitive patterns from gstack.

## Directory Structure

```
founder/
├── README.md              (this file)
├── domain/                Domain knowledge and frameworks
│   ├── business-frameworks.md    TAM/SAM/SOM, business model canvas
│   └── strategic-thinking.md     CEO patterns, YC principles
├── patterns/              Reusable analysis patterns
│   ├── forcing-questions.md      Question framework for specificity
│   ├── decision-making.md        Two-way doors, inversion, focus
│   └── mode-selection.md         Operational modes pattern
└── templates/             Artifact templates
    ├── market-sizing.md          TAM/SAM/SOM analysis template
    ├── competitive-analysis.md   Competitor landscape template
    └── gtm-strategy.md           Go-to-market strategy template
```

## Key Concepts

### Forcing Questions

One question per interaction, push for specificity. Vague answers are not accepted.

**The Six Forcing Questions**:
1. **Demand Reality**: What evidence proves someone wants this?
2. **Status Quo**: What do users do today to solve this?
3. **Desperate Specificity**: Name one specific person who needs this
4. **Narrowest Wedge**: What's the smallest version someone would pay for?
5. **Observation**: What surprised you watching someone use this?
6. **Future-Fit**: Does your product become more essential over time?

### Decision Frameworks

- **Two-Way Doors**: Reversible decisions - move fast, 70% information
- **One-Way Doors**: Irreversible decisions - be rigorous, 90% information
- **Inversion**: Ask both "How do we win?" and "What makes us fail?"
- **Focus as Subtraction**: Document what NOT to do

### Operational Modes

Commands offer 3-4 modes giving users explicit scope control:
- Selection happens early in interaction
- All subsequent analysis adapts to mode
- Mode switches are explicit and confirmed

## Related Commands

| Command | Context Used | Purpose |
|---------|--------------|---------|
| `/market` | domain/, patterns/forcing-questions, templates/market-sizing | Market sizing analysis |
| `/analyze` | domain/, patterns/forcing-questions, templates/competitive-analysis | Competitive analysis |
| `/strategy` | domain/, patterns/, templates/gtm-strategy | GTM strategy development |

## Usage

Context files are loaded by founder extension agents via @-references:

```markdown
Load market sizing context:
@.claude/extensions/founder/context/project/founder/domain/business-frameworks.md
@.claude/extensions/founder/context/project/founder/templates/market-sizing.md
```

Index entries in `index-entries.json` enable automatic context discovery based on agent, language, or command.

## References

- [gstack (Garry Tan)](https://github.com/garrytan/gstack)
- [YC Library](https://www.ycombinator.com/library)
- [Paul Graham Essays](http://paulgraham.com/articles.html)
- [Business Model Canvas](https://www.strategyzer.com/canvas/business-model-canvas)
