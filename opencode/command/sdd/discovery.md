---
description: Perform principal-level fit review for the change specs
agent: sdd/forge
---

Produce discovery/fit review notes for the generated delta specs.

## Usage

- `/sdd/discovery <change-name>`

## What to do (forge)

1. Verify `changes/<change-name>/state.md` exists.
2. Enforce gate: phase must be `specs` or later.
3. Delegate to `sdd/discoverer` via `task`.

### Subtask prompt

Provide:
- change name
- key inputs:
  - `changes/<change-name>/specs/**`
  - prior `changes/<change-name>/thoughts/**` (if exists)
- constraints:
  - artifact-only writes (only under `changes/<change-name>/`)
  - bounded critique loop with `archimedes`

4. On return, point the user to review `changes/<change-name>/thoughts/**`.
5. If discoverer reports `NEEDS_USER_DECISION`, inform the user they must choose a path before proceeding.
