---
name: sdd-task-format
description: Canonical structure for SDD tasks.md (checkboxes, requirements, validation)
---

# Task Format

The `tasks.md` file breaks delta specs into committable, dependency-ordered tasks. Each task keeps the repo green when completed.

## File Structure

```markdown
# Tasks

## [ ] 01: <Short task title>

### Requirements

- <Verbatim requirement line from delta spec>
- <Another requirement line>

### Validation

- <Specific validation step>
- <Another validation step>

---

## [ ] 02: <Short task title>

### Requirements

- <Verbatim requirement line>

### Validation

- <Validation step>

---

## [ ] 03: <Short task title>

...
```

## Checkbox States

| State | Meaning |
|-------|---------|
| `[ ]` | Pending — not yet started |
| `[-]` | In progress — being planned or implemented |
| `[x]` | Complete — implemented and validated |

Only ONE task should be `[-]` at a time.

## Task Numbering

- Always use 2-digit zero-padded numbers: `01`, `02`, `03`, ... `10`, `11`, ...
- Numbers indicate dependency order (lower numbers must complete before higher).
- Gaps are allowed if tasks are removed during reconciliation.

## Requirements Section Rules

**Critical**: Requirements MUST be verbatim copies from the delta specs.

- Copy the exact requirement line from `changes/<change-name>/specs/**`.
- Do NOT paraphrase, summarize, or reword.
- A task may include requirements from multiple delta specs if they're logically cohesive.
- Every requirement line from every delta spec must appear in exactly one task.

Good:
```markdown
### Requirements

- THE SYSTEM SHALL accept a --verbose flag.
- THE SYSTEM SHALL log debug output when --verbose is set.
```

Bad:
```markdown
### Requirements

- Add verbose flag support (paraphrased - DON'T DO THIS)
```

## Validation Section Rules

Each task must have concrete validation steps that prove the task is complete:

- Command to run (test, build, lint)
- Expected output or behavior to verify
- Manual check if automated check isn't possible

Good:
```markdown
### Validation

- Run `./cli --verbose` and verify flag is recognized (no "unknown flag" error).
- Run `./cli --help` and verify --verbose appears in output.
- Run `npm test -- --grep "verbose"` and verify tests pass.
```

Bad:
```markdown
### Validation

- Make sure it works (too vague)
```

## Dependency Ordering

Tasks must be ordered so that:

1. Each task can be completed independently of later tasks.
2. After completing task N, the repo compiles/builds/passes tests.
3. Task N+1 may depend on task N being done, but not vice versa.

If you discover a dependency violation, reorder tasks or split them.

## Horizontal Rule Separator

Use `---` between tasks for visual separation.

## Reconciliation Rules

When `/sdd/tasks` is re-run:
- If any task is `[-]` or `[x]`, DO NOT overwrite without user confirmation.
- Tasks may be reordered if dependencies change.
- New tasks may be inserted; completed tasks should not be removed.

## Checklist Before Finishing

- [ ] All requirement lines are verbatim from delta specs
- [ ] Every delta spec requirement appears in exactly one task
- [ ] Tasks are dependency-ordered (later tasks may depend on earlier, not reverse)
- [ ] Each task has concrete validation steps
- [ ] Task numbers are 2-digit zero-padded
- [ ] `---` separators between tasks
- [ ] File ends with pinned `## User Feedback` section
