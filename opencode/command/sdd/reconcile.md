---
name: sdd/reconcile
description: Verify implementation matches specifications
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>spec-format</skill>

# Reconcile

Verify that implementation matches the delta specifications.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `reconcile` and lane is `full`
2. Read all delta specs from `changes/<name>/specs/`
3. Read `changes/<name>/tasks.md` for context

### Reconciliation Process

For each requirement in delta specs:

1. **Locate implementation**: Find the code that implements this requirement
2. **Verify completeness**: Does the implementation fully satisfy the requirement?
3. **Check acceptance criteria**: Are all criteria met?
4. **Document finding**: Pass, fail, or partial

### Reconciliation Report

Create or update `changes/<name>/reconciliation.md`:

```markdown
# Reconciliation: <name>

## Summary

X of Y requirements verified.

## Findings

### <REQ-ID>: <Title>

**Status:** pass | fail | partial

**Implementation:** `path/to/file.ts:123`

**Notes:** Any relevant observations.

---

### <REQ-ID>: <Title>

...

## Unimplemented Requirements

- <REQ-ID>: <reason>

## Implementation Without Specs

- `path/to/file.ts`: <description of unspecced change>
```

### Handling Gaps

**Unimplemented requirements:**
- Return to tasks/plan/implement phases
- Or: Remove requirement from specs (with rationale)

**Implementation without specs:**
- Add missing specs (return to specs phase)
- Or: Remove the implementation
- Or: Document as intentional (tech debt, etc.)

### Completion

When reconciliation passes (all requirements verified):

1. Update state.md phase to `finish`
2. Suggest running `/sdd/finish <name>`
