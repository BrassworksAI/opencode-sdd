---
name: create-command
description: Create a new Codex custom prompt from a plain-English description
---

Before executing, read the Codex custom prompts docs: https://developers.openai.com/codex/custom-prompts/

## Task

1. Ask the user for the custom prompt spec in plain English.
2. Ask the user for the output path:
   - `(1) project` → `.codex/prompts/<name>.md`
   - `(2) global` → `~/.codex/prompts/<name>.md`
3. Choose a short, kebab-case name based on the spec.
   - Prompt names are the filename (no subdirectories).
4. Confirm required inputs and instruct the prompt to ask for them at runtime (do not use argument placeholders).
5. Write the new prompt markdown:
   - YAML frontmatter: `description`, optional `argument-hint`
   - Body: clear, step-based instructions tailored to the spec
6. Output: filepath and an example invocation like `/prompts:<name> ...`.

## Guardrails

- Keep it specific and runnable.
- Ask at most 5 follow-ups if required.
- Prefer explicit instructions over tool-specific syntax; Codex will decide when to run commands.
- Do not include shell execution syntax or inline command blocks.
