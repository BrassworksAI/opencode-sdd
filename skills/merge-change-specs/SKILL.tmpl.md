---
name: merge-change-specs
description: Merge change-set specs in `changes/<name>/specs/` into canonical `specs/` deterministically.
---

# Merge Change Specs

## What this skill does

- Merges a change set at `changes/<name>/specs/**/*.md` into canonical `specs/**/*.md`.
- Produces a deterministic JSON report of what would change / did change.

## Inputs

- Change set name (the `<name>` in `changes/<name>/`).
- Should this be a dry run (no writes), or should it write to `specs/`?

## How to run the script

The implementation lives at `{{{SKILL_INSTALL_PATH}}}/merge-change-specs/scripts/merge-change-specs.ts`.

Supported flags:

- `--change <name>` (or `-c <name>`) (required)
- `--dry-run` (optional): compute and report changes without writing any files

Examples:

- Dry run first:
- `bun {{{SKILL_INSTALL_PATH}}}/merge-change-specs/scripts/merge-change-specs.ts --change auth-refresh --dry-run`
- `bun {{{SKILL_INSTALL_PATH}}}/merge-change-specs/scripts/merge-change-specs.ts --change auth-refresh`


### Output format

The script prints a single JSON object to stdout:

- `change`: the change set name
- `dryRun`: boolean
- `counts.created|modified|skipped`
- `created|modified|skipped`: arrays of canonical `specs/...` paths

If anything is invalid or unsafe, the script exits non-zero and prints a human-readable error to stderr.

## Workflow

1. Validate `changes/<name>/specs/` exists and contains `**/*.md`.
2. For each change-set spec:
   - Validate the markdown format using `{{{SKILL_INSTALL_PATH}}}/spec-format/scripts/validate-change-spec.ts`.
   - Parse YAML frontmatter and determine `kind: new|delta`.
   - Compute the canonical spec path by stripping `changes/<name>/specs/` and prefixing with `specs/`.
3. Apply changes deterministically:
   - `kind: new`: write canonical file as the change-set body (frontmatter removed).
     - If the canonical file already exists, it is overwritten and reported as `modified`.
   - `kind: delta`: patch the canonical spec by applying the delta file’s `### ADDED`, `### MODIFIED`, `### REMOVED` buckets under `## Requirements`.
4. Emit a deterministic JSON summary (created/modified/skipped) and fail fast on errors.

## Guardrails

- Refuses unsafe `--change` values (absolute paths or `..`).
- Fail fast if a `kind: delta` spec targets a missing canonical file.
- Do not reorder unrelated canonical content; only apply targeted edits.
- Keep ordering deterministic: stable traversal + stable output formatting.

## References

- Merge semantics: `{{{SKILL_INSTALL_PATH}}}/merge-change-specs/references/delta-merge-rules.md`
- Spec format + validator: `{{{SKILL_INSTALL_PATH}}}/spec-format/SKILL.md`
