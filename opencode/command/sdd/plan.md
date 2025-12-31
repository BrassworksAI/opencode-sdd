---
name: sdd/plan
description: Create implementation plan for current task
agent: sdd/forge
---

<skill>sdd-state-management</skill>
<skill>counsel</skill>
<skill>research</skill>

# Plan

Create an implementation plan for the current task.

## Arguments

- `$ARGUMENTS` - Change set name (optionally: `<name> <task-number>`)

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `plan` or `implement`
2. Read `changes/<name>/tasks.md`
3. Identify current task (first pending, or specified task number)
4. List existing plans in `changes/<name>/plans/`

### Research Phase (Critical)

Before writing any plan, **research the codebase** using the `research` skill:

1. **Consult librarian** to understand:
   - Where the changes need to happen (exact file paths)
   - What patterns exist for similar functionality
   - What integration points are involved
   - What tests exist that might need updates

2. **Iterate with librarian** until you have:
   - Specific file paths for all changes
   - Understanding of existing patterns to follow
   - Clear picture of integration points

A plan without proper research is just guessing. Do the research first.

### Consulting Archimedes (Optional)

For complex tasks, consult Archimedes to stress-test the approach:

> Use Task tool with `archimedes` agent.
> Provide: task requirements, proposed approach, research findings
> Ask for: gaps, risks, alternative approaches

### Plan Structure

Create `changes/<name>/plans/<NN>.md` where NN is zero-padded task number:

```markdown
# Plan: Task <N> - <Task Title>

## Objective

What this plan accomplishes (from task description).

## Requirements

- <REQ-ID>: <requirement text> (full lane)
- Or: <requirement from proposal> (quick/bug lane)

## Research Findings

Key findings from librarian research:
- <relevant patterns found>
- <integration points identified>
- <existing code to modify>

## Approach

High-level approach to implementation.

## Steps

### Step 1: <Title>

**Files:** `path/to/file.ts`

**Changes:**
- What changes to make
- Specific modifications

### Step 2: <Title>

...

## Validation

How to verify the implementation:
- [ ] Test case 1
- [ ] Test case 2
- [ ] Acceptance criteria from requirements

## Risks

Any implementation risks or concerns.
```

### Plan Quality

A good plan:
- Is based on actual codebase research (not assumptions)
- Has clear, specific file paths (verified to exist)
- Describes actual code changes (not vague directions)
- Follows patterns found in the codebase
- Includes validation steps

### Completion

When plan is ready:

1. Mark task as `in_progress` in tasks.md
2. Update state.md phase to `implement`
3. Suggest running `/sdd/implement <name>`
