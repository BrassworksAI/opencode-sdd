---
name: sdd/specs
description: Write delta specifications for the change
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>spec-format</skill>
<skill>counsel</skill>
<skill>research</skill>

# Specs

Write delta specifications for the change set.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `specs` and lane is `full`
2. Read `changes/<name>/proposal.md` for context
3. List existing `specs/` structure to understand current taxonomy

### Research Phase

Before writing specs, **research** using the `research` skill:

1. **Consult librarian** to understand:
   - Current spec structure and taxonomy
   - Related existing capabilities
   - How similar things are specified

2. **Build context** for spec writing:
   - What specs already exist in related areas
   - What naming conventions are used

### Consulting Cartographer

With research in hand, consult Cartographer:

> Use Task tool with `sdd/cartographer` agent.
> Provide: proposal summary, current specs/ structure, research findings
> Ask for: recommended paths for new capabilities, taxonomy placement

### Writing Delta Specs

Create specs in `changes/<name>/specs/` following the `spec-format` skill:

1. **Identify capabilities** needed from the proposal
2. **Determine paths** using Cartographer's guidance
3. **Write requirements** using EARS syntax

### Spec Review

For each spec file:
- Ensure requirements are atomic (one SHALL per requirement)
- Ensure requirements are testable
- Ensure requirements are implementation-agnostic
- Ensure requirements use appropriate EARS patterns

### Consulting Archimedes

When specs are complete, consult Archimedes:

> Use Task tool with `archimedes` agent.
> Provide: all delta specs
> Ask for: completeness check, contradiction detection, missing edge cases

### Completion

When specs pass review:

1. Update state.md phase to `discovery`
2. Suggest running `/sdd/discovery <name>`
