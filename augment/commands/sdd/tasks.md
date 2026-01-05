---
description: Create implementation tasks from specs (full lane)
argument-hint: <change-set-name>
---

# Tasks

Create implementation tasks for the change set. This command is for **full lane** only.

> **Note**: Vibe and bug lanes skip this command. They use `/sdd/plan` which combines research, tasking, and planning into a single `plan.md` file.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `tasks` and lane is `full`
2. Read delta specs from `changes/<name>/specs/`

If lane is `vibe` or `bug`, redirect user to `/sdd/plan` instead.

### Task Structure

Create `changes/<name>/tasks.md`:

```markdown
# Tasks: <name>

## Overview

Brief summary of what these tasks accomplish.

## Tasks

### Task 1: <Title>

**Status:** pending | in_progress | complete

**Requirements:**
- "<EARS requirement line>" (full lane - quote from delta specs)
- Or: <requirement description from proposal>

**Description:**
What this task accomplishes.

**Acceptance Criteria:**
- <Testable criterion>
- <Testable criterion>

---

### Task 2: <Title>

...
```

### Task Ordering

Order tasks by dependency:
1. Foundation tasks first (models, types, interfaces)
2. Core implementation tasks
3. Integration tasks
4. Validation/test tasks

### Task Granularity

Each task should be:
- Completable in one implementation session
- Independently testable
- Clear on what "done" means

### Requirement Mapping

- Every requirement in delta specs must map to at least one task
- Tasks reference requirements by quoting the EARS line
- Use spec format guidance to understand requirement structure

### Completion

When tasks are defined:

1. Update state.md phase to `plan`
2. Suggest running `/sdd/plan <name>` to plan first task
