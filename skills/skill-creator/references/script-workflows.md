# Script Workflows (When Present)

Use these workflow patterns when a skill bundles scripts.

## Prefer scripts for fragile steps

If a validation or scaffolding script exists, prefer running it over manual work.

Examples:

- Validate skill naming/frontmatter
- Scaffold a skill folder from a known-good template

## Iteration loop

1. Run the script
2. Review output and warnings
3. Fix issues
4. Re-run until clean

## Human-in-the-loop checkpoints

If a script produces generated files:

- Show the exact paths created/modified
- Ask the user to confirm before large changes
- Keep the generated template minimal; the user/agent should fill in specifics

## When manual work is better

Prefer manual editing when:

- The task is highly context-dependent
- The workflow is one-off
- The output requires judgment or prose quality
