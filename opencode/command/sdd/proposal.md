---
name: sdd/proposal
description: Draft and refine the change proposal
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>counsel</skill>
<skill>research</skill>

# Proposal

Draft and refine the proposal document for a change set.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `proposal` (or `ideation` transitioning)
2. Read `changes/<name>/seed.md` if exists (for context)
3. Read `changes/<name>/proposal.md` if exists

### Research Phase (Recommended)

For non-trivial proposals, **research** using the `research` skill:

1. **Consult librarian** to understand:
   - Does similar functionality already exist?
   - What would this change interact with?
   - Are there existing patterns or constraints to respect?

2. **Inform the proposal** with findings:
   - Reference existing code/patterns in approach
   - Note integration points
   - Identify potential risks based on codebase structure

### Lane Selection

If lane not yet selected, determine with user:

| Lane | When to Use |
|------|-------------|
| `full` | New capabilities, architectural changes, complex features |
| `quick` | Small enhancements to existing capabilities |
| `bug` | Fixing incorrect behavior |

Update state.md with selected lane.

### Proposal Content

Proposals are **freeform** - capture intent in whatever structure works. Common elements:

- **Problem**: What problem are we solving?
- **Goals**: What does success look like?
- **Non-Goals**: What are we explicitly NOT doing?
- **Approach**: High-level solution direction
- **Risks**: What could go wrong?
- **Definition of Done**: How do we know we're finished?

For **bug lane**, also include:
- **Current Behavior**: What's happening now
- **Expected Behavior**: What should happen
- **Reproduction Steps**: How to see the bug

For **quick lane**, keep it lightweight - just enough to understand the change.

### Consulting Archimedes

For full lane proposals, consult Archimedes for analytical critique:

> Use Task tool with `archimedes` agent.
> Provide: proposal content
> Ask for: contradictions, gaps, risk assessment, verdict

Address any FAIL findings before proceeding.

### Consulting Loki

After Archimedes, consult Loki for scenario validation:

> Use Task tool with `sdd/loki` agent.
> Provide: proposal content
> Ask for: persona, journey through a realistic task, gaps/friction/wins, verdict

Loki tests from the inside — inhabiting a user to see if the proposal holds up under realistic demands. Address blocking issues before proceeding; note friction points for consideration.

### Completion

When proposal is approved:

1. Update state.md phase:
   - Full lane: `specs`
   - Quick/Bug lane: `tasks`
2. Suggest next command based on lane
