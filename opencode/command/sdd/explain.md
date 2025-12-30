---
description: Explain the SDD workflow and how to use it
agent: sdd/forge
---

Explain the Spec-Driven Development workflow.

## Usage

- `/sdd/explain` — full workflow overview
- `/sdd/explain <phase>` — explain a specific phase

## Supported Phases

- `init` — initializing a change set
- `proposal` — capturing problem statement and intent
- `specs` — writing delta specs
- `discovery` — architecture fit review
- `tasks` — breaking specs into work units
- `plan` — detailed implementation planning
- `implement` — executing the plan
- `sync` — merging deltas into canonical specs

## What to do (forge)

Handle this directly (no delegation).

### Full Overview (no argument)

Output the complete SDD workflow explanation as defined in forge's `/sdd/explain` section:
- The pipeline diagram
- What each phase produces
- How feedback works
- Quick start instructions
- Example artifact summaries

### Phase-Specific (with argument)

Output detailed explanation for just that phase:
- What it does
- What artifacts it produces
- How to run it
- What to review afterward
- How to provide feedback

Keep output scannable and practical. This is onboarding material.
