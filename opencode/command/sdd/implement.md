---
name: sdd/implement
description: Execute the implementation plan
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>research</skill>

# Implement

Execute the current implementation plan.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `implement`
2. Determine lane and load plan:
   - **Full lane**: Read `changes/<name>/tasks.md` to find current in_progress task, then read corresponding plan from `changes/<name>/plans/`
   - **Vibe/Bug lane**: Read `changes/<name>/plan.md` (single combined plan)

### Implementation Process

Execute the plan step by step:

1. **Follow the plan**: The plan was created for a reason - follow it
2. **Validate as you go**: Run tests/checks after each significant change
3. **Keep the repo green**: Don't leave broken state
4. **Document deviations**: If you must deviate from plan, note why

### Research During Implementation

If you encounter unexpected situations, use the `research` skill:

- **Unexpected code structure**: Investigate to understand it
- **Need to understand a dependency**: Research how it works
- **Unclear integration**: Research before guessing

Don't guess when you can research. But also don't over-research - the plan should have captured the major research needs.

### Handling Issues

If implementation reveals plan problems:

- **Minor adjustments**: Proceed, document deviation in plan
- **Major issues**: Stop, discuss with user, potentially re-plan
- **Spec issues (full lane)**: Flag for reconciliation (don't modify specs during implement)

### Validation

After implementation:

1. Run validation steps from plan
2. Verify acceptance criteria are met
3. Ensure tests pass

### Completion

**Full Lane:**
1. Mark current task `complete` in tasks.md
2. Check if more tasks remain:
   - **More tasks**: Update state to `plan`, suggest `/sdd/plan <name>`
   - **All complete**: Update state to `reconcile`, suggest `/sdd/reconcile <name>`

**Vibe/Bug Lane:**
1. Implementation is complete with the single plan
2. User decides next step:
   - **Throwing away**: Done - no further action needed
   - **Keeping the work**: Update state to `reconcile`, suggest `/sdd/reconcile <name>`

> **Note**: For vibe/bug lanes, reconcile is optional. If the work is exploratory or a quick fix that doesn't warrant spec updates, stopping here is perfectly valid.

