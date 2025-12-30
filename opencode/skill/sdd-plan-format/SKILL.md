---
name: sdd-plan-format
description: Canonical structure for SDD implementation plans (plans/NN.md)
---

# Plan Format

Each `plans/<NN>.md` file contains a detailed implementation plan for one task from `tasks.md`.

## File Structure

```markdown
# Plan: Task <NN>

## Task Summary

<Copy of task header and requirements from tasks.md>

## Files to Change

| File | Change Type | Description |
|------|-------------|-------------|
| `path/to/file.ts` | modify | Add verbose flag handling |
| `path/to/new-file.ts` | create | New utility module |
| `tests/file.test.ts` | modify | Add tests for verbose flag |

## Implementation Steps

### Step 1: <Short description>

**File**: `path/to/file.ts`

**Changes**:
- <Specific change 1>
- <Specific change 2>

**Code sketch** (if helpful):
```typescript
// Pseudocode or actual code showing the change
```

### Step 2: <Short description>

**File**: `path/to/another-file.ts`

**Changes**:
- <Specific change>

### Step 3: ...

## Validation Commands

```bash
# Build
npm run build

# Type check
npm run typecheck

# Run relevant tests
npm test -- --grep "verbose"

# Manual verification
./cli --verbose
./cli --help | grep verbose
```

## Rollback Notes

If this task fails validation after implementation:
- <What to revert>
- <How to restore previous state>

## Dependencies

- Requires task <NN-1> to be complete (if applicable)
- External dependencies: <none / list them>

## Open Questions

- <Any uncertainties to resolve during implementation>

---

## User Feedback

(Leave blank if approved. If you want changes, write notes here and rerun the command.)
```

## Required Sections

Every plan MUST include:

1. **Task Summary** — Copy from tasks.md so the plan is self-contained
2. **Files to Change** — Table listing every file that will be touched
3. **Implementation Steps** — Ordered steps with specific changes per file
4. **Validation Commands** — Exact commands to run to verify success

## Optional Sections

- **Rollback Notes** — How to undo if something goes wrong
- **Dependencies** — What must be true before starting
- **Open Questions** — Uncertainties to resolve during implementation

## Implementation Steps Rules

Each step should be:
- Focused on ONE file (or a tightly coupled set of files)
- Specific enough that the implementer doesn't have to make design decisions
- Ordered so earlier steps don't depend on later steps

Good step:
```markdown
### Step 2: Add verbose flag to CLI parser

**File**: `src/cli/parser.ts`

**Changes**:
- Add `--verbose` to the `options` object in `parseArgs()`
- Type: boolean, default: false
- Short alias: `-v`

**Code sketch**:
```typescript
options: {
  verbose: {
    type: 'boolean',
    short: 'v',
    default: false,
    description: 'Enable verbose output'
  }
}
```
```

Bad step:
```markdown
### Step 2: Add the flag

Add verbose flag support somehow.
```

## Validation Commands Rules

- List the EXACT commands to run (copy-pasteable)
- Include build, typecheck, and relevant tests
- Include manual verification steps if automated tests don't cover everything
- Commands should pass after implementation is complete

## Granularity

The plan should be detailed enough that:
- A different agent (implementer) can execute it without asking questions
- Each step is unambiguous
- The validation proves the task is done

Rule: If you'd need to "figure something out" during implementation, the plan isn't detailed enough.

## Task Number Format

- Accept `1` or `01` as input
- Always output as 2-digit zero-padded: `01`, `02`, etc.
- File name: `plans/01.md`, `plans/02.md`, etc.

## Checklist Before Finishing

- [ ] Task summary copied verbatim from tasks.md
- [ ] Every file to be changed is listed in the table
- [ ] Steps are specific enough for blind execution
- [ ] Validation commands are exact and copy-pasteable
- [ ] Steps are ordered correctly (no forward dependencies)
- [ ] File ends with pinned `## User Feedback` section
