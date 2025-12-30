---
description: Generate or reconcile tasks.md for a change
agent: sdd/forge
---

Break delta specs into committable tasks.

## Usage

- `/sdd/tasks <change-name>`

## What to do (forge)

1. Verify `changes/<change-name>/state.md` exists.
2. Enforce gate: phase must be `discovery` or later.
3. If `changes/<change-name>/tasks.md` exists and contains any `[-]` or `[x]`, ask the user before overwriting.
4. Delegate to `sdd/tasker` via `task`.

### Subtask prompt

Provide:
- change name
- key inputs:
  - `changes/<change-name>/specs/**`
  - `changes/<change-name>/thoughts/**` (discovery constraints are binding for task ordering)
  - existing `changes/<change-name>/tasks.md` (if exists)
- constraints:
  - artifact-only writes
  - dependency-ordered tasks; repo stays green
  - bounded critique loop with `archimedes`

5. On return, point the user to review `changes/<change-name>/tasks.md`.
