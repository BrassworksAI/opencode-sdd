# Bun Script Rules

Guidelines for writing Bun scripts that are bundled with skills.

## Goals

- Predictable: scripts should behave the same across machines
- Safe: avoid surprising writes or destructive operations
- Easy to invoke: single command, clear usage

## Script structure

- Put scripts under `scripts/`
- When documenting invocation, use `{{{SKILL_INSTALL_PATH}}}/<skill-name>/scripts/<script>.ts`
- Use descriptive, kebab/underscore-case names like `init_skill.ts`, `quick_validate.ts`
- Include a short docstring at top with purpose and usage

Example:

```ts
/**
 * Validates an OpenCode skill directory.
 *
 * Usage:
 *   bun run {{{SKILL_INSTALL_PATH}}}/my-skill/scripts/quick_validate.ts -- <skill-dir>
 */
```

## CLI args

- Validate args early
- Print usage and exit with code `2` on invalid usage
- Prefer explicit flags over positional args for non-trivial scripts

## Exit codes

Use consistent codes:

- `0`: success
- `1`: general failure
- `2`: invalid usage
- `3`: validation failed

## Output

- `console.log` for normal output
- `console.error` for errors
- Keep output concise and actionable
- If you support `--json`, ensure it’s stable and documented

## File operations

- Use `node:fs/promises` and `node:path`
- Create directories with `mkdir({ recursive: true })`
- Avoid deleting files by default
- If deletion is necessary, require an explicit `--force` flag and print what will be deleted

## Dependencies

- Prefer zero-dependency scripts
- If dependencies are needed, prefer small, well-known packages
- Avoid network fetch at runtime unless explicitly required

## Script entrypoint

- Keep scripts single-purpose and small.
- Put side effects in a clear `main()`.
- Prefer `main().catch((err) => { console.error(err); process.exit(1); })`.
