---
name: sdd/bug
description: Quick-start a bug fix change set
agent: sdd/forge
---

<skill>sdd-state-management</skill>

# Bug Fix

Quick-start a bug fix change set. This is a shortcut that initializes with bug lane defaults.

## Arguments

- `$ARGUMENTS` - Name for the bug fix (kebab-case)

## Instructions

### Initialize

1. Create `changes/<name>/` structure
2. Initialize state.md with bug lane:
   ```markdown
   # SDD State: <name>

   ## Phase

   proposal

   ## Lane

   bug

   ## Pending

   - Fill in bug details in proposal.md
   ```

### Proposal Template

Create `changes/<name>/proposal.md` with bug-specific template:

```markdown
# Bug Fix: <name>

## Current Behavior

What is happening now (the bug).

## Expected Behavior

What should happen instead.

## Reproduction Steps

1. Step to reproduce
2. ...

## Root Cause

(To be filled in after investigation)

## Fix Approach

(To be filled in after investigation)

## Validation

How to verify the fix works.
```

### Next Steps

Guide user to:
1. Fill in current/expected behavior
2. Investigate root cause
3. Document fix approach
4. Run `/sdd/tasks <name>` when ready
