# Bun Runtime

This reference provides guidance for using Bun when a skill includes scripts.

## When to use scripts

Use scripts when you want a small, deterministic helper that makes the skill more reliable and repeatable.

Good fit signals:

- The workflow is deterministic and repeated often.
- The same code would otherwise be re-authored each time (scaffolds, transforms, validations).
- The task is easy to get subtly wrong by hand (naming rules, frontmatter parsing, file layout).
- You want a single command with predictable output.

Bad fit signals:

- The task is mostly judgment, writing, or design decisions.
- The workflow depends heavily on repo-specific context that won’t generalize.
- The operation is one-off and low-risk.

Rule of thumb:

- Put judgment and policy in `SKILL.md`.
- Use scripts only for the mechanical steps.

## Prerequisites

Bun must be installed locally to run Bun-based scripts.

Check installation:

```bash
bun --version
```

If Bun is not installed, instruct the user to install it (do not install it for them):

- Docs: https://bun.sh/docs/installation

## Running Bun scripts

Typical patterns:

```bash
# Run a TypeScript/JavaScript script
bun run {{{SKILL_INSTALL_PATH}}}/my-skill/scripts/my_script.ts

# Pass args
bun run {{{SKILL_INSTALL_PATH}}}/my-skill/scripts/my_script.ts -- --flag value
```

If the repository uses a `package.json`, prefer defining stable script entries:

```json
{
  "scripts": {
    "skill:init": "bun run {{{SKILL_INSTALL_PATH}}}/my-skill/scripts/init_skill.ts",
    "skill:validate": "bun run {{{SKILL_INSTALL_PATH}}}/my-skill/scripts/validate_skill.ts"
  }
}
```

Then run:

```bash
bun run skill:init
bun run skill:validate
```

## File system access and safety

Bun does not use Deno-style permission flags. To keep scripts safe:

- Prefer operating within a single target directory.
- Require explicit paths as arguments (avoid implicit global writes).
- Print what will be created/modified before writing.
- Fail fast on missing/invalid paths.

## TypeScript guidance

- Prefer TypeScript for scripts.
- Keep scripts dependency-light.
- If adding dependencies, prefer a single lockfile strategy consistent with the repo.

## Common APIs

- `process.argv` for CLI args
- `process.cwd()` for current directory
- `node:fs/promises` for file operations
- `node:path` for path operations
