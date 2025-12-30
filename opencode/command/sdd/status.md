---
description: Show SDD phase/task status and next command
agent: sdd/forge
---

Summarize workflow status for a change.

## Usage

- `/sdd/status <change-name>`

## What to do (forge)

Read state and report concisely. No delegation needed.

1. Read `changes/<change-name>/state.md`.
2. Extract: Lane, Phase, Run Mode, Proposal.Status, Reconcile.Status
3. If present, read `changes/<change-name>/tasks.md` and count:
   - `[x]` = completed
   - `[-]` = in progress (current task)
   - `[ ]` = pending
4. Determine next command based on lane, phase, and proposal status.

### Output Format

```
<change-name> | <lane> | Phase: <phase>
Proposal: <draft|approved> | Reconcile: <pending|complete>
Current task: <NN or none> | Remaining: <N>
Next: <recommended command>
```

Keep it to 3-4 lines. No prose. Just state and recommendation.

### Next Command Logic

**If `Proposal.Status: draft`** (any lane):
- Next: "Review proposal.md and reply 'approve' to proceed"

**Full Lane** (after proposal approved):

| Phase | Next Command |
|-------|--------------|
| (no folder) | `/sdd/init <change-name>` |
| initialized | `/sdd/brainstorm <change-name>` or `/sdd/proposal <change-name>` |
| ideation | `/sdd/continue <change-name>` (iterate) or tell ideator to write seed |
| proposal | `/sdd/specs <change-name>` |
| specs | `/sdd/discovery <change-name>` |
| discovery | `/sdd/tasks <change-name>` |
| tasks | `/sdd/plan <change-name> <NN>` (first `[ ]` task) |
| planning | `/sdd/implement <change-name> <NN>` |
| implementing (tasks remain) | `/sdd/plan <change-name> <NN>` (next `[ ]` task) |
| implementing (all `[x]`) | `/sdd/reconcile <change-name>` |
| reconciling | `/sdd/finish <change-name>` |

**Bug/Quick Lane** (after proposal approved):

| Phase | Next Command |
|-------|--------------|
| proposal | "Reply 'approve' to proceed to tasking" |
| implementing (tasks remain) | `/sdd/implement <change-name> <NN>` |
| implementing (all `[x]`) | `/sdd/reconcile <change-name>` |
| reconciling | `/sdd/finish <change-name>` |
