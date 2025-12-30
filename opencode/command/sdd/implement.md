---
description: Implement one planned task and validate
agent: sdd/forge
---

Execute an implementation plan for a single task.

## Usage

- `/sdd/implement <change-name> <NN>`

## Requirements

- `<NN>` required. Accept `1` or `01`.
- `changes/<change-name>/plans/<NN>.md` must exist.

## What to do (forge)

1. Verify `changes/<change-name>/state.md` exists.
2. Verify `changes/<change-name>/plans/<NN>.md` exists.
3. Delegate to `sdd/implementer` via `task`.

### Subtask prompt

Provide:
- change name
- task number string; instruct implementer to normalize
- key inputs:
  - `changes/<change-name>/tasks.md`
  - `changes/<change-name>/plans/<NN>.md`
- constraints:
  - keep repo green
  - implementer may edit repo code anywhere
  - implementer may mark only current task `<NN>` as `[x]`

4. On return, summarize what changed and point user to `changes/<change-name>/loops/implement-<NN>.md`.
