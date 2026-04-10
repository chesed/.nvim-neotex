# Epidemiology Extension

Epidemiology research and implementation support using R and related tooling. Covers statistical modeling, infectious disease dynamics (EpiModel), and Bayesian inference (epidemia/Stan).

## Overview

| Task Type | Agent | Purpose |
|-----------|-------|---------|
| `epidemiology` | epidemiology-research-agent | Study design, analysis planning, literature review |
| `epidemiology` | epidemiology-implementation-agent | R code implementation, statistical modeling, data analysis |

## Installation

Loaded via `<leader>ac` in Neovim. Once loaded, `epidemiology` (and `r` as an alias) become recognized task types.

## Commands

No dedicated commands. Use core `/research`, `/plan`, `/implement` with `task_type: "epidemiology"`.

## Skill-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-epidemiology-research | epidemiology-research-agent | Study design, analysis planning, literature review |
| skill-epidemiology-implementation | epidemiology-implementation-agent | R code implementation, statistical modeling |

## Language Routing

| Task Type | Research Tools | Implementation Tools |
|-----------|----------------|---------------------|
| `epidemiology` | rmcp, WebSearch, Read | Rscript, Read, Write, Edit |
| `r` | rmcp, WebSearch | Rscript, Read, Write |

## Domain Coverage

The research agent covers:
- **Infectious disease modeling**: SIR, SEIR, agent-based models
- **Survival analysis**: Cox proportional hazards, Kaplan-Meier
- **Bayesian inference**: Stan, `epidemia` package
- **Time-varying reproduction number**: `EpiEstim`, `EpiNow2`

## Key R Packages

| Package | Purpose |
|---------|---------|
| `EpiModel` | Mathematical modeling of infectious diseases |
| `epidemia` | Bayesian epidemic modeling using Stan |
| `EpiEstim` | Estimation of time-varying reproduction number |
| `EpiNow2` | Reproduction number and forecasting |
| `survival` | Survival analysis |
| `rstan` / `cmdstanr` | Stan interface for R |

## Context References

- `@.claude/extensions/epidemiology/context/project/epidemiology/README.md`
- `@.claude/extensions/epidemiology/context/project/epidemiology/tools/r-packages.md`

## References

- [EpiModel](https://www.epimodel.org/)
- [epidemia](https://imperialcollegelondon.github.io/epidemia/)
- [EpiEstim](https://mrc-ide.github.io/EpiEstim/)
- [Stan](https://mc-stan.org/)
