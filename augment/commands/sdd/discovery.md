---
description: Review specs against existing architecture
argument-hint: <change-set-name>
---

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

Before evaluating architecture fit, **delegate to @librarian** to understand the codebase:

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

Use this framework to evaluate if delta specs fit the existing architecture:

**Primary Question:** Can an implementer translate these delta specs into the repo's current architecture with routine changes + small refactors?

#### Process

1. **Identify Constraints** based on research:
   - **Structural**: Module boundaries, dependency directions, layering rules
   - **Behavioral**: Error handling, state management, concurrency model
   - **Interface**: API contracts, extension points, data formats

2. **Evaluate Each Delta** against constraints:
   - Can it be implemented using existing patterns?
   - Does it require crossing boundaries in new ways?
   - Does it introduce new primitives the repo doesn't have?

3. **Check for Workaround Smell**:
   - Am I proposing adjustments that are really just hacks?
   - Would these adjustments create inconsistent patterns?

#### Verdicts

| Verdict | Choose When |
|---------|-------------|
| **FITS** | All constraints satisfied, changes follow existing patterns |
| **FITS_WITH_ADJUSTMENTS** | Minor violations fixable with targeted work |
| **NO_FIT** | Clean solution requires a new paradigm |

### Analyzing Findings

Based on verdict:

1. **FITS**: Proceed to tasks phase
2. **FITS_WITH_ADJUSTMENTS**: Document adjustments needed in proposal.md, then proceed
3. **NO_FIT**: Explore architecture options (see below)

### Architecture Workshop (if NO_FIT)

If architecture evaluation returns NO_FIT:

1. Tell user: "Architecture fit evaluation returned NO_FIT. Exploring architecture options."

2. **Generate Options**:
   - **Light-Touch**: New module boundary, adapter layer, small abstraction
   - **Architecture**: New eventing/pubsub, state machine, concurrency model change

3. **Evaluate Each Option**:
   - **Blast radius**: Which domains/components change
   - **Incremental path**: Can we keep repo green throughout?
   - **Long-term impact**: How this affects future changes

4. Document chosen approach in proposal.md
5. If architecture work affects specs, return to specs phase first

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
