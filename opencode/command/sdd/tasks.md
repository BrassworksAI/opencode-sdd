---
name: sdd/tasks
description: Create implementation tasks from specs or proposal
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>spec-format</skill>

# Tasks

Create implementation tasks for the change set.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `tasks`
2. Determine source based on lane:
   - **Full lane**: Read delta specs from `changes/<name>/specs/`
   - **Quick/Bug lane**: Read `changes/<name>/proposal.md`

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
- <REQ-ID> (full lane only)
- Or: <requirement description from proposal>

**Description:**
What this task accomplishes.

**Validation:**
How to verify this task is complete.

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

### For Full Lane

- Every requirement in delta specs must map to at least one task
- Tasks reference requirement IDs
- Use `spec-format` skill to understand requirement structure

### For Quick/Bug Lane

- Tasks derive from proposal directly
- No requirement IDs (no specs exist)
- Focus on the specific change/fix described

### Completion

When tasks are defined:

1. Update state.md phase to `plan`
2. Suggest running `/sdd/plan <name>` to plan first task
