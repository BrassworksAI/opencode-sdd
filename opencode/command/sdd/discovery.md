---
name: sdd/discovery
description: Review specs against existing architecture
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>research</skill>
<skill>architecture-fit-check</skill>

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

Before evaluating architecture fit, use the `research` skill to understand the codebase:

1. **Research to understand**:
   - Current architecture patterns in codebase
   - Code areas that will be affected by specs
   - Existing implementations of similar capabilities
   - Potential integration points and conflicts

2. **Build context** for architecture evaluation:
   - Document what you learned about architecture
   - Identify specific code areas specs will touch
   - Note any patterns that seem relevant

### Architecture Fit Evaluation

Using `architecture-fit-check` skill framework:

1. Identify architectural constraints that matter for this change
2. Evaluate each delta spec against those constraints
3. Check for workaround smell (are adjustments really just hacks?)
4. Determine verdict: FITS, FITS_WITH_ADJUSTMENTS, or NO_FIT

Document findings in format specified by skill.

### Analyzing Findings

Based on verdict:

1. **FITS**: Proceed to tasks phase
2. **FITS_WITH_ADJUSTMENTS**: Document adjustments needed in proposal.md, then proceed
3. **NO_FIT**: Load `architecture-workshop` skill and explore options

### Architecture Workshop (if NO_FIT)

If architecture evaluation returns NO_FIT:

1. Tell user: "Architecture fit evaluation returned NO_FIT. Loading architecture-workshop skill to explore options."
2. Use `architecture-workshop` skill framework to:
   - Generate light-touch and architecture options
   - Evaluate blast radius and incremental paths
   - Make a recommendation
3. Document chosen approach in proposal.md
4. If architecture work affects specs, return to specs phase first

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
