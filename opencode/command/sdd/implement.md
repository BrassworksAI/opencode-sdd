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
2. Read `changes/<name>/tasks.md` - find current in_progress task
3. Read corresponding plan from `changes/<name>/plans/`

### Implementation Process

Execute the plan step by step:

1. **Follow the plan**: The plan was created for a reason - follow it
2. **Validate as you go**: Run tests/checks after each significant change
3. **Keep the repo green**: Don't leave broken state
4. **Document deviations**: If you must deviate from plan, note why

### Research During Implementation

If you encounter unexpected situations, use the `research` skill:

- **Unexpected code structure**: Consult librarian to understand it
- **Need to understand a dependency**: Ask librarian how it works
- **Unclear integration**: Research before guessing

Don't guess when you can research. But also don't over-research - the plan should have captured the major research needs.

### Handling Issues

If implementation reveals plan problems:

- **Minor adjustments**: Proceed, document deviation in plan
- **Major issues**: Stop, discuss with user, potentially re-plan
- **Spec issues**: Flag for reconciliation (don't modify specs during implement)

### Validation

After implementation:

1. Run validation steps from plan
2. Verify acceptance criteria are met
3. Ensure tests pass

### Task Completion

When task is complete:

1. Mark task `complete` in tasks.md
2. Check if more tasks remain:
   - **More tasks**: Update state to `plan`, suggest `/sdd/plan <name>`
   - **All complete (full lane)**: Update state to `reconcile`, suggest `/sdd/reconcile <name>`
   - **All complete (quick/bug lane)**: Update state to `finish`, suggest `/sdd/finish <name>`
