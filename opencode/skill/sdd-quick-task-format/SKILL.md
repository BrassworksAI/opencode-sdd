---
name: sdd-quick-task-format
description: Task format for bug/quick lanes (derived from proposal, not delta specs)
---

# Quick-Task Format

The `tasks.md` file for bug/quick lanes differs from full lane: tasks are derived from **proposal acceptance criteria**, not delta specs.

## Key Differences from Full Lane Tasks

| Aspect | Full Lane | Bug/Quick Lane |
|--------|-----------|----------------|
| Source | Delta specs (verbatim requirements) | Proposal (acceptance criteria) |
| Language | Formal spec language (THE SYSTEM SHALL...) | Practical criteria |
| Typical count | Multiple tasks | Usually single task (01) |

## File Structure

```markdown
# Tasks

## [ ] 01: <Short task title>

### Acceptance Criteria

- <criterion from proposal>
- <criterion from proposal>

### Validation

- <specific validation step>
- <specific validation step>

---

## User Feedback

(Leave blank if approved. If you want changes, write notes here and rerun the command.)
```

## Checkbox States

Same as full lane:

| State | Meaning |
|-------|---------|
| `[ ]` | Pending — not yet started |
| `[-]` | In progress — being planned or implemented |
| `[x]` | Complete — implemented and validated |

## Acceptance Criteria Section Rules

**Source**: Extract from proposal.md

For **bug lane**, acceptance criteria come from:
- Definition of Done items
- Expected behavior (derived from Expected vs Actual section)
- Implicit success criteria from Symptom description

For **quick lane**, acceptance criteria come from:
- Acceptance Criteria section in proposal
- Goal decomposition (if goal has multiple parts)

**Style**: Use practical, testable language:

Good:
```markdown
### Acceptance Criteria

- Login button works on mobile browsers
- No JavaScript errors in console during login flow
- User sees success message after login
```

Bad:
```markdown
### Acceptance Criteria

- THE SYSTEM SHALL authenticate users (too formal for quick lane)
- Fix the bug (too vague)
```

## Validation Section Rules

Same as full lane — concrete, runnable validation steps:

```markdown
### Validation

- Run `npm test -- --grep "login"` and verify tests pass.
- Test manually on Chrome mobile emulator.
- Check browser console for errors during login flow.
```

## When to Use Multiple Tasks

Bug/quick lanes typically produce a single task (`01`), but may produce multiple if:

1. **Sequential dependencies**: Task 02 can't start until task 01 completes
2. **Logical separation**: Distinct pieces of work that could land separately
3. **User requested decomposition**: Proposal explicitly lists multiple deliverables

## Task Numbering

Same as full lane: 2-digit zero-padded (`01`, `02`, etc.)

## Reconciliation

Bug/quick lane tasks are generated once during `/sdd/bug` or `/sdd/quick` and not regenerated. The reconcile phase (`/sdd/reconcile`) validates specs, not tasks.

## Checklist Before Finishing

- [ ] All acceptance criteria are from proposal (not invented)
- [ ] Acceptance criteria are testable
- [ ] Each task has concrete validation steps
- [ ] Task numbers are 2-digit zero-padded
- [ ] File ends with pinned `## User Feedback` section
