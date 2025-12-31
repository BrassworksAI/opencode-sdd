---
name: sdd/finish
description: Close the change set and sync specs
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>spec-format</skill>

# Finish

Close the change set and sync delta specs to canonical.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `finish`
2. Verify prerequisites based on lane:
   - **Full lane**: Reconciliation complete
   - **Quick/Bug lane**: All tasks complete

### Sync Delta Specs (Full Lane Only)

For each delta spec in `changes/<name>/specs/`:

1. **Read the delta spec**
2. **Apply to canonical**: 
   - New capabilities: Create new file in `specs/`
   - Modified requirements: Update existing file in `specs/`
   - Removed requirements: Remove from existing file in `specs/`
3. **Verify sync**: Ensure canonical reflects all changes

### Update State

Update `changes/<name>/state.md`:

```markdown
## Phase

complete

## Completed

<timestamp>
```

### Cleanup Options

Ask user about cleanup preference:

1. **Keep all artifacts**: Leave `changes/<name>/` intact for history
2. **Archive**: Move to `changes/archive/<name>/`
3. **Remove**: Delete `changes/<name>/` (delta specs already synced)

### Summary Report

Provide completion summary:

- What was accomplished
- Files changed
- Specs added/modified/removed (full lane)
- Any notes or follow-up items
