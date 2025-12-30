---
description: Initialize a bug fix (fast lane)
agent: sdd/forge
---

Initialize a bug fix SDD change set using the fast bug lane.

## Usage

- `/sdd/bug <change-name>`

## Requirements

- `<change-name>` is required.
- `<change-name>` must be a safe folder name (recommend kebab-case). Reject path separators.
- `changes/<change-name>/` must not already exist.

## When to Use

- Bug fixes
- Regression repairs
- Restoring documented behavior
- Critical production issues (use with auto mode for speed)

## What to do (forge)

### First Run (or when `Proposal.Status: draft`)

1. Create the folder structure (if not exists):
   - `changes/<change-name>/`
   - `changes/<change-name>/specs/`
   - `changes/<change-name>/thoughts/`
   - `changes/<change-name>/plans/`
   - `changes/<change-name>/loops/`

2. Create `changes/<change-name>/state.md` with:

```markdown
# SDD State: <change-name>

## Phase

proposal

## Lane

bug

## Run Mode

manual

## Current Task

none

## Proposal

- Status: draft

## Reconcile

- Required: yes
- Status: pending

## Pointers

- Proposal: `proposal.md`
- Specs: `specs/**`
- Discovery: `thoughts/**`
- Tasks: `tasks.md`
- Plans: `plans/**`

## Taxonomy Decisions


## Architecture Decisions


## Finish Status

not-ready

## Notes


```

3. Delegate to `sdd/proposer` with bug proposal schema:
   - Symptom (what's broken)
   - Expected vs Actual
   - Repro steps
   - Links (ticket, logs, screenshots)
   - Root-cause hypothesis (optional)
   - Risk/Rollback
   - Definition of Done

4. **STOP and ask user**: "Proposal ready. Approve and proceed? (yes/no)"
   - If user says no or wants changes: instruct them to edit `proposal.md` and rerun `/sdd/bug <change-name>`
   - If user says yes: proceed to "After Approval" steps below

### After Approval (when user approves)

5. Update `state.md`:
   - `Proposal.Status: approved`

6. Delegate to `sdd/quick-tasker` to generate `tasks.md` from proposal.

7. Delegate to `sdd/planner` to generate `plans/01.md`.

8. Update `state.md`:
   - `Phase: implementing`
   - `Current Task: 01`

9. Report:
   - Artifacts created: `state.md`, `proposal.md`, `tasks.md`, `plans/01.md`
   - Next command: `/sdd/implement <change-name> 01`
   - After implementation: `/sdd/reconcile <change-name>` → `/sdd/finish <change-name>`

10. If `Run Mode: auto`, proceed directly into `/sdd/implement <change-name> 01`.

## Auto Mode

To use auto mode:

1. Run `/sdd/bug <change-name>` — this creates the proposal
2. Review and refine `proposal.md` as needed
3. Edit `state.md` and set `Run Mode: auto`
4. When ready, approve the proposal (say "yes" or "approve")
5. System will then:
   - Generate tasks and plan
   - Proceed through implement with validation retry loop (max 20 cycles)
   - Stop before `/sdd/reconcile` (reconcile and finish are always manual)

**Key point**: Auto mode only kicks in *after* proposal approval. A change name alone is never enough.

## Why Specs Are Optional

Bug fixes typically restore *expected behavior* that should already be documented in specs. The reconcile phase validates whether the fix:
- Simply restored documented behavior (no spec changes needed)
- Introduced new behavior or capabilities (delta specs generated)
- Fixed an undocumented edge case (delta specs generated to document it)

## Differences from Full Lane

| Aspect | Full Lane | Bug Lane |
|--------|-----------|----------|
| Specs up front | Required | Not required |
| Discovery | Required | Skipped |
| Tasks derived from | Delta specs | Proposal (acceptance criteria) |
| Proposal approval | Required before specs | Required before tasks |
| Reconcile | Required | Required |
| Finish | Required | Required |
