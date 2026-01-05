---
description: Explore problem space and develop seed document
argument-hint: <change-set-name>
---

# Brainstorm / Ideation

Explore the problem space collaboratively to develop a seed document.

## Arguments

- `$ARGUMENTS` - Change set name

## Instructions

### Setup

1. Read `changes/<name>/state.md` - verify phase is `ideation` or initialize if new
2. Check for existing `changes/<name>/seed.md`

### Research Phase (As Needed)

During ideation, research can help ground ideas in reality. **Delegate to @librarian** when you need to understand:

- Does something similar already exist in the codebase?
- What constraints does the current architecture impose?
- What patterns are already established?

Use research to inform ideation, not constrain it:
- Research helps identify what's possible
- But don't let existing patterns limit creative thinking
- Note constraints, then explore solutions

### Ideation Process

This is a **collaborative conversation**. Your job is to:

1. **Understand the problem**: Ask clarifying questions about what the user wants to build
2. **Explore constraints**: What are the boundaries? What's out of scope?
3. **Surface assumptions**: What's being taken for granted?
4. **Identify risks**: What could go wrong?
5. **Document incrementally**: Update seed.md as understanding develops

### Seed Document Structure

The seed is freeform but typically includes:

```markdown
# <Name> Seed

## Problem Statement

What problem exists and why it matters.

## Core Thesis

Key beliefs/assumptions underlying the solution.

## Proposed Approach

High-level direction (not detailed design).

## Constraints

What limits the solution space.

## Open Questions

What needs to be resolved.

## Risks

What could derail this.
```

### Critique

When the seed feels complete, suggest the user run `/sdd/tools/critique seed`:

- Identifies contradictions and missing cases
- Flags risks that aren't acknowledged
- Validates the seed is ready to become a proposal

If critique identifies serious issues, work with user to address them.

### Completion

When seed is solid and user approves:

1. Update state.md phase to `proposal`
2. Suggest running `/sdd/proposal <name>`
