---
description: Close the change set and sync delta specs to canonical (if any)
agent: sdd/forge
---

Close the change set. If delta specs exist, sync them to canonical. Delete the change folder.

## Usage

- `/sdd/finish <change-name>`

## Requirements

- `<change-name>` is required.
- `changes/<change-name>/` must exist.
- All tasks in `tasks.md` must be marked `[x]` complete.
- `Reconcile.Status` must be `complete`.

## Why Finish Replaced Sync

`/sdd/finish` is now the mandatory pre-PR command for all lanes:

1. **Reconcile gate**: Finish enforces that reconcile completed first.
2. **Conditional sync**: Finish only runs sync if delta specs exist.
3. **Clean closure**: Finish handles the full cleanup consistently across lanes.

## What to do (forge)

1. Verify preconditions:
   - All tasks in `tasks.md` are `[x]`
   - `Reconcile.Status: complete`

2. If preconditions fail:
   - If tasks incomplete: "Complete all tasks first."
   - If reconcile not complete: "Run `/sdd/reconcile <change-name>` first to validate specs match implementation."

3. Delegate to `sdd/finisher` with:

**Mission**: Close the change set. Sync delta specs to canonical if they exist. Delete the change folder.

**Inputs**:
- `changes/<change-name>/state.md`
- `changes/<change-name>/specs/**` (delta specs, if any)
- `changes/<change-name>/glossary.md` (delta glossary, if any)
- `docs/specs/**` (canonical specs)
- `docs/glossary.md` (canonical glossary)

**Outputs**:
- `changes/<change-name>/loops/finish.md`
- `docs/specs/**` (updated if delta specs existed)
- `docs/glossary.md` (updated if glossary delta existed)
- Delete `changes/<change-name>/` on success

4. Report:
   - Whether sync was run (if delta specs existed)
   - What canonical specs were updated
   - Confirmation that change folder was deleted
   - Next: Open PR / merge to main

## Finish Outcomes

### With Delta Specs

1. Run deterministic sync algorithm
2. Merge delta specs into `docs/specs/**`
3. Merge glossary delta into `docs/glossary.md` (if exists)
4. Ask user to confirm deletion of change folder
5. Delete `changes/<change-name>/`

### Without Delta Specs

1. No canonical changes needed
2. Ask user to confirm deletion of change folder
3. Delete `changes/<change-name>/`

## User Confirmation

Before deleting the change folder, ask:

> Ready to delete `changes/<change-name>/`? This cannot be undone.
> - Delta specs synced: yes/no
> - Canonical specs updated: [list of files]
> 
> Confirm deletion? (yes/no)

## After Finish

The change is complete:
- Canonical specs in `docs/specs/**` reflect the implementation
- Change artifacts under `changes/<change-name>/` are removed
- Ready to open PR or merge to main
