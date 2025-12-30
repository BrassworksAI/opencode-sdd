---
description: Create or revise an implementation plan for one task
agent: sdd/forge
---

Create a detailed plan for a single task.

## Usage

- `/sdd/plan <change-name> <NN>`

## Requirements

- `<NN>` required. Accept `1` or `01`.

## What to do (forge)

1. Verify `changes/<change-name>/state.md` exists.
2. Enforce gate: phase must be `tasks` or later.
3. Delegate to `sdd/planner` via `task`, passing `<NN>`.

### Subtask prompt

Provide:
- change name
- task number string as provided; instruct planner to normalize to `01` form
- key inputs:
  - `changes/<change-name>/tasks.md`
  - `changes/<change-name>/specs/**`
  - `changes/<change-name>/thoughts/**` (discovery constraints are binding)
  - existing `changes/<change-name>/plans/<NN>.md` (if exists)
- constraints:
  - artifact-only writes
  - bounded critique loop with `archimedes` (max 4 for planner)
  - discovery constraints from `thoughts/**` are binding

4. On return, point user to review `changes/<change-name>/plans/<NN>.md`.
