---
name: sdd-state-management
description: SDD state tracking - phases, gates, lanes, and state.md structure
---

# SDD State Management

This skill covers how SDD tracks change set state and enforces phase gates.

## State File

Every change set has a state file at `changes/<name>/state.md`:

```markdown
# SDD State: <name>

## Phase

<current-phase>

## Lane

<full|quick|bug>

## Pending

- <any blocked items or decisions needed>
```

## Phases

### Full Lane Phases

```
ideation -> proposal -> specs -> discovery -> tasks -> plan -> implement -> reconcile -> finish
```

| Phase | Purpose | Artifacts Created |
|-------|---------|-------------------|
| `ideation` | Explore problem space | `seed.md` |
| `proposal` | Define what we're building | `proposal.md` |
| `specs` | Write detailed specifications | `specs/*.md` (delta specs) |
| `discovery` | Review specs against existing architecture | Discovery notes in proposal |
| `tasks` | Break specs into implementation tasks | `tasks.md` |
| `plan` | Create implementation plan for current task | `plans/NN.md` |
| `implement` | Execute the plan | Code changes |
| `reconcile` | Verify implementation matches specs | Reconciliation report |
| `finish` | Close change set, sync delta specs | Specs synced to canonical |

### Quick Lane Phases

```
proposal -> tasks -> plan -> implement -> finish
```

For small enhancements that don't need full spec treatment. Skips: ideation, specs, discovery, reconcile.

### Bug Lane Phases

```
proposal -> tasks -> plan -> implement -> finish
```

For bug fixes. Same as quick lane. Proposal documents the bug and fix approach.

## Phase Gates

Gates prevent advancing until prerequisites are met:

| From | To | Gate Condition |
|------|----|----------------|
| ideation | proposal | Seed reviewed and approved |
| proposal | specs | Proposal reviewed and approved |
| specs | discovery | All delta specs written |
| discovery | tasks | Architecture review complete |
| tasks | plan | Tasks defined with requirements |
| plan | implement | Plan approved for current task |
| implement | reconcile | All tasks complete |
| reconcile | finish | Implementation matches specs |

## Updating State

### Pending semantics (ledger rule)

`## Pending` is a working ledger of **unresolved** questions, decisions, or blockers needed to continue work (especially after a break / new chat).

Rules:
- `## Pending` MUST contain **only** items that are still unresolved.
- When a pending item is resolved, it MUST be **removed** from the list (do not mark it "done", do not strike it through).
- Deferred/non-blocking ideas MUST NOT go in `## Pending`; put them in an explicit future/deferred document (e.g., `docs/future-capabilities.md`).

When transitioning phases, update `state.md`:

```markdown
## Phase

tasks  # was: specs
```

Add pending items when blocked:

```markdown
## Pending

- Waiting for Steward review of auth changes
- Need clarification on error handling approach
```

## Lane Selection

Choose lane at proposal time based on scope:

| Scope | Lane | When to Use |
|-------|------|-------------|
| Large feature | `full` | New capabilities, architectural changes |
| Small enhancement | `quick` | Adding to existing capability, minor features |
| Bug fix | `bug` | Fixing incorrect behavior |

Lane is recorded in state and cannot change mid-flight.

## State Queries

To check current state: read `changes/<name>/state.md`

To list all active change sets: `ls changes/*/state.md`

To find change sets in a specific phase: grep for `## Phase` followed by phase name
