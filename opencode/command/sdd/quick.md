---
name: sdd/quick
description: Quick-start a small enhancement change set
agent: sdd/forge
---

<skill>sdd-state-management</skill>

# Quick Enhancement

Quick-start a small enhancement change set. This is a shortcut that initializes with quick lane defaults.

## Arguments

- `$ARGUMENTS` - Name for the enhancement (kebab-case)

## Instructions

### Initialize

1. Create `changes/<name>/` structure
2. Initialize state.md with quick lane:
   ```markdown
   # SDD State: <name>

   ## Phase

   proposal

   ## Lane

   quick

   ## Pending

   - Fill in enhancement details in proposal.md
   ```

### Proposal Template

Create `changes/<name>/proposal.md` with quick-specific template:

```markdown
# Quick Enhancement: <name>

## Summary

Brief description of the enhancement.

## Motivation

Why this enhancement is needed.

## Changes

What will be changed/added.

## Validation

How to verify the enhancement works.
```

### Next Steps

Guide user to:
1. Fill in the proposal
2. Run `/sdd/tasks <name>` when ready
