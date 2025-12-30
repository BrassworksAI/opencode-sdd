---
description: Generate or revise delta specs for a change
agent: sdd/forge
---

Generate or revise delta specs under `changes/<change-name>/specs/**`.

## Usage

- `/sdd/specs <change-name>`

## What to do (forge)

1. Verify `changes/<change-name>/state.md` exists.
2. Enforce gate: phase must be `proposal` or later.
3. Delegate to `sdd/specsmith` via `task`.

### Subtask prompt

Provide:
- change name
- key inputs:
  - `changes/<change-name>/proposal.md`
  - existing `docs/specs/**` (if present)
- constraints:
  - artifact-only writes (only under `changes/<change-name>/`)
  - follow delta spec format (load `skill("sdd-delta-format")`)
  - consult `librarian` and `sdd/cartographer` as needed
  - bounded critique loop with `archimedes`
  - end every produced file with pinned `## User Feedback`

4. On return, point the user to review `changes/<change-name>/specs/**`.
