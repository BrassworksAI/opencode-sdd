---
description: Resume work on an existing change set
argument-hint: <change-set-name>
---

# Continue

Resume work on an existing change set.

## Arguments

- `$ARGUMENTS` - Change set name (optional - will list if not provided)

## Instructions

### No Arguments

If no name provided, list active change sets by finding all `changes/*/state.md` files.

For each, show: name, phase, lane, any pending items.

### With Arguments

1. Read `changes/<name>/state.md`
2. Understand current state
3. Route to appropriate phase command

### Phase Routing

| Phase | Suggested Action |
|-------|------------------|
| `ideation` | Continue brainstorming or `/sdd/proposal` |
| `proposal` | Continue refining or advance to next phase |
| `specs` | Continue writing specs or `/sdd/discovery` |
| `discovery` | Review findings or `/sdd/tasks` |
| `tasks` | Review tasks or `/sdd/plan` |
| `plan` | Review plan or `/sdd/implement` |
| `implement` | Continue implementation |
| `reconcile` | Continue reconciliation or `/sdd/finish` |
| `finish` | Complete the finish process |
| `complete` | Change set is done, no action needed |

### Context Loading

Before suggesting actions, load relevant context:

- Read proposal.md for problem/goals context
- Read tasks.md if in task-related phase
- Read current plan if in plan/implement phase
- Check for any pending items in state.md
