---
name: sdd-state-management
description: SDD state tracking - phases, gates, lanes, and TOML-based state management
---

# SDD State Management

This skill covers how SDD tracks change set state and enforces phase gates using TOML files and CLI commands.

## State File

Every change set has a state file at `changes/<name>/state.toml`:

```toml
[change]
name = "my-feature"
lane = "full"  # full | vibe | bug
created_at = 2026-01-27T10:00:00Z

[phase]
current = "plan"
status = "in_progress"  # in_progress | complete | blocked

[pending]
items = [
  "Waiting on API design decision"
]

[notes]
content = """
Working through auth endpoint design.
Decided to use JWT over sessions.
"""
```

## Tasks File

Tasks are stored in `changes/<name>/tasks.toml`:

```toml
[task.db-models]
title = "Foundation - DB models and migrations"
description = "Add user tables and migrations."
status = "complete"  # pending | in_progress | complete
requirements = [
  "When a new user is created, the system shall persist profile fields."
]

[task.auth-endpoint]
title = "Auth endpoint implementation"
description = "Build the authentication REST endpoint."
status = "in_progress"
requirements = [
  "WHEN the user submits credentials the system SHALL validate them."
]
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `ae sdd init <name> --lane <full\|vibe\|bug>` | Create change set with state.toml |
| `ae sdd status [name]` | Show styled status UI |
| `ae sdd phase next` | Advance to next phase |
| `ae sdd phase set <phase>` | Set current phase |
| `ae sdd task list` | List all tasks |
| `ae sdd task add <short-name>` | Add new task |
| `ae sdd task start <short-name>` | Start a task |
| `ae sdd task complete <short-name>` | Complete a task |
| `ae sdd pending add "item"` | Add pending item |
| `ae sdd pending clear <index>` | Remove pending item |
| `ae sdd notes set "content"` | Update notes |

## Lanes Overview

| Lane | Purpose | Flow |
|------|---------|------|
| **Full** | Enterprise features, architectural changes | Proposal (external doc) → Specs → Discovery → Tasks → Plan → Implement → Reconcile → Finish |
| **Vibe** | Rapid prototypes, exploration | Context → Plan → Implement → [Reconcile → Finish] |
| **Bug** | Fix defects | Triage + Research → Plan → Implement → [Reconcile → Finish] |

## Full Lane

The complete SDD experience. Specs are written before implementation.

### Phases

```text
proposal -> specs -> discovery -> tasks -> plan -> implement -> reconcile -> finish
```

Proposal artifacts can be authored outside SDD. The state file just tracks the phase and SDD reads `proposal.md` when present.

| Phase | Purpose | Artifacts |
|-------|---------|-----------|
| `init` | Change set initialization | N/A |
| `proposal` | Define what we're building | `proposal.md` |
| `specs` | Write detailed specifications | `specs/**/*.md` (change-set specs: `kind: new|delta`) |
| `discovery` | Understand high-level architecture needs | `thoughts/*.md` |
| `tasks` | Break specs into tasks | `tasks.md` |
| `plan` | Plan current task | `plans/NN.md` |
| `implement` | Execute the plan | Code changes |
| `reconcile` | Verify implementation matches specs | Reconciliation report |
| `finish` | Close and sync specs | `kind: new` moved; `kind: delta` merged into canonical |

### Phase Gates

| From | To | Gate |
|------|----|------|
| init | proposal | Initialization complete |
| proposal | specs | Proposal approved |
| specs | discovery | Change-set specs written (`kind: new|delta`) |
| discovery | tasks | Architecture review complete |
| tasks | plan | Tasks defined |
| plan | implement | Plan approved |
| implement | reconcile | All tasks complete |
| reconcile | finish | Implementation matches specs |

## Vibe Lane

Freedom to explore. Skip specs, get to building fast.

### Flow (Vibe lane)

```text
/sdd/fast/vibe <context>  →  /sdd/plan  →  /sdd/implement  →  [/sdd/reconcile  →  /sdd/finish]
```

### Artifacts (Vibe lane)

| File | Purpose |
|------|---------|
| `state.md` | Phase and lane tracking |
| `context.md` | Loose capture of what we're exploring |
| `plan.md` | Combined research + planning (single file) |

### Optional Completion (Vibe lane)

Reconcile and finish are optional:

- **Throwing it away**: Stop after implement
- **Keeping it**: Reconcile captures specs from implementation, finish syncs to canonical

## Bug Lane

Hunt and fix. Triages the issue first.

### Flow (Bug lane)

```text
/sdd/fast/bug <context>  →  /sdd/plan  →  /sdd/implement  →  [/sdd/reconcile  →  /sdd/finish]
```

### Triage

The bug command determines if this is:

- **Actual bug**: Implementation doesn't match intent → proceed with bug lane
- **Behavioral change**: User wants different behavior → redirect to full lane with specs

### Artifacts (Bug lane)

| File | Purpose |
|------|---------|
| `state.md` | Phase and lane tracking |
| `context.md` | Bug details, root cause, fix approach |
| `plan.md` | Combined research + planning |
| `thoughts/` | Optional scratch space for complex investigations |

### Optional Completion (Bug lane)

Reconcile and finish are optional:

- **No spec impact**: Stop after implement (most bug fixes)
- **Specs affected**: Reconcile captures changes, finish syncs

## Thoughts Directory

For complex investigations, use `thoughts/` as a free-form workspace:

```text
changes/<name>/
  thoughts/
    investigation.md
    options.md
```

Purpose: Document thinking so users can continue in a new chat with full context.

## Pending Semantics

`## Pending` is a ledger of **unresolved** items:

- Contains only unresolved items (blockers, decisions needed)
- Remove items when resolved (don't strike through)
- Leave it blank when nothing is pending
- Deferred ideas go elsewhere (e.g., `docs/future-capabilities.md`)

`## Pending` is NOT an approval log. Do not record approvals there.

## Flexible Phase Management

Phase transitions are guided but not rigid. Users can skip phases or jump ahead if needed.

### Core Principles

- **Flexible flow**: The phase sequence is a guide, not a strict process. Users can skip phases or jump ahead.
- **User intent first**: When users run a command, assume they know what they're doing. Provide guidance but don't block.
- **Smart but not controlling**: Suggest the right path, warn about skipped phases, confirm major jumps, but ultimately follow the user's lead.

### Entry Check Logic

When a command is invoked, check the current state and handle appropriately:

1. **Natural progression** (previous phase is `complete`):
   - Update state.md: `## Phase` → current command's phase, `## Phase Status: in_progress`
   - Proceed with command

2. **Jumping forward across multiple phases**:
   - Show: "Skipping over [phase1, phase2] - are you sure?"
   - If confirmed: Update state.md to this phase, set `## Phase Status: in_progress`

3. **Going back to a previous phase**:
   - Show: "Moving back to [phase] - this will reset its status to in_progress"
   - If confirmed: Update state.md to that phase, set `## Phase Status: in_progress`

4. **Same phase already complete**:
   - Show: "This phase is complete - do you want to re-enter it?"
   - If confirmed: Set `## Phase Status: in_progress`

5. **Same phase in_progress** or first run:
   - Continue with command (natural continuation)

### Command Completion

When a command completes (user approves work):

- Set `## Phase Status: complete`
- Clear `## Notes` to empty string
- Do NOT advance to next phase - next command will handle that

### Keeping Notes Updated

During command execution, keep `## Notes` updated with:

- Decisions made
- Current progress
- Context about where we are
- Blockers or issues encountered

Notes are meant to capture state so work can be resumed later or in a new chat. They should be concise but informative.
