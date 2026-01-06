---
description: Initialize a new SDD change set
argument-hint: <change-name>
---

# Initialize Change Set

Create a new SDD change set with the given name.

> **SDD Process**: If you're unsure how state management works, read `augment/skills/sdd-state-management.md`.

## Arguments

- `$ARGUMENTS` - Name for the change set (kebab-case)

## Instructions

> **Scope**: This command ONLY creates folder structure and initial template files. Do NOT begin brainstorming, research, code analysis, or any other work. Scaffold and stop.

1. **Validate name**: Ensure name is kebab-case, no spaces, lowercase
2. **Check for conflicts**: Verify `changes/<name>/` doesn't already exist
3. **Create structure**:
   ```
   changes/<name>/
     state.md
     proposal.md
   ```
4. **Initialize state.md**:
   ```markdown
   # SDD State: <name>

   ## Phase

   ideation

   ## Lane

   (not yet selected)

   ## Pending

    - Select lane (full/vibe/bug) during proposal
   ```
5. **Initialize proposal.md** with empty template:
   ```markdown
   # Proposal: <name>

   ## Problem

   (What problem are we solving?)

   ## Goals

   (What does success look like?)

   ## Non-Goals

   (What are we explicitly NOT doing?)

   ## Approach

   (High-level approach - freeform)
   ```
6. **Report**: Confirm creation and tell the user they can run `/sdd:brainstorm` or `/sdd:proposal` next. **Stop here — do not continue with any further work.**
