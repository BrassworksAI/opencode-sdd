---
name: brainstorm
description: Explore problem space and develop seed document
---

# Brainstorm / Ideation

Explore the problem space collaboratively to develop a seed document.

## Required Skills (Must Load)

You MUST load and follow these skills before doing anything else:

- `research`

If any required skill content is missing or not available in context, you MUST stop and ask the user to re-run the command or otherwise provide the missing skill content. Do NOT proceed without them.

## Inputs

- Target location for `seed.md`. Ask the user for a folder or file path. If they provide a folder, use `<target>/seed.md`. If they provide a file path, use that file. If they provide nothing, default to `seed.md` in the current working directory.

## Instructions

### Setup

Run:

- `cat <seed-path> 2>/dev/null || echo "No seed found"`

### Research Phase (As Needed)

During ideation, research can help ground ideas in reality:

1. **Use `research` skill** when you need to understand:
   - Does something similar already exist in the codebase?
   - What constraints does the current architecture impose?
   - What patterns are already established?

2. **Use research to inform ideation**, not constrain it:
   - Research helps identify what's possible
   - But don't let existing patterns limit creative thinking
   - Note constraints, then explore solutions

### Ideation Process

This is a **collaborative conversation**. Your job is to:

1. **Understand the problem**: Ask clarifying questions about what the user wants to build
2. **Explore constraints**: What are the boundaries? What's out of scope?
3. **Surface assumptions**: What's being taken for granted?
4. **Identify risks**: What could go wrong?
5. **Document incrementally**: Update seed.md and state.md `## Notes` as understanding develops

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

If the user wants critique, offer to review for contradictions, missing cases, and unaddressed risks. Address any serious issues before moving on.

### Completion

When seed is solid and user explicitly approves:

1. Save the finalized seed to `<seed-path>`
2. Suggest drafting a proposal next (optionally via `/product/proposal`)
