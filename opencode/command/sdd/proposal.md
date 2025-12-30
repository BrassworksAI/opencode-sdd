---
description: Draft or revise the proposal for a change
agent: sdd/forge
---

Draft or revise `changes/<change-name>/proposal.md`.

## Usage

- `/sdd/proposal <change-name>`

## What to do (forge)

1. Verify `changes/<change-name>/state.md` exists.
2. Verify phase gate allows proposal (phase is `initialized` or later).
3. Delegate to `sdd/proposer` via `task`.

### Subtask prompt

Provide:
- change name
- lane (from state.md) — determines which proposal schema to use
- relevant files:
  - `changes/<change-name>/state.md`
  - `changes/<change-name>/proposal.md` (if exists)
  - `changes/<change-name>/loops/proposal.md` (if exists)
- the user feedback contract: revise if `## User Feedback` is non-empty
- bounded critique loop using `archimedes`

4. On return, report what was created and ask for **explicit approval**:

```
Review `proposal.md` and respond:
- **approve** — Proceed to next phase
- **feedback** — Edit `## User Feedback` in proposal.md and rerun `/sdd/proposal`
```

5. **Do NOT proceed to downstream phases** until user explicitly approves.

6. When user approves (responds "approve", "yes", "looks good", etc.):
   - Update `state.md`: set `Proposal.Status: approved`
   - Report the next command (`/sdd/specs` for full lane)

## Approval Gate

The proposal is a collaboration checkpoint. A change name alone is never enough — the proposer researches, asks questions, and drafts a proposal that the user must review and approve.

`Proposal.Status` in state.md tracks this:
- `draft` — Created but awaiting user approval
- `approved` — User has approved; downstream phases can proceed
