---
name: sdd/discovery
description: Review specs against existing architecture
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>counsel</skill>
<skill>research</skill>

# Discovery

Review delta specs against existing repository architecture.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `discovery` and lane is `full`
2. Read all delta specs from `changes/<name>/specs/`
3. Read `changes/<name>/proposal.md` for context

### Research Phase (Critical)

Before consulting Steward, **research the codebase** using the `research` skill:

1. **Consult librarian** to understand:
   - Current architecture patterns in the codebase
   - Code areas that will be affected by the specs
   - Existing implementations of similar capabilities
   - Potential integration points and conflicts

2. **Build context** for Steward:
   - Document what you learned about the architecture
   - Identify specific code areas the specs will touch
   - Note any patterns that seem relevant

### Consulting Steward

With research in hand, consult Steward for architecture fit:

> Use Task tool with `sdd/steward` agent.
> Provide: delta specs summary, research findings about current architecture
> Ask for: fit assessment, conflicts with existing patterns, integration concerns

### Analyzing Findings

Review Steward's findings:

1. **Fits well**: Proceed to tasks
2. **Minor concerns**: Document mitigations, proceed
3. **Major conflicts**: Either revise specs or consult Daedalus

### Consulting Daedalus (if needed)

If existing patterns don't fit:

> Use Task tool with `sdd/daedalus` agent.
> Provide: the conflict/problem, why existing patterns fail, research findings
> Ask for: proposed new mechanism or structural approach

### Updating Specs

If discovery reveals spec issues:
- Return to specs phase
- Update delta specs
- Re-run discovery

### Completion

When architecture review passes:

1. Update state.md phase to `tasks`
2. Document any architectural decisions in proposal.md
3. Suggest running `/sdd/tasks <name>`
