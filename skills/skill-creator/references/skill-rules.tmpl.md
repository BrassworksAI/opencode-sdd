# Skill Rules (Summary)

This file summarizes the OpenCode and Codex rules that affect skill discovery and loading.

## Discovery locations

OpenCode searches for skills in:

- Project config: `{{{SKILL_LOCAL_PATH}}}/<name>/SKILL.md`
- Global config: `{{{SKILL_GLOBAL_PATH}}}/<name>/SKILL.md`

Codex searches for skills in:

- Project config: `{{{SKILL_LOCAL_PATH}}}/<name>/SKILL.md`
- Global config: `{{{SKILL_GLOBAL_PATH}}}/<name>/SKILL.md`

OpenCode also supports Claude-compatible locations (optional compatibility):

- Project Claude-compatible: `.claude/skills/<name>/SKILL.md`
- Global Claude-compatible: `~/.claude/skills/<name>/SKILL.md`

## Skill frontmatter

Each `SKILL.md` must start with YAML frontmatter.

Only these fields are recognized by OpenCode and Codex:

- `name` (required)
- `description` (required)
- `license` (optional)
- `compatibility` (optional)
- `metadata` (optional, string-to-string map)

Unknown frontmatter fields are ignored.

## Name rules

`name` must:

- Be 1–64 characters
- Be lowercase alphanumeric with single hyphen separators
- Not start or end with `-`
- Not contain consecutive `--`
- Match the directory name that contains `SKILL.md`

Equivalent regex:

```
^[a-z0-9]+(-[a-z0-9]+)*$
```

## Description rules

- `description` must be 1–1024 characters
- Keep it specific: discovery is based on `name` + `description` only

## Permissions (optional)

Skill access can be controlled with pattern-based permissions in `opencode.json`:

```json
{
  "permission": {
    "skill": {
      "internal-*": "deny",
      "experimental-*": "ask",
      "*": "allow"
    }
  }
}
```
