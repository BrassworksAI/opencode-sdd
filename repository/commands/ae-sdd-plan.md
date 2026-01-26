---
description: Research, plan, and prepare for implementation
---

# Plan

Research the codebase and create an implementation plan. Full lane plans one task at a time; vibe/bug combines discovery + tasking + planning into one pass.

## Inputs

> [!IMPORTANT]
> Resolve the change set by running `ls changes/ | grep -v archive/`. If exactly one directory exists, use it. Only prompt the user when multiple change sets are present.

## Instructions

Load `sdd-state-management`, `research`, and `keep-current` skills. Read state.md and tasks.md. Apply state entry check.

**Full lane**: Identify current task. If `[o]` exists, plan it (never replace without user approval). Otherwise, pick first `[ ]`, mark it `[o]`. Read task from tasks.md (which contains the spec) and all `thoughts/` (discovery outputs). Research codebase for patterns, paths, integration, tests. Update state.md notes.

**Vibe/bug lane**: Read `thoughts/` and research codebase patterns, changes needed, risks.

This is a dialogue. Before writing, summarize research findings. If a path is clear, present your recommendation with reasoning. If you see questions, trade-offs, or risks, discuss them with opinions and recommendations. Collaborate through back-and-forth until direction is right.

**Plan requirements**: Be unambiguous. Prose-only allowed for simple edits. For complex logic, include pseudocode or actual code. Include exact file paths. Resolve choices—don't leave them to implementer.

**Full lane**: Create `changes/<name>/plans/<NN>.md` with objective, requirements (from task), research findings, steps with file paths/changes, validation. This is the last stop to convince the user—be exhaustive so implementer executes without interpretation.

**Vibe/bug lane**: Create `changes/<name>/plan.md` with goal, research findings, strategy, changes with file paths, validation. Show full intent with code/pseudocode. Exhaustive enough for direct execution.

When user explicitly approves, update state.md: `## Phase Status: complete`, clear `## Notes`, suggest `/sdd/implement <name>`. Questions/feedback don't count as approval.

## Examples

**Full lane planning with dialogue:**

```text
Input: "password-reset" (full lane, task 2 pending)
Output: "Validated tasks.md—no in-progress tasks. Marked task 2 in-progress. Read task 2 and thoughts/. Research shows extending auth/login/validator.ts fits DRY. One concern: validator is getting large. Address now or focus on reset?"
       User: "Stay focused on reset. Show me the plan."
       Output: "Created plans/02.md with exhaustive breakdown: file-by-file changes, code snippets for validator.js, auth/routes.js, tests, validation checklist."
```

**Vibe lane with clear recommendation:**

```text
Input: "bug-fix" (vibe lane)
Output: "Read thoughts/. Found consistent fix pattern in router/middleware.ts. Applying that keeps codebase uniform. Created plan.md with exhaustive breakdown: exact changes to middleware.ts, code snippet, test updates, validation steps."
```
