---
name: skill-creator
description: Collaboratively design and author agent skills with correct frontmatter, naming, and placement conventions.
---

# Skill Creator

## Optional: Quick fit check

Good fit if the user wants to:

- Create a new skill
- Improve an existing `SKILL.md`
- Decide where a skill should live (project/global/custom)

Not needed if the user is asking for a normal code change, debugging help, or a one-off question.

If this skill isn’t needed, ignore it and continue.

## Outcomes

When used, this skill helps produce:

- A new skill folder containing a valid `SKILL.md`
- A clear, discovery-friendly `description`
- Optional supporting docs in `references/` to keep `SKILL.md` concise

## Core rules

- Skills are discovered by **frontmatter only**: `name` + `description`.
- `SKILL.md` must start with YAML frontmatter. See `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/skill-rules.md`.
- Skill `name` must match the directory name and pass naming constraints.
- Prefer progressive disclosure:
  - Keep `SKILL.md` short and actionable.
  - Put long or rarely-needed details in `references/`.

## Workflow

### 1) Gather requirements (collaborative)

This is a collaborative workflow: ask questions first, then draft, then confirm.

Ask for:

- Skill name (kebab-case)
- A single-sentence `description` that makes the discovery decision easy
- What the skill should reliably produce (outputs/artifacts)
- What questions the agent must ask up front (inputs)
- Guardrails (what to avoid, what not to assume)

Do not generate files until the user confirms the name, description, and placement.

### 2) Choose placement (three options)

Ask the user to choose where the new skill should live:

1. **Project local (Recommended)**: `{{{SKILL_LOCAL_PATH}}}/<skill-name>/SKILL.md`
2. **Global**: `{{{SKILL_GLOBAL_PATH}}}/<skill-name>/SKILL.md`
3. **Other (absolute path)**: user provides an absolute path

Rules for **Other**:

- If the provided path ends with `SKILL.md`, treat it as the exact file path.
- Otherwise treat it as a directory path and place the skill at `<path>/<name>/SKILL.md`.
- If the path isn’t absolute, ask again for an absolute path.

### 3) Validate before writing

Before creating files, verify:

- `name` matches rules (see `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/skill-rules.md`)
- The directory name will exactly match `name`
- `description` is 1–1024 characters and describes when to use the skill

### 4) Author `SKILL.md`

Start from `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/skill-template.md` and fill it in.

Guidelines:

- Do not include a "when to use me" body section; put that information in frontmatter `description`.
- Prefer concise, step-based workflows.
- If the workflow is complex, include a small checklist or gates.

### 4a) Template files (`.tmpl.md`)

If your skill references scripts or supporting files using path variables, name the file with a `.tmpl.md` suffix instead of `.md`.

**When to use `.tmpl.md`:**

- The skill bundles scripts that need to be invoked with a known install path
- Reference files point to other files within the skill using path variables
- Any file that contains `{{{SKILL_INSTALL_PATH}}}`, `{{{SKILL_LOCAL_PATH}}}`, or `{{{SKILL_GLOBAL_PATH}}}`

**How it works:**

- Files named `*.tmpl.md` are rendered at install time with variables substituted
- The output is placed in a cache directory (e.g., `.cache/skills-rendered/opencode/`)
- Symlinks point to the rendered output, not the source template
- Non-template files (`*.md`) are symlinked directly to the source

**Available template variables:**

| Variable | Description | Example (OpenCode global) |
|----------|-------------|---------------------------|
| `{{{SKILL_INSTALL_PATH}}}` | Path to installed skill location | `$HOME/.config/opencode/skill` |
| `{{{SKILL_LOCAL_PATH}}}` | Project-local skill directory | `.opencode/skill` |
| `{{{SKILL_GLOBAL_PATH}}}` | Global skill directory | `~/.config/opencode/skill` |

**Example usage in a skill:**

Referencing a script:
```markdown
Run the validator:
`bun {{{SKILL_INSTALL_PATH}}}/my-skill/scripts/validate.ts <path>`
```

Referencing a file in `references/`:
```markdown
See `{{{SKILL_INSTALL_PATH}}}/my-skill/references/api-conventions.md` for naming rules.
```

**Conflict detection:**

If both `SKILL.md` and `SKILL.tmpl.md` exist in a skill directory, the install will fail with an error. Choose one or the other.

### 5) Add optional `references/`

Only add `references/` files when they keep the main `SKILL.md` smaller and more usable.

Good candidates:

- Company-specific conventions
- API references
- Codebase-specific patterns
- Templates that are too long for the main skill body

**How to link to references:**

When your skill points to files in `references/`, use the full templated path:

```markdown
See `{{{SKILL_INSTALL_PATH}}}/my-skill/references/api-conventions.md` for details.
```

This ensures the agent can locate the file regardless of install location. If your skill links to any `references/` files this way, name the skill file `SKILL.tmpl.md` (see section 4a).

If you are considering bundling scripts in the new skill, use `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/bun-runtime.md` to decide if scripts are worth it.

## How to write a good `description`

A strong `description` makes the discovery decision obvious.

Patterns that work well:

- Start with an action verb: “Design…”, “Generate…”, “Review…”, “Refactor…”, “Draft…”, “Validate…”
- Include the artifact produced: “...a `SKILL.md`…”, “...a release checklist…”, “...a migration plan…”
- Include the context boundary: “...for this tool…”, “...for our monorepo…”, “...without changing runtime behavior…”

Examples:

- “Create a scoped `SKILL.md` and references for consistent API endpoint changes in this repo.”
- “Draft agent skills for repeatable workflows, keeping `SKILL.md` concise and using `references/` for details.”

## References

- Skill rules: `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/skill-rules.md`
- Skill template: `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/skill-template.md`

## References (Bun scripts, optional)

Only relevant if the skill you are creating will bundle scripts.

- Bun runtime: `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/bun-runtime.md`
- Bun script rules: `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/bun-script-rules.md`
- Script output patterns: `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/script-output-patterns.md`
- Script workflows: `{{{SKILL_INSTALL_PATH}}}/skill-creator/references/script-workflows.md`
