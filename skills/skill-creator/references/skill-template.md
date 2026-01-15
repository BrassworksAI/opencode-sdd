# Skill Template

Copy this into a new skill folder as `SKILL.md` and then tailor it.

```markdown
---
name: <skill-name>
description: <One sentence describing when this skill should be used>
---

# <Skill Title>

## Collaboration

This skill is meant to be used collaboratively:

- Ask the user for missing inputs.
- Summarize your intended outputs and file changes.
- Wait for confirmation before creating or editing files.

## Optional: Quick fit check

Good fit if the user wants to:

- <goal 1>
- <goal 2>

Not needed if the user wants to:

- <common mismatch 1>
- <common mismatch 2>

If this skill isn’t needed, ignore it and continue.

## What I do

Outputs/artifacts this skill helps produce:

- <artifact 1>
- <artifact 2>

## Inputs I need

Questions to ask up front (only include questions that materially affect correctness):

- <question 1>
- <question 2>

## Workflow

1. <Step 1>
2. <Step 2>
3. <Step 3>

## Guardrails

- <constraints>
- <things to avoid>
- <things not to assume>

## Examples

### Example 1

User:

- "<example user request>"

Assistant:

- <what you will do>
- <what you will ask next>
```

Notes:

- Put “when to use” in frontmatter `description`, not in a separate body section.
- Prefer concise instructions and progressive disclosure (move long docs into `references/`).
