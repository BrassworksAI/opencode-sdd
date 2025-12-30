---
description: Validate that implementation matches canonical specs
agent: sdd/forge
---

Validate that implementation matches canonical specs; generate delta specs if drift occurred.

## Usage

- `/sdd/reconcile <change-name>`

## Requirements

- `<change-name>` is required.
- `changes/<change-name>/` must exist.
- All tasks in `tasks.md` must be marked `[x]` complete.
- Phase must be `implementing` or later.

## Why Reconcile Is Required

Every lane (full, bug, quick) requires reconcile before finish because:

1. **Implementation can drift**: Even well-planned implementations may introduce behavior not in the original specs.
2. **Capability discovery**: Bug fixes and quick experiments often reveal capabilities that should be documented.
3. **Spec-adjacency**: Reconcile ensures the canonical specs remain the source of truth for what the system does.

## What to do (forge)

1. Verify preconditions:
   - All tasks in `tasks.md` are `[x]`
   - Phase is `implementing` or later

2. Delegate to `sdd/reconciler` with:

**Mission**: Validate that implementation matches canonical specs. Generate delta specs if drift occurred.

**Inputs**:
- `changes/<change-name>/proposal.md` (original intent)
- `changes/<change-name>/tasks.md` (what we meant to do)
- `changes/<change-name>/plans/**` (detailed plans)
- `changes/<change-name>/loops/implement-*.md` (what we actually changed)
- `docs/specs/**` (canonical truth)
- `changes/<change-name>/specs/**` (existing delta specs, if any)

**Outputs**:
- `changes/<change-name>/loops/reconcile.md`
- `changes/<change-name>/specs/**` (if drift detected)
- `changes/<change-name>/state.md` (update `Reconcile.Status: complete`)

3. Update phase to `reconciling`.

4. Report:
   - What was analyzed
   - Whether drift was detected
   - What delta specs were generated (if any)
   - Next command: `/sdd/finish <change-name>`

## Reconcile Outcomes

### No Drift Detected

Implementation matches existing canonical specs. No delta specs generated.

**Next**: `/sdd/finish <change-name>` will proceed without sync.

### Drift Detected

Implementation introduced new or modified behavior. Delta specs generated via `sdd/specsmith` in reconcile mode.

**Review**: Check `changes/<change-name>/specs/**` for generated delta specs.

**Next**: `/sdd/finish <change-name>` will run sync to merge delta specs into canonical.

## When Reconcile Generates Specs

Reconciler invokes `sdd/specsmith` (in reconcile mode) when:

- Bug fix revealed undocumented behavior that should be specified
- Quick experiment introduced new capabilities worth preserving
- Full lane implementation evolved beyond original delta specs
- Implementation discovered edge cases not covered in original specs

## State After Reconcile

```markdown
## Phase

reconciling

## Reconcile

- Required: yes
- Status: complete
```
